const std = @import("std");
const testing = std.testing;

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var lookupRule = std.AutoHashMap(u8, std.AutoArrayHashMap(u8, void)).init(
        alloc,
    );
    defer lookupRule.deinit();
    defer {
        var vi = lookupRule.valueIterator();
        while (vi.next()) |v| v.deinit();
    }

    var parsing_rules = true;
    var valid: i64 = 0;

    lines: for (input.items) |line| {
        if (line.len == 0) {
            parsing_rules = false;
            continue;
        }

        if (parsing_rules) {
            var it = std.mem.splitScalar(u8, line, '|');
            const before = try std.fmt.parseUnsigned(u8, it.next().?, 10);
            const after = try std.fmt.parseUnsigned(u8, it.next().?, 10);
            std.debug.assert(it.peek() == null);
            const entry = try lookupRule.getOrPut(before);
            // std.debug.print("before: {d}, after: {d}, key: {}\n", .{ before, after, entry.key_ptr.* });
            if (!entry.found_existing) {
                entry.value_ptr.* = std.AutoArrayHashMap(u8, void).init(alloc);
            }
            try entry.value_ptr.*.put(after, {});
            continue;
        }

        var it = std.mem.splitScalar(u8, line, ',');
        var seen = std.AutoArrayHashMap(u8, void).init(
            alloc,
        );
        defer seen.deinit();

        while (it.next()) |num| {
            const n = try std.fmt.parseUnsigned(u8, num, 10);
            try seen.put(n, {});
            const should_not_have_seen = lookupRule.get(n) orelse continue;

            for (should_not_have_seen.keys()) |k| {
                if (seen.contains(k)) continue :lines;
            }
        }
        const keys = seen.keys();
        const middle = keys[try std.math.divFloor(usize, keys.len, 2)];
        // std.debug.print("middle: {d}\n", .{middle});
        valid += middle;
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
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.splitScalar(u8, input, '\n');
    while (it.next()) |line| {
        // std.debug.print("appending line: {s}\n", .{line});
        try list.append(line);
    }

    try testing.expect(try part1(list, std.testing.allocator) == 143);
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
