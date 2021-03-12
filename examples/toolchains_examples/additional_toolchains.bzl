# buildifier: disable=module-docstring
# buildifier: disable=bzl-visibility
load("@rules_foreign_cc//foreign_cc/private/shell_toolchain/toolchains:toolchain_mappings.bzl", "ToolchainMapping")

ADD_TOOLCHAIN_MAPPINGS = [
    ToolchainMapping(
        exec_compatible_with = [
            "@rules_foreign_cc_toolchains_examples//:fancy_constraint_value",
        ],
        file = "@rules_foreign_cc_toolchains_examples//:fancy_platform_commands.bzl",
    ),
]
