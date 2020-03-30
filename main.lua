push = require 'push'

Class = require 'Class'

require 'Ball'

require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
BALL_SPEED_INCREASE = 1.05

POINTS_TO_WIN = 3

function love.load()
    love.window.setTitle("PONG")

    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    math.randomseed(os.time())

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

    player1Score = 0
    player2Score = 0
    servingPlayer = 1
    winner = 0

    gameState = 'start'
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'match' then
            gameState = 'serve'
            player1Score = 0
            player2Score = 0
        end
    end
end

function love.update(dt)
    if gameState == 'serve' then
        if player1Score == POINTS_TO_WIN then
            winner = 1
            gameState = 'match'
        end

        if player2Score == POINTS_TO_WIN then
            winner = 2
            gameState = 'match'
        end

        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        if ball.y < 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        if ball.y + ball.height > VIRTUAL_HEIGHT then
            ball.y = VIRTUAL_HEIGHT - ball.height
            ball.dy = -ball.dy
        end

        if ball:collides(player1) then
            ball.dx = -ball.dx * BALL_SPEED_INCREASE
            ball.x = player1.x + player1.width
            ball.dy = math.min(100, math.max(-100, ball.dy + player1.dy / 5))
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * BALL_SPEED_INCREASE
            ball.x = player2.x - ball.width
            ball.dy = math.min(100, math.max(-100, ball.dy + player2.dy / 5))
        end

        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            ball:reset()
            gameState = 'serve'
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            ball:reset()
            gameState = 'serve'
        end

        ball:update(dt)
    end

    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    player1:update(dt)
    player2:update(dt)
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 1)
    love.graphics.setFont(smallFont)

    displayScore()

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'match' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player ' .. tostring(winner) .. ' wins!',
            0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to start a new match!', 0, 20, VIRTUAL_WIDTH, 'center')
    end

    player1:render()
    player2:render()

    ball:render()

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)
end