!include "MUI.nsh"
!include "WordFunc.nsh"

!ifndef PROD_NAME
    !define PROD_NAME "LeanPulse"
!endif
!ifndef PROD_VERSION
    !define /Date PROD_VERSION "%Y%m%d%H%M%S"
!endif
!ifndef PROD_TITLE
    !define PROD_TITLE "LeanPulse Tool"
!endif
!ifndef DEMO_MDL
    !define DEMO_MDL "SyDdemo.mdl"
!endif
!ifndef CUSTOMER
    !define CUSTOMER ""
!endif


!define INI_FILE "install.ini"

;***** Inscriptions dans la base de registres *****
!define REG_KEY "Software\LeanPulse\${PROD_NAME}"
!define REG_UNINSTKEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROD_NAME}"

;***** Nom du désinstalleur *****
!define UNINSTALLER "Uninstall.exe"


!insertmacro VersionCompare
!insertmacro WordAdd
!insertmacro WordReplace
!insertmacro WordFind
!insertmacro un.WordAdd
!insertmacro un.WordReplace


Var /GLOBAL matlabExe
Var /GLOBAL matlabPath


;--------------------------------
;Installer Configuration
Name "${PROD_NAME}"
Caption "${PROD_TITLE} Setup"
OutFile "..\..\#dist\${PROD_NAME} ${PROD_VERSION} ${CUSTOMER}.exe"
SetCompressor /SOLID lzma
InstType "Full"
InstallDirRegKey HKLM "${REG_KEY}" ""



;--------------------------------
;Interface Settings
!define MUI_ABORTWARNING
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\orange-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\orange-uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\orange.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Wizard\orange.bmp"
!define MUI_COMPONENTSPAGE_SMALLDESC



;--------------------------------------------------------------------------------------------------
;Install
;--------------------------------------------------------------------------------------------------


;User rights check*********************************************************************************
Function .onInit
    ClearErrors
    UserInfo::GetName
    IfErrors done ;done # This one means you don't need to care about admin or
		        # not admin because Windows 9x doesn't either
    Pop $0
    UserInfo::GetAccountType
    Pop $1
    StrCmp $1 "Admin" 0 suite
	;MessageBox MB_OK 'User "$0" is in the Administrators group'
    Goto done
suite:
    StrCmp $1 "" 0 exit
    ;MessageBox MB_OK 'Win9x with no Type'
    Goto done

exit: ; ni Admin ni vide
    MessageBox MB_OK|MB_ICONEXCLAMATION \
    "An administrator login is required to install ${PROD_NAME}."
    Quit
done:
FunctionEnd


;Welcome page**************************************************************************************
!define MUI_WELCOMEPAGE_TITLE "Welcome to the ${PROD_NAME} ${PROD_VERSION} Setup Wizard"
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of ${PROD_TITLE}\r\n\r\n$_CLICK"
!insertmacro MUI_PAGE_WELCOME


;License page**************************************************************************************
!insertmacro MUI_PAGE_LICENSE ..\..\#dist\app\license.txt


;Install check*************************************************************************************
Page custom PageReinstall PageLeaveReinstall 

Function PageReinstall
  ClearErrors
  SearchPath $matlabExe 'matlab.exe'
  IfErrors 0 MatlabInstalled
      MessageBox MB_OK|MB_ICONEXCLAMATION \
      "No Matlab installation has been found."
      Quit
  MatlabInstalled:
      ${WordReplace} $matlabExe "\bin\win32\matlab.exe" "" "-1" $matlabPath
      ${WordReplace} $matlabPath "\bin\matlab.exe" "" "-1" $matlabPath
      StrCpy $INSTDIR "$matlabPath\toolbox\${PROD_NAME}"

  ReadRegStr $R0 HKLM "${REG_KEY}" ""
  StrCmp $R0 "" 0 +2
    Abort

  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "${INI_FILE}"
  
  ReadRegStr $INSTDIR HKLM "${REG_UNINSTKEY}" "InstallLocation"
  ReadRegStr $R0 HKLM "${REG_KEY}" "VersionBuild"
  ${VersionCompare} "${PROD_VERSION}" "$R0" $R1
  IntCmp $R1 1 new_version same_version older_version

  new_version:
   !insertmacro MUI_INSTALLOPTIONS_WRITE "${INI_FILE}" "Field 1" "Text" "An older version of ${PROD_NAME} is installed on your system. It's recommended that you uninstall the current version before installing. Select the operation you want to perform and click Next to continue."
   !insertmacro MUI_INSTALLOPTIONS_WRITE "${INI_FILE}" "Field 2" "Text" "Uninstall before installing"
   !insertmacro MUI_INSTALLOPTIONS_WRITE "${INI_FILE}" "Field 3" "Text" "Do not uninstall"
   !insertmacro MUI_HEADER_TEXT "Already Installed" "Choose how you want to install ${PROD_NAME}."
   StrCpy $R0 "1"
   Goto reinst_start

  older_version:
   !insertmacro MUI_INSTALLOPTIONS_WRITE "${INI_FILE}" "Field 1" "Text" "A newer version of ${PROD_NAME} is already installed! It is not recommended that you install an older version. If you really want to install this older version, it's better to uninstall the current version first. Select the operation you want to perform and click Next to continue."
   !insertmacro MUI_INSTALLOPTIONS_WRITE "${INI_FILE}" "Field 2" "Text" "Uninstall before installing"
   !insertmacro MUI_INSTALLOPTIONS_WRITE "${INI_FILE}" "Field 3" "Text" "Do not uninstall"
   !insertmacro MUI_HEADER_TEXT "Already Installed" "Choose how you want to install ${PROD_NAME}."
   StrCpy $R0 "1"
   Goto reinst_start

  same_version:
   !insertmacro MUI_INSTALLOPTIONS_WRITE "${INI_FILE}" "Field 1" "Text" "${PROD_NAME} ${PROD_VERSION} is already installed. Select the operation you want to perform and click Next to continue."
   !insertmacro MUI_INSTALLOPTIONS_WRITE "${INI_FILE}" "Field 2" "Text" "Add/Reinstall components"
   !insertmacro MUI_INSTALLOPTIONS_WRITE "${INI_FILE}" "Field 3" "Text" "Uninstall ${PROD_NAME}"
   !insertmacro MUI_HEADER_TEXT "Already Installed" "Choose the maintenance option to perform."
   StrCpy $R0 "2"

  reinst_start:
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "${INI_FILE}"
FunctionEnd



Function PageLeaveReinstall
  !insertmacro MUI_INSTALLOPTIONS_READ $R1 "${INI_FILE}" "Field 2" "State"

  StrCmp $R0 "1" 0 +2
    StrCmp $R1 "1" reinst_uninstall reinst_done

  StrCmp $R0 "2" 0 +3
    StrCmp $R1 "1" reinst_done reinst_uninstall

  reinst_uninstall:
  ReadRegStr $R1 HKLM "${REG_UNINSTKEY}" "UninstallString"

  ;Run uninstaller
  HideWindow

    ClearErrors
    ExecWait '$R1 _?=$INSTDIR'

    IfErrors no_remove_uninstaller
    
    Delete $R1
    RMDir $INSTDIR

    no_remove_uninstaller:

  StrCmp $R0 "2" 0 +2
    Quit

  BringToFront

  reinst_done:
FunctionEnd


;Components page***********************************************************************************
!insertmacro MUI_PAGE_COMPONENTS


;Directory page************************************************************************************
!insertmacro MUI_PAGE_DIRECTORY




;Installation page*********************************************************************************
!insertmacro MUI_PAGE_INSTFILES
ReserveFile "${INI_FILE}"
!insertmacro MUI_RESERVEFILE_INSTALLOPTIONS
Section "${PROD_NAME} Core Files (required)" SecCore
  SetDetailsPrint both
  DetailPrint "Installing ${PROD_NAME} Core Files..."
  SetDetailsPrint listonly
  SectionIn RO
  SetOutPath $INSTDIR
  SetOverwrite on
  File /r ..\..\#dist\app\*.*
SectionEnd

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecCore} "The core files required to use ${PROD_NAME}"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section -post
  SetDetailsPrint both
  DetailPrint "Adding Matlab path..."
  SetDetailsPrint listonly
  
  ${WordReplace} "$\'$INSTDIR" "$\'$matlabPath" "matlabroot,$\'" "+1" $R0
  StrCpy $R0 "$R0;$\', ...$\r$\n"
  
  FileOpen $0 "$matlabPath\toolbox\local\pathdef.m" "r"
loopread:
  ClearErrors
  FileRead $0 $1
  IfErrors write
  StrCmp $1 $R0 0 +3
    FileClose $0
    Goto finish
  Goto loopread
write:
  FileSeek $0 0 SET
  GetTempFileName $3
  FileOpen $2 $3 "w"
loopwritestart:
  ClearErrors
  FileRead $0 $1
  IfErrors donewrite
  ${WordFind} $1 "matlabroot" "+1" $4
  StrCmp $1 $4 0 +3
  FileWrite $2 $1 
  Goto loopwritestart
  FileWrite $2 $R0
  FileWrite $2 $1
loopwriteend:
  ClearErrors
  FileRead $0 $1
  IfErrors donewrite
  FileWrite $2 $1
  Goto loopwriteend
donewrite:
  FileClose $0
  FileClose $2
  Delete "$matlabPath\toolbox\local\pathdef.m"
  CopyFiles /SILENT $3 "$matlabPath\toolbox\local\pathdef.m"
  Delete $3

finish:
  SetDetailsPrint both
  DetailPrint "Creating Registry Keys..."
  SetDetailsPrint listonly
  WriteRegStr HKLM "${REG_KEY}" "" "$INSTDIR"
  WriteRegStr HKLM "${REG_KEY}" "VersionBuild" "${PROD_VERSION}"
  WriteRegExpandStr HKLM "${REG_UNINSTKEY}" "UninstallString" '"$INSTDIR\${UNINSTALLER}"'
  WriteRegExpandStr HKLM "${REG_UNINSTKEY}" "InstallLocation" "$INSTDIR"
  WriteRegStr HKLM "${REG_UNINSTKEY}" "DisplayName" "${PROD_TITLE}"
  WriteRegStr HKLM "${REG_UNINSTKEY}" "DisplayIcon" "$INSTDIR\${UNINSTALLER}"
  WriteRegStr HKLM "${REG_UNINSTKEY}" "DisplayVersion" "${PROD_VERSION}"
  WriteRegStr HKLM "${REG_UNINSTKEY}" "Publisher" "LeanPulse"
  
  SetDetailsPrint both
  DetailPrint "Creating Uninstaller..."
  SetDetailsPrint listonly
  WriteUninstaller "$INSTDIR\${UNINSTALLER}"
  
  SetOutPath "$DOCUMENTS"
  
  SetDetailsPrint both
SectionEnd


;Finish page***************************************************************************************
!define MUI_FINISHPAGE_SHOWREADME $INSTDIR\GettingStarted.pdf
!define MUI_FINISHPAGE_SHOWREADME_TEXT "Show me how to get started."
!define MUI_FINISHPAGE_RUN "matlab"
!define MUI_FINISHPAGE_RUN_PARAMETERS "-r $\"open('$INSTDIR\demos\${DEMO_MDL}');$\""
!define MUI_FINISHPAGE_RUN_TEXT "Open a demo model in Matlab."
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!insertmacro MUI_PAGE_FINISH







;--------------------------------------------------------------------------------------------------
;UnInstal
;--------------------------------------------------------------------------------------------------

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

Section "Uninstall"

  IfFileExists "$INSTDIR\*.*" nsis_installed
    MessageBox MB_YESNO "It does not appear that ${PROD_NAME} is installed in the directory '$INSTDIR'.$\r$\nContinue anyway (not recommended)?" /SD IDYES IDYES nsis_installed
    Abort "Uninstall aborted by user"
    
nsis_installed:
  ClearErrors
  SearchPath $matlabExe 'matlab.exe'
  IfErrors matlabNotInstalled matlabInstalled
    
matlabInstalled:
  ${WordReplace} $matlabExe "\bin\win32\matlab.exe" "" "-1" $matlabPath
  ${WordReplace} $matlabPath "\bin\matlab.exe" "" "-1" $matlabPath
  ${WordReplace} "$\'$INSTDIR" "$\'$matlabPath" "matlabroot,$\'" "+1" $R0
  StrCpy $R0 "$R0;$\', ...$\r$\n"
  
  SetDetailsPrint both
  DetailPrint "Resetting Matlab path..."
  
  SetDetailsPrint none
  ClearErrors
  FileOpen $0 "$matlabPath\toolbox\local\pathdef.m" "r"
  GetTempFileName $1
  FileOpen $2 $1 "w"
unloop:
  FileRead $0 $3
  IfErrors undone
  StrCmp $3 $R0 unloop 0
  FileWrite $2 $3
  Goto unloop
undone:
  FileClose $0
  FileClose $2
  Delete "$matlabPath\toolbox\local\pathdef.m"
  CopyFiles /SILENT $1 "$matlabPath\toolbox\local\pathdef.m"
  Delete $1
  
matlabNotInstalled:
  SetDetailsPrint both
  DetailPrint "Deleting Registry Keys..."
  
  SetDetailsPrint listonly
  DeleteRegKey HKLM "${REG_UNINSTKEY}"
  DeleteRegKey HKLM "${REG_KEY}"

  SetDetailsPrint both
  DetailPrint "Deleting Files..."
  
  SetDetailsPrint listonly
  RMDir /r "$INSTDIR"
SectionEnd


!insertmacro MUI_LANGUAGE "English"
