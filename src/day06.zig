const std = @import("std");
const testing = std.testing;

const Coord = packed struct {
    x: i32,
    y: i32,
};

const Delta = packed struct {
    dx: i2,
    dy: i2,
};

const Map = std.AutoArrayHashMap(Coord, void);
const DeltaSet = std.AutoArrayHashMap(Delta, void);

const Guard = packed struct {
    loc: Coord,
    delta: Delta,
    x_max: u14,
    y_max: u14,

    fn step(self: *Guard, map: Map) bool {
        if (self.loc.x == 0 and self.delta.dx == -1 or
            self.loc.y == 0 and self.delta.dy == -1 or
            self.loc.x == self.x_max and self.delta.dx == 1 or
            self.loc.y == self.y_max and self.delta.dy == 1)
        {
            return false;
        }
        if (self.loc.x >= self.x_max or self.loc.y >= self.y_max) {
            std.debug.print("\n{any}\n", .{self});
            @panic("out of bounds");
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
            const xx: u14 = @intCast(x);
            const yy: u14 = @intCast(y);
            if (cell == '#') {
                try map.put(.{ .x = xx, .y = yy }, {});
            } else if (cell == '^') {
                const x_max: u14 = @intCast(input.items.len - 1);
                const y_max: u14 = @intCast(input.items[0].len - 1);
                guard = .{
                    .loc = .{ .x = xx, .y = yy },
                    .delta = .{ .dx = -1, .dy = 0 },
                    .x_max = x_max,
                    .y_max = y_max,
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
    return @intCast(visited.count());
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var map = Map.init(alloc);
    defer map.deinit();
    var guard: Guard = undefined;
    for (input.items, 0..) |row, x| {
        for (row, 0..) |cell, y| {
            const xx: u14 = @intCast(x);
            const yy: u14 = @intCast(y);
            if (cell == '#') {
                try map.put(.{ .x = xx, .y = yy }, {});
            } else if (cell == '^') {
                const x_max: u14 = @intCast(input.items.len - 1);
                const y_max: u14 = @intCast(input.items[0].len - 1);
                guard = .{
                    .loc = .{ .x = xx, .y = yy },
                    .delta = .{ .dx = -1, .dy = 0 },
                    .x_max = x_max,
                    .y_max = y_max,
                };
            }
        }
    }
    const old_guard = guard;
    // std.debug.print("map size: {d}, guard: {any}\n\n", .{ map.count(), guard });

    var visited = Map.init(alloc);
    defer visited.deinit();
    try visited.put(guard.loc, {});
    while (guard.step(map)) {
        try visited.put(guard.loc, {});
    }

    var loops: i32 = 0;
    for (visited.keys()) |loc| {
        // std.debug.print("checking loc {any}\n", .{loc});
        if (std.meta.eql(loc, old_guard.loc)) continue;
        var new_map = try map.clone();
        defer new_map.deinit();
        try new_map.put(loc, {});

        if (try causes_loop(old_guard, new_map, alloc)) {
            loops += 1;
            // std.debug.print("found loop at {any}, total {d} loops\n", .{ loc, loops });
        }
    }

    return loops;
}

fn causes_loop(guard: Guard, map: Map, alloc: std.mem.Allocator) !bool {
    // much easier to deallocate everything at once
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
    const aa = arena.allocator();

    var visited = std.AutoArrayHashMap(Coord, DeltaSet).init(aa);

    // record initial location and delta in visited set
    var g_delta = DeltaSet.init(aa);
    try g_delta.put(guard.delta, {});
    try visited.put(guard.loc, g_delta);

    // mutable copy of guard for simulation
    var g = guard;
    while (g.step(map)) {
        const visit = try visited.getOrPut(g.loc);

        if (visit.found_existing) {
            // guard has been here before, check direction
            // std.debug.print("found existing: loc: {any}, delta: {any}, visit: {any}\n", .{ g.loc, g.delta, visit.value_ptr.*.keys() });

            if (visit.value_ptr.*.contains(g.delta)) {
                // guard has been here facing the same direction
                // std.debug.print("found loop at {any}, {d}\n", .{ g, visited.count() });
                return true;
            }
        }

        if (!visit.found_existing) {
            // guard hasn't been here before
            var deltas = DeltaSet.init(aa);
            try deltas.ensureTotalCapacity(4);
            visit.value_ptr.* = deltas;
        }

        // record direction
        try visit.value_ptr.put(g.delta, {});
    }
    // std.debug.print("NO loop at {any}, {d}\n", .{ g, visited.count() });
    return false;
}

test "part 1" {
    const input =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(41, try part1(list, std.testing.allocator));
}

test "part 2" {
    const input =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(6, try part2(list, std.testing.allocator));
}
