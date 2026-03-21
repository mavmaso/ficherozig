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

    const content = file.readToEndAlloc(allocator, std.math.maxInt(usize)) catch |err| {
        std.log.err("Failed to read file: {s}", .{@errorName(err)});
        return;
    };

    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        std.debug.print("{s}\n", .{line});
    }

    std.debug.print("Finished\n", .{});
}
