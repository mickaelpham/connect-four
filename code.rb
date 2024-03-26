require 'minitest/autorun'

class Board
  MAX_ROWS = 6
  MAX_COLS = 7
  O_TOKEN = 'O'
  X_TOKEN = 'X'
  EMPTY_CELL = ' '

  def initialize
    @grid = Array.new(MAX_COLS).fill { [] }
    @current_player = O_TOKEN
    @game_ended = false
  end

  def game_ended?
    @game_ended
  end

  def show_grid
    rows = []

    (0...MAX_ROWS).each do |row_index|
      row = []

      (0...MAX_COLS).each do |col_index|
        row << elem_at(col_index, row_index)
      end

      rows << "|#{row.join('|')}|"
    end

    rows.reverse.join("\n")
  end

  def place_token(col_index)
    end_game! unless valid_column?(col_index)
    return if game_ended?

    @grid[col_index] << @current_player
    swap_players
    end_game! if connect_four?
  end

  private

  def elem_at(col_index, row_index)
    cell = @grid[col_index][row_index]
    cell.nil? ? EMPTY_CELL : cell
  end

  def end_game!
    @game_ended = true
  end

  def swap_players
    @current_player = @current_player == O_TOKEN ? X_TOKEN : O_TOKEN
  end

  def valid_column?(col_index)
    col_index >= 0 &&
      col_index < MAX_COLS &&
      @grid[col_index].size < MAX_ROWS
  end

  def connect_four?
    (cols + rows + diagonals).any? do |str|
      str =~ /#{O_TOKEN}{4}|#{X_TOKEN}{4}/
    end
  end

  def cols
    @grid.map { |col| col.join }
  end

  def rows
    rows = []

    (0...MAX_ROWS).each do |row_index|
      row = []

      (0...MAX_COLS).each do |col_index|
        row << elem_at(col_index, row_index)
      end

      rows << row.join
    end

    rows
  end

  def diagonals
    result = []

    # fixed row at 0, diagonals going up->right
    starting_row = 0
    (0...MAX_COLS).each do |starting_col|
      diagonal = ""
      row_index = starting_row
      col_index = starting_col

      while row_index < MAX_ROWS && col_index < MAX_COLS
        diagonal += elem_at(col_index, row_index)
        row_index += 1
        col_index += 1
      end

      result << diagonal
    end

    # fixed col at 0, diagonals going up->right
    starting_col = 0
    # starting from 1 because we already collected the diagonal at 0 above
    (1...MAX_ROWS).each do |starting_row|
      diagonal = ""
      row_index = starting_row
      col_index = starting_col

      while row_index < MAX_ROWS && col_index < MAX_COLS
        diagonal += elem_at(col_index, row_index)
        row_index += 1
        col_index += 1
      end

      result << diagonal
    end

    # fixed row at 0, diagonals going up->left
    starting_row = 0
    (0...MAX_COLS).each do |starting_col|
      diagonal = ""
      row_index = starting_row
      col_index = starting_col

      while row_index < MAX_ROWS && col_index >= 0
        diagonal += elem_at(col_index, row_index)
        row_index += 1
        col_index -= 1
      end

      result << diagonal
    end

    # fixed col at MAX_COLS - 1, diagonals going up->left
    starting_col = MAX_COLS - 1
    # starting from 1 because we already collected the diagonal at 0 above
    (1...MAX_ROWS).each do |starting_row|
      diagonal = ""
      row_index = starting_row
      col_index = starting_col

      while row_index < MAX_ROWS && col_index >= 0
        diagonal += elem_at(col_index, row_index)
        row_index += 1
        col_index -= 1
      end

      result << diagonal
    end

    result
  end
end

class BoardTest < Minitest::Test
  def setup
    @board = Board.new
  end

  def test_it_prints_empty_grid
    expected = <<~GRID.chomp
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
    GRID

    assert_equal expected, @board.show_grid
  end

  def test_place_one_token
    expected = <<~GRID.chomp
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      | | | |O| | | |
    GRID

    @board.place_token(3)
    assert_equal expected, @board.show_grid
  end

  def test_place_three_tokens_alternating_players
    expected = <<~GRID.chomp
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      | | | |O| | | |
      | | | |X| | | |
      | | | |O| | | |
    GRID

    3.times { @board.place_token(3) }
    assert_equal expected, @board.show_grid
  end

  def test_cannot_place_more_tokens_than_max_rows
    expected = <<~GRID.chomp
      | | | |X| | | |
      | | | |O| | | |
      | | | |X| | | |
      | | | |O| | | |
      | | | |X| | | |
      | | | |O| | | |
    GRID

    (Board::MAX_ROWS + 1).times { @board.place_token(3) }
    assert_equal expected, @board.show_grid
    assert @board.game_ended?, 'game must end after invalid move'
  end

  def test_cannot_place_token_out_of_grid
    expected = <<~GRID.chomp
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
    GRID

    @board.place_token(-1)
    assert_equal expected, @board.show_grid
    assert @board.game_ended?, 'game must end after invalid move'
  end

  def test_connect_four_in_col
    expected = <<~GRID.chomp
      | | | | | | | |
      | | | | | | | |
      | | | |O| | | |
      | | |X|O| | | |
      | | |X|O| | | |
      | | |X|O| | | |
    GRID

    input = [3, 2, 3, 2, 3, 2, 3, 2]
    input.each { |col_index| @board.place_token(col_index) }

    assert_equal expected, @board.show_grid
    assert @board.game_ended?, 'game must end after connect four'
  end

  def test_connect_four_in_row
    expected = <<~GRID.chomp
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      | | | | | | | |
      |X|X|X| | | | |
      |O|O|O|O| | | |
    GRID

    input = [0, 0, 1, 1, 2, 2, 3, 3]
    input.each { |col_index| @board.place_token(col_index) }

    assert_equal expected, @board.show_grid
    assert @board.game_ended?, 'game must end after connect four'
  end

  def test_connect_four_in_diagonal_up_right
    expected = <<~GRID.chomp
      | | | | | | | |
      | | | | | | | |
      | | | |O| | | |
      | | |O|X| | | |
      |X|O|X|O| | | |
      |O|X|O|X| | | |
    GRID

    input = [0, 1, 1, 0, 2, 2, 2, 3, 3, 3, 3]
    input.each { |col_index| @board.place_token(col_index) }

    assert_equal expected, @board.show_grid
    assert @board.game_ended?, 'game must end after connect four'
  end

  def test_connect_four_in_diagonal_up_left
    expected = <<~GRID.chomp
      | | | | | | | |
      | | | | | | | |
      | | | |X| | | |
      | | | |O|X| |O|
      | | | |X|O|X|O|
      | | | |O|X|O|X|
    GRID

    input = [5, 6, 6, 5, 3, 3, 3, 3, 6, 4, 4, 4]
    input.each { |col_index| @board.place_token(col_index) }

    assert_equal expected, @board.show_grid
    assert @board.game_ended?, 'game must end after connect four'
  end
end
