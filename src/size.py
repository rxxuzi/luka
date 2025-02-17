#!/usr/bin/env python3
# -----------------------------------------------------------------------------
#  size.py
#   - DESCRIPTION: Disk Usage Analysis Tool
#   - AUTHOR      : github.com/rxxuzi
#   - LICENSE     : CC0
# -----------------------------------------------------------------------------

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
    """
    文字列表現のサイズをバイト単位に変換する。
    例: 1G -> 1073741824, 500M -> 524288000
    """
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
    """
    バイト数を適切な単位に変換して文字列化する。
    例: 1234567 -> '1.2M'
    """
    units = ['B', 'K', 'M', 'G', 'T', 'P']
    index = 0
    while bytes_size >= 1024 and index < len(units) - 1:
        bytes_size /= 1024
        index += 1
    return f"{bytes_size:.1f}{units[index]}"

def custom_help_message():
    """
    スクリプトの使い方を表示するカスタムメッセージ。
    usageやオプション説明をわかりやすくまとめる。
    """
    return f"""
Luka size - Disk Usage Analysis Tool

Usage:
  luka size <path> [options]

Positional Arguments:
  path                       Target directory to analyze (default: current directory)

Options:
  -r, --recursive           Recursively scan subdirectories (no depth limit)
  -i, --ignore <patterns>   Ignore paths or patterns
  -s, --size <size>         Size threshold (e.g., 1G, 500M) (default: 1K)
  -d, --depth <depth>       Directory traversal depth (default: 1, ignored if -r is given)
  -a, --all                 Include hidden files and directories
  -v, --verbose             Display detailed output
  -f, --filter <patterns>   Filter patterns (e.g., .md .txt)
  -h, --help                Show this help message and exit

Examples:
  luka size ./src/ -d 2
    - Analyze the 'src/' directory up to depth 2.

  luka size . -r
    - Recursively analyze the current directory (no depth limit).

  luka size /path/to/dir -a -d 2 -v
    - Include hidden files and directories, analyze up to depth 2, and display detailed output.

  luka size . -f .md .txt .json
    - Analyze only files/directories matching the patterns '.md', '.txt', or '.json'.

  luka size . -i node_modules .git
    - Ignore 'node_modules' and '.git' directories during analysis.
"""

def get_args():
    """
    コマンドライン引数を解析する。
    - 最初の位置引数: path (省略時は '.')
    - その他のオプション: -r, -i, -s, -d, -a, -v, -f, -h
    """
    parser = argparse.ArgumentParser(add_help=False)

    # 位置引数: path（省略時は . カレントディレクトリ）
    parser.add_argument("path", nargs="?", default=".",
                        help=argparse.SUPPRESS)  # カスタムヘルプで説明しているため SUPPRESS

    # オプション引数
    parser.add_argument("-r", "--recursive", action="store_true", help=argparse.SUPPRESS)
    parser.add_argument("-i", "--ignore", nargs='+', help=argparse.SUPPRESS)
    parser.add_argument("-s", "--size", default="1K", type=parse_size, help=argparse.SUPPRESS)
    parser.add_argument("-d", "--depth", type=int, default=1, help=argparse.SUPPRESS)
    parser.add_argument("-a", "--all", action='store_true', help=argparse.SUPPRESS)
    parser.add_argument("-v", "--verbose", action='store_true', help=argparse.SUPPRESS)
    parser.add_argument("-f", "--filter", nargs='+', help=argparse.SUPPRESS)
    parser.add_argument("-h", "--help", action='store_true', help=argparse.SUPPRESS)

    args, unknown = parser.parse_known_args()

    # -h/--help が指定された場合、または引数がまったくない場合はカスタムヘルプを表示
    if args.help and len(sys.argv) == 2:
        print(custom_help_message())
        sys.exit(0)
    if args.help:
        print(custom_help_message())
        sys.exit(0)

    return parser.parse_args()

def is_hidden(filepath):
    """ファイルまたはディレクトリが隠し項目かどうかを判定する。"""
    return any(part.startswith('.') for part in filepath.strip(os.sep).split(os.sep))

def matches_patterns(name, patterns):
    """ファイル/ディレクトリ名がパターンにマッチするかどうかを判定。"""
    return any(fnmatch.fnmatch(name, pattern) or name.endswith(pattern) for pattern in patterns or [])

def get_dir_size(path, include_hidden):
    """
    ディレクトリ以下のファイルサイズ合計を再帰的に取得。
    include_hidden=False の場合は隠しファイルやフォルダは集計しない。
    """
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
    """ファイル/ディレクトリのパーミッションを文字列化。"""
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
    """UNIXタイムを YYYY-MM-DD HH:MM 形式に変換する。"""
    return datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M')

def traverse(path, max_depth, current_depth=0,
             filters=None, ignores=None, include_hidden=False,
             verbose=False, executor=None):
    """
    ディレクトリを再帰的に走査し、ファイル/ディレクトリの情報を返す。
    max_depth: 再帰の最大深度。-r 指定時は非常に大きい値を想定。
    """
    items = []
    try:
        for entry in os.scandir(path):
            if entry.is_symlink():
                continue
            name = entry.name

            # 隠しファイル/ディレクトリの制御
            if not include_hidden and is_hidden(name):
                continue

            # 無視するパターンの制御
            if matches_patterns(name, ignores):
                continue

            # ファイル
            if entry.is_file(follow_symlinks=False):
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

            # ディレクトリ
            elif entry.is_dir(follow_symlinks=False):
                if current_depth < max_depth:
                    # 再帰的に検索
                    items.extend(traverse(entry.path, max_depth, current_depth + 1,
                                          filters, ignores, include_hidden, verbose, executor))

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

    path = args.path
    size_threshold = args.size
    depth = args.depth
    if args.recursive:
        # -r 指定があれば深度を実質無制限にする
        depth = 999999

    filters = args.filter
    ignores = args.ignore
    include_hidden = args.all
    verbose = args.verbose

    # スレッドプールを使ってサイズ計算を並列化
    max_workers = os.cpu_count() or 4
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        items = traverse(path, depth - 1, 0,  # depth-1 でちょうど希望の深さまで再帰
                         filters=filters, ignores=ignores,
                         include_hidden=include_hidden,
                         verbose=verbose, executor=executor)

        # size_future を解決
        for item in items:
            if 'size_future' in item:
                try:
                    item['size'] = item['size_future'].result()
                except Exception:
                    item['size'] = 0
                del item['size_future']

    # サイズしきい値でフィルタリング
    filtered_items = [item for item in items if item['size'] >= size_threshold]
    filtered_items.sort(key=lambda x: x['size'], reverse=True)

    if not filtered_items:
        print(f"{Fore.GREEN}No files or directories match the specified criteria.{Style.RESET_ALL}")
        return

    # 見やすいヘッダー行を出力
    if verbose:
        header = f"{Fore.CYAN}{'SIZE':>10}  {'TYPE':^6}  {'PERMISSIONS':^11}  {'LAST MODIFIED':^16}  PATH{Style.RESET_ALL}"
    else:
        header = f"{Fore.CYAN}{'SIZE':>10}  {'TYPE':^6}  PATH{Style.RESET_ALL}"
    print(header)
    print("-" * (len(header) + 40))

    # 各項目を出力
    for item in filtered_items:
        size_str = format_size(item['size'])
        type_str = item['type']
        path_str = item['path']

        if verbose:
            mode_str = format_mode(item['mode'])
            time_str = format_time(item['mtime'])
            print(f"{size_str:>10}  {type_str:^6}  {mode_str:^11}  {time_str:^16}  {path_str}")
        else:
            print(f"{size_str:>10}  {type_str:^6}  {path_str}")

if __name__ == "__main__":
    main()
