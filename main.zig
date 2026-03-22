const std = @import("std");

const BUFFER_SIZE = 64 * 1024;

pub fn main() !void {
    const file = try std.fs.cwd().openFile("0mb.txt", .{});
    defer file.close();

    var io_buf: [BUFFER_SIZE]u8 = undefined;
    var reader = file.reader(io_buf[0..]);
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
                std.debug.print("FIELD: {s}\n", .{field});
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
