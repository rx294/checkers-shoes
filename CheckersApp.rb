# @name    Checkers
# @author  Rony Xavier
# @version 1.0, 04/23/2018

require_relative 'Checkers'
require_relative 'Board'

#======================================= HELPER METHODS =======================================#

# Draw the checkers board
def draw_board
  @board = stack do
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
end

# Identify the box that was clicked
def get_clicked_box(co_x,co_y)
    [(co_y - BOARD_SQUARE_POS[:board_start])/BLOCK_DIMENTION,(co_x - BOARD_SQUARE_POS[:board_start])/BLOCK_DIMENTION]
end

# Get the co-ordinates at which the peice is to be drawn
def get_co_x_y(x,y)
    co_y = x*BLOCK_DIMENTION + BLOCK_DIMENTION/2 + BOARD_SQUARE_POS[:board_start]
    co_x = y*BLOCK_DIMENTION + BLOCK_DIMENTION/2 + BOARD_SQUARE_POS[:board_start]
    return co_x,co_y
end

# Draw a single peice of checkboard
def draw_piece(x,y,peice)
    co_x, co_y = get_co_x_y(x,y)
    stroke blue
    strokewidth 4
    fill black if peice.color.eql?('black')
    fill white if peice.color.eql?('white')
    oval top: co_y, left: co_x, radius: 40, center:true
end


# Draw the peices at the beginning of the game
def draw_pieces
    CHECKERS_HEIGHT.times do |x|
        CHECKERS_WIDTH.times do |y|
            @pieces[x][y].remove unless @pieces[x][y].nil?
            @pieces[x][y] = draw_piece(x,y,@board.state[x][y]) unless @board.state[x][y].nil?
        end
    end
end

# Remove all pieces from the board in case of restart
def remove_pieces
    CHECKERS_HEIGHT.times do |x|
        CHECKERS_WIDTH.times do |y|
            @pieces[x][y].remove unless @pieces[x][y].nil?
        end
    end
end

# check if a piece has been selected
def piece_selected?
  !@selected_piece.nil?
end

# Deselect selected peice
def deselect_piece
  @selected_piece = nil
end

# Highlight a selected piece
def highlight(box)
    @pieces[box[0]][box[1]].stroke = yellow
end

# Remove piece highlight
def de_highlight(box)
    @pieces[box[0]][box[1]].stroke = blue
end

# Move piece on the board
def move_piece(org,dest)
    # remove catured piece if capture move
    if (dest[0] - org[0]).abs == 2
      captured_box = [org[0] + (dest[0]-org[0])/2 , org[1] + (dest[1]-org[1])/2]
      @pieces[captured_box[0]][captured_box[1]].remove
    end

    @pieces[org[0]][org[1]].remove
    @pieces[dest[0]][dest[1]] = draw_piece(dest[0],dest[1],@board.state[dest[0]][dest[1]])
end

# Diplay game Statistics
def update_stats
    @msg.replace        "Message: #{@message}\n"
    @whos_turn.replace  "TURN       :#{@game.turn.upcase}"
    @b_score.replace    "BLACK SCORE:#{@game.score(HUMAN_PLAYER)}"
    @w_score.replace    "WHITE SCORE:#{@game.score(CPU_PLAYER)}"
    @time_taken.replace "TIME TAKEN :#{@game.time_taken}s " 
    @max_depth.replace  "MAX DEPTH  :#{@game.max_depth}" 
    @max_nodes.replace  "MAX NODES  :#{@game.max_nodes}"
    @max_prunes.replace  "MAX PRUNES  :#{@game.max_prunes}"
    @min_prunes.replace  "MIN PRUNES  :#{@game.min_prunes}"
end

# Show winner information if game over
def show_winner
  if (@game.score(CPU_PLAYER) == @game.score(HUMAN_PLAYER))
    @message = "Game over\n\n Its a DRAW people!!!" 
  elsif (@game.score(CPU_PLAYER)>@game.score(HUMAN_PLAYER))
    @message = "Game over\n\nWINNER: #{CPU_PLAYER.upcase}!!!"
  else
    @message = "Game over\n\nWINNER: #{HUMAN_PLAYER.upcase}!!!"
  end
  @message += "\n\nBLACK SCORE:#{@game.score(HUMAN_PLAYER)}\nWHITE SCORE:#{@game.score(CPU_PLAYER)}"

  alert("#{@message}")
end

# Select a piece based on the clicked co-ordinates
def select_piece(left,top)
  clicked_box = get_clicked_box(left,top)
  # select the piece if the piece exists and is a human player piece
  @selected_piece = clicked_box if @board.exists?(clicked_box) && @board.piece(clicked_box).color == HUMAN_PLAYER
  highlight(@selected_piece)
end

# Move the selected piece to click destination
def make_move(left,top)
  # get destination selected
  dest = get_clicked_box(left,top)
  # try to make the move on the board; @game.user_move returns false if move is not allowed
  if @game.user_move(@selected_piece, dest)
      # move the piece on the GUI boars
      move_piece(@selected_piece,dest)
      de_highlight(@selected_piece)
      deselect_piece
      # switch player turn after the move
      @game.switch_turn
  else
      # if move not allowed deselect and de highlight the piece
      de_highlight(@selected_piece)
      deselect_piece
  end
end

# Method initialized the game
def start_game
  # remove all pieces in case of a restart
  remove_pieces unless @pieces.nil?
  # initialize a new game board
  @board = Board.new
  # initialize pieces for the GUI board
  @pieces = Array.new(CHECKERS_WIDTH) { Array.new(CHECKERS_HEIGHT) }
  # Start a new game with :starting player turn, created board, CPU player and difficulty 
  @game = Checkers.new(@first_player.text.downcase, @board, CPU_PLAYER, DIFFICULTY[@difficulty.text])
  draw_pieces
  @selected_piece = nil
  @message = "None"
  # Display game statistics
  update_stats
  # toggle game status to running
  @game_running = true
end

# check if game is running
def game_running?
  @game_running
end

#======================================= GAME MAIN =======================================#

# Start GUI
Shoes.app(title: "Checkers", width: 850, height: 630, resizable: false) do

  # toggle for game running status
  @game_running = false
  background rgb(240,248,255)
  draw_board

  # Display game selection menu
  @menu = stack left: 620,top: 10, width: 220 do
    para "First Player:"
    @first_player = list_box :items => ["BLACK", "WHITE"]
    para "Difficulty:"
    @difficulty = list_box :items => ["EASY", "MEDIUM", "HARD"]
    @start = button "START/RESTART", top: 160, font: "Menlo Bold 14",width: 220
  end

  # Setup game statistic display
  @stats = stack left: 620,top: 270, width: 220 do
     @msg = para 
     @whos_turn = para
     @b_score = para 
     @w_score = para 
     @time_taken = para 
     @max_depth = para 
     @max_nodes = para 
     @max_prunes = para
     @min_prunes = para
  end

  @start.click { start_game }

  # Listen of user mouse input if game is running and if is the users turn
  click do |btn, left, top|
    if game_running?
      if @game.turn.eql?(HUMAN_PLAYER)
        # select a piece if no piece has not be selected yet
        if !piece_selected?
          select_piece(left,top)
        else
          # make the move to clicked destination
          make_move(left,top)
          update_stats
        end
      end
    end
  end 

  # Main Game Loop to be run as long as the game is still running
  animate = animate 24 do
    if game_running?
      update_stats
      # if game is over show winner information
      if @game.game_over?
        show_winner
        @game_running = false
      end
      # if Human player has no turns left switch turn to CPU player
      if @game.turn.eql?(HUMAN_PLAYER) && !@game.moves_available?(HUMAN_PLAYER)
        @message = "no moves for #{HUMAN_PLAYER.upcase}"
        @game.switch_turn
      end
      # if CPU player has no turns left switch turn to Human player
      if @game.turn.eql?(CPU_PLAYER) && !@game.moves_available?(CPU_PLAYER)
        @message ="no moves for #{CPU_PLAYER.upcase}"
        @game.switch_turn
      end
      # if it is CPU player's turn compute and perform the move
      if @game.turn.eql?(CPU_PLAYER)
        # compute and make the board on the game board
        @game.cpu_move
        # introduce a slight delay so the CPU move is visible to the user
        sleep(0.5)
        # make the move on the GUI board
        move_piece([@game.chosen_move[0],@game.chosen_move[1]],[@game.chosen_move[2],@game.chosen_move[3]])
        @game.switch_turn
      end
    end
  end
end

