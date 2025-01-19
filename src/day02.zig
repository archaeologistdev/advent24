const std = @import("std");
const testing = std.testing;

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var safe: u32 = 0;
    for (input.items) |report| {
        var levels = std.ArrayList(i32).init(alloc);
        defer levels.deinit();

        var it = std.mem.tokenizeAny(u8, report, " \n");
        while (it.next()) |n| {
            const num = try std.fmt.parseUnsigned(i32, n, 10);
            try levels.append(num);
        }

        if (isReportSafe(levels.items)) {
            safe += 1;
            // std.debug.print("report {any} is safe\n", .{levels.items});
        } else {
            // std.debug.print("report {any} is unsafe\n", .{levels.items});
        }
    }
    // std.debug.print("\n {d} reports are safe\n", .{safe});
    return safe;
}

fn isReportSafe(levels: []i32) bool {
    const sign: i32 = std.math.sign(levels[0] - levels[1]);
    for (levels[0..(levels.len - 1)], levels[1..]) |a, b| {
        const diff = a - b;
        // std.debug.print("\n{d} - {d} = {d}\n", .{ a, b, diff });
        if (std.math.sign(diff) != sign) {
            // std.debug.print("sign({d} = {d}\n", .{ diff, std.math.sign(diff) });
            return false;
        }
        const abs_diff = sign * diff;
        if (abs_diff < 1 or abs_diff > 3) {
            // std.debug.print("{d} < 1 or {d} > 3\n", .{ diff, diff });
            return false;
        }
    }
    return true;
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var safe: u32 = 0;
    for (input.items) |report| {
        var levels = std.ArrayList(i32).init(alloc);
        defer levels.deinit();

        var it = std.mem.tokenizeAny(u8, report, " \n");
        while (it.next()) |n| {
            const num = try std.fmt.parseUnsigned(i32, n, 10);
            try levels.append(num);
        }

        if (try isDampenedReportSafe(levels.items, alloc)) {
            safe += 1;
            // std.debug.print("report {any} is safe\n", .{levels.items});
        } else {
            // std.debug.print("report {any} is unsafe\n", .{levels.items});
        }
    }
    // std.debug.print("\n {d} reports are safe\n", .{safe});
    return safe;
}

fn isDampenedReportSafe(levels: []i32, alloc: std.mem.Allocator) !bool {
    for (0..levels.len) |i| {
        const ls = try std.mem.concat(alloc, i32, &[_][]i32{ levels[0..i], levels[i + 1 ..] });
        defer alloc.free(ls);
        std.debug.assert(ls.len == levels.len - 1);
        if (isReportSafe(ls)) {
            // std.debug.print("{any} -> {any} (safe)\n\n", .{ levels, ls });
            return true;
        }
        // std.debug.print("{any} -> {any} (unsafe)\n", .{ levels, ls });
    }
    return false;
}

test "part 1" {
    const input =
        \\ 7 6 4 2 1
        \\ 1 2 7 8 9
        \\ 9 7 6 2 1
        \\ 1 3 2 4 5
        \\ 8 6 4 4 1
        \\ 1 3 6 7 9
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(2, try part1(list, std.testing.allocator));
}

test "part 2" {
    const input =
        \\ 7 6 4 2 1
        \\ 1 2 7 8 9
        \\ 9 7 6 2 1
        \\ 1 3 2 4 5
        \\ 8 6 4 4 1
        \\ 1 3 6 7 9
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(4, try part2(list, std.testing.allocator));
}
