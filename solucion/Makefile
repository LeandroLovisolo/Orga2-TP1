# Flags
C_FLAGS    = -Wall -Werror -pedantic --std=c99 -ggdb -O0
CPP_FLAGS  = -Wall -Werror -pedantic -ggdb -O0 -Wno-variadic-macros
NASM_FLAGS = -f elf64 -g -F dwarf 

# Ejercicio 1
EJ1        = tp1
EJ1_OBJS   = tree.o

# Ejercicio 2
EJ2        = main
EJ2_OBJS   = tree.o

.PHONY: all clean

all: $(EJ1) $(EJ2)

$(EJ1): $(EJ1).cpp $(EJ1_OBJS)
	g++ -o $@ $(CPP_FLAGS) $< $(EJ1_OBJS)

$(EJ2): $(EJ2).c $(EJ2_OBJS)
	gcc -o $@ $(C_FLAGS) $< $(EJ2_OBJS)

%.o: %.asm
	nasm $(NASM_FLAGS) -o $@ $<

%.o: %.c
	gcc -c $(C_FLAGS) -o $@ $<

clean:
	rm -f $(EJ1) $(EJ2) *.o