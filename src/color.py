#!/usr/bin/env python3

import os
import sys
import json
import argparse
import shutil

# 定数
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
COLOR_RES_DIR = os.path.join(BASE_DIR, '../res/color')
SCRIPTS_DIR = os.path.join(BASE_DIR, '../res/scripts')
VIM_COLORS_DIR = os.path.expanduser('~/.vim/colors')
VIMRC_PATH = os.path.expanduser('~/.vimrc')
BASHRC_PATH = os.path.expanduser('~/luka/src/bashrc/luka.bashrc')

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

def apply_vim_colorscheme(scheme):
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
    print(f"'{scheme['name']}.vim' copied to '{VIM_COLORS_DIR}'.")

    # .vimrcを更新してカラースキームを設定
    update_vimrc(scheme['name'])
    print(f"Vim color scheme set to '{scheme['name']}'.")

def apply_terminal_colorscheme(scheme):
    """
    ターミナルのカラースキームを適用するためにluka.bashrcを変更する。
    """
    ansi_colors = generate_prompt_color_sequences(scheme)
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
        new_lines.append(f"c1=$(fg {c1['r']} {c1['g']} {c1['b']})\n")
        new_lines.append(f"c2=$(fg {c2['r']} {c2['g']} {c2['b']})\n")
        new_lines.append(f"c3=$(fg {c3['r']} {c3['g']} {c3['b']})\n")
        new_lines.append(f"c4=$(fg {c4['r']} {c4['g']} {c4['b']})\n")
        new_lines.append("# Luka Prompt Color End\n")

    with open(BASHRC_PATH, 'w') as f:
        f.writelines(new_lines)

    print(f"Terminal color scheme set to '{scheme['name']}'. Restart the terminal to apply the change or run the following command")
    print(f"reload")

def update_vimrc(scheme_name):
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

def generate_prompt_color_sequences(scheme):
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
    ansi_colors = []
    for color in selected_colors:
        if color.upper() == "NONE":
            ansi_colors.append({"r":0, "g":0, "b":0})  # デフォルト色または適切なデフォルト値
        else:
            rgb = hex_to_rgb(color)
            if rgb:
                ansi_colors.append({"r":rgb[0], "g":rgb[1], "b":rgb[2]})
            else:
                print(f"Error: Invalid color code '{color}'.")
                sys.exit(1)
    return ansi_colors

def hex_to_rgb(hex_color):
    """
    HEXカラーコードをRGBタプルに変換する。
    """
    hex_color = hex_color.lstrip('#')
    if len(hex_color) != 6:
        return None
    try:
        r, g, b = tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))
        return (r, g, b)
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

def reset_colorscheme():
    """
    Vimとターミナルのカラースキームをデフォルトにリセットする。
    """
    # Vimのカラースキームをリセット
    reset_vim_colorscheme()

    # ターミナルのカラースキームをリセット
    reset_terminal_colorscheme()

    print("Vim and terminal color schemes reset to default.") 
    print("Restart terminal to apply changes or run the following command:") 
    print("reload")

def reset_vim_colorscheme():
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

    print("Vim color scheme reset to default.")

def reset_terminal_colorscheme():
    """
    ターミナルのカラースキームをデフォルトにリセットするためにluka.bashrcを変更する。
    """
    # luka.bashrcのバックアップ
    backup_file(BASHRC_PATH)

    prompt_start = "# Luka Prompt Color Start"
    prompt_end = "# Luka Prompt Color End"

    with open(BASHRC_PATH, 'r') as f:
        lines = f.readlines()

    new_lines = []
    in_prompt_color_section = False
    for line in lines:
        if line.strip() == prompt_start:
            in_prompt_color_section = True
            new_lines.append(line)  # コメント行を保持
            # デフォルトのカラー設定を挿入
            new_lines.append("c1=$(fg 70 255 70)\n")
            new_lines.append("c2=$(fg 0 255 255)\n")
            new_lines.append("c3=$(fg 255 255 255)\n")
            new_lines.append("c4=$(fg 0 255 255)\n")
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
        new_lines.append("c1=$(fg 70 255 70)\n")
        new_lines.append("c2=$(fg 0 255 255)\n")
        new_lines.append("c3=$(fg 255 255 255)\n")
        new_lines.append("c4=$(fg 0 255 255)\n")
        new_lines.append("# Luka Prompt Color End\n")

    with open(BASHRC_PATH, 'w') as f:
        f.writelines(new_lines)

    print("Terminal color scheme reset to default.")

def show_help():
    """
    Display the help message.
    """
    help_text = """
Luka Color - Vim and Terminal Color Scheme Management Tool

Usage:
  luka color <command> [<args>]

Commands:
  list
    - Displays a list of registered color schemes.

  set <name|index> [--vim] [--term]
    - Apply the specified color scheme.
    - Option `--vim`: Apply only to Vim.
    - Option `--term`: Apply only to the terminal.
    - If no option is specified, the color scheme is applied to both Vim and the terminal.

  reset
    - Reset Vim and terminal color schemes to default.

  help
    - Display this help message.

Examples:
  luka color list
  luka color set berry --vim
  luka color set berry --term
  luka color set berry
  luka color set 0 --vim
  luka color help
    """
    print(help_text)


def main():
    """
    メイン関数。引数を解析し、対応する操作を実行する。
    """
    schemes = load_color_schemes()

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

        for opt in options:
            if opt == '--vim':
                apply_vim = True
            elif opt == '--term':
                apply_term = True

        # オプションが指定されていない場合、両方に適用
        if not (apply_vim or apply_term):
            apply_vim = True
            apply_term = True

        scheme = select_scheme(schemes, identifier)

        if apply_vim:
            backup_file(VIMRC_PATH)
            apply_vim_colorscheme(scheme)

        if apply_term:
            backup_file(BASHRC_PATH)
            apply_terminal_colorscheme(scheme)

        sys.exit(0)

    elif command_or_identifier == 'reset':
        reset_colorscheme()
        sys.exit(0)

    elif command_or_identifier == 'help' or command_or_identifier == '--help' :
        show_help()
        sys.exit(0)

    elif command_or_identifier.isdigit():
        index = int(command_or_identifier)
        options = sys.argv[2:]

        # デフォルトで両方に適用
        apply_vim = False
        apply_term = False

        for opt in options:
            if opt == '--vim':
                apply_vim = True
            elif opt == '--term':
                apply_term = True

        # オプションが指定されていない場合、両方に適用
        if not (apply_vim or apply_term):
            apply_vim = True
            apply_term = True

        scheme = select_scheme(schemes, command_or_identifier)

        if apply_vim:
            backup_file(VIMRC_PATH)
            apply_vim_colorscheme(scheme)

        if apply_term:
            backup_file(BASHRC_PATH)
            apply_terminal_colorscheme(scheme)

        sys.exit(0)

    else:
        print(f"Error: unknown command or identifier '{command_or_identifier}'.")
        show_help()
        sys.exit(1)

if __name__ == "__main__":
    main()
