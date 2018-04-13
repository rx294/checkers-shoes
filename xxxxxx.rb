require_relative 'blewer'


piece = Piece.new('black')


board = Board.new


def get_box(co_x,co_y)
    [(co_y - BOARD_SQUARE_POS[:board_start])/BLOCK_DIMENTION,(co_x - BOARD_SQUARE_POS[:board_start])/BLOCK_DIMENTION]
end

def draw_piece(x,y,peice)
    # co_y = x*BLOCK_DIMENTION + BLOCK_DIMENTION/2 + BOARD_SQUARE_POS[:board_start]
    # co_x = y*BLOCK_DIMENTION + BLOCK_DIMENTION/2 + BOARD_SQUARE_POS[:board_start]
    co_x, co_y = get_co_x_y(x,y)
    stroke blue
    strokewidth 4
    fill black if peice.color.eql?('black')
    fill white if peice.color.eql?('white')
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
    if (dest[0] - org[0]).abs == 2
      captured_box = [org[0] + (dest[0]-org[0])/2 , org[1] + (dest[1]-org[1])/2]
      @pieces[captured_box[0]][captured_box[1]].remove
    end


    # @pieces[org[0]][org[1]].remove
    # @pieces[dest[0]][dest[1]] = draw_piece(org[0] + (dest[0]-org[0])*1/10 ,org[0] + (dest[0]-org[0])*1/10,@board.state[dest[0]][dest[1]])

    # sleep(0.25)

        # co_x, co_y = get_co_x_y(org[0] + (dest[0]-org[0])*1/10 ,org[0] + (dest[0]-org[0])*1/10)
        # @pieces[org[0]][org[1]].top = co_y
        # @pieces[org[0]][org[1]].left = co_x
        # sleep(1)
        # co_x, co_y = get_co_x_y(org[0] + (dest[0]-org[0])*2/10 ,org[0] + (dest[0]-org[0])*2/10)
        # @pieces[org[0]][org[1]].top = co_y
        # @pieces[org[0]][org[1]].left = co_x
        # sleep(1)
        # co_x, co_y = get_co_x_y(org[0] + (dest[0]-org[0])*4/10 ,org[0] + (dest[0]-org[0])*4/10)
        # @pieces[org[0]][org[1]].top = co_y
        # @pieces[org[0]][org[1]].left = co_x
        # sleep(1)
        # co_x, co_y = get_co_x_y(org[0] + (dest[0]-org[0])*6/10 ,org[0] + (dest[0]-org[0])*6/10)
        # @pieces[org[0]][org[1]].top = co_y
        # @pieces[org[0]][org[1]].left = co_x
        # sleep(1)
        # co_x, co_y = get_co_x_y(org[0] + (dest[0]-org[0])*8/10 ,org[0] + (dest[0]-org[0])*8/10)
        # @pieces[org[0]][org[1]].top = co_y
        # @pieces[org[0]][org[1]].left = co_x
        # sleep(1)


    @pieces[org[0]][org[1]].remove
    # @pieces[dest[0]][dest[1]].remove
    @pieces[dest[0]][dest[1]] = draw_piece(dest[0],dest[1],@board.state[dest[0]][dest[1]])
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

# Shoes.app do
#   para "#{Time.now}\n"    
#   para "#{Time.local(2015, 06, 19)}\n"
#   $stderr.puts "do you see this?"
# end

Shoes.app(title: "Checkers", width: 850, height: 630, resizable: false) do
# Shoes.app(title: "Checkers", width: 1000, height: 1000, resizable: false) do
    @pieces = Array.new(CHECKERS_WIDTH) { Array.new(CHECKERS_HEIGHT) }
    @board = Board.new
    @game = Checkers.new('white',@board,'white',10)

    # @board = @game.board

  Shoes::show_console


    # @human_player = CPU_PLAYER
    @human_player = 'black'
    

    selected = nil

# @game.cpu_move


    click do |btn, left, top|
        if @game.turn.eql?(HUMAN_PLAYER)
            if selected.nil?
                clicked_box = get_box(left,top)
                selected = clicked_box if @board.exists?(clicked_box) && @board.piece(clicked_box).color == @human_player
                highlight(selected)
                # @p.replace "selectedasdsa:  #{@game.piece([1,0]).color}" #if @game.exists?(clicked_box)
            else
                dest = get_box(left,top)
                @p.replace "org: #{RUBY_VERSION}|| #{selected.inspect}, dest: #{dest.inspect} | #{dest[0]} == #{(selected[0]-1)}"
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
    animate = animate 30 do
        if @game.game_over?
            $stderr.puts "--------------Game over:--------------"#{}" #{@game.score}"
            $stderr.puts "--------------Black:#{@game.score(HUMAN_PLAYER)}--------------"#{}" #{@game.score}"
            $stderr.puts "--------------White:#{@game.score(CPU_PLAYER)}--------------"#{}" #{@game.score}"
            # banner "Game Over", :align => 'center', :stroke => black
            animate.stop
        end
        # $stderr.puts "Game over?: #{@game.game_over?}"
        if @game.turn.eql?(HUMAN_PLAYER) && !@game.moves_available?(HUMAN_PLAYER)
            $stderr.puts "no moves for #{HUMAN_PLAYER}"
            @game.switch_turn
        end
        if @game.turn.eql?(CPU_PLAYER) && !@game.moves_available?(CPU_PLAYER)
            $stderr.puts "no moves for #{CPU_PLAYER}"
            @game.switch_turn
        end
        if @game.turn.eql?(CPU_PLAYER)
            start_t = Time.now
            @game.cpu_move
            $stderr.puts "Time taken: #{Time.now - start_t}s"
            $stderr.puts "Chosen Move: #{@game.chosen_move}"
            move_piece([@game.chosen_move[0],@game.chosen_move[1]],[@game.chosen_move[2],@game.chosen_move[3]])
            @game.switch_turn
        end
    end
 end

