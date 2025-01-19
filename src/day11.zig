const std = @import("std");
const testing = std.testing;

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    std.debug.assert(input.items.len == 1);

    return @intCast(try calculate(alloc, 25, input.items[0]));
}

fn calculate(alloc: std.mem.Allocator, comptime n: usize, items: []const u8) !usize {
    var arena = std.heap.ArenaAllocator.init(alloc);
    const aa = arena.allocator();
    defer arena.deinit();

    var stones = std.AutoArrayHashMap(u64, u64).init(aa);
    var parts = std.mem.splitScalar(u8, items, ' ');
    while (parts.next()) |p| {
        const num = try std.fmt.parseUnsigned(u64, p, 10);
        const entry = try stones.getOrPutValue(num, 0);
        entry.value_ptr.* += 1;
    }

    for (0..n) |_| {
        const before = try stones.clone();
        stones.clearRetainingCapacity();
        var it = before.iterator();
        while (it.next()) |entry| {
            const s = entry.key_ptr.*;
            const v = entry.value_ptr.*;
            if (s == 0) {
                const prev = try stones.getOrPutValue(1, 0);
                prev.value_ptr.* += v;
            } else if (countDigits(s) % 2 == 0) {
                var buf: [20]u8 = undefined;
                const digits = try std.fmt.bufPrint(&buf, "{}", .{s});
                const h = @divExact(digits.len, 2);
                const h1 = try std.fmt.parseUnsigned(u64, digits[0..h], 10);
                const h2 = try std.fmt.parseUnsigned(u64, digits[h..], 10);
                const prev1 = try stones.getOrPutValue(h1, 0);
                prev1.value_ptr.* += v;
                const prev2 = try stones.getOrPutValue(h2, 0);
                prev2.value_ptr.* += v;
            } else {
                const prev = try stones.getOrPutValue(s * 2024, 0);
                prev.value_ptr.* += v;
            }
        }
    }

    var total: usize = 0;
    for (stones.values()) |v| total += v;
    return total;
}

inline fn countDigits(n: u64) u64 {
    const nf: f128 = @floatFromInt(n);
    return @intFromFloat(@floor(@log10(nf)) + 1);
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    std.debug.assert(input.items.len == 1);
    return @intCast(try calculate(alloc, 75, input.items[0]));
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
        \\125 17
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(65601038650482, try part2(list, std.testing.allocator));
}
