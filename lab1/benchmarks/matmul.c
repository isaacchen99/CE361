// C program to multiply two matrices
// adapted from https://www.geeksforgeeks.org/c-program-multiply-two-matrices/

#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>

// matrix dimensions so that we dont have to pass them as
// parameters 
int R1, R2, C1, C2;
int flops;

void multiplyMatrix(double **r, double **m1, double **m2)
{
	for (int i = 0; i < R1; i++) 
		for (int j = 0; j < C2; j++)
			r[i][j] = 0;
	for (int i = 0; i < R1; i++) {
		for (int j = 0; j < C2; j++) {
			for (int k = 0; k < R2; k++) {
				r[i][j] += m1[i][k] * m2[k][j];
				flops += 2;
			}

		}
	}
}

double ** mat_alloc(int rows, int cols) {
	double **mat = malloc((sizeof(double*) * rows));
	for(int i = 0; i < rows; i++) {
		mat[i] = calloc(cols, sizeof(double));
		for(int j = 0; j < cols; j++)
		  mat[i][j] = ((double) random()) / RAND_MAX;
	}
	return mat;
}


int main(int argc, char **argv)
{
	double **r, **m1, **m2;
	int ndim;

	if (argc != 2) {
	  fprintf(stderr, "usage: %s <ndim>\n", argv[0]);
	  exit(1);
	}

	ndim = atoi(argv[1]);

	R1 = R2 = C1 = C2 = ndim;

	r = mat_alloc(R1, C2);
	m1 = mat_alloc(R1, C1);
	m2 = mat_alloc(R2, C2);

	for(int i = 0; i < R1; i++)
		for(int j = 0; j < C1; j++)
			m1[i][j] = i+j+1;

	for(int i = 0; i < R2; i++)
		for(int j = 0; j < C2; j++)
			m2[i][j] = i+j;

	flops = 0;
	multiplyMatrix(r, m1, m2);
	fprintf(stdout, "Flops = %d\n", flops);

	return 0;
}

