const std = @import("std");
const csv_core = @import("csv_core");
const io = std.Options.debug_io;

test "parse_data: valid file creates expected output" {
    const path = "tests/test_files/valid_1.csv";
    const out_path = "temp/test_output.csv";

    const metadata = csv_core.Metadata{
        .country_code = "",
        .has_accent = true,
        .new_path = out_path,
    };

    try csv_core.parse_data(path, metadata, io);

    const file = try std.Io.Dir.cwd().openFile(io, out_path, .{});
    defer file.close(io);
    defer std.Io.Dir.cwd().deleteFile(io, out_path) catch {};

    var gpa = std.heap.DebugAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var read_buf: [4096]u8 = undefined;
    var rdr = file.reader(io, read_buf[0..]);
    const subject = try rdr.interface.allocRemaining(allocator, @enumFromInt(1024 * 1024));
    defer allocator.free(subject);

    const expected =
        \\destination;name;organization;nickname
        \\5516912345678;Test Contact 1;Sinch;Nickname 1
        \\5516912345679;Test Contact 2;Wavy;Nickname 2
        \\
    ;

    try std.testing.expectEqualStrings(expected, subject);
}

test "parse_data: missing file returns error" {
    const metadata = csv_core.Metadata{
        .new_path = "temp/test_output.csv",
        .country_code = "",
        .has_accent = true,
    };

    const result = csv_core.parse_data("nonexistent.txt", metadata, io);
    try std.testing.expectError(error.FileNotFound, result);
}
