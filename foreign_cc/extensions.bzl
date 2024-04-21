"""Entry point for extensions used by bzlmod."""

load("//foreign_cc:repositories.bzl", "DEFAULT_CMAKE_VERSION", "DEFAULT_MAKE_VERSION", "DEFAULT_MESON_VERSION", "DEFAULT_NINJA_VERSION", "DEFAULT_PKGCONFIG_VERSION", "rules_foreign_cc_dependencies")
load("//foreign_cc/private/framework:toolchain.bzl", "register_framework_toolchains")
load("//toolchains:built_toolchains.bzl", cmake_toolchains_src = "cmake_toolchain", "make_toolchain", "meson_toolchain", "pkgconfig_toolchain", ninja_toolchains_src = "ninja_toolchain")
load("//toolchains:prebuilt_toolchains.bzl", "cmake_toolchains", "ninja_toolchains")

cmake_toolchain_version = tag_class(attrs = {
    "version": attr.string(doc = "The cmake version", default = DEFAULT_CMAKE_VERSION),
})

make_toolchain_version = tag_class(attrs = {
    "version": attr.string(doc = "The GNU Make version", default = DEFAULT_MAKE_VERSION),
})

meson_toolchain_version = tag_class(attrs = {
    "version": attr.string(doc = "The meson version", default = DEFAULT_MESON_VERSION),
})

ninja_toolchain_version = tag_class(attrs = {
    "version": attr.string(doc = "The ninja version", default = DEFAULT_NINJA_VERSION),
})

pkgconfig_toolchain_version = tag_class(attrs = {
    "version": attr.string(doc = "The pkgconfig version", default = DEFAULT_PKGCONFIG_VERSION),
})

def _init(module_ctx):
    cmake_registered = False
    make_registered = False
    meson_registered = False
    ninja_registered = False
    pkgconfig_registered = False

    for mod in module_ctx.modules:
        if mod.is_root:
            for toolchain in mod.tags.cmake:
                cmake_toolchains_src(toolchain.version, register_toolchains = False)
                cmake_toolchains(toolchain.version, register_toolchains = False)
                cmake_registered = True

            for toolchain in mod.tags.make:
                make_toolchain(toolchain.version, register_toolchains = False)
                make_registered = True

            for toolchain in mod.tags.meson:
                meson_toolchain(toolchain.version, register_toolchains = False)
                meson_registered = True

            for toolchain in mod.tags.ninja:
                ninja_toolchains(toolchain.version, register_toolchains = False)
                ninja_toolchains_src(toolchain.version, register_toolchains = False)
                ninja_registered = True

            for toolchain in mod.tags.pkgconfig:
                pkgconfig_toolchain(toolchain.version, register_toolchains = False)
                pkgconfig_registered = True

    if not cmake_registered:
        cmake_toolchains_src(DEFAULT_CMAKE_VERSION, register_toolchains = False)
        cmake_toolchains(DEFAULT_CMAKE_VERSION, register_toolchains = False)
    if not make_registered:
        make_toolchain(DEFAULT_MAKE_VERSION, register_toolchains = False)
    if not meson_registered:
        meson_toolchain(DEFAULT_MESON_VERSION, register_toolchains = False)
    if not ninja_registered:
        ninja_toolchains(DEFAULT_NINJA_VERSION, register_toolchains = False)
        ninja_toolchains_src(DEFAULT_NINJA_VERSION, register_toolchains = False)
    if not pkgconfig_registered:
        pkgconfig_toolchain(DEFAULT_PKGCONFIG_VERSION, register_toolchains = False)

    register_framework_toolchains(register_toolchains = False)


tools = module_extension(
    implementation = _init,
    tag_classes = {
        "cmake": cmake_toolchain_version,
        "make": make_toolchain_version,
        "meson": meson_toolchain_version,
        "ninja": ninja_toolchain_version,
        "pkgconfig": pkgconfig_toolchain_version,
    },
)
