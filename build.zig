const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // root module (main.zig)
    const root_mod = b.createModule(.{
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // main executable
    const exe = b.addExecutable(.{
        .name = "ficherozig",
        .root_module = root_mod,
    });
    b.installArtifact(exe);

    // `zig build run` -> compile and run
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Compile and run the program");
    run_step.dependOn(&run_cmd.step);

    // `zig build test` -> run all tests
    const csv_core_mod = b.createModule(.{
        .root_source_file = b.path("csv_core.zig"),
        .target = target,
        .optimize = optimize,
    });
    const test_mod = b.createModule(.{
        .root_source_file = b.path("tests/all_tests.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "csv_core", .module = csv_core_mod },
        },
    });
    const unit_tests = b.addTest(.{ .root_module = test_mod });
    const run_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_tests.step);
}
