CC = gcc
CFLAGS = -Wall -Wextra

all: preprocessor compiler assembler linker run

.PHONY: all clean

run:
        @-./program

linker:
        @gcc main.o function.o -o program

assembler:
        @as main.s -o main.o
        @as function.s -o function.o

compiler:
        @gcc -S main.c
        @gcc -S function.c

preprocessor:
        @gcc -E main.c > main.i
        @gcc -E function.c > function.i

clean:
        @rm -f program *.o *.s *.i *.out
        @clear