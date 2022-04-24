pub const std = @import("std");
const mem = std.mem;
const str = []const u8;
const builtin = @import("builtin");

pub const ArgPosition = union {
    index: usize,
    cmd: Cmd,
    flag: Flag,
    opt: Opt,

    pub fn initIndex(ix: usize) !ArgPosition {
        if (ix < 0) return DefinitionError.NoNegativeNumbers;
        return ArgPosition { .index = ix };
    }

    pub fn initCmd(cmd: Cmd) !ArgPosition {
        return ArgPosition { .cmd = cmd };
    }
};

pub const IndexRange = struct {
    above: ?usize,
    below: ?usize,
};

pub const Scope = union(enum(u3)) {
    position = union(enum(u2)) {
        exact: usize,
        range = IndexRange,
    },
    cmd: Cmd,
    global,
};

pub const Opt = struct {
    short: str,
    long: str,
    strval: ?str = null,
    default_val: ?str = null,
    required: bool = false,
    valtype: type = str,

    pub const OptError = error{
        missing_value,
        invalid_value_type,
        custom_error,
    };
};

pub const Flag = struct {
    short: str,
    long: str,
    pos: ?usize = null,

    /// Take first letter of str for short, str itself for long, no pos
    pub fn default(s: str) Flag {
        return Flag{ .short = s[0..1], .long = s, .pos = null };
    }

    pub fn init(s: str, long: str, pos: ?usize) Flag {
        return Flag{.short = s, .long = long, .pos = pos};
    }
};

pub const Cmd = struct {
    short: str,
    long: str,
    pos: ?usize,
};
pub fn Param(comptime Ty: type) type {
    return struct {
        const Self = @This();
        param: Ty,
        val: ?str = null,
    };
}

pub fn List(comptime T: type) []const T {
    return [_]T{ };
}

// pub const RawArgs = struct {
//     args: [_][]const u8
// };
//
pub fn Parser() type {
    return struct {
        const Context = union(enum) {
            parsing: Position,
            in_opt: Opt,
            parsing_literal: Position,
        };

        const Position = struct {
            idx: usize,
            current: str,
        };

        const Errors = error{

        };

        cmds: []const Cmd,
        opts: []const Opt,
        flags: []const Flag,
        args: *std.process.ArgIterator,
        context: Context = .parsing,
        errors: [:0]Errors = [_]Errors{},
        



    };
}

pub const DefinitionError = error{
    NoNegativeNumbers
};

pub fn CmdInfo(
    
    comptime Opts: type, 
    comptime Flags: type,
    comptime Args: type) type
{
    return struct {
        opts: ?Opts,
        flags: ?Flags,
        args: ?Args,
        pos: ?usize = 0,

        const Self = @This();
        
        pub fn init(o: ?Opts, f: ?Flags, a: ?Args, pos: ?usize) Self {
            return Self {
                .opts = o,
                .flags = f,
                .args = a,
                .pos = pos,
            };
        }

        pub fn mainSubcmd(o: ?Opts, f: ?Flags, a: ?Args) Self {
            return Self.init(o, f, a, 0);
        }
    };
}

test "List generic" {
    try std.testing.expectEqual(@TypeOf(List(str)), @TypeOf([][]const u8));
}
