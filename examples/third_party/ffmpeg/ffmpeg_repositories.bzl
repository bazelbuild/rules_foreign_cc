"""A module defining the third party dependency ffmpeg"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# buildifier: disable=function-docstring
def ffmpeg_repositories():
    maybe(
        http_archive,
        name = "ffmpeg",
        build_file = Label("//ffmpeg:BUILD.ffmpeg.bazel"),
        strip_prefix = "FFmpeg-n7.0.2",
        urls = ["https://github.com/FFmpeg/FFmpeg/archive/refs/tags/n7.0.2.tar.gz"],
        integrity = "sha256-XrRtGNZkoMyt97Ct7gO9O3+nKJPWZ/NsaeICqAfm1TM=",
    )

    YASM_COMMMIT = "121ab150b3577b666c79a79f4a511798d7ad2432"
    maybe(
        http_archive,
        name = "yasm",
        build_file = Label("//ffmpeg:BUILD.yasm.bazel"),
        strip_prefix = "yasm-%s" % YASM_COMMMIT,
        urls = ["https://github.com/yasm/yasm/archive/%s.tar.gz" % YASM_COMMMIT],
        integrity = "sha256-PfFT8fuUUTq5LLHaf7g3ejFW93TWi8z070IJRzqqG7Y=",
    )

    maybe(
        http_archive,
        name = "libyuv",
        build_file = Label("//ffmpeg:BUILD.libyuv.bazel"),
        urls = ["https://chromium.googlesource.com/libyuv/libyuv/+archive/eb6e7bb63738e29efd82ea3cf2a115238a89fa51.tar.gz"],
    )

    maybe(
        http_archive,
        name = "libvpx",
        build_file = Label("//ffmpeg:BUILD.libvpx.bazel"),
        urls = ["https://chromium.googlesource.com/webm/libvpx/+archive/12f3a2ac603e8f10742105519e0cd03c3b8f71dd.tar.gz"],
    )

    maybe(
        http_archive,
        name = "libaom",
        build_file = Label("//ffmpeg:BUILD.libaom.bazel"),
        urls = ["https://aomedia.googlesource.com/aom/+archive/c2fe6bf370f7c14fbaf12884b76244a3cfd7c5fc.tar.gz"],
    )

    maybe(
        http_archive,
        name = "libsvtav1",
        build_file = Label("//ffmpeg:BUILD.libsvtav1.bazel"),
        strip_prefix = "SVT-AV1-v2.2.1",
        urls = ["https://gitlab.com/AOMediaCodec/SVT-AV1/-/archive/v2.2.1/SVT-AV1-v2.2.1.tar.gz"],
        integrity = "sha256-0CtUaFVC3gI2vOS+G1CRKrpor/mXxDs1DYSlGN8M9OU=",
    )

    maybe(
        http_archive,
        name = "libdav1d",
        build_file = Label("//ffmpeg:BUILD.libdav1d.bazel"),
        strip_prefix = "dav1d-1.4.3",
        urls = ["https://code.videolan.org/videolan/dav1d/-/archive/1.4.3/dav1d-1.4.3.tar.gz"],
        integrity = "sha256-iKAj5Y2VXgiG+vSccpQODpCRSpSKjmDBMmzj4J56YJk=",
    )
