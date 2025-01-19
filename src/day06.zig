const std = @import("std");
const testing = std.testing;

const Coord = struct {
    x: i128,
    y: i128,
};

const Delta = struct {
    dx: i128,
    dy: i128,
};

const Map = std.AutoHashMap(Coord, void);

const Guard = struct {
    loc: Coord,
    delta: Delta,
    x_max: i128,
    y_max: i128,

    fn step(self: *Guard, map: Map) bool {
        if (self.loc.x == 0 and self.delta.dx == -1 or
            self.loc.y == 0 and self.delta.dy == -1 or
            self.loc.x == self.x_max and self.delta.dx == 1 or
            self.loc.y == self.y_max and self.delta.dx == 1)
        {
            return false;
        }
        const new_loc = .{
            .x = self.loc.x + self.delta.dx,
            .y = self.loc.y + self.delta.dy,
        };

        if (map.contains(new_loc)) {
            const new_delta = .{
                .dx = self.delta.dy,
                .dy = -self.delta.dx,
            };
            self.delta = new_delta;
            return true;
        }

        self.loc = new_loc;
        return true;
    }
};

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var map = Map.init(alloc);
    defer map.deinit();
    var guard: Guard = undefined;
    for (input.items, 0..) |row, x| {
        for (row, 0..) |cell, y| {
            if (cell == '#') {
                try map.put(.{ .x = x, .y = y }, {});
            } else if (cell == '^') {
                guard = .{
                    .loc = .{ .x = x, .y = y },
                    .delta = .{ .dx = -1, .dy = 0 },
                    .x_max = input.items.len - 1,
                    .y_max = input.items[0].len - 1,
                };
            }
        }
    }
    // std.debug.print("map size: {d}, guard: {any}\n\n", .{ map.count(), guard });

    var visited = Map.init(alloc);
    defer visited.deinit();
    try visited.put(guard.loc, {});
    while (guard.step(map)) {
        try visited.put(guard.loc, {});
        // std.debug.print("{any}, {d}\n", .{ guard, visited.count() });
    }
    return visited.count();
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    _ = input;
    _ = alloc;
    return 0;
}

test "part 1" {
    const input =
        \\ ....#.....
        \\ .........#
        \\ ..........
        \\ ..#.......
        \\ .......#..
        \\ ..........
        \\ .#..^.....
        \\ ........#.
        \\ #.........
        \\ ......#...
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expect(try part1(list, std.testing.allocator) == 41);
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
