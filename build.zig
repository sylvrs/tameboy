const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});

    const wasm_target = try std.Build.parseTargetQuery(.{ .arch_os_abi = "wasm32-freestanding" });
    const exe = b.addExecutable(.{
        .name = "tameboy",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(wasm_target),
        .optimize = optimize,
        .version = .{ .major = 0, .minor = 0, .patch = 1 },
    });
    exe.rdynamic = true;
    exe.entry = .disabled;

    const install = b.addInstallArtifact(exe, .{
        .dest_dir = .{ .override = .{ .custom = "../src/assets/" } },
    });
    install.step.dependOn(&exe.step);

    const run_bun = b.addSystemCommand(&.{ "bun", "run", "dev" });

    const run_step = b.step("run", "Builds the WASM library and runs the website");
    run_bun.step.dependOn(&install.step);
    run_step.dependOn(&run_bun.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(wasm_target),
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
