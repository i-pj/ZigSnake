const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
});

pub const SNAKE_LENGTH = 256;
pub const SQUARE_SIZE = 31;

pub const Snake = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    speed: rl.Vector2,
    color: rl.Color,

    fn init() Snake {
        return Snake{
            .position = rl.Vector2Zero(),
            .size = rl.Vector2{ .x = @as(f32, SQUARE_SIZE), .y = @as(f32, SQUARE_SIZE) },
            .speed = rl.Vector2{ .x = @as(f32, SQUARE_SIZE), .y = 0 },
            .color = rl.DARKBLUE,
        };
    }
};

pub const Food = struct {
    position: rl.Vector2,
    size: rl.Vector2,
    active: bool,
    color: rl.Color,

    fn init() Food {
        return Food{
            .position = rl.Vector2Zero(),
            .size = rl.Vector2{ .x = @as(f32, SQUARE_SIZE), .y = @as(f32, SQUARE_SIZE) },
            .active = false,
            .color = rl.SKYBLUE,
        };
    }
};
var screenWidth: i32 = 800;
var screenHeight: i32 = 450;

var framesCounter: i32 = 0;
var gameOver: bool = false;
var pause: bool = false;

var fruit: Food = Food.init();
var snake: [SNAKE_LENGTH]Snake = undefined;
var snakePosition: [SNAKE_LENGTH]rl.Vector2 = undefined;
var allowMove: bool = false;
var offset: rl.Vector2 = rl.Vector2Zero();
var counterTail: i32 = 0;

fn InitGame() void {
    framesCounter = 0;
    gameOver = false;
    pause = false;

    counterTail = 1;
    allowMove = false;

    // for screen position
    offset = rl.Vector2{
        .x = @as(f32, @floatFromInt(@rem(screenWidth, SQUARE_SIZE))), // @rem calculates remainder
        .y = @as(f32, @floatFromInt(@rem(screenHeight, SQUARE_SIZE))), // and @as does conversion between types(https://ziglang.org/documentation/master/#as)
    };

    // snake positions
    for (&snake) |*snake_part| {
        snake_part.* = Snake.init();
        snake_part.position = rl.Vector2{ .x = offset.x / 2, .y = offset.y / 2 };
        if (snake_part != &snake[0]) {
            snake_part.color = rl.BLUE;
        }
    }

    // snake positions array
    for (&snakePosition) |*position| {
        position.* = rl.Vector2Zero();
    }

    fruit.size = rl.Vector2{ .x = @as(f32, SQUARE_SIZE), .y = @as(f32, SQUARE_SIZE) };
    fruit.color = rl.SKYBLUE;
    fruit.active = false;
}

fn UpdateGame() void {
    if (!gameOver) {
        if (rl.IsKeyPressed(rl.KEY_P)) {
            pause = !pause;
        }

        if (!pause) {
            // Player controls
            if (rl.IsKeyPressed(rl.KEY_RIGHT) and (snake[0].speed.x == 0) and allowMove) {
                snake[0].speed = rl.Vector2{ .x = @as(f32, SQUARE_SIZE), .y = 0 };
                allowMove = false;
            }
            if (rl.IsKeyPressed(rl.KEY_LEFT) and (snake[0].speed.x == 0) and allowMove) {
                snake[0].speed = rl.Vector2{ .x = @as(f32, -SQUARE_SIZE), .y = 0 };
                allowMove = false;
            }
            if (rl.IsKeyPressed(rl.KEY_UP) and (snake[0].speed.y == 0) and allowMove) {
                snake[0].speed = rl.Vector2{ .x = 0, .y = @as(f32, -SQUARE_SIZE) };
                allowMove = false;
            }
            if (rl.IsKeyPressed(rl.KEY_DOWN) and (snake[0].speed.y == 0) and allowMove) {
                snake[0].speed = rl.Vector2{ .x = 0, .y = @as(f32, SQUARE_SIZE) };
                allowMove = false;
            }
            // Snake movement
            var j: usize = 0;
            while (j < @as(usize, @intCast(counterTail))) : (j += 1) {
                snakePosition[j] = snake[j].position;
            }

            if (@rem(framesCounter, 5) == 0) {
                j = 0;
                while (j < @as(usize, @intCast(counterTail))) : (j += 1) {
                    if (j == 0) {
                        snake[0].position = rl.Vector2Add(snake[0].position, snake[0].speed);
                        allowMove = true;
                    } else {
                        snake[j].position = snakePosition[j - 1];
                    }
                }
            }

            // Wall behaviour
            if ((snake[0].position.x > (@as(f32, @floatFromInt(screenWidth)) - offset.x)) or
                (snake[0].position.y > (@as(f32, @floatFromInt(screenHeight)) - offset.y)) or
                (snake[0].position.x < 0) or (snake[0].position.y < 0))
            {
                gameOver = true;
            }

            // Collision with self check!
            j = 1;
            while (j < @as(usize, @intCast(counterTail))) : (j += 1) {
                if (snake[0].position.x == snake[j].position.x and snake[0].position.y == snake[j].position.y) {
                    gameOver = true;
                    break;
                }
            }

            // Fruit position calculation
            if (!fruit.active) {
                fruit.active = true;
                fruit.position = rl.Vector2{
                    .x = @as(f32, @floatFromInt(rl.GetRandomValue(0, @divTrunc(screenWidth, SQUARE_SIZE) - 1) * SQUARE_SIZE)) + (offset.x / 2),
                    .y = @as(f32, @floatFromInt(rl.GetRandomValue(0, @divTrunc(screenHeight, SQUARE_SIZE) - 1) * SQUARE_SIZE)) + (offset.y / 2),
                };

                //check to make sure the fruit is not on the snake
                j = 0;
                while (j < @as(usize, @intCast(counterTail))) : (j += 1) {
                    while (fruit.position.x == snake[j].position.x and fruit.position.y == snake[j].position.y) {
                        fruit.position = rl.Vector2{
                            .x = @as(f32, @floatFromInt(rl.GetRandomValue(0, @divTrunc(screenWidth, SQUARE_SIZE) - 1) * SQUARE_SIZE)) + (offset.x / 2),
                            .y = @as(f32, @floatFromInt(rl.GetRandomValue(0, @divTrunc(screenHeight, SQUARE_SIZE) - 1) * SQUARE_SIZE)) + (offset.y / 2),
                        };
                        j = 0;
                    }
                }
            }

            // Collision with fruit
            if (rl.CheckCollisionRecs(
                rl.Rectangle{ .x = snake[0].position.x, .y = snake[0].position.y, .width = snake[0].size.x, .height = snake[0].size.y },
                rl.Rectangle{ .x = fruit.position.x, .y = fruit.position.y, .width = fruit.size.x, .height = fruit.size.y },
            )) {
                snake[@intCast(counterTail)].position = snakePosition[@intCast(counterTail - 1)];
                counterTail += 1;
                fruit.active = false;
            }

            framesCounter += 1;
        }
    } else {
        if (rl.IsKeyPressed(rl.KEY_ENTER)) {
            InitGame();
            gameOver = false;
        }
    }
}

fn drawGame() void {
    rl.BeginDrawing();
    rl.ClearBackground(rl.RAYWHITE);

    if (!gameOver) {
        // Draw grid lines
        var i: i32 = 0;
        while (i < @divTrunc(screenWidth, SQUARE_SIZE) + 1) : (i += 1) {
            rl.DrawLineV(
                rl.Vector2{ .x = @as(f32, @floatFromInt(SQUARE_SIZE * i)) + (offset.x / 2), .y = offset.y / 2 },
                rl.Vector2{ .x = @as(f32, @floatFromInt(SQUARE_SIZE * i)) + (offset.x / 2), .y = @as(f32, @floatFromInt(screenHeight)) - (offset.y / 2) },
                rl.LIGHTGRAY,
            );
        }

        i = 0;
        while (i < @divTrunc(screenHeight, SQUARE_SIZE) + 1) : (i += 1) {
            rl.DrawLineV(
                rl.Vector2{ .x = offset.x / 2, .y = @as(f32, @floatFromInt(SQUARE_SIZE * i)) + (offset.y / 2) },
                rl.Vector2{ .x = @as(f32, @floatFromInt(screenWidth)) - (offset.x / 2), .y = @as(f32, @floatFromInt(SQUARE_SIZE * i)) + (offset.y / 2) },
                rl.LIGHTGRAY,
            );
        }

        // Draw snake
        i = 0;
        while (i < counterTail) : (i += 1) {
            rl.DrawRectangleV(snake[@intCast(i)].position, snake[@intCast(i)].size, snake[@intCast(i)].color);
        }

        // Draw fruit to pick
        rl.DrawRectangleV(fruit.position, fruit.size, fruit.color);

        if (pause) {
            rl.DrawText(
                "GAME PAUSED",
                @divTrunc(screenWidth, 2) - @divTrunc(rl.MeasureText("GAME PAUSED", 40), 2),
                @divTrunc(screenHeight, 2) - 40,
                40,
                rl.GRAY,
            );
        }
    } else {
        rl.DrawText(
            "PRESS [ENTER] TO PLAY AGAIN",
            @divTrunc(screenWidth, 2) - @divTrunc(rl.MeasureText("PRESS [ENTER] TO PLAY AGAIN", 20), 2),
            @divTrunc(screenHeight, 2) - 50,
            20,
            rl.GRAY,
        );
    }

    rl.EndDrawing();
}

fn UpdateDrawFrame() void {
    UpdateGame();
    drawGame();
}

pub fn main() !void {
    rl.InitWindow(screenWidth, screenHeight, "ZigSnake");
    defer rl.CloseWindow();

    rl.SetTargetFPS(60);

    InitGame();

    while (!rl.WindowShouldClose()) {
        UpdateDrawFrame();
    }
}
