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
