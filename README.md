# BeQuick Coding Challenge

## Running tests and scripts
From the root folder, execute the command:

    ./runner.pl

This will run in order:
* Unit tests for the Perl script
* Unit tests for the Ruby script
* The Perl script
* The Ruby script

The runner script will produce output to STDOUT outlining unit test results, the amount of time it took for each script to run, and verification that the `sequences` and `words` files from both scripts match. Note that both scripts are configured to create `sequences` and `words` files in the same folder as the script.

## Rerunning tests and scripts
You can run the `./runner.pl` command as many times as you want and the `sequences` and `words` files will be regenerated each time.

## Notes
* In both versions of the script, I wrote two nearly identical subroutines for writing to the `sequences` and `words` files. I'm aware this architecture violates [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself), but in this case I think writing one subroutine to handle writing both files is a premature optimization. I generally only optimize abstrations for situations like this where 3 or more use cases are involved. There are only two files needing to be written here and it's unlikely that will ever change. If it ever did, I would refactor at that point.

* The Perl version of the script involves building up a hash of hashes where the key of each inner hash is a substring and the value is a hash containing the word from which the substring was extracted and an index to keep everything in order. Doing it this way forced me to come up with a way to keep multiple substrings within a word in the proper order, and my solution to that entailed creating fractional indexes.

    It could be argued that this wasn't a particularly elegant solution and I would tend to agree. An alternative approach would have been to push the inner hash value to an array and that would have preserved insertion order, but then you run into the problem of removing substrings that appear more than once in the dictionary. To manage that, every time you examine a new substring you would have to do something like:

    ```perl
    for my $substring_word (@substrings_words) {
        if ( exists $seen->{ lc $substring_word->{substring} } ) {
            @master = grep { $_->{substring} ne $seen->{ lc $substring_word->{substring} } } @master;
        } else {
            push @master, { substring => $substring_word->{substring}, word => $word };
            $seen->{ lc $substring_word->{substring} } = $substring_word->{substring};
        }
    }
    ```

    I didn't like this approach because that `grep` is expensive as it requires walking the entire array every time you want to insert a new substring. My method may be less elegant but it's almost certainly faster.
