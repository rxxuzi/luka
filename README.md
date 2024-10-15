# Luka

**Luka**: **L**inux **U**tility **K**it **A**ssistant

## Introduction

Luka provides a suite of user-level commands that empower you to manage your Linux environment efficiently without requiring administrative privileges.

## Features

- **Application Management**: Install, remove, and manage applications without needing sudo privileges.
- **Python Virtual Environment Setup**: Easily set up and manage Python virtual environments.
- **Color Scheme Management**: Customize Vim and terminal color schemes with ease.
- **System Information**: Quickly display detailed system information.
- **Path Management**: Seamlessly manage your PATH entries using the `lpath` command.
- **Version Control**: Easily check the current version of Luka.
- **Help System**: Access detailed help for all commands.

## Quickstart

Get Luka up and running in just a few simple steps:

```sh
git clone https://github.com/rxxuzi/luka.git
cd luka
bash init.sh
luka version
```

**Note**: The `init.sh` script should be run only once to initialize Luka. Subsequent executions will be prevented to avoid overwriting configurations. If you need to reinitialize, remove the `.luka_initialized` flag file from your home directory and run `init.sh` again.

## Installation

### Prerequisites

- **Git**: To clone the repository.
- **Bash**: Shell environment for running scripts.
- **Python 3**: Required for executing Luka's Python-based tools.
- **pip3**: Python package installer.

Ensure these are installed on your system before proceeding.

### Steps

1. **Clone the Repository**

    ```sh
    git clone https://github.com/rxxuzi/luka.git
    ```

2. **Navigate to the Project Directory**

    ```sh
    cd luka
    ```

3. **Run the Initialization Script**

    ```sh
    bash init.sh
    ```

4. **Verify Installation**

    ```sh
    luka version
    ```

    This should display Luka's version information along with ASCII art.

## Usage

Luka provides a set of user-friendly commands to manage various aspects of your Linux environment. Each command supports the `--help` flag for detailed usage instructions.

### Command Overview

```sh
luka <command> [<args>]
```

Additionally, PATH management is handled via the `lpath` command:

```sh
lpath <command> [<args>]
```

For detailed documentation on each command, please refer to the [Documentation](doc/) directory.

**Note**: After modifying PATH entries, please restart your terminal or run `source ~/.bashrc` to apply changes.

## Documentation

For detailed information on each command and its subcommands, please refer to the [Documentation](doc/) directory.

## License

**Luka** is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for more details.

---

*Thank you for using Luka! We hope it enhances your Linux experience.*
