# I'm assuming everyone is using at least Ruby 1.9 which includes minitest/autorun

require 'minitest/autorun'
require_relative 'parser'

class ParserTest < Minitest::Test
  def setup
    @script_dir = '/tmp'
    @dictionary_file = File.join(@script_dir, 'test_dictionary.txt')
    source_file = File.expand_path('../dictionary.txt', __dir__)
    destination_file = '/tmp/test_dictionary.txt'
    lines_to_copy = 15

    File.open(source_file, 'r') do |source|
      File.open(destination_file, 'w') do |destination|
        lines_to_copy.times do
          line = source.gets
          destination.puts line
        end
      end
    end
    @parser = Parser.new(@dictionary_file, @script_dir)
  end

  def teardown
    File.delete(@dictionary_file) if File.exist?(@dictionary_file)
    File.delete(File.join(@script_dir, 'sequences')) if File.exist?(File.join(@script_dir, 'sequences'))
    File.delete(File.join(@script_dir, 'words')) if File.exist?(File.join(@script_dir, 'words'))
  end

  def test_parse
    @parser.parse
    assert_equal({
                   'AAAS' => { word: 'AAAS' },
                   'Aarh' => { word: 'Aarhus' },
                   'arhu' => { word: 'Aarhus' },
                   'rhus' => { word: 'Aarhus' },
                   'Aaro' => { word: 'Aaron' },
                   'aron' => { word: 'Aaron' }
                 }, @parser.master)
  end

  def test_get_substrings_words
    result = @parser.get_substrings_words('testword')
    expected = { 'test' => 'testword', 'estw' => 'testword',
                 'stwo' => 'testword', 'twor' => 'testword',
                 'word' => 'testword' }
    assert_equal expected, result
  end

  def test_write_sequences
    sequences = %w[AAAS Aarh arhu rhus Aaro aron]
    @parser.write_sequences(sequences)
    written_sequences = File.read(File.join(@script_dir, 'sequences')).split('\n')
    expected = ["AAAS\nAarh\narhu\nrhus\nAaro\naron\n"]
    assert_equal expected, written_sequences
  end

  def test_write_words
    words = %w[AAAS Aarhus Aaron]
    @parser.write_words(words)
    written_words = File.read(File.join(@script_dir, 'words')).split('\n')
    expected = ["AAAS\nAarhus\nAaron\n"]
    assert_equal expected, written_words
  end
end
