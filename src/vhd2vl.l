/*
    vhd2vl v2.3
    VHDL to Verilog RTL translator
    Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd - http://www.ocean-logic.com
    Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc
    Modifications Copyright (C) 2008-2010 Larry Doolittle - LBNL

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
%option noyywrap

%{
#include <stdio.h>
#include <string.h>
#include "def.h"
#include "vhd2vl.tab.h"

extern int lineno;

extern int skipRem;

void getstring(unsigned skip);
void getbasedstring(unsigned skip);
int scan_int(char *s);

%}
%%

[ \t] {;}

"--".*\n {
  lineno++;
  if (skipRem == 0) {
    /* sometimes comments should be dropped by lex -
     * e.g. in expressions - this makes the grammar much simpler
     */
    size_t l=strlen(yytext);
    yylval.txt=malloc(l+1);
    strcpy(yylval.txt, yytext);
    yylval.txt[0]='/';
    yylval.txt[1]='/';
    if(yylval.txt[l-2]=='\r') {
       yylval.txt[l-2]='\n';
       yylval.txt[l-1]='\0';
    }
    return REM;
  }
}

"\x0d\n" |
\n                                { lineno++; }

"abs"                             { return ABS; }
"after"                           { return AFTER; }
"and"                             { return AND; }
"architecture"                    { return ARCHITECTURE; }
"array"                           { return ARRAY; }
"assert"                          { return ASSERT; }
"begin"                           { return BEGN; }
"case"                            { return CASE; }
"component"                       { return COMPONENT; }
"constant"                        { return CONSTANT; }
"downto"                          { return DOWNTO; }
"else"                            { return ELSE; }
"elsif"                           { return ELSIF; }
"end"                             { return END; }
"entity"                          { return ENTITY; }
"entity ".*\.                     { ; /* to remove entity instantiation */ }
"exit"                            { return EXIT; }
"for"                             { return FOR; }
"generate"                        { return GENERATE; }
"generic"                         { return GENERIC; }
"if"                              { return IF; }
"in"                              { return IN; }
"inout"                           { return INOUT; }
"is"                              { return IS; }
"library ".*\n                    { lineno++; }
"loop"                            { return LOOP; }
"map"                             { return MAP; }
"mod"                             { return MOD; }
"nand"                            { return NAND; }
"nor"                             { return NOR; }
"not"                             { return NOT; }
"null"                            { return NULLV; }
"of"                              { return OF; }
"open"                            { return OPEN; }
"out"                             { return OUT; }
"or"                              { return OR; }
"others"                          { return OTHERS; }
"port"                            { return PORT; }
"process"                         { return PROCESS; }
"range"                           { return RANGE; }
"rem"                             { return RW_REM; }
"report"                          { return REPORT;}
"rol"                             { return ROL; }
"ror"                             { return ROR; }
"select"                          { return SELECT; }
"severity"                        { return SEVERITY;}
"signal"                          { return SIGNAL; }
"sla"                             { return SLA; }
"sll"                             { return SLL; }
"sra"                             { return SRA; }
"srl"                             { return SRL; }
"then"                            { return THEN; }
"to"                              { return TO; }
"type"                            { return TYPE; }
"use ".*\n                        { lineno++; }
"variable"                        { return VARIABLE; }
"when"                            { return WHEN; }
"while"                           { return WHILE; }
"with"                            { return WITH; }
"xnor"                            { return XNOR; }
"xor"                             { return XOR; }

"time" |
"natural" |
"positive" |
"integer"                         { return INTEGER; }
"boolean" |
"std_logic" |
"std_ulogic"                      { return BIT; }
"signed" |
"unsigned" |
"std_logic_vector" |
"std_ulogic_vector"               { return BITVECT; }
"real"                            { return REAL; }
"resize" |
"to_unsigned"                     { return CONVFUNC_2; }
"to_integer" |
"conv_integer"                    { return CONVFUNC_1; }

"event"                           { return EVENT; }
"rising_edge"                     { return POSEDGE; }
"falling_edge"                    { return NEGEDGE; }

"left" |
"high"                            { return LEFT; }

"failure"                         { return FAILURE; }
"error"                           { return ERROR; }
"warning"                         { return WARNING; }
"note"                            { return NOTE; }

"**"                              { return POW; }

\"[ \!#-~]*\" |
\'[01xz]\' {
  getstring(1);
  return STRING;
}

#[0-9a-f]*# {
  getbasedstring(1); /* skip leading # */
  return BASED;
}

[a-zA-Z_$][a-zA-Z0-9_$.]* {
  yylval.txt=malloc(strlen(yytext)+1);
  strcpy(yylval.txt, yytext);
  return NAME;
}

[0-9][0-9_]* {
  yylval.n = scan_int(yytext);
  return NATURAL;
}

[0-9]+e[-+]?[0-9]+ |
[0-9]+\.[0-9]+e[-+]?[0-9]+ {
  yylval.txt=malloc(strlen(yytext)+1);
  strcpy(yylval.txt, yytext);
  return SCIENTIFIC;
}

[0-9]+\.[0-9]+ {
  getstring(0);
  return FLOAT;
}

. { return yytext[0]; }

%%

void getstring(unsigned skip){
/* Gets a string excluding " or ' */
  unsigned i;
  for(i=skip; yytext[i]!='"' && yytext[i]!='\'' && yytext[i]!=0; i++);
  yytext[i]=0;
  yylval.txt=malloc(i+1);
  strcpy(yylval.txt, yytext+skip);
}

void getbasedstring(unsigned skip){
/* Gets a string excluding # */
  unsigned i;
  for(i=skip; yytext[i]!='#' && yytext[i]!=0; i++);
  yytext[i]=0;
  yylval.txt=malloc(i+1);
  strcpy(yylval.txt, yytext+skip);
}

int scan_int(char *s){
  char c;
  int nn = 0;
  while ((c=*s++)) {
    if (c>='0' && c<='9') nn = nn*10 + (c-'0');
    /* ignore underscores and any other non-digit; depend on
     * the lex pattern to only feed us digits and underscores */
  }
  return nn;
}

void yyerror(char *s){
  fprintf(stderr,"%s at \"%s\" in line %d.\n\n",s,yytext,lineno);
}
