require_relative 'Checkers1'


DIFFICULTY = {
  'EASY' => 1,
  'MEDIUM' => 7,
  'HARD' => 14,
}

def get_box(co_x,co_y)
    [(co_y - BOARD_SQUARE_POS[:board_start])/BLOCK_DIMENTION,(co_x - BOARD_SQUARE_POS[:board_start])/BLOCK_DIMENTION]
end

def draw_piece(x,y,peice)
    # co_y = x*BLOCK_DIMENTION + BLOCK_DIMENTION/2 + BOARD_SQUARE_POS[:board_start]
    # co_x = y*BLOCK_DIMENTION + BLOCK_DIMENTION/2 + BOARD_SQUARE_POS[:board_start]
    co_x, co_y = get_co_x_y(x,y)
    stroke blue
    strokewidth 4
    fill black if peice.color.eql?(HUMAN_PLAYER)
    fill white if peice.color.eql?(CPU_PLAYER)
    oval top: co_y, left: co_x, radius: 40, center:true
end

def get_co_x_y(x,y)
    co_y = x*BLOCK_DIMENTION + BLOCK_DIMENTION/2 + BOARD_SQUARE_POS[:board_start]
    co_x = y*BLOCK_DIMENTION + BLOCK_DIMENTION/2 + BOARD_SQUARE_POS[:board_start]
    return co_x,co_y
end

def draw_pieces
    CHECKERS_HEIGHT.times do |x|
        CHECKERS_WIDTH.times do |y|
            @pieces[x][y].remove unless @pieces[x][y].nil?
            @pieces[x][y] = draw_piece(x,y,@board.state[x][y]) unless @board.state[x][y].nil?
        end
    end
end

def remove_pieces
    CHECKERS_HEIGHT.times do |x|
        CHECKERS_WIDTH.times do |y|
            @pieces[x][y].remove unless @pieces[x][y].nil?
        end
    end
end

def highlight(box)
    @pieces[box[0]][box[1]].stroke = yellow
end

def de_highlight(box)
    @pieces[box[0]][box[1]].stroke = blue
end

def move_piece(org,dest)
    if (dest[0] - org[0]).abs == 2
      captured_box = [org[0] + (dest[0]-org[0])/2 , org[1] + (dest[1]-org[1])/2]
      @pieces[captured_box[0]][captured_box[1]].remove
    end

    @pieces[org[0]][org[1]].remove
    @pieces[dest[0]][dest[1]] = draw_piece(dest[0],dest[1],@board.state[dest[0]][dest[1]])
end

def capture_piece(org,dest)
    @pieces[org[0]][org[1]].remove
    @pieces[org[0] + (dest[0]-org[0])/2][org[1] + (dest[1]-org[1])/2].remove
    @pieces[dest[0]][dest[1]] = draw_piece(dest[0],dest[1],@board.state[dest[0]][dest[1]])
end


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


def update_stats
    @msg.replace        "Message: #{@message}\n"
    @whos_turn.replace  "TURN       :#{@game.turn}"
    @b_score.replace    "BLACK SCORE:#{@game.score(HUMAN_PLAYER)}"
    @w_score.replace    "WHITE SCORE:#{@game.score(CPU_PLAYER)}"
    @time_taken.replace "TIME TAKEN :#{@game.time_taken}s " 
    @max_depth.replace  "MAX DEPTH  :#{@game.max_depth}" 
    @max_nodes.replace  "MAX NODES  :#{@game.max_nodes}"
end

def select_piece(left,top)
  clicked_box = get_box(left,top)
  @selected_piece = clicked_box if @board.exists?(clicked_box) && @board.piece(clicked_box).color == HUMAN_PLAYER
  highlight(@selected_piece)
end

def piece_selected?
  !@selected_piece.nil?
end

def deselect_piece
  @selected_piece = nil
end

def make_move(left,top)
  dest = get_box(left,top)
  if @game.user_move(@selected_piece, dest)
      move_piece(@selected_piece,dest)
      de_highlight(@selected_piece)
      deselect_piece
      @game.switch_turn
  else
      de_highlight(@selected_piece)
      deselect_piece
  end
end


def start_game
  remove_pieces unless @pieces.nil?
  @board = Board.new
  @pieces = Array.new(CHECKERS_WIDTH) { Array.new(CHECKERS_HEIGHT) }
  @game = Checkers.new(@first_player.text, @board, CPU_PLAYER, DIFFICULTY[@difficulty.text])
  draw_pieces
  @selected_piece = nil
  @message = "None"
  update_stats
  @game_running = true
end

def game_running?
  @game_running
end
Shoes.app(title: "Checkers", width: 850, height: 630, resizable: false) do
  
  @game_running = false
  background rgb(240,248,255)
  draw_board

  @menu = stack left: 620,top: 10, width: 220 do
    para "First Player:"
    @first_player = list_box :items => ["BLACK", "WHITE"]
    para "Difficulty:"
    @difficulty = list_box :items => ["EASY", "MEDIUM", "HARD"]
    @start = button "START/RESTART", top: 160, font: "Menlo Bold 14",width: 220
  end

  @stats = stack left: 620,top: 360, width: 220 do
     @msg = para 
     @whos_turn = para
     @b_score = para 
     @w_score = para 
     @time_taken = para 
     @max_depth = para 
     @max_nodes = para 
  end

  @start.click { start_game }

  click do |btn, left, top|
    if game_running?
      if @game.turn.eql?(HUMAN_PLAYER)
        if !piece_selected?
          select_piece(left,top)
        else
          make_move(left,top)
          update_stats
        end
      end
    end
  end 


  animate = animate 24 do
    if game_running?
      update_stats
      if @game.game_over?
        @message = "WINNER: #{(@game.score(CPU_PLAYER)>@game.score(HUMAN_PLAYER)) ? CPU_PLAYER : HUMAN_PLAYER}"
        alert("Game over\n\n WINNER: #{(@game.score(CPU_PLAYER)>@game.score(HUMAN_PLAYER)) ? CPU_PLAYER : HUMAN_PLAYER}\n\nBLACK SCORE:#{@game.score(CPU_PLAYER)}\nWHITE SCORE:#{@game.score(HUMAN_PLAYER)}")
        animate.stop
        @game_running = false
      end
      if @game.turn.eql?(HUMAN_PLAYER) && !@game.moves_available?(HUMAN_PLAYER)
        @message = "no moves for #{HUMAN_PLAYER}"
        @game.switch_turn
      end
      if @game.turn.eql?(CPU_PLAYER) && !@game.moves_available?(CPU_PLAYER)
        @message ="no moves for #{CPU_PLAYER}"
        @game.switch_turn
      end
      if @game.turn.eql?(CPU_PLAYER)
        @game.cpu_move
        move_piece([@game.chosen_move[0],@game.chosen_move[1]],[@game.chosen_move[2],@game.chosen_move[3]])
        @game.switch_turn
        sleep(0.5)
      end
    end
  end
end

