#!/usr/bin/env perl

# Parse a dictionary file and write the sequences and words to files
#
# The program should generate two output files, "sequences" and "words".
# The sequences file should contain every unique sequence of four letters that are unique and appear in exactly one word of the dictionary file.
# Differences in casing should not reflect a unique sequence.
# Numbers and special characters should not create a unique sequence.
# The words file should contain the corresponding words that contain the sequence, in the same order, again one per line.

package Parser;

use strict;
use warnings;
use File::Spec;

sub new {
    my ( $class, %args ) = @_;
    my $self = {
        script_dir      => ( File::Spec->splitpath($0) )[1],
        dictionary_file => $args{dictionary_file},
    };
    bless $self, $class;
    return $self;
}

sub parse_dictionary {
    my $self = shift;
    my ( $master, $seen ) = {};
    my $index = 0;

    open my $dict_fh, '<', $self->{dictionary_file} or die "Could not open '$self->{dictionary_file}' $!";
    my @words = <$dict_fh>;
    close $dict_fh;

    for my $word (@words) {
        $index++;
        chomp($word);
        my @substrings_words = $self->get_substrings_words($word);
        next unless @substrings_words && keys %{ $substrings_words[0] };
        my $inner_index = 0;
        for my $substring_word (@substrings_words) {
            if ( exists $seen->{ lc $substring_word->{substring} } ) {
                delete $master->{ $seen->{ lc $substring_word->{substring} } };
            } else {
                $inner_index++;

                # These shenanigans with inner index / 1000 are to ensure that the order is maintained. A value of 10
                # would have been sufficient with this particular dictionary file, but 1000 covers all future cases.
                # This isn't necessary in the Ruby version because Ruby hashes preserve insertion order (since v1.9).
                $master->{ $substring_word->{substring} } = { index => $index + ( $inner_index / 1_000 ), word => $substring_word->{word} };
                $seen->{ lc $substring_word->{substring} } = $substring_word->{substring};
            }
        }
    }

    my @sorted_keys = sort { +$master->{$a}{index} <=> +$master->{$b}{index} } keys %$master;

    $self->write_sequences(@sorted_keys);
    $self->write_words( map { $master->{$_}{word} } @sorted_keys );
}

sub get_substrings_words {
    my ( $self, $word ) = @_;
    my @substrings_words = ();
    my $local_seen       = {};
    return @substrings_words unless length($word) > 3;
    for ( my $i = 0; $i < length($word) - 3; $i++ ) {
        my $substring = substr( $word, $i, 4 );
        next if $substring =~ /[^a-zA-Z]/;
        next if exists $local_seen->{ lc $substring };
        push @substrings_words, { substring => $substring, word => $word };
        $local_seen->{ lc $substring } = 1;
    }
    return @substrings_words;
}

sub write_sequences {
    my ( $self, @sequences ) = @_;
    my $sequences_file = File::Spec->catfile( $self->{script_dir}, 'sequences' );
    open( my $fh, ">", $sequences_file ) or die "Cannot open sequences file: $!";
    foreach my $seq (@sequences) {
        print $fh "$seq\n";
    }
    close($fh);
}

sub write_words {
    my ( $self, @words ) = @_;
    my $words_file = File::Spec->catfile( $self->{script_dir}, 'words' );
    open( my $fh, ">", $words_file ) or die "Cannot open words file: $!";
    foreach my $word (@words) {
        print $fh "$word\n";
    }
    close($fh);
}

1;
