require 'open-uri'

class GamesController < ApplicationController
  def new
    @grid = generate_grid(10)
  end

  def score
    @grid = params[:grid].split
    @word = params[:word]
    @game_info = get_game_info(get_word_api(@word), @grid)
    if session[:score].nil?
      session[:score] = @game_info[:score]
    else
      session[:score] += @game_info[:score]
    end
  end

  private

  ALPHABET = ('a'..'z').to_a

  def generate_grid(grid_size)
    result = []
    (0...grid_size).each { result << ALPHABET.sample }
    return result
  end

  def get_word_api(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    JSON.parse(URI(url).read)
  end

  def valid_grid?(word, grid)
    return false if word.size > grid.size || !grid.all? { |letter| word.count(letter) <= grid.count(letter) }
    word.each_char { |letter| return false if grid.count(letter).zero? }
    true
  end

  def check_word(word, grid)
    game_info = {}
    message = "Sorry but #{word['word'].upcase} does not seem to be a valid English word..."
    game_info[:message] = message if word['found'] == false
    message = "Sorry but #{word['word'].upcase} can't be built out of #{grid.join(', ').upcase}"
    game_info[:message] = message unless valid_grid?(word['word'], grid)
    return game_info
  end

  def get_game_info(word_info, grid)
    game_info = check_word(word_info, grid)
    game_info[:score] = 0
    return game_info if game_info.key?(:message)
    game_info[:score] = word_info['word'].size
    game_info[:message] = "<strong>Congratulations!</strong> #{word_info['word'].upcase} is a valid English word!"
    return game_info
  end
end
