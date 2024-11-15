#!/usr/bin/env python3
# color.py

import os
import sys
import json
import shutil

# 定数
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
COLOR_RES_DIR = os.path.join(BASE_DIR, '../res/color')
SCRIPTS_DIR = os.path.join(BASE_DIR, '../res/scripts')
VIM_COLORS_DIR = os.path.expanduser('~/.vim/colors')
VIMRC_PATH = os.path.expanduser('~/.vimrc')
BASHRC_PATH = os.path.expanduser('~/luka/src/bashrc/luka.bashrc')
C256_JSON_PATH = os.path.join(BASE_DIR, '../res/c_256.json')

def load_color_schemes():
    """
    res/colorディレクトリ内のすべてのカラースキームを読み込む。
    """
    schemes = {}
    if not os.path.exists(COLOR_RES_DIR):
        print(f"Error: color scheme directory '{COLOR_RES_DIR}' not found.")
        sys.exit(1)

    for file in os.listdir(COLOR_RES_DIR):
        if file.endswith('.json'):
            path = os.path.join(COLOR_RES_DIR, file)
            with open(path, 'r') as f:
                try:
                    data = json.load(f)
                    schemes[data['name']] = data
                except json.JSONDecodeError as e:
                    print(f"Error: an error occurred while parsing {file}: {e}")
    return schemes

def load_xterm_colors():
    """
    res/c_256.jsonを読み込んでxtermカラーのリストを返す。
    """
    if not os.path.exists(C256_JSON_PATH):
        print(f"Error: xterm color file '{C256_JSON_PATH}' not found.")
        sys.exit(1)
    with open(C256_JSON_PATH, 'r') as f:
        try:
            xterm_colors = json.load(f)
        except json.JSONDecodeError as e:
            print(f"Error: an error occurred while parsing c_256.json: {e}")
            sys.exit(1)
    return xterm_colors

def list_schemes(schemes):
    """
    利用可能なカラースキームを一覧表示する。
    """
    if not schemes:
        print("No color scheme available.")
        return
    print("Available color schemes:")
    for idx, name in enumerate(sorted(schemes.keys()), 0):
        print(f"  {idx}. {name}")

def select_scheme(schemes, identifier):
    """
    名前またはインデックスでカラースキームを選択する。
    """
    sorted_names = sorted(schemes.keys())
    if identifier.isdigit():
        idx = int(identifier)
        if 0 <= idx < len(sorted_names):
            scheme_name = sorted_names[idx]
            return schemes[scheme_name]
        else:
            print(f"Error: Index {idx} is not valid.")
            sys.exit(1)
    else:
        scheme = schemes.get(identifier)
        if scheme:
            return scheme
        else:
            print(f"Error: No corresponding color scheme found for name '{identifier}'.")
            sys.exit(1)

def apply_vim_colorscheme(scheme, verbose=False):
    """
    Vimのカラースキームを適用する。
    """
    if not os.path.exists(SCRIPTS_DIR):
        print(f"Error: Vim script directory '{SCRIPTS_DIR}' not found.")
        sys.exit(1)

    scheme_vim_file = os.path.join(SCRIPTS_DIR, f"{scheme['name']}.vim")

    if not os.path.exists(scheme_vim_file):
        print(f"Error: '{scheme['name']}.vim' file does not exist in '{SCRIPTS_DIR}'.")
        sys.exit(1)

    # Vimのカラースキームディレクトリにコピー
    os.makedirs(VIM_COLORS_DIR, exist_ok=True)
    shutil.copy(scheme_vim_file, VIM_COLORS_DIR)
    if verbose:
        print(f"'{scheme['name']}.vim' copied to '{VIM_COLORS_DIR}'.")

    # .vimrcを更新してカラースキームを設定
    update_vimrc(scheme['name'], verbose)
    print(f"Vim color scheme set to '{scheme['name']}'.")

def apply_terminal_colorscheme(scheme, xterm_colors, use_xterm256=False, verbose=False):
    """
    ターミナルのカラースキームを適用するためにluka.bashrcを変更する。
    """
    ansi_colors = generate_prompt_color_sequences(scheme, xterm_colors, use_xterm256)
    if not ansi_colors:
        print("Error: ANSI color sequence generation failed.")
        sys.exit(1)

    # ANSIカラーをPS1にマッピング
    c1, c2, c3, c4 = ansi_colors

    # luka.bashrcのバックアップ
    backup_file(BASHRC_PATH)

    # Luka Prompt Color Sectionを更新
    with open(BASHRC_PATH, 'r') as f:
        lines = f.readlines()

    new_lines = []
    in_prompt_color_section = False
    for line in lines:
        if line.strip() == "# Luka Prompt Color Start":
            in_prompt_color_section = True
            new_lines.append(line)  # コメント行を保持
            # 新しいカラー設定を挿入
            if use_xterm256:
                new_lines.append(f"c1='\\e[38;5;{c1}m'\n")
                new_lines.append(f"c2='\\e[38;5;{c2}m'\n")
                new_lines.append(f"c3='\\e[38;5;{c3}m'\n")
                new_lines.append(f"c4='\\e[38;5;{c4}m'\n")
            else:
                new_lines.append(f"c1=$(fg {c1['r']} {c1['g']} {c1['b']})\n")
                new_lines.append(f"c2=$(fg {c2['r']} {c2['g']} {c2['b']})\n")
                new_lines.append(f"c3=$(fg {c3['r']} {c3['g']} {c3['b']})\n")
                new_lines.append(f"c4=$(fg {c4['r']} {c4['g']} {c4['b']})\n")
            continue
        if line.strip() == "# Luka Prompt Color End":
            in_prompt_color_section = False
            new_lines.append(line)  # コメント行を保持
            continue
        if not in_prompt_color_section:
            new_lines.append(line)

    # Luka Prompt Color Sectionが存在しない場合は追加
    if not any("# Luka Prompt Color Start" in line for line in lines):
        new_lines.append("\n# Luka Prompt Color Start\n")
        if use_xterm256:
            new_lines.append(f"c1='\\e[38;5;{c1}m'\n")
            new_lines.append(f"c2='\\e[38;5;{c2}m'\n")
            new_lines.append(f"c3='\\e[38;5;{c3}m'\n")
            new_lines.append(f"c4='\\e[38;5;{c4}m'\n")
        else:
            new_lines.append(f"c1=$(fg {c1['r']} {c1['g']} {c1['b']})\n")
            new_lines.append(f"c2=$(fg {c2['r']} {c2['g']} {c2['b']})\n")
            new_lines.append(f"c3=$(fg {c3['r']} {c3['g']} {c3['b']})\n")
            new_lines.append(f"c4=$(fg {c4['r']} {c4['g']} {c4['b']})\n")
        new_lines.append("# Luka Prompt Color End\n")

    with open(BASHRC_PATH, 'w') as f:
        f.writelines(new_lines)

    print(f"Terminal color scheme set to '{scheme['name']}'. Restart the terminal to apply the change or run the following command:")
    print(f"reload")

    if verbose:
        # Show the new colors in the terminal
        print("New terminal colors:")
        for idx, c in enumerate([c1, c2, c3, c4], 1):
            if use_xterm256:
                print(f"c{idx}: \033[38;5;{c}m█\033[0m")
            else:
                print(f"c{idx}: \033[38;2;{c['r']};{c['g']};{c['b']}m█\033[0m")

def update_vimrc(scheme_name, verbose=False):
    """
    .vimrcを更新して指定されたカラースキームを設定する。
    """
    if not os.path.exists(VIMRC_PATH):
        print(f"Error: Vim configuration file '{VIMRC_PATH}' not found.")
        sys.exit(1)

    with open(VIMRC_PATH, 'r') as f:
        lines = f.readlines()

    with open(VIMRC_PATH, 'w') as f:
        found = False
        for line in lines:
            if line.strip().startswith('colorscheme'):
                f.write(f"colorscheme {scheme_name}\n")
                found = True
            else:
                f.write(line)
        if not found:
            f.write(f"\ncolorscheme {scheme_name}\n")

    if verbose:
        print(f".vimrc updated with colorscheme {scheme_name}.")

def generate_prompt_color_sequences(scheme, xterm_colors, use_xterm256):
    """
    カラースキームに基づいてターミナルプロンプト用のカラー情報を生成する。
    """
    # JSON内の"@"キーに定義された4色を使用
    at_colors = scheme.get('@', [])
    if not at_colors:
        print("Error: The '@' key is not defined in the color scheme.")
        sys.exit(1)
    if len(at_colors) < 4:
        print("Error: '@' key requires at least 4 colors.")
        sys.exit(1)

    # 最初の4色を選択
    selected_colors = at_colors[:4]
    color_values = []
    for color in selected_colors:
        if color.upper() == "NONE":
            color_values.append(None)  # デフォルト色または適切なデフォルト値
        else:
            if use_xterm256:
                xterm_code = hex_to_xterm256(color, xterm_colors)
                if xterm_code is not None:
                    color_values.append(xterm_code)
                else:
                    print(f"Error: Invalid color code '{color}'.")
                    sys.exit(1)
            else:
                rgb = hex_to_rgb(color)
                if rgb:
                    color_values.append({"r": rgb[0], "g": rgb[1], "b": rgb[2]})
                else:
                    print(f"Error: Invalid color code '{color}'.")
                    sys.exit(1)
    return color_values

def hex_to_xterm256(hex_color, xterm_colors):
    """
    HEXカラーコードから最も近いxterm 256色のカラーコードを取得する。
    """
    rgb = hex_to_rgb(hex_color)
    if rgb is None:
        return None
    min_distance = float('inf')
    closest_xterm = None
    for color in xterm_colors:
        xterm_rgb = color['rgb']
        dist = color_distance(rgb, xterm_rgb)
        if dist < min_distance:
            min_distance = dist
            closest_xterm = color['xterm']
    return closest_xterm

def color_distance(rgb1, rgb2):
    """
    2つのRGBカラー間の距離を計算する。
    """
    return sum((c1 - c2) ** 2 for c1, c2 in zip(rgb1, rgb2))

def hex_to_rgb(hex_color):
    """
    HEXカラーコードをRGBタプルに変換する。
    """
    hex_color = hex_color.lstrip('#')
    if len(hex_color) != 6:
        return None
    try:
        r, g, b = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
        return [r, g, b]
    except ValueError:
        return None

def backup_file(file_path):
    """
    指定されたファイルのバックアップを作成する。
    """
    backup_path = f"{file_path}.backup"
    if not os.path.exists(backup_path):
        shutil.copy(file_path, backup_path)
        print(f"Backup created to '{backup_path}'.")
    else:
        print(f"The backup already exists at '{backup_path}'.")

def reset_colorscheme(xterm_colors, use_xterm256=False, verbose=False):
    """
    Vimとターミナルのカラースキームをデフォルトにリセットする。
    """
    # Vimのカラースキームをリセット
    reset_vim_colorscheme(verbose)

    # ターミナルのカラースキームをリセット
    reset_terminal_colorscheme(xterm_colors, use_xterm256, verbose)

    print("Vim and terminal color schemes reset to default.") 
    print("Restart terminal to apply changes or run the following command:") 
    print("`reload`")

def reset_vim_colorscheme(verbose=False):
    """
    Vimのカラースキームをデフォルトにリセットする。
    """
    if not os.path.exists(VIMRC_PATH):
        print(f"Error: Vim configuration file '{VIMRC_PATH}' not found.")
        return

    with open(VIMRC_PATH, 'r') as f:
        lines = f.readlines()

    with open(VIMRC_PATH, 'w') as f:
        found = False
        for line in lines:
            if line.strip().startswith('colorscheme'):
                f.write("colorscheme default\n")
                found = True
            else:
                f.write(line)
        if not found:
            f.write("\ncolorscheme default\n")

    if verbose:
        print("Vim color scheme reset to default.")

def reset_terminal_colorscheme(xterm_colors, use_xterm256=False, verbose=False):
    """
    ターミナルのカラースキームをデフォルトにリセットするためにluka.bashrcを変更する。
    """
    # luka.bashrcのバックアップ
    backup_file(BASHRC_PATH)

    prompt_start = "# Luka Prompt Color Start"
    prompt_end = "# Luka Prompt Color End"

    # デフォルトのカラーコードを設定
    default_colors = ["#87ffff","#87ff00","#ff7fff","#feec90"]

    if use_xterm256:
        color_values = [hex_to_xterm256(color, xterm_colors) for color in default_colors]
    else:
        color_values = [hex_to_rgb(color) for color in default_colors]
        color_values = [{"r": rgb[0], "g": rgb[1], "b": rgb[2]} if rgb else None for rgb in color_values]

    with open(BASHRC_PATH, 'r') as f:
        lines = f.readlines()

    new_lines = []
    in_prompt_color_section = False
    for line in lines:
        if line.strip() == prompt_start:
            in_prompt_color_section = True
            new_lines.append(line)  # コメント行を保持
            # デフォルトのカラー設定を挿入
            if use_xterm256:
                new_lines.append(f"c1='\\e[38;5;{color_values[0]}m'\n")
                new_lines.append(f"c2='\\e[38;5;{color_values[1]}m'\n")
                new_lines.append(f"c3='\\e[38;5;{color_values[2]}m'\n")
                new_lines.append(f"c4='\\e[38;5;{color_values[3]}m'\n")
            else:
                new_lines.append(f"c1=$(fg {color_values[0]['r']} {color_values[0]['g']} {color_values[0]['b']})\n")
                new_lines.append(f"c2=$(fg {color_values[1]['r']} {color_values[1]['g']} {color_values[1]['b']})\n")
                new_lines.append(f"c3=$(fg {color_values[2]['r']} {color_values[2]['g']} {color_values[2]['b']})\n")
                new_lines.append(f"c4=$(fg {color_values[3]['r']} {color_values[3]['g']} {color_values[3]['b']})\n")
            continue
        if line.strip() == prompt_end:
            in_prompt_color_section = False
            new_lines.append(line)  # コメント行を保持
            continue
        if not in_prompt_color_section:
            new_lines.append(line)

    # Luka Prompt Color Sectionが存在しない場合は追加
    if not any(prompt_start in line for line in lines):
        new_lines.append("\n# Luka Prompt Color Start\n")
        if use_xterm256:
            new_lines.append(f"c1='\\e[38;5;{color_values[0]}m'\n")
            new_lines.append(f"c2='\\e[38;5;{color_values[1]}m'\n")
            new_lines.append(f"c3='\\e[38;5;{color_values[2]}m'\n")
            new_lines.append(f"c4='\\e[38;5;{color_values[3]}m'\n")
        else:
            new_lines.append(f"c1=$(fg {color_values[0]['r']} {color_values[0]['g']} {color_values[0]['b']})\n")
            new_lines.append(f"c2=$(fg {color_values[1]['r']} {color_values[1]['g']} {color_values[1]['b']})\n")
            new_lines.append(f"c3=$(fg {color_values[2]['r']} {color_values[2]['g']} {color_values[2]['b']})\n")
            new_lines.append(f"c4=$(fg {color_values[3]['r']} {color_values[3]['g']} {color_values[3]['b']})\n")
        new_lines.append("# Luka Prompt Color End\n")

    with open(BASHRC_PATH, 'w') as f:
        f.writelines(new_lines)

    if verbose:
        print("Terminal color scheme reset to default.")

def show_help():
    """
    Display the help message.
    """
    help_text = """
Luka Color - Vim and Terminal Color Scheme Management Tool

Usage:
  luka color <command> [<args>] [options]

Commands:
  list
    - Displays a list of registered color schemes.

  set <name|index> [--vim] [--term] [-x] [-v|--verbose]
    - Apply the specified color scheme.
    - Option `--vim`: Apply only to Vim.
    - Option `--term`: Apply only to the terminal.
    - Option `-x`: Use xterm 256-color mode for terminal colors.
    - Option `-v`, `--verbose`: Enable verbose output.
    - If no option is specified, the color scheme is applied to both Vim and the terminal.

  reset [-x] [-v|--verbose]
    - Reset Vim and terminal color schemes to default.
    - Option `-x`: Use xterm 256-color mode for terminal colors.
    - Option `-v`, `--verbose`: Enable verbose output.

  help
    - Display this help message.

Examples:
  luka color list
  luka color set berry --vim
  luka color set berry --term
  luka color set berry -x
  luka color set berry
  luka color set 0 --vim
  luka color set 2 -x
  luka color reset -x
    """
    print(help_text)

def main():
    """
    メイン関数。引数を解析し、対応する操作を実行する。
    """
    schemes = load_color_schemes()
    xterm_colors = load_xterm_colors()

    if len(sys.argv) < 2:
        show_help()
        sys.exit(1)

    command_or_identifier = sys.argv[1]

    if command_or_identifier == 'list':
        list_schemes(schemes)
        sys.exit(0)

    elif command_or_identifier == 'set':
        if len(sys.argv) < 3:
            print("Error: 'set' command requires the name or index of the color scheme.")
            sys.exit(1)
        identifier = sys.argv[2]
        options = sys.argv[3:]

        # デフォルトで両方に適用
        apply_vim = False
        apply_term = False
        use_xterm256 = False
        verbose = False

        for opt in options:
            if opt == '--vim':
                apply_vim = True
            elif opt == '--term':
                apply_term = True
            elif opt == '-x':
                use_xterm256 = True
            elif opt == '-v' or opt == '--verbose':
                verbose = True
            else:
                print(f"Error: unknown option '{opt}'.")
                sys.exit(1)

        # オプションが指定されていない場合、両方に適用
        if not (apply_vim or apply_term):
            apply_vim = True
            apply_term = True

        scheme = select_scheme(schemes, identifier)

        if apply_vim:
            backup_file(VIMRC_PATH)
            apply_vim_colorscheme(scheme, verbose)

        if apply_term:
            backup_file(BASHRC_PATH)
            apply_terminal_colorscheme(scheme, xterm_colors, use_xterm256, verbose)

        sys.exit(0)

    elif command_or_identifier == 'reset':
        options = sys.argv[2:]
        use_xterm256 = False
        verbose = False

        for opt in options:
            if opt == '-x':
                use_xterm256 = True
            elif opt == '-v' or opt == '--verbose':
                verbose = True
            else:
                print(f"Error: unknown option '{opt}'.")
                sys.exit(1)

        reset_colorscheme(xterm_colors, use_xterm256, verbose)
        sys.exit(0)

    elif command_or_identifier == 'help' or command_or_identifier == '--help' :
        show_help()
        sys.exit(0)

    else:
        print(f"Error: unknown command or identifier '{command_or_identifier}'.")
        show_help()
        sys.exit(1)

if __name__ == "__main__":
    main()
