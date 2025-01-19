const std = @import("std");
const root = @import("./root.zig");
const assert = std.debug.assert;

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var args = std.process.args();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    assert(args.skip()); // should always have program name
    if (args.next()) |day| {
        std.debug.print("received: {s}\n", .{day});
        var file = try std.fs.cwd().openFile(day, .{});
        defer file.close();

        var reader = file.reader();

        var lines = std.ArrayList([]const u8).init(alloc);
        while (try reader.readUntilDelimiterOrEofAlloc(alloc, '\n', 512)) |line| {
            // std.debug.print("{any}", .{line});
            try lines.append(line);
        }
        std.debug.print("read {d} lines\n", .{lines.items.len});
        try stdout.print("{d}\n", .{try root.day1_part1(lines, alloc)});
    } else {
        std.debug.print("no args given\n", .{});
    }
    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
