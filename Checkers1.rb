# require 'colorize'
require 'set'


VERBOSE = false
AB_VERBOSE  = false
GAME_VERBOSE  = false


BOARD_SQUARE_POS = {board_start: 10, board_end:610 }

INITIAL_BOARD = [
        [ 0, 1, 0, 1, 0, 1],
        [ 1, 0, 1, 0, 1, 0],
        [ 0, 0, 0, 0, 0, 0],
        [ 0, 0, 0, 0, 0, 0],
        [ 0,-1, 0,-1, 0,-1],
        [-1, 0,-1, 0,-1, 0]
        ] # initial board setting
# INITIAL_BOARD = [ 
#         [ 0, 0, 0, 0, 0, 0],
#         [ 0, 0, 0, 0, 0, 0],
#         [ 0, 0, 0, 0, 0, 0],
#         [ 1, 0, 1, 0, 1, 0],
#         [ 0, 0, 0, 0, 0, 0],
#         [-1, 0, 0, 0,-1, 0]
#         ] # initial board setting

GRID_SCORE = [
        [ 0, 4, 0, 4, 0, 4],
        [ 4, 0, 3, 0, 3, 0],
        [ 0, 3, 0, 1, 0, 4],
        [ 4, 0, 1, 0, 3, 0],
        [ 0, 3, 0, 2, 0, 4],
        [ 4, 0, 4, 0, 4, 0]
        ] # initial board setting

BLOCK_DIMENTION = 100
CHECKERS_WIDTH = 6
CHECKERS_HEIGHT = 6

CPU_PLAYER = 'white'
HUMAN_PLAYER = 'black'

HEURISTIC1 = true
HEURISTIC2 = true

EASY = 1
MEDIUM = 7
HARD = 14

$score_1 = []
$score_2 = []
$score_3 = []


class Piece
  attr_reader :color
  
  def initialize(color)
    @color = color
  end
end

class Board
  attr_reader :state, :score, :moves, :pieces

  def initialize
    @state = Array.new(CHECKERS_WIDTH) { Array.new(CHECKERS_HEIGHT) }
    @moves = {'black'=> [], 'white'=> []}
    @pieces = {'black'=> [], 'white'=> []}

    CHECKERS_HEIGHT.times.each do |x|
      CHECKERS_WIDTH.times.each do |y|
        if INITIAL_BOARD[x][y] == 1 
          @state[x][y] = Piece.new('white')
          @pieces['white'] << [x,y]
        end
        if INITIAL_BOARD[x][y] == -1
          @state[x][y] = Piece.new('black')
          @pieces['black'] << [x,y]
        end
      end
    end
    compute_available_moves
  end

  def exists?(box)
    !outofbounds?(box) && !@state[box[0]][box[1]].nil? 
  end

  def moves(player)
    @moves[player].sample(@moves[player].count)
  end

  def piece(box)
    @state[box[0]][box[1]]
  end

  def end_game?
      @pieces['black'].length == 0 || @pieces['white'].length == 0
  end

  def can_move?(org,dest)
    return false if exists?(dest) || outofbounds?(org) || outofbounds?(dest)
    return true if piece(org).color.eql?('white') && (org[0]- dest[0]).eql?(-1) && [-1,1].include?(dest[1] - org[1])
    return true if piece(org).color.eql?('black') && (org[0]- dest[0]).eql?( 1) && [-1,1].include?(dest[1] - org[1])
    false 
  end

  def can_capture?(org,dest)
    return false if exists?(dest) || outofbounds?(org) || outofbounds?(dest)
    return true if piece(org).color.eql?('white') && (org[0]- dest[0]).eql?(-2) && [-2,2].include?(dest[1] - org[1]) && exists?([org[0] + (dest[0]-org[0])/2, org[1] + (dest[1]-org[1])/2]) && piece([org[0] + (dest[0]-org[0])/2, org[1] + (dest[1]-org[1])/2]).color.eql?('black')
    return true if piece(org).color.eql?('black') && (org[0]- dest[0]).eql?( 2) && [-2,2].include?(dest[1] - org[1]) && exists?([org[0] + (dest[0]-org[0])/2, org[1] + (dest[1]-org[1])/2]) && piece([org[0] + (dest[0]-org[0])/2, org[1] + (dest[1]-org[1])/2]).color.eql?('white')
    false 
  end

  def outofbounds?(box)
    box[0] < 0 || box[0] >= CHECKERS_HEIGHT || box[1] < 0 || box[1] >= CHECKERS_WIDTH
  end

  def move(org,dest)
      @state[dest[0]][dest[1]] = @state[org[0]][org[1]]
      @pieces[piece(org).color].delete(org)
      @pieces[piece(org).color].push(dest)
      @state[org[0]][org[1]] = nil

      if (dest[0] - org[0]).abs == 2
        captured_box = [org[0] + (dest[0]-org[0])/2 , org[1] + (dest[1]-org[1])/2]
        @pieces[piece(captured_box).color].delete(captured_box)
        @state[captured_box[0]][captured_box[1]] = nil
      end
      compute_available_moves
  end

  def compute_available_moves
    @moves = {'black'=> [], 'white'=> []}
    # compute capture moves
    @pieces['white'].each do |x,y|
      @moves['white'] << [x,y,x+2,y+2] if exists?([x,y]) && can_capture?([x,y],[x+2,y+2])
      @moves['white'] << [x,y,x+2,y-2] if exists?([x,y]) && can_capture?([x,y],[x+2,y-2])
    end
    @pieces['black'].each do |x,y|
      @moves['black'] << [x,y,x-2,y+2] if exists?([x,y]) && can_capture?([x,y],[x-2,y+2])
      @moves['black'] << [x,y,x-2,y-2] if exists?([x,y]) && can_capture?([x,y],[x-2,y-2])
    end
    # if not capture moves are found or compute regular moves
    if @moves['white'].empty?
      @pieces['white'].each do |x,y|
        @moves['white'] << [x,y,x+1,y+1] if exists?([x,y]) && can_move?([x,y],[x+1,y+1])
        @moves['white'] << [x,y,x+1,y-1] if exists?([x,y]) && can_move?([x,y],[x+1,y-1])
      end
    end
    if @moves['black'].empty?
      @pieces['black'].each do |x,y|
        @moves['black'] << [x,y,x-1,y+1] if exists?([x,y]) && can_move?([x,y],[x-1,y+1])
        @moves['black'] << [x,y,x-1,y-1] if exists?([x,y]) && can_move?([x,y],[x-1,y-1])
      end
    end
  end



  def utility(player)
    score = @pieces[player].count - @pieces[other_player(player)].count
    return 0 if score.zero?
    return  2000 if score > 0
    return -2000 if score < 0
  end

  def evaluate(player)
    # @pieces[player].count - @pieces[other_player(player)].count
    score = 0
    score1 = 0
    score2 = 0

    # if player.eql?('black')
    #   score1 = (pieces[player].count - pieces[other_player(player)].count)*10
    # end
    score1 = (pieces[player].count - pieces[other_player(player)].count)*10

    # if player.eql?('white')
    #   # score1 = (pieces[player].count - pieces[other_player(player)].count)*100

    #   pieces[player].each do |loc|
    #     score2 += GRID_SCORE[loc[0]][loc[1]]
    #   end

    #   pieces[other_player(player)].each do |loc|
    #     score2 -= GRID_SCORE[loc[0]][loc[1]]
    #   end
    #   score2 *= 1
    # end

    score = score1 + score2
    score
  end

end

  def other_player(player)
    player.eql?('white') ? 'black' :  'white'
  end

  def max(*params)
    params.max
  end

  def min(*params)
    params.min
  end


  def print_board2(board)
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


class Checkers
  attr_reader :board, :turn, :chosen_move, :max_nodes, :max_depth, :time_taken

  def initialize(turn,board,player,difficulty)
    @board = board
    @score = { "black" => 0, "white" => 0 }
    @available_moves = []
    @difficulty = difficulty
    @player = player
    # @chosen_move = [1, 0, 2, 1]
    @turn = turn
    @max_depth = 0
    @max_nodes = 0
    @time_taken = 0
    @ab_moves = {}
  end


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

  def score(player)
    @score[player]
  end

  def game_over?
      @board.pieces['black'].empty? || @board.pieces['white'].empty? || (@board.moves(HUMAN_PLAYER).empty? && @board.moves(CPU_PLAYER).empty?)
  end


  def switch_turn
    @turn.eql?('white') ? @turn = 'black' : @turn = 'white'
    $stderr.puts "switched to #{@turn}" if VERBOSE
  end

  def moves_available?(player)
    !@board.moves(player).empty?
  end

  def cpu_move 
    @max_depth = 0
    @max_nodes = 0
    @test_count = 0
      @ab_moves = {}
      start_t = Time.now
      value = a_b(@player)
      @time_taken = Time.now - start_t
    # $stderr.puts "#{@max_nodes}"

      @chosen_move = @ab_moves[value].to_a.first#.sample
    @board.move([@chosen_move[0],@chosen_move[1]],[@chosen_move[2],@chosen_move[3]])
    @score[@player] += 1 if (chosen_move[2] - chosen_move[0]).abs == 2
  end

  def user_move(org,dest)
    if @board.moves(HUMAN_PLAYER).include?([org[0],org[1],dest[0],dest[1]])
      @board.move(org,dest) 
      @score[HUMAN_PLAYER] += 1 if (dest[0] - org[0]).abs == 2
      true
    else
      false
    end
  end

  def clone_board(board)
    log_nodes_count
    Marshal.load( Marshal.dump(board) )
  end

  def log_depth(depth)
    @max_depth = max(@max_depth,depth)
  end

  def log_nodes_count
    @max_nodes += 1
  end

  def a_b(player)
    max_value(@board,-10000,10000,0,player)
  end

  def result(board,move)
    temp_board = clone_board(board)

    temp_board.move([move[0],move[1]],[move[2],move[3]])
    p move if AB_VERBOSE
    print_board(temp_board.state) if AB_VERBOSE
    temp_board
  end

  def max_value(board,alpha,beta,depth,player)
    log_depth(depth)
    if board.moves(player).empty? || board.pieces[player].empty?
      return board.utility(@player)
    end
    if depth >= @difficulty
      return board.evaluate(@player)
    end
    value = -10000
    p board.moves(player) if AB_VERBOSE
    board.moves(player).each do |current_move|
      x = min_value(result(board,current_move),alpha,beta,depth+1,other_player(player))
      value = max(value,x)
      if depth.zero?
        @ab_moves[value] = @ab_moves[value] || [].to_set 
        @ab_moves[value] << current_move
      end
      if value >= beta
        return value 
      end
      alpha = max(alpha,value)
    end
    return value
  end

  def min_value(board,alpha,beta,depth,player)
    log_depth(depth)
    if board.moves(player).empty? || board.pieces[player].empty?
      return board.utility(@player)
    end
    if depth >= @difficulty
      return board.evaluate(@player)
    end
    value = 10000
    board.moves(player).each do |current_move|
      x = max_value(result(board,current_move),alpha,beta,depth+1,other_player(player))
      value = min(value,x)
      puts "min val: #{value}" if AB_VERBOSE
    if value <= alpha
      return value 
    end
      beta = min(beta,value)
    end
    return value
  end


end


# black_win_count = 0
# white_win_count = 0
# draw = 0
# (1..50).each do |x|

#   board = Board.new
#   black = Checkers.new('black',board,'black',MEDIUM)
#   white = Checkers.new('white',board,'white',HARD)

# # white.cpu_move

# # black.cpu_move

#   white.print_board(board.state)  if GAME_VERBOSE

#   while !(white.game_over? || black.game_over?)

#     p board.moves('white') if GAME_VERBOSE
#     white.cpu_move if !board.moves('white').empty? 
#     print " WHITE ".colorize(:yellow) if GAME_VERBOSE
#     white.print_board(board.state) if GAME_VERBOSE

#     p board.moves('black') if GAME_VERBOSE
#     black.cpu_move if !board.moves('black').empty?
#     print " BLACK ".colorize(:red) if GAME_VERBOSE
#     white.print_board(board.state) if GAME_VERBOSE
#   end if x.even?

#   while !(white.game_over? || black.game_over?)

#     p board.moves('black') if GAME_VERBOSE
#     black.cpu_move if !board.moves('black').empty?
#     print " BLACK ".colorize(:red) if GAME_VERBOSE
#     white.print_board(board.state) if GAME_VERBOSE

#     p board.moves('white') if GAME_VERBOSE
#     white.cpu_move if !board.moves('white').empty? 
#     print " WHITE ".colorize(:yellow) if GAME_VERBOSE
#     white.print_board(board.state) if GAME_VERBOSE


#   end if x.odd?

#   puts "--------------Game over:--------------" if VERBOSE#{}" #{@game.score}" if VERBOSE
#   puts "--------------white:#{white.score('white')}--------------"if VERBOSE
#   puts "--------------black:#{black.score('black')}--------------" if VERBOSE

#   white_win_count += 1 if (white.score('white') > black.score('black'))
#   black_win_count += 1 if (black.score('black') > white.score('white'))
#   draw += 1 if (white.score('white') == black.score('black'))
# end

# # # (1..20).each do |x|
#   puts "white win #{white_win_count}"
#   puts "black win #{black_win_count}"
#   puts "draw win #{draw}"

