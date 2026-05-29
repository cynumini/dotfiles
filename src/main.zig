const std = @import("std");

const Dotfiles = struct {
    io: std.Io,
    current_path: []const u8,
    home: std.Io.Dir,

    pub fn init(
        io: std.Io,
        current_path: []const u8,
        home_path: []const u8,
    ) !Dotfiles {
        return .{
            .current_path = current_path,
            .home = try std.Io.Dir.openDirAbsolute(
                io,
                home_path,
                .{},
            ),
            .io = io,
        };
    }

    pub fn symlink(self: Dotfiles, allocator: std.mem.Allocator, target_path: []const u8, link_path: []const u8) !void {
        try self.home.createDirPath(self.io, std.fs.path.dirname(link_path).?);
        self.home.symLink(
            self.io,
            try std.fs.path.join(
                allocator,
                &.{ self.current_path, target_path },
            ),
            link_path,
            .{},
        ) catch |err| switch (err) {
            error.PathAlreadyExists => {},
            else => |e| return e,
        };
    }
};

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const dotfiles = try Dotfiles.init(
        init.io,
        try std.process.currentPathAlloc(init.io, allocator),
        init.environ_map.get("HOME").?,
    );
    try dotfiles.symlink(allocator, "i3/config", ".config/i3/config");
}
