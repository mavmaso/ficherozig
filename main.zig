const std = @import("std");
const csv_core = @import("csv_core.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var threaded = std.Io.Threaded.init(allocator, .{});
    const io = threaded.io();

    const metadata = csv_core.Metadata{ .new_path = "temp/output.csv", .country_code = "", .has_accent = false };

    try csv_core.parse_data("0mb.txt", metadata, io);
}
