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
       .x = @as(f32, @floatFromInt(@rem(screenWidth, SQUARE_SIZE))), // @rem calculates remainder and @as does conversion between types(https://ziglang.org/documentation/master/#as)
       .y = @as(f32, @floatFromInt(@rem(screenHeight, SQUARE_SIZE))),
    };


