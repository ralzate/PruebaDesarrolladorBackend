require 'spec_helper'

describe Games::HangmanApi do
  let :hangman do
    Games::Hangman.create(word: word)
  end

  let :word do
    Games::Word.create(c: "this is a test", h: "")
  end

  describe ':init' do
    before(:each) do
      hangman
    end

    it do
      get '/hangman/yo'
      expect(last_response).to be_ok
      body = Oj.load(last_response.body)
      expect(body[:attempts]).to eq([])
    end
  end

  describe ':try' do
    before(:each) do
      hangman
      get '/hangman/yo'
    end

    it do
      get '/hangman/yo/try/t'
      expect(last_response).to be_ok

      body = Oj.load(last_response.body)
      expect(body[:attempts]).to eq(['t'])
    end
  end
end
