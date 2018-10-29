# frozen_string_literal: true

require_relative 'colors'

module SinatraMind
  class Game
    MAX_GUESSES = 12
    KEY = Colors::COLORS

    attr_reader :player, :num_guesses, :secret_code,
                :board, :colors, :win, :loss

    def initialize
      reset
    end

    def reset
      @player = add_player
      @board = Board.new
      @num_guesses = 0
      @secret_code = random_code
      @win = false
      @loss = false
    end

    # For web browsing
    def take_turn(input:)
      input = @player.good_input?(input: input)
      return :bad_input if input == false

      correct_guess?(input: input, web: true)
      return game_over? if game_over?

      @board.update_guesses(input: input, row: @num_guesses)
      hints_ary = hints_input(ary: input)
      @board.update_hints(input: hints_ary, row: @num_guesses)

      @num_guesses += 1
    end

    def guesses_to_s
      guesses.map do |ary|
        ary.map { |cell| cell.value.to_s }
      end
    end

    def guesses
      @board.board[:guesses]
    end

    def hints
      @board.board[:hints]
    end

    def hints_to_s
      hints.map do |ary|
        ary.map { |cell| cell.value.to_s }
      end
    end

    # for CLI
    def play
      loop do
        # @board.print_board
        # p KEY
        # puts format_s_code
        # p @board
        input = @player.get_input

        take_turn(input: input)
      end
    end

    def game_over?
      return :win if win?
      return :loss if loss?

      false
    end

    def format_s_code
      @secret_code.map(&:to_s).join(', ')
    end

    def key_to_s
      KEY.clone
    end

    def win_message
      'Congratulations! You have won! You guessed the secret code correctly.
      The code was: '
    end

    def loss_message
      'You have lost! The code was:'
    end

    def reset_message
      'The game will reset with your next guess!'
    end

    def bad_input_message
      'Please provide a 4 digit input with numbers 1-6'
    end

    def hints_input(ary:, secret_code: @secret_code)
      ary = convert_to_syms(ary: ary)
      secret_ary = secret_code.clone
      hints = []
      indexes = []

      4.times do |index|
        if ary[index] == secret_code[index]
          hints << 2
          indexes << index
          p index
        end
      end

      indexes.reverse.each do |idx|
        secret_ary.delete_at(idx)
        ary.delete_at(idx)
      end

      ary.each do |guess|
        secret_ary.each_with_index do |code, idx|
          hints << 1 if code == guess
          secret_ary.delete_at(idx)
        end
      end
      p secret_ary
      p ary

      hints << 0 until hints.size >= 4
      hints
    end

    def s_count_hash(s_code:)
      secret_count = Hash.new(0)
      s_code.each { |v| secret_count[v] += 1 }
      secret_count
    end

    def win?
      return true if @win == true

      false
    end

    def loss?
      return @loss = true if @num_guesses >= MAX_GUESSES

      false
    end

    private

    def random_code
      Array.new(4) { KEY[KEY.keys.sample] }
    end

    def correct_guess?(input:, web: false)
      input = @player.get_input(input: input) if web == false
      input = @player.good_input?(input: input) if web == true

      return false if input == false
      return @win = true if convert_to_syms(ary: input) == @secret_code

      false
    end

    def convert_to_syms(ary:)
      ary.map { |num| KEY[num] }
    end

    def add_player
      Player.new
    end
  end
end
