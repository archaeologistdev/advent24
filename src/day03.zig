const std = @import("std");
const testing = std.testing;

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var total: i64 = 0;
    for (input.items) |line| {
        const sum = try doMul(line, alloc);
        total += sum;
    }
    return total;
}

fn doMul(line: []const u8, alloc: std.mem.Allocator) !i64 {
    var nums = std.ArrayList(i64).init(alloc);
    defer nums.deinit();

    var it = std.mem.tokenizeSequence(u8, line, "mul(");
    while (it.next()) |fragment| {
        // std.debug.print("fragment: {s}\n", .{fragment});
        var tokens = std.mem.splitScalar(u8, fragment, ',');
        // std.debug.print("peek: {s}\n", .{tokens.peek().?});

        const n1 = tokens.next() orelse continue;
        // std.debug.print("n1: {s}\n", .{n1});

        const fragment2 = tokens.next() orelse continue;
        var tokens2 = std.mem.splitScalar(u8, fragment2, ')');
        const n2 = tokens2.next() orelse continue;
        //std.debug.print("n2: {s}\n", .{n2});

        if (tokens2.peek() == null) continue;

        const num1 = std.fmt.parseUnsigned(i64, n1, 10) catch continue;
        const num2 = std.fmt.parseUnsigned(i64, n2, 10) catch continue;
        // std.debug.print("fragment: {s}\n", .{fragment});
        // std.debug.print("tokens2 peek: {s}\n", .{tokens2.peek() orelse "null"});
        // std.debug.print("{d} * {d} = {d}\n\n", .{ num1, num2, num1 * num2 });
        std.debug.assert(num1 > 0 and num1 < 1000);
        std.debug.assert(num2 > 0 and num2 < 1000);

        try nums.append(num1 * num2);
    }
    var sum: i64 = 0;
    for (nums.items) |v| sum += v;
    // std.debug.print("sum: {d}\n", .{sum});
    return sum;
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var total: i64 = 0;
    const line = try std.mem.join(alloc, "", input.items);
    defer alloc.free(line);
    var nums = std.ArrayList(i64).init(alloc);
    defer nums.deinit();

    var it = std.mem.tokenizeSequence(u8, line, "do()");
    while (it.next()) |fragment| {
        // std.debug.print("\n\nfragment: {s}\n", .{fragment});
        var tokens = std.mem.splitSequence(u8, fragment, "don't()");
        // std.debug.print("peek: {s}\n\n", .{tokens.peek().?});
        const dos = tokens.next().?;

        const result = try doMul(dos, alloc);
        try nums.append(result);
    }
    var sum: i64 = 0;
    for (nums.items) |v| sum += v;
    // std.debug.print("sum: {d}\n", .{sum});
    total += sum;
    return total;
}

test "part 1" {
    const input =
        \\xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(161, try part1(list, std.testing.allocator));
}

test "part 1 edge case" {
    const input =
        \\mul(288,740,<@
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(0, try part1(list, std.testing.allocator));
}

test "part 2" {
    const input =
        \\xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(48, try part2(list, std.testing.allocator));
}
