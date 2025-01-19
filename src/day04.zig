const std = @import("std");
const testing = std.testing;

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var sum: i64 = 0;

    // std.debug.print("\nchecking horizontal\n", .{});
    for (input.items) |slice| {
        sum += @intCast(countXmas(slice));
    }
    // std.debug.print("\nchecking vertical\n", .{});
    const transposed = try transpose(input.items, alloc);
    defer alloc.free(transposed);

    for (transposed) |slice| {
        defer alloc.free(slice);
        sum += @intCast(countXmas(slice));
    }
    const x_end = input.items.len;
    const y_end = input.items[0].len;
    // std.debug.print("\nchecking diagonals (x descending)\n", .{});
    for (0..x_end) |x_start| {
        var diag = std.ArrayList(u8).init(alloc);
        defer diag.deinit();

        for (x_start..x_end, 0..) |x, y| {
            if (y >= y_end) break;
            try diag.append(input.items[x][y]);
        }

        sum += @intCast(countXmas(diag.items));
    }
    // std.debug.print("\nchecking diagonals (y descending)\n", .{});
    for (1..y_end) |y_start| {
        var diag = std.ArrayList(u8).init(alloc);
        defer diag.deinit();

        for (0.., y_start..y_end) |x, y| {
            if (x >= x_end) break;
            try diag.append(input.items[x][y]);
        }

        sum += @intCast(countXmas(diag.items));
    }
    // std.debug.print("\nchecking diagonals (x ascending)\n", .{});
    for (0..x_end) |x_start| {
        var diag = std.ArrayList(u8).init(alloc);
        defer diag.deinit();

        for (x_start..x_end, 0..) |x, y| {
            if (y >= y_end) break;
            try diag.append(input.items[x_end - x - 1][y]);
        }

        sum += @intCast(countXmas(diag.items));
    }
    // std.debug.print("\nchecking diagonals (y ascending)\n", .{});
    for (1..y_end) |y_start| {
        var diag = std.ArrayList(u8).init(alloc);
        defer diag.deinit();

        for (0.., y_start..y_end) |x, y| {
            if (x >= x_end) break;
            try diag.append(input.items[x_end - x - 1][y]);
        }

        sum += @intCast(countXmas(diag.items));
    }

    // std.debug.print("sum: {d}", .{sum});
    return sum;
}

fn countXmas(slice: []const u8) usize {
    const xmas = std.mem.count(u8, slice, "XMAS");
    const samx = std.mem.count(u8, slice, "SAMX");
    // std.debug.print("{s} has xmas: {d} samx: {d}\n", .{ slice, xmas, samx });
    return xmas + samx;
}

fn transpose(slices: [][]const u8, alloc: std.mem.Allocator) ![][]const u8 {
    // caller must free:
    var transposed = std.ArrayList([]u8).init(alloc);
    for (0..slices[0].len) |i| {
        // caller must free:
        var row = std.ArrayList(u8).init(alloc);
        for (slices) |slice| {
            try row.append(slice[i]);
        }
        try transposed.append(try row.toOwnedSlice());
    }
    return transposed.toOwnedSlice();
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    _ = input;
    _ = alloc;
    return 0;
}

test "part 1" {
    const input =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expect(try part1(list, std.testing.allocator) == 18);
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
