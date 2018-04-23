# @name    Checkers
# @author  Rony Xavier
# @version 1.0, 04/23/2018

# require 'colorize'
require 'set'
require_relative 'Board'

#======================================= CONSTANTS =======================================#

VERBOSE  = false

# Span of the board on the GUI window
BOARD_SQUARE_POS = {board_start: 10, board_end:610 }

# Initial piece position on the board
INITIAL_BOARD = [
        [ 0, 1, 0, 1, 0, 1],
        [ 1, 0, 1, 0, 1, 0],
        [ 0, 0, 0, 0, 0, 0],
        [ 0, 0, 0, 0, 0, 0],
        [ 0,-1, 0,-1, 0,-1],
        [-1, 0,-1, 0,-1, 0]
        ] 

# Size of a single box on the GUI board
BLOCK_DIMENTION = 100

# Height and width of of the GUI board
CHECKERS_WIDTH = 6
CHECKERS_HEIGHT = 6

CPU_PLAYER = 'white'
HUMAN_PLAYER = 'black'

# MAX and MIN Terminal values
MAX_TERMINAL_VAL = 1000
MIN_TERMINAL_VAL = -1000

# Specify levels of difficulty
DIFFICULTY = {
  'EASY' => 1,
  'MEDIUM' => 7,
  'HARD' => 14,
}


#======================================= HELPER METHODS =======================================#

  def other_player(player)
    player.eql?('white') ? 'black' :  'white'
  end

  def max(*params)
    params.max
  end

  def min(*params)
    params.min
  end

  # pretty print the board for debug
  def print_board(board)
    p "--------------------------------------------------------------------------------------------------------------"
    count = 0
    puts  " | 0  1  2  3  4  5"
    # puts  "___________________"
    board.each do |line|
      print "#{count}|"
      line.each do |x|
        if x.nil?
          print ' 0 '.colorize(:blue)
        else
          print " #{x.color[0]} ".colorize(:yellow) if x.color == 'white'
          print " #{x.color[0]} ".colorize(:red) if x.color == 'black'
        end
      end
      print "|#{count}"
      count += 1
      puts ""

    end
    puts  " | 0  1  2  3  4  5"
    p "--------------------------------------------------------------------------------------------------------------"
  end

#======================================= CHECKERS CLASS =======================================#

class Checkers
  attr_reader :board, :turn, :chosen_move, :max_nodes, :max_depth, :time_taken, :max_prunes, :min_prunes

  def initialize(turn,board,player,difficulty)
    @board = board
    @score = { "black" => 0, "white" => 0 }
    @available_moves = []
    @difficulty = difficulty
    @player = player
    @turn = turn
    @max_depth = 0
    @max_nodes = 0
    @min_prunes = 0
    @max_prunes = 0
    @time_taken = 0
    @ab_moves = {}
  end

  # get current game score
  def score(player)
    @score[player]
  end

  # return true of either of the player lost all pieces OR if BOTH players does not have any moves left
  def game_over?
      @board.pieces['black'].empty? || @board.pieces['white'].empty? || (@board.moves(HUMAN_PLAYER).empty? && @board.moves(CPU_PLAYER).empty?)
  end

  # switch player turn
  def switch_turn
    @turn = other_player(@turn)
  end

  # check if any moves are available for the player
  def moves_available?(player)
    !@board.moves(player).empty?
  end

  def cpu_move 
    # reset stat counters
    @max_depth = 0
    @max_nodes = 1
    @min_prunes = 0
    @max_prunes = 0
    @ab_moves = {}

    # start the clock and run alpha beta search
    start_t = Time.now
    value = alpha_beta_search(@player)
    @time_taken = Time.now - start_t

    # choose a the first move from the moves that match the value returned from the alpha_beta_search
    @chosen_move = @ab_moves[value].to_a.first#sample

    # perform the move on the board
    @board.move([@chosen_move[0],@chosen_move[1]],[@chosen_move[2],@chosen_move[3]])
    # increment CPU player score if it is a capture move
    @score[@player] += 1 if (chosen_move[2] - chosen_move[0]).abs == 2
  end

  # execute Human player move if the move is available to the player and return success or failure
  def user_move(org,dest)
    if @board.moves(HUMAN_PLAYER).include?([org[0],org[1],dest[0],dest[1]])
      @board.move(org,dest) 
      # increment human player score if capture move
      @score[HUMAN_PLAYER] += 1 if (dest[0] - org[0]).abs == 2
      true
    else
      false
    end
  end

  # create node and increment node created counter
  def clone_board(board)
    log_nodes_count
    Marshal.load( Marshal.dump(board) )
  end

  # log maximum depth reached
  def log_depth(depth)
    @max_depth = max(@max_depth,depth)
  end

  # log number of nodes created
  def log_nodes_count
    @max_nodes += 1
  end

  # log number of max prunes during alpha_beta_search
  def log_max_prune_count
    @max_prunes += 1
  end

  # log number of min prunes during alpha_beta_search
  def log_min_prune_count
    @min_prunes += 1
  end

  # perform alpha_beta search
  def alpha_beta_search(player)
    max_value(@board,-10000,10000,0,player)
  end

  # create a new node and perform the specified move on it and return the new node
  def result(board,move)
    temp_board = clone_board(board)

    temp_board.move([move[0],move[1]],[move[2],move[3]])
    p move if VERBOSE
    print_board(temp_board.state) if VERBOSE
    temp_board
  end

  def max_value(board,alpha,beta,depth,player)
    # log maximum depth
    log_depth(depth)

    # if either of the players have no moves left OR no pieces left(implied by no moves left) return utility value for the CPU player
    if board.moves(player).empty? || board.pieces[player].empty?
      return board.utility(@player)
    end

    # return value of the evaluation function which provides the heuristic value for the CPU player if max depth is reached
    # specified difficulty value provides max depth; higher max depth results in higher game difficulty
    if depth >= @difficulty
      return board.evaluate(@player)
    end

    value = MIN_TERMINAL_VAL
    board.moves(player).each do |current_move|
      x = min_value(result(board,current_move),alpha,beta,depth+1,other_player(player))
      value = max(value,x)
      # log moves by value of the move
      if depth.zero?
        @ab_moves[value] = @ab_moves[value] || [].to_set 
        @ab_moves[value] << current_move
      end
      # check if pruning condition has been met
      if value >= beta
        # record pruning count
        log_max_prune_count
        return value 
      end
      alpha = max(alpha,value)
    end
    return value
  end

  def min_value(board,alpha,beta,depth,player)
    # log maximum depth
    log_depth(depth)

    # if either of the players have no moves left OR no pieces left(implied by no moves left) return utility value for the CPU player
    if board.moves(player).empty? || board.pieces[player].empty?
      return board.utility(@player)
    end

    # return value of the evaluation function which provides the heuristic value for the CPU player if max depth is reached
    # specified difficulty value provides max depth; higher max depth results in higher game difficulty
    if depth >= @difficulty
      return board.evaluate(@player)
    end
    value = MAX_TERMINAL_VAL
    board.moves(player).each do |current_move|
      x = max_value(result(board,current_move),alpha,beta,depth+1,other_player(player))
      value = min(value,x)
      # check if pruning condition has been met
    if value <= alpha
      # record pruning count
      log_min_prune_count
      return value 
    end
      beta = min(beta,value)
    end
    return value
  end
end

