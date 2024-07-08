#!/usr/bin/env perl

use strict;
use warnings;

BEGIN {
    use File::Basename;
    use Cwd 'abs_path';
    my $script_dir = dirname(abs_path($0));
    unshift @INC, $script_dir;
}

use File::Spec;
use Parser;

my $script_dir = ( File::Spec->splitpath( $0 ) )[1];
my $dictionary_file = File::Spec->catfile( $script_dir, '..', 'dictionary.txt' );

my $parser = Parser->new(dictionary_file => $dictionary_file);
$parser->parse_dictionary();
