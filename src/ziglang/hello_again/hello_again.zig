// https://ziglang.org/documentation/master/
// zig build-exe hello_again.zig
const std = @import("std");

pub fn main() void {
    std.debug.print("Hello, {s}!\n", .{"World"});
}
