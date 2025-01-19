const std = @import("std");
const testing = std.testing;

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    var arena = std.heap.ArenaAllocator.init(alloc);
    const aa = arena.allocator();
    defer arena.deinit();
    std.debug.assert(input.items.len == 1);
    var stones = std.ArrayList(u64).init(aa);
    var parts = std.mem.splitScalar(u8, input.items[0], ' ');
    while (parts.next()) |p| {
        try stones.append(try std.fmt.parseUnsigned(u64, p, 10));
    }

    var history = std.AutoArrayHashMap(u64, std.ArrayList(u64)).init(aa);

    for (0..25) |_| {
        const prev_len: usize = stones.items.len;
        var new_len: usize = 0;
        try stones.ensureUnusedCapacity(prev_len * 2);
        for (stones.items) |s| {
            const prev = try history.getOrPut(s);
            if (!prev.found_existing) {
                var outcomes = try std.ArrayList(u64).initCapacity(aa, 2);
                if (s == 0) {
                    try outcomes.append(1);
                } else if (countDigits(s) % 2 == 0) {
                    var buf: [20]u8 = undefined;
                    const digits = try std.fmt.bufPrint(&buf, "{}", .{s});
                    const h = @divExact(digits.len, 2);
                    const h1 = try std.fmt.parseUnsigned(u64, digits[0..h], 10);
                    const h2 = try std.fmt.parseUnsigned(u64, digits[h..], 10);
                    try outcomes.appendSlice(&[_]u64{ h1, h2 });
                } else {
                    try outcomes.append(s * 2024);
                }
                prev.value_ptr.* = outcomes;
            }
            // don't invalidate pointers
            stones.appendSliceAssumeCapacity(prev.value_ptr.*.items);
            new_len += prev.value_ptr.*.items.len;
        }
        // to avoid aliasing, copy in 2 steps
        stones.replaceRangeAssumeCapacity(0, prev_len, stones.items[prev_len .. prev_len * 2]);
        stones.replaceRangeAssumeCapacity(prev_len, prev_len, stones.items[prev_len * 2 ..]);
        stones.shrinkRetainingCapacity(new_len);
    }

    return @intCast(stones.items.len);
}

inline fn countDigits(n: u64) u64 {
    const nf: f128 = @floatFromInt(n);
    return @intFromFloat(@floor(@log10(nf)) + 1);
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    _ = input;
    _ = alloc;
    return 0;
}

test "part 1" {
    const input =
        \\125 17
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(55312, try part1(list, std.testing.allocator));
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

    try testing.expectEqual(0, try part2(list, std.testing.allocator));
}
