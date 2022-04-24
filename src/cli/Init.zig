const std=@import("std");
const str = []const u8;

dir: std.fs.Dir = std.fs.cwd(),
name: ?str = null,
debug: bool = true,
