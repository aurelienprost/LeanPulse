/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal.matlab;

import java.io.File;
import java.util.Hashtable;
import java.util.Map;

import com.mathworks.jmi.CompletionObserver;
import com.mathworks.jmi.Matlab;
import com.mathworks.jmi.MatlabException;
import com.mathworks.jmi.MatlabMCR;
import com.mathworks.jmi.MatlabPath;
import com.mathworks.jmi.NativeMatlab;
import com.mathworks.jmi.bean.UDDObject;

/**
 * 
 * 
 * <p>
 * 
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class MatlabControl {
	
	private static String matlabVer;
	
	public static String getMatlabVer() {
		if(matlabVer == null) {
			MatlabControl matlab = new MatlabControl();
	    	try {
	    		MatStructure matVerStruct = new MatStructure((Object[]) matlab.feval("ver", new Object[] {"Matlab"}));
	    		matlabVer = (String) matVerStruct.getField("Version", 0);
			} catch (MatlabException e) {
				matlabVer = "";
			}
		}
		return matlabVer;
	}
	
	public static class MatStructure {
		private int size;
		private Map<String,Object[]> data;
		
		public MatStructure(Object[] array) {
			String[] names = (String[]) array[0];
			data = new Hashtable<String,Object[]>(names.length);
			size = ((Object[])array[1]).length;
			for(int i=0 ; i<names.length ; i++) {
				Object[] values = new Object[size];
				for(int j=0 ; j<size ; j++) {
					values[j] = ((Object[])((Object[])array[1])[j])[i];
				}
				data.put(names[i], values);
			}
		}
		
		public int size() {
			return size;
		}
		
		public Object getField(String name, int index) {
			Object[] values = data.get(name);
			if(values != null)
				return values[index];
			return null;
		}
	}
	
	private static class BlockingObserver implements CompletionObserver {
		private int status;
		private Object result;
		private boolean isCompleted;
		BlockingObserver() {
			super();
			isCompleted = false;
		}
		public synchronized void completed(int stat, Object res) {
			if(!isCompleted) {
				status = stat;
				result = res;
				isCompleted = true;
				notifyAll();
			}
		}
		synchronized void waitForReply() throws InterruptedException {
			while (!isCompleted) {
				wait();
			}
		}
		public int getStatus() {
			return status;
		}
		public Object getResult() {
			return result;
		}
	}
	
	
	private MatlabMCR matlab;
	private UDDObject slroot;
	
	
	
	public MatlabControl() {
		matlab = new MatlabMCR();
	}
	
	
	public UDDObject getSlRoot() {
		if (slroot == null) {
			if (NativeMatlab.nativeIsMatlabThread()) {
				try {
					slroot = (UDDObject) Matlab.mtFeval("eval",
							new Object[] { "java(slroot)" }, 1);
				} catch (Exception ex) {}
			} else {
				BlockingObserver obs = new BlockingObserver();
				matlab.feval("eval", new Object[] { "java(slroot)" }, 1, obs);
				try {
					obs.waitForReply();
				} catch (InterruptedException ex) {}
				slroot = (UDDObject)obs.getResult();
			}
		}
		return slroot;
	}
	
	public Object feval(String command, Object args[]) throws MatlabException {
		if (NativeMatlab.nativeIsMatlabThread()) {
			try {
				return Matlab.mtFevalConsoleOutput(command, args, 1);
			} catch (Exception ex) {
				throw (MatlabException) ex;
			}
		} else {
			BlockingObserver obs = new BlockingObserver();
			matlab.fevalConsoleOutput(command, args, 1, obs);
			try {
				obs.waitForReply();
			} catch (InterruptedException e) {}
			return processResult(obs.getStatus(), obs.getResult());
		}
	}
	
	public String getCurDir() {
		return MatlabPath.getCWD();
	}
	
	private Object processResult(int status, Object result) throws MatlabException {
		switch(Matlab.getExecutionStatus(status)) {
			case Matlab.EXECUTION_SUCCESS:
				return result;
			case Matlab.RUNTIME_ERROR:
				if(result != null)
					throw new MatlabException(result.toString().replace('\n', ' ').trim());
				else {
					MatlabException error = getLastError();
					if(error != null)
						throw error;
					else
						throw new MatlabException("Runtime error");
				}
			case Matlab.COMPILE_ERROR:
				if(result != null)
					throw new MatlabException(result.toString());
				else
					throw new MatlabException("Compilation error");
			case Matlab.EXECUTION_DBQUIT:
				throw new MatlabException("The execution has been ended by the user (Exit debug mode)");
			case Matlab.EXECUTION_CTRLC:
				throw new MatlabException("The execution has been ended by the user (CTRL+C)");
			default:
				throw new MatlabException("An error occured during the execution (status: " + Integer.toHexString(status) + ")");
		}
	}
	
	private MatlabException getLastError() {
		BlockingObserver obs = new BlockingObserver();
		matlab.feval("lasterror", new Object[0], obs);
		try {
			obs.waitForReply();
		} catch(InterruptedException ex) {
			return null;
		}
		Object result = obs.getResult();
		if(result instanceof Object[]) {
			try {
				MatStructure errStruct = new MatStructure((Object[])result);
				MatlabException exc = new MatlabException((String)errStruct.getField("message", 0));
				MatStructure errStackStruct = new MatStructure((Object[])errStruct.getField("stack", 0));
				StackTraceElement[] stackEls = new StackTraceElement[errStackStruct.size()];
				for(int i=0 ; i<errStackStruct.size() ; i++) {
					String filePath = (String) errStackStruct.getField("file", i);
					String fileName = new File(filePath).getName();
					int extPos = fileName.lastIndexOf(".");
					if(extPos > 0)
						fileName = fileName.substring(0, extPos);
					String function = (String) errStackStruct.getField("name", i);
					int line = (int) ((double[])errStackStruct.getField("line", i))[0];
					stackEls[i] = new StackTraceElement(fileName, function, filePath, line);
				}
				exc.setStackTrace(stackEls);
				return exc;
			} catch(Exception ex) {
				return null;
			}
		}
		return null;
	}

}
