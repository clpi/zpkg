const std = @import("std");
const str = []const u8;
const log = std.log.scoped(.cli);
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();
const builtin = @import("builtin");
const Gpa = std.heap.GeneralPurposeAllocator(.{});
const Allocator = std.mem.Allocator;
const ArgIterator = std.process.ArgIterator;

pub fn eq(a: str, b: str) bool {
    return std.mem.eql(u8, a, b);
}

pub fn isCmd(s: str, long: str, short: str) bool {
    if (!std.mem.eql(u8, s, ""))
        return eq(s, short) or eq(s, long);
    return eq(s, long);
}

pub fn isArg(s: str, long: str, short: str) bool {
    if (std.mem.startsWith("--", s)) 
        return eq(s, long);
    if (std.mem.startsWith("-", s))
        return eq(s, short);
    return false;
}

pub const Cmd = enum(u8) {
    help, init, run, build, shell,

    pub fn fromStr(s: []const u8) ?Cmd {
        if (isCmd(s, "help", "h")) return .help
        else if (isCmd(s, "init", "i")) return .init
        else if (isCmd(s, "run", "r"))  return .run
        else if (isCmd(s, "build", "b")) return .build
        else return null;
    }

    pub fn default() Cmd {
        return .help;
    }

    pub fn toStr(self: @This()) []const u8 {
        return @tagName(self);
    }

    pub fn run(self: @This()) CmdError!void {
        log.info("\x1b[32;1m[RUN]:\x1b[0m\x1b[33m {s}\x1b[0m", .{self.toStr()});
        switch (self) {
            .help => {

            },
            .shell => {

            },
            .init => {

            },
            .run => {

            },
            .build => {

            }
        }
    }
};


pub fn cli() anyerror!void {
    var gpa = Gpa{};
    const global_alloc: Allocator = if (comptime builtin.target.isWasm()) {
        return gpa.allocator();
    } else gpa.allocator();
    var args: ArgIterator = std.process.args();
    while ( args.next(global_alloc)) |arg| {
        log.info("arg: {s}", .{try arg});
    }
    _ = args.skip();
    std.log.info("All your codebase are belong to us.", .{});
}

pub const CmdError = error{
    parse_error,
    run_error
};

const testing = std.testing;

test "Cmd fromStr" {
    try testing.expectEqual(Cmd.fromStr("help"), .help);
    try testing.expectEqual(Cmd.fromStr("init"), .init);
    try testing.expectEqual(Cmd.fromStr("r"), .run);
    try testing.expectEqual(Cmd.fromStr("b"), .build);
}
test "Cmd toStr" {
    try testing.expect(std.mem.eql(u8, Cmd.toStr(.help), "help"));
    try testing.expect(std.mem.eql(u8, Cmd.toStr(.init), "init"));
    try testing.expect(std.mem.eql(u8, Cmd.toStr(.run), "run"));
    try testing.expect(std.mem.eql(u8, Cmd.toStr(.build), "build"));
    var stdo =  stdout.writer();
    _ = try stdo.write("hje");
}
