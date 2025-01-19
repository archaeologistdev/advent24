const std = @import("std");
const testing = std.testing;

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) anyerror!i64 {
    _ = input;
    _ = alloc;
    return 0;
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) anyerror!i64 {
    _ = input;
    _ = alloc;
    return 0;
}

test "part 1" {
    const input =
        \\
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expect(try part1(list, std.testing.allocator) == 0);
}

test "part 2" {
    const input =
        \\
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expect(try part2(list, std.testing.allocator) == 0);
}
