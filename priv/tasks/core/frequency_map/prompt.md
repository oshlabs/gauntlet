Write a module `FrequencyMap` with a function `words/1` that takes a string and returns a map from each word to its number of occurrences.

Rules:

- Words are compared case-insensitively (downcase them in the result).
- A word is a maximal run of Unicode letters, digits, or apostrophes (`'`). Everything else separates words.
- Apostrophes only count inside a word (`don't` is one word); a leading or trailing apostrophe is not part of the word.
- The empty string returns an empty map.

Examples:

    FrequencyMap.words("The quick brown fox, the LAZY dog.")
    #=> %{"the" => 2, "quick" => 1, "brown" => 1, "fox" => 1, "lazy" => 1, "dog" => 1}

    FrequencyMap.words("'Don't stop', she said - don't!")
    #=> %{"don't" => 2, "stop" => 1, "she" => 1, "said" => 1}
