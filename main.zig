const std = @import("std");
const csv_core = @import("csv_core.zig");

pub fn main() !void {
    std.debug.print("Running ...\n", .{});

    const path = "0mb.txt";

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        std.log.err("Failed to open file: {s}", .{@errorName(err)});
        return;
    };
    defer file.close();

    while (file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', std.math.maxInt(usize)) catch |err| {
        std.log.err("Failed to read line: {s}", .{@errorName(err)});
        return;
    }) |line| {
        defer allocator.free(line);
        std.debug.print("{s}\n", .{line});
    }

    std.debug.print("Finished\n", .{});
}
