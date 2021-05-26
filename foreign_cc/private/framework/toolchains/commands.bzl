"""A module difining all commands for a foreign_cc framework toolchain"""

FunctionAndCallInfo = provider(
    doc = "Wrapper to pass function definition and (if custom) function call",
    fields = {
        "call": "How to call defined function, if different from <function-name> <arg1> ...<argn>",
        "text": "Function body, without wrapping function <name>() {} fragment.",
    },
)

def _command_info(arguments, doc):
    """To pass information about the Starlark function, defining the shell fragment.

    Args:
        arguments (list): Arguments of Starlark function (`_argument_info`)
        doc (str): What the shell script fragment, generated by this function, does.

    Returns:
        struct: A struct of command info
    """
    return struct(
        arguments = arguments,
        doc = doc,
    )

def _argument_info(name, data_type, doc):
    """Generates a struct of information about a command argument for `_command_info` commands

    Args:
        name (str): The name fo the argument
        data_type (str): The type of the data, typically the result of `type(...)`
        doc (str): Documentation for the argument

    Returns:
        struct: A struct of argument info
    """
    return struct(
        name = name,
        doc = doc,
        data_type = data_type,
    )

PLATFORM_COMMANDS = {
    "assert_script_errors": _command_info(
        arguments = [],
        doc = "Script fragment that stops the execution after any error",
    ),
    "cat": _command_info(
        arguments = [
            _argument_info(name = "filepath", data_type = type(""), doc = "Path to the file"),
        ],
        doc = "Output the file contents to stdout",
    ),
    "children_to_path": _command_info(
        arguments = [
            _argument_info(name = "dir_", data_type = type(""), doc = "Directory"),
        ],
        doc = "Put all immediate subdirectories (and symlinks) into PATH",
    ),
    "cleanup_function": _command_info(
        arguments = [
            _argument_info(name = "on_success", data_type = type(""), doc = "Command(s) to be executed on success"),
            _argument_info(name = "on_failure", data_type = type(""), doc = "Command(s) to be executed on failure"),
        ],
        doc = "Trap function called after the script is finished",
        #        doc = "Read the result of the execution of the previous command, execute success or failure callbacks",
    ),
    "copy_dir_contents_to_dir": _command_info(
        arguments = [
            _argument_info(
                name = "source",
                data_type = type(""),
                doc = "Source directory, immediate children of which are copied",
            ),
            _argument_info(name = "target", data_type = type(""), doc = "Target directory"),
        ],
        doc = "Copies contents of the directory to target directory",
    ),
    "define_absolute_paths": _command_info(
        arguments = [
            _argument_info(name = "dir_", data_type = type(""), doc = "Directory where to replace"),
            _argument_info(name = "abs_path", data_type = type(""), doc = "Absolute path value"),
        ],
        doc = "Replaces absolute path placeholder inside 'dir_' with a provided value 'abs_path'",
    ),
    "define_function": _command_info(
        arguments = [
            _argument_info(name = "name", data_type = type(""), doc = "Function name"),
            _argument_info(name = "text", data_type = type(""), doc = "Function body"),
        ],
        doc = "Defines a function with 'text' as the function body.",
    ),
    "disable_tracing": _command_info(
        arguments = [],
        doc = "Disable script tracing. eg: `set +x`",
    ),
    "echo": _command_info(
        arguments = [_argument_info(name = "text", data_type = type(""), doc = "Text to output")],
        doc = "Outputs 'text' to stdout",
    ),
    "enable_tracing": _command_info(
        arguments = [],
        doc = "Enable script tracing. eg: `set -x`",
    ),
    "env": _command_info(
        arguments = [],
        doc = "Print all environment variables",
    ),
    "export_var": _command_info(
        arguments = [
            _argument_info(name = "name", data_type = type(""), doc = "Variable name"),
            _argument_info(name = "value", data_type = type(""), doc = "Variable value"),
        ],
        doc = "Defines and exports environment variable.",
    ),
    "if_else": _command_info(
        doc = "Creates if-else construct",
        arguments = [
            _argument_info(name = "condition", data_type = type(""), doc = "Condition text"),
            _argument_info(name = "if_text", data_type = type(""), doc = "If block text"),
            _argument_info(name = "else_text", data_type = type(""), doc = "Else block text"),
        ],
    ),
    "increment_pkg_config_path": _command_info(
        arguments = [
            _argument_info(
                name = "source",
                data_type = type(""),
                doc = "Source directory",
            ),
        ],
        doc = (
            "Find subdirectory inside a passed directory with *.pc files and add it " +
            "to the PKG_CONFIG_PATH"
        ),
    ),
    "local_var": _command_info(
        arguments = [
            _argument_info(name = "name", data_type = type(""), doc = "Variable name"),
            _argument_info(name = "value", data_type = type(""), doc = "Variable value"),
        ],
        doc = "Defines local shell variable.",
    ),
    "mkdirs": _command_info(
        arguments = [_argument_info(name = "path", data_type = type(""), doc = "Path to directory")],
        doc = "Creates a directory and, if neccesary, it's parents",
    ),
    "path": _command_info(
        arguments = [
            _argument_info(name = "expression", data_type = type(""), doc = "Path"),
        ],
        doc = "Adds passed arguments in the beginning of the PATH.",
    ),
    "pwd": _command_info(
        arguments = [],
        doc = "Returns command for getting current directory.",
    ),
    "redirect_out_err": _command_info(
        arguments = [
            _argument_info(name = "from_process", data_type = type(""), doc = "Process to run"),
            _argument_info(name = "to_file", data_type = type(""), doc = "File to redirect output to"),
        ],
        doc = "Read the result of the execution of the previous command, execute success or failure callbacks",
    ),
    "replace_absolute_paths": _command_info(
        arguments = [
            _argument_info(name = "dir_", data_type = type(""), doc = "Directory where to replace"),
            _argument_info(name = "abs_path", data_type = type(""), doc = "Absolute path value"),
        ],
        doc = "Replaces absolute path 'abs_path' inside 'dir_' with a placeholder value",
    ),
    "replace_in_files": _command_info(
        arguments = [
            _argument_info(name = "dir_", data_type = type(""), doc = "Directory to search recursively"),
            _argument_info(name = "from_", data_type = type(""), doc = "String to be replaced"),
            _argument_info(name = "to_", data_type = type(""), doc = "Replace target"),
        ],
        doc = "Replaces all occurrences of 'from_' to 'to_' recursively in the directory 'dir'.",
    ),
    "replace_symlink": _command_info(
        arguments = [
            _argument_info(
                name = "file",
                data_type = type(""),
                doc = "Target file",
            ),
        ],
        doc = (
            "Replace the target symlink with resolved file it points to if `file` is a symlink"
        ),
    ),
    "script_extension": _command_info(
        arguments = [],
        doc = "Return the extension for the current set of commands (`.sh` for bash, `.ps1` for powershell)",
    ),
    "script_prelude": _command_info(
        arguments = [],
        doc = "Function for setting necessary environment variables for the platform",
    ),
    "shebang": _command_info(
        arguments = [],
        doc = "The shebang for the current shell executable",
    ),
    "symlink_contents_to_dir": _command_info(
        arguments = [
            _argument_info(
                name = "source",
                data_type = type(""),
                doc = "Source directory, immediate children of which are symlinked, or file to be symlinked.",
            ),
            _argument_info(name = "target", data_type = type(""), doc = "Target directory"),
        ],
        doc = (
            "Symlink contents of the directory to target directory (create the target directory if needed). " +
            "If file is passed, symlink it into the target directory."
        ),
    ),
    "symlink_to_dir": _command_info(
        arguments = [
            _argument_info(
                name = "source",
                data_type = type(""),
                doc = "Source directory",
            ),
            _argument_info(name = "target", data_type = type(""), doc = "Target directory"),
        ],
        doc = (
            "Symlink all files from source directory to target directory (create the target directory if needed). " +
            "NB symlinks from the source directory are copied."
        ),
    ),
    "touch": _command_info(
        arguments = [_argument_info(name = "path", data_type = type(""), doc = "Path to file")],
        doc = "Creates a file",
    ),
    "use_var": _command_info(
        arguments = [
            _argument_info(name = "name", data_type = type(""), doc = "Variable name"),
        ],
        doc = "Expression to address the variable.",
    ),
}
