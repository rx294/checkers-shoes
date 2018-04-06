BOARD_SQUARE_POS = {board_start: 10, board_end:610 }

# INITIAL_BOARD = [
#         [ 0, 1, 0, 1, 0, 1],
#         [ 1, 0, 1, 0, 1, 0],
#         [ 0,-1, 0, 0, 0, 0],
#         [ 0, 0, 0, 0, 1, 0],
#         [ 0,-1, 0,-1, 0,-1],
#         [-1, 0,-1, 0,-1, 0]
#         ] # initial board setting
INITIAL_BOARD = [
        [ 0, 1, 0, 1, 0, 1],
        [ 1, 0, 1, 0, 1, 0],
        [ 0, 0, 0, 0, 0, 0],
        [ 0, 0, 0, 0, 1, 0],
        [ 0,-1, 0,-1, 0,-1],
        [-1, 0,-1, 0,-1, 0]
        ] # initial board setting



BLOCK_DIMENTION = 100
CHECKERS_WIDTH = 6
CHECKERS_HEIGHT = 6

CPU_PLAYER = 'white'
HUMAN_PLAYER = 'black'

HEURISTIC1 = true
HEURISTIC2 = true


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

  def piece(box)
    @state[box[0]][box[1]]
  end

  def end_game?
      @pieces['black'] == 0 || @pieces['white'] == 0
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
    score += (pieces['black'].length - pieces['white'].length) if HEURISTIC1 && player.eql?('black')
    score += (pieces['white'].length - pieces['black'].length) if HEURISTIC1 && player.eql?('white')

    score += pieces['black'].map{ |x| (5-x[0])*(5-x[0]) }.sum - pieces['white'].map{ |x| x[0]*x[0] }.sum if HEURISTIC2 && player.eql?('black')
    score += pieces['white'].map{ |x| x[0]*x[0] }.sum - pieces['black'].map{ |x| (5-x[0])*(5-x[0]) }.sum if HEURISTIC2 && player.eql?('white')
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
    @difficulty = 6
    @chosen_move = nil
    @turn = turn
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

  def switch_turn
    @turn.eql?('white') ? @turn = 'black' : @turn = 'white'
  end

  def cpu_move
    # factorial(num = 10)
    alpha_beta('white',@board,0,-10000,10000)
    @board.move([@chosen_move[0],chosen_move[1]],[@chosen_move[2],chosen_move[3]])
  end

  def user_move(org,dest)
    if @board.moves[HUMAN_PLAYER].include?([org[0],org[1],dest[0],dest[1]])
      @board.move(org,dest) 
      true
    else
      false
    end
  end

  def factorial(num = 0)
    return "Can not calculate factorial of a negative number" if num < 0

    if num <= 1
      1
    else
      num * factorial(num - 1)
    end
  end

  def dup_board(board)
    temp_board = Board.new
    CHECKERS_HEIGHT.times.each do |x|
      CHECKERS_WIDTH.times.each do |y|
        temp_board.state[x][y] = board.state[x][y]
      end
    end
    return temp_board
  end

  def alpha_beta(player,board,depth,alpha,beta)
    if depth > @difficulty or board.end_game?
      # puts "|||||||||||||||||||||||||#{board.compute_board_score(player)}|||||||||||||||||||||"
      return board.compute_board_score(player)
    end
    if player.eql?(@turn)
      board.moves[player].each do |move|
        # temp_board = Marshal.load( Marshal.dump(board) )
        temp_board = dup_board(board)

        # p move
        # p temp_board.state[move[0],move[1]]
        # p temp_board.state[move[2],move[3]]
        # p temp_board.state[0,0]
        # p player
        # print_board(temp_board.state)
        temp_board.move([move[0],move[1]],[move[2],move[3]])
        # print_board(temp_board.state)

        
        player.eql?('white') ? player = 'black' : player = 'white'

        board_score = alpha_beta(player,temp_board,depth+1,alpha,beta)

        if board_score > alpha
          @chosen_move = [move[0],move[1],move[2],move[3]] if depth.zero?
          # p @chosen_move
          alpha = board_score
        end

        if alpha >= beta
          return alpha
        end
      end
      return alpha
    else
      board.moves[player].each do |move|
        # temp_board = Marshal.load( Marshal.dump(board) )
        temp_board = dup_board(board)
        # p player
        # print_board(temp_board.state)
        temp_board.move([move[0],move[1]],[move[2],move[3]])
        # print_board(temp_board.state)

        player.eql?('white') ? player = 'black' : player = 'white'

        board_score = alpha_beta(player,temp_board,depth+1,alpha,beta)
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
end


def get_box(co_x,co_y)
    [(co_y - BOARD_SQUARE_POS[:board_start])/BLOCK_DIMENTION,(co_x - BOARD_SQUARE_POS[:board_start])/BLOCK_DIMENTION]
end

def draw_piece(x,y,peice)
    co_y = x*BLOCK_DIMENTION + BLOCK_DIMENTION/2 + BOARD_SQUARE_POS[:board_start]
    co_x = y*BLOCK_DIMENTION + BLOCK_DIMENTION/2 + BOARD_SQUARE_POS[:board_start]

    stroke blue
    strokewidth 4
    fill black if peice.color.eql?('black')
    fill white if peice.color.eql?('white')
    oval top: co_y, left: co_x, radius: 40, center:true
end

def draw_pieces
    CHECKERS_HEIGHT.times do |x|
        CHECKERS_WIDTH.times do |y|
            @pieces[x][y] = draw_piece(x,y,@board.state[x][y]) unless @board.state[x][y].nil?
        end
    end
end

def highlight(box)
    @pieces[box[0]][box[1]].stroke = yellow
end

def de_highlight(box)
    @pieces[box[0]][box[1]].stroke = blue
end

# def move_piece(org,dest)
#     @pieces[org[0]][org[1]].remove
#     @pieces[dest[0]][dest[1]] = draw_piece(dest[0],dest[1],@board.state[dest[0]][dest[1]])
# end
def move_piece(org,dest)
    @pieces[org[0]][org[1]].remove
    @pieces[dest[0]][dest[1]] = draw_piece(dest[0],dest[1],@board.state[dest[0]][dest[1]])
    if (dest[0] - org[0]).abs == 2
      captured_box = [org[0] + (dest[0]-org[0])/2 , org[1] + (dest[1]-org[1])/2]
      @pieces[captured_box[0]][captured_box[1]].remove
    end
end

def capture_piece(org,dest)
    @pieces[org[0]][org[1]].remove
    @pieces[org[0] + (dest[0]-org[0])/2][org[1] + (dest[1]-org[1])/2].remove
    @pieces[dest[0]][dest[1]] = draw_piece(dest[0],dest[1],@board.state[dest[0]][dest[1]])
end


def draw_board
    background rgb(240,248,255)
    fill rgb(210,105,30)
    rect BOARD_SQUARE_POS[:board_start], BOARD_SQUARE_POS[:board_start], BLOCK_DIMENTION*CHECKERS_WIDTH , BLOCK_DIMENTION*CHECKERS_HEIGHT
    fill rgb(245,222,179)
    CHECKERS_HEIGHT.times do |x|
        CHECKERS_WIDTH.times do |y|
            rect BOARD_SQUARE_POS[:board_start] + BLOCK_DIMENTION*x, BOARD_SQUARE_POS[:board_start] + BLOCK_DIMENTION*y, BLOCK_DIMENTION,BLOCK_DIMENTION if x.even? && y.even?
            rect BOARD_SQUARE_POS[:board_start] + BLOCK_DIMENTION*x, BOARD_SQUARE_POS[:board_start] + BLOCK_DIMENTION*y, BLOCK_DIMENTION,BLOCK_DIMENTION if !x.even? && !y.even?
        end
    end
end

Shoes.app(title: "Checkers", width: 850, height: 630, resizable: false) do
    @pieces = Array.new(CHECKERS_WIDTH) { Array.new(CHECKERS_HEIGHT) }
    @game = Checkers.new('white')
    @board = @game.board



    # @human_player = CPU_PLAYER
    @human_player = 'black'
    

    selected = nil

@game.cpu_move


    click do |btn, left, top|
        if @game.turn.eql?(HUMAN_PLAYER)
            if selected.nil?
                clicked_box = get_box(left,top)
                selected = clicked_box if @board.exists?(clicked_box) && @board.piece(clicked_box).color == @human_player
                highlight(selected)
                # @p.replace "selectedasdsa:  #{@game.piece([1,0]).color}" #if @game.exists?(clicked_box)
            else
                dest = get_box(left,top)
                @p.replace "org: #{selected.inspect}, dest: #{dest.inspect} | #{dest[0]} == #{(selected[0]-1)}"
                if @game.user_move(selected, dest)
                    move_piece(selected,dest)
                    de_highlight(selected)
                    selected = nil
                    @game.switch_turn
                else
                    de_highlight(selected)
                    selected = nil
                end
            end
        end
    end

    draw_board
    draw_pieces  
    @c = caption
    @p = para top: 0, left: 300
    @score = para top: 10, left: 620


    # oval top: co_y, left: co_x, radius: 40, center:true
    animate = animate 60 do
        if @game.turn.eql?(CPU_PLAYER)
            @game.cpu_move
            @p.replace "cpu test"
            # move_piece([@game.chosen_move[0],@game.chosen_move[1]],[@game.chosen_move[2],@game.chosen_move[3]])
            @game.switch_turn
        end

    end
 end

