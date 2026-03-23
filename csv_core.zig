const std = @import("std");

const BUFFER_SIZE = 64 * 1024;

pub const Metadata = struct {
    new_path: []const u8,
    // country_code: []const u8,  // future
    // has_accent: bool,           // future
};

pub fn parse_data(path: []const u8, metadata: Metadata) !void {
    const in_file = try std.fs.cwd().openFile(path, .{});
    defer in_file.close();

    const out_file = try std.fs.cwd().createFile(metadata.new_path, .{});
    defer out_file.close();

    var io_buf: [BUFFER_SIZE]u8 = undefined;
    var reader = in_file.reader(io_buf[0..]);
    var buffer: [BUFFER_SIZE + 1]u8 = undefined;
    var start: usize = 0;

    while (true) {
        const n = try reader.interface.readSliceShort(buffer[start..BUFFER_SIZE]);

        if (n == 0) break;

        const end = start + n;
        var i = start;

        buffer[end] = ','; // sentinel

        while (i < end + 1) {
            const c = buffer[i];
            if (c == ',' or c == '\n') {
                const field = buffer[start..i];
                try out_file.writeAll(field);
                try out_file.writeAll("\n");
                start = i + 1;
            }
            i += 1;
        }

        if (start < end) {
            const leftover = buffer[start..end];
            std.mem.copyForwards(u8, buffer[0..leftover.len], leftover);
            start = leftover.len;
        } else {
            start = 0;
        }
    }
}
