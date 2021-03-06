const std = @import("std");
const log = std.log.scoped;
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();
const builtin = @import("builtin");
const Gpa = std.heap.GeneralPurposeAllocator(.{});
const Allocator = std.mem.Allocator;
const ArgIterator = std.process.ArgIterator;
const RootCmd = @import("./cmd.zig").RootCmd;
const Fmt = @import("./cli/Fmt.zig");
const Style = Fmt.Style;
const Color = Fmt.Color;

pub fn main() anyerror!void {
    var gpa = Gpa{};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    const galloc = if (comptime builtin.target.isWasm())
        arena.child_allocator
    else
        gpa.allocator();
    const cmd: RootCmd = RootCmd.parse(galloc) catch unreachable;
    // comptime var f1 = Fmt.init(gpa.allocator(), .black, .yellow);
    // var f2 = Fmt.init(galloc, .red, .blue);
    // var f3 = f2.addStyle(.bold);
    // std.debug.print("{s}{s}{s} {s} {s} {s}", .{
    //     f1.fmt("Hi there"), Fmt.reset,
    //     Fmt.post,
    //     f1.fmt("FSDF"),
        // Fmt.pre ++ Fmt.Fg.toStr(.green) ++ Fmt.div ++ Fmt.Bg.toStr(.blue) ++ "hi there" + Fmt.post,
        // f1.toJson(),
    //     f1.fmt("FDJSKJDF"),
    //     Fmt.Fg.fmt(.red, "hi"),
    // });
    try cmd.run();
}

pub fn allocator() Allocator {
    var gpa = Gpa{};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    return arena.child_allocator;
    // return if (comptime builtin.target.isWasm()) gpa.allocator()
    // else gpa.allocator();
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
