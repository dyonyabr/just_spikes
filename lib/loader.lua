require "lib.shaders"
require "lib.tools"
Timer = require "lib.Timer"

colors = {
    shadow = { 0, 0, 0, 0 }
}

fonts = {
    score = love.graphics.newFont("assets/fonts/font.ttf", 288),
    default = love.graphics.newFont("assets/fonts/font.ttf", 96)
}

sounds = {
    click = love.audio.newSource("assets/sound/click.wav", "static")
}
