#!/usr/bin/env ruby

# Parse a dictionary file and write the sequences and words to files
#
# The program should generate two output files, "sequences" and "words".
# The sequences file should contain every unique sequence of four letters that are unique and appear in exactly one word of the dictionary file.
# Differences in casing should not reflect a unique sequence.
# Numbers and special characters should not create a unique sequence.
# The words file should contain the corresponding words that contain the sequence, in the same order, again one per line.

class Parser
  attr_reader :master

  def initialize(dictionary_file, script_dir)
    @dictionary_file = dictionary_file
    @script_dir = script_dir
    @master = {}
    @seen = {}
  end

  def parse
    # Reset in case of previous calls
    @master = {}
    @seen = {}

    File.readlines(@dictionary_file).each do |word|
      word.chomp!
      substrings_words = get_substrings_words(word)
      next if substrings_words.empty?

      substrings_words.each_key do |key|
        if @seen.key?(key.downcase)
          @master.delete(@seen[key.downcase])
        else
          @master[key] = { word: substrings_words[key] }
          @seen[key.downcase] = key
        end
      end
    end

    write_sequences(@master.keys)
    write_words(@master.keys.map { |key| @master[key][:word] })
  end

  def get_substrings_words(word)
    substrings_words = {}
    local_seen = {}
    return {} unless word.length > 3

    (0..word.length - 4).each do |i|
      substring = word[i, 4]
      next if substring.match?(/[^a-zA-Z]/)
      next if local_seen.key?(substring.downcase)

      substrings_words[substring] = word
      local_seen[substring.downcase] = true
    end

    substrings_words
  end

  def write_sequences(sequences)
    File.open(File.join(@script_dir, 'sequences'), 'w') do |file|
      sequences.each { |seq| file.puts(seq) }
    end
  end

  def write_words(words)
    File.open(File.join(@script_dir, 'words'), 'w') do |file|
      words.each { |word| file.puts(word) }
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  script_dir = __dir__
  dictionary_file = File.expand_path('../dictionary.txt', script_dir)
  parser = Parser.new(dictionary_file, script_dir)
  parser.parse
end
