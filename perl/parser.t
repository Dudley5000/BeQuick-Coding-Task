#!/usr/bin/env perl

use strict;
use warnings;

BEGIN {
    use File::Basename;
    use Cwd 'abs_path';
    my $script_dir = dirname(abs_path($0));
    unshift @INC, $script_dir;
}

use Test::More tests => 5;
use File::Spec;
use File::Temp qw(tempfile tempdir);
use File::Basename qw(dirname);
use Parser;

# Define the file paths relative to the script directory
my $script_dir = dirname(abs_path($0));

# Define file paths for testing in the script directory
my $dictionary_file = File::Spec->catfile( $script_dir, 'test_dictionary.txt' );
my $sequences_file  = File::Spec->catfile( $script_dir, 'sequences' );
my $words_file      = File::Spec->catfile( $script_dir, 'words' );

# Define a mock dictionary file content
my $dictionary_content = <<'END_DICTIONARY';
10th
1st
2nd
3rd
4th
5th
6th
7th
8th
9th
a
AAA
AAAS
Aarhus
Aaron
END_DICTIONARY

# Write the mock dictionary file
open my $fh, '>', $dictionary_file or die "Could not open '$dictionary_file': $!";
print $fh $dictionary_content;
close $fh;

# Create Parser object and run the parse_dictionary method
my $parser = Parser->new(dictionary_file => $dictionary_file);
$parser->parse_dictionary();

# Test that the sequences file is created and has the expected content
open $fh, '<', $sequences_file or die "Could not open '$sequences_file': $!";
my @sequences = <$fh>;
close $fh;
chomp @sequences;
is_deeply( \@sequences, [qw(AAAS Aarh arhu rhus Aaro aron)], 'Sequences file content' );

# Test that the words file is created and has the expected content
open $fh, '<', $words_file or die "Could not open '$words_file': $!";
my @words = <$fh>;
close $fh;
chomp @words;
is_deeply( \@words, [qw(AAAS Aarhus Aarhus Aarhus Aaron Aaron)], 'Words file content' );

# Test get_substrings_words function
my @substrings_words = $parser->get_substrings_words('Testword');
is_deeply(
    \@substrings_words,
    [
        { substring => 'Test', word => 'Testword' },
        { substring => 'estw', word => 'Testword' },
        { substring => 'stwo', word => 'Testword' },
        { substring => 'twor', word => 'Testword' },
        { substring => 'word', word => 'Testword' },
    ],
    'get_substrings_words function'
);

# Test that non-alphabetic characters are ignored
@substrings_words = $parser->get_substrings_words('Te$t1234');

is_deeply( \@substrings_words, [], 'Non-alphabetic characters are ignored' );

# Test that short words are ignored
@substrings_words = $parser->get_substrings_words('Tes');

is_deeply( \@substrings_words, [], 'Short words are ignored' );

done_testing();

# Cleanup test files
END {
    unlink $dictionary_file, $sequences_file, $words_file;
}
