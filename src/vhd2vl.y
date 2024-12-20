/*
    vhd2vl v3.0
    VHDL to Verilog RTL translator
    Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd - http://www.ocean-logic.com
    Modifications (C) 2006 Mark Gonzales - PMC Sierra Inc
    Modifications (C) 2010 Shankar Giri
    Modifications (C) 2002-2023 Larry Doolittle
    Modifications (C) 2017 Rodrigo A. Melo

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

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <assert.h>
#include "def.h"

#define VHD2VL_VER "3.0"

int yylex(void);
void yyerror(const char *s);

int vlog_ver=2001;

/* You will of course want to tinker with these if you use a debugging
 * malloc(), otherwise all the line numbers will point here.
 */
void *xmalloc(size_t size) {
	void *p = malloc(size);
	if (!p) {
		perror("malloc");
		exit(2);
	}
	return p;
}
void *xrealloc(void *ptr, size_t size) {

	void *p = realloc(ptr, size);
	if (!p) {
		perror("realloc");
		exit(2);
	}
	return p;
}

char *xstrdup(const char *s) {
	size_t l = strlen(s);
	char *x = xmalloc(l+1);
	memcpy(x, s, l+1);
	return x;
}

int skipRem = 0;
int lineno=1;

sglist *io_list=NULL;
sglist *sig_list=NULL;
sglist *type_list=NULL;
blknamelist *blkname_list=NULL;

/* need a stack of clock-edges because all edges are processed before all processes are processed.
 * Edges are processed in source file order, processes are processed in reverse source file order.
 * The original scheme of just one clkedge variable makes all clocked processes have the edge sensitivity
 * of the last clocked process in the file.
 */
int clkedges[MAXEDGES];
int clkptr = 0;
int delay=1;
int dolist=1;
int np=1;
char wire[]="wire";
char reg[]="reg";
int dowith=0;
slist *slwith;

/* Indentation variables */
int indent=0;
slist *indents[MAXINDENT];

struct vrange *new_vrange(enum vrangeType t)
{
  struct vrange *v=xmalloc(sizeof(vrange));
  v->vtype=t;
  v->nlo = NULL;
  v->nhi = NULL;
  v->size_expr = NULL;
  v->sizeval = 0;
  v->updown = 0;
  v->xlo = NULL;
  v->xhi = NULL;
  return v;
}

void qindent(int ind){
  int ix;
  for (ix=0; ix<ind; ix++) fputc(' ', stderr);
}

/* Visualize an slist structure as an aid to debugging and development.
 * Will never be used for actual Verilog generation. */
void sldump(int ind, slist *sl){
  if (sl){
    assert(sl != sl->slst);
    qindent(ind);
    fprintf(stderr, "slst:\n");
    sldump(ind + 4, sl->slst);
    qindent(ind);
    switch(sl->type){
    case tSLIST : case tOTHERS :
      assert(sl != sl->data.sl);
      fprintf(stderr, "tSLIST:\n");
      sldump(ind + 4,sl->data.sl);
      break;
    case tTXT :
      fprintf(stderr, "pTXT \"%s\"\n",sl->data.txt);
      break;
    case tVAL :
      fprintf(stderr, "tVAL %d\n",sl->data.val);
      break;
    case tPTXT :
      fprintf(stderr, "pPTXT \"%s\"\n",*(sl->data.ptxt));
      break;
    }
  }
}

/* I'd really rather not write the following astring support routines,
 * it seems like giving up compared to just using the slist structure.
 * But I couldn't find an effective way of comparing two slists without
 * this step.  Thus slist_check_diff() will convert two slists to strings
 * so they can be compared.
 * Keep it short and correct, (almost) forget about efficiency */
#define ASTRING_CHUNK 512
struct astring {
  char *s;
  size_t space, used;
};

void ainit(struct astring *a)
{
  a->used = 0;
  if (!a->s) {
    a->space = ASTRING_CHUNK;
    a->s = xmalloc(a->space);
  }
}

void astring_addc(struct astring *a, char c) {
  if (a->used+1 >= a->space) {
    a->space += ASTRING_CHUNK;
    a->s = xrealloc(a->s, a->space);
  }
  a->s[a->used++] = c;
}

void astring_adds(struct astring *a, char *s) {
  char c;
  while ((c=*s++)) astring_addc(a, c);
}

void sslprint(struct astring *a, slist *sl){
  char decimal[30];
  if(sl){
    assert(sl != sl->slst);
    sslprint(a, sl->slst);
    switch(sl->type){
    case tSLIST : case tOTHERS :
      assert(sl != sl->data.sl);
      sslprint(a, sl->data.sl);
      break;
    case tTXT :
      astring_adds(a, sl->data.txt);
      break;
    case tVAL :
      snprintf(decimal, sizeof(decimal), "%d", sl->data.val);
      astring_adds(a, decimal);
      break;
    case tPTXT :
      astring_adds(a, (sl->data.txt));
      break;
    }
  }
  a->s[a->used] = '\0';
  if (0) fprintf(stderr, "sslprint %lu/%lu \"%s\"\n", a->used, a->space, a->s);
}
/* end astring complaint zone */

void fslprint(FILE *fp,slist *sl){
  if(sl){
    assert(sl != sl->slst);
    fslprint(fp,sl->slst);
    switch(sl->type){
    case tSLIST : case tOTHERS :
      assert(sl != sl->data.sl);
      fslprint(fp,sl->data.sl);
      break;
    case tTXT :
      fprintf(fp,"%s",sl->data.txt);
      break;
    case tVAL :
      fprintf(fp,"%d",sl->data.val);
      break;
    case tPTXT :
      fprintf(fp,"%s",*(sl->data.ptxt));
      break;
    }
  }
}

void slprint(slist *sl){
  fslprint(stdout, sl);
}

slist *copysl(slist *sl){
  if(sl){
    slist *newsl;
    newsl = xmalloc(sizeof(slist));
    *newsl = *sl;
    if (sl->slst != NULL) {
      assert(sl != sl->slst);
      newsl->slst = copysl(sl->slst);
    }
    switch(sl->type){
    case tSLIST : case tOTHERS :
      if (sl->data.sl != NULL) {
        assert(sl != sl->data.sl);
        newsl->data.sl = copysl(sl->data.sl);
      }
      break;
    case tTXT :
      newsl->data.txt = xmalloc(strlen(sl->data.txt) + 1);
      strcpy(newsl->data.txt, sl->data.txt);
      break;
    default :
      /* We really ignore tPTXT here? */
      /* fprintf(stderr, "WARNING (line %d): unexpected slist type in copysl()\n", lineno); */
      break;
    }
    return newsl;
  }
  return NULL;
}

slist *addtxt(slist *sl, const char *s){
  slist *p;

  if(s == NULL)
    return sl;
  p = xmalloc(sizeof *p);
  p->type = tTXT;
  p->slst = sl;
  p->data.txt = xmalloc(strlen(s) + 1);
  strcpy(p->data.txt, s);

  return p;
}

slist *addothers(slist *sl, slist *sl2){
  slist *p;

  if(sl2 == NULL)
    return sl;
  p = xmalloc(sizeof *p);
  p->type = tOTHERS;
  p->slst = sl;
  p->data.sl = sl2;

  return p;
}

slist *addptxt(slist *sl, char **s){
  slist *p;

  if(s == NULL)
    return sl;

  p = xmalloc(sizeof *p);
  p->type = tPTXT;
  p->slst = sl;
  p->data.ptxt = s;

  return p;
}

slist *addval(slist *sl, int val){
  slist *p;

  p = xmalloc(sizeof(slist));
  p->type = tVAL;
  p->slst = sl;
  p->data.val = val;

  return p;
}

slist *addsl(slist *sl, slist *sl2){
  slist *p;
  if(sl2 == NULL) return sl;
  p = xmalloc(sizeof(slist));
  p->type = tSLIST;
  p->slst = sl;
  p->data.sl = sl2;
  return p;
}

slist *addvec(slist *sl, char *s){
  sl=addval(sl,strlen(s));
  sl=addtxt(sl,"'b");
  sl=addtxt(sl,s);
  return sl;
}

slist *addvec_base(slist *sl, char *b, char *s){
  const char *base_str="'b";
  int base_mult=1;
  if (strcasecmp(b,"B") == 0) {
     /* nothing to do */
  } else if (strcasecmp(b,"X") == 0) {
     base_str="'h"; base_mult=4;
  } else if (strcasecmp(b,"O") == 0) {
     base_str="'o"; base_mult=3;
  } else {
     fprintf(stderr,"WARNING (line %d): NAME STRING rule matched but NAME='%s' is not X or O.\n", lineno, b);
  }
  sl=addval(sl,strlen(s)*base_mult);
  sl=addtxt(sl,base_str);
  sl=addtxt(sl,s);
  return sl;
}

slist *addind(slist *sl){
  if(sl)
    sl=addsl(indents[indent],sl);
  return sl;
}

#define DEBUG_RANGE 0
slist *addpar_snug(slist *sl, vrange *v){
  if (DEBUG_RANGE) {
    fprintf(stderr,"addpar_snug %d: ", v->sizeval);
    fslprint(stderr, v->size_expr);
    fprintf(stderr,"\n");
  }
  if(v->nlo != NULL) {   /* indexes are simple expressions */
    sl=addtxt(sl,"[");
    if(v->nhi != NULL){
      sl=addsl(sl,v->nhi);
      if(v->updown) sl=addtxt(sl,v->updown==1 ? " +: " : " -: ");
      else sl=addtxt(sl,":");
    }
    if(v->updown){
      sl=addsl(sl,v->size_expr);
      sl=addtxt(sl," + 1");
    } else {
      sl=addsl(sl,v->nlo);
    }
    sl=addtxt(sl,"]");
  }
  return sl;
}

slist *addpar(slist *sl, vrange *v){
  sl=addtxt(sl," ");
  if(v->nlo != NULL) {   /* indexes are simple expressions */
    sl=addpar_snug(sl, v);
    sl=addtxt(sl," ");
  }
  return sl;
}

/* This function handles array of vectors in signal lists */
slist *addpar_snug2(slist *sl, vrange *v, vrange *v1){
  if(v->nlo != NULL) {   /* indexes are simple expressions */
    sl=addtxt(sl,"[");
    if(v->nhi != NULL){
      sl=addsl(sl,v->nhi);
      sl=addtxt(sl,":");
    }
    sl=addsl(sl,v->nlo);
    sl=addtxt(sl,"]");
  }
  if(v1->nlo != NULL) {   /* indexes are simple expressions */
    sl=addtxt(sl,"[");
    if(v1->nhi != NULL){
      sl=addsl(sl,v1->nhi);
      sl=addtxt(sl,":");
    }
    sl=addsl(sl,v1->nlo);
    sl=addtxt(sl,"]");
  }
  return sl;
}

slist *addpost(slist *sl, vrange *v){
  if(v->xlo != NULL) {
    sl=addtxt(sl,"[");
    if(v->xhi != NULL){
      sl=addsl(sl,v->xhi);
      sl=addtxt(sl,":");
    }
    sl=addsl(sl,v->xlo);
    sl=addtxt(sl,"]");
  }
  return sl;
}

slist *addwrap(const char *l,slist *sl,const char *r){
slist *s;
  s=addtxt(NULL,l);
  s=addsl(s,sl);
  return addtxt(s,r);
}

expdata *addnest(struct expdata *inner)
{
  expdata *e;
  e=xmalloc(sizeof(expdata));
  if (inner->op == 'c') {
    e->sl=addwrap("{",inner->sl,"}");
  } else {
    e->sl=addsl(NULL,inner->sl);
  }
  e->op='e';
  return e;
}

slist *addrem(slist *sl, slist *rem)
{
  if (rem) {
    sl=addtxt(sl, "  ");
    sl=addsl(sl, rem);
  } else {
    sl=addtxt(sl, "\n");
  }
  return sl;
}

sglist *lookup(sglist *sg,char *s){
  for(;;){
    if(sg == NULL || strcmp(sg->name,s)==0)
      return sg;
    sg=sg->next;
  }
}

char *sbottom(slist *sl){
  while(sl->slst != NULL)
    sl=sl->slst;
  return sl->data.txt;
}

slist *new_signal(const char *s){
  slist *sl;
  /* somewhat boring now, but will get more interesting later */
  sl=addtxt(NULL,s);
  return sl;
}

/* kind of like strdup, but with specified len */
char *strgrab(char*s, size_t len)
{
  char *r = xmalloc(len+1);
  if (r) {
    memcpy(r, s, len);
    r[len] = 0;
  }
  return r;
}

/* s1 is the longer string, s2 is the shorter string */
char *string_check_diff(char *s1, char *s2)
{
  size_t llen = strlen(s1);
  size_t slen = strlen(s2);
  char *rv=0;
  if (memcmp(s1, s2, slen)==0) {
    if (DEBUG_RANGE) fprintf(stderr, "first %lu chars match\n", slen);
    if (llen>slen+3 && memcmp(s1+slen," + ",3)==0) {
      if (DEBUG_RANGE) fprintf(stderr, "followed by valid \" + \"\n");
      rv=strgrab(s1+slen+3,llen-slen-3);
    }
  } else if (memcmp(s1+llen-slen, s2, slen)==0) {
    if (DEBUG_RANGE) fprintf(stderr, "last %lu chars match\n", slen);
    if (llen>slen+3 && memcmp(s1+llen-slen-3," + ",3)==0) {
      if (DEBUG_RANGE) fprintf(stderr, "preceded by valid \" + \"\n");
      rv=strgrab(s1,llen-slen-3);
    }
  }
  return rv;
}

/* Look for common beginning or end of a string,
 * as needed for creating indexed part selects.
 * updown key:  DOWNTO = -1, TO = 1 */
char *slist_check_diff(slist *shi, slist *slo, int updown)
{
  char *diff = 0;
  size_t t1len, t2len;
  static struct astring a1={0,0,0}, a2={0,0,0};
  ainit(&a1);  sslprint(&a1, shi);  t1len = a1.used;
  ainit(&a2);  sslprint(&a2, slo);  t2len = a2.used;
  if (updown == -1 && t2len < t1len) {
    diff = string_check_diff(a1.s, a2.s);
  } else if (updown == 1 && t1len < t2len) {
    diff = string_check_diff(a2.s, a1.s);
  } /* I don't have sane test cases for the other possibilities */
  return diff;
}

const char *inout_string(int type)
{
  const char *name=NULL;
  switch(type) {
    case 0: name="input"  ; break;
    case 1: name="output" ; break;
    case 2: name="inout"  ; break;
    default: break;
  }
  return name;
}

int prec(int op){
  switch(op){
  case 'o': /* others */
    return 9;
    break;
  case 't':case 'n':
    return 8;
    break;
  case '~':
    return 7;
    break;
  case 'p': case 'm':
    return 6;
    break;
  case '*': case '/': case '%':
    return 5;
    break;
  case '+': case '-':
    return 4;
    break;
  case '&':
    return 3;
    break;
  case '^':
    return 2;
    break;
  case '|':
    return 1;
    break;
   default:
    return 0;
    break;
  }
}

expdata *addexpr(expdata *expr1,int op,const char* opstr,expdata *expr2){
slist *sl1,*sl2;
  if(expr1 == NULL)
    sl1=NULL;
  else if(expr1->op == 'c')
    sl1=addwrap("{",expr1->sl,"}");
  else if(prec(expr1->op) < prec(op))
    sl1=addwrap("(",expr1->sl,")");
  else
    sl1=expr1->sl;

  if(expr2->op == 'c')
    sl2=addwrap("{",expr2->sl,"}");
  else if(prec(expr2->op) < prec(op))
    sl2=addwrap("(",expr2->sl,")");
  else
    sl2=expr2->sl;

  if(expr1 == NULL)
    expr1=expr2;
  else
    free(expr2);

  expr1->op=op;
  sl1=addtxt(sl1,opstr);
  sl1=addsl(sl1,sl2);
  expr1->sl=sl1;
  return expr1;
}

void slTxtReplace(slist *sl, const char *match, const char *replace){
  if(sl){
    slTxtReplace(sl->slst, match, replace);
    switch(sl->type) {
    case tSLIST :
      slTxtReplace(sl->data.sl, match, replace);
      break;
    case tTXT :
      if (strcmp(sl->data.txt, match) == 0) {
        sl->data.txt = strdup(replace);
      }
      break;
    case tPTXT :
      if (strcmp(*(sl->data.ptxt), match) == 0) {
        *(sl->data.ptxt) = strdup(replace);
      }
      break;
    default :
      fprintf(stderr, "WARNING (line %d): unexpected slist type in slTxtReplace()\n", lineno);
    }
  }
}


/* XXX todo: runtime engage clkedge debug */
void push_clkedge(int val, const char *comment)
{
  if (0) fprintf(stderr,"clock event push: line=%d clkptr=%d, value=%d (%s)\n",lineno,clkptr,val,comment);
  clkedges[clkptr++]=val;
  assert(clkptr < MAXEDGES);
}

int pull_clkedge(slist *sensitivities)
{
  int clkedge;
  assert(clkptr>0);
  clkedge = clkedges[--clkptr];
  if (0) {
     fprintf(stderr,"clock event pull: value=%d, sensitivity list = ", clkedge);
     fslprint(stderr,sensitivities);
     fprintf(stderr,"\n");
  }
  return clkedge;
}

/* XXX maybe it's a bug that some uses don't munge clocks? */
slist *add_always(slist *sl, slist *sensitivities, slist *decls, int munge)
{
           int clkedge;
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"always @(");
           if (munge) {
             clkedge = pull_clkedge(sensitivities);
             if(clkedge) {
               sl=addtxt(sl,"posedge ");
               /* traverse $4->sl replacing " or " with " or posedge " if there is a clockedge */
               if (vlog_ver == 2001) slTxtReplace(sensitivities,", ", ", posedge ");
               if (vlog_ver == 1995) slTxtReplace(sensitivities," or ", " or posedge ");
             } else {
               sl=addtxt(sl,"negedge ");
               if (vlog_ver == 2001) slTxtReplace(sensitivities,", ", ", negedge ");
               if (vlog_ver == 1995) slTxtReplace(sensitivities," or ", " or negedge ");
             }
           }
           sl=addsl(sl,sensitivities);
           sl=addtxt(sl,") begin");
           if(decls){
             sl=addtxt(sl," : P");
             sl=addval(sl,np++);
             sl=addtxt(sl,"\n");
             sl=addsl(sl,decls);
           }
           sl=addtxt(sl,"\n");
           return sl;
}

void fixothers(slist *size_expr, slist *sl) {
  if(sl) {
    fixothers(size_expr, sl->slst);
    switch(sl->type) {
    case tSLIST :
      fixothers(size_expr,sl->data.sl);
      break;
    case tOTHERS : {
      /* found an (OTHERS => 'x') clause - change to type tSLIST, and insert the
       * size_expr for the corresponding signal */
      slist *p;
      slist *size_copy = xmalloc(sizeof(slist));
      size_copy = copysl(size_expr);
      if (0) {
        fprintf(stderr,"fixothers type 4 size_expr ");
        fslprint(stderr,size_expr);
        fprintf(stderr,"\n");
      }
      p = addwrap("{",sl->data.sl,"}");
      p = addsl(size_copy, p);
      p = addwrap("{",p,"}");
      sl->type=tSLIST;
      sl->slst=p;
      sl->data.sl=NULL;
      break;
    } /* case tOTHERS */
    default :
      /* fprintf(stderr, "WARNING (line %d): unexpected slist type in fixothers()\n", lineno); */
      break; /* no action */
    } /* switch */
  }
}

void findothers(slval *sgin,slist *sl){
  sglist *sg = NULL;
  int size = -1;
  int useExpr=0;
  if (0) {
    fprintf(stderr,"findothers lhs ");
    fslprint(stderr,sgin->sl);
    fprintf(stderr,", sgin->val %d\n", sgin->val);
  }
  if(sgin->val>0) {
    size=sgin->val;
  } else if (sgin->range != NULL) {
    if (sgin->range->vtype != tVRANGE) {
      size=1;
    } else if (sgin->range->sizeval > 0) {
      size=sgin->range->sizeval;
    } else if (sgin->range->size_expr != NULL) {
      useExpr = 1;
      fixothers(sgin->range->size_expr, sl);
    }
  } else {
    if((sg=lookup(io_list,sgin->sl->data.txt))==NULL) {
      sg=lookup(sig_list,sgin->sl->data.txt);
    }
    if(sg) {
      if(sg->range->vtype != tVRANGE) {
        size=1;
      } else {
        if (sg->range->sizeval > 0) {
          size = sg->range->sizeval;
        } else {
          assert (sg->range->size_expr != NULL);
          useExpr = 1;
          fixothers(sg->range->size_expr, sl);
        }
      }
    } else {
      /* lookup failed, there was no vrange or size value in sgin - so just punt, and assign size=1 */
      size=1;
    }  /* if(sg) */
  }
  if (!useExpr) {
    slist *p;
    assert(size>0);
    /* use size */
    p = addval(NULL,size);
    fixothers(p,sl);
  }
}

/* code to find bit number of the msb of n */
int find_msb(int n)
{
    int k=0;
    if(n&0xff00){
        k|=8;
        n&=0xff00;
    }
    if(n&0xf0f0){
        k|=4;
        n&=0xf0f0;
    }
    if(n&0xcccc){
        k|=2;
        n&=0xcccc;
    }
    if(n&0xaaaa){
        k|=1;
        n&=0xaaaa;
    }
    return k;
}

static char time_unit[2]="\0\0", new_unit[2]="\0\0";
static void set_timescale(const char *s)
{
    if (0) fprintf(stderr,"set_timescale (%s)\n", s);
    new_unit[0] = time_unit[0];
         if (strcasecmp(s,"ms") == 0) { new_unit[0] = 'm'; }
    else if (strcasecmp(s,"us") == 0) { new_unit[0] = 'u'; }
    else if (strcasecmp(s,"ns") == 0) { new_unit[0] = 'n'; }
    else if (strcasecmp(s,"ps") == 0) { new_unit[0] = 'p'; }
    else {
        fprintf(stderr,"WARNING (line %d): AFTER NATURAL NAME pattern matched, but NAME='%s' should be a time unit.\n", lineno, s);
    }
    if (new_unit[0] != time_unit[0]) {
        if (time_unit[0] != 0) {
            fprintf(stderr,"WARNING (line %d): inconsistent time unit (%s) ignored.\n", lineno, s);
        } else {
            time_unit[0] = new_unit[0];
        }
    }
}

slist *output_timescale(slist *sl)
{
    if (time_unit[0] != 0) {
        sl = addtxt(sl, "`timescale 1 ");
        sl = addtxt(sl, time_unit);
        sl = addtxt(sl, "s / 1 ");
        sl = addtxt(sl, time_unit);
        sl = addtxt(sl, "s\n");
    } else {
        sl = addtxt(sl, "// no timescale needed\n");
    }
    return sl;
}

slist *setup_port(sglist *s_list, int dir, vrange *type) {
  slist *sl;
  sglist *p;
  if (vlog_ver == 2001) {
    sl=addtxt(NULL,NULL);
  }
  else {
    sl=addtxt(NULL,inout_string(dir));
    sl=addpar(sl,type);
  }
  p=s_list;
  for(;;){
    p->type=wire;
    if (vlog_ver == 2001) p->dir=inout_string(dir);
    p->range=type;
    if (vlog_ver == 1995) sl=addtxt(sl, p->name);
    if(p->next==NULL)
      break;
    p=p->next;
    if (vlog_ver == 1995) sl=addtxt(sl,", ");
  }
  if (vlog_ver == 1995) sl=addtxt(sl,";\n");
  p->next=io_list;
  io_list=s_list;
  return sl;
}

slist *emit_io_list(slist *sl)
{
              sglist *p;
              sl=addtxt(sl,"(\n");
              p=io_list;
              for(;;){
                if (vlog_ver == 2001) {
                  sl=addtxt(sl,p->dir);
                  sl=addtxt(sl," ");
                  sl=addptxt(sl,&(p->type));
                  sl=addpar(sl,p->range);
                }
                sl=addtxt(sl,p->name);
                p=p->next;
                if(p)
                  sl=addtxt(sl,",\n");
                else{
                  sl=addtxt(sl,"\n");
                  break;
                }
              }
              sl=addtxt(sl,");\n\n");
              return sl;
}
%}

%union {
  char * txt; /* String */
  int n;      /* Value */
  vrange *v;  /* Signal range */
  sglist *sg; /* Signal list */
  slist *sl;  /* String list */
  expdata *e; /* Expression structure */
  slval *ss;  /* Signal structure */
}

%token <txt> ABS REM ENTITY IS PORT GENERIC IN OUT INOUT MAP
%token <txt> INTEGER BIT BITVECT DOWNTO TO TYPE END
%token <txt> ARCHITECTURE COMPONENT OF ARRAY
%token <txt> SIGNAL BEGN NOT WHEN WITH EXIT
%token <txt> SELECT OTHERS PROCESS VARIABLE CONSTANT
%token <txt> IF THEN ELSIF ELSE CASE WHILE
%token <txt> FOR LOOP GENERATE
%token <txt> AFTER AND OR NAND NOR XOR XNOR MOD RW_REM POW
%token <txt> LASTVALUE EVENT POSEDGE NEGEDGE
%token <txt> STRING NAME RANGE NULLV OPEN
%token <txt> CONVFUNC_1 CONVFUNC_2 BASED FLOAT LEFT
%token <txt> SCIENTIFIC REAL
%token <txt> ASSERT REPORT SEVERITY WARNING ERROR FAILURE NOTE
%token <txt> ROL ROR SLA SLL SRA SRL
%token ROTATE_LEFT ROTATE_RIGHT SHIFT_LEFT SHIFT_RIGHT
%token <n> NATURAL

%type <n> trad
%type <sl> rem  remlist entity
%type <sl> portlist genlist architecture
%type <sl> a_decl a_body p_decl oname
%type <sl> map_list map_item mvalue sigvalue
%type <sl> generic_map_list generic_map_item
%type <sl> conf exprc sign_list p_body optname gen_optname
%type <sl> edge
%type <sl> elsepart wlist wvalue cases
%type <sl> with_item with_list
%type <sl> vhdassert
%type <sg> s_list
%type <n> dir delay
%type <v> type vec_range
%type <n> updown
%type <e> expr
%type <e> simple_expr
%type <ss> signal
%type <txt> opt_is opt_generic opt_entity opt_architecture opt_begin
%type <txt> generate endgenerate
%type <txt> sevlevel

%right '='
/* Logic operators: */
%left ORL NORL
%left ANDL NANDL
/* Shift/rotate operators */
%left ROL ROR SLA SLL SRA SRL
/* Binary operators: */
%left OR NOR
%left XOR
%left XNOR
%left AND NAND
%left MOD RW_REM
/* Comparison: */
%left '<'  '>'  BIGEQ  LESSEQ  NOTEQ  EQUAL
%left  '+'  '-'  '&'
%left  '*'  '/'
%left  POW
%right UMINUS  UPLUS  NOTL  NOT  ABS
%define parse.error verbose

/* rule for "...ELSE IF edge THEN..." causes 1 shift/reduce conflict */
/* rule for opt_begin causes 1 shift/reduce conflict */
%expect 2

/* glr-parser is needed because processes can start with if statements, but
 * not have edges in them - more than one level of look-ahead is needed in that case
 * %glr-parser
 * unfortunately using glr-parser causes slists to become self-referential, causing core dumps!
 */
%%

/* Input file must contain entity declaration followed by architecture */
trad  : rem entity rem architecture rem {
        slist *sl;
          sl=output_timescale($1);
          sl=addsl(sl,$2);
          sl=addsl(sl,$3);
          sl=addsl(sl,$4);
          sl=addsl(sl,$5);
          sl=addtxt(sl,"\nendmodule\n");
          slprint(sl);
          $$=0;
        }
/* some people put entity declarations and architectures in separate files -
 * translate each piece - note that this will not make a legal Verilog file
 * - let them take care of that manually
 */
      | rem entity rem  {
        slist *sl;
          sl=addsl($1,$2);
          sl=addsl(sl,$3);
          sl=addtxt(sl,"\nendmodule\n");
          slprint(sl);
          $$=0;
        }
      | rem architecture rem {
        slist *sl;
          sl=addsl($1,$2);
          sl=addsl(sl,$3);
          sl=addtxt(sl,"\nendmodule\n");
          slprint(sl);
          $$=0;
        }
      ;

/* Comments */
rem      : /* Empty */ {$$=NULL; }
         | remlist {$$=$1; }
         ;

remlist  : REM {$$=addtxt(indents[indent],$1);}
         | REM remlist {
           slist *sl;
           sl=addtxt(indents[indent],$1);
           $$=addsl(sl,$2);}
         ;

opt_is   : /* Empty */ {$$=NULL;} | IS ;

opt_entity   : /* Empty */ {$$=NULL;} | ENTITY ;

opt_architecture   : /* Empty */ {$$=NULL;} | ARCHITECTURE ;

opt_begin    : /* Empty */ {$$=NULL;} | BEGN;

generate       : GENERATE opt_begin;

endgenerate    : END GENERATE;

/* tell the lexer to discard or keep comments ('-- ') - this makes the grammar much easier */
norem : /*Empty*/ {skipRem = 1;}
yesrem : /*Empty*/ {skipRem = 0;}

/* Beginning support for assertions. Currently parsed but not translated. */
vhdassert : ASSERT exprc REPORT STRING SEVERITY sevlevel ';' {
              fprintf(stderr,"WARNING (line %d): assertion ignored.\n",lineno);
              $$=NULL;
            }

sevlevel  : WARNING | ERROR | FAILURE | NOTE {
               $$=NULL;
            }

/* Entity */
/*          1      2    3  4     5  6   7         8   9  10  11  12    13 */
entity    : ENTITY NAME IS rem PORT '(' rem portlist ')' ';' rem END opt_entity oname ';' {
            slist *sl;
            sglist *p;
              sl=addtxt(NULL,"\nmodule ");
              sl=addtxt(sl,$2); /* NAME */
              /* Add the signal list */
              sl=emit_io_list(sl);
              sl=addsl(sl,$7); /* rem */
              sl=addsl(sl,$8); /* portlist */
              sl=addtxt(sl,"\n");
              p=io_list;
              if (vlog_ver == 1995) {
                do{
                sl=addptxt(sl,&(p->type));
                /*sl=addtxt(sl,p->type);*/
                sl=addpar(sl,p->range);
                sl=addtxt(sl,p->name);
                /* sl=addpost(sl,p->range); */
                sl=addtxt(sl,";\n");
                p=p->next;
                } while(p!=NULL);
              }
              sl=addtxt(sl,"\n");
              sl=addsl(sl,$11); /* rem2 */
              $$=addtxt(sl,"\n");
            }
 /*         1      2    3  4       5        6   7  8         9  10  11   12      13  14  15       16   17 18  19  20  21    22 */
          | ENTITY NAME IS GENERIC yeslist '(' rem genlist  ')' ';' rem PORT yeslist '(' rem portlist ')' ';' rem END opt_entity oname ';' {
            slist *sl;
            sglist *p;
              if (0) fprintf(stderr,"matched ENTITY GENERIC\n");
              sl=addtxt(NULL,"\nmodule ");
              sl=addtxt(sl,$2); /* NAME */
              sl=emit_io_list(sl);
              sl=addsl(sl,$7);  /* rem */
              sl=addsl(sl,$8);  /* genlist */
              sl=addsl(sl,$11); /* rem */
              sl=addsl(sl,$15); /* rem */
              sl=addsl(sl,$16); /* portlist */
              sl=addtxt(sl,"\n");
              p=io_list;
              if (vlog_ver == 1995) {
                do{
                sl=addptxt(sl,&(p->type));
                /*sl=addtxt(sl,p->type);*/
                sl=addpar(sl,p->range);
                sl=addtxt(sl,p->name);
                sl=addtxt(sl,";\n");
                p=p->next;
                } while(p!=NULL);
              }
              sl=addtxt(sl,"\n");
              sl=addsl(sl,$19); /* rem2 */
              $$=addtxt(sl,"\n");
            }
          ;

          /* 1     2  3     4   5  6    7 */
genlist  : s_list ':' type ':' '=' expr rem {
          if(dolist){
            slist *sl;
            sglist *p;
            sl=addtxt(NULL,"parameter");
            sl=addpar(sl,$3); /* type */
            p=$1;
            for(;;){
              sl=addtxt(sl,p->name);
              sl=addtxt(sl,"=");
              sl=addsl(sl, addnest($6)->sl); /* expr */
              sl=addtxt(sl,";\n");
              p=p->next;
              if(p==NULL) break;
            }
            $$=addsl(sl,$7); /* rem */
          } else {
            $$=NULL;
          }
         }
          /* 1     2  3     4   5  6     7  8    9 */
         | s_list ':' type ':' '=' expr ';' rem genlist {
          if(dolist){
            slist *sl;
            sglist *p;
            sl=addtxt(NULL,"parameter");
            sl=addpar(sl,$3); /* type */
            p=$1;
            for(;;){
              sl=addtxt(sl,p->name);
              sl=addtxt(sl,"=");
              sl=addsl(sl, addnest($6)->sl); /* expr */
              sl=addtxt(sl,";\n");
              p=p->next;
              if(p==NULL) break;
            }
            $$=addsl(sl,$8); /* rem */
            $$=addsl(sl,$9); /* genlist */
          } else {
            $$=NULL;
          }
         }
          /* 1     2  3     4   5  6 */
         | s_list ':' type ';' rem genlist {
          if(dolist){
            slist *sl;
            sglist *p;
            sl=addtxt(NULL,"parameter");
            sl=addpar(sl,$3); /* type */
            p=$1;
            for(;;){
              sl=addtxt(sl,p->name);
              sl=addtxt(sl,";\n");
              p=p->next;
              if(p==NULL) break;
            }
            $$=addsl(sl,$5); /* rem */
            $$=addsl(sl,$6); /* genlist */
          } else {
            $$=NULL;
          }
         }
          /* 1     2  3    4   */
         | s_list ':' type rem  {
          if(dolist){
            slist *sl;
            sglist *p;
            sl=addtxt(NULL,"parameter");
            sl=addpar(sl,$3); /* type */
            p=$1;
            for(;;){
              sl=addtxt(sl,p->name);
              sl=addtxt(sl,";\n");
              p=p->next;
              if(p==NULL) break;
            }
            $$=addsl(sl,$4); /* rem */
          } else {
            $$=NULL;
          }
         }
        ;

          /* 1      2   3   4    5 */
portlist  : s_list ':' dir type rem {
            slist *sl;

              if(dolist){
                io_list=NULL;
                sl=setup_port($1,$3,$4);  /* modifies io_list global */
                $$=addsl(sl,$5);
              } else{
                free($5);
                free($4);
              }
            }
          /* 1      2   3   4    5   6   7     */
          | s_list ':' dir type ';' rem portlist {
            slist *sl;

              if(dolist){
                sl=setup_port($1,$3,$4);  /* modifies io_list global */
                sl=addsl(sl,$6);
                $$=addsl(sl,$7);
              } else{
                free($6);
                free($4);
              }
            }
          /* 1      2   3   4    5   6   7    8 */
          | s_list ':' dir type ':' '=' expr rem {
            slist *sl;
              fprintf(stderr,"WARNING (line %d): port default initialization ignored.\n",lineno);
              if(dolist){
                io_list=NULL;
                sl=setup_port($1,$3,$4);  /* modifies io_list global */
                $$=addsl(sl,$8);
              } else{
                free($8);
                free($4);
              }
            }
          /* 1      2   3   4    5   6   7    8   9   10     */
          | s_list ':' dir type ':' '=' expr ';' rem portlist {
            slist *sl;
              fprintf(stderr,"WARNING (line %d): port default initialization ignored.\n",lineno);
              if(dolist){
                sl=setup_port($1,$3,$4);  /* modifies io_list global */
                sl=addsl(sl,$9);
                $$=addsl(sl,$10);
              } else{
                free($9);
                free($4);
              }
            }
          ;

dir         : IN { $$=0;}
            | OUT { $$=1; }
            | INOUT { $$=2; }
            ;

type        : BIT {
                $$=new_vrange(tSCALAR);
              }
            | INTEGER RANGE expr TO expr {
                fprintf(stderr,"WARNING (line %d): integer range ignored.\n",lineno);
                $$=new_vrange(tSCALAR);
                $$->nlo = addtxt(NULL,"0");
                $$->nhi = addtxt(NULL,"31");
              }
            | INTEGER {
                $$=new_vrange(tSCALAR);
                $$->nlo = addtxt(NULL,"0");
                $$->nhi = addtxt(NULL,"31");
              }
            | REAL {
                $$=new_vrange(tSCALAR);
              }
            | BITVECT '(' vec_range ')' {$$=$3;}
            | NAME {
              sglist *sg;

                sg=lookup(type_list,$1);
                if(sg)
                  $$=sg->range;
                else{
                  fprintf(stderr,"ERROR (line %d): undefined type '%s'.\n", lineno, $1);
                  YYABORT;
                }
              }
            ;

/* using expr instead of simple_expr here makes the grammar ambiguous (why?) */
vec_range : simple_expr updown simple_expr {
              char *range_diff = 0;
              $$=new_vrange(tVRANGE);
              $$->nhi=$1->sl;
              $$->nlo=$3->sl;
              $$->sizeval = -1; /* undefined size */
              $$->updown = 0; /* not relevant */
              /* slist_check_diff() is where we analyze the two expressions
               * to see if they have a simple (possibly constant) difference.
               * Start with an option to visualize their data structures.
               */
              if (DEBUG_RANGE) {
                fprintf(stderr, "debug width hi: ");
                fslprint(stderr, $$->nhi);
                fprintf(stderr, "\n");
                if (0) sldump(4, $$->nhi);
                fprintf(stderr, "debug width lo: ");
                fslprint(stderr, $$->nlo);
                fprintf(stderr, "\n");
                if (0) sldump(4, $$->nlo);
              }
              /* calculate the width of this vrange */
              if ($1->op == 'n' && $3->op == 'n') {
                if ($2==-1) { /* (nhi:natural downto nlo:natural) */
                  $$->sizeval = $1->value - $3->value + 1;
                } else {      /* (nhi:natural to     nlo:natural) */
                  $$->sizeval = $3->value - $1->value + 1;
                }
              } else if ((range_diff = slist_check_diff($$->nhi, $$->nlo, $2))) {
                if (DEBUG_RANGE) fprintf(stderr, "difference: %s\n", range_diff);
                $$->updown = $2;  /* triggers use of range_diff in addpar_snug */
                $$->size_expr = addtxt(NULL, range_diff);
              } else {
                /* make an expression to calculate the width of this vrange:
                 * create an expression that calculates:
                 *   size expr = (simple_expr1) - (simple_expr2) + 1
                 */
                expdata *size_expr1  = xmalloc(sizeof(expdata));
                expdata *size_expr2  = xmalloc(sizeof(expdata));
                expdata *diff12  = xmalloc(sizeof(expdata));
                expdata *plusone = xmalloc(sizeof(expdata));
                expdata *finalexpr = xmalloc(sizeof(expdata));
                size_expr1->sl = addwrap("(",$1->sl,")");
                size_expr1->op = 't';
                size_expr2->sl = addwrap("(",$3->sl,")");
                size_expr2->op = 't';
                plusone->op='t';
                plusone->sl=addtxt(NULL,"1");
                if ($2==-1) {
                  /* (simple_expr1 downto simple_expr1) */
                  diff12 = addexpr(size_expr1,'-',"-",size_expr2);
                } else {
                  /* (simple_expr1   to   simple_expr1) */
                  diff12 = addexpr(size_expr2,'-',"-",size_expr1);
                }
                finalexpr = addexpr(diff12,'+',"+",plusone);
                finalexpr->sl = addwrap("(",finalexpr->sl,")");
                $$->size_expr = finalexpr->sl;
              }
              if (DEBUG_RANGE) fprintf(stderr, "\n");
            }
          | simple_expr {
              $$=new_vrange(tSUBSCRIPT);
              $$->nlo=$1->sl;
          }
          | NAME '\'' RANGE {
              /* lookup NAME and copy its vrange */
              sglist *sg = NULL;
              if((sg=lookup(io_list,$1))==NULL) {
                sg=lookup(sig_list,$1);
              }
              if(sg) {
                $$ = sg->range;
              } else {
                fprintf(stderr,"ERROR (line %d): undefined range \"%s'range\".\n", lineno, $1);
                YYABORT;
              }
          }
          ;

updown : DOWNTO {$$=-1;}
       | TO {$$=1;}
       ;

/* Architecture */
architecture : ARCHITECTURE NAME OF NAME IS rem a_decl
               BEGN doindent a_body END opt_architecture oname ';' unindent {
               slist *sl;
                 sl=addsl($6,$7);
                 sl=addtxt(sl,"\n");
                 $$=addsl(sl,$10);
               }
             ;

/* Extends indentation by one level */
doindent : /* Empty */ {indent= indent < MAXINDENT ? indent + 1 : indent;}
         ;
/* Shorten indentation by one level */
unindent : /* Empty */ {indent= indent > 0 ? indent - 1 : indent;}

/* Declarative part of the architecture */
a_decl    : {$$=NULL;}
          | a_decl SIGNAL s_list ':' type ';' rem {
            sglist *sg;
            slist *sl;

              sl=$1;
              sg=$3;
              for(;;){
                sg->type=wire;
                sg->range=$5;
                sl=addptxt(sl,&(sg->type));
                sl=addpar(sl,$5);
                sl=addtxt(sl,sg->name);
                sl=addpost(sl,$5);
                sl=addtxt(sl,";");
                if(sg->next == NULL)
                  break;
                sl=addtxt(sl," ");
                sg=sg->next;
              }
              sg->next=sig_list;
              sig_list=$3;
              $$=addrem(sl,$7);
            }
          | a_decl SIGNAL s_list ':' type ':' '=' expr ';' rem {
            sglist *sg;
            slist *sl;

              sl=$1;
              sg=$3;
              for(;;){
                sg->type=wire;
                sg->range=$5;
                sl=addptxt(sl,&(sg->type));
                sl=addpar(sl,$5);
                sl=addtxt(sl,sg->name);
                sl=addpost(sl,$5);
                sl=addtxt(sl," = ");
                sl=addsl(sl,$8->sl);
                sl=addtxt(sl,";");
                if(sg->next == NULL)
                  break;
                sl=addtxt(sl," ");
                sg=sg->next;
              }
              sg->next=sig_list;
              sig_list=$3;
              $$=addrem(sl,$10);
            }
          | a_decl CONSTANT NAME ':' type ':' '=' expr ';' rem {
            slist * sl;
              sl=addtxt($1,"parameter ");
              sl=addtxt(sl,$3);
              sl=addtxt(sl," = ");
              sl=addsl(sl,$8->sl);
              sl=addtxt(sl,";");
              $$=addrem(sl,$10);
            }
          | a_decl TYPE NAME IS '(' s_list ')' ';' rem {
            slist *sl, *sl2;
            sglist *p;
            int n,k;
              n=0;
              sl=NULL;
              p=$6;
              for(;;){
                sl=addtxt(sl,"  ");
                sl=addtxt(sl,p->name);
                sl=addtxt(sl," = ");
                sl=addval(sl,n++);
                p=p->next;
                if(p==NULL){
                  sl=addtxt(sl,";\n");
                  break;
                } else
                  sl=addtxt(sl,",\n");
              }
              n--;
              k=find_msb(n);
              sl2=addtxt(NULL,"parameter [");
              sl2=addval(sl2,k);
              sl2=addtxt(sl2,":0]\n");
              sl=addsl(sl2,sl);
              sl=addsl($1,sl);
              $$=addrem(sl,$9);
              p=xmalloc(sizeof(sglist));
              p->name=$3;
              if(k>0) {
                p->range=new_vrange(tVRANGE);
                p->range->sizeval = k+1;
                p->range->nhi=addval(NULL,k);
                p->range->nlo=addtxt(NULL,"0");
              } else {
                p->range=new_vrange(tSCALAR);
              }
              p->next=type_list;
              type_list=p;
            }
          | a_decl TYPE NAME IS ARRAY '(' vec_range ')' OF type ';' rem {
            slist *sl=$1;
            sglist *p;
              $$=addrem(sl,$12);
              p=xmalloc(sizeof(sglist));
              p->name=$3;
              p->range=$10;
              p->range->xhi=$7->nhi;
              p->range->xlo=$7->nlo;
              p->next=type_list;
              type_list=p;
            }
          /* 1     2         3    4      5r1  6           7    8      9   10r2 11      12  13  14r3 15 16        17    18  19      20r4 */
          | a_decl COMPONENT NAME opt_is rem  opt_generic PORT nolist '(' rem portlist ')' ';' rem END COMPONENT oname ';' yeslist rem {
              $$=addsl($1,$20); /* a_decl, rem4 */
              free($3); /* NAME */
              free($10); /* rem2 */
              free($14); /* rem3 */
            }
          ;

opt_generic : /* Empty */ {$$=NULL;}
          | GENERIC nolist '(' rem genlist ')' ';' rem {
             if (0) fprintf(stderr,"matched opt_generic\n");
             free($4);  /* rem */
             free($8);  /* rem */
             $$=NULL;
            }
          ;

nolist : /*Empty*/ {dolist = 0;}
yeslist : /*Empty*/ {dolist = 1;}

/* XXX wishlist: record comments into slist, play them back later */
s_list : NAME rem {
         sglist * sg;
           if(dolist){
             sg=xmalloc(sizeof(sglist));
             sg->name=$1;
             sg->next=NULL;
             $$=sg;
           } else{
             free($1);
             $$=NULL;
           }
           free($2);
         }
       | NAME ',' rem s_list {
         sglist * sg;
           if(dolist){
             sg=xmalloc(sizeof(sglist));
             sg->name=$1;
             sg->next=$4;
             $$=sg;
           } else{
             free($1);
             $$=NULL;
           }
           free($3);
         }
       ;

a_body : rem {$$=addind($1);}
       /* 1   2     3    4  5   6     7         8     9 */
       | rem signal '<' '=' rem norem sigvalue yesrem a_body {
         slist *sl;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"assign ");
           sl=addsl(sl,$2->sl);
           findothers($2,$7);
           free($2);
           sl=addtxt(sl," = ");
           sl=addsl(sl,$7);
           sl=addtxt(sl,";\n");
           $$=addsl(sl,$9);
         }
       /* 1  2    3      4   5   6   7     8        9      10     11  12   13 */
       | rem BEGN signal '<' '=' rem norem sigvalue yesrem a_body END NAME ';' {
         slist *sl;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"assign ");
           sl=addsl(sl,$3->sl);
           findothers($3,$8);
           free($3);
           sl=addtxt(sl," = ");
           sl=addsl(sl,$8);
           sl=addtxt(sl,";\n");
           $$=addsl(sl,$10);
         }
       /* 1   2     3    4    5   6       7       8   9     10     11 */
       | rem WITH expr SELECT rem yeswith signal '<' '=' with_list a_body {
         slist *sl;
         sglist *sg;
         char *s;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"always @(*) begin\n");
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"  case(");
           sl=addsl(sl,$3->sl);
           free($3);
           sl=addtxt(sl,")\n");
           if($5)
             sl=addsl(sl,$5);
           s=sbottom($7->sl);
           if((sg=lookup(io_list,s))==NULL)
             sg=lookup(sig_list,s);
           if(sg)
             sg->type=reg;
           findothers($7,$10);
           free($7);
           sl=addsl(sl,$10);
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"  endcase\n");
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"end\n\n");
           $$=addsl(sl,$11);
         }
       /* 1   2   3     4  5   6    7    8   9         10     11  12  13  14       15 */
       | rem NAME ':' NAME rem PORT MAP '(' doindent map_list rem ')' ';' unindent a_body {
         slist *sl;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,$4); /* NAME2 */
           sl=addtxt(sl," ");
           sl=addtxt(sl,$2); /* NAME1 */
           sl=addtxt(sl,"(\n");
           sl=addsl(sl,indents[indent]);
           sl=addsl(sl,$10);  /* map_list */
           sl=addtxt(sl,");\n\n");
           $$=addsl(sl,$15); /* a_body */
         }
       /* 1   2   3     4  5   6        7  8    9       10               11  12  13       14   15  16  17       18       19  20  21       22 */
       | rem NAME ':' NAME rem GENERIC MAP '(' doindent generic_map_list ')' rem unindent PORT MAP '(' doindent map_list ')' ';' unindent a_body {
         slist *sl;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,$4); /* NAME2 (component name) */
           if ($5) {
             sl=addsl(sl,$5);
             sl=addsl(sl,indents[indent]);
           }
           sl=addtxt(sl," #(\n");
           sl=addsl(sl,indents[indent]);
           sl=addsl(sl,$10); /* (generic) map_list */
           sl=addtxt(sl,")\n");
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,$2); /* NAME1 (instance name) */
           sl=addtxt(sl,"(\n");
           sl=addsl(sl,indents[indent]);
           sl=addsl(sl,$18); /* map_list */
           sl=addtxt(sl,");\n\n");
           $$=addsl(sl,$22); /* a_body */
         }
       | optname PROCESS '(' sign_list ')' p_decl opt_is BEGN doindent p_body END PROCESS oname ';' unindent a_body {
         slist *sl;
           if (0) fprintf(stderr,"process style 1\n");
           sl=add_always($1,$4,$6,0);
           sl=addsl(sl,$10);
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"end\n\n");
           $$=addsl(sl,$16);
         }
       | optname PROCESS '(' sign_list ')' p_decl opt_is BEGN doindent
           rem IF edge THEN p_body END IF ';' rem END PROCESS oname ';' unindent a_body {
           slist *sl;
             if (0) fprintf(stderr,"process style 2: if then end if\n");
             sl=add_always($1,$4,$6,1);
             if($10){
               sl=addsl(sl,indents[indent]);
               sl=addsl(sl,$10);
             }
             sl=addsl(sl,$14);
             sl=addsl(sl,indents[indent]);
             sl=addtxt(sl,"end\n\n");
             $$=addsl(sl,$24);
         }
       /* 1      2        3  4          5  6       7      8     9 */
       | optname PROCESS '(' sign_list ')' p_decl opt_is BEGN doindent
         /* 10 11 12    13    14         15  16       17    18   19   20       21     22       23  24 25 */
           rem IF exprc THEN doindent p_body unindent ELSIF edge THEN doindent p_body unindent END IF ';'
         /* 26  27      28    29 30       31   32    */
           rem END PROCESS oname ';' unindent a_body {
           slist *sl;
             if (0) fprintf(stderr,"process style 3: if then elsif then end if\n");
             sl=add_always($1,$4,$6,1);
             if($10){
               sl=addsl(sl,indents[indent]);
               sl=addsl(sl,$10);
             }
             sl=addsl(sl,indents[indent]);
             sl=addtxt(sl,"  if(");
             sl=addsl(sl,$12);
             sl=addtxt(sl,") begin\n");
             sl=addsl(sl,$15);
             sl=addsl(sl,indents[indent]);
             sl=addtxt(sl,"  end else begin\n");
             sl=addsl(sl,$21);
             sl=addsl(sl,indents[indent]);
             sl=addtxt(sl,"  end\n");
             sl=addsl(sl,indents[indent]);
             sl=addtxt(sl,"end\n\n");
             $$=addsl(sl,$32);
         }
       /* 1      2        3  4          5  6       7      8     9 */
       | optname PROCESS '(' sign_list ')' p_decl opt_is BEGN doindent
         /* 10 11 12    13    14         15  16       17   18   19   20       21     22     23   24  25 26  27  28 29 */
           rem IF exprc THEN doindent p_body unindent ELSE IF edge THEN doindent p_body unindent END IF ';' END IF ';'
         /* 30      31    32 33       34   35    */
           END PROCESS oname ';' unindent a_body {
           slist *sl;
             if (0) fprintf(stderr,"process style 4: if then else if then end if\n");
             sl=add_always($1,$4,$6,1);
             if($10){
               sl=addsl(sl,indents[indent]);
               sl=addsl(sl,$10);
             }
             sl=addsl(sl,indents[indent]);
             sl=addtxt(sl,"  if(");
             sl=addsl(sl,$12); /* exprc */
             sl=addtxt(sl,") begin\n");
             sl=addsl(sl,$15); /* p_body:1 */
             sl=addsl(sl,indents[indent]);
             sl=addtxt(sl,"  end else begin\n");
             sl=addsl(sl,$22); /* p_body:2 */
             sl=addsl(sl,indents[indent]);
             sl=addtxt(sl,"  end\n");
             sl=addsl(sl,indents[indent]);
             sl=addtxt(sl,"end\n\n");
             $$=addsl(sl,$35); /* a_body */
         }

       /* note VHDL does not allow an else in an if generate statement */
       /* 1       2   3          4       5       6        7     8        9   10   11  12 */
       | gen_optname IF exprc generate  doindent a_body  unindent endgenerate oname ';' a_body {
         slist *sl;
         blknamelist *tname_list;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"generate ");
           sl=addtxt(sl,"if (");
           sl=addsl(sl,$3); /* exprc */
           sl=addtxt(sl,") begin: ");
           tname_list=blkname_list;
           sl=addtxt(sl,tname_list->name);
           blkname_list=blkname_list->next;
           if (tname_list!=NULL) {
           free(tname_list->name);
           free(tname_list);
           }
           sl=addtxt(sl,"\n");
           sl=addsl(sl,indents[indent]);
           sl=addsl(sl,$6);   /* a_body:1 */
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"end\n");
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"endgenerate\n");
           $$=addsl(sl,$11);    /* a_body:2 */
         }
       /* 1       2       3    4 5    6   7  8        9      10      11       12    13     14    15  16 */
       | gen_optname FOR  signal IN expr TO expr generate doindent a_body  unindent endgenerate oname ';' a_body {
         slist *sl;
         blknamelist *tname_list;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"genvar ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl,";\n");
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"generate ");
           sl=addtxt(sl,"for (");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl,"=");
           sl=addsl(sl,$5->sl); /* expr:1 */
           sl=addtxt(sl,"; ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," <= ");
           sl=addsl(sl,$7->sl); /* expr:2 */
           sl=addtxt(sl,"; ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," = ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," + 1) begin: ");
           tname_list=blkname_list;
           sl=addtxt(sl,tname_list->name);
           blkname_list=blkname_list->next;
           if (tname_list!=NULL) {
           free(tname_list->name);
           free(tname_list);
           }
           sl=addtxt(sl,"\n");
           sl=addsl(sl,indents[indent]);
           sl=addsl(sl,$10);   /* a_body:1 */
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"end\n");
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"endgenerate\n");
           $$=addsl(sl,$15);    /* a_body:2 */
         }
       /* 1           2       3   4   5    6     7      8        9      10      11       12    13     14    15  16 */
       | gen_optname FOR  signal IN expr DOWNTO expr generate doindent a_body  unindent endgenerate oname ';' a_body {
         slist *sl;
           blknamelist* tname_list;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"genvar ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl,";\n");
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"generate ");
           sl=addtxt(sl,"for (");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl,"=");
           sl=addsl(sl,$5->sl); /* expr:1 */
           sl=addtxt(sl,"; ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," >= ");
           sl=addsl(sl,$7->sl); /* expr:2 */
           sl=addtxt(sl,"; ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," = ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," - 1) begin: ");
           tname_list=blkname_list;
           sl=addtxt(sl,tname_list->name);
           blkname_list=blkname_list->next;
           if (tname_list!=NULL) {
           free(tname_list->name);
           free(tname_list);
           }
           sl=addtxt(sl,"\n");
           sl=addsl(sl,$10);   /* a_body:1 */
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"end\n");
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"endgenerate\n");
           $$=addsl(sl,$15);    /* a_body:2 */
         }
        | rem vhdassert a_body {
           slist *sl;
           sl=addsl($1,$2);
           $$=addsl(sl,$3);
        }
       ;

oname : {$$=NULL;}
      | NAME {free($1); $$=NULL;}
      ;

optname : rem {$$=$1;}
        | rem NAME ':' {$$=$1; free($2);}

gen_optname : rem {$$=$1;}
        | rem NAME ':' {
           blknamelist *tname_list;
           tname_list = xmalloc (sizeof(blknamelist));
           tname_list->name = xmalloc(strlen($2) + 1);
           strcpy(tname_list->name, $2);
           tname_list->next = blkname_list;
           blkname_list=tname_list;
           $$=$1;
           free($2);
         }
        ;

edge : '(' edge ')' {$$=addwrap("(",$2,")");}
     | NAME '\'' EVENT AND exprc {
         push_clkedge($5->data.sl->data.txt[0]-'0', "name'event and exprc");
       }
     | exprc AND NAME '\'' EVENT {
         push_clkedge($1->data.sl->data.txt[0]-'0', "exprc and name'event");
       }
     | POSEDGE '(' NAME ')' {
         push_clkedge(1, "explicit");
       }
     | NEGEDGE '(' NAME ')' {
         push_clkedge(0, "explicit");
       }
     ;

yeswith : {dowith=1;}

with_list : with_item ';' {$$=$1;}
          | with_item ',' rem with_list {
            slist *sl;
              if($3){
                sl=addsl($1,$3);
                $$=addsl(sl,$4);
              } else
                $$=addsl($1,$4);
            }
          | expr delay WHEN OTHERS ';' {
            slist *sl;
              sl=addtxt(indents[indent],"    default : ");
              sl=addsl(sl,slwith);
              sl=addtxt(sl," <= ");
              if(delay && $2){
                sl=addtxt(sl,"# ");
                sl=addval(sl,$2);
                sl=addtxt(sl," ");
              }
              if($1->op == 'c')
                sl=addsl(sl,addwrap("{",$1->sl,"}"));
              else
                sl=addsl(sl,$1->sl);
              free($1);
              delay=1;
              $$=addtxt(sl,";\n");
            }

with_item : expr delay WHEN wlist {
            slist *sl;
              sl=addtxt(indents[indent],"    ");
              sl=addsl(sl,$4);
              sl=addtxt(sl," : ");
              sl=addsl(sl,slwith);
              sl=addtxt(sl," <= ");
              if(delay && $2){
                sl=addtxt(sl,"# ");
                sl=addval(sl,$2);
                sl=addtxt(sl," ");
              }
              if($1->op == 'c')
                sl=addsl(sl,addwrap("{",$1->sl,"}"));
              else
                sl=addsl(sl,$1->sl);
              free($1);
              delay=1;
              $$=addtxt(sl,";\n");
            }

p_decl : rem {$$=$1;}
       | rem VARIABLE s_list ':' type ';' p_decl {
         slist *sl;
         sglist *sg, *p;
           sl=addtxt($1,"    reg");
           sl=addpar(sl,$5);
           free($5);
           sg=$3;
           for(;;){
             sl=addtxt(sl,sg->name);
             p=sg;
             sg=sg->next;
             free(p);
             if(sg)
               sl=addtxt(sl,", ");
             else
               break;
           }
           sl=addtxt(sl,";\n");
           $$=addsl(sl,$7);
         }
       | rem VARIABLE s_list ':' type ':' '=' expr ';' p_decl {
         slist *sl;
         sglist *sg, *p;
           sl=addtxt($1,"    reg");
           sl=addpar(sl,$5);
           free($5);
           sg=$3;
           for(;;){
             sl=addtxt(sl,sg->name);
             p=sg;
             sg=sg->next;
             free(p);
             if(sg)
               sl=addtxt(sl,", ");
             else
               break;
           }
           sl=addtxt(sl," = ");
           sl=addsl(sl,$8->sl);
           sl=addtxt(sl,";\n");
           $$=addsl(sl,$10);
         }
       ;

p_body : rem {$$=$1;}
       /* 1   2     3    4  5     6     7    8     9 */
       | rem signal ':' '=' norem expr ';' yesrem  p_body {
         slist *sl;
           sl=addsl($1,indents[indent]);
           sl=addsl(sl,$2->sl);
           findothers($2,$6->sl);
           sl=addtxt(sl," = ");
           if($6->op == 'c')
             sl=addsl(sl,addwrap("{",$6->sl,"}"));
           else
             sl=addsl(sl,$6->sl);
           sl=addtxt(sl,";\n");
           $$=addsl(sl,$9);
         }
       /* 1   2     3      4   5     6         7     8   */
       | rem signal norem '<' '=' sigvalue yesrem  p_body {
         slist *sl;
         sglist *sg;
         char *s;
           s=sbottom($2->sl);
           if((sg=lookup(io_list,s))==NULL)
             sg=lookup(sig_list,s);
           if(sg)
             sg->type=reg;
           sl=addsl($1,indents[indent]);
           sl=addsl(sl,$2->sl);
           findothers($2,$6);
           sl=addtxt(sl," <= ");
           sl=addsl(sl,$6);
           sl=addtxt(sl,";\n");
           $$=addsl(sl,$8);
         }
/*        1   2    3     4 5        6:1      7        8      9   10  11    12:2  */
       | rem IF exprc THEN doindent p_body unindent elsepart END IF ';' p_body {
         slist *sl;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"if(");
           sl=addsl(sl,$3);
           sl=addtxt(sl,") begin\n");
           sl=addsl(sl,$6);
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"end\n");
           sl=addsl(sl,$8);
           $$=addsl(sl,$12);
         }
/*        1   2    3      4 5:1  6  7:2   8    9       10:1   11       12  13   14  15:2 */
       | rem FOR  signal IN expr TO expr LOOP doindent p_body unindent END LOOP ';' p_body {
         slist *sl;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"for (");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl,"=");
           sl=addsl(sl,$5->sl); /* expr:1 */
           sl=addtxt(sl,"; ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," <= ");
           sl=addsl(sl,$7->sl); /* expr:2 */
           sl=addtxt(sl,"; ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," = ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," + 1) begin\n");
           sl=addsl(sl,$10);    /* p_body:1 */
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"end\n");
           $$=addsl(sl,$15);    /* p_body:2 */
         }
/*        1   2    3      4 5:1  6      7:2   8    9       10:1   11       12  13   14  15:2 */
       | rem FOR  signal IN expr DOWNTO expr LOOP doindent p_body unindent END LOOP ';' p_body {
         slist *sl;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"for (");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl,"=");
           sl=addsl(sl,$5->sl); /* expr:1 */
           sl=addtxt(sl,"; ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," >= ");
           sl=addsl(sl,$7->sl); /* expr:2 */
           sl=addtxt(sl,"; ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," = ");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl," - 1) begin\n");
           sl=addsl(sl,$10);    /* p_body:1 */
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"end\n");
           $$=addsl(sl,$15);    /* p_body:2 */
         }
/*        1   2    3      4   5         6      7       8   9    10  11*/
       | rem WHILE exprc LOOP doindent p_body unindent END LOOP ';' p_body {
         slist *sl;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"while ");
           sl=addtxt(sl,"(");
           sl=addsl(sl,$3); /* exprc */
           sl=addtxt(sl,") begin\n");
           sl=addsl(sl,$6);    /* p_body:1 */
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"end\n");
           $$=addsl(sl,$11);    /* p_body:2 */
         }
/*        1   2    3      4 5       6  7   8    9      10 */
       | rem CASE signal IS rem cases END CASE ';' p_body {
         slist *sl;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"case(");
           sl=addsl(sl,$3->sl); /* signal */
           sl=addtxt(sl,")\n");
           if($5){
             sl=addsl(sl,indents[indent]);
             sl=addsl(sl,$5);
           }
           sl=addsl(sl,$6);
           sl=addsl(sl,indents[indent]);
           sl=addtxt(sl,"endcase\n");
           $$=addsl(sl,$10);
         }
       | rem EXIT ';' p_body {
         slist *sl;
           sl=addsl($1,indents[indent]);
           sl=addtxt(sl,"disable;  //VHD2VL: add block name here\n");
           $$=addsl(sl,$4);
         }
       | rem NULLV ';' p_body {
         slist *sl;
           if($1){
             sl=addsl($1,indents[indent]);
             $$=addsl(sl,$4);
           }else
             $$=$4;
         }
       ;

elsepart : {$$=NULL;}
         | ELSIF exprc THEN doindent p_body unindent elsepart {
           slist *sl;
             sl=addtxt(indents[indent],"else if(");
             sl=addsl(sl,$2);
             sl=addtxt(sl,") begin\n");
             sl=addsl(sl,$5);
             sl=addsl(sl,indents[indent]);
             sl=addtxt(sl,"end\n");
             $$=addsl(sl,$7);
           }
         | ELSE doindent p_body unindent {
           slist *sl;
             sl=addtxt(indents[indent],"else begin\n");
             sl=addsl(sl,$3);
             sl=addsl(sl,indents[indent]);
             $$=addtxt(sl,"end\n");
           }
         ;

cases : WHEN wlist '=' '>' doindent p_body unindent cases{
        slist *sl;
          sl=addsl(indents[indent],$2);
          sl=addtxt(sl," : begin\n");
          sl=addsl(sl,$6);
          sl=addsl(sl,indents[indent]);
          sl=addtxt(sl,"end\n");
          $$=addsl(sl,$8);
        }
      | WHEN OTHERS '=' '>' doindent p_body unindent {
        slist *sl;
          sl=addtxt(indents[indent],"default : begin\n");
          sl=addsl(sl,$6);
          sl=addsl(sl,indents[indent]);
          $$=addtxt(sl,"end\n");
        }
      | /* Empty */ { $$=NULL; }  /* List without WHEN OTHERS */
      ;

wlist : wvalue {$$=$1;}
      | wlist '|' wvalue {
        slist *sl;
          sl=addtxt($1,",");
          $$=addsl(sl,$3);
        }
      ;

wvalue : STRING {$$=addvec(NULL,$1);}
       | NAME STRING {$$=addvec_base(NULL,$1,$2);}
       | NAME {$$=addtxt(NULL,$1);}
       ;

sign_list : signal {$$=$1->sl; free($1);}
          | signal ',' sign_list {
            slist *sl;
              if (vlog_ver == 2001)
                 sl=addtxt($1->sl,", ");
              else if (vlog_ver == 1995)
                 sl=addtxt($1->sl," or ");
              else
                 sl=0;
              free($1);
              $$=addsl(sl,$3);
            }
          ;

sigvalue : expr delay ';' {
           slist *sl;
             if(delay && $2){
               sl=addtxt(NULL,"# ");
               sl=addval(sl,$2);
               sl=addtxt(sl," ");
             } else
               sl=NULL;
             if($1->op == 'c')
               sl=addsl(sl,addwrap("{",$1->sl,"}"));
             else
               sl=addsl(sl,$1->sl);
             free($1);
             delay=1;
             $$=sl;
           }
         | expr delay WHEN exprc ';' {
             fprintf(stderr,"WARNING (line %d): Can't translate 'expr delay WHEN exprc;' expressions.\n",lineno);
             $$=NULL;
           }
         | expr delay WHEN exprc ELSE nodelay sigvalue {
           slist *sl;
             sl=addtxt($4," ? ");
             if($1->op == 'c')
               sl=addsl(sl,addwrap("{",$1->sl,"}"));
             else
               sl=addsl(sl,$1->sl);
             free($1);
             sl=addtxt(sl," : ");
             $$=addsl(sl,$7);
           }
         ;

nodelay  : /* empty */ {delay=0;}
         ;

delay    : /* empty */ {$$=0;}
         | AFTER NATURAL NAME {
             set_timescale($3);
             $$=$2;
           }
         ;

map_list : rem map_item {
           slist *sl;
           sl=addsl($1,indents[indent]);
           $$=addsl(sl,$2);}
         | rem map_item ',' map_list {
           slist *sl;
             sl=addsl($1,indents[indent]);
             sl=addsl(sl,$2);
             sl=addtxt(sl,",\n");
             $$=addsl(sl,$4);
           }
         ;

map_item : mvalue {$$=$1;}
         | NAME '=' '>' mvalue {
           slist *sl;
             sl=addtxt(NULL,".");
             sl=addtxt(sl,$1);
             sl=addtxt(sl,"(");
             sl=addsl(sl,$4);
             $$=addtxt(sl,")");
           }
         ;

mvalue : STRING {$$=addvec(NULL,$1);}
       | signal {$$=addsl(NULL,$1->sl);}
       | NATURAL {$$=addval(NULL,$1);}
       | NAME STRING {$$=addvec_base(NULL,$1,$2);}
       | OPEN {$$=addtxt(NULL,"/* open */");}
       | '(' OTHERS '=' '>' STRING ')' {
             $$=addtxt(NULL,"{broken{");
             $$=addtxt($$,$5);
             $$=addtxt($$,"}}");
             fprintf(stderr,"WARNING (line %d): broken width on port with OTHERS.\n",lineno);
           }
       ;


generic_map_list : rem generic_map_item {
           slist *sl;
           sl=addsl($1,indents[indent]);
           $$=addsl(sl,$2);}
         | rem generic_map_item ',' generic_map_list {
           slist *sl;
             sl=addsl($1,indents[indent]);
             sl=addsl(sl,$2);
             sl=addtxt(sl,",\n");
             $$=addsl(sl,$4);
           }
         | rem expr {  /* only allow a single un-named map item */
             $$=addsl(NULL,$2->sl);
           }
         ;

generic_map_item : NAME '=' '>' expr {
           slist *sl;
             sl=addtxt(NULL,".");
             sl=addtxt(sl,$1);
             sl=addtxt(sl,"(");
             sl=addsl(sl,$4->sl);
             $$=addtxt(sl,")");
           }
         ;

signal : NAME {
         slist *sl;
         slval *ss;
           ss=xmalloc(sizeof(slval));
           sl=new_signal($1);
           if (!sl) YYABORT;
           if(dowith){
             slwith=sl;
             dowith=0;
           }
           ss->sl=sl;
           ss->val=-1;
           ss->range=NULL;
           $$=ss;
         }
       | NAME '(' vec_range ')' {
         slval *ss;
         slist *sl;
           ss=xmalloc(sizeof(slval));
           sl=new_signal($1);
           if (!sl) YYABORT;
           sl=addpar_snug(sl,$3);
           if(dowith){
             slwith=sl;
             dowith=0;
           }
           ss->sl=sl;
           ss->range=$3;
           if($3->vtype==tVRANGE) {
             if (0) {
               fprintf(stderr,"ss->val set to 1 for ");
               fslprint(stderr,ss->sl);
               fprintf(stderr,", why?\n");
             }
             ss->val = -1; /* width is in the vrange */
           } else {
             ss->val = 1;
           }
           $$=ss;
         }
       | NAME '(' vec_range ')' '(' vec_range ')' {
         slval *ss;
         slist *sl;
           ss=xmalloc(sizeof(slval));
           sl=new_signal($1);
           if (!sl) YYABORT;
           sl=addpar_snug2(sl,$3, $6);
           if(dowith){
             slwith=sl;
             dowith=0;
           }
           ss->sl=sl;
           ss->range=$3;
           if($3->vtype==tVRANGE) {
             ss->val = -1; /* width is in the vrange */
           } else {
             ss->val = 1;
           }
           $$=ss;
         }
       ;

/* Expressions */
expr : signal {
         expdata *e;
           e=xmalloc(sizeof(expdata));
           e->op='t'; /* Terminal symbol */
           e->sl=$1->sl;
           free($1);
           $$=e;
         }
     | STRING {
         expdata *e;
           e=xmalloc(sizeof(expdata));
           e->op='t'; /* Terminal symbol */
           e->sl=addvec(NULL,$1);
           $$=e;
         }
     | SCIENTIFIC {
         expdata *e=xmalloc(sizeof(expdata));
           e->op='t'; /* Terminal symbol */
           e->sl=addtxt(NULL,$1);
           $$=e;
         }
     | FLOAT {
         expdata *e=xmalloc(sizeof(expdata));
           e->op='t'; /* Terminal symbol */
           e->sl=addtxt(NULL,$1);
           $$=e;
         }
     | NATURAL {
         expdata *e=xmalloc(sizeof(expdata));
           e->op='t'; /* Terminal symbol */
           e->sl=addval(NULL,$1);
           $$=e;
         }
     | NATURAL BASED {  /* e.g. 16#55aa# */
         /* XXX unify this code with addvec_base */
         expdata *e=xmalloc(sizeof(expdata));
         char *natval = xmalloc(strlen($2)+34);
           e->op='t'; /* Terminal symbol */
           switch($1) {
           case  2:
             sprintf(natval, "'B%s",$2);
             break;
           case  8:
             sprintf(natval, "'O%s",$2);
             break;
           case 10:
             sprintf(natval, "'D%s",$2);
             break;
           case 16:
             sprintf(natval, "'H%s",$2);
             break;
           default:
             sprintf(natval,"%d#%s#",$1,$2);
             fprintf(stderr,"ERROR (line %d): can't translate based number %s (only bases of 2, 8, 10, and 16 are translatable).\n", lineno, natval);
             YYABORT;
           }
           e->sl=addtxt(NULL,natval);
           $$=e;
         }
     | NAME STRING {
         expdata *e=xmalloc(sizeof(expdata));
           e->op='t'; /* Terminal symbol */
           e->sl=addvec_base(NULL,$1,$2);
           $$=e;
         }
     | '(' OTHERS '=' '>' expr ')' {
         expdata *e;
           e=xmalloc(sizeof(expdata));
           e->op='o'; /* others */
           e->sl=addothers(NULL,$5->sl);
           $$=e;
         }
     | expr '&' expr { /* Vector chaining a.k.a. bit concatenation */
         slist *sl;
           sl=addtxt($1->sl,",");
           sl=addsl(sl,$3->sl);
           free($3);
           $1->op='c';
           $1->sl=sl;
           $$=$1;
         }
     | '-' expr %prec UMINUS {$$=addexpr(NULL,'m'," -",$2);}
     | '+' expr %prec UPLUS {$$=addexpr(NULL,'p'," +",$2);}
     | expr '+' expr {$$=addexpr($1,'+'," + ",$3);}
     | expr '-' expr {$$=addexpr($1,'-'," - ",$3);}
     | expr POW expr {$$=addexpr($1,'*'," ** ",$3);}
     | expr '*' expr {$$=addexpr($1,'*'," * ",$3);}
     | expr '/' expr {$$=addexpr($1,'/'," / ",$3);}
     | expr MOD expr {
         $$=addexpr($1,'%'," % ",$3);
         fprintf(stderr,"WARNING (line %d): MOD translation as %% is wrong when args have different signs.\n", lineno);
       }
     | expr RW_REM expr {$$=addexpr($1,'%'," % ",$3);}
     | NOT expr {$$=addexpr(NULL,'~'," ~",$2);}
     | ABS expr {
        slist *sl;
          sl=addtxt(NULL,"( ( $signed(");
          sl= addsl(sl,$2->sl);
          sl=addtxt(sl,") < 0 ) ? -$signed(");
          sl= addsl(sl,$2->sl);
          sl=addtxt(sl,") : ");
          sl= addsl(sl,$2->sl);
          sl=addtxt(sl," )");
          $2->sl=sl;
          $$=$2;
       }
     | expr AND expr {$$=addexpr($1,'&'," & ",$3);}
     | expr OR expr {$$=addexpr($1,'|'," | ",$3);}
     | expr NAND expr {$$=addexpr(NULL,'~'," ~",addexpr($1,'&'," & ",$3));}
     | expr NOR expr {$$=addexpr(NULL,'~'," ~",addexpr($1,'|'," | ",$3));}
     | expr XOR expr {$$=addexpr($1,'^'," ^ ",$3);}
     | expr XNOR expr {$$=addexpr(NULL,'~'," ~",addexpr($1,'^'," ^ ",$3));}
     | expr SLL expr {
         $$=addexpr($1,'*'," << ",$3);
         fprintf(stderr,"WARNING (line %d): SLL translated as logical shift.\n", lineno);
         fprintf(stderr," Replace << by <<< in the resulting Verilog for the arithmetic version.\n");
       }
     | SHIFT_LEFT '(' expr ',' expr ')' {
         $$=addexpr($3,'*'," << ",$5);
         fprintf(stderr,"WARNING (line %d): SHIFT_LEFT() translated as logical shift.\n", lineno);
         fprintf(stderr," Replace << by <<< in the resulting Verilog for the arithmetic version.\n");
       }
     | expr SRL expr {
         $$=addexpr($1,'*'," >> ",$3);
         fprintf(stderr,"WARNING (line %d): SRL translated as logical shift.\n", lineno);
         fprintf(stderr," Replace >> by >>> in the resulting Verilog for the arithmetic version.\n");
       }
     | SHIFT_RIGHT '(' expr ',' expr ')' {
         $$=addexpr($3,'*'," >> ",$5);
         fprintf(stderr,"WARNING (line %d): SHIFT_RIGHT() translated as logical shift.\n", lineno);
         fprintf(stderr," Replace >> by >>> in the resulting Verilog for the arithmetic version.\n");
       }
     | expr SLA expr {
         fprintf(stderr,"ERROR (line %d): SLA must not be used.\n", lineno);
         fprintf(stderr,"Use SHIFT_LEFT/SLL from NUMERIC_STD with type SIGNED.\n");
         YYABORT;
       }
     | expr SRA expr {
         fprintf(stderr,"ERROR (line %d): SRA must not be used.\n", lineno);
         fprintf(stderr," Use SHIFT_RIGHT/SRL from NUMERIC_STD with type SIGNED.\n");
         YYABORT;
       }
     | expr ROR expr {
         fprintf(stderr,"ERROR (line %d): ROR is not implemented yet.\n", lineno);
         YYABORT;
       }
     | ROTATE_RIGHT '(' expr ',' expr ')' {
         fprintf(stderr,"ERROR (line %d): ROTATE_RIGHT is not implemented yet.\n", lineno);
         YYABORT;
       }
     | expr ROL expr {
         fprintf(stderr,"ERROR (line %d): ROL is not implemented yet.\n", lineno);
         YYABORT;
       }
     | ROTATE_LEFT '(' expr ',' expr ')' {
         fprintf(stderr,"ERROR (line %d): ROTATE_LEFT is not implemented yet.\n", lineno);
         YYABORT;
       }
     | BITVECT '(' expr ')' {
       /* single argument type conversion function e.g. std_logic_vector(x) */
       $$ = addnest($3);
      }
     | CONVFUNC_1 '(' expr ')' {
       $$ = addnest($3);
      }
     | CONVFUNC_2 '(' expr ',' expr ')' {
       /* two argument type conversion e.g. to_unsigned(x, 3) */
       $$ = addnest($3);
      }
     | '(' expr ')' {
       $$ = addnest($2);
      }
     ;

/* Conditional expressions */
exprc : conf { $$=$1; }
      | '(' exprc ')' {
         $$=addwrap("(",$2,")");
      }
      | exprc AND exprc %prec ANDL {
        slist *sl;
          sl=addtxt($1," && ");
          $$=addsl(sl,$3);
        }
      | exprc NAND exprc %prec NANDL {
        slist *sl;
          sl=addtxt(NULL,"!(");
          sl= addsl(sl,$1);
          sl=addtxt(sl," && ");
          sl= addsl(sl,$3);
          $$=addtxt(sl,")");
        }
      | exprc OR exprc %prec ORL {
        slist *sl;
          sl=addtxt($1," || ");
          $$=addsl(sl,$3);
        }
      | exprc NOR exprc %prec NORL {
        slist *sl;
          sl=addtxt(NULL,"!(");
          sl= addsl(sl,$1);
          sl=addtxt(sl," || ");
          sl= addsl(sl,$3);
          $$=addtxt(sl,")");
        }
      | NOT exprc %prec NOTL {
        slist *sl;
          sl=addtxt(NULL,"!");
          $$=addsl(sl,$2);
        }
      ;

/* Comparisons */
conf : expr '=' expr %prec EQUAL {
       slist *sl;
         if($1->op == 'c')
           sl=addwrap("{",$1->sl,"} == ");
         else if($1->op != 't')
           sl=addwrap("(",$1->sl,") == ");
         else
           sl=addtxt($1->sl," == ");
         if($3->op == 'c')
           $$=addsl(sl,addwrap("{",$3->sl,"}"));
         else if($3->op != 't')
           $$=addsl(sl,addwrap("(",$3->sl,")"));
         else
           $$=addsl(sl,$3->sl);
         free($1);
         free($3);
       }
     | expr '>' expr {
       slist *sl;
         if($1->op == 'c')
           sl=addwrap("{",$1->sl,"} > ");
         else if($1->op != 't')
           sl=addwrap("(",$1->sl,") > ");
         else
           sl=addtxt($1->sl," > ");
         if($3->op == 'c')
           $$=addsl(sl,addwrap("{",$3->sl,"}"));
         else if($3->op != 't')
           $$=addsl(sl,addwrap("(",$3->sl,")"));
         else
           $$=addsl(sl,$3->sl);
         free($1);
         free($3);
       }
     | expr '>' '=' expr %prec BIGEQ {
       slist *sl;
         if($1->op == 'c')
           sl=addwrap("{",$1->sl,"} >= ");
         else if($1->op != 't')
           sl=addwrap("(",$1->sl,") >= ");
         else
           sl=addtxt($1->sl," >= ");
         if($4->op == 'c')
           $$=addsl(sl,addwrap("{",$4->sl,"}"));
         else if($4->op != 't')
           $$=addsl(sl,addwrap("(",$4->sl,")"));
         else
           $$=addsl(sl,$4->sl);
         free($1);
         free($4);
       }
     | expr '<' expr {
       slist *sl;
         if($1->op == 'c')
           sl=addwrap("{",$1->sl,"} < ");
         else if($1->op != 't')
           sl=addwrap("(",$1->sl,") < ");
         else
           sl=addtxt($1->sl," < ");
         if($3->op == 'c')
           $$=addsl(sl,addwrap("{",$3->sl,"}"));
         else if($3->op != 't')
           $$=addsl(sl,addwrap("(",$3->sl,")"));
         else
           $$=addsl(sl,$3->sl);
         free($1);
         free($3);
       }
     | expr '<' '=' expr %prec LESSEQ {
       slist *sl;
         if($1->op == 'c')
           sl=addwrap("{",$1->sl,"} <= ");
         else if($1->op != 't')
           sl=addwrap("(",$1->sl,") <= ");
         else
           sl=addtxt($1->sl," <= ");
         if($4->op == 'c')
           $$=addsl(sl,addwrap("{",$4->sl,"}"));
         else if($4->op != 't')
           $$=addsl(sl,addwrap("(",$4->sl,")"));
         else
           $$=addsl(sl,$4->sl);
         free($1);
         free($4);
       }
     | expr '/' '=' expr %prec NOTEQ {
       slist *sl;
         if($1->op == 'c')
           sl=addwrap("{",$1->sl,"} != ");
         else if($1->op != 't')
           sl=addwrap("(",$1->sl,") != ");
         else
           sl=addtxt($1->sl," != ");
         if($4->op == 'c')
           $$=addsl(sl,addwrap("{",$4->sl,"}"));
         else if($4->op != 't')
           $$=addsl(sl,addwrap("(",$4->sl,")"));
         else
           $$=addsl(sl,$4->sl);
         free($1);
         free($4);
       }
     ;

simple_expr : signal {
         expdata *e;
         e=xmalloc(sizeof(expdata));
         e->op='t'; /* Terminal symbol */
         e->sl=$1->sl;
         free($1);
         $$=e;
      }
     | STRING {
         expdata *e;
         e=xmalloc(sizeof(expdata));
         e->op='t'; /* Terminal symbol */
         e->sl=addvec(NULL,$1);
         $$=e;
      }
     | NATURAL {
         expdata *e;
         e=xmalloc(sizeof(expdata));
         e->op='n'; /* natural */
         e->value=$1;
         e->sl=addval(NULL,$1);
         $$=e;
      }
     | NAME '\'' LEFT {
	      /* lookup NAME and get its left */
              sglist *sg = NULL;
              if((sg=lookup(io_list,$1))==NULL) {
                sg=lookup(sig_list,$1);
              }
              if(sg) {
                expdata *e;
                e=xmalloc(sizeof(expdata));
                e->sl=addwrap("(",sg->range->nhi,")");  /* XXX left vs. high? */
                e->op='t';
                $$=e;
              } else {
                fprintf(stderr,"ERROR (line %d): undefined left \"%s'left\".\n", lineno, $1);
                YYABORT;
              }
      }
     | simple_expr '+' simple_expr {
       $$=addexpr($1,'+'," + ",$3);
      }
     | simple_expr '-' simple_expr {
       $$=addexpr($1,'-'," - ",$3);
      }
     | simple_expr POW simple_expr {
       $$=addexpr($1,'*'," ** ",$3);
      }
     | simple_expr '*' simple_expr {
       $$=addexpr($1,'*'," * ",$3);
      }
     | simple_expr '/' simple_expr {
       $$=addexpr($1,'/'," / ",$3);
      }
     | CONVFUNC_1 '(' simple_expr ')' {
       /* one argument type conversion e.g. to_integer(x) */
       expdata *e;
       e=xmalloc(sizeof(expdata));
       e->sl=addsl(NULL,$3->sl);
       e->op='e';
       $$=e;
      }
     | '(' simple_expr ')' {
       expdata *e;
       e=xmalloc(sizeof(expdata));
       /* e->sl=addwrap("(",$2->sl,")"); */
       e->sl=addsl(NULL,$2->sl);
       e->op='e';
       $$=e;
      }
     ;

%%

const char *outfile;    /* Output file */
const char *sourcefile; /* Input file */

void print_usage(void) {
   printf(
      "Usage: vhd2vl [--debug] [--quiet] [--std 1995|2001] [--version] source_file.vhd > target_file.v\n"
      "   or  vhd2vl [--debug] [--quiet] [--std 1995|2001] [--version] source_file.vhd target_file.v\n"
   );
}

int main(int argc, char **argv){
int i,j;
char *s;
slist *sl;
int status;
int opt;
static int quiet;

  static struct option options[] = {
    {"debug",     no_argument,       &yydebug,  1  },
    {"quiet",     no_argument,       &quiet,    1  },
    {"std",       required_argument, 0,        's' },
    {"help",      no_argument,       0,        'h' },
    {"version",   no_argument,       0,        'v' },
    {0,           0,                 0,         0  }
  };

  /* Init the indentation variables */
  indents[0]=NULL;
  for(i=1;i<MAXINDENT;i++){
    indents[i]=sl=xmalloc(sizeof(slist));
    sl->data.txt=s=xmalloc(sizeof(char) *((i<<1)+1));
    for(j=0;j<(i<<1);j++)
      *s++=' ';
    *s=0;
    sl->type=tTXT;
    sl->slst=NULL;
  }

  while ((opt = getopt_long(argc, argv,"s:h", options, 0 )) != -1) {
    switch (opt) {
      case 0:
         break;
      case 's':
        vlog_ver = atoi(optarg);
        if (vlog_ver != 1995 && vlog_ver != 2001) {
           print_usage();
           exit(EXIT_FAILURE);
        }
        break;
      case 'v':
#ifdef GIT_BASED_VERS
        printf("vhd2vl version " VHD2VL_VER " (git commit " GIT_BASED_VERS ")\n");
#else
        printf("vhd2vl version " VHD2VL_VER "\n");
#endif
        exit(EXIT_SUCCESS);
      default:
        print_usage();
        exit(EXIT_SUCCESS);
    }
  }

  sourcefile = "-";
  outfile    = "-";
  if (optind < argc) {
     sourcefile = argv[optind++];
     if (strcmp(sourcefile,"-")!=0 && !freopen(sourcefile, "r", stdin)) {
        fprintf(stderr, "ERROR: Can't open input file '%s'.\n", sourcefile);
        return(1);
     }
  } else {
    print_usage();
    exit(EXIT_FAILURE);
  }
  if (optind < argc) {
     outfile = argv[optind++];
     if (strcmp(outfile,"-")!=0 && !freopen(outfile, "w", stdout)) {
        fprintf(stderr, "ERROR: Can't open output file '%s'.\n", outfile);
        return(1);
     }
  }
  if (optind < argc) {
     print_usage();
     exit(EXIT_FAILURE);
  }

  if (!quiet) {
     printf("// File %s translated with vhd2vl " VHD2VL_VER " VHDL to Verilog RTL translator\n", sourcefile);
     printf("// vhd2vl settings:\n"
            "//  * Verilog Module Declaration Style: %d\n\n", vlog_ver);
     fputs(
"// vhd2vl is Free (libre) Software:\n"
"//   Copyright (C) 2001-2023 Vincenzo Liguori - Ocean Logic Pty Ltd\n"
"//     http://www.ocean-logic.com\n"
"//   Modifications Copyright (C) 2006 Mark Gonzales - PMC Sierra Inc\n"
"//   Modifications (C) 2010 Shankar Giri\n"
"//   Modifications Copyright (C) 2002-2023 Larry Doolittle\n"
"//     http://doolittle.icarus.com/~larry/vhd2vl/\n"
"//   Modifications (C) 2017 Rodrigo A. Melo\n"
"//\n", stdout);
     fputs(
"//   vhd2vl comes with ABSOLUTELY NO WARRANTY.  Always check the resulting\n"
"//   Verilog for correctness, ideally with a formal verification tool.\n"
"//\n"
"//   You are welcome to redistribute vhd2vl under certain conditions.\n"
"//   See the license (GPLv2) file included with the source for details.\n\n"
"// The result of translation follows.  Its copyright status should be\n"
"// considered unchanged from the original VHDL.\n\n"
     , stdout);
  }
  status = yyparse();
  fclose(stdout);
  fclose(stdin);
  if (status != 0 && strcmp(outfile,"-")!=0) unlink(outfile);
  return status;
}
