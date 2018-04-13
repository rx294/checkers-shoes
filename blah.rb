# Shoes.app do
#    click do |btn, left, top|
#       para "#{btn}, #{left}, #{top}, \n"
#    end
# end
 # Shoes.app (title: "White Circle",
 #   width: 200, height: 200, resizable: false) do
 #   stroke rgb(0.5, 0.5, 0.7)
 #   fill rgb(1.0, 1.0, 0.9)
 #   rect 10, 10, self.width - 20, self.height - 20
 # end



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
#         [ 0, 0,-1, 0, 0, 0],
#         [ 0, 0, 0, 0, 0, 0],
#         [ 0, 0, 0, 0, 0, 0],
#         [ 0, 0, 0, 1, 0, 1],
#         [ 0, 0, 0, 0, 0, 0]
#         ] # initial board setting
# INITIAL_BOARD = [
#         [ 0, 1, 0, 1, 0, 1, 0, 1 ],
#         [ 1, 0, 1, 0, 1, 0, 1, 0 ],
#         [ 0, 0, 0, 0, 0, 0, 0, 0 ],
#         [ 0, 0, 0, 0, 0, 0, 0, 0 ],
#         [ 0, 0, 0, 0, 0, 0, 0, 0 ],
#         [ 0, 0, 0, 0, 0, 0, 0, 0 ],
#         [ 0,-1, 0,-1, 0,-1, 0,-1 ],
#         [-1, 0,-1, 0,-1, 0,-1, 0 ]
#         ] # initial board setting
# INITIAL_BOARD = [
#         [ 0, 1, 0, 1, 0, 1, 0, 1 ],
#         [ 1, 0, 1, 0, 1, 0, 1, 0 ],
#         [ 0, 1, 0, 1, 0, 1, 0, 1 ],
#         [ 0, 0, 0, 0, 0, 0, 0, 0 ],
#         [ 0, 0, 0, 0, 0, 0, 0, 0 ],
#         [-1, 0,-1, 0,-1, 0,-1, 0 ],
#         [ 0,-1, 0,-1, 0,-1, 0,-1 ],
#         [-1, 0,-1, 0,-1, 0,-1, 0 ]
#         ] # initial board setting



BLOCK_DIMENTION = 100
CHECKERS_WIDTH = 6
CHECKERS_HEIGHT = 6

CPU_PLAYER = 'white'
HUMAN_PLAYER = 'black'

HEURISTIC1 = true
HEURISTIC2 = false


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
      # $stderr.puts "WHITE: #{@pieces[CPU_PLAYER]}"
      # $stderr.puts "BLACK: #{@pieces[HUMAN_PLAYER]}"
      compute_available_moves
  end

  # def move(org,dest)
  #     @state[dest[0]][dest[1]] = @state[org[0]][org[1]]
  #     @state[org[0]][org[1]] = nil

  #     if (dest[0] - org[0]).abs == 2
  #       @state[org[0] + (dest[0]-org[0])/2][org[1] + (dest[1]-org[1])/2] = nil
  #       @score[piece(dest).color] += 1
  #     end
  # end


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
    other_player = player.eql?('white') ? 'black' :  'white'
    # score += (pieces[player].length - pieces[other_player].length)
    score += pieces[player].count

    # score += (pieces['black'].length - pieces['white'].length)*100 if HEURISTIC1 && player.eql?('black')
    # score += (pieces['white'].length - pieces['black'].length)*100 if HEURISTIC1 && player.eql?('white')

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
    # $stderr.puts "fancy score #{score}"
    score
  end

  # def compute_available_moves
  #   @moves = {'black'=> [], 'white'=> []}
  #   CHECKERS_HEIGHT.times.each do |x|
  #     CHECKERS_WIDTH.times.each do |y|
  #       @moves[piece([x,y]).color] << [x,y,x+2,y+2] if exists?([x,y]) && can_capture?([x,y],[x+2,y+2])
  #       @moves[piece([x,y]).color] << [x,y,x+2,y-2] if exists?([x,y]) && can_capture?([x,y],[x+2,y-2])
  #       @moves[piece([x,y]).color] << [x,y,x-2,y+2] if exists?([x,y]) && can_capture?([x,y],[x-2,y+2])
  #       @moves[piece([x,y]).color] << [x,y,x-2,y-2] if exists?([x,y]) && can_capture?([x,y],[x-2,y-2])
  #     end
  #   end
  #   ['white','black'].each do |player|
  #     if @moves[player].empty?
  #       CHECKERS_HEIGHT.times.each do |x|
  #         CHECKERS_WIDTH.times.each do |y|
  #           if exists?([x,y]) && piece([x,y]).color.eql?(player)
  #             @moves[player] << [x,y,x+1,y+1] if exists?([x,y]) && can_move?([x,y],[x+1,y+1])
  #             @moves[player] << [x,y,x+1,y-1] if exists?([x,y]) && can_move?([x,y],[x+1,y-1])
  #             @moves[player] << [x,y,x-1,y+1] if exists?([x,y]) && can_move?([x,y],[x-1,y+1])
  #             @moves[player] << [x,y,x-1,y-1] if exists?([x,y]) && can_move?([x,y],[x-1,y-1])
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

end

class Checkers
  attr_reader :board, :turn, :chosen_move

  def initialize(turn)
    @board = Board.new
    @score = { "black" => 0, "white" => 0 }
    @available_moves = []
    @difficulty = 4
    # @chosen_move = [1, 0, 2, 1]
    @turn = turn
    @max_depth = 0
    @max_nodes = 0
    @test_count = 0
  end


  def print_board(board)
    p "--------------------------------------------------------------------------------------------------------------"
    board.each do |line|
      p line
    end
    p "--------------------------------------------------------------------------------------------------------------"
  end

  def score(player)
    @score[player]
  end

  def game_over?
      # $stderr.puts "Game over: test" #{@game.score}""
      @board.pieces['black'].empty? || @board.pieces['white'].empty? || (@board.moves(HUMAN_PLAYER).empty? && @board.moves(CPU_PLAYER).empty?)
  end


  def switch_turn
    @turn.eql?('white') ? @turn = 'black' : @turn = 'white'
    $stderr.puts "switched to #{@turn}"
  end

  def moves_available?(player)
    !@board.moves(player).empty?
  end

  def cpu_move 
    @max_depth = 0
    @max_nodes = 0
    $stderr.puts "WHITE: #{@board.moves(CPU_PLAYER)}"
    $stderr.puts "BLACK: #{@board.moves(HUMAN_PLAYER)}"

    @test_count = 0
    $stderr.puts "Moves :#{@board.moves(CPU_PLAYER).length}"
    if @board.moves(CPU_PLAYER).length == 1
      @chosen_move = @board.moves(CPU_PLAYER).first
    # elsif @board.moves(CPU_PLAYER).length > 4
      # @chosen_move = @board.moves(CPU_PLAYER).first
    else
      alphabeta_cutoff_search(@board,CPU_PLAYER)
      # alpha_beta(CPU_PLAYER,@board,0,-10000,10000)
    end

    $stderr.puts "chosen_move: #{@chosen_move}"

    $stderr.puts "MAX DEPTH: #{@max_depth}"  
    $stderr.puts "MAX NODES: #{@max_nodes}"  
    @board.move([@chosen_move[0],@chosen_move[1]],[@chosen_move[2],@chosen_move[3]])
    @score[CPU_PLAYER] += 1 if (chosen_move[2] - chosen_move[0]).abs == 2
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
    # temp_board = Board.new
    # CHECKERS_HEIGHT.times.each do |x|
    #   CHECKERS_WIDTH.times.each do |y|
    #     temp_board.state[x][y] = board.state[x][y]
    #   end
    # end
    # temp_board.moves = board.moves
    # temp_board.pieces = board.pieces
    Marshal.load( Marshal.dump(board) )
    # return temp_board
  end

  def min(a,b)
    a < b ? a : b
  end

  def max(a,b)
    a > b ? a : b
  end

  def alphabeta_cutoff_search(board, player)

    # player = @turn

    def max_value(board, player, alpha, beta, depth,move)
      board.pieces[player]
      if depth > @difficulty or board.moves(player).empty? 
        @max_depth = max(@max_depth,depth)
        # $stderr.puts "evaluated move for #{player}: #{move}" 
        return board.compute_board_score(player)
      end
      v = -10000000000000000000000000
      board.moves(player).each do |move|
        temp_board = clone_board(board)
        temp_board.move([move[0],move[1]],[move[2],move[3]])

        player.eql?('white') ? player = 'black' : player = 'white'

        v = max(v, min_value(temp_board, player, alpha, beta, depth + 1,move))
        if v >= beta
          return v
        end
        alpha = max(alpha, v)
      end
      return v
    end

    def min_value(board, player, alpha, beta, depth,move)
      if depth > @difficulty or board.moves(player).empty? 
        @max_depth = max(@max_depth,depth)
        # $stderr.puts "evaluated move for #{player}: #{move}" 
        return board.compute_board_score(player)
      end
      v = 10000000000000000000000000
      board.moves(player).each do |move|
        temp_board = clone_board(board)
        temp_board.move([move[0],move[1]],[move[2],move[3]])

        player.eql?('white') ? player = 'black' : player = 'white'

        v = min(v, max_value(temp_board, player, alpha, beta, depth + 1,move))
        if v <= alpha
          return v
        end
        beta = min(beta, v)
      end
      return v
    end
    best_score = -10000000
    beta = 10000000

    board.moves(player).each do |move|
      temp_board = clone_board(board)
      temp_board.move([move[0],move[1]],[move[2],move[3]])

      # player = 'black'
      # player.eql?('white') ? player = 'black' : player = 'white'

      $stderr.puts "||player: #{player}"
      $stderr.puts "||current move: #{move}"

      v = min_value(temp_board, player, best_score, beta, 1,move)
       $stderr.puts "v: #{v}"
      if v > best_score
        best_score = v
        $stderr.puts "best_score: #{best_score}"
        $stderr.puts "chosen_move: #{move}"
        @chosen_move = move
      end
    end
  end


  def alpha_beta(player,board,depth,alpha,beta,move = nil)
    # $stderr.puts "end_game? #{board.end_game?}"
    @chosen_move = 0
    # if depth > @difficulty or board.moves[CPU_PLAYER].empty? or board.moves[HUMAN_PLAYER].empty?
    if depth > @difficulty #or board.pieces[CPU_PLAYER].empty? or board.pieces[HUMAN_PLAYER].empty?
      @test_count +=1
      # $stderr.puts "||||||score #{player} : #{board.compute_board_score(player)}"
      # $stderr.puts "score #{player} : #{board.compute_board_score(player)}"
      $stderr.puts "evaluated move for #{player}: #{move}" 
      return board.compute_board_score(player)
    end
    @max_depth = depth if @max_depth < depth

    if player.eql?(@turn)
      board.moves(player).each do |move|
        temp_board = clone_board(board)
        # temp_board = Marshal.load( Marshal.dump(board) )

        temp_board.move([move[0],move[1]],[move[2],move[3]])

        
        player.eql?('white') ? player = 'black' : player = 'white'

        board_score = alpha_beta(player,temp_board,depth+1,alpha,beta,move)

        if board_score > alpha
          @chosen_move = [move[0],move[1],move[2],move[3]] if depth.zero?
          alpha = board_score
        end

        if alpha >= beta
          return alpha
        end
      end
      return alpha
    else
      board.moves(player).each do |move|
        temp_board = clone_board(board)
        # temp_board = Marshal.load( Marshal.dump(board) )

        temp_board.move([move[0],move[1]],[move[2],move[3]])

        player.eql?('white') ? player = 'black' : player = 'white'

        board_score = alpha_beta(player,temp_board,depth+1,alpha,beta,move)
        # p board_score
        if board_score < alpha
          beta = board_score
        end

        if alpha >= beta
          return beta
        end
      end
      return beta
    end
  end

  # def alpha_beta(player,board,depth,alpha,beta)
  #   if depth > @difficulty or board.end_game?
  #     # puts "|||||||||||||||||||||||||#{board.compute_board_score(player)}|||||||||||||||||||||"
  #     return board.compute_board_score(player)
  #   end
  #   if player.eql?(@turn)
  #     board.moves(player).each do |move|
  #       # temp_board = Marshal.load( Marshal.dump(board) )
  #       temp_board = clone_board(board)

  #       # p move
  #       # p temp_board.state[move[0],move[1]]
  #       # p temp_board.state[move[2],move[3]]
  #       # p temp_board.state[0,0]
  #       # p player
  #       # print_board(temp_board.state)
  #       temp_board.move([move[0],move[1]],[move[2],move[3]])
  #       # print_board(temp_board.state)

        
  #       player.eql?('white') ? player = 'black' : player = 'white'

  #       board_score = alpha_beta(player,temp_board,depth+1,alpha,beta)

  #       if board_score > alpha
  #         @chosen_move = [move[0],move[1],move[2],move[3]] if depth.zero?
  #         # p @chosen_move
  #         alpha = board_score
  #       end

  #       if alpha >= beta
  #         return alpha
  #       end
  #     end
  #     return alpha
  #   else
  #     board.moves(player).each do |move|
  #       # temp_board = Marshal.load( Marshal.dump(board) )
  #       temp_board = clone_board(board)
  #       # p player
  #       # print_board(temp_board.state)
  #       temp_board.move([move[0],move[1]],[move[2],move[3]])
  #       # print_board(temp_board.state)

  #       player.eql?('white') ? player = 'black' : player = 'white'

  #       board_score = alpha_beta(player,temp_board,depth+1,alpha,beta)
  #       # p board_score
  #       if board_score < alpha
  #         beta = board_score
  #       end

  #       if alpha >= beta
  #         return beta
  #       end
  #     end
  #     return beta
  #   end
  # end
end

# @game = Checkers.new('white')

# # @game.print_board(@game.board.state)
# # @game.print_board(@game.clone_board(@game.board).state)
# # @game.print_board(@game.board.state)

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

