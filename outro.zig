const std = @import("std");

pub fn main() !void {
    const path = "0mb.txt";

    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const stat = try file.stat();
    const content = try file.readToEndAlloc(allocator, stat.size);
    defer allocator.free(content);

    var iter = std.mem.splitScalar(u8, content, '\n');
    while (iter.next()) |line| {
        std.debug.print("{s}\n", .{line});
    }
}
