# Luka size - Disk Usage Analysis Tool

## Overview

`luka size` is a command-line tool for analyzing disk usage, identifying large files and directories within a specified path. It provides options to filter by file types, sizes, depths, and more.

## Usage

```bash
luka size [options]
```

## Options

- `-t`, `--target <path>`  
  Target directory to analyze (default: current directory).

- `-s`, `--size <size>`  
  Size threshold (e.g., `1G`, `500M`) (default: `1K`).

- `-d`, `--depth <depth>`  
  Directory traversal depth (default: `1`).

- `-i`, `--item-type <type>`  
  Item type to include:
  - `f`: files
  - `d`: directories
  - `all`: both (default)

- `-a`, `--all`  
  Include hidden files and directories.

- `-v`, `--verbose`  
  Display detailed output (permissions and last modified time).

- `-f`, `--filter <patterns>`  
  Filter patterns (e.g., `.md`, `.txt`). Supports multiple patterns.

- `-I`, `--ignore <patterns>`  
  Ignore patterns or directories. Supports multiple patterns.

- `-h`, `--help`  
  Show the help message and exit.

## Examples

### 1. Analyze the `src/` Directory Up to Depth 2

```bash
luka size -t ./src/ -d 2
```

- **Explanation**: Analyzes the `src/` directory and its subdirectories up to a depth of 2.

### 2. Include Hidden Files and Directories, Analyze Up to Depth 2, and Display Detailed Output

```bash
luka size -a -d 2 -v
```

- **Explanation**: Includes hidden files and directories, analyzes up to depth 2, and displays detailed information such as permissions and last modified time.

### 3. Analyze Only Files with Extensions `.md`, `.txt`, or `.json`

```bash
luka size -i f -f .md .txt .json
```

- **Explanation**: Analyzes only files with the specified extensions.

### 4. Ignore `node_modules` and `.git` Directories During Analysis

```bash
luka size -I node_modules .git
```

- **Explanation**: Ignores directories named `node_modules` and `.git` during the analysis.

## Notes

- **Size Units**: The size thresholds can be specified using units like `K` (Kilobytes), `M` (Megabytes), `G` (Gigabytes), `T` (Terabytes), or in bytes if no unit is specified.

- **Pattern Matching**: The filter and ignore patterns support simple string matching and wildcard patterns (e.g., `*.md`).

- **Hidden Files**: By default, hidden files and directories (those starting with a dot `.`) are excluded. Use the `-a` option to include them.

- **Permissions Format**: The permissions are displayed in the format similar to `ls -l`, e.g., `drwxr-xr-x`.

## Contact

For issues or contributions, please contact the developer or submit a pull request to the repository.
