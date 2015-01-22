<?xml version="1.0" encoding="UTF-8"?>

<!-- ===============================================

This stylesheet defines named templates for common tasks:
  1. conversion of hexadecimal color values from Word to XSL-FO,
  2. substitution of Unicode for character codes in symbol fonts,
  3. normalization of font family names,
  4. parsing of 'CSS style'-like structures,
  5. page number format setting.

Copyright (c) 2011 LeanPulse. All rights reserved.

Author: Aurélien PROST (a.prost@leanpulse.com)

==================================================== -->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"
	xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint"
	xmlns:my="dummy.namespace" version="1.0">

	<!-- ======================= -->
	<!-- Custom recording tables -->
	<!-- ======================= -->

    <!-- Symbol font -->
	<!-- Provided a comprehensive recoding table for many more Symbol characters -->
	<!-- Attention! If you use @code or @entity attribute value (also for searching), you should use only first character of attribute value! -->
	<!-- In some cases value of attributes @code and @entity is doubled for compatibility reason. -->
	<!-- See http://www.w3.org/TR/xslt#attribute-value-templates 7.6.2 Attribute Value Templates -->
	<!-- It is an error if a right curly brace occurs in an attribute value template outside an expression without being followed by a second right curly brace. -->
    <my:recoding-table font="Symbol">
		<my:char code="&#x21;" value="21" altvalue="F021" entity="&#x0021;"/> <!--EXCLAMATION MARK-->
		<my:char code="&#x22;" value="22" altvalue="F022" entity="&#x2200;"/> <!--FOR ALL-->
		<my:char code="&#x23;" value="23" altvalue="F023" entity="&#x0023;"/> <!--NUMBER SIGN-->
		<my:char code="&#x24;" value="24" altvalue="F024" entity="&#x2203;"/> <!--THERE EXISTS-->
		<my:char code="&#x25;" value="25" altvalue="F025" entity="&#x0025;"/> <!--PERCENT SIGN-->
		<my:char code="&#x26;" value="26" altvalue="F026" entity="&#x0026;"/> <!--AMPERSAND-->
		<my:char code="&#x27;" value="27" altvalue="F027" entity="&#x220D;"/> <!--SMALL CONTAINS AS MEMBER-->
		<my:char code="&#x28;" value="28" altvalue="F028" entity="&#x0028;"/> <!--LEFT PARENTHESIS-->
		<my:char code="&#x29;" value="29" altvalue="F029" entity="&#x0029;"/> <!--RIGHT PARENTHESIS-->
		<my:char code="&#x2A;" value="2A" altvalue="F02A" entity="&#x2217;"/> <!--ASTERISK OPERATOR-->
		<my:char code="&#x2B;" value="2B" altvalue="F02B" entity="&#x002B;"/> <!--PLUS SIGN-->
		<my:char code="&#x2C;" value="2C" altvalue="F02C" entity="&#x002C;"/> <!--COMMA-->
		<my:char code="&#x2D;" value="2D" altvalue="F02D" entity="&#x2212;"/> <!--MINUS SIGN-->
		<my:char code="&#x2E;" value="2E" altvalue="F02E" entity="&#x002E;"/> <!--FULL STOP-->
		<my:char code="&#x2F;" value="2F" altvalue="F02F" entity="&#x002F;"/> <!--SOLIDUS-->
		<my:char code="&#x30;" value="30" altvalue="F030" entity="&#x0030;"/> <!--DIGIT ZERO-->
		<my:char code="&#x31;" value="31" altvalue="F031" entity="&#x0031;"/> <!--DIGIT ONE-->
		<my:char code="&#x32;" value="32" altvalue="F032" entity="&#x0032;"/> <!--DIGIT TWO-->
		<my:char code="&#x33;" value="33" altvalue="F033" entity="&#x0033;"/> <!--DIGIT THREE-->
		<my:char code="&#x34;" value="34" altvalue="F034" entity="&#x0034;"/> <!--DIGIT FOUR-->
		<my:char code="&#x35;" value="35" altvalue="F035" entity="&#x0035;"/> <!--DIGIT FIVE-->
		<my:char code="&#x36;" value="36" altvalue="F036" entity="&#x0036;"/> <!--DIGIT SIX-->
		<my:char code="&#x37;" value="37" altvalue="F037" entity="&#x0037;"/> <!--DIGIT SEVEN-->
		<my:char code="&#x38;" value="38" altvalue="F038" entity="&#x0038;"/> <!--DIGIT EIGHT-->
		<my:char code="&#x39;" value="39" altvalue="F039" entity="&#x0039;"/> <!--DIGIT NINE-->
		<my:char code="&#x3A;" value="3A" altvalue="F03A" entity="&#x003A;"/> <!--COLON-->
		<my:char code="&#x3B;" value="3B" altvalue="F03B" entity="&#x003B;"/> <!--SEMICOLON-->
		<my:char code="&#x3C;" value="3C" altvalue="F03C" entity="&#x003C;"/> <!--LESS-THAN SIGN-->
		<my:char code="&#x3D;" value="3D" altvalue="F03D" entity="&#x003D;"/> <!--EQUALS SIGN-->
		<my:char code="&#x3E;" value="3E" altvalue="F03E" entity="&#x003E;"/> <!--GREATER-THAN SIGN-->
		<my:char code="&#x3F;" value="3F" altvalue="F03F" entity="&#x003F;"/> <!--QUESTION MARK-->
		<my:char code="&#x40;" value="40" altvalue="F040" entity="&#x2245;"/> <!--APPROXIMATELY EQUAL TO-->
		<my:char code="&#x41;" value="41" altvalue="F041" entity="&#x0391;"/> <!--GREEK CAPITAL LETTER ALPHA-->
		<my:char code="&#x42;" value="42" altvalue="F042" entity="&#x0392;"/> <!--GREEK CAPITAL LETTER BETA-->
		<my:char code="&#x43;" value="43" altvalue="F043" entity="&#x03A7;"/> <!--GREEK CAPITAL LETTER CHI-->
		<my:char code="&#x44;" value="44" altvalue="F044" entity="&#x0394;"/> <!--GREEK CAPITAL LETTER DELTA-->
		<my:char code="&#x45;" value="45" altvalue="F045" entity="&#x0395;"/> <!--GREEK CAPITAL LETTER EPSILON-->
		<my:char code="&#x46;" value="46" altvalue="F046" entity="&#x03A6;"/> <!--GREEK CAPITAL LETTER PHI-->
		<my:char code="&#x47;" value="47" altvalue="F047" entity="&#x0393;"/> <!--GREEK CAPITAL LETTER GAMMA-->
		<my:char code="&#x48;" value="48" altvalue="F048" entity="&#x0397;"/> <!--GREEK CAPITAL LETTER ETA-->
		<my:char code="&#x49;" value="49" altvalue="F049" entity="&#x0399;"/> <!--GREEK CAPITAL LETTER IOTA-->
		<my:char code="&#x4A;" value="4A" altvalue="F04A" entity="&#x03D1;"/> <!--GREEK THETA SYMBOL-->
		<my:char code="&#x4B;" value="4B" altvalue="F04B" entity="&#x039A;"/> <!--GREEK CAPITAL LETTER KAPPA-->
		<my:char code="&#x4C;" value="4C" altvalue="F04C" entity="&#x039B;"/> <!--GREEK CAPITAL LETTER LAMDA-->
		<my:char code="&#x4D;" value="4D" altvalue="F04D" entity="&#x039C;"/> <!--GREEK CAPITAL LETTER MU-->
		<my:char code="&#x4E;" value="4E" altvalue="F04E" entity="&#x039D;"/> <!--GREEK CAPITAL LETTER NU-->
		<my:char code="&#x4F;" value="4F" altvalue="F04F" entity="&#x039F;"/> <!--GREEK CAPITAL LETTER OMICRON-->
		<my:char code="&#x50;" value="50" altvalue="F050" entity="&#x03A0;"/> <!--GREEK CAPITAL LETTER PI-->
		<my:char code="&#x51;" value="51" altvalue="F051" entity="&#x0398;"/> <!--GREEK CAPITAL LETTER THETA-->
		<my:char code="&#x52;" value="52" altvalue="F052" entity="&#x03A1;"/> <!--GREEK CAPITAL LETTER RHO-->
		<my:char code="&#x53;" value="53" altvalue="F053" entity="&#x03A3;"/> <!--GREEK CAPITAL LETTER SIGMA-->
		<my:char code="&#x54;" value="54" altvalue="F054" entity="&#x03A4;"/> <!--GREEK CAPITAL LETTER TAU-->
		<my:char code="&#x55;" value="55" altvalue="F055" entity="&#x03A5;"/> <!--GREEK CAPITAL LETTER UPSILON-->
		<my:char code="&#x56;" value="56" altvalue="F056" entity="&#x03C2;"/> <!--GREEK SMALL LETTER FINAL SIGMA-->
		<my:char code="&#x57;" value="57" altvalue="F057" entity="&#x03A9;"/> <!--GREEK CAPITAL LETTER OMEGA-->
		<my:char code="&#x58;" value="58" altvalue="F058" entity="&#x039E;"/> <!--GREEK CAPITAL LETTER XI-->
		<my:char code="&#x59;" value="59" altvalue="F059" entity="&#x03A8;"/> <!--GREEK CAPITAL LETTER PSI-->
		<my:char code="&#x5A;" value="5A" altvalue="F05A" entity="&#x0396;"/> <!--GREEK CAPITAL LETTER ZETA-->
		<my:char code="&#x5B;" value="5B" altvalue="F05B" entity="&#x005B;"/> <!--LEFT SQUARE BRACKET-->
		<my:char code="&#x5C;" value="5C" altvalue="F05C" entity="&#x2234;"/> <!--THEREFORE-->
		<my:char code="&#x5D;" value="5D" altvalue="F05D" entity="&#x005D;"/> <!--RIGHT SQUARE BRACKET-->
		<my:char code="&#x5E;" value="5E" altvalue="F05E" entity="&#x22A5;"/> <!--UP TACK-->
		<my:char code="&#x5F;" value="5F" altvalue="F05F" entity="&#x005F;"/> <!--LOW LINE-->
		<my:char code="&#x60;" value="60" altvalue="F060" entity="&#x203E;"/> <!--radical extender # corporate char-->
		<my:char code="&#x61;" value="61" altvalue="F061" entity="&#x03B1;"/> <!--GREEK SMALL LETTER ALPHA-->
		<my:char code="&#x62;" value="62" altvalue="F062" entity="&#x03B2;"/> <!--GREEK SMALL LETTER BETA-->
		<my:char code="&#x63;" value="63" altvalue="F063" entity="&#x03C7;"/> <!--GREEK SMALL LETTER CHI-->
		<my:char code="&#x64;" value="64" altvalue="F064" entity="&#x03B4;"/> <!--GREEK SMALL LETTER DELTA-->
		<my:char code="&#x65;" value="65" altvalue="F065" entity="&#x03B5;"/> <!--GREEK SMALL LETTER EPSILON-->
		<my:char code="&#x66;" value="66" altvalue="F066" entity="&#x03C6;"/> <!--GREEK SMALL LETTER PHI-->
		<my:char code="&#x67;" value="67" altvalue="F067" entity="&#x03B3;"/> <!--GREEK SMALL LETTER GAMMA-->
		<my:char code="&#x68;" value="68" altvalue="F068" entity="&#x03B7;"/> <!--GREEK SMALL LETTER ETA-->
		<my:char code="&#x69;" value="69" altvalue="F069" entity="&#x03B9;"/> <!--GREEK SMALL LETTER IOTA-->
		<my:char code="&#x6A;" value="6A" altvalue="F06A" entity="&#x03D6;"/> <!--GREEK PHI SYMBOL-->
		<my:char code="&#x6B;" value="6B" altvalue="F06B" entity="&#x03BA;"/> <!--GREEK SMALL LETTER KAPPA-->
		<my:char code="&#x6C;" value="6C" altvalue="F06C" entity="&#x03BB;"/> <!--GREEK SMALL LETTER LAMDA-->
		<my:char code="&#x6D;" value="6D" altvalue="F06D" entity="&#x03BC;"/> <!--GREEK SMALL LETTER MU-->
		<my:char code="&#x6E;" value="6E" altvalue="F06E" entity="&#x03BD;"/> <!--GREEK SMALL LETTER NU-->
		<my:char code="&#x6F;" value="6F" altvalue="F06F" entity="&#x03BF;"/> <!--GREEK SMALL LETTER OMICRON-->
		<my:char code="&#x70;" value="70" altvalue="F070" entity="&#x03C0;"/> <!--GREEK SMALL LETTER PI-->
		<my:char code="&#x71;" value="71" altvalue="F071" entity="&#x03B8;"/> <!--GREEK SMALL LETTER THETA-->
		<my:char code="&#x72;" value="72" altvalue="F072" entity="&#x03C1;"/> <!--GREEK SMALL LETTER RHO-->
		<my:char code="&#x73;" value="73" altvalue="F073" entity="&#x03C3;"/> <!--GREEK SMALL LETTER SIGMA-->
		<my:char code="&#x74;" value="74" altvalue="F074" entity="&#x03C4;"/> <!--GREEK SMALL LETTER TAU-->
		<my:char code="&#x75;" value="75" altvalue="F075" entity="&#x03C5;"/> <!--GREEK SMALL LETTER UPSILON-->
		<my:char code="&#x76;" value="76" altvalue="F076" entity="&#x03D6;"/> <!--GREEK PI SYMBOL-->
		<my:char code="&#x77;" value="77" altvalue="F077" entity="&#x03C9;"/> <!--GREEK SMALL LETTER OMEGA-->
		<my:char code="&#x78;" value="78" altvalue="F078" entity="&#x03BE;"/> <!--GREEK SMALL LETTER XI-->
		<my:char code="&#x79;" value="79" altvalue="F079" entity="&#x03C8;"/> <!--GREEK SMALL LETTER PSI-->
		<my:char code="&#x7A;" value="7A" altvalue="F07A" entity="&#x03B6;"/> <!--GREEK SMALL LETTER ZETA-->
		<!--<my:char code="&#x7B;" value="7B" altvalue="F07B" entity="&#x007B;"/>--> <!--LEFT CURLY BRACKET-->
		<my:char code="&#x7B;&#x7B;" value="7B" altvalue="F07B" entity="&#x007B;&#x007B;"/> <!--LEFT CURLY BRACKET-->
		<my:char code="&#x7C;" value="7C" altvalue="F07C" entity="&#x007C;"/> <!--VERTICAL LINE-->
		<!--<my:char code="&#x7D;" value="7D" altvalue="F07D" entity="&#x007D;"/>--> <!--RIGHT CURLY BRACKET-->
		<my:char code="&#x7D;&#x7D;" value="7D" altvalue="F07D" entity="&#x007D;&#x007D;"/> <!--RIGHT CURLY BRACKET-->
		<my:char code="&#x7E;" value="7E" altvalue="F07E" entity="&#x223C;"/> <!--TILDE OPERATOR-->
		<my:char code="&#xA0;" value="A0" altvalue="F0A0" entity="&#x20AC;"/> <!--EURO SIGN-->
		<my:char code="&#xA1;" value="A1" altvalue="F0A1" entity="&#x03D2;"/> <!--GREEK UPSILON WITH HOOK SYMBOL-->
		<my:char code="&#xA2;" value="A2" altvalue="F0A2" entity="&#x2032;"/> <!--PRIME	# minute-->
		<my:char code="&#xA3;" value="A3" altvalue="F0A3" entity="&#x2264;"/> <!--LESS-THAN OR EQUAL TO-->
		<my:char code="&#xA4;" value="A4" altvalue="F0A4" entity="&#x2044;"/> <!--FRACTION SLASH-->
		<my:char code="&#xA5;" value="A5" altvalue="F0A5" entity="&#x221E;"/> <!--INFINITY-->
		<my:char code="&#xA6;" value="A6" altvalue="F0A6" entity="&#x0192;"/> <!--LATIN SMALL LETTER F WITH HOOK-->
		<my:char code="&#xA7;" value="A7" altvalue="F0A7" entity="&#x2663;"/> <!--BLACK CLUB SUIT-->
		<my:char code="&#xA8;" value="A8" altvalue="F0A8" entity="&#x2666;"/> <!--BLACK DIAMOND SUIT-->
		<my:char code="&#xA9;" value="A9" altvalue="F0A9" entity="&#x2665;"/> <!--BLACK HEART SUIT-->
		<my:char code="&#xAA;" value="AA" altvalue="F0AA" entity="&#x2660;"/> <!--BLACK SPADE SUIT-->
		<my:char code="&#xAB;" value="AB" altvalue="F0AB" entity="&#x2194;"/> <!--LEFT RIGHT ARROW-->
		<my:char code="&#xAC;" value="AC" altvalue="F0AC" entity="&#x2190;"/> <!--LEFTWARDS ARROW-->
		<my:char code="&#xAD;" value="AD" altvalue="F0AD" entity="&#x2191;"/> <!--UPWARDS ARROW-->
		<my:char code="&#xAE;" value="AE" altvalue="F0AE" entity="&#x2192;"/> <!--RIGHTWARDS ARROW-->
		<my:char code="&#xAF;" value="AF" altvalue="F0AF" entity="&#x2193;"/> <!--DOWNWARDS ARROW-->
		<my:char code="&#xB0;" value="B0" altvalue="F0B0" entity="&#x00B0;"/> <!--DEGREE SIGN-->
		<my:char code="&#xB1;" value="B1" altvalue="F0B1" entity="&#x00B1;"/> <!--PLUS-MINUS SIGN-->
		<my:char code="&#xB2;" value="B2" altvalue="F0B2" entity="&#x2033;"/> <!--DOUBLE PRIME	# second-->
		<my:char code="&#xB3;" value="B3" altvalue="F0B3" entity="&#x2265;"/> <!--GREATER-THAN OR EQUAL TO-->
		<my:char code="&#xB4;" value="B4" altvalue="F0B4" entity="&#x00D7;"/> <!--MULTIPLICATION SIGN-->
		<my:char code="&#xB5;" value="B5" altvalue="F0B5" entity="&#x221D;"/> <!--PROPORTIONAL TO-->
		<my:char code="&#xB6;" value="B6" altvalue="F0B6" entity="&#x2202;"/> <!--PARTIAL DIFFERENTIAL-->
		<my:char code="&#xB7;" value="B7" altvalue="F0B7" entity="&#x2022;"/> <!--BULLET-->
		<my:char code="&#xB8;" value="B8" altvalue="F0B8" entity="&#x00F7;"/> <!--DIVISION SIGN-->
		<my:char code="&#xB9;" value="B9" altvalue="F0B9" entity="&#x2260;"/> <!--NOT EQUAL TO-->
		<my:char code="&#xBA;" value="BA" altvalue="F0BA" entity="&#x2261;"/> <!--IDENTICAL TO-->
		<my:char code="&#xBB;" value="BB" altvalue="F0BB" entity="&#x2248;"/> <!--ALMOST EQUAL TO-->
		<my:char code="&#xBC;" value="BC" altvalue="F0BC" entity="&#x2026;"/> <!--HORIZONTAL ELLIPSIS-->
		<my:char code="&#xBD;" value="BD" altvalue="F0BD" entity="&#x23D0;"/> <!--VERTICAL LINE EXTENSION (for arrows) # for Unicode 4.0 and later-->
		<my:char code="&#xBE;" value="BE" altvalue="F0BE" entity="&#x23AF;"/> <!--HORIZONTAL LINE EXTENSION (for arrows) # for Unicode 3.2 and later-->
		<my:char code="&#xBF;" value="BF" altvalue="F0BF" entity="&#x21B5;"/> <!--DOWNWARDS ARROW WITH CORNER LEFTWARDS-->
		<my:char code="&#xC0;" value="C0" altvalue="F0C0" entity="&#x2135;"/> <!--ALEF SYMBOL-->
		<my:char code="&#xC1;" value="C1" altvalue="F0C1" entity="&#x2111;"/> <!--BLACK-LETTER CAPITAL I-->
		<my:char code="&#xC2;" value="C2" altvalue="F0C2" entity="&#x211C;"/> <!--BLACK-LETTER CAPITAL R-->
		<my:char code="&#xC3;" value="C3" altvalue="F0C3" entity="&#x2118;"/> <!--SCRIPT CAPITAL P-->
		<my:char code="&#xC4;" value="C4" altvalue="F0C4" entity="&#x2297;"/> <!--CIRCLED TIMES-->
		<my:char code="&#xC5;" value="C5" altvalue="F0C5" entity="&#x2295;"/> <!--CIRCLED PLUS-->
		<my:char code="&#xC6;" value="C6" altvalue="F0C6" entity="&#x2205;"/> <!--EMPTY SET-->
		<my:char code="&#xC7;" value="C7" altvalue="F0C7" entity="&#x2229;"/> <!--INTERSECTION-->
		<my:char code="&#xC8;" value="C8" altvalue="F0C8" entity="&#x222A;"/> <!--UNION-->
		<my:char code="&#xC9;" value="C9" altvalue="F0C9" entity="&#x2283;"/> <!--SUPERSET OF-->
		<my:char code="&#xCA;" value="CA" altvalue="F0CA" entity="&#x2287;"/> <!--SUPERSET OF OR EQUAL TO-->
		<my:char code="&#xCB;" value="CB" altvalue="F0CB" entity="&#x2284;"/> <!--NOT A SUBSET OF-->
		<my:char code="&#xCC;" value="CC" altvalue="F0CC" entity="&#x2282;"/> <!--SUBSET OF-->
		<my:char code="&#xCD;" value="CD" altvalue="F0CD" entity="&#x2286;"/> <!--SUBSET OF OR EQUAL TO-->
		<my:char code="&#xCE;" value="CE" altvalue="F0CE" entity="&#x2208;"/> <!--ELEMENT OF-->
		<my:char code="&#xCF;" value="CF" altvalue="F0CF" entity="&#x2209;"/> <!--NOT AN ELEMENT OF-->
		<my:char code="&#xD0;" value="D0" altvalue="F0D0" entity="&#x2220;"/> <!--ANGLE-->
		<my:char code="&#xD1;" value="D1" altvalue="F0D1" entity="&#x2207;"/> <!--NABLA-->
		<my:char code="&#xD2;" value="D2" altvalue="F0D2" entity="&#x00AE;"/> <!--REGISTERED SIGN # serif-->
		<my:char code="&#xD3;" value="D3" altvalue="F0D3" entity="&#x00A9;"/> <!--COPYRIGHT SIGN # serif-->
		<my:char code="&#xD4;" value="D4" altvalue="F0D4" entity="&#x2122;"/> <!--TRADE MARK SIGN # serif-->
		<my:char code="&#xD5;" value="D5" altvalue="F0D5" entity="&#x220F;"/> <!--N-ARY PRODUCT-->
		<my:char code="&#xD6;" value="D6" altvalue="F0D6" entity="&#x221A;"/> <!--SQUARE ROOT-->
		<my:char code="&#xD7;" value="D7" altvalue="F0D7" entity="·"/> <!--DOT OPERATOR-->
		<my:char code="&#xD8;" value="D8" altvalue="F0D8" entity="&#x00AC;"/> <!--NOT SIGN-->
		<my:char code="&#xD9;" value="D9" altvalue="F0D9" entity="&#x2227;"/> <!--LOGICAL AND-->
		<my:char code="&#xDA;" value="DA" altvalue="F0DA" entity="&#x2228;"/> <!--LOGICAL OR-->
		<my:char code="&#xDB;" value="DB" altvalue="F0DB" entity="&#x21D4;"/> <!--LEFT RIGHT DOUBLE ARROW-->
		<my:char code="&#xDC;" value="DC" altvalue="F0DC" entity="&#x21D0;"/> <!--LEFTWARDS DOUBLE ARROW-->
		<my:char code="&#xDD;" value="DD" altvalue="F0DD" entity="&#x21D1;"/> <!--UPWARDS DOUBLE ARROW-->
		<my:char code="&#xDE;" value="DE" altvalue="F0DE" entity="&#x21D2;"/> <!--RIGHTWARDS DOUBLE ARROW-->
		<my:char code="&#xDF;" value="DF" altvalue="F0DF" entity="&#x21D3;"/> <!--DOWNWARDS DOUBLE ARROW-->
		<my:char code="&#xE0;" value="E0" altvalue="F0E0" entity="&#x22C4;"/> <!--DIAMOND OPERATOR-->
		<my:char code="&#xE1;" value="E1" altvalue="F0E1" entity="&#x3008;"/> <!--LEFT ANGLE BRACKET-->
		<my:char code="&#xE2;" value="E2" altvalue="F0E2" entity="&#x00AE;"/> <!--REGISTERED SIGN # sans serif-->
		<my:char code="&#xE3;" value="E3" altvalue="F0E3" entity="&#x00A9;"/> <!--COPYRIGHT SIGN # sans serif-->
		<my:char code="&#xE4;" value="E4" altvalue="F0E4" entity="&#x2122;"/> <!--TRADE MARK SIGN # sans serif-->
		<my:char code="&#xE5;" value="E5" altvalue="F0E5" entity="&#x2211;"/> <!--N-ARY SUMMATION-->
		<my:char code="&#xE6;" value="E6" altvalue="F0E6" entity="&#x239B;"/> <!--LEFT PARENTHESIS UPPER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xE7;" value="E7" altvalue="F0E7" entity="&#x239C;"/> <!--LEFT PARENTHESIS EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xE8;" value="E8" altvalue="F0E8" entity="&#x239D;"/> <!--LEFT PARENTHESIS LOWER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xE9;" value="E9" altvalue="F0E9" entity="&#x23A1;"/> <!--LEFT SQUARE BRACKET UPPER CORNER # for Unicode 3.2 and later-->
		<my:char code="&#xEA;" value="EA" altvalue="F0EA" entity="&#x23A2;"/> <!--LEFT SQUARE BRACKET EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xEB;" value="EB" altvalue="F0EB" entity="&#x23A3;"/> <!--LEFT SQUARE BRACKET LOWER CORNER # for Unicode 3.2 and later-->
		<my:char code="&#xEC;" value="EC" altvalue="F0EC" entity="&#x23A7;"/> <!--LEFT CURLY BRACKET UPPER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xED;" value="ED" altvalue="F0ED" entity="&#x23A8;"/> <!--LEFT CURLY BRACKET MIDDLE PIECE # for Unicode 3.2 and later-->
		<my:char code="&#xEE;" value="EE" altvalue="F0EE" entity="&#x23A9;"/> <!--LEFT CURLY BRACKET LOWER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xEF;" value="EF" altvalue="F0EF" entity="&#x23AA;"/> <!--CURLY BRACKET EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xF0;" value="F0" altvalue="F0F0" entity="&#xF8FF;"/> <!--Apple logo-->
		<my:char code="&#xF1;" value="F1" altvalue="F0F1" entity="&#x3009;"/> <!--RIGHT ANGLE BRACKET-->
		<my:char code="&#xF2;" value="F2" altvalue="F0F2" entity="&#x222B;"/> <!--INTEGRAL-->
		<my:char code="&#xF3;" value="F3" altvalue="F0F3" entity="&#x2320;"/> <!--TOP HALF INTEGRAL-->
		<my:char code="&#xF4;" value="F4" altvalue="F0F4" entity="&#x23AE;"/> <!--INTEGRAL EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xF5;" value="F5" altvalue="F0F5" entity="&#x2321;"/> <!--BOTTOM HALF INTEGRAL-->
		<my:char code="&#xF6;" value="F6" altvalue="F0F6" entity="&#x239E;"/> <!--RIGHT PARENTHESIS UPPER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xF7;" value="F7" altvalue="F0F7" entity="&#x239F;"/> <!--RIGHT PARENTHESIS EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xF8;" value="F8" altvalue="F0F8" entity="&#x23A0;"/> <!--RIGHT PARENTHESIS LOWER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xF9;" value="F9" altvalue="F0F9" entity="&#x23A4;"/> <!--RIGHT SQUARE BRACKET UPPER CORNER # for Unicode 3.2 and later-->
		<my:char code="&#xFA;" value="FA" altvalue="F0FA" entity="&#x23A5;"/> <!--RIGHT SQUARE BRACKET EXTENSION # for Unicode 3.2 and later-->
		<my:char code="&#xFB;" value="FB" altvalue="F0FB" entity="&#x23A6;"/> <!--RIGHT SQUARE BRACKET LOWER CORNER # for Unicode 3.2 and later-->
		<my:char code="&#xFC;" value="FC" altvalue="F0FC" entity="&#x23AB;"/> <!--RIGHT CURLY BRACKET UPPER HOOK # for Unicode 3.2 and later-->
		<my:char code="&#xFD;" value="FD" altvalue="F0FD" entity="&#x23AC;"/> <!--RIGHT CURLY BRACKET MIDDLE PIECE # for Unicode 3.2 and later-->
		<my:char code="&#xFE;" value="FE" altvalue="F0FE" entity="&#x23AD;"/> <!--RIGHT CURLY BRACKET LOWER HOOK # for Unicode 3.2 and later-->
    </my:recoding-table>

    <!-- Wingdings font -->
	<!-- Provided a comprehensive recoding table for many more Wingdings characters -->
	<!-- Attention! If you use @code or @entity attribute value (also for searching), you should use only first character of attribute value! -->
	<!-- In some cases value of attributes @code and @entity is doubled for compatibility reason. -->
	<!-- See http://www.w3.org/TR/xslt#attribute-value-templates 7.6.2 Attribute Value Templates -->
	<!-- It is an error if a right curly brace occurs in an attribute value template outside an expression without being followed by a second right curly brace. -->
	<my:recoding-table font="Wingdings">
		<my:char code="&#x22;" value="22" altvalue="F022" entity="&#x2702;"/>
		<my:char code="&#x23;" value="23" altvalue="F023" entity="&#x2701;"/>
		<my:char code="&#x28;" value="28" altvalue="F028" entity="&#x260E;"/>
		<my:char code="&#x2A;" value="2A" altvalue="F02A" entity="&#x2709;"/>
		<my:char code="&#x3E;" value="3E" altvalue="F03E" entity="&#x2622;"/>
		<my:char code="&#x3F;" value="3F" altvalue="F03F" entity="&#x270D;"/>
		<my:char code="&#x41;" value="41" altvalue="F041" entity="&#x270C;"/>
		<my:char code="&#x46;" value="46" altvalue="F046" entity="&#x261E;"/>
		<my:char code="&#x4C;" value="4C" altvalue="F04C" entity="&#x2639;"/>
		<my:char code="&#x58;" value="58" altvalue="F058" entity="&#x2720;"/>
		<my:char code="&#x59;" value="59" altvalue="F059" entity="&#x2721;"/>
		<my:char code="&#x5A;" value="5A" altvalue="F05A" entity="&#x262A;"/>
		<my:char code="&#x5B;" value="5B" altvalue="F05B" entity="&#x262F;"/>
		<my:char code="&#x5D;" value="5D" altvalue="F05D" entity="&#x2638;"/>
		<my:char code="&#x52;" value="52" altvalue="F052" entity="&#x263C;"/>
		<my:char code="&#x5E;" value="5E" altvalue="F05E" entity="&#x2648;"/>
		<my:char code="&#x5F;" value="5F" altvalue="F05F" entity="&#x2649;"/>
		<my:char code="&#x60;" value="60" altvalue="F060" entity="&#x264A;"/>
		<my:char code="&#x61;" value="61" altvalue="F061" entity="&#x264B;"/>
		<my:char code="&#x62;" value="62" altvalue="F062" entity="&#x264C;"/>
		<my:char code="&#x63;" value="63" altvalue="F063" entity="&#x264D;"/>
		<my:char code="&#x64;" value="64" altvalue="F064" entity="&#x264E;"/>
		<my:char code="&#x65;" value="65" altvalue="F065" entity="&#x264F;"/>
		<my:char code="&#x66;" value="66" altvalue="F066" entity="&#x2650;"/>
		<my:char code="&#x67;" value="67" altvalue="F067" entity="&#x2651;"/>
		<my:char code="&#x68;" value="68" altvalue="F068" entity="&#x2652;"/>
		<my:char code="&#x69;" value="69" altvalue="F069" entity="&#x2653;"/>
		<my:char code="&#x6C;" value="6C" altvalue="F06C" entity="&#x25CF;"/>
		<my:char code="&#x6D;" value="6D" altvalue="F06D" entity="&#x274D;"/>
		<my:char code="&#x6E;" value="6E" altvalue="F06E" entity="&#x25A0;"/>
		<my:char code="&#x6F;" value="6F" altvalue="F06F" entity="&#x25A1;"/>
		<my:char code="&#x71;" value="71" altvalue="F071" entity="&#x2751;"/>
		<my:char code="&#x72;" value="72" altvalue="F072" entity="&#x2752;"/>
		<my:char code="&#x76;" value="76" altvalue="F076" entity="&#x2756;"/>
		<my:char code="&#x77;" value="77" altvalue="F077" entity="&#x25C6;"/>
		<!--<my:char code="&#x7B;" value="7B" altvalue="F07B" entity="&#x2740;"/>-->
		<my:char code="&#x7B;&#x7B;" value="7B" altvalue="F07B" entity="&#x2740;"/>
		<!--<my:char code="&#x7D;" value="7D" altvalue="F07D" entity="&#x275D;"/>-->
		<my:char code="&#x7D;&#x7D;" value="7D" altvalue="F07D" entity="&#x275D;"/>
		<my:char code="&#x7E;" value="7E" altvalue="F07E" entity="&#x275E;"/>
		<my:char code="&#x81;" value="81" altvalue="F081" entity="&#x2460;"/>
		<my:char code="&#x82;" value="82" altvalue="F082" entity="&#x2461;"/>
		<my:char code="&#x83;" value="83" altvalue="F083" entity="&#x2462;"/>
		<my:char code="&#x84;" value="84" altvalue="F084" entity="&#x2463;"/>
		<my:char code="&#x85;" value="85" altvalue="F085" entity="&#x2464;"/>
		<my:char code="&#x86;" value="86" altvalue="F086" entity="&#x2465;"/>
		<my:char code="&#x87;" value="87" altvalue="F087" entity="&#x2466;"/>
		<my:char code="&#x88;" value="88" altvalue="F088" entity="&#x2467;"/>
		<my:char code="&#x89;" value="89" altvalue="F089" entity="&#x2468;"/>
		<my:char code="&#x8A;" value="8A" altvalue="F08A" entity="&#x2469;"/>
		<my:char code="&#x8C;" value="8C" altvalue="F08C" entity="&#x2776;"/>
		<my:char code="&#x8D;" value="8D" altvalue="F08D" entity="&#x2777;"/>
		<my:char code="&#x8E;" value="8E" altvalue="F08E" entity="&#x2778;"/>
		<my:char code="&#x8F;" value="8F" altvalue="F08F" entity="&#x2779;"/>
		<my:char code="&#x90;" value="90" altvalue="F090" entity="&#x277A;"/>
		<my:char code="&#x91;" value="91" altvalue="F091" entity="&#x277B;"/>
		<my:char code="&#x92;" value="92" altvalue="F092" entity="&#x277C;"/>
		<my:char code="&#x93;" value="93" altvalue="F093" entity="&#x277D;"/>
		<my:char code="&#x94;" value="94" altvalue="F094" entity="&#x277E;"/>
		<my:char code="&#x95;" value="95" altvalue="F095" entity="&#x277F;"/>
		<my:char code="&#x9F;" value="9F" altvalue="F09F" entity="&#x2022;"/>
		<my:char code="&#xA1;" value="A1" altvalue="F0A1" entity="&#x25CC;"/>
		<my:char code="&#xA4;" value="A4" altvalue="F0A4" entity="&#x25C9;"/>
		<my:char code="&#xA6;" value="A6" altvalue="F0A6" entity="&#x274D;"/>
		<my:char code="&#xAA;" value="AA" altvalue="F0AA" entity="&#x2726;"/>
		<my:char code="&#xAB;" value="AB" altvalue="F0AB" entity="&#x2605;"/>
		<my:char code="&#xAC;" value="AC" altvalue="F0AC" entity="&#x2736;"/>
		<my:char code="&#xAD;" value="AD" altvalue="F0AD" entity="&#x2737;"/>
		<my:char code="&#xAE;" value="AE" altvalue="F0AE" entity="&#x2739;"/>
		<my:char code="&#xAF;" value="AF" altvalue="F0AF" entity="&#x2735;"/>
		<my:char code="&#xD5;" value="D5" altvalue="F0D5" entity="&#x232B;"/>
		<my:char code="&#xD6;" value="D6" altvalue="F0D6" entity="&#x2326;"/>
		<my:char code="&#xEF;" value="EF" altvalue="F0EF" entity="&#x21E6;"/>
		<my:char code="&#xF0;" value="F0" altvalue="F0F0" entity="&#x21E8;"/>
		<my:char code="&#xF1;" value="F1" altvalue="F0F1" entity="&#x21E7;"/>
		<my:char code="&#xF2;" value="F2" altvalue="F0F2" entity="&#x21E9;"/>
		<my:char code="&#xFB;" value="FB" altvalue="F0FB" entity="&#x2718;"/>
		<my:char code="&#xFC;" value="FC" altvalue="F0FC" entity="&#x2713;"/>
		<my:char code="&#xFD;" value="FD" altvalue="F0FD" entity="&#x2612;"/>
		<my:char code="&#xFE;" value="FE" altvalue="F0FE" entity="&#x2611;"/>
    </my:recoding-table>


	<!-- ================= -->
	<!-- GENERAL TEMPLATES -->
	<!-- ================= -->

	<!-- Convert hexadecimal color from MS Word to XSL-FO. -->
	<xsl:template name="ConvertHexColor">
		<xsl:param name="hexColor" select="'auto'" />
		<xsl:param name="style" select="'none'" />
		<xsl:param name="type" select="'color'" />
		<xsl:param name="bgColor" select="'none'" />
		<xsl:choose>
			<xsl:when test="$hexColor='auto'">
				<xsl:choose>
					<xsl:when test="$style='three-d-emboss' or $style='ridge'">
						<xsl:text>#B0B0B0</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$type = 'color' ">
								<xsl:choose>
									<xsl:when test="$bgColor = 'none' or string($bgColor) = 'auto'">black</xsl:when>
									<xsl:otherwise>
										<xsl:variable name="decColorR1">
											<xsl:call-template name="ConvertHexCiphToDec">
												<xsl:with-param name="hex"
													select="substring(string($bgColor),1,1)" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="decColorR2">
											<xsl:call-template name="ConvertHexCiphToDec">
												<xsl:with-param name="hex"
													select="substring(string($bgColor),2,1)" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="decColorR" select="16*$decColorR1 + $decColorR2" />
										<xsl:variable name="decColorG1">
											<xsl:call-template name="ConvertHexCiphToDec">
												<xsl:with-param name="hex"
													select="substring(string($bgColor),3,1)" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="decColorG2">
											<xsl:call-template name="ConvertHexCiphToDec">
												<xsl:with-param name="hex"
													select="substring(string($bgColor),4,1)" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="decColorG" select="16*$decColorG1 + $decColorG2" />
										<xsl:variable name="decColorB1">
											<xsl:call-template name="ConvertHexCiphToDec">
												<xsl:with-param name="hex"
													select="substring(string($bgColor),5,1)" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="decColorB2">
											<xsl:call-template name="ConvertHexCiphToDec">
												<xsl:with-param name="hex"
													select="substring(string($bgColor),6,1)" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="decColorB" select="16*$decColorB1 + $decColorB2" />
										<xsl:variable name="isWhite">
											<xsl:call-template name="GetFontColorRGBbg">
												<xsl:with-param name="decColorR" select="$decColorR" />
												<xsl:with-param name="decColorG" select="$decColorG" />
												<xsl:with-param name="decColorB" select="$decColorB" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:choose>
											<xsl:when test="$isWhite = 0">white</xsl:when>
											<xsl:otherwise>black</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$type = 'fill' or $type = 'bgcolor' ">white</xsl:when>
							<xsl:otherwise>black</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('#', $hexColor)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Convert hex color to dec -->
	<xsl:template name="ConvertHexCiphToDec">
		<xsl:param name="hex" />
		<xsl:choose>
			<xsl:when test="$hex = 'a' or $hex = 'A'">10</xsl:when>
			<xsl:when test="$hex = 'b' or $hex = 'B'">11</xsl:when>
			<xsl:when test="$hex = 'c' or $hex = 'C'">12</xsl:when>
			<xsl:when test="$hex = 'd' or $hex = 'D'">13</xsl:when>
			<xsl:when test="$hex = 'e' or $hex = 'E'">14</xsl:when>
			<xsl:when test="$hex = 'f' or $hex = 'F'">15</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$hex" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Check RGB background and set flag isWhite font color -->
	<xsl:template name="GetFontColorRGBbg">
		<xsl:param name="decColorR" />
		<xsl:param name="decColorG" />
		<xsl:param name="decColorB" />
		<xsl:choose>
			<xsl:when test="$decColorR &lt;= 203 and $decColorG = 0 and $decColorB = 0">0</xsl:when>
			<xsl:when test="$decColorR = 0 and $decColorG &lt;= 53 and $decColorB &lt;= 255">0</xsl:when>
			<xsl:when test="$decColorR = 0 and $decColorG = 61 and $decColorB &lt;= 218">0</xsl:when>
			<xsl:when test="$decColorR = 0 and $decColorG &lt;= 103 and $decColorB = 0">0</xsl:when>
			<xsl:when test="$decColorR = 0 and $decColorG = 0 and $decColorB >= 0">0</xsl:when>
			<xsl:when test="$decColorR &lt;= 60 and $decColorG &lt;= 60 and $decColorB &lt;= 60">0</xsl:when>
			<xsl:when test="$decColorR &lt;= 103 and $decColorG &lt;= 51 and $decColorB = 0">0</xsl:when>
			<xsl:when test="$decColorR &lt;= 103 and $decColorG &lt;= 21 and $decColorB &lt;= 154">0</xsl:when>
			<xsl:when test="$decColorR &lt;= 190 and $decColorG = 0 and $decColorB &lt;= 33">0</xsl:when>
			<xsl:when test="$decColorR &lt;= 173 and $decColorG = 0 and $decColorB &lt;= 79">0</xsl:when>
			<xsl:when test="$decColorR &lt;= 147 and $decColorG = 0 and $decColorB &lt;= 147">0</xsl:when>
			<xsl:when test="$decColorR &lt;= 105 and $decColorG = 0 and $decColorB &lt;= 255">0</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Check for existing unsupported elements. -->
	<xsl:template name="CheckNotSupportedElements">
		<xsl:param name="elements" />
		<xsl:for-each select="$elements">
			<xsl:if test="contains($not-supported-inlines, .)">
				<xsl:value-of select="'presents'" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Convert "Symbol" and "Wingdings" symbol codes to Unicode. -->
	<xsl:template name="ConvertSymbol">
		<xsl:param name="font-family" />
		<xsl:param name="symbol" />
		<xsl:apply-templates select="document('')//my:recoding-table[@font=$font-family]/my:char[@value=$symbol or @altvalue=$symbol]" />
	</xsl:template>

	<!-- Convert string with chars from fonts "Symbol" and "Wingdings" symbol codes to Unicode. -->
	<xsl:template name="ConvertString">
		<xsl:param name="font-family" />
		<xsl:param name="string" />
		<xsl:if test="string-length($string)">
			<xsl:value-of select="substring(document('')//my:recoding-table[@font=$font-family]/my:char[substring(@code, 1, 1)=substring($string, 1, 1)]/@entity, 1, 1)" />
			<xsl:call-template name="ConvertString">
				<xsl:with-param name="font-family" select="$font-family" />
				<xsl:with-param name="string" select="substring($string, 2)" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- Convert symbol codes (expressed as a unicode) to Unicode character. -->
	<xsl:template name="ConvertChars">
		<xsl:param name="font-family" />
		<xsl:param name="char-string" />
		<xsl:variable name="recorded-char" select="document('')//my:recoding-table[@font=$font-family]/my:char[substring(@code, 1, 1)=$char-string]" />
		<xsl:choose>
			<xsl:when test="$recorded-char">
				<xsl:attribute name="font-size">
          			<xsl:value-of select="$default-font-size.symbol" /><xsl:text>pt</xsl:text>
       			 </xsl:attribute>
				<xsl:attribute name="font-family"><xsl:text>ZapfDingbats, Arial</xsl:text></xsl:attribute>
				<xsl:apply-templates select="$recorded-char" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$char-string" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Apply an entry from a recording table -->
	<xsl:template match="my:recoding-table/my:char">
		<xsl:attribute name="font-family"><xsl:text>Symbol, Zapf Dingbats, Helvetica</xsl:text></xsl:attribute>
		<xsl:value-of select="substring(@entity,1,1)" />
	</xsl:template>

	<!-- Set border-style. -->
	<xsl:template name="SetBorderStyle">
		<xsl:param name="attribute-name" />
		<xsl:param name="style" />
		<xsl:attribute name="{$attribute-name}">
      <xsl:choose>
        <xsl:when test="$style='double'"><xsl:text>double</xsl:text></xsl:when>
        <xsl:when test="$style='dotted' or $style='dot-dot-dash' or $style='basic-black-dots' or $style='basic-white-dots' or $style='coupon-cutout-dots'"><xsl:text>dotted</xsl:text></xsl:when>
        <xsl:when test="$style='dashed' or $style='dot-dash' or $style='dash-small-gap' or $style='dash-dot-stroked' or $style='basic-black-dashes' or $style='basic-white-dashes' or $style='coupon-cutout-dashes'"><xsl:text>dashed</xsl:text></xsl:when>
        <xsl:when test="$style='three-d-engrave'"><xsl:text>groove</xsl:text></xsl:when>  
        <xsl:when test="$style='three-d-emboss'"><xsl:text>ridge</xsl:text></xsl:when>
        <xsl:when test="$style='inset'"><xsl:text>inset</xsl:text></xsl:when>
        <xsl:when test="$style='outset'"><xsl:text>outset</xsl:text></xsl:when>
        <xsl:otherwise>
            <xsl:choose>
                <xsl:when test="$style != 'nil' and $style != 'none'"><xsl:text>solid</xsl:text></xsl:when>
                <xsl:otherwise><xsl:text>none</xsl:text></xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
	</xsl:template>

	<!-- Convert tableWidthPropertyType (MS Word) to points or percents. -->
	<xsl:template name="ConvertTableWidthPropertyType">
		<xsl:param name="type" select="auto" />
		<xsl:param name="value" select="0" />
		<xsl:choose>
			<xsl:when test="$type='nil' or $type='dxa'">
				<xsl:value-of select="$value div 20" />
				<xsl:text>pt</xsl:text>
			</xsl:when>
			<xsl:when test="$type='pct'">
				<xsl:value-of select="$value div 50" />
				<xsl:text>%</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>auto</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- The template return media subtype from the name of the binary data. -->
	<xsl:template name="RetrieveMediaSubtype">
		<xsl:param name="name" />
		<xsl:choose>
			<xsl:when test="contains($name, '.jpg') or contains($name, '.jpeg') or contains($name, '.jpe') or contains($name, '.jfif')">
				<xsl:text>jpeg</xsl:text>
			</xsl:when>
			<xsl:when test="contains($name, '.gif')">
				<xsl:text>gif</xsl:text>
			</xsl:when>
			<xsl:when test="contains($name, '.tif') or contains($name, '.tiff')">
				<xsl:text>tiff</xsl:text>
			</xsl:when>
			<xsl:when test="contains($name, '.png')">
				<xsl:text>png</xsl:text>
			</xsl:when>
			<xsl:when test="contains($name, '.emf')">
				<xsl:text>emf</xsl:text>
			</xsl:when>
			<xsl:when test="contains($name, '.emz')">
				<xsl:text>emz</xsl:text>
			</xsl:when>
			<xsl:when test="contains($name, '.eps')">
				<xsl:text>eps</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>auto</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Get content width from CSS style. -->
	<xsl:template name="GetWidthFromCSSStyle">
		<xsl:param name="style" />
		<xsl:param name="object" />
		<xsl:param name="factor" select="1" />
		<xsl:if test="contains($style, 'width:')">
			<xsl:variable name="width-with-trailing" select="substring-after($style, 'width:')" />
			<xsl:variable name="width">
				<xsl:choose>
					<xsl:when test="contains($width-with-trailing, ';')">
						<xsl:value-of select="substring-before($width-with-trailing, ';')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$width-with-trailing" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="units" select="translate($width, '0123456789.', '')" />
			<xsl:variable name="numeric-value">
				<xsl:choose>
					<xsl:when test="not($units)">
						<xsl:value-of select="$width" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before($width, $units)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="concat($factor * $numeric-value, $units)" />
		</xsl:if>
	</xsl:template>

	<!-- Get content height from CSS style. -->
	<xsl:template name="GetHeightFromCSSStyle">
		<xsl:param name="style" />
		<xsl:param name="object" />
		<xsl:param name="factor" select="1" />
		<xsl:if test="contains($style, 'height:')">
			<xsl:variable name="height-with-trailing" select="substring-after($style, 'height:')" />
			<xsl:variable name="height">
				<xsl:choose>
					<xsl:when test="contains($height-with-trailing, ';')">
						<xsl:value-of select="substring-before($height-with-trailing, ';')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$height-with-trailing" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="units" select="translate($height, '0123456789.', '')" />
			<xsl:variable name="numeric-value">
				<xsl:choose>
					<xsl:when test="not($units)">
						<xsl:value-of select="$height" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before($height, $units)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="concat($factor * $numeric-value, $units)" />
		</xsl:if>
	</xsl:template>

	<!-- The template parses an CSS style. -->
	<xsl:template name="ParsingCSSStyle">
		<xsl:param name="style" />
		<xsl:param name="object" />
		<xsl:param name="x-factor" select="1" />
		<xsl:param name="y-factor" select="1" />
		<xsl:if test="contains($style, 'width:')">
			<xsl:variable name="attribute-name">
				<xsl:choose>
					<xsl:when test="$object='image'">
						<xsl:text>content-width</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>width</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="{$attribute-name}">
		        <xsl:call-template name="GetWidthFromCSSStyle">
					<xsl:with-param name="style" select="$style" />  
					<xsl:with-param name="object" select="$object" />  
					<xsl:with-param name="factor" select="$x-factor" />  
		        </xsl:call-template>    
		    </xsl:attribute>
		</xsl:if>
		<xsl:if test="contains($style, 'height:')">
			<xsl:variable name="attribute-name">
				<xsl:choose>
					<xsl:when test="$object='image'">
						<xsl:text>content-height</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>height</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="{$attribute-name}">
				<xsl:call-template name="GetHeightFromCSSStyle">
					<xsl:with-param name="style" select="$style" />
					<xsl:with-param name="object" select="$object" />
					<xsl:with-param name="factor" select="$y-factor" />
				</xsl:call-template>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

	<!-- Normalize font family. -->
	<xsl:template name="NormalizeFontFamilyName">
		<xsl:param name="font-family" />
		<!-- <xsl:choose> <xsl:when test="contains($font-family, ' ')"> <xsl:value-of 
			select="substring-before($font-family, ' ')"/> <xsl:call-template name="NormalizeFontFamilyName"> 
			<xsl:with-param name="font-family" select="substring-after($font-family, 
			' ')"/> </xsl:call-template> </xsl:when> <xsl:otherwise><xsl:value-of select="$font-family"/></xsl:otherwise> 
			</xsl:choose> -->
		<xsl:value-of select="$font-family" />
	</xsl:template>

	<!-- Set page number format. -->
	<xsl:template name="PageNumberFormat">
		<xsl:param name="format" />
		<xsl:choose>
			<xsl:when test="$format='Arabic'">
				<xsl:text>1</xsl:text>
			</xsl:when>
			<xsl:when test="$format='ArabicDash'">
				<xsl:text>- 1 -</xsl:text>
			</xsl:when>
			<xsl:when test="$format='alphabetic'">
				<xsl:text>a</xsl:text>
			</xsl:when>
			<xsl:when test="$format='ALPHABETIC'">
				<xsl:text>A</xsl:text>
			</xsl:when>
			<xsl:when test="$format='roman'">
				<xsl:text>i</xsl:text>
			</xsl:when>
			<xsl:when test="$format='ROMAN'">
				<xsl:text>I</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>1</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- ================= -->
	<!-- SPECIAL TEMPLATES -->
	<!-- ================= -->
	
    <!-- Count the number of spanned cells. -->
    <xsl:template name="CountCellsSpanned">
		<xsl:param name="number-cells-spanned" />
		<xsl:param name="following-cell" />
		<xsl:param name="col-or-row" />
		<xsl:param name="real-column-number" />
		<xsl:choose>
			<xsl:when test="$col-or-row='col' and $following-cell/w:tcPr/w:hmerge[not(@w:val='restart')]">
				<xsl:call-template name="CountCellsSpanned">
					<xsl:with-param name="number-cells-spanned" select="$number-cells-spanned + 1" />
					<xsl:with-param name="following-cell" select="$following-cell/following-sibling::w:tc[1]" />
					<xsl:with-param name="col-or-row" select="'col'" />
					<xsl:with-param name="real-column-number" select="$real-column-number" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$col-or-row='row' and $following-cell/w:tcPr/w:vmerge[not(@w:val='restart')]">
				<xsl:call-template name="CountCellsSpanned">
					<xsl:with-param name="number-cells-spanned" select="$number-cells-spanned + 1" />
					<xsl:with-param name="following-cell" select="$following-cell/ancestor::w:tr[1]/following-sibling::w:tr[1]/w:tc[count(.|preceding-sibling::w:tc[not(w:tcPr/w:gridSpan)]) + sum(preceding-sibling::w:tc/w:tcPr/w:gridSpan/@w:val) = $real-column-number]" />
					<xsl:with-param name="col-or-row" select="'row'" />
					<xsl:with-param name="real-column-number" select="$real-column-number" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$col-or-row='col'">
						<xsl:attribute name="number-columns-spanned">
	                <xsl:value-of select="$number-cells-spanned" />
	              </xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="number-rows-spanned">
	                <xsl:value-of select="$number-cells-spanned" />
	              </xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Select alt font name. -->
	<xsl:template name="AltFontName">
		<xsl:param name="font-name" />
		<!-- <xsl:variable name="alt-font-name" select="key('fonts', $font-name, 
			ancestor::w:wordDocument)/w:altName"/> <xsl:choose> <xsl:when test="$alt-font-name"> 
			<xsl:variable name="apos">'</xsl:variable> <xsl:value-of select="concat($apos, 
			$font-name, $apos, ', ', $apos, $alt-font-name/@w:val, $apos)"/> </xsl:when> 
			<xsl:otherwise> <xsl:value-of select="$font-name"/> </xsl:otherwise> </xsl:choose> -->
		<xsl:value-of select="$font-name" />
	</xsl:template>

	<!-- Concatanate an instruction -->
	<xsl:template name="ConcatInstruction">
		<xsl:param name="current-run-element" select="." />
		<xsl:param name="num-nested-loops" select="1" />
		<xsl:value-of select="normalize-space($current-run-element/preceding-sibling::w:r[w:instrText][1]/w:instrText)" />
	</xsl:template>
    
	<xsl:template name="PutOneBorderSpecifics">
		<xsl:param name="specifier-node" />
		<xsl:param name="side" />
		<xsl:call-template name="SetBorderStyle">
			<xsl:with-param name="attribute-name" select="concat('border-', $side, '-style')" />
			<xsl:with-param name="style" select="$specifier-node/@w:val" />
		</xsl:call-template>
		<xsl:if test="$specifier-node/@w:color">
			<xsl:attribute name="border-{$side}-color">
				<xsl:call-template name="ConvertHexColor">
					<xsl:with-param name="hexColor" select="$specifier-node/@w:color" />
					<xsl:with-param name="style" select="$specifier-node/@w:val" />
				</xsl:call-template>
			</xsl:attribute>
		</xsl:if>
		<!-- set half border-width on the cell -->
		<xsl:if test="$specifier-node/@w:sz">
			<xsl:attribute name="border-{$side}-width">
                <xsl:value-of select="$specifier-node/@w:sz div 16" /><xsl:text>pt</xsl:text>
            </xsl:attribute>
		</xsl:if>
		<!-- if wx:bdrwidth attribute exists, it overwrites the w:sz -->
		<xsl:if test="$specifier-node/@wx:bdrwidth">
			<xsl:attribute name="border-{$side}-width">
                <xsl:value-of select="$specifier-node/@wx:bdrwidth div 20" /><xsl:text>pt</xsl:text>
            </xsl:attribute>
		</xsl:if>
	</xsl:template>

	<xsl:template name="PutBorderSpecificsForCell">
		<xsl:param name="specifier-node" />
		<xsl:param name="cell" />
		<xsl:param name="direction" />
		<!-- We need to determine if this border is only border of cell or border of table -->
		<!-- following X-Pathes keep in mind contiguous tables and merged cells -->
		<xsl:variable name="leftside-cells-exist" select="$cell/preceding-sibling::w:tc[ancestor::w:tbl = $cell/ancestor::w:tbl]" />
		<xsl:variable name="upper-cells-exist" select="$cell/parent::w:tr/preceding-sibling::w:tr[ancestor::w:tbl = $cell/ancestor::w:tbl]" />
		<xsl:variable name="rightside-cells-exist" select="$cell/following-sibling::w:tc[ancestor::w:tbl = $cell/ancestor::w:tbl and (not(w:tcPr/w:hmerge) or w:tcPr/w:hmerge/@w:val='restart')]" />
		<xsl:variable name="position" select="count($cell/preceding-sibling::w:tc[ancestor::w:tr = $cell/ancestor::w:tr]) + 1" />
		<xsl:variable name="bottomside-cells-exist" select="$cell/parent::w:tr/following-sibling::w:tr[ancestor::w:tbl = $cell/ancestor::w:tbl and w:tc[position() = $position and (not(w:tcPr/w:vmerge) or w:tcPr/w:vmerge/@w:val='restart')]]" />
		<xsl:choose>
			<xsl:when test="$direction = 'vertical'">
				<xsl:if test="$cell">
					<xsl:if test="count($cell/../w:tc) &gt; 1">
						<xsl:choose>
							<xsl:when test="not($leftside-cells-exist)">
								<!-- is the first cell in a row -->
								<xsl:call-template name="PutOneBorderSpecifics">
									<xsl:with-param name="specifier-node" select="$specifier-node" />
									<xsl:with-param name="side" select="'right'" />
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="not($rightside-cells-exist)">
								<!-- is the last cell in a row -->
								<xsl:call-template name="PutOneBorderSpecifics">
									<xsl:with-param name="specifier-node" select="$specifier-node" />
									<xsl:with-param name="side" select="'left'" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<!-- set for both sides... -->
								<!-- LEFT SIDE -->
								<xsl:call-template name="PutOneBorderSpecifics">
									<xsl:with-param name="specifier-node" select="$specifier-node" />
									<xsl:with-param name="side" select="'left'" />
								</xsl:call-template>
								<!-- RIGHT SIDE -->
								<xsl:call-template name="PutOneBorderSpecifics">
									<xsl:with-param name="specifier-node" select="$specifier-node" />
									<xsl:with-param name="side" select="'right'" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$direction = 'horizontal'">
				<xsl:if test="$cell">
					<xsl:if test="count($cell/parent::w:tr/parent::w:tbl/w:tr) &gt; 1">
						<xsl:choose>
							<xsl:when test="not($upper-cells-exist)">
								<!-- the cell is in the first row -->
								<xsl:call-template name="PutOneBorderSpecifics">
									<xsl:with-param name="specifier-node" select="$specifier-node" />
									<xsl:with-param name="side" select="'bottom'" />
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="not($bottomside-cells-exist)">
								<!-- the cell is in the last row -->
								<xsl:call-template name="PutOneBorderSpecifics">
									<xsl:with-param name="specifier-node" select="$specifier-node" />
									<xsl:with-param name="side" select="'top'" />
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<!-- set for both sides -->
								<!-- BOTTOM SIDE -->
								<xsl:call-template name="PutOneBorderSpecifics">
									<xsl:with-param name="specifier-node" select="$specifier-node" />
									<xsl:with-param name="side" select="'bottom'" />
								</xsl:call-template>
								<!-- TOP SIDE -->
								<xsl:call-template name="PutOneBorderSpecifics">
									<xsl:with-param name="specifier-node" select="$specifier-node" />
									<xsl:with-param name="side" select="'top'" />
								</xsl:call-template>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:if>
			</xsl:when>
			<!-- keep the cases separate for this moment -->
			<xsl:when test="$direction = 'top'">
				<xsl:if test="name($specifier-node/..)='w:tcBorders' or not($upper-cells-exist) "> <!-- w:tblBorders, w:tcBorders -->
					<xsl:call-template name="PutOneBorderSpecifics">
						<xsl:with-param name="specifier-node" select="$specifier-node" />
						<xsl:with-param name="side" select="'top'" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$direction = 'right'">
				<xsl:if test="name($specifier-node/..)='w:tcBorders' or not($rightside-cells-exist) "> <!-- w:tblBorders, w:tcBorders -->
					<xsl:call-template name="PutOneBorderSpecifics">
						<xsl:with-param name="specifier-node" select="$specifier-node" />
						<xsl:with-param name="side" select="'right'" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$direction = 'bottom'">
				<xsl:if test="name($specifier-node/..)='w:tcBorders' or not($bottomside-cells-exist) "> <!-- w:tblBorders, w:tcBorders -->
					<xsl:call-template name="PutOneBorderSpecifics">
						<xsl:with-param name="specifier-node" select="$specifier-node" />
						<xsl:with-param name="side" select="'bottom'" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$direction = 'left'">
				<xsl:if test="name($specifier-node/..)='w:tcBorders' or not($leftside-cells-exist) "> <!-- w:tblBorders, w:tcBorders -->
					<xsl:call-template name="PutOneBorderSpecifics">
						<xsl:with-param name="specifier-node" select="$specifier-node" />
						<xsl:with-param name="side" select="'left'" />
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

    <!-- Chooses the last value from the list of items. -->   
	<xsl:template name="AnalyzeOverridings">
		<xsl:param name="list" />
		<xsl:param name="sep" />
		<xsl:if test="string-length($list) &gt; 0 and string-length($sep) &gt; 0">
			<xsl:variable name="current-item">
				<xsl:choose>
					<xsl:when test="contains($list, $sep)">
						<xsl:value-of select="substring-before($list, $sep)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$list" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="item-from-rest">
				<xsl:call-template name="AnalyzeOverridings">
					<xsl:with-param name="list" select="substring-after($list, $sep)" />
					<xsl:with-param name="sep" select="$sep" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="normalize-space($item-from-rest)">
					<xsl:value-of select="$item-from-rest" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$current-item" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- Converts inches, points, centimeters, etc. to user units as defined in SVG -->
	<xsl:template name="ConvertToUserUnits">
		<xsl:param name="value" />
		<xsl:variable name="unit" select="translate($value, '-0123456789.', '')" />
		<xsl:choose>
			<xsl:when test="not($unit)">
				<xsl:value-of select="$value" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="numeric-value"
					select="number(substring-before($value, $unit))" />
				<xsl:choose>
					<xsl:when test="$unit = 'px'">
						<xsl:value-of select="round($numeric-value)" />
					</xsl:when>
					<xsl:when test="$unit = 'pt'">
						<xsl:value-of select="round(1.25 * $numeric-value)" />
					</xsl:when>
					<xsl:when test="$unit = 'pc'">
						<xsl:value-of select="round(15 * $numeric-value)" />
					</xsl:when>
					<xsl:when test="$unit = 'mm'">
						<xsl:value-of select="round(3.543307 * $numeric-value)" />
					</xsl:when>
					<xsl:when test="$unit = 'cm'">
						<xsl:value-of select="round(35.43307 * $numeric-value)" />
					</xsl:when>
					<xsl:when test="$unit = 'in'">
						<xsl:value-of select="round(90 * $numeric-value)" />
					</xsl:when>
					<xsl:otherwise>
						<!-- suppose the value already is in user units (SVG) -->
						<xsl:value-of select="$numeric-value" /> <!--<xsl:value-of select="round(1.25 * $numeric-value)"/> -->
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Round specified number to the needed sign after a comma -->
	<xsl:template name="DoubleRound">
		<xsl:param name="Source" />
		<xsl:param name="Precision">0.001</xsl:param>
		<xsl:choose>
			<xsl:when test="string(number($Source))='NaN'">
				<xsl:value-of select="$Source" />  <!-- not a number! return source as is -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$Precision=0">
						<xsl:value-of select="number($Source)" />  <!-- round not need -->
					</xsl:when>
					<xsl:when test="$Precision=1">
						<xsl:value-of select="round(number($Source))" />  <!-- simple round -->
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="round(number($Source) div $Precision) * $Precision" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Convert string to lowercase -->
	<xsl:template name="ConvertStringToLowercase">
		<xsl:param name="field-name" />
		<xsl:variable name="lc-letter" select="'abcdefghijklmnopqrstuvwxyz'" />
		<xsl:variable name="uc-letter" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
		<xsl:value-of select="translate($field-name, $uc-letter, $lc-letter)" />
	</xsl:template>

	<xsl:template name="HexCompare">
		<xsl:param name="hex1" />
		<xsl:param name="hex2" />
		<xsl:choose>
			<xsl:when test="string-length($hex1) > string-length($hex2)">1</xsl:when>
			<xsl:when test="string-length($hex2) > string-length($hex1)">-1</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="hex1lower"
					select="translate($hex1, 'ABCDEF', 'abcdef' )" />
				<xsl:variable name="hex2lower"
					select="translate($hex2, 'ABCDEF', 'abcdef' )" />
				<xsl:choose>
					<xsl:when test="$hex1lower = $hex2lower">0</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="HexCompareRecursive">
							<xsl:with-param name="hex1" select="$hex1lower" />
							<xsl:with-param name="hex2" select="$hex2lower" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="HexCompareRecursive">
		<xsl:param name="hex1" />
		<xsl:param name="hex2" />
		<xsl:choose>
			<xsl:when test="string-length($hex1)>0 and string-length($hex2)>0">
				<xsl:variable name="char1" select="substring($hex1, 1, 1)" />
				<xsl:variable name="char2" select="substring($hex2, 1, 1)" />
				<xsl:variable name="num1">
					<xsl:call-template name="ConvertHexCiphToDec">
						<xsl:with-param name="hex" select="$char1" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="num2">
					<xsl:call-template name="ConvertHexCiphToDec">
						<xsl:with-param name="hex" select="$char2" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$num1 > $num2">1</xsl:when>
					<xsl:when test="$num2 > $num1">-1</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="HexCompareRecursive">
							<xsl:with-param name="hex1" select="substring($hex1, 2)" />
							<xsl:with-param name="hex2" select="substring($hex2, 2)" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Convert any lengths to the basic units. -->
	<xsl:template name="convert-to-basic-units">
		<xsl:param name="length" />
		<xsl:variable name="length-numeric-value" select="translate ($length, 'ptxcinme ', '')" />
		<xsl:variable name="length-unit" select="translate ($length, '-0123456789. ', '')" />
		<xsl:variable name="length-scale-factor">
			<xsl:choose>
				<xsl:when test="$length-numeric-value = 0">0</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="get-unit-scaling-factor">
						<xsl:with-param name="unit" select="$length-unit" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="round($length-numeric-value * $length-scale-factor)" />
	</xsl:template>

	<!-- This template expresses all length units in 1/360s of mm. -->
	<!-- This is the largest unit in which both 1pt and 1 mm get -->
	<!-- integer values. Also spellchecks length units. -->
	<xsl:template name="get-unit-scaling-factor">
		<xsl:param name="unit" />
		<xsl:choose>
			<xsl:when test="$unit = 'cm'">3600</xsl:when>
			<xsl:when test="$unit = 'mm'">360</xsl:when>
			<xsl:when test="$unit = 'in'">9144</xsl:when>
			<xsl:when test="$unit = 'pt'">127</xsl:when>
			<xsl:when test="$unit = 'pc'">1524</xsl:when>
			<xsl:when test="$unit = 'em'">
				<xsl:text>1524</xsl:text> <!-- defaulting to 12pt -->
			</xsl:when>
			<xsl:when test="$unit = 'ex'">
				<xsl:text>700</xsl:text>  <!-- defaulting to 12pt x 0.46 -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>360</xsl:text>  <!-- defaulting to 1mm -->
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
