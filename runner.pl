#!/usr/bin/env perl

# Run the scripts and test cases
use strict;
use warnings;
use Time::HiRes qw(gettimeofday tv_interval);

use feature 'say';

# Remove files from previous run
unlink 'perl/words', 'perl/sequences', 'ruby/words', 'ruby/sequences';

# Run the Perl test cases
say "-" x 20 . "\n" . "Running Perl test cases" . "\n" . "-" x 20;
my $res = system('./perl/parser.t');
if ( $res != 0 ) {
    say "Error: $res";
    exit 1;
} else {
    say "All Perl test cases passed\n";
}

# Run the Ruby test cases
say "-" x 20 . "\n" . "Running Ruby test cases" . "\n" . "-" x 20;
$res = system('ruby ./ruby/parser_tests.rb');
if ( $res != 0 ) {
    say "Error: $res";
    exit 1;
} else {
    say "All Ruby test cases passed\n";
}

say "-" x 20 . "\n" . "Running the scripts" . "\n" . "-" x 20;

# Run the Perl script
my $start = [gettimeofday];
$res = system('./perl/parser.pl');
if ( $res != 0 ) {
    say "Error: $res";
    exit 1;
}
my $end = [gettimeofday];
say "Perl script time taken: ", tv_interval( $start, $end ) * 1_000, ' ms';

# Run the Ruby script
$start = [gettimeofday];
$res   = system('./ruby/parser.rb');
if ( $res != 0 ) {
    say "Error: $res";
    exit 1;
}
$end = [gettimeofday];
say "Ruby script time taken: ", tv_interval( $start, $end ) * 1_000, ' ms';

# Verify the sequences and words files are identical in both versions
say "\n" . "-" x 20 . "\n" . "Verifying the output files" . "\n" . "-" x 20;
$res = system('diff perl/words ruby/words');
if ( $res != 0 ) {
    say "Error: words files are not identical";
    exit 1;
} else {
    say "Words files are identical";
}

$res = system('diff perl/sequences ruby/sequences');
if ( $res != 0 ) {
    say "Error: sequences files are not identical";
    exit 1;
} else {
    say "Sequences files are identical";
}

say "\nHopefully, the fact that the generated files are identical means that the scripts both work correctly! 😬\n";
