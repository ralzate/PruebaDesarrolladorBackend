module Games
  class Hangman
    include Mongoid::Document

    field :w, type: String # word
    field :h, type: String # hint
    field :c, type: String # current
    field :a, type: Array, default: [] # attempts
    field :pid, type: String # :participation_id
    field :f, type: Integer, default: 0 # :failures

    index({ pid: 1 }, unique: true)

    def word=(word)
      self[:w] = word.c
      self[:c] = word.c.gsub(/\S/, '_')
      self[:h] = word.h
      self[:a] = []
      self[:f] = 0
    end

    def win?
      self[:w] == self[:c]
    end

    def state
      if win?
        return 'win'
      elsif f >= 8
        return 'lose'
      end
      'playing'
    end

    def start
      self.word = Word.random
    end

    def try(letter)
      letter = ActiveSupport::Inflector.transliterate(letter.downcase)
      return false if a.include? letter
      new_word = c.dup
      ok = check(letter, new_word)

      self.c = new_word

      a << letter
      self.f += 1 unless ok
      save
      ok
    end

    def should_provide_hint?
      self.f >= 3
    end

    private

    def check(letter, new_word)
      ok = false
      index = 0
      ActiveSupport::Inflector.transliterate(w.downcase).each_char do |l|
        if l == letter
          ok = true
          new_word[index] = w[index]
        end
        index += 1
      end
      ok
    end
  end
end
