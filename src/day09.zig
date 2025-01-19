const std = @import("std");
const testing = std.testing;

const File = packed struct {
    id: u16,
    len: u8,
};

const Free = packed struct {
    len: u8,
};

const Thing = union(enum) { file: File, space: Free };

pub fn part1(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    std.debug.assert(input.items.len == 1);
    // EXAMPLE:
    //ids: 0.1.2
    //map: 12345
    //     ^   ^
    //  start end
    //expanded: 0..111....22222
    //
    // 1. tag each disk with its id + length
    // 2. tag each free space with its length
    // 3. push them onto a list, in sequence.
    // 4. initialize result list
    // 5. iterate over the original list.
    //    5.1 for files, push them to the result list
    //    5.2 for spaces, pop the last file from the original list.
    //        if file size = space: replace space with file.
    //        if file size > space: remove space, split file, replace space with first half file.
    //                              retain second half of file in orig list.
    //        if file size < space: reduce len of space, insert file before space.
    //

    const in: []const u8 = input.items[0];
    var things = try std.ArrayList(Thing).initCapacity(alloc, in.len);
    defer things.deinit();
    for (in, 0..) |char, i| {
        const digit = try std.fmt.charToDigit(char, 10);
        if (i % 2 == 0) {
            // even indexes contain files
            const id: u16 = @intCast(@divExact(i, 2));
            try things.append(Thing{ .file = File{ .id = id, .len = digit } });
        } else {
            // odd indexes contain empty space
            try things.append(Thing{ .space = Free{ .len = digit } });
        }
    }
    // std.debug.print("{any}", .{things.items});

    var result = try std.ArrayList(Thing).initCapacity(alloc, in.len);
    defer result.deinit();

    var start_idx: usize = 0;
    var end_idx: usize = things.items.len - 1;

    // std.debug.print("\n> ", .{});
    while (start_idx <= end_idx) {
        const start = things.items[start_idx];
        const end = things.items[end_idx];

        if (start == Thing.file) {
            // for (0..start.file.len) |_| std.debug.print("{d}", .{start.file.id});
            try result.append(start);
            start_idx += 1;
            continue;
        }

        if (end == Thing.space) {
            end_idx -= 1;
            continue;
        }

        std.debug.assert(start == Thing.space);
        std.debug.assert(end == Thing.file);

        if (start.space.len < end.file.len) {
            const split = Thing{ .file = File{ .id = end.file.id, .len = start.space.len } };
            // for (0..split.file.len) |_| std.debug.print("{d}", .{split.file.id});
            try result.append(split);
            things.items[end_idx].file.len -= start.space.len;
            start_idx += 1;
        } else if (start.space.len > end.file.len) {
            // for (0..end.file.len) |_| std.debug.print("{d}", .{end.file.id});
            try result.append(end);
            things.items[start_idx].space.len -= end.file.len;
            end_idx -= 1;
        } else {
            // for (0..end.file.len) |_| std.debug.print("{d}", .{end.file.id});
            try result.append(end);
            end_idx -= 1;
            start_idx += 1;
        }
    }

    var i: u64 = 0;
    var checksum: u64 = 0;
    for (result.items) |r| {
        std.debug.assert(r == Thing.file);
        for (0..r.file.len) |_| {
            // std.debug.print("{d} * {d} = {d}\n", .{ i, r.file.id, i * r.file.id });
            checksum += i * r.file.id;
            i += 1;
        }
    }
    // std.debug.print("\n", .{});

    // std.debug.print("{any}", .{result.items});

    return @intCast(checksum);
}

pub fn part2(input: std.ArrayList([]const u8), alloc: std.mem.Allocator) !i64 {
    _ = input;
    _ = alloc;
    return 0;
}

test "part 1" {
    const input =
        //0.1.2.3.4.5.6.7.8.9
        \\2333133121414131402
    ;
    var list = std.ArrayList([]const u8).init(std.testing.allocator);
    defer list.deinit();
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        try list.append(line);
    }

    try testing.expectEqual(1928, try part1(list, std.testing.allocator));
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
