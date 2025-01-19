const std = @import("std");
const testing = std.testing;

pub fn day1_part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) anyerror!usize {
    var list1 = std.ArrayList(u32).init(alloc);
    defer list1.deinit();
    var list2 = std.ArrayList(u32).init(alloc);
    defer list2.deinit();
    for (input.items) |item| {
        var it = std.mem.tokenizeScalar(u8, item, ' ');
        const fst = it.next().?;
        const snd = it.next().?;

        const first = try std.fmt.parseUnsigned(u32, fst, 10);
        const second = try std.fmt.parseUnsigned(u32, snd, 10);
        try list1.append(first);
        try list2.append(second);
    }
    std.mem.sort(u32, list1.items, {}, comptime std.sort.asc(u32));
    std.mem.sort(u32, list2.items, {}, comptime std.sort.asc(u32));

    var result: u32 = 0;
    for (list1.items, list2.items) |x, y| {
        const dist = std.mem.max(u32, &[_]u32{ x, y }) - std.mem.min(u32, &[_]u32{ x, y });
        std.debug.print("|{d} - {d}| = {d}\n", .{ x, y, dist });
        result += dist;
    }

    std.debug.print("{d}\n", .{result});
    return result;
}

test "day 1 example" {
    const input =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expect(try day1_part1(list, std.testing.allocator) == 11);
}
