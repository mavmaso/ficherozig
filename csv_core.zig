const std = @import("std");

const BUFFER_SIZE = 64 * 1024;

pub const Metadata = struct {
    new_path: []const u8,
    country_code: []const u8,
    has_accent: bool,
};

pub fn parse_data(path: []const u8, metadata: Metadata, io: std.Io) !void {
    const in_file = try std.Io.Dir.cwd().openFile(io, path, .{});
    defer in_file.close(io);

    const out_file = try std.Io.Dir.cwd().createFile(io, metadata.new_path, .{});
    defer out_file.close(io);

    var probe: [1024]u8 = undefined;
    const first_line = try read_first_line_from_file(in_file, io, probe[0..]);
    const separator = get_separator(first_line);

    var io_buf: [BUFFER_SIZE]u8 = undefined;
    var reader = in_file.reader(io, io_buf[0..]);
    var buffer: [BUFFER_SIZE + 1]u8 = undefined;
    var start: usize = 0;

    while (true) {
        const n = try reader.interface.readSliceShort(buffer[start..BUFFER_SIZE]);

        if (n == 0) break;

        const end = start + n;
        var i = start;

        buffer[end] = separator; // sentinel

        while (i < end + 1) {
            const c = buffer[i];

            if (c == separator or c == '\n') {
                const field = buffer[start..i];
                try out_file.writeStreamingAll(io, field);

                if (i != end) {
                    const out_sep = if (c == '\n') "\n" else ";";
                    try out_file.writeStreamingAll(io, out_sep);
                }

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

fn get_separator(line: []const u8) u8 {
    if (std.mem.indexOfScalar(u8, line, ';') != null) return ';';
    if (std.mem.indexOfScalar(u8, line, '|') != null) return '|';
    if (std.mem.indexOfScalar(u8, line, '\t') != null) return '\t';
    if (std.mem.indexOfScalar(u8, line, ',') != null) return ',';
    if (std.mem.indexOfScalar(u8, line, ' ') != null) return ' ';
    return ',';
}

fn get_first_line(line: []const u8) []const u8 {
    const newline_pos = std.mem.indexOfScalar(u8, line, '\n');

    if (newline_pos != null) {
        return line[0..newline_pos.?];
    }

    return line;
}

fn read_first_line_from_file(in_file: std.Io.File, io: std.Io, probe: []u8) ![]const u8 {
    const probe_n = try in_file.readPositional(io, &.{probe}, 0);
    const probe_slice = probe[0..probe_n];
    const first_line = get_first_line(probe_slice);

    return first_line;
}
