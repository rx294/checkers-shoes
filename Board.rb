# @name    Checkers
# @author  Rony Xavier
# @version 1.0, 04/23/2018

#======================================= PIECE CLASS =======================================#

class Piece
  attr_reader :color
  
  def initialize(color)
    @color = color
  end
end

#======================================= BOARD CLASS =======================================#

class Board
  attr_reader :state, :score, :moves, :pieces

  def initialize
    @state = Array.new(CHECKERS_WIDTH) { Array.new(CHECKERS_HEIGHT) }
    # store available moves for each player
    @moves = {'black'=> [], 'white'=> []}
    # store available pieces for each player
    @pieces = {'black'=> [], 'white'=> []}

    # initialize board based on INITIAL_BOARD value
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
    # compute available moves for each player
    compute_available_moves
  end

  # check if a piece exits in the specified box
  def exists?(box)
    !outofbounds?(box) && !@state[box[0]][box[1]].nil? 
  end

  # return available moves for the specified user 
  def moves(player)
    @moves[player].sample(@moves[player].count)
  end

  # return piece object in the specified box
  def piece(box)
    @state[box[0]][box[1]]
  end

  # check if the specified move is allowed
  def can_move?(org,dest)
    return false if exists?(dest) || outofbounds?(org) || outofbounds?(dest)
    return true if piece(org).color.eql?('white') && (org[0]- dest[0]).eql?(-1) && [-1,1].include?(dest[1] - org[1])
    return true if piece(org).color.eql?('black') && (org[0]- dest[0]).eql?( 1) && [-1,1].include?(dest[1] - org[1])
    false 
  end

  # check if the specified capture move is allowed
  def can_capture?(org,dest)
    return false if exists?(dest) || outofbounds?(org) || outofbounds?(dest)
    return true if piece(org).color.eql?('white') && (org[0]- dest[0]).eql?(-2) && [-2,2].include?(dest[1] - org[1]) && exists?([org[0] + (dest[0]-org[0])/2, org[1] + (dest[1]-org[1])/2]) && piece([org[0] + (dest[0]-org[0])/2, org[1] + (dest[1]-org[1])/2]).color.eql?('black')
    return true if piece(org).color.eql?('black') && (org[0]- dest[0]).eql?( 2) && [-2,2].include?(dest[1] - org[1]) && exists?([org[0] + (dest[0]-org[0])/2, org[1] + (dest[1]-org[1])/2]) && piece([org[0] + (dest[0]-org[0])/2, org[1] + (dest[1]-org[1])/2]).color.eql?('white')
    false 
  end

  # check if the specified box is out of bounds
  def outofbounds?(box)
    box[0] < 0 || box[0] >= CHECKERS_HEIGHT || box[1] < 0 || box[1] >= CHECKERS_WIDTH
  end

  # perform specified move
  def move(org,dest)
      @state[dest[0]][dest[1]] = @state[org[0]][org[1]]
      @pieces[piece(org).color].delete(org)
      @pieces[piece(org).color].push(dest)
      @state[org[0]][org[1]] = nil

      # perform capture of it is a capture move
      if (dest[0] - org[0]).abs == 2
        captured_box = [org[0] + (dest[0]-org[0])/2 , org[1] + (dest[1]-org[1])/2]
        @pieces[piece(captured_box).color].delete(captured_box)
        @state[captured_box[0]][captured_box[1]] = nil
      end
      # re-compute available moves for both players after the move
      compute_available_moves
  end

  # compute available moves and store in @moves
  # if capture moves are available only those moves are recorded
  # if a capture move is not available other moves are recorded 
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

  # calculate the terminal utility value of the move
  # for equal piece count return 0
  # if piece count of the specified player is higher than the other player return MAX_TERMINAL_VAL
  # if piece count of the specified player is lower  than the other player return MIN_TERMINAL_VAL
  def utility(player)
    score = @pieces[player].count - @pieces[other_player(player)].count
    return 0 if score.zero?
    return MAX_TERMINAL_VAL if score > 0
    return MIN_TERMINAL_VAL if score < 0
  end


  # Evaluation function returns piece count of the specified player - other player times 10
  def evaluate(player)
    (pieces[player].count - pieces[other_player(player)].count)*10
  end
end