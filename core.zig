// const std = @import("std");

// pub const CsvData = struct {
//     placeholders: []std.String,
//     data: [][]std.String,
// };

// pub fn pathToCsvData(allocator: std.mem.Allocator, path: []const u8) !CsvData {
//     var file = try std.fs.cwd().openFile(path, .{});
//     defer file.close();

//     var reader = std.io.bufferedReader(file.reader());
//     var separator: u8 = undefined;

//     if (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |first_line| {
//         defer allocator.free(first_line);
//         separator = try getSeparator(first_line);
//     } else {
//         return error.separator_error;
//     }

//     var csv_reader = try std.csv.Reader.init(allocator, file.reader(), separator);
//     defer csv_reader.deinit();

//     const csv_data = try createCsvData(allocator, csv_reader);
//     return csv_data;
// }

// pub fn createCsvData(allocator: std.mem.Allocator, reader: std.csv.Reader) !CsvData {
//     const placeholders = try reader.headers(allocator);
//     defer allocator.free(placeholders);

//     try checkHeader(placeholders);

//     var data = std.ArrayList([]std.String).init(allocator);
//     defer data.deinit();

//     while (try reader.next()) |row| {
//         var line = try std.ArrayList(std.String).initCapacity(allocator, row.len);
//         defer line.deinit();

//         for (row) |field| {
//             try line.append(try std.String.init(allocator, field));
//         }

//         try data.append(line.items);
//     }

//     const csv_data = CsvData{
//         .placeholders = placeholders,
//         .data = data.items,
//     };

//     return csv_data;
// }

// fn getSeparator(line: []u8) !u8 {
//     const mem = std.mem;

//     if (mem.indexOf(u8, line, ";") != null) {
//         return ';';
//     } else if (mem.indexOf(u8, line, "|") != null) {
//         return '|';
//     } else if (mem.indexOf(u8, line, "\t") != null) {
//         return '\t';
//     } else if (mem.indexOf(u8, line, ",") != null) {
//         return ',';
//     } else {
//         return ',';
//     }
// }

// fn checkHeader(placeholders: []std.String) !void {
//     // implementação da função checkHeader aqui
// }
