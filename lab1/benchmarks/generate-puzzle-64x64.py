import random

def place_word_in_grid(grid, word):
    grid_size = len(grid)
    word_length = len(word)
    placed = False

    while not placed:
        # Choose a random row and column such that the word fits
        start_row = random.randint(0, grid_size - 1)
        start_col = random.randint(0, grid_size - word_length)

        # Check if the space is free or matches the word to be placed
        if all(grid[start_row][start_col + i] == '.' for i in range(word_length)):
            # Place the word in the grid
            for i in range(word_length):
                grid[start_row][start_col + i] = word[i]
            placed = True
    return (start_row, start_col)  # Return the position where the word was placed

def create_grid(size):
    # Create a grid filled with '.' as placeholders
    return [['.' for _ in range(size)] for _ in range(size)]

def fill_grid_with_random_letters(grid):
    # Fill remaining spaces with random letters
    alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    for row_index, row in enumerate(grid):
        for col_index, item in enumerate(row):
            if item == '.':
                grid[row_index][col_index] = random.choice(alphabet)

def write_grid_to_file(grid, filename):
    # Write the grid to a text file
    with open(filename, 'w') as file:
        for row in grid:
            file.write(''.join(row) + '\n')

def write_words_to_file(words, filename):
    # Write the list of words to a text file
    with open(filename, 'w') as file:
        for word in words:
            file.write(word + '\n')

def main():
    grid_size = 60
    words = ["DEVELOPERS", "VACATIONS", "ESSENTIALS", "PROJECTS", "SKILLS", 
             "PRACTICE", "ENGINEERING", "SUNNY", "NETWORKING", "REFLECTIONS", 
             "EVOLUTION", "VISITORS", "ERGONOMICS", "SOFTWARE"]
    grid = create_grid(grid_size)
    words_placed = []

    # Randomly decide to include each word 0, 1, or 2 times
    for word in words:
        num_occurrences = random.randint(0, 2)  # 0, 1, or 2 times
        for _ in range(num_occurrences):
            placement = place_word_in_grid(grid, word)
            words_placed.append(f"{word} (Starts at row {placement[0]}, col {placement[1]})")

    fill_grid_with_random_letters(grid)
    write_grid_to_file(grid, 'new-puzzle.txt')
    write_words_to_file(words_placed, 'new-words.txt')

if __name__ == '__main__':
    main()
