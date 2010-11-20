# Leave off -Wundef -Wredundant-decls -Wtraditional-conversion until flex
# and bison get cleaned up.  Our code is nearly fine now.
# Use -W for now instead of the more modern -Wextra, since lots of people
# still use older compilers.
# Use the following for development
# WARNS = -Wall -W -Wshadow -Wpointer-arith -Wcast-qual -Wpointer-arith -Wcast-align -Wcast-qual -Wsign-compare -Wwrite-strings -Wstrict-overflow=5 -Wformat=2 -pedantic

# simplified version for general use, so as not to look so intimidating
WARNS = -Wall -W

# any of the following three should work:
STANDARD =
#STANDARD = --std=c89 -D_POSIX_C_SOURCE -D_BSD_SOURCE
#STANDARD = --std=c99 -D_POSIX_C_SOURCE -D_BSD_SOURCE

vhd2vl : lex.yy.c vhd2vl.tab.c
	gcc ${STANDARD} ${WARNS} -O2 -g -o vhd2vl lex.yy.c vhd2vl.tab.c -lfl

vhd2vl.tab.c : vhd2vl.y def.h
	bison -d -v -t vhd2vl.y

lex.yy.c : vhd2vl.l def.h
	flex -i vhd2vl.l

clean :
	rm -f lex.yy.c vhd2vl.tab.c vhd2vl.tab.h vhd2vl.output  vhd2vl
