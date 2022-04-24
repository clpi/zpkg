const std = @import("std");
const str = []const u8;
const File = std.fs.File;
const Dir = std.fs.Dir;
const path = std.fs.path;
const stdout: fn() File = std.io.getStdOut;
const stdin: fn() File = std.io.getStdIn;
const Gpa = std.heap.GeneralPurposeAllocator(.{});
const Cmd = @import("../cmd.zig").RootCmd;
const pr = std.debug.print;
const warn = std.log.warn;
const Fmt = @import ("./Fmt.zig");
const Fg = Fmt.Fg;
const Bg = Fmt.Bg;


const Self = @This();

pub fn fromCmd(comptime c: ?Cmd) @This() {
    Self.print(c);
}

pub fn printPre(comptime c: Cmd) void {
    Headers.print(.title);
    Headers.print(.version);
    Headers.print(.author);
    pr(Fmt.nl, .{});
    const head = Headers{.usage = c};
    const ex = Headers{.example = c};
    head.print();
    ex.print();
}


pub const Headers = union(enum(u4)) {
    title,
    example: Cmd,
    usage: Cmd,
    version,
    arguments,
    options,
    flags,
    commands,
    author,

    pub fn titleFg() str {
        return Fg.yel("zpk: ") ++ Fg.whi("The ") 
        ++ Fg.grn("modular, ") ++ Fg.cya("distributed, ")
        ++ Fg.blu("multifunctional ")
        ++ Fg.whi("package manager for ")
        ++ Fg.bgrn("e") ++ Fg.bcya("v") ++ Fg.bblu("e")
        ++ Fg.bmag("r") ++ Fg.bred("y") ++ Fg.byel("o") 
        ++ Fg.bgrn("n") ++ Fg.bcya("e.");
    }

    pub fn usageFg(comptime cmd: Cmd) str {
        const cstr: str = if (cmd == .none) "" 
            else ": " ++ "(" ++ cmd.toStr() ++ ")";
        return Fg.bwhi("Usage") ++ Fg.cya(cstr);
    }

    pub fn authorFg() str {
        return Fg.bwhi("Author: ")
            ++ Fg.yel("Chris P ")
            ++ Fg.grn("<clp@clp.is>");

    }
    pub fn versionFg() str {
        return Fg.bwhi("Version: ")
            ++ Fg.yel("zbk ") 
            ++ Fg.grn("v0.1.0 ");
    }
 
    pub fn exampleFg(comptime c: Cmd) str {
        const cmdstr:str = if (c == Cmd.none) 
            "[commands] "
        else 
            c.toStr() ++ " ";
        return Fg.yel("zpk ")
            ++ Fg.grn(cmdstr)
            ++ Fg.blu("[options] ")
            ++ Fg.mag("[flags] ")
            ++ Fg.red("[arguments] ") ++ Fmt.nl;
    }

    pub fn fmt(comptime self: @This()) str {
        pr("\n", .{});
        return switch(self) {
            .title => titleFg(),
            .example => |cmd| comptime exampleFg(cmd),
            .usage => |cmd| comptime usageFg(cmd),
            .version => versionFg(),
            .author => authorFg(),
            .arguments => Fg.bmag("Arguments") ++ Fmt.nl,
            .options => Fg.bblu("Options") ++ Fmt.nl,
            .flags => Fg.byel("Flags") ++ Fmt.nl,
            .commands => Fg.bgrn("Commends") ++ Fmt.nl,
        };
    }

    pub fn print(comptime self: @This()) void {
        pr("{s}", .{self.fmt()});
    }
};

pub fn root() void {
    printPre(Cmd.none);
    Headers.print(.commands);
    pr(
    \\  - init | i
    \\  - add | a
    \\  - run | r
    \\  - remove | rm
    \\  - shell | sh
    \\  - build | b
    \\  - install | in
    \\  - clean | c
    \\  - sync | s
    \\  - update | u
    \\  - help | h
    ,.{});
    Headers.print(.options);
    Headers.print(.flags);
    Headers.print(.arguments);
    pr(
    \\ Options
    \\  --log-level | -l
    \\
    \\ Flags
    \\  --debug | -d
    \\  --help | -h
    \\  --version | -v
    , .{});

}

pub fn help() void {
    printPre(.help);
    pr("  zpk help <CMD?> [options] [flags]\n\n", .{});
    pr("  Arguments\n", .{});
    pr("    - CMD\t\t\tCommand to get help for \n", .{});
}

pub fn sync() void {
    printPre(.sync);
    _ = stdout().writer().write(
    \\  zpk sync [options] [flags]
    \\
    ) catch unreachable;
}


pub fn run() void {
    printPre(.run);
    _ = stdout().writer().write(
    \\  zpk run [options] [flags]
    \\
    ) catch unreachable;

}

pub fn init() void {
    printPre(.init);

}

pub fn shell() void {
    printPre(.shell);

}

pub fn build() void {
    printPre(.build);

}

pub fn print(cmd: Cmd) void {
    switch (cmd) {
        .help => Self.help(),
        .run => Self.run(),
        .init => Self.init(),
        .shell => Self.shell(),
        .build => Self.build(),
        .update => Self.root(),
        .sync => Self.root(),
        .install => Self.root(),
        .clean => Self.root(),
        .add => Self.root(),
        .remove => Self.root(),
        .none => Self.root(),
    } 
}
