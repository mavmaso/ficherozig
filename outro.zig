const std = @import("std");

pub fn main() !void {
    const path = "0mb.txt";

    const allocator = std.heap.page_allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    const io = threaded.io();

    const file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer file.close(io);

    var read_buf: [4096]u8 = undefined;
    var rdr = file.reader(io, read_buf[0..]);
    const content = try rdr.interface.allocRemaining(allocator, @enumFromInt(1024 * 1024));
    defer allocator.free(content);

    var iter = std.mem.splitScalar(u8, content, '\n');
    while (iter.next()) |line| {
        std.debug.print("{s}\n", .{line});
    }
}
