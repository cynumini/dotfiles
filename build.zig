const std = @import("std");

pub fn script(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    comptime name: []const u8,
) void {
    const exe = b.addExecutable(.{
        .name = name,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/" ++ name ++ ".zig"),
            .strip = optimize != .Debug,
        }),
    });
    b.installArtifact(exe);
    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step(name, "Run the " ++ name);
    run_step.dependOn(&run_exe.step);
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const scripts = b.option(bool, "scripts", "Build scripts only") orelse false;
    if (!scripts) {
        script(b, target, optimize, "deploy");
    }
    script(b, target, optimize, "wallpaper");
}
