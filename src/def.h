/*
    vhd2vl v2.3
    VHDL to Verilog RTL translator
    Copyright (C) 2001 Vincenzo Liguori - Ocean Logic Pty Ltd - http://www.ocean-logic.com
    Modifications (C) 2006 Mark Gonzales - PMC Sierra Inc

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

#ifndef __def_h
#define __def_h

#define MAXINDENT 36
#define MAXEDGES  1000  /* maximum number of @(edge) processes supported in a source file */

typedef struct nlist {
  char *name; /* Name */
  struct nlist *next;
} nlist;

enum slistType {tSLIST, tTXT, tVAL, tPTXT, tOTHERS};
typedef struct slist {
  enum slistType type;
  struct slist *slst;
  union {
    struct slist *sl; /* type 0 */
    char *txt;        /* type 1 */
    char **ptxt;      /* type 3!*/
    int val;          /* type 2,4 */
  } data;
} slist;

enum vrangeType {tSCALAR, tSUBSCRIPT, tVRANGE};
typedef struct vrange {
  /*  int hi, lo; */
  enum vrangeType vtype;
  struct slist *nhi, *nlo; /* MAG index is a simple expression */
  slist *size_expr;        /* expression that calculates size (width) of this vrange */
  int    sizeval;          /* precalculated size value */
  int    updown;           /* only used for indexed part select case */
  struct slist *xhi, *xlo; /* array index range; 0,0 for normal scalars */
} vrange;

typedef struct slval {
  slist *sl;
  int val; /* Signal size */
  vrange *range; /* Signal size */
} slval;

typedef struct expdata {
  char op;
  int value;  /* only set for simple_expr */
  slist *sl;
} expdata;
/* Other people might use an enum for the op (operation).
 * I use a mnemonic character.
 *  'c'  Chain
 *  'e'  Expression
 *  'n'  Natural
 *  't'  Terminal symbol
 *  'o'  Others
 * This is used to determine punctuation in the nesting process,
 * reducing the number of useless parenthesis levels.
 */

typedef struct sglist {
  char *name; /* Signal name */
  char *type; /* Reg or wire */
  const char *dir; /* input, output, inout */
  vrange *range; /* Signal size */
  struct sglist *next;
} sglist;

typedef struct blknamelist {
  char *name; /* Optional name */
  struct blknamelist *next;
} blknamelist;

/* Routine common between vhd2vl.l and vhd2vl.y */
char *xstrdup(const char *s);

#endif
