// C program to implement Quick Sort Algorithm
// adapted from https://www.geeksforgeeks.org/quick-sort-in-c/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <unistd.h>

void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

int partition(int arr[], int low, int high) {

    // Initialize pivot to be the first element
    int p = arr[low];
    int i = low;
    int j = high;

    while (i < j) {

        // Find the first element greater than
        // the pivot (from starting)
        while (arr[i] <= p && i <= high - 1) {
            i++;
        }

        // Find the first element smaller than
        // the pivot (from last)
        while (arr[j] > p && j >= low + 1) {
            j--;
        }
        if (i < j) {
            swap(&arr[i], &arr[j]);
        }
    }
    swap(&arr[low], &arr[j]);
    return j;
}

void quickSort(int arr[], int low, int high) {
    if (low < high) {

        // call partition function to find Partition Index
        int pi = partition(arr, low, high);

        // Recursively call quickSort() for left and right
        // half based on Partition Index
        quickSort(arr, low, pi - 1);
        quickSort(arr, pi + 1, high);
    }
}

/*
    1) Rewrite to take argument size from command line (use getopt)
    2) Write usage
    3) Credit
    4) Random in distribution
    5) Use quiet option to suprress output

    /usr/bin/time -a -o qsort.txt qsort > /dev/null
*/


int main(int argc, char **argv) {
    char opt;
    int n, quiet = 0;
    int *arr;


    if (argc != 2) {
      fprintf(stderr, "usage: %s <size>\n", argv[0]);
      exit(1);
    }

    n = atoi(argv[1]);
    arr = malloc(sizeof(int) * n);
 
    srand(time(0));
    for (int i = 0; i < n; i++)
        arr[i] = n * ((double) rand()) / RAND_MAX;

    // calling quickSort() to sort the given array
    quickSort(arr, 0, n - 1);

    if (!quiet) {
        for (int i = 0; i < n; i++)
            printf("%d ", arr[i]);
        printf("\n");
    }

    return 0;
}
