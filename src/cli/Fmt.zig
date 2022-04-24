const std = @import("std");
const str = []const u8;
const io = std.io;
const Writer = std.io.Writer;
const File = std.fs.File;
const Buffer = std.io.BufferedWriter;
const stdout: fn() File = std.io.getStdOut;
const stderr: fn() File = std.io.getStdErr;
const Allocator = std.mem.Allocator;
const stdin: fn() File = std.io.getStdIn;
// const Styles = [:0]Style;

const Fmt = @This();

pub const pre: []const u8 = "\x1b[";
pub const div: str = ";";
pub const post: []const u8 = "m";
pub const reset: []const u8 = "\x1b[0m";
pub const nl: []const u8 = "\n";
pub const dnl: []const u8 = "\n\n";

pub const t = "\t";
pub const dt = "\t\t";

fg: ?Fg = null,
bg: ?Bg = null,
styles: std.ArrayList(Style),

pub fn init(a: Allocator, fgc: ?Color, bgc: ?Color) Fmt {
    var fc = if (fgc) |f| Fg.init(f) else null;
    var bc = if (bgc) |b| Bg.init(b) else null;
    var styl = std.ArrayList(Style).init(a);
    // if (styles) |sty| for (sty) |s| try st.append(s);
    // var s = [0]Style{ };
    return Fmt{ .fg = fc, .bg = bc, .styles = styl };
}

pub fn fromFg(color: Color) Fmt {
    return Fmt.init(color, null, null);
}

pub fn fromBg(color: Color) Fmt {
    return Fmt.init(null, color, null);
}

pub fn style(s: Style) Fmt {
    return Fmt.init(null, null, .{ s });
}

pub fn toJson(self: Fmt) !void {
    // var buf: []u8 = [_]u8{ };
    try std.json.stringify(self, .{}, stdout().writer());
    // return buf;
}

pub fn addStyle(comptime self: *@This(), s: Style) Fmt {
    // const new: [self.styles.len + 1]Style = self.styles ++ [1]Style{ s };
    // const o = self.styles;
    var st = [1]Style{s};
    return Fmt{
        .fg = self.fg, .bg = self.bg, .styles =&st,
    };
}

// pub fn bold(self: *Fmt) void {}

pub fn fmt(comptime self: Fmt, comptime s: str) str {
    // var stys = std.ArrayList(u8);
    comptime var r: str = Fmt.pre 
        ++ (if (self.fg) |f| Fg.toStr(f.color) else "") 
        ++ (if (self.bg) |b| ";" ++ Bg.toStr(b.color) else "");
    for (self.styles.items) |sty| 
        r += sty.toStr();
        // stys.appendSlice(st.toStr() else ""
    // const rs = r ++ self.styles
    // comptime var st: []u8 = "";
    // inline for (self.styles) |sty| {
    //     var styl = sty.toStr();
    //     st += &styl;
    // } 
    
        // ++ ()
    const rc = r ++ Fmt.post ++ s;
    return rc;
    // var bf = std.ArrayList(u8).init(a);
    // bf.appendSlice(Fmt.pgalloc, re); // \x1b[
    // if (self.fg) |f| bf.appendSlice(f.toStr(a));
    // if (self.bg) |b| bf.appendSlice(b.toStr(a));
    // for (self.styles) |sty| bf.appendSlice(sty.toStr(a));
    // bf.append(Fmt.post);
    // for (s) |sch| bf.append(sch);
    // bf.append(Fmt.reset);
    // return bf.toOwnedSlice();
}

pub fn print(self: Fmt, s: str) void {
    const r: str = self.fmt(s);
    std.debug.print("{s}", .{r});
    // if (self.fg) |fc| try bw.print("{s}", .{fc.toStr(alloc)});
    // if (self.bg) |bc| try bw.print("{s}", .{bc.toStr(alloc)});
    // if (self.style.len > 0) for (self.style) |sty| 
    //     try bw.print("{d}", .{sty.toStr(a)});
    // try bw.print("{s}{s}", s, Fmt.reset());
}

pub fn code(comptime c: str, comptime s: str) str {
    return Fmt.pre ++ c ++ Fmt.post ++ s ++ Fmt.reset;
}

pub const Color = enum(u4) {
    const Self = @This();
    black   = 0,
    red     = 1,
    green   = 2,
    yellow  = 3,
    blue    = 4,
    magenta = 5,
    cyan    = 6,
    white   = 7,

    pub fn init(int: u4) Self {
        if (int > 9) @compileError("Invalid style number");
        return @intToEnum(Self, int);
    }

    pub fn toFg(self: Self) Fg {
        return Fg.init(self, .{});
    }

    pub fn toBg(self: Color) Fg {
        return Bg.init(self);
    }

    pub fn toFgStr(self: Color) str {
        return Fg.fmtC(self);
    }

    pub fn toBgStr(self: Color) str {
        return Bg.fmtC(self);
    }

    pub fn toInt(self: Self) u4 {
        return @enumToInt(self);
    }

    pub fn toStr(self: Self) []const u8 {
        return switch (self) {
            .black => "0",
            .red => "1",
            .green => "2",
            .yellow => "3",
            .blue => "4",
            .magenta => "5",
            .cyan => "6",
            .white => "7",
        };
        // return [1]u8{@intCast(u8, @enumToInt(self))};
        // return std.fmt.bufPrint(buf, "{d}", .{self.toInt()}) catch unreachable;
        // try std.fmt.parseInt([]u8, buf, @enumToInt(self))
        // catch unreachable;
    }
};

pub const Style = union(enum(u4)) {
    const Self = @This();

    pub const pre = ";";

    reset      = 0,
    bold       = 1,
    dim        = 2,
    italic     = 3,
    underline  = 4,
    sblink     = 5,
    fblink     = 6,
    invert     = 7,
    hide       = 8,
    strike     = 9,

    pub fn toInt(self: Self) u4 {
        return @enumToInt(self);
    }
    //
    // pub fn toStr(self: Self) str {
    //     return Self.pre ++ self.toInt();
    // }
    //
    pub fn toStr(comptime self: Style) str {
        return Self.pre ++ switch (self) {
            .reset => "0",
            .bold => "1",
            .dim => "2",
            .italic => "3",
            .underline => "4",
            .sblink => "5",
            .fblink => "6",
            .invert => "7",
            .hide => "8",
            .strike => "9",
        };
    }

    pub fn toStrPre(comptime self: Style) str {
        return Self.pre ++ self.toStr();
    }

    pub fn init(int: u4) Self {
        if (int > 9) @compileError("Invalid style number");
        return @intToEnum(Self, int);
    }

    pub fn initStyles(sty: []u4) []Self {
        var styles: []Self = [_]Self{ };
        inline for (sty) |s| styles.push(Self.init(s));
        return styles;
    }

};

pub const Fg = struct {
    const Self = @This();

    color: Color,

    pub fn init(color: Color) Self {
        return Self{
            .color = color,
        };
    }

    pub fn fullPre() []const u8 {
        return Fmt.pre ++ Self.pre; // \x1b[3
    }

    pub fn fmt(comptime color: Color, comptime s: str) str {
        return Fmt.pre ++ Self.toStr(color) ++ s;
    }


    pub fn fmtC(color: Color, s: str) str {
        return Self.init(color).fmt(s);
    }

    pub fn toStr(comptime color: Color) []const u8 {
        return Self.pre ++ color.toStr();
    }
    // pub fn toStr(self: Self) []const u8 {
    //     return Self.pre ++ self.color.toInt();
    //     // return std.fmt.allocPrint(alloc, "{s}{d}", .{Self.pre, self.color.toInt()})
    //     // catch unreachable; // 
    // }

    pub const pre: str = "3";

    pub const bk = "\x1b[30m";
    pub const rd = "\x1b[31m";
    pub const gn = "\x1b[32m";
    pub const yw = "\x1b[33m";
    pub const be = "\x1b[34m";
    pub const ma = "\x1b[35m";
    pub const cn = "\x1b[36m";
    pub const we = "\x1b[37m";

    pub fn blk(comptime s: str) str { return Fmt.code( "30", s); }
    pub fn bblk(comptime s: str) str { return Fmt.code("30;1", s);}

    pub fn red(comptime s: str) str { return Fmt.code( "31", s); }
    pub fn bred(comptime s: str) str { return Fmt.code("31;1", s);}

    pub fn grn(comptime s: str) str { return Fmt.code( "32", s); }
    pub fn bgrn(comptime s: str) str { return Fmt.code("32;1", s);}

    pub fn yel(comptime s: str) str { return Fmt.code( "33", s); }
    pub fn byel(comptime s: str) str { return Fmt.code("33;1", s);}

    pub fn blu(comptime s: str) str { return Fmt.code( "34", s); }
    pub fn bblu(comptime s: str) str { return Fmt.code("34;1", s);}

    pub fn mag(comptime s: str) str { return Fmt.code( "35", s); }
    pub fn bmag(comptime s: str) str { return Fmt.code("35;1", s);}

    pub fn cya(comptime s: str) str { return Fmt.code( "36", s); }
    pub fn bcya(comptime s: str) str { return Fmt.code("36;1", s);}

    pub fn whi(comptime s: str) str { return Fmt.code( "37", s); }
    pub fn bwhi(comptime s: str) str { return Fmt.code("37;1", s);}

};

pub const Bg = struct {
    const Self = @This();
    pub const pre: str = "4";

    color: Color,

    pub fn init(color: Color) Self {
        return Self{
            .color = color,
        };
    }

    pub fn fullPre() []const u8 {
        return Fmt.pre ++ Color.pre ++ Self.pre;// \x1b[4
    }

    pub fn toStr(comptime color: Color) []const u8 {
        return Self.pre ++ color.toStr();
        // return std.fmt.allocPrint(alloc, "{s}{d}", .{Self.pre, self.color.toInt()})
        // catch unreachable; // 
    }

    pub fn fmt(comptime c: Color, comptime s: str) str {
        return Fmt.pre ++ Self.toStr(c) ++ s;
    }

    pub fn fmtC(color: Color, s: str) str {
        return Self.init(color).fmt(s);
    }

    pub fn blk(comptime s: str) str { return Fmt.code( "40", s); }
    pub fn red(comptime s: str) str { return Fmt.code( "41", s); }
    pub fn grn(comptime s: str) str { return Fmt.code( "42", s); }
    pub fn yel(comptime s: str) str { return Fmt.code( "43", s); }
    pub fn blu(comptime s: str) str { return Fmt.code( "44", s); }
    pub fn mag(comptime s: str) str { return Fmt.code( "45", s); }
    pub fn cya(comptime s: str) str { return Fmt.code( "46", s); }
    pub fn whi(comptime s: str) str { return Fmt.code( "47", s); }
    pub fn bblk(comptime s: str) str { return Fmt.code( "40;1", s); }
    pub fn bred(comptime s: str) str { return Fmt.code( "41;1", s); }
    pub fn bgrn(comptime s: str) str { return Fmt.code( "42;1", s); }
    pub fn byel(comptime s: str) str { return Fmt.code( "43;1", s); }
    pub fn bblu(comptime s: str) str { return Fmt.code( "44;1", s); }
    pub fn bmag(comptime s: str) str { return Fmt.code( "45;1", s); }
    pub fn bcya(comptime s: str) str { return Fmt.code( "46;1", s); }
    pub fn bwhi(comptime s: str) str { return Fmt.code( "47;1", s); }


    pub const bk = "\x1b[40m";
    pub const rd = "\x1b[41m";
    pub const gn = "\x1b[42m";
    pub const yw = "\x1b[43m";
    pub const be = "\x1b[44m";
    pub const ma = "\x1b[45m";
    pub const cn = "\x1b[46m";
    pub const wh = "\x1b[47m";
};


const testing = std.testing;
const expect = std.testing.expect;
const expectFmt = std.testing.expectFmt;
const expectEq = std.testing.expectEqual;
const expectEqStr = std.testing.expectEqualStrings;
test "Color ok" {
    try expectEqStr(Fg.toStr(.blue), "34");
    try expectEqStr(Fg.toStr(.green), "32");
}

test "Bg toStr" {
    try expectEqStr(Bg.toStr(.red), "41");
    try expectEqStr(Bg.toStr(.white), "47");
}
