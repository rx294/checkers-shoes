require_relative 'blah'


piece = Piece.new('black')


board = Board.new


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

Shoes.app do
  Shoes::show_console
  para "#{Time.now}\n"    
  para "#{Time.local(2015, 06, 19)}\n"
  $stderr.puts "do you see this?"
end

Shoes.app(title: "Checkers", width: 850, height: 630, resizable: false) do
    @pieces = Array.new(CHECKERS_WIDTH) { Array.new(CHECKERS_HEIGHT) }
    @game = Checkers.new('black')
    @board = @game.board



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
    animate = animate 60 do

        if @game.turn.eql?(CPU_PLAYER)
            @game.cpu_move
            @p.replace "cpu test#{@game.chosen_move}"
            # move_piece([1,0],[2,1])
            move_piece([@game.chosen_move[0],@game.chosen_move[1]],[@game.chosen_move[2],@game.chosen_move[3]])
            @game.switch_turn
        end
    end
 end

