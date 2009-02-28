/*
    vhd2vl v2.2
    VHDL to Verilog RTL translator
    Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd - http://www.ocean-logic.com
    Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
    Modifications Copyright (C) 2008, 2009 Larry Doolittle - LBNL

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

%option noinput
%option nounput

%{
#include <stdio.h>
#include <string.h>
#include "def.h"
#include "vhd2vl.tab.h"

extern int lineno;

extern int skipRem;

void getstring(int skip);
void getbasedstring(int skip);

%}
%%

[ \t] {;}

"--".*\n {
  if (skipRem == 0) {
    /* sometimes comments should be dropped by lex - 
     * e.g. in expressions - this makes the grammar much simpler
     */
    yylval.txt=malloc(strlen(yytext)+1);
    strcpy(yylval.txt, yytext);
    yylval.txt[0]='/'; 
    yylval.txt[1]='/';
    lineno++; 
    return REM;
  } else {
    lineno++; 
  }
}
"library ".*\n {lineno++;}
"use ".*\n {lineno++;}

"\x0d\n" |
\n { lineno++;}

"entity" { return ENTITY; }
"is" { return IS; }
"port" { return PORT; }
"generic" { return GENERIC; }
"map" { return MAP; }
"in" { return IN; }
"out" { return OUT; }
"inout" { return INOUT; }
"time" |
"natural" |
"positive" |
"integer" { return INTEGER; }
"boolean" |
"std_logic" |
"std_ulogic" { return BIT; }
"signed" |
"unsigned" |
"std_logic_vector" |
"std_ulogic_vector" { return BITVECT; }
"downto" { return DOWNTO; }
"to" { return TO; }
"type" {return TYPE; }
"end" { return END; }
"for" { return FOR; }
"loop" { return LOOP; }
"generate" { return GENERATE; }
"architecture" { return ARCHITECTURE; }
"component" { return COMPONENT; }
"of" { return OF; }
"signal" { return SIGNAL; }
"begin" { return BEGN; }
"not" { return NOT; }
"when" { return WHEN; }
"exit" { return EXIT; }
"with" {
  return WITH; }
"select" { return SELECT; }
"others" { return OTHERS; }
"range" { return RANGE; }
"process" { return PROCESS; }
"variable" { return VARIABLE; }
"constant" { return CONSTANT; }
"null" { return NULLV; }
"if" { return IF; }
"then" { return THEN; }
"elsif" { return ELSIF; }
"else" { return ELSE; }
"case" { return CASE; }
"after" { return AFTER; }
"and" { return AND; }
"or" { return OR; }
"xor" { return XOR; }
"xnor" { return XNOR; }
"mod" { return MOD; }
"event" { return EVENT; }
"rising_edge" { return POSEDGE;}
"falling_edge" { return NEGEDGE;}
"resize" { return CONVFUNC_2;}
"to_unsigned" { return CONVFUNC_2;}

\"[ \!#-~]*\" |
\'[01xz]\' { getstring(1); return STRING;}

#[0-9a-f]*# {
  getbasedstring(1); /* skip leading # */
  return BASED;
}

[a-zA-Z_$][a-zA-Z0-9_$.]* {
  yylval.txt=malloc(strlen(yytext)+1);
  strcpy(yylval.txt, yytext);
  return NAME;
}

[0-9]+ {
  sscanf(yytext, "%d", &yylval.n);
  return NATURAL;
}

. { return yytext[0]; }

%%

void getstring(int skip){
/* Gets a string excluding " or ' */
int i;

  for(i=skip; yytext[i]!='"' && yytext[i]!='\'' && yytext[i]!=0; i++);
  yytext[i]=0;
  yylval.txt=malloc(i+1);
  strcpy(yylval.txt, yytext+skip);
}

void getbasedstring(int skip){
/* Gets a string excluding # */
int i;

  for(i=skip; yytext[i]!='#' && yytext[i]!=0; i++);
  yytext[i]=0;
  yylval.txt=malloc(i+1);
  strcpy(yylval.txt, yytext+skip);
}

void yyerror(char *s){
  fprintf(stderr,"%s at \"%s\" in line %d.\n\n",s,yytext,lineno);
}
