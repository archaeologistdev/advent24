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
        // std.debug.print("received: {s}\n", .{day});
        var file = try std.fs.cwd().openFile(day, .{});
        defer file.close();

        var reader = file.reader();

        var lines = std.ArrayList([]const u8).init(alloc);
        while (try reader.readUntilDelimiterOrEofAlloc(alloc, '\n', 32768)) |line| {
            // std.debug.print("{any}", .{line});
            try lines.append(line);
        }
        // std.debug.print("read {d} lines\n", .{lines.items.len});
        const d = try std.fmt.parseUnsigned(u8, std.fs.path.stem(day), 10);
        const part1 = switch (d) {
            1 => try root.day01.part1(lines, alloc),
            2 => try root.day02.part1(lines, alloc),
            3 => try root.day03.part1(lines, alloc),
            4 => try root.day04.part1(lines, alloc),
            5 => try root.day05.part1(lines, alloc),
            6 => try root.day06.part1(lines, alloc),
            7 => try root.day07.part1(lines, alloc),
            8 => try root.day08.part1(lines, alloc),
            9 => try root.day09.part1(lines, alloc),
            10 => try root.day10.part1(lines, alloc),
            11 => try root.day11.part1(lines, alloc),
            12 => try root.day12.part1(lines, alloc),
            13 => try root.day13.part1(lines, alloc),
            14 => try root.day14.part1(lines, alloc),
            15 => try root.day15.part1(lines, alloc),
            16 => try root.day16.part1(lines, alloc),
            17 => try root.day17.part1(lines, alloc),
            18 => try root.day18.part1(lines, alloc),
            19 => try root.day19.part1(lines, alloc),
            20 => try root.day20.part1(lines, alloc),
            21 => try root.day21.part1(lines, alloc),
            22 => try root.day22.part1(lines, alloc),
            23 => try root.day23.part1(lines, alloc),
            24 => try root.day24.part1(lines, alloc),
            else => @panic("not implemented"),
        };
        const part2 = switch (d) {
            1 => try root.day01.part2(lines, alloc),
            2 => try root.day02.part2(lines, alloc),
            3 => try root.day03.part2(lines, alloc),
            4 => try root.day04.part2(lines, alloc),
            5 => try root.day05.part2(lines, alloc),
            6 => try root.day06.part2(lines, alloc),
            7 => try root.day07.part2(lines, alloc),
            8 => try root.day08.part2(lines, alloc),
            9 => try root.day09.part2(lines, alloc),
            10 => try root.day10.part2(lines, alloc),
            11 => try root.day11.part2(lines, alloc),
            12 => try root.day12.part2(lines, alloc),
            13 => try root.day13.part2(lines, alloc),
            14 => try root.day14.part2(lines, alloc),
            15 => try root.day15.part2(lines, alloc),
            16 => try root.day16.part2(lines, alloc),
            17 => try root.day17.part2(lines, alloc),
            18 => try root.day18.part2(lines, alloc),
            19 => try root.day19.part2(lines, alloc),
            20 => try root.day20.part2(lines, alloc),
            21 => try root.day21.part2(lines, alloc),
            22 => try root.day22.part2(lines, alloc),
            23 => try root.day23.part2(lines, alloc),
            24 => try root.day24.part2(lines, alloc),
            else => @panic("not implemented"),
        };
        try stdout.print("{d}\n", .{part1});
        try stdout.print("{d}\n", .{part2});
    } else {
        std.debug.print("no args given\n", .{});
    }
    // try stdout.print("Run `zig build test` to run the tests.\n", .{});
    try bw.flush();
}
