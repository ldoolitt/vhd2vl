vhd2vl : lex.yy.c vhd2vl.tab.c
	gcc -Wall -Wshadow -W -O2 -g -o vhd2vl lex.yy.c vhd2vl.tab.c -lfl

vhd2vl.tab.c : vhd2vl.y def.h
	bison -d -v -t vhd2vl.y

lex.yy.c : vhd2vl.l def.h
	flex -i vhd2vl.l

clean :
	rm -f lex.yy.c vhd2vl.tab.c vhd2vl.tab.h vhd2vl.output  vhd2vl
