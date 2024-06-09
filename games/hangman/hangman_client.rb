require 'net/http'
require 'oj'
require 'uri'

class HangmanClient
  def initialize(base_url, player_id)
    @base_url = base_url
    @player_id = player_id
  end

  def start_game
    uri = URI("#{@base_url}/hangman/#{@player_id}")
    response = Net::HTTP.get(uri)
    parse_response(response)
  end

  def make_guess(letter)
    uri = URI("#{@base_url}/hangman/#{@player_id}/try/#{letter}")
    response = Net::HTTP.get(uri)
    parse_response(response)
  end

  private

  def parse_response(response)
    Oj.load(response)
  end
end

def main
  base_url = 'http://localhost:4567'
  puts 'Welcome to Hangman!'
  print 'Enter your player ID: '
  player_id = gets.chomp

  client = HangmanClient.new(base_url, player_id)
  game_data = client.start_game

  while game_data['state'] == 'playing'
    puts "\nWord: #{game_data['word']}"
    puts "Hint: #{game_data['hint']}" if game_data['hint']
    puts "Attempts: #{game_data['attempts'].join(', ')}"
    puts "Chances left: #{game_data['chances']}"
    puts "Failures: #{game_data['failures']}"

    print 'Enter a letter to guess: '
    letter = gets.chomp
    game_data = client.make_guess(letter)

    if game_data['state'] == 'win'
      puts "\nCongratulations! You won!"
      break
    elsif game_data['state'] == 'lose'
      puts "\nSorry, you lost. The word was: #{game_data['word']}"
      break
    end
  end

  puts "\nThanks for playing!"
end

main