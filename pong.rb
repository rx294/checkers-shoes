# Global constants
HEIGHT = 600
WIDTH = 800
RADIUS = 30
DIAMETER = 2*RADIUS
PADDLE_HEIGHT = 120
PADDLE_WIDTH = 10
ACCELARATION = 1.05

# new_game() -> starts the game and contains animate method which is called continuously until stopped.
def new_game
  # set playing boolean as true
  @playing = true
  # set velocity in x and y direction
  vel_x, vel_y = [8, 10]
  # show ball and set position in center of frame.
  @ball.show
  @ball.top, @ball.left = HEIGHT / 2, WIDTH / 2

  # animate method is kind of a timer and runs on 30 frames per second.
  @animate = animate 30 do
    # start moving ball
    @ball.left += vel_x
    @ball.top += vel_y

    # reflect ball if it hits on top or bottom.
    vel_y = -vel_y if @ball.top + DIAMETER >= HEIGHT or @ball.top <= 0

    # move computer's paddle
    @comp.top =
      @ball.top + RADIUS - PADDLE_HEIGHT / 2 if @comp.top >= 0 or @comp.top <= HEIGHT - PADDLE_HEIGHT
      0 if @comp.top < 0
      HEIGHT - PADDLE_HEIGHT if @comp.top > HEIGHT - PADDLE_HEIGHT

    # check if ball hits side walls
    if @ball.left + DIAMETER >= WIDTH - PADDLE_WIDTH or @ball.left   <= PADDLE_WIDTH
      # check if ball hits any of the paddle
      unless (@ball.left <= PADDLE_WIDTH and (@you.top..@you.top+PADDLE_HEIGHT).include? @ball.top + RADIUS) or (@ball.left + DIAMETER >= WIDTH - PADDLE_WIDTH and (@comp.top..@comp.top+PADDLE_HEIGHT).include? @ball.top + RADIUS)
        # stop the game if not and announce a winner
        stop "User" if @ball.left + DIAMETER >= WIDTH - PADDLE_WIDTH
        stop "Computer" if @ball.left <= PADDLE_WIDTH
      end
      # reflect ball if it hits a paddle and increase 5% speed.
      vel_x = -vel_x * ACCELARATION
    end
  end
  # move user's paddle according to mouse movement.
  motion { |x, y| @you.top = y - PADDLE_HEIGHT / 2 }
end

# stop() -> called whenever ball is missed by any of the player
def stop winner
  # set playing boolean to false
  @playing = false
  # stop animation, hide ball, display messages
  @animate.stop
  @ball.hide
  @banner = banner "Game Over.", align: "center"
  alert "#{winner} won."
  @subtitle = stack { subtitle "Press Space Bar or 'n' to start new game.", align: "center" }
end

Shoes.app title: "Pong", height: HEIGHT, width: WIDTH, resizable: false do
  # spawn a ball, two paddles and display messages.
  stack { banner "Pong", align: "center" }
  @ball = oval top: HEIGHT / 2, left: WIDTH / 2, radius: RADIUS, fill: "#FD1"
  @you, @comp = [0, WIDTH - PADDLE_WIDTH].map {|x| rect top: HEIGHT / 2,
    left: x,
    height: PADDLE_HEIGHT,
    width: PADDLE_WIDTH,
    curve: 2
  }
  @banner = stack { banner "New game", align: "center" }
  @subtitle = stack { subtitle "Press Space Bar or 'n' to start.", align: "center" }
  # start the game by calling new_game when space bar or 'n' key is pressed.
  keypress do |key|
    if (key == " " or key == "n") and (not @playing)
      @banner.remove
      @subtitle.remove
      new_game
    end
  end
end