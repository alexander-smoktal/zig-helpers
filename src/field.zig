const std = @import("std");

pub fn Field(comptime T: type) type {
    return struct {
        const Self = @This();

        data: std.ArrayList(std.ArrayList(T)),
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .data = std.ArrayList(std.ArrayList(T)).init(allocator),
                .allocator = allocator,
            };
        }

        pub fn set(self: *Self, row: i64, column: i64, char: T) void {
            if (self.data.items.len <= row) {
                self.data.append(std.ArrayList(T).init(self.allocator)) catch unreachable;
            }

            var row_elem = &self.data.items[row];
            if (row_elem.items.len <= column) {
                row_elem.resize(column + 1) catch unreachable;
            }

            row_elem.items[column] = char;
        }

        pub fn get(self: Self, row: i64, column: i64) ?T {
            if (row < 0 or row >= self.nrows()) {
                return null;
            }

            if (column < 0 or column >= self.ncols()) {
                return null;
            }

            return self.data.items[@intCast(row)].items[@intCast(column)];
        }

        pub fn nrows(self: Self) usize {
            return self.data.items.len;
        }

        pub fn ncols(self: Self) usize {
            return self.data.items[0].items.len;
        }

        pub fn append_line(self: *Self, line: []const T) !void {
            try self.data.append(std.ArrayList(T).init(self.allocator));
            var last_row = &self.data.items[self.data.items.len - 1];

            for (line) |letter| {
                try last_row.append(letter);
            }
        }

        pub fn parse_line(self: *Self, line: []const u8, comptime parse_fn: fn (u8) T) !void {
            try self.data.append(std.ArrayList(T).init(self.allocator));
            var last_row = &self.data.items[self.data.items.len - 1];

            for (line) |letter| {
                try last_row.append(parse_fn(letter));
            }
        }

        pub fn clone(self: Self) !Self {
            var data = std.ArrayList(std.ArrayList(T)).init(self.allocator);

            for (self.data.items) |arr| {
                try data.append(try arr.clone());
            }

            return Self{
                .data = data,
                .allocator = self.allocator,
            };
        }

        pub fn dump(self: Self) !void {
            const stdout_file = std.io.getStdOut().writer();

            for (self.data.items) |row| {
                for (row.items) |item| {
                    try stdout_file.print("{any}", .{item});
                }

                try stdout_file.print("\n", .{});
            }
            try stdout_file.print("\n", .{});
        }
    };
}
