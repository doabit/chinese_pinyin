# -*- encoding : utf-8 -*-
$KCODE = 'u' if RUBY_VERSION !~ /1\.9/

class Pinyin

  class <<self
    attr_accessor :table

    def init_table
      return if @table
      @table = {}
      open(File.dirname(__FILE__) + '/../data/Mandarin.dat') do |file|
        while line = file.gets
          key, value = line.split(' ', 2)
          @table[key] = value
        end
      end
    end

    def init_word_table
      return if @words_table
      @words_table = {}
      if ENV["WORDS_FILE"]
        open(ENV["WORDS_FILE"]) do |file|
          while line = file.gets
            key, value = line.sub("\n", "").split('|', 2)
            @words_table[key] = value
          end
        end
      end
    end

    def translate(chars, splitter = ' ', only_first_char = false)
      init_word_table
      return @words_table[chars].gsub(' ', splitter) if @words_table[chars]

      init_table
      results = []
      is_english = false
      chars.scan(/./).each do |char|
        key = sprintf("%X", char.unpack("U").first)
        if @table[key]
          results << splitter if is_english
          if only_first_char
            results << @table[key].chomp.split(' ', 2)[0].slice(0).downcase
          else
            results << @table[key].chomp.split(' ', 2)[0].slice(0..-2).downcase
          end
          results << splitter
          is_english = false
        else
          results <<  char if char != ' '
          is_english = true
        end
      end
      results.join('').chomp(splitter)
    end

    alias_method :t, :translate
  end
end
