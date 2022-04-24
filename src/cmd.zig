const std = @import("std");
const Fmt = @import("./cli/Fmt.zig");
const builtin = @import("builtin");
const Help = @import("./cli/Help.zig");
const Init = @import("./cli/Init.zig");
const str = []const u8;
const log = std.log.scoped(.cli);
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();
const Gpa = std.heap.GeneralPurposeAllocator(.{});
const Allocator = std.mem.Allocator;
const ArgIterator = std.process.ArgIterator;

// cmd: ?RootCmd,
// opts: ?RootOpts,
// flags: ?RootOpts,

pub fn eq(a: str, b: str) bool {
    return std.mem.eql(u8, a, b);
}

pub fn isCmd(s: str, long: str, short: str) bool {
    return if (!eq(s, "")) eq(s, short) or eq(s, long)
    else eq(s, long);
}

pub fn isOpt(s: str, val: str, long: str, short: str) ?RootOpts {
    if (val) |v|
        if (std.mem.startsWith(u8, v, "-")) return null
        else if (eq(v, short))
    return if (std.mem.startsWith(u8, "--", s)) eq(s[2..], long)
    else if (std.mem.startsWith(u8, "-", s)) eq(s[1..], short)
    else false;
}

// pub fn isFlag(s: str, val: ?str, long: str, short: str) bool {
    // return false;
    // return if (std.mem)
// }

pub const RootFlags = union(enum) {
    debug,
    version,
    help,
    pub fn fromStr(s: str) ?RootFlags {
        if (isOpt(s, "debug", "d")) return .debug
        else if (isOpt(s, "version", "v")) return .version
        else if (isOpt(s, "help", "h")) return .help
        else return null;
    }
};
pub const RootOpts = union(enum){ 
    dir: ?str,
    log_level: ?str,
    profile: ?str,

    // pub fn fromStr(s: str, nx: str) ?RootOpts {
        // if (isOpt(s, "debug", "d")) return .debug
        // else if (isOpt(s, "version", "v")) return .version
        // else if (isOpt(s, "help", "h")) return .help
        // else if (isOpt(s, "log-level", "l")) return .log_level
        // else if (isOpt(s, "dir", "d")) return Opt{dir = 
        // else 
        // return null;
    // }
};

pub const RootCmd = enum {
    const Self = @This();

    help,
    clean,
    add,
    remove,
    init,
    run,
    build,
    shell,
    install,
    sync,
    update,
    none,

    pub fn parse(a: Allocator) anyerror!RootCmd {
        var args: ArgIterator = std.process.args();
        var i: usize = 0;
        var cmd: RootCmd = RootCmd.none;
        while ( args.next(a)) |arg| : (i += 1) {
            std.debug.print("\t{d}: {s}\n", .{i, try arg});
            switch (i) {
                0 => continue,
                1 => cmd = RootCmd.fromStr(try arg),
                else => {
                    std.debug.print("ARG: {d} {s} ", .{i, try arg});
                }
            }
        }
        return cmd;
    }

    pub fn fromStr(s: []const u8) Self {
        //TODO: get args from respective structs
        if      (isCmd(s, "help", "h")) return .help
        else if (isCmd(s, "init", "i")) return .init
        else if (isCmd(s, "remove", "rm")) return .remove
        else if (isCmd(s, "sync", "s")) return .remove
        else if (isCmd(s, "update", "u")) return .remove
        else if (isCmd(s, "add", "a")) return .add
        else if (isCmd(s, "install", "in")) return .install
        else if (isCmd(s, "clean", "c")) return .clean
        else if (isCmd(s, "run", "r"))  return .run
        else if (isCmd(s, "shell", "sh"))  return .shell
        else if (isCmd(s, "build", "b")) return .build
        else return RootCmd.none;
    }

    pub fn default() RootCmd {
        return .none;
    }

    pub fn toStr(self: @This()) []const u8 {
        return @tagName(self);
    }

    pub fn help(self: Self) void {
        Help.print(self);
    }

    pub fn run(self: Self) CmdError!void {
        switch (self) {
            .clean => {
                self.help();

            },
            .help => {
                self.help();

            },
            .sync => {
                self.help();

            },
            .update => {
                self.help();

            },
            .add => {
                self.help();

            },
            .install => {
                self.help();

            },
            .remove => {
                self.help();

            },
            .shell => {
                self.help();
            },
            .init => {
                self.help();

            },
            .run => {
                self.help();

            },
            .build => {
                self.help();
                // std.debug.print("{s} {s}", Fmt)

            },
            .none => {
                self.help();

            }// Help.root(),
        }
    }
};


pub fn cli() anyerror!void {
    var gpa = Gpa{};
    const global_alloc: Allocator = if (comptime builtin.target.isWasm()) {
        return gpa.allocator();
    } else gpa.allocator();
    var args: ArgIterator = std.process.args();
    _ = args.skip();
    while ( args.next(global_alloc)) |arg| {
        log.info("arg: {s}", .{try arg});
    }
    std.log.info("All your codebase are belong to us.", .{});
}

pub const CmdError = error{
    parse_error,
    run_error
};

const testing = std.testing;

test "Cmd fromStr" {
    try testing.expectEqual(RootCmd.fromStr("help"), .help);
    try testing.expectEqual(RootCmd.fromStr("init"), .init);
    try testing.expectEqual(RootCmd.fromStr("r"), .run);
    try testing.expectEqual(RootCmd.fromStr("b"), .build);
}
test "Cmd toStr" {
    try testing.expect(std.mem.eql(u8, RootCmd.toStr(.help), "help"));
    try testing.expect(std.mem.eql(u8, RootCmd.toStr(.init), "init"));
    try testing.expect(std.mem.eql(u8, RootCmd.toStr(.run), "run"));
    try testing.expect(std.mem.eql(u8, RootCmd.toStr(.build), "build"));
    var stdo =  stdout.writer();
    _ = try stdo.write("hje");
}
