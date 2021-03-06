# News

**March 2021:**

These rules are now maintained by the community.

_Note_: After this release we will be bumping the minimum tested version to _4.0.0_.

- Added repository rules for downloading prebuilt versions of cmake and ninja
  rather than relying on system installed tools.

- Added native ninja build rule

- Now builds under the Bazel sandbox rather than in `/tmp`

- Tidied up the structure of the examples directory

- Deprecated the old rules `install_ws_dependency` and `cc_configure_make`

- Autogenerated documentation was added

**March 2019:**

- Support for versions earlier than 0.22 was removed.

- Tests on Bazel CI are running in the nested workspace

**January 2019:**

- Bazel 0.22.0 is released, no flags are needed for this version, but it does not work on Windows (Bazel C++ API is broken).

- Support for versions earlier than 0.20 was removed.

- [rules_foreign_cc take-aways](https://docs.google.com/document/d/1ZVvzvkUVTkPCzI-2z4S4VrSNu4kdaBknz7UnK8vaoZU/edit?usp=sharing) describing the recent work has been published.

- Examples package became the separate workspace.
  This also allows to illustrate how to initialize rules_foreign_cc.

- Native tools (cmake, ninja) toolchains were introduced.
  Though the user code does not have to be changed (default toolchains are registered, they call the preinstalled binaries by name.),
  you may simplify usage of ninja with the cmake_external rule and call it just by name.
  Please see examples/cmake_nghttp2 for ninja usage, and WORKSPACE and BUILD files in examples for the native tools toolchains usage
  (the locally preinstalled tools are registered by default, the build as part of the build tools are used in examples).
  Also, in examples/with_prebuilt_ninja_artefact you can see how to download and use prebuilt artifact.

- Shell script parts were extracted into a separate toolchain.
  Shell script inside framework.bzl is first created with special notations:
  - `export var_name=var_value` for defining the environment variable
  - `$$var_name$$` for referencing environment variable
  - `` `shell_command <space-separated-maybe-quoted-arguments>` `` for calling shell fragment

  The created script is further processed to get the real shell script with shell parts either
  replaced with actual fragments or with shell function calls (functions are added into the beginning of the script).
  Extracted shell fragments are described in commands.bzl.

  Further planned steps in this direction: testing with RBE, shell script fragments for running on Windows without msys/mingw,
  tests for shell fragments.
