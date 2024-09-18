const std = @import("std");
const ldmd2 = @import("abs").ldc2;
const zcc = @import("abs").zcc;

pub fn build(b: *std.Build) !void {
    // replace mingw to msvc on default windows target
    const target = b.standardTargetOptions(.{
        .default_target = if (@import("builtin").os.tag == .windows)
            try std.Target.Query.parse(.{
                .arch_os_abi = "native-windows-msvc",
            })
        else
            .{},
    });
    const optimize = b.standardOptimizeOption(.{});

    const examples = &.{
        "base",
        "list",
        "set",
        "string",
        "vector",
    };

    const lib = b.addObject(.{
        .name = "testobj",
        .target = target,
        .optimize = optimize,
    });
    lib.addCSourceFile(.{
        .file = b.path("extras/test.cpp"),
        .flags = &.{
            "-std=c++11",
        },
    });
    lib.pie = true;
    if (lib.rootModuleTarget().abi != .msvc)
        lib.linkLibCpp() // static libc++ + libc++abi + libunwind
    else
        lib.linkLibC(); // winsdk + msvc++

    inline for (examples) |example| {
        ldcBuild(b, .{
            .name = example,
            .kind = .@"test", // single runner-test (default: exe)
            .target = target,
            .optimize = optimize,
            // .betterC = true, // disable D runtimeGC
            .artifact = lib, // c++ library
            .sources = &.{
                b.fmt("source/stdcpp/test/{s}.d", .{example}),
            },
            .dflags = &.{
                "-w",
                "-L-E", // export-dynamic alias (lld and zld)
            },
            .ldflags = &.{"c++"}, // library name only
            .cxx_interop = .cxx11, // extern-std
            .importPaths = &.{
                "source",
            },
            .use_zigcc = true, // use generated zcc (zig c++ wrapper) as linker and gcc
            .zcc_options = try zcc.buildOptions(b, target),
        });
    }
}

fn ldcBuild(b: *std.Build, options: ldmd2.DCompileStep) void {
    const exe = ldmd2.BuildStep(b, options) catch |err| {
        std.log.err("Error: {s}\n", .{@errorName(err)});
        return;
    };
    b.getInstallStep().dependOn(&exe.step);
}
