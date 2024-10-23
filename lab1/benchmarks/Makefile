# Makefile

all: matmul qsort treeops puzzle

matmul: matmul.c
	gcc -O2 -o matmul matmul.c

qsort: qsort.c
	gcc -O2 -o qsort qsort.c


treeops: top-down-splay.c
	gcc -O2 -o treeops top-down-splay.c

puzzle: puzzle.c
	gcc -O2 -o puzzle puzzle.c

clean:
	rm -f matmul qsort treeops puzzle


