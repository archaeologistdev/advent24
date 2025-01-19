const std = @import("std");
const testing = std.testing;

const Coord = packed struct {
    x: u8,
    y: u8,
};

const Map = std.AutoArrayHashMap(u8, std.ArrayList(Coord));

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const aa = arena.allocator();
    const map = try parseMap(input.items, aa);

    const x_max = input.items.len - 1;
    const y_max = input.items[0].len - 1;

    var antinodes = std.AutoArrayHashMap(Coord, void).init(aa);
    for (map.values()) |coords| {
        for (coords.items, 0..) |c1, i| {
            for (coords.items, 0..) |c2, j| {
                if (i == j) continue;

                const dx = @as(i16, c1.x) - c2.x;
                const dy = @as(i16, c1.y) - c2.y;

                const new_x = c2.x - dx;
                const new_y = c2.y - dy;

                if (new_x < 0 or new_x > x_max or
                    new_y < 0 or new_y > y_max)
                    continue;

                const antinode = Coord{
                    .x = @intCast(new_x),
                    .y = @intCast(new_y),
                };
                try antinodes.put(antinode, {});
            }
        }
    }
    return @intCast(antinodes.count());
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const aa = arena.allocator();
    const map = try parseMap(input.items, aa);

    const x_max = input.items.len - 1;
    const y_max = input.items[0].len - 1;

    var antinodes = std.AutoArrayHashMap(Coord, void).init(aa);
    for (map.values()) |coords| {
        for (coords.items, 0..) |c1, i| {
            try antinodes.put(c1, {});

            for (coords.items, 0..) |c2, j| {
                if (i == j) continue;

                const dx = @as(i16, c1.x) - c2.x;
                const dy = @as(i16, c1.y) - c2.y;

                var new_x = c2.x - dx;
                var new_y = c2.y - dy;

                while (new_x >= 0 and new_x <= x_max and
                    new_y >= 0 and new_y <= y_max)
                {
                    const antinode = Coord{
                        .x = @intCast(new_x),
                        .y = @intCast(new_y),
                    };
                    try antinodes.put(antinode, {});

                    new_x = antinode.x - dx;
                    new_y = antinode.y - dy;
                }
            }
        }
    }
    return @intCast(antinodes.count());
}

fn parseMap(input: [][]const u8, aa: std.mem.Allocator) !Map {
    var map = Map.init(aa);
    for (input, 0..) |line, x| {
        for (line, 0..) |char, y| {
            if (char == '.') continue;
            const entry = try map.getOrPut(char);
            if (!entry.found_existing) {
                entry.value_ptr.* = std.ArrayList(Coord).init(aa);
            }
            try entry.value_ptr.*.append(Coord{ .x = @intCast(x), .y = @intCast(y) });
            // std.debug.print("{c}: {any}\n", .{ char, entry.value_ptr.*.items });
        }
    }
    return map;
}

test "part 1" {
    const input =
        \\............
        \\........0...
        \\.....0......
        \\.......0....
        \\....0.......
        \\......A.....
        \\............
        \\............
        \\........A...
        \\.........A..
        \\............
        \\............
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(14, try part1(list, std.testing.allocator));
}

test "part 2" {
    const input =
        \\............
        \\........0...
        \\.....0......
        \\.......0....
        \\....0.......
        \\......A.....
        \\............
        \\............
        \\........A...
        \\.........A..
        \\............
        \\............
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(34, try part2(list, std.testing.allocator));
}
