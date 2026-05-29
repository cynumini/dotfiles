const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    var run_result = try std.process.run(allocator, init.io, .{
        .argv = &.{ "xclip", "-o", "-sel", "clip" },
    });
    const image_path = run_result.stdout;
    std.log.info("Input path: \"{s}\"", .{image_path});
    if (!std.fs.path.isAbsolute(image_path)) {
        std.log.err("The path is not absolute or does not exist.", .{});
        return;
    }
    try std.Io.Dir.accessAbsolute(init.io, image_path, .{});
    const output_path = try std.fs.path.join(
        allocator,
        &.{ init.environ_map.get("HOME").?, "Pictures/wallpaper.png" },
    );
    std.log.info("Output path: \"{s}\"", .{output_path});
    std.log.info("Creating image with ImageMagick", .{});
    const argv: [21][]const u8 =
        .{"magick"} ++
        .{
            "(",
            image_path,
            "-resize",
            "1920x",
            "-blur",
            "0x8",
            "-gravity",
            "center",
            "-crop",
            "1920x1080+0+0",
            ")",
        } ++
        .{ "(", image_path, "-resize", "x1080", ")" } ++
        .{ "-gravity", "center", "-composite", output_path };
    run_result = try std.process.run(allocator, init.io, .{ .argv = &argv });
    std.log.info("Setting wallpaper with xwallpaper", .{});
    run_result = try std.process.run(
        allocator,
        init.io,
        .{ .argv = &.{ "xwallpaper", "--center", output_path } },
    );
}
