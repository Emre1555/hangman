require 'yaml'

class Game
  attr_reader :the_word, :guessed_chr, :displayed_word, :turns_left, :displayed_word_arr, :the_word_arr
  
  def initialize(the_word=0, guessed_chr=0, displayed_word=0)
    @the_word = the_word
    @guessed_chr= guessed_chr
    @displayed_word = displayed_word
    @displayed_word_arr = displayed_word_arr
    @turns_left = turns_left

  end

  def start
    # new game load dic
    dictionary = File.open('5desk.txt')
    @arr = dictionary.map do |line|
      line.split(' ')
    end
    dictionary.close
    loop do
      sampling
      break if sampling_cond_met?
    end
    @displayed_word_arr = Array.new(@the_word.length, '_')
    @turns_left = 8
    @guessed_chr = []

    # p @the_word
    turns
    display
    # load a saved game
  end

  def sampling
    @sample_word = @arr.sample[0]
    secret_word(@sample_word)
  end

  def sampling_cond_met?
    @sample_word.length > 4 && @sample_word.length < 13
  end

  def secret_word(word)
    @the_word = word.downcase
  end

  def display
    # show _ for each word in the screen
    @displayed_word = @displayed_word_arr.join(' ').to_s
    p @displayed_word
    # show the guesses left
    p 'Turns left:' + @turns_left.to_s
    # show the guessed letters
    p 'Guessed characters:'
    p @guessed_chr
  end

  def win_condition?
    p 'you won!' if @displayed_word_arr == @the_word_arr
  end

  def turns
    # turn based letter guess
    display
    until @turns_left.zero?
      guessing
      display
      @turns_left -= 1
      win_condition?
    end
    p 'You Lost!'
    p "the word was #{@the_word}"
    # option to save the game
    # serialize the whole game class if so
  end

  def guessing
    p 'type a letter to guess and <save> to save your progress'
    guess = gets.chomp
    if guess == 'save'
      save_it
    elsif guess.length == 1
      @guessed_chr.push(guess) unless @guessed_chr.include?(guess)
    else
      guessing
    end

    # actual guessing part
    if @the_word.include?(guess)
      @the_word_arr = @the_word.split('')
      @the_word_arr.each_with_index do |val, index|
        @displayed_word_arr[index] = guess if val == guess
      end
      @turns_left += 1 if @turns_left < 7
    end
  end

  def save_it
    output = File.new("saved.yml", "w")
    output.puts YAML.dump(self)
    output.close
    puts "You've successfully saved your game. Goodbye"
    exit
  end

  def load_it
    load_game = File.open("saved.yml", "r")
    data = YAML.load(load_game)   
    @the_word = data.the_word
    @displayed_word = data.displayed_word
    @displayed_word_arr = data.displayed_word_arr
    @turns_left = data.turns_left
    @guessed_chr = data.guessed_chr
    @the_word_arr = data.the_word_arr
    turns
    
    p "game loaded"
    
  
  end
end

game = Game.new
p 'type <newgame> for a new game and <loadgame> to load the saved game'
answer = gets.strip
game.start if answer == 'newgame'
return game.load_it if answer == 'loadgame'
