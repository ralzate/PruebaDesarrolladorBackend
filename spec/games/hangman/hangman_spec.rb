require 'spec_helper'

describe Games::Hangman do
  let :hangman do
    Games::Hangman.create(word: word)
  end

  let :word do
    Games::Word.create(c: "this is a test", h: "")
  end

  describe "#word=" do
    it do
      expect(hangman.w).to eq("this is a test")
      expect(hangman.c).to eq("____ __ _ ____")
      expect(hangman.h).to eq("")
    end
  end

  describe "#win?" do
    it do
      expect(hangman.win?).to eq(false)
      hangman.w.split('').uniq.each do |ch|
        hangman.try(ch)
      end

      expect(hangman.win?).to eq(true)
    end
  end

  describe "#try" do
    it do
      expect(hangman.try("t")).to eq(true)
      expect(hangman.try("z")).to eq(false)

      expect(hangman.f).to eq(1)
      expect(hangman.a).to eq(%w(t z))
    end
  end
end
