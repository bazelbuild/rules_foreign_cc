""" Remote repositories, used by this project itself """

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def repositories():
    _all_content = """filegroup(name = "all", srcs = glob(["**"]), visibility = ["//visibility:public"])"""

    http_archive(
        name = "bazel_skylib",
        build_file_content = _all_content,
        sha256 = "eb5c57e4c12e68c0c20bc774bfbc60a568e800d025557bc4ea022c6479acc867",
        strip_prefix = "bazel-skylib-0.6.0",
        type = "tar.gz",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/archive/0.6.0.tar.gz",
        ],
    )

    http_archive(
        name = "ninja_build",
        build_file_content = _all_content,
        sha256 = "86b8700c3d0880c2b44c2ff67ce42774aaf8c28cbf57725cb881569288c1c6f4",
        strip_prefix = "ninja-1.8.2",
        urls = [
            "https://github.com/ninja-build/ninja/archive/v1.8.2.tar.gz",
        ],
    )

    http_archive(
        name = "cmake",
        build_file_content = _all_content,
        strip_prefix = "CMake-3.12.1",
        urls = [
            "https://github.com/Kitware/CMake/archive/v3.12.1.tar.gz",
        ],
    )
