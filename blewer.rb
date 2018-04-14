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

  def compute_board_score(player)
    score = 0
    # other_player = player.eql?('white') ? 'black' :  'white'
    # score += (pieces[player].length - pieces[other_player].length)
    # score += pieces[player].count

    score += (pieces['black'].length - pieces['white'].length)*100 if HEURISTIC1 && player.eql?('black')
    score += (pieces['white'].length - pieces['black'].length)*100 if HEURISTIC1 && player.eql?('white')

    # score += pieces['black'].map{ |x| (5-x[0])*(5-x[0]) }.inject(0, :+) - pieces['white'].map{ |x| x[0]*x[0] }.inject(0, :+) if HEURISTIC2 && player.eql?('black')
    # score += pieces['white'].map{ |x| x[0]*x[0] }.inject(0, :+) - pieces['black'].map{ |x| (5-x[0])*(5-x[0]) }.inject(0, :+) if HEURISTIC2 && player.eql?('white')
    
    # def fancy_score(player)
    #   fancy_score = 0
    #   moves(player).each do |move| 
    #     other_player = player.eql?('white') ? 'black' :  'white'
    #     temp_board = Marshal.load( Marshal.dump(self) )

    #     player_score = temp_board.pieces[player].count 
    #     other_player_score = temp_board.pieces[other_player].count 

    #     temp_board.move([move[0],move[1]],[move[2],move[3]])
        
    #     temp_board.pieces[player].count - temp_board.pieces[other_player].count

    #     new_player_score = temp_board.pieces[player].count 
    #     new_other_player_score = temp_board.pieces[other_player].count 

    #     fancy_score += (new_player_score - player_score) + (other_player_score - new_other_player_score)
    #   end
    #   fancy_score
    # end
    # score += fancy_score(player)
    # $stderr.puts "fancy score #{score}" if VERBOSE
    score
  end


  def utility(player)
    score = @pieces[player].count - @pieces[other_player(player)].count
    # score = (pieces['black'].count - pieces['white'].count) if player.eql?('white')
    # score = (pieces['white'].count - pieces['black'].count) if player.eql?('black')

    # puts "#{player} utility score: #{score}"
    return 0 if score.zero?
    return  2000 if score > 0
    return -2000 if score < 0
  end

  def evaluate(player)
    # @pieces[player].count - @pieces[other_player(player)].count
    score = 0
    score1 = 0
    score2 = 0

    # score1 = (pieces['black'].length*1 - pieces['white'].length)*100 if HEURISTIC1 && player.eql?('black')
    # score1 = (pieces['white'].length*1 - pieces['black'].length)*100 if HEURISTIC1 && player.eql?('white')
    # $score_1 << score1


    # score2 = (pieces['black'].length*1 - pieces['white'].length)*10 if HEURISTIC1 && player.eql?('black')
    # score2 = (pieces['white'].length*1 - pieces['black'].length)*10 if HEURISTIC1 && player.eql?('white')

    # if player.eql?('black')
    #   score1 = (pieces[player].count - pieces[other_player(player)].count)*10
    # end


    if player.eql?('white')
      score1 = (pieces[player].count - pieces[other_player(player)].count)*10

      # pieces[player].each do |loc|
      #   score2 += GRID_SCORE[loc[0]][loc[1]]
      # end

      # pieces[other_player(player)].each do |loc|
      #   score2 -= GRID_SCORE[loc[0]][loc[1]]
      # end
      # score2 *= 1
    end

    

    score = score1 + score2

    # # p score1
    # score2 = pieces['black'].map{ |x| (5-x[0])*(5-x[0]) }.inject(0, :+) - pieces['white'].map{ |x| x[0]*x[0] }.inject(0, :+) if HEURISTIC2 && player.eql?('black')
    # score2 = pieces['white'].map{ |x| x[0]*x[0] }.inject(0, :+) - pieces['black'].map{ |x| (5-x[0])*(5-x[0]) }.inject(0, :+) if HEURISTIC2 && player.eql?('white')
    # $score_2 << score2

    # def fancy_score(player)
    #   fancy_score = 0
    #   moves(player).each do |move| 
    #     other_player = player.eql?('white') ? 'black' :  'white'
    #     temp_board = Marshal.load( Marshal.dump(self) )

    #     player_score = temp_board.pieces[player].count 
    #     other_player_score = temp_board.pieces[other_player].count 

    #     temp_board.move([move[0],move[1]],[move[2],move[3]])
        
    #     temp_board.pieces[player].count - temp_board.pieces[other_player].count

    #     new_player_score = temp_board.pieces[player].count 
    #     new_other_player_score = temp_board.pieces[other_player].count 

    #     fancy_score += (new_player_score - player_score) + (other_player_score - new_other_player_score)
    #   end
    #   fancy_score
    # end
    
    # score_3 = fancy_score(player) #if player.eql?('black')
    # $score_3 << score_3



    # # score =  score1 + score2

    # score += score_3 if player.eql?('black')

    # p score
    # puts "#{player} evaluate score: #{score2}"
    # return score2 if player.eql?('black')
    # return score1 if player.eql?('white')
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
  attr_reader :board, :turn, :chosen_move

  def initialize(turn,board,player,difficulty)
    @board = board
    @score = { "black" => 0, "white" => 0 }
    @available_moves = []
    @difficulty = difficulty
    @player = player
    # @chosen_move = [1, 0, 2, 1]
    @turn = player
    @max_depth = 0
    @max_nodes = 0
    @test_count = 0
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
      # $stderr.puts "Game over: test" #{@game.score}"" if VERBOSE
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
    $stderr.puts "WHITE: #{@board.moves(CPU_PLAYER)}" if VERBOSE
    $stderr.puts "BLACK: #{@board.moves(HUMAN_PLAYER)}" if VERBOSE

    @test_count = 0
    $stderr.puts "Moves :#{@board.moves(CPU_PLAYER).length}" if VERBOSE


    # $stderr.puts "#{@player}: #{@board.moves(@player)}"

    # if @board.moves(@player).length == 1
      # @chosen_move = @board.moves(@player).first
    # elsif @board.moves(CPU_PLAYER).length > 4
      # @chosen_move = @board.moves(CPU_PLAYER).first
    # else
      # alphabeta_cutoff_search(@board,@player)
      # alpha_beta(CPU_PLAYER,@board,0,-10000,10000)
      # value = a_b(other_player(@player))
      # @difficulty = 30 - @board.moves(@player).count*3
      # $stderr.puts "difficulty: #{@difficulty}"
      @ab_moves = {}
      value = a_b(@player)
      # $stderr.puts "Value: #{value}" #if AB_VERBOSE
      # $stderr.puts "Move: #{current_move}"
      @chosen_move = @ab_moves[value].to_a.first#.sample
    # end
    # print_board(@board.state)
    # $stderr.puts "chosen_move: #{@chosen_move}" 

    $stderr.puts "MAX DEPTH: #{@max_depth}"   if VERBOSE
    $stderr.puts "MAX NODES: #{@max_nodes}"   if VERBOSE
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
    @max_nodes += 1
    Marshal.load( Marshal.dump(board) )
  end

  def a_b(player)
    # temp_board = Marshal.load( Marshal.dump(@board) )
    value = max_value(@board,-10000,10000,0,player)
    # p "hi am back"
    # puts @ab_moves #if AB_VERBOSE
    value
  end

  def result(board,move)
    temp_board = Marshal.load( Marshal.dump(board) )
    temp_board.move([move[0],move[1]],[move[2],move[3]])
    p move if AB_VERBOSE
    print_board(temp_board.state) if AB_VERBOSE
    temp_board
  end

  def max_value(board,alpha,beta,depth,player)
    puts "max: #{alpha},#{beta},#{depth},#{player}" if AB_VERBOSE
    # puts "#{board.moves(player).count}, #{board.pieces[player].count}"
    # print_board(board.state)
    if board.moves(player).empty? || board.pieces[player].empty?
      # p "==============================util"
      # p "==============================util: #{board.utility(player)}"
      return board.utility(@player)
    end
    if depth >= @difficulty
      # p "==============================eval: #{board.evaluate(player)}" #if AB_VERBOSE
      return board.evaluate(@player)
    end
    value = -10000
    p board.moves(player) if AB_VERBOSE
    board.moves(player).each do |current_move|
      x = min_value(result(board,current_move),alpha,beta,depth+1,other_player(player))
      puts "max val: #{value}  x: #{x}  a: #{alpha}  b: #{beta}, depth:#{depth}" if AB_VERBOSE
      # puts "score black:#{board.evaluate('black').abs} white: #{board.evaluate('white').abs}"
      value = max(value,x)
      puts "max val: #{value}" if AB_VERBOSE
      if depth.zero?
        @ab_moves[value] = @ab_moves[value] || [].to_set 
        @ab_moves[value] << current_move
      end
      if value >= beta
        # p "=====================================================================value >= beta" if AB_VERBOSE
        return value 
      end
      alpha = max(alpha,value)
    end
    return value
  end

  def min_value(board,alpha,beta,depth,player)
    puts "min: #{alpha},#{beta},#{depth},#{player}" if AB_VERBOSE
    # puts "#{board.moves(player).count}, #{board.pieces[player].count}"
    # print_board(board.state)
    if board.moves(player).empty? || board.pieces[player].empty?
      # p "==============================util: #{board.utility(player)}"
      return board.utility(@player)
    end
    if depth >= @difficulty
      # p "==============================eval: #{board.evaluate(player)}" #if AB_VERBOSE
      return board.evaluate(@player)
    end
    value = 10000
    # p board.moves(player)
    board.moves(player).each do |current_move|
      x = max_value(result(board,current_move),alpha,beta,depth+1,other_player(player))
      puts "min val: #{value}  x: #{x}  a: #{alpha}  b: #{beta}, depth:#{depth}" if AB_VERBOSE
      # puts "score black:#{board.evaluate('black').abs} white: #{board.evaluate('white').abs}"
      value = min(value,x)
      puts "min val: #{value}" if AB_VERBOSE
    if value <= alpha
        # p "=====================================================================value <= alpha" if AB_VERBOSE
      # @chosen_move = current_move
      return value 
    end
      beta = min(beta,value)
    end
    # puts "val: #{value}"
    return value
  end


end



#   board = Board.new

#   white = Checkers.new('white',board,'white',3)

# white.cpu_move

#   black = Checkers.new('black',board,'black',3)
# black.cpu_move



black_win_count = 0
white_win_count = 0
draw = 0
(1..10).each do |x|

  board = Board.new
  black = Checkers.new('black',board,'black',14)
  white = Checkers.new('white',board,'white',14)

# white.cpu_move

# black.cpu_move

  white.print_board(board.state)  if GAME_VERBOSE

  while !(white.game_over? || black.game_over?)

    p board.moves('white') if GAME_VERBOSE
    white.cpu_move if !board.moves('white').empty? 
    print " WHITE ".colorize(:yellow) if GAME_VERBOSE
    white.print_board(board.state) if GAME_VERBOSE

    p board.moves('black') if GAME_VERBOSE
    black.cpu_move if !board.moves('black').empty?
    print " BLACK ".colorize(:red) if GAME_VERBOSE
    white.print_board(board.state) if GAME_VERBOSE
  end if x.even?

  while !(white.game_over? || black.game_over?)

    p board.moves('black') if GAME_VERBOSE
    black.cpu_move if !board.moves('black').empty?
    print " BLACK ".colorize(:red) if GAME_VERBOSE
    white.print_board(board.state) if GAME_VERBOSE

    p board.moves('white') if GAME_VERBOSE
    white.cpu_move if !board.moves('white').empty? 
    print " WHITE ".colorize(:yellow) if GAME_VERBOSE
    white.print_board(board.state) if GAME_VERBOSE


  end if x.odd?

  puts "--------------Game over:--------------" if VERBOSE#{}" #{@game.score}" if VERBOSE
  puts "--------------white:#{white.score('white')}--------------"if VERBOSE
  puts "--------------black:#{black.score('black')}--------------" if VERBOSE

  white_win_count += 1 if (white.score('white') > black.score('black'))
  black_win_count += 1 if (black.score('black') > white.score('white'))
  draw += 1 if (white.score('white') == black.score('black'))
end

# # (1..20).each do |x|
  puts "white win #{white_win_count}"
  puts "black win #{black_win_count}"
  puts "draw win #{draw}"
# # end

# # p max(1,2,4)


# p $score_1.minmax
# p $score_2.minmax
# p $score_3.compact.minmax

# def initialize(turn,board,player,difficulty)
# @game.print_board(@game.board.state)
# @game.print_board(@game.clone_board(@game.board).state)
# @game.print_board(@game.board.state)

#     if @game.turn.eql?(CPU_PLAYER)
#         @game.cpu_move
#         p "cpu test #{@game.chosen_move}"
#         # move_piece([@game.chosen_move[0],@game.chosen_move[1]],[@game.chosen_move[2],@game.chosen_move[3]])
#         @game.switch_turn
#     end
# @game.print_board(@game.board.state)

# test.cpu_move
# p test.chosen_move
# p test.board.moves
# p test.user_move([4, 1],[ 3, 2])
# puts test.score('black')
# puts test.exists?([2,1])
# puts test.piece([1,0]).color
# puts test.move([1,0],[2,1])
# puts test.exists?([1,0])
# puts test.can_capture?([1,0],[3,2])


# board = Board.new

# game = Checkers.new('white')
# # p game.turn
# # game.switch_turn
# # p game.turn

# # p game.board.state
# game.cpu_move
# p game.chosen_move




# # p board.moves
# p board.pieces
# board.move([1, 0],[3, 2])
# # p board.moves
# p board.pieces
# board.move([4, 1],[2, 3])
# # p board.moves
# p board.pieces

# p board.compute_board_score('black')
# def draw_pieces(board)
#     CHECKERS_HEIGHT.times do |y|
#         CHECKERS_WIDTH.times do |x|
#             puts "#{x},#{y},#{board.state[x][y].color}" unless board.state[x][y].nil?
#         end
#     end
# end

# puts board.state.inspect
# draw_pieces(board)

