# frozen_string_literal: true

require 'open-uri'
require 'json'
# GamesControler class to manage requests
class GamesController < ApplicationController
  def new
    @letters = []
    10.times { @letters << ('A'..'Z').to_a.sample }
    @letters
  end

  def score
    letters = params[:letters].split(',').map { |letter| letter.gsub(/\W/, '') }
    guess = params[:guess].upcase.split('')
    guess.each do |letter|
      return @message = "The word can't be built out of the original grid" unless letters.include?(letter.upcase)
    end
    return @message = "The word #{guess.join} can't be built out of the original grid" unless check_grid(guess, letters)
    return @message = "The word #{guess.join} is valid according to the grid, but is not a valid English word" unless check_word(params[:guess])
    session[:score].present? ? session[:score] += guess.length.to_i : session[:score] = guess.length.to_i
    return @message = "The word is valid"
  end

  def check_word(word)
    url = "https://wagon-dictionary.herokuapp.com/#{word}"
    api_response = open(url).read
    word = JSON.parse(api_response)
    word['found']
  end

  def check_grid(word_file, grid)
    # check if the word matches the check_grid
    word_file.each do |char|
      return false unless grid.include?(char)

      # delete chars already checked
      grid.delete_at(grid.index(char))
    end
    true
  end
end
