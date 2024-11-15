#!/usr/bin/env python3
import os
import sys
import argparse
import fnmatch
import stat
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor
from colorama import Fore, Style, init

# Initialize colorama
init(autoreset=True)

def parse_size(size_str):
    size_str = size_str.strip().upper()
    units = {'T': 1024**4, 'G': 1024**3, 'M': 1024**2, 'K': 1024, 'B': 1}
    for unit in units:
        if size_str.endswith(unit):
            try:
                return float(size_str[:-1]) * units[unit]
            except ValueError:
                raise argparse.ArgumentTypeError(f"Invalid size format: {size_str}")
    try:
        return float(size_str)
    except ValueError:
        raise argparse.ArgumentTypeError(f"Invalid size format: {size_str}")

def format_size(bytes_size):
    units = ['B', 'K', 'M', 'G', 'T', 'P']
    index = 0
    while bytes_size >= 1024 and index < len(units) - 1:
        bytes_size /= 1024
        index += 1
    return f"{bytes_size:.1f}{units[index]}"

def get_args():
    # Custom help message
    custom_help = f"""
Luka size - Disk Usage Analysis Tool

Usage:
  luka size [options]

Options:
  -t, --target <path>          Target directory to analyze (default: current directory)
  -s, --size <size>            Size threshold (e.g., 1G, 500M) (default: 1K)
  -d, --depth <depth>          Directory traversal depth (default: 1)
  -i, --item-type <type>       Item type to include (f: files, d: directories, all: both) (default: all)
  -a, --all                    Include hidden files and directories
  -v, --verbose                Display detailed output
  -f, --filter <patterns>      Filter patterns (e.g., .md .txt)
  -I, --ignore <patterns>      Ignore patterns or directories
  -h, --help                   Show this help message and exit

Examples:
  luka size -t ./src/ -d 2
    - Analyze the 'src/' directory up to depth 2.

  luka size -a -d 2 -v
    - Include hidden files and directories, analyze up to depth 2, and display detailed output.

  luka size -i f -f .md .txt .json
    - Analyze only files with extensions '.md', '.txt', or '.json'.

  luka size -I node_modules .git
    - Ignore 'node_modules' and '.git' directories during analysis.
"""

    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument("-t", "--target", default='.', help=argparse.SUPPRESS)
    parser.add_argument("-s", "--size", default="1K", type=parse_size, help=argparse.SUPPRESS)
    parser.add_argument("-d", "--depth", type=int, default=1, help=argparse.SUPPRESS)
    parser.add_argument("-i", "--item-type", choices=['f', 'd', 'all'], default='all', help=argparse.SUPPRESS)
    parser.add_argument("-a", "--all", action='store_true', help=argparse.SUPPRESS)
    parser.add_argument("-v", "--verbose", action='store_true', help=argparse.SUPPRESS)
    parser.add_argument("-f", "--filter", nargs='+', help=argparse.SUPPRESS)
    parser.add_argument("-I", "--ignore", nargs='+', help=argparse.SUPPRESS)
    parser.add_argument("-h", "--help", action='store_true', help=argparse.SUPPRESS)

    args, unknown = parser.parse_known_args()

    if args.help or len(sys.argv) == 1:
        print(custom_help)
        sys.exit(0)

    return parser.parse_args()

def is_hidden(filepath):
    return any(part.startswith('.') for part in filepath.strip(os.sep).split(os.sep))

def matches_patterns(name, patterns):
    return any(fnmatch.fnmatch(name, pattern) or name.endswith(pattern) for pattern in patterns or [])

def get_dir_size(path, include_hidden):
    total = 0
    try:
        for entry in os.scandir(path):
            if entry.is_symlink():
                continue
            if not include_hidden and is_hidden(entry.name):
                continue
            if entry.is_file(follow_symlinks=False):
                total += entry.stat(follow_symlinks=False).st_size
            elif entry.is_dir(follow_symlinks=False):
                total += get_dir_size(entry.path, include_hidden)
    except Exception:
        pass
    return total

def format_mode(mode):
    is_dir = 'd' if stat.S_ISDIR(mode) else '-'
    perms = [
        ('r' if mode & stat.S_IRUSR else '-'),
        ('w' if mode & stat.S_IWUSR else '-'),
        ('x' if mode & stat.S_IXUSR else '-'),
        ('r' if mode & stat.S_IRGRP else '-'),
        ('w' if mode & stat.S_IWGRP else '-'),
        ('x' if mode & stat.S_IXGRP else '-'),
        ('r' if mode & stat.S_IROTH else '-'),
        ('w' if mode & stat.S_IWOTH else '-'),
        ('x' if mode & stat.S_IXOTH else '-')
    ]
    return is_dir + ''.join(perms)

def format_time(mtime):
    return datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M')

def traverse(path, max_depth, current_depth=0, types=['f', 'd'],
             filters=None, ignores=None, include_hidden=False, verbose=False, executor=None):
    items = []
    try:
        for entry in os.scandir(path):
            if entry.is_symlink():
                continue
            name = entry.name

            # Handle hidden files/directories
            if not include_hidden and is_hidden(name):
                continue

            # Handle ignore patterns
            if matches_patterns(name, ignores):
                continue

            # Handle filter patterns
            if filters:
                if not matches_patterns(name, filters):
                    continue

            if entry.is_file(follow_symlinks=False) and 'f' in types:
                try:
                    stat_info = entry.stat(follow_symlinks=False)
                    items.append({
                        'path': entry.path,
                        'size': stat_info.st_size,
                        'type': 'File',
                        'mode': stat_info.st_mode,
                        'mtime': stat_info.st_mtime
                    })
                except Exception:
                    pass
            elif entry.is_dir(follow_symlinks=False) and 'd' in types:
                if current_depth < max_depth - 1:
                    items.extend(traverse(entry.path, max_depth, current_depth + 1,
                                          types, filters, ignores, include_hidden, verbose, executor))
                if executor:
                    future = executor.submit(get_dir_size, entry.path, include_hidden)
                    items.append({
                        'path': entry.path,
                        'size_future': future,
                        'type': 'Dir',
                        'mode': entry.stat(follow_symlinks=False).st_mode,
                        'mtime': entry.stat(follow_symlinks=False).st_mtime
                    })
                else:
                    size = get_dir_size(entry.path, include_hidden)
                    items.append({
                        'path': entry.path,
                        'size': size,
                        'type': 'Dir',
                        'mode': entry.stat(follow_symlinks=False).st_mode,
                        'mtime': entry.stat(follow_symlinks=False).st_mtime
                    })
    except Exception as e:
        if verbose:
            print(f"{Fore.RED}Error accessing {path}: {e}{Style.RESET_ALL}")
    return items

def main():
    args = get_args()
    size_threshold = args.size
    types = ['f', 'd'] if args.item_type == 'all' else [args.item_type]
    filters = args.filter
    ignores = args.ignore
    include_hidden = args.all

    max_workers = os.cpu_count() or 4
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        items = traverse(args.target, args.depth, types=types, filters=filters,
                         ignores=ignores, include_hidden=include_hidden, verbose=args.verbose, executor=executor)

        # Resolve futures
        for item in items:
            if 'size_future' in item:
                try:
                    item['size'] = item['size_future'].result()
                except Exception:
                    item['size'] = 0
                del item['size_future']

    # Filter and sort items
    filtered_items = [item for item in items if item['size'] >= size_threshold]
    filtered_items.sort(key=lambda x: x['size'], reverse=True)

    if not filtered_items:
        print(f"{Fore.GREEN}No files or directories match the specified criteria.{Style.RESET_ALL}")
        return

    # Print header
    if args.verbose:
        header = f"{Fore.CYAN}{'SIZE':>10}  {'TYPE':^6}  {'PERMISSIONS':^11}  {'LAST MODIFIED':^16}  PATH{Style.RESET_ALL}"
    else:
        header = f"{Fore.CYAN}{'SIZE':>10}  {'TYPE':^6}  PATH{Style.RESET_ALL}"
    print(header)
    print("-" * (len(header) + 40))

    # Print each item
    for item in filtered_items:
        size_str = format_size(item['size'])
        type_str = item['type']
        path = item['path']
        if args.verbose:
            mode_str = format_mode(item['mode'])
            time_str = format_time(item['mtime'])
            print(f"{size_str:>10}  {type_str:^6}  {mode_str:^11}  {time_str:^16}  {path}")
        else:
            print(f"{size_str:>10}  {type_str:^6}  {path}")

if __name__ == "__main__":
    main()
