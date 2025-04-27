const std = @import("std");
const fs = std.fs;
const mem = std.mem;
const ArrayList = std.ArrayList;
const Allocator = mem.Allocator;

pub const CsvData = struct {
    placeholders: ArrayList([]const u8),
    data: ArrayList(ArrayList([]const u8)),
    allocator: Allocator,

    pub fn init(allocator: Allocator) CsvData {
        return CsvData{
            .placeholders = ArrayList([]const u8).init(allocator),
            .data = ArrayList(ArrayList([]const u8)).init(allocator),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *CsvData) void {
        for (self.placeholders.items) |item| {
            self.allocator.free(item);
        }
        self.placeholders.deinit();

        for (self.data.items) |*row| {
            for (row.items) |item| {
                self.allocator.free(item);
            }
            row.deinit();
        }
        self.data.deinit();
    }
};

pub fn getSeparator(line: []const u8) u8 {
    if (mem.indexOf(u8, line, ";") != null) {
        return ';';
    } else if (mem.indexOf(u8, line, "|") != null) {
        return '|';
    } else if (mem.indexOf(u8, line, "\t") != null) {
        return '\t';
    } else if (mem.indexOf(u8, line, ",") != null) {
        return ',';
    } else {
        return ',';
    }
}

// fn getSeparator(line: []const u8) u8 {
//     // Simple heuristic: check for common separators
//     const separators = [_]u8{ ',', ';', '\t', '|' };
//     var max_count: usize = 0;
//     var best_sep: u8 = ','; // Default to comma

//     for (separators) |sep| {
//         var count: usize = 0;
//         for (line) |c| {
//             if (c == sep) count += 1;
//         }
//         if (count > max_count) {
//             max_count = count;
//             best_sep = sep;
//         }
//     }

//     return best_sep;
// }

fn createCsvData(allocator: Allocator, lines: [][]const u8) !CsvData {
    var csv_data = CsvData.init(allocator);
    // errdefer csv_data.deinit();

    if (lines.len == 0) {
        return error.EmptyCsv;
    }

    const separator = getSeparator(lines[0]);

    var header_it = std.mem.splitScalar(u8, lines[0], separator);
    while (header_it.next()) |field| {
        const trimmed = mem.trim(u8, field, &[_]u8{ ' ', '\t', '\r', '\n' });
        const dup = try allocator.dupe(u8, trimmed);
        try csv_data.placeholders.append(dup);
    }

    for (lines[1..]) |line| {
        var row = ArrayList([]const u8).init(allocator);
        errdefer {
            for (row.items) |item| {
                allocator.free(item);
            }
            row.deinit();
        }

        var field_it = std.mem.splitScalar(u8, line, separator);
        while (field_it.next()) |field| {
            const trimmed = mem.trim(u8, field, &[_]u8{ ' ', '\t', '\r', '\n' });
            const dup = try allocator.dupe(u8, trimmed);
            try row.append(dup);
        }

        try csv_data.data.append(row);
    }

    return csv_data;
}

pub fn pathToCsvData(allocator: Allocator, path: []const u8) !CsvData {
    const file = try fs.cwd().openFile(path, .{});
    defer file.close();

    var buffer = ArrayList(u8).init(allocator);
    defer buffer.deinit();

    try file.reader().readAllArrayList(&buffer, std.math.maxInt(usize));

    var lines = ArrayList([]const u8).init(allocator);
    defer {
        for (lines.items) |line| {
            allocator.free(line);
        }
        lines.deinit();
    }

    var line_it = std.mem.splitScalar(u8, buffer.items, '\n');
    while (line_it.next()) |line| {
        if (line.len == 0) continue;
        const dup = try allocator.dupe(u8, line);
        try lines.append(dup);
    }

    if (lines.items.len == 0) {
        return error.EmptyFile;
    }

    return try createCsvData(allocator, lines.items);
}
