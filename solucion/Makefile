EXTRAFLAGS:= -Wall -Werror -pedantic --std=c99 -ggdb -O0
EXTRACPPFLAGS:= -Wall -Werror -pedantic -ggdb -O0 -Wno-variadic-macros
NASMEXTRAFLAGS:=-f elf64 -g -F dwarf 
OBJS=tree.o
COBJS=ctree.o
HEADS=tree.h
EXE=tp1
INCLUDE=-include /usr/include/errno.h

.PHONY: all clean

test: $(OBJS) $(HEADS) test.o
	 gcc $(INCLUDE) -o test $(EXTRAFLAGS) test.c $(OBJS)

$(EXE): $(EXE).cpp $(OBJS) $(HEADS)
	g++ $(INCLUDE) -o $@ $(EXTRACPPFLAGS) $< $(OBJS)

solc: $(EXE).cpp $(COBJS) $(HEADS)
	g++ $(INCLUDE) -o $@ $(EXTRACPPFLAGS) $< $(OBJS)

%.o: %.asm
	nasm $(NASMEXTRAFLAGS) -o $@ $<

%.o: %.c
	gcc -c $(EXTRAFLAGS) -o $@ $<

bundle:
	mkdir -p tp1bundle
	mkdir -p tp1bundle/solucion
	mkdir -p tp1bundle/tests
	cp ../enunciado/enunciado-tp1.pdf versiones.txt tp1bundle
	cp ../tests/*.in tp1bundle/tests
	cp ../tests/*.catedra.out tp1bundle/tests
	cp tree.asm tree.h tests.sh tp1.cpp Makefile tp1bundle/solucion
	tar -czf tp1.tar.gz tp1bundle
	#rm -rf tp1bundle

all: $(EXE)

clean:
	rm -f $(OBJS) test.o test
	rm -f $(EXE) *.o
