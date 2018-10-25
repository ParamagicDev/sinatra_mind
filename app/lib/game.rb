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
      return true if game_over?

      @board.update_guesses(input: input, row: @num_guesses)
      hints_ary = hints_input(ary: input)
      @board.update_hints(input: hints_ary, row: @num_guesses)

      @num_guesses += 1
    end

    def guesses
      @board.guesses
    end

    def hints
      @board.hints
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
      return true if win?
      return true if loss?

      false
    end

    def format_s_code
      @secret_code.map(&:to_s).join(', ')
    end

    def key_to_s
      f_string = ''
      KEY.each do |num, color|
        f_string += "#{num} = #{color}, " unless num >= KEY.size
        f_string += "#{num} = #{color}" if num == KEY.size
      end
      f_string
    end

    def win_message
      "Congratulations! You have won! You guessed the secret_code correctly\n
      The correct code was #{format_s_code}"
    end

    def loss_message
      "You have lost, the correct code was #{format_s_code}"
    end

    def bad_input_message
      'Please provide a 4 digit input with numbers 1-6'
    end

    def hints_input(ary:, secret_code: @secret_code)
      ary = convert_to_syms(ary: ary)
      hints = []

      secret_count = s_count_hash(s_code: secret_code)
      hint_count = Hash.new(0)

      4.times do |index|
        hint_count[ary[index]] += 1

        hints << if ary[index] == secret_code[index]
                   2
                 elsif secret_code.include?(ary[index])
                   if hint_count[ary[index]] <= secret_count[secret_code[index]]
                     1
                   else
                     0
                   end
                 else
                   0
                 end
      end

      hints
    end

    def s_count_hash(s_code:)
      secret_count = Hash.new(0)
      s_code.each { |v| secret_count[v] += 1 }
      secret_count
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

    def win?
      return true if @win == true

      false
    end

    def loss?
      return @loss = true if @num_guesses > MAX_GUESSES

      false
    end

    def add_player
      Player.new
    end
  end
end
