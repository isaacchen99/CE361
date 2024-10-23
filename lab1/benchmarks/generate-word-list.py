import random
import string

def generate_random_words(num_words, min_length=3, max_length=10):
    words = set()  # Using a set to avoid duplicates

    while len(words) < num_words:
        word_length = random.randint(min_length, max_length)
        word = ''.join(random.choices(string.ascii_uppercase, k=word_length))
        words.add(word)

    return list(words)

def write_words_to_file(words, filename):
    with open(filename, 'w') as file:
        for word in words:
            file.write(word + '\n')

def main():
    num_words = 10
    random_words = generate_random_words(num_words)
    write_words_to_file(random_words, 'random-words.txt')
    print(f"Generated {num_words} random words and saved to 'random-words.txt'.")

if __name__ == '__main__':
    main()
