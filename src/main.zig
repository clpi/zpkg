const std = @import("std");
const log = std.log.scoped;
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();
const builtin = @import("builtin");
const Gpa = std.heap.GeneralPurposeAllocator(.{});
const Allocator = std.mem.Allocator;
const ArgIterator = std.process.ArgIterator;
const cli = @import("./cli.zig");

pub fn main() anyerror!void {
    var gpa = Gpa{};
    const global_alloc: Allocator = if (comptime builtin.target.isWasm()) {
        return gpa.allocator();
    } else gpa.allocator();
    var args: ArgIterator = std.process.args();
    _ = args.skip();
    while ( args.next(global_alloc)) |arg| {
        if (cli.Cmd.fromStr(try arg)) |cmd| {
            try cmd.run();
        } else try cli.Cmd.default().run();
    }
    std.log.info("All your codebase are belong to us.", .{});
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
