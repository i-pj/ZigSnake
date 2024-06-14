const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

pub const Snake = struct {
    x: i32,
    y: i32,
    speed: i32,
    direction: Direction,

    pub fn init(x: i32, y: i32, speed: i32) Snake {
        return Snake{
            .x = x,
            .y = y,
            .speed = speed,
            .direction = .right,
        };
    }

    pub fn move(self: *Snake) void {
        switch (self.direction) {
            .up => self.y -= self.speed,
            .down => self.y += self.speed,
            .left => self.x -= self.speed,
            .right => self.x += self.speed,
        }
    }

    pub const Direction = enum(i32) {
        up,
        down,
        left,
        right,
    };
};

pub const Food = struct {
    x: i32,
    y: i32,

    pub fn init(x: i32, y: i32) Food {
        return Food{
            .x = x,
            .y = y,
        };
    }
};

pub const Game = struct {
    snake: Snake,
    food: Food,
    score: i32,

    pub fn init() Game {
        return Game{
            .snake = Snake.init(7, 7, 1),
            .food = Food.init(rl.GetRandomValue(0, 14), rl.GetRandomValue(0, 14)),
            .score = 0,
        };
    }

    pub fn update(self: *Game) void {
        self.snake.move();
        if (self.snake.x == self.food.x and self.snake.y == self.food.y) {
            self.score += 1;
            self.food = Food.init(rl.GetRandomValue(0, 14), rl.GetRandomValue(0, 14));
        }
    }

    pub fn draw(self: *Game) void {
        rl.DrawRectangle(self.snake.x * 40, self.snake.y * 40, 40, 40, rl.Color{ .r = 255, .g = 0, .b = 0, .a = 255 });
        rl.DrawRectangle(self.food.x * 40, self.food.y * 40, 40, 40, rl.Color{ .r = 0, .g = 255, .b = 0, .a = 255 });
        var score_buffer: [20]u8 = undefined;
        var fbs = std.io.fixedBufferStream(&score_buffer);
        var writer = fbs.writer();
        fbs.seekTo(0) catch unreachable;
        writer.print("Score: {}\x00", .{self.score}) catch unreachable;
        rl.DrawText(score_buffer[0..], 10, 10, 20, rl.Color{ .r = 255, .g = 255, .b = 255, .a = 255 });
    }
};

pub fn main() !void {
    rl.InitWindow(600, 600, "SNAKE GAME");
    rl.SetTargetFPS(60);

    var game = Game.init();

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.Color{ .r = 173, .g = 255, .b = 47, .a = 255 }); //green color

        game.update();
        game.draw();
    }
}
