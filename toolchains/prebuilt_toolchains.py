#!/usr/bin/env python3

from pathlib import Path
from textwrap import indent
import hashlib
import json
import urllib.request


CMAKE_SHA256_URL_TEMPLATE = "https://cmake.org/files/v{minor}/cmake-{full}-SHA-256.txt"
CMAKE_URL_TEMPLATE = "https://github.com/Kitware/CMake/releases/download/v{full}/{file}"

CMAKE_VERSIONS = [
    "3.19.6",
    "3.19.5",
    "3.18.6",
    "3.17.5",
    "3.16.9",
    "3.15.7",
    "3.14.7",
]

CMAKE_TARGETS = {
    "Darwin-x86_64": [
        "@platforms//cpu:x86_64",
        "@platforms//os:macos",
    ],
    "Linux-aarch64": [
        "@platforms//cpu:aarch64",
        "@platforms//os:linux",
    ],
    "Linux-x86_64": [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    "macos-universal": [
        "@platforms//os:macos",
    ],
    "win32-x86": [
        "@platforms//cpu:x86_32",
        "@platforms//os:windows",
    ],
    "win64-x64": [
        "@platforms//cpu:x86_64",
        "@platforms//os:windows",
    ],
}

NINJA_URL_TEMPLATE = "https://github.com/ninja-build/ninja/releases/download/v{full}/ninja-{target}.zip"

NINJA_TARGETS = {
    "linux": [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    "mac": [
        "@platforms//cpu:x86_64",
        "@platforms//os:macos",
    ],
    "win": [
        "@platforms//cpu:x86_64",
        "@platforms//os:windows",
    ],
}

NINJA_VERSIONS = (
    "1.10.2",
    "1.10.1",
    "1.10.0",
    "1.9.0",
    "1.8.2",
)

REPO_DEFINITION = """\
maybe(
    http_archive,
    name = "{name}",
    urls = [
        "{url}",
    ],
    sha256 = "{sha256}",
    strip_prefix = "{prefix}",
    build_file_content = {template}.format(
        bin = "{bin}",
    ),
)
"""

TOOLCHAIN_REPO_DEFINITION = """\
# buildifier: leave-alone
maybe(
    prebuilt_toolchains_repository,
    name = "{name}",
    repos = {repos},
    tool = "{tool}",
)
"""

REGISTER_TOOLCHAINS = """\
native.register_toolchains(
{toolchains}
)
"""

BZL_FILE_TEMPLATE = """\
\"\"\" A U T O G E N E R A T E D  -- D O   N O T   M O D I F Y
@generated

This file is generated by prebuilt_toolchains.py
\"\"\"

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@rules_foreign_cc//toolchains:prebuilt_toolchains_repository.bzl", "prebuilt_toolchains_repository")

_CMAKE_BUILD_FILE = \"\"\"\\
load("@rules_foreign_cc//tools/build_defs/native_tools:native_tools_toolchain.bzl", "native_tool_toolchain")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "cmake_data",
    srcs = glob(
        [
            "**",
        ],
        exclude = [
            "WORKSPACE",
            "WORKSPACE.bazel",
            "BUILD",
            "BUILD.bazel",
        ],
    ),
)

filegroup(
    name = "cmake_bin",
    srcs = ["bin/{{bin}}"],
    data = [":cmake_data"],
)

native_tool_toolchain(
    name = "cmake_tool",
    path = "$(execpath :cmake_bin)",
    target = ":cmake_bin",
)
\"\"\"

_NINJA_BUILD_FILE = \"\"\"\\
load("@rules_foreign_cc//tools/build_defs/native_tools:native_tools_toolchain.bzl", "native_tool_toolchain")

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "ninja_bin",
    srcs = ["{{bin}}"],
)

native_tool_toolchain(
    name = "ninja_tool",
    path = "$(execpath :ninja_bin)",
    target = ":ninja_bin",
)
\"\"\"

# buildifier: disable=unnamed-macro
def prebuilt_toolchains(cmake_version, ninja_version):
    \"\"\"Register toolchains for pre-built cmake and ninja binaries

    Args:
        cmake_version (string): The target cmake version
        ninja_version (string): The target ninja-build version
    \"\"\"
    _cmake_toolchains(cmake_version)
    _ninja_toolchains(ninja_version)
    _make_toolchains()

def _cmake_toolchains(version):
{cmake_definitions}

def _ninja_toolchains(version):
{ninja_definitions}

def _make_toolchains():
{make_definitions}
"""


def get_cmake_definitions() -> str:
    """Define a set of repositories and calls for registering `cmake` toolchains

    Returns:
        str: The Implementation of `_cmake_toolchains`
    """

    archives = []

    for version in CMAKE_VERSIONS:
        major, minor, _patch = version.split(".")

        version_archives = []
        version_toolchains = {}

        minor_version = "{}.{}".format(major, minor)
        for line in urllib.request.urlopen(CMAKE_SHA256_URL_TEMPLATE.format(minor=minor_version, full=version)).readlines():
            line = line.decode("utf-8").strip("\n ")

            # Only take tar and zip files. The rest can't be easily decompressed.
            if not line.endswith(".tar.gz") and not line.endswith(".zip"):
                continue

            # Only include the targets we care about.
            plat_target = None
            for target in CMAKE_TARGETS.keys():
                if target in line:
                    plat_target = target
                    break

            if not plat_target:
                continue

            sha256, file = line.split()
            name = file.replace(".tar.gz", "").replace(".zip", "")
            bin = "cmake.exe" if "win" in file.lower() else "cmake"

            if "Darwin" in file or "macos" in file:
                prefix = name + "/CMake.app/Contents"
            else:
                prefix = name

            version_archives.append(
                REPO_DEFINITION.format(
                    name=name,
                    sha256=sha256,
                    prefix=prefix,
                    url=CMAKE_URL_TEMPLATE.format(
                        full=version,
                        file=file
                    ),
                    build="cmake",
                    template="_CMAKE_BUILD_FILE",
                    bin=bin,
                )
            )
            version_toolchains.update({plat_target: name})

        archives.append("\n".join(
            [
                "    if \"{}\" == version:".format(version),
            ] + [indent(archive, " " * 8) for archive in version_archives])
        )

        toolchains_repos = {}
        for target, name in version_toolchains.items():
            toolchains_repos.update({name: CMAKE_TARGETS[target]})

        archives.append(indent(TOOLCHAIN_REPO_DEFINITION.format(
            name="cmake_{}_toolchains".format(version),
            repos=indent(json.dumps(toolchains_repos, indent=4), " " * 4).lstrip(),
            tool="cmake",
        ), " " * 8))

        archives.append(indent(REGISTER_TOOLCHAINS.format(
            toolchains="\n".join(
                [indent("\"@cmake_{}_toolchains//:{}_toolchain\",".format(
                    version,
                    repo
                ), " " * 4) for repo in toolchains_repos])
        ), " " * 8))

        archives.extend([
            indent("return", " " * 8),
            "",
        ])

    archives.append(
        indent("fail(\"Unsupported version: \" + str(version))", " " * 4))

    return "\n".join([archive.rstrip(" ") for archive in archives])


def get_ninja_definitions() -> str:
    """Define a set of repositories and calls for registering `ninja` toolchains

    Returns:
        str: The Implementation of `_ninja_toolchains`
    """

    archives = []

    for version in NINJA_VERSIONS:

        version_archives = []
        version_toolchains = {}

        for target in NINJA_TARGETS.keys():
            url = NINJA_URL_TEMPLATE.format(
                full=version,
                target=target,
            )

            # Get sha256 (can be slow)
            remote = urllib.request.urlopen(url)
            total_read = 0
            max_file_size = 100*1024*1024
            hash = hashlib.sha256()
            while True:
                data = remote.read(4096)
                total_read += 4096

                if not data or total_read > max_file_size:
                    break

                hash.update(data)
            sha256 = hash.hexdigest()

            name = "ninja_{}_{}".format(version, target)

            version_archives.append(
                REPO_DEFINITION.format(
                    name=name,
                    url=url,
                    sha256=sha256,
                    prefix="",
                    build="ninja",
                    template="_NINJA_BUILD_FILE",
                    bin="ninja.exe" if "win" in target else "ninja",
                )
            )
            version_toolchains.update({target: name})

        archives.append("\n".join(
            [
                "    if \"{}\" == version:".format(version),
            ] + [indent(archive, " " * 8) for archive in version_archives])
        )

        toolchains_repos = {}
        for target, name in version_toolchains.items():
            toolchains_repos.update({name: NINJA_TARGETS[target]})

        archives.append(indent(TOOLCHAIN_REPO_DEFINITION.format(
            name="ninja_{}_toolchains".format(version),
            repos=indent(json.dumps(toolchains_repos, indent=4), " " * 4).lstrip(),
            tool="ninja",
        ), " " * 8))

        archives.append(indent(REGISTER_TOOLCHAINS.format(
            toolchains="\n".join(
                [indent("\"@ninja_{}_toolchains//:{}_toolchain\",".format(
                    version,
                    repo
                ), " " * 4) for repo in toolchains_repos])
        ), " " * 8))

        archives.extend([
            indent("return", " " * 8),
            "",
        ])

    archives.append(
        indent("fail(\"Unsupported version: \" + str(version))", " " * 4))

    return "\n".join(archives)


def get_make_definitions() -> str:
    """Define a set of repositories and calls for registering `make` toolchains

    Returns:
        str: The Implementation of `_make_toolchains`
    """

    return indent(
        "native.register_toolchains(\"@rules_foreign_cc//tools/build_defs:preinstalled_make_toolchain\")",
        " " * 4)


def main():
    """The main entrypoint of the toolchains generator"""
    repos_bzl_file = Path(__file__).parent.absolute() / \
        "prebuilt_toolchains.bzl"

    repos_bzl_file.write_text(BZL_FILE_TEMPLATE.format(
        cmake_definitions=get_cmake_definitions(),
        ninja_definitions=get_ninja_definitions(),
        make_definitions=get_make_definitions(),
    ))


if __name__ == "__main__":
    main()
