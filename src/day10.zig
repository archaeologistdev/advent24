const std = @import("std");
const testing = std.testing;

const Node = packed struct {
    x: u8,
    y: u8,
    z: u8,
};

const Adj = std.AutoArrayHashMap(Node, void);
const Graph = std.AutoArrayHashMap(Node, Adj);
const deltas = [_]i8{ -1, 0, 1 };

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var arena = std.heap.ArenaAllocator.init(alloc);
    const aa = arena.allocator();
    defer arena.deinit();

    var graph = try buildGraph(aa, input.items);

    var total: i64 = 0;
    for (graph.keys()) |k| {
        // trailhead
        if (k.z == 0) {
            const score = try countPeaks(aa, k, graph);
            // std.debug.print("{d} peaks reachable from trailhead: {any}\n", .{ score, k });

            total += score;
        }
    }
    // std.debug.print("\n{any}\n", .{graph.keys()});
    // for (graph.values()) |v| std.debug.print("{any}\n", .{v.keys()});
    return total;
}

fn buildGraph(aa: std.mem.Allocator, input: [][]const u8) !Graph {
    var graph = Graph.init(aa);
    for (input, 0..) |row, x| {
        for (row, 0..) |cell, y| {
            const z = try std.fmt.charToDigit(cell, 10);
            const node = Node{ .x = @intCast(x), .y = @intCast(y), .z = @intCast(z) };
            const entry = try graph.getOrPut(node);
            if (!entry.found_existing) {
                entry.value_ptr.* = Adj.init(aa);
            }

            // check neighbors
            for (deltas) |dx| {
                for (deltas) |dy| {
                    // skip self
                    if (dx == 0 and dy == 0) continue;
                    // skip diagonals
                    if (dx != 0 and dy != 0) continue;

                    const x2 = @as(i16, node.x) + dx;
                    const y2 = @as(i16, node.y) + dy;

                    // outside of map?
                    if (x2 < 0 or y2 < 0 or
                        x2 >= input.len or y2 >= row.len) continue;

                    const z2 = try std.fmt.charToDigit(input[@intCast(x2)][@intCast(y2)], 10);
                    // check for hiking path between z and z2
                    if (z2 -| z == 1) {
                        const node2 = Node{ .x = @intCast(x2), .y = @intCast(y2), .z = z2 };
                        try entry.value_ptr.*.put(node2, {});
                    }
                }
            }
        }
    }
    return graph;
}

fn countPeaks(alloc: std.mem.Allocator, start: Node, graph: Graph) !u32 {
    var frontier = std.ArrayList(Node).init(alloc);
    var seen = std.AutoArrayHashMap(Node, void).init(alloc);
    try frontier.append(start);
    while (frontier.popOrNull()) |node| {
        if (seen.contains(node)) continue;
        try seen.put(node, {});

        const adj = graph.get(node) orelse continue;
        try frontier.appendSlice(adj.keys());
    }
    var peaks: u32 = 0;
    for (seen.keys()) |s| {
        if (s.z == 9) peaks += 1;
    }
    return peaks;
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var arena = std.heap.ArenaAllocator.init(alloc);
    const aa = arena.allocator();
    defer arena.deinit();

    var graph = try buildGraph(aa, input.items);

    var total: i64 = 0;
    for (graph.keys()) |k| {
        // trailhead
        if (k.z == 0) {
            const score = try countTrails(aa, k, graph);
            // std.debug.print("{d} paths from trailhead: {any}\n", .{ score, k });

            total += score;
        }
    }
    // std.debug.print("\n{any}\n", .{graph.keys()});
    // for (graph.values()) |v| std.debug.print("{any}\n", .{v.keys()});
    return total;
}

fn countTrails(alloc: std.mem.Allocator, start: Node, graph: Graph) !u32 {
    var frontier = std.ArrayList(Node).init(alloc);
    try frontier.append(start);
    var paths: u32 = 0;
    while (frontier.popOrNull()) |node| {
        if (node.z == 9) paths += 1;
        const adj = graph.get(node) orelse continue;
        try frontier.appendSlice(adj.keys());
    }

    return paths;
}

test "part 1" {
    const input =
        \\89010123
        \\78121874
        \\87430965
        \\96549874
        \\45678903
        \\32019012
        \\01329801
        \\10456732
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(36, try part1(list, std.testing.allocator));
}

test "part 2" {
    const input =
        \\89010123
        \\78121874
        \\87430965
        \\96549874
        \\45678903
        \\32019012
        \\01329801
        \\10456732
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(81, try part2(list, std.testing.allocator));
}
