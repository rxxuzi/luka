# Luka

**Luka**: **L**inux **U**tility **K**it **A**ssistant

## Introduction

Luka is a lightweight Linux assistant that helps you manage applications, system configurations, and development environments—all without requiring root access.

### Quick Start

Install Luka with a single command:

```sh
curl -fsSL https://raw.githubusercontent.com/rxxuzi/luka/main/init.sh | sh
```

Or manually:

```sh
git clone https://github.com/rxxuzi/luka.git
cd luka
bash init.sh
luka version
```

### Prerequisites

Before installing Luka, ensure the following dependencies are installed:

- **Git** – Required to clone the repository.
- **Bash** – A shell environment for running scripts.
- **Python 3** – Required for Luka’s Python-based tools.
- **pip3** – The Python package installer.

### Reinitializing Luka

If you need to reset Luka, remove the flag file and re-run the initialization script:

```sh
rm ~/.luka_initialized
bash ~/luka/init.sh
```

## Usage

Luka provides a set of user-friendly commands for managing various aspects of your Linux environment. Each command supports the `--help` flag for detailed usage instructions.

### Basic Commands

```sh
luka <command> [<args>]
```

Example:

```sh
luka version
```

## Documentation

For detailed information on each command and its options, refer to the [Documentation](doc/) directory.

## License

**Luka** is licensed under the **GNU General Public License v3.0**. See the [LICENSE](LICENSE) file for more details.

---

**Thank you for using Luka! We hope it enhances your Linux experience. 🚀**  
