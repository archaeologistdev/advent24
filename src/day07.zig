const std = @import("std");
const testing = std.testing;

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var valid: i64 = 0;
    for (input.items) |line| {
        var parts = std.mem.splitScalar(u8, line, ':');
        const checksum = try std.fmt.parseInt(i64, parts.next().?, 10);
        var rest = std.mem.tokenizeScalar(u8, parts.next().?, ' ');

        var old = std.ArrayList(i64).init(alloc);
        defer old.deinit();

        var new = std.ArrayList(i64).init(alloc);
        defer new.deinit();

        const val1 = rest.next().?;
        const num1 = try std.fmt.parseInt(i32, val1, 10);
        try old.append(num1);

        while (rest.next()) |val| {
            const new_n = try std.fmt.parseInt(i32, val, 10);
            for (old.items) |old_n| {
                const prod: i64 = old_n * new_n;
                if (prod <= checksum) try new.append(prod);

                const sum: i64 = old_n + new_n;
                if (sum <= checksum) try new.append(sum);
            }
            old.clearRetainingCapacity();
            try old.appendSlice(new.items);
            new.clearRetainingCapacity();
        }

        if (std.mem.indexOf(i64, old.items, &[_]i64{checksum}) != null) {
            valid += checksum;
        }
    }
    return valid;
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    _ = input;
    _ = alloc;
    return 0;
}

test "part 1" {
    const input =
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expect(try part1(list, std.testing.allocator) == 3749);
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
