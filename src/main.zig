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
        if (std.fs.path.dirname(link_path)) |dirname| {
            try self.home.createDirPath(self.io, dirname);
        }
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
    try dotfiles.symlink(allocator, "i3status/config", ".config/i3status/config");
    try dotfiles.symlink(allocator, "btop/btop.conf", ".config/btop/btop.conf");
    try dotfiles.symlink(allocator, "fcitx5/config", ".config/fcitx5/config");
    try dotfiles.symlink(allocator, "git/config", ".config/git/config");
    try dotfiles.symlink(allocator, "gtk/settings.ini", ".config/gtk-3.0/settings.ini");
    try dotfiles.symlink(allocator, "qt6ct/qt6ct.conf", ".config/qt6ct/qt6ct.conf");
    try dotfiles.symlink(allocator, "picom/picom.conf", ".config/picom.conf");
    try dotfiles.symlink(allocator, "bash/.bash_profile", ".bash_profile");
    try dotfiles.symlink(allocator, "bash/.bashrc", ".bashrc");
    try dotfiles.symlink(allocator, "x11/.xinitrc", ".xinitrc");
    try dotfiles.symlink(allocator, "clang/.clang-format", ".clang-format");
    try dotfiles.symlink(allocator, "emacs/.emacs", ".emacs");
}
