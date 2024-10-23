#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_DIM 64
#define MAX(a,b) ((a > b) ? a : b)

/* create visited map */
int** make_visited(int rd, int cd)
{
    int **v = malloc((sizeof(int*)) * rd);   
    for(int i = 0; i < rd; i++)
        v[i] = calloc(sizeof(int*), cd);
    return v;
}

/* initialize visited map */
void clear_visited(int **v, int rd, int cd)
{
    for(int i = 0; i < rd; i++)
        for(int j = 0; j < cd; j++)
            v[i][j] = 0;
}

/* depth first search within the grid counting the number of matching substrings */
int dfs(char *match, char **grid, int r, int c, int rd, int cd, int **visited)
{
    /* no match if search is off the grid */
    if ((r < 0) || (r >= rd) || (c < 0) || (c >= cd))
        return 0;

    /* no match if this cell has been visited already */
    if (visited[r][c])
        return 0;

    /* first time here -- mark as visited */
    visited[r][c] = 1;

    /* check for match of next character */
    if (grid[r][c] == match[0]) {
        char *next = match + 1; /* next substring */

        /* are we done yet? */
        if (*next == '\0')
            return 1;
        
        /* recursive calls in every direction */
        return dfs(next, grid, r-1, c, rd, cd, visited) +
            dfs(next, grid, r, c-1, rd, cd, visited) +
            dfs(next, grid, r+1, c, rd, cd, visited) +
            dfs(next, grid, r, c+1, rd, cd, visited);         
    }
    return 0;
}

/* find given word within the puzzle grid */
void find_word(char *word, char **grid, int rd, int cd, int **visited)
{
    int count = 0;

    /* look for the word starting at every location in the grid */
    for(int i = 0; i < rd; i++)
        for(int j = 0; j < cd; j++) {  
            /* each start gets a clear visit map */
            clear_visited(visited, rd, cd); 

            /* count all matches of word starting at (i,j) */
            count += dfs(word, grid, i, j, rd, cd, visited); 
        }
    /* report findings */
    fprintf(stdout, "%s %d\n", word, count);
}

/* read in entire puzzle grid */
char** read_puzzle(FILE *infile, int *rd, int *cd) {
    char buffer[MAX_DIM], **puzzle = NULL, *result;
    int rows = 0;
    int width, cols = 0;

    /* attempt to read first line */
    result = fgets(buffer, sizeof(buffer), infile);
    if (!result) {
        /* this failed :( */
        *rd = rows;
        *cd = cols;
        return NULL;
    }
    /* first line determines width */
    cols = strnlen(buffer, sizeof(buffer)); 

    do {
        /* add line to the puzzle grid */
        rows++;
        puzzle = realloc(puzzle, sizeof(char*) * rows);
        puzzle[rows-1] = strndup(buffer, sizeof(buffer));

        /* try to read the next line */
        result = fgets(buffer, sizeof(buffer), infile);
        width = strnlen(buffer, sizeof(buffer));

        /* exit if read fails or not enough characters in this line */
    } while(result && (width >= cols));

    /* set dimensions and return result */
    *rd = rows;
    *cd = cols;
    return puzzle;
}

/* pick out a single word (throw away spaces) */
char* chop(char *s) {
    char word_buffer[MAX_DIM+1];
    sscanf(s, "%s", word_buffer);
    return strndup(word_buffer, sizeof(word_buffer));
}

int main(int argc, char **argv)
{
    char buffer[MAX_DIM+1], *word, **puzzle;
    int **visited;
    int rows, cols;

    if (argc != 2) {
        fprintf(stderr, "usage: %s <puzzle-file>\n", argv[0]);
        exit(1);
    }

    /* read in the puzzle */
    FILE *puzzle_fd = fopen(argv[1], "r");
    puzzle = read_puzzle(puzzle_fd, &rows, &cols);
    if (!puzzle) {
        fprintf(stderr, "could not read puzzle\n");
        exit(1);
    }

    /* report on dimensions */
    fprintf(stdout, "puzzle is %d x %d\n", rows, cols);

    /* create visited map */
    visited = make_visited(rows, cols);

    /* read the next word from stdin and try to find it in the puzzle grid */
    while (fgets(buffer, sizeof(buffer), stdin)) {
        word = chop(buffer);
        find_word(word, puzzle, rows, cols, visited);
    }

    return 0;
}


