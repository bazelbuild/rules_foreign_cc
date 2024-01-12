"""Entry point for extensions used by bzlmod."""

load("//foreign_cc:repositories.bzl", "DEFAULT_CMAKE_VERSION", "DEFAULT_MAKE_VERSION", "DEFAULT_MESON_VERSION", "DEFAULT_NINJA_VERSION", "DEFAULT_PKGCONFIG_VERSION", "rules_foreign_cc_dependencies")
load("//toolchains:built_toolchains.bzl", "make_toolchain", "meson_toolchain", "pkgconfig_toolchain")
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
    for mod in module_ctx.modules:
        if mod.is_root:
            for toolchain in mod.tags.cmake:
                cmake_toolchains(toolchain.version, register_toolchains = False)

            for toolchain in mod.tags.make:
                make_toolchain(toolchain.version, register_toolchains = False)

            for toolchain in mod.tags.meson:
                meson_toolchain(toolchain.version, register_toolchains = False)

            for toolchain in mod.tags.ninja:
                ninja_toolchains(toolchain.version, register_toolchains = False)

            for toolchain in mod.tags.pkgconfig:
                pkgconfig_toolchain(toolchain.version, register_toolchains = False)

    cmake_toolchains(DEFAULT_CMAKE_VERSION, register_toolchains = False)
    make_toolchain(DEFAULT_MAKE_VERSION, register_toolchains = False)
    meson_toolchain(DEFAULT_MESON_VERSION, register_toolchains = False)
    ninja_toolchains(DEFAULT_NINJA_VERSION, register_toolchains = False)
    pkgconfig_toolchain(DEFAULT_PKGCONFIG_VERSION, register_toolchains = False)

    rules_foreign_cc_dependencies(
        register_toolchains = False,
        register_built_tools = True,
        register_default_tools = False,
        register_preinstalled_tools = False,
        register_built_pkgconfig_toolchain = False,
    )

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
