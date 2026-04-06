const std = @import("std");
const csv_core = @import("csv_core");

test "parse_data: valid file creates expected output" {
    const path = "tests/test_files/valid_1.csv";
    const out_path = "temp/test_output.csv";

    const metadata = csv_core.Metadata{
        .country_code = "",
        .has_accent = true,
        .new_path = out_path,
    };

    try csv_core.parse_data(path, metadata);

    const file = try std.fs.cwd().openFile(out_path, .{});
    defer file.close();
    defer std.fs.cwd().deleteFile(out_path) catch {};

    const stat = try file.stat();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const subject = try file.readToEndAlloc(allocator, stat.size);
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

    const result = csv_core.parse_data("nonexistent.txt", metadata);
    try std.testing.expectError(error.FileNotFound, result);
}
