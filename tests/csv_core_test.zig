const std = @import("std");
const csv_core = @import("csv_core");

test "parse_data: valid file creates output file" {
    const out_path = "temp/test_output.csv";
    const metadata = csv_core.Metadata{ .new_path = out_path };

    try csv_core.parse_data("0mb.txt", metadata);

    const out = try std.fs.cwd().openFile(out_path, .{});
    const stat = try out.stat();
    try std.testing.expect(stat.size > 0);
    out.close();
    try std.fs.cwd().deleteFile(out_path);
}

test "parse_data: missing file returns error" {
    const metadata = csv_core.Metadata{ .new_path = "temp/test_output.csv" };
    const result = csv_core.parse_data("nonexistent.txt", metadata);
    try std.testing.expectError(error.FileNotFound, result);
}
