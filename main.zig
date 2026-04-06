const csv_core = @import("csv_core.zig");

pub fn main() !void {
    const metadata = csv_core.Metadata{ .new_path = "temp/output.csv" };

    try csv_core.parse_data("0mb.txt", metadata);
}
