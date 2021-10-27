requiredEntries = 5 # used to change how many word inputs the system is expecting. Minimum of 2
largestWord = None # stores the current most largest word that's been passed through input from the user
smallestWord = None # stores the current smallest word that's been passed through input from the user

# Checks to make sure requirements are met, takes in 4 words, each new word compares it's length to the current largest word
# as well as the current smallest word and replaces the value in-case it is better fit for the position.
# once finished, a detailed output is given.
if requiredEntries > 1:
    for i in range(requiredEntries):
        word = input("Please write down a word: ")
        wordLength = len(word)
        if not largestWord or wordLength > len(largestWord):
            largestWord = word
        if not smallestWord or wordLength < len(smallestWord):
            smallestWord = word

    print("After " + str(requiredEntries) + " entries, here are the results!")
    if largestWord:
        print("Your largest word was: " + largestWord + " with a length of " + str(len(largestWord)))
    if smallestWord:
        print("Your smallest word was: " + smallestWord + " with a length of " + str(len(smallestWord)))
    print("Note: If multiple words of the same length have been inserted, the word that was inserted first will be prioritized.")
else:
    print("Two or more entries are required for this program to run!")