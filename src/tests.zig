const std = @import("std");
const testing = std.testing;

const Field = @import("./lib.zig").Field;
const CharField = @import("./lib.zig").CharField;

test "Char field test" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var field = CharField.init(arena.allocator());
    try field.append_line("123");
    try field.append_line("456");
    try field.append_line("789");

    try testing.expect(field.ncols() == 3);
    try testing.expect(field.nrows() == 3);

    try testing.expect(field.get(0, 0).? == '1');
    try testing.expect(field.get(1, 1).? == '5');
    try testing.expect(field.get(2, 2).? == '9');

    try field.dump();
}

fn parse_int(char: u8) i64 {
    return std.fmt.parseInt(i64, &[_]u8{char}, 10) catch unreachable;
}

test "Field test" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var field = Field(i64).init(arena.allocator());
    try field.parse_line("123", parse_int);
    try field.parse_line("456", parse_int);
    try field.parse_line("789", parse_int);

    try testing.expect(field.ncols() == 3);
    try testing.expect(field.nrows() == 3);

    try testing.expect(field.get(0, 0).? == 1);
    try testing.expect(field.get(1, 1).? == 5);
    try testing.expect(field.get(2, 2).? == 9);

    try field.dump();
}
