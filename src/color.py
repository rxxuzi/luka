#!/usr/bin/env python3
# -----------------------------------------------------------------------------
#  color.py
#   - DESCRIPTION: Vim and Terminal Color Scheme Management Tool (Dynamic base.vim)
#   - AUTHOR      : github.com/rxxuzi
#   - LICENSE     : CC0
# -----------------------------------------------------------------------------

import os
import sys
import json
import shutil
import re
import tempfile

# -----------------------------------------------------------------------------
#  定数定義
# -----------------------------------------------------------------------------
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

COLOR_RES_DIR  = os.path.join(BASE_DIR, '../res/color')
SCRIPTS_DIR    = os.path.join(BASE_DIR, '../res/scripts')
VIM_COLORS_DIR = os.path.expanduser('~/.vim/colors')
VIMRC_PATH     = os.path.expanduser('~/.vimrc')
BASHRC_PATH    = os.path.expanduser('~/luka/src/bashrc/luka.bashrc')
C256_JSON_PATH = os.path.join(BASE_DIR, '../res/c_256.json')
BASE_VIM_FILE  = os.path.join(BASE_DIR, '../res/base.vim')

# -----------------------------------------------------------------------------
#  ヘルパー関数群
# -----------------------------------------------------------------------------

def show_help():
    """
    Display the help message.
    """
    help_text = r"""
Luka Color - Vim and Terminal Color Scheme Management Tool (Dynamic base.vim)

Usage:
  luka color <command> [<args>] [options]

Commands:
  list
    - Displays a list of registered color schemes.

  set <name|index> [--vim] [--term] [-t] [-v|--verbose]
    - Apply the specified color scheme.
    - Option `--vim`: Apply only to Vim.
    - Option `--term`: Apply only to the terminal.
    - Option `-t`, `--true-color`: Use true-color (24bit) mode instead of xterm256.
    - Option `-v`, `--verbose`: Enable verbose output.
    - If no option is specified, the color scheme is applied to both Vim and the terminal.

  reset [-t] [-v|--verbose]
    - Reset Vim and terminal color schemes to default.
    - Option `-t`, `--true-color`: Use true-color for terminal colors.
    - Option `-v`, `--verbose`: Enable verbose output.

  help
    - Display this help message.

Examples:
  luka color list
  luka color set berry --vim
  luka color set berry --term
  luka color set berry -t
  luka color set berry
  luka color set 0 --vim
  luka color set 2 -t
  luka color reset -t
    """
    print(help_text)

def backup_file(file_path):
    """
    指定ファイルのバックアップを作成する。（一度作成されていれば再作成はしない）
    """
    backup_path = f"{file_path}.backup"
    if not os.path.exists(backup_path):
        shutil.copy(file_path, backup_path)
        print(f"Backup created to '{backup_path}'.")

def hex_to_rgb(hex_color):
    """
    #RRGGBB 形式の文字列を (r, g, b) のタプルにパース。
    失敗した場合は None を返す。
    """
    hex_color = hex_color.lstrip('#')
    if len(hex_color) != 6:
        return None
    try:
        r, g, b = (int(hex_color[i:i+2], 16) for i in (0, 2, 4))
        return (r, g, b)
    except ValueError:
        return None

def color_distance(rgb1, rgb2):
    """
    2つの RGB カラー間の距離を計算（単純な Euclidean distance の2乗和）。
    """
    return sum((c1 - c2) ** 2 for c1, c2 in zip(rgb1, rgb2))

def hex_to_xterm256(hex_color, xterm_colors):
    """
    #RRGGBB を最も近い xterm256 カラーコード(0~255) に変換。
    """
    rgb = hex_to_rgb(hex_color)
    if rgb is None:
        return None
    min_distance = float('inf')
    closest_xterm = None
    for color in xterm_colors:
        xterm_rgb = tuple(color['rgb'])
        dist = color_distance(rgb, xterm_rgb)
        if dist < min_distance:
            min_distance = dist
            closest_xterm = color['xterm']
    return closest_xterm

# -----------------------------------------------------------------------------
#  カラースキームのロード
# -----------------------------------------------------------------------------

def load_color_schemes():
    """
    res/color ディレクトリ内の .json スキームを name をキーとした辞書にまとめて返す。
    """
    if not os.path.exists(COLOR_RES_DIR):
        print(f"Error: color scheme directory '{COLOR_RES_DIR}' not found.")
        sys.exit(1)

    schemes = {}
    for file in os.listdir(COLOR_RES_DIR):
        if file.endswith('.json'):
            path = os.path.join(COLOR_RES_DIR, file)
            with open(path, 'r') as f:
                try:
                    data = json.load(f)
                    if 'name' in data:
                        schemes[data['name']] = data
                except json.JSONDecodeError as e:
                    print(f"Error: parse error in {file}: {e}")
    return schemes

def load_xterm_colors():
    """
    c_256.json を読み込んで xterm256 カラーへのマッピング情報を取得。
    """
    if not os.path.exists(C256_JSON_PATH):
        print(f"Error: xterm color file '{C256_JSON_PATH}' not found.")
        sys.exit(1)
    with open(C256_JSON_PATH, 'r') as f:
        try:
            return json.load(f)
        except json.JSONDecodeError as e:
            print(f"Error: parse error in c_256.json: {e}")
            sys.exit(1)

def list_schemes(schemes):
    """
    登録されたカラースキーム一覧を表示。
    """
    if not schemes:
        print("No color scheme available.")
        return
    print("Available color schemes:")
    sorted_names = sorted(schemes.keys())
    for idx, name in enumerate(sorted_names):
        print(f"  {idx}. {name}")

def select_scheme(schemes, identifier):
    """
    スキーム名 (string) または インデックス (string digit) からスキームを取得。
    """
    sorted_names = sorted(schemes.keys())
    if identifier.isdigit():
        idx = int(identifier)
        if 0 <= idx < len(sorted_names):
            return schemes[sorted_names[idx]]
        else:
            print(f"Error: Index {idx} is out of range.")
            sys.exit(1)
    else:
        # 名前指定
        if identifier in schemes:
            return schemes[identifier]
        else:
            print(f"Error: No scheme found for '{identifier}'.")
            sys.exit(1)

# -----------------------------------------------------------------------------
#  base.vim を動的に生成する処理
# -----------------------------------------------------------------------------

def generate_dynamic_vim(scheme, use_true_color, xterm_colors, base_vim_file):
    """
    base.vim ファイル内のプレースホルダ ({ct_x_0}, {gui_x_0} など) を
    JSONスキームの色で置換して最終的な Vim カラー設定テキストを返す。

    - {ct_x_0}  → 256色モード時は数値、true-colorならどうする？など、今回の例では「true-color時も 'NONE' または何かを入れる」
      一般的には cterm は 256色のためだけに使うので、true-colorの場合は cterm系はあまり気にしなくてよいかもしれません。
    - {gui_x_0} → true-color時は #rrggbb、256色時は同じ #rrggbb にしておくことが多いです。

    """
    if not os.path.exists(base_vim_file):
        print(f"Error: base Vim file '{base_vim_file}' not found.")
        sys.exit(1)

    with open(base_vim_file, 'r', encoding='utf-8') as f:
        base_lines = f.readlines()

    # 例: {ct_x_0} => scheme["x"][0] (→ xterm256 に変換)
    #     {gui_z_1} => scheme["z"][1] (→ #RRGGBB のまま)
    pattern = re.compile(r'\{(ct|gui)_([a-z])_(\d+)\}')

    def get_color(prefix, idx):
        """
        scheme[prefix] がリストならインデックスで取り出す
        scheme[prefix] が単一値ならそのまま返す
        """
        if prefix not in scheme:
            print(f"Error: key '{prefix}' not found in scheme '{scheme['name']}'.")
            sys.exit(1)
        value = scheme[prefix]
        if isinstance(value, list):
            if idx < len(value):
                return value[idx]
            else:
                print(f"Error: index {idx} out of range for '{prefix}' in scheme '{scheme['name']}'.")
                sys.exit(1)
        else:
            # 単色の場合は idx は無視してそのまま返す
            return value

    def placeholder_replacer(m):
        mode   = m.group(1)  # "ct" or "gui"
        prefix = m.group(2)  # "x", "z", "c", "a" etc.
        idx    = int(m.group(3))

        hexcol = get_color(prefix, idx)  # ex. "#ffcc00" or "NONE" etc.

        if hexcol.upper() == "NONE":
            return "NONE"

        if not hexcol.startswith("#"):
            # たとえば "NONE" や何かの場合はそのまま
            return hexcol

        if mode == "ct":
            # cterm 用 → 256色番号に変換して返す
            # true-colorでも一旦 cterm は数字で行く、もしくは "NONE" にするなど適宜
            code_256 = hex_to_xterm256(hexcol, xterm_colors)
            if code_256 is None:
                print(f"Warning: invalid color '{hexcol}' -> fallback to 15 (white).")
                code_256 = 15
            return str(code_256)
        else:
            # gui 用
            if use_true_color:
                # そのまま #RRGGBB
                return hexcol
            else:
                # 256色モードでも、guifg=... のところは #RRGGBB を指定してOK
                # ただし端末だと実際に256色しか出ませんが、エラーにはならない
                return hexcol

    new_lines = []
    for line in base_lines:
        replaced_line = pattern.sub(placeholder_replacer, line)
        new_lines.append(replaced_line)

    return "".join(new_lines)

def apply_vim_colorscheme(scheme, verbose=False, use_true_color=False, xterm_colors=None):
    """
    base.vim と scheme を合成した Vim カラーファイルを生成し、~/.vim/colors に配置して有効化。
    """
    if not xterm_colors and not use_true_color:
        print("Warning: xterm_colors is empty but use_true_color=False => fallback might fail.")

    generated_vim_text = generate_dynamic_vim(
        scheme        = scheme,
        use_true_color= use_true_color,
        xterm_colors  = xterm_colors,
        base_vim_file = BASE_VIM_FILE
    )

    # 一時ファイルに書き出し
    with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.vim') as tmp:
        tmp.write(generated_vim_text)
        tmp_vim_path = tmp.name

    # ~/.vim/colors/<scheme_name>.vim に保存
    os.makedirs(VIM_COLORS_DIR, exist_ok=True)
    final_vim_file = os.path.join(VIM_COLORS_DIR, f"{scheme['name']}.vim")
    shutil.copy(tmp_vim_path, final_vim_file)

    if verbose:
        print(f"Generated Vim color file -> {final_vim_file}")

    # vimrc を更新
    update_vimrc(scheme['name'], verbose)
    print(f"Vim color scheme set to '{scheme['name']}'.")

# -----------------------------------------------------------------------------
#  ターミナル用の @ キー先頭4色を設定するロジック
# -----------------------------------------------------------------------------

def generate_prompt_color_sequences(scheme, xterm_colors, use_xterm256):
    """
    ターミナルのカラースキームを作る。
    スキームJSONの "@" キーに定義された配列の先頭4色を取り、PS1などに使う。
    """
    at_colors = scheme.get('@', [])
    if len(at_colors) < 4:
        print("Error: The '@' key requires at least 4 colors in the scheme JSON.")
        sys.exit(1)

    selected = at_colors[:4]
    result = []
    for col in selected:
        if col.upper() == "NONE":
            result.append(None)
        else:
            if use_xterm256:
                # 256色に変換
                code = hex_to_xterm256(col, xterm_colors)
                if code is None:
                    print(f"Error: invalid color code '{col}' in @ array.")
                    sys.exit(1)
                result.append(code)
            else:
                # true-color
                rgb = hex_to_rgb(col)
                if not rgb:
                    print(f"Error: invalid color code '{col}' in @ array.")
                    sys.exit(1)
                result.append({"r": rgb[0], "g": rgb[1], "b": rgb[2]})
    return result

def apply_terminal_colorscheme(scheme, xterm_colors, use_xterm256, verbose=False):
    """
    ターミナル(PS1)カラーを '@'キーの先頭4色で設定。
    """
    ansi_colors = generate_prompt_color_sequences(scheme, xterm_colors, use_xterm256)
    if not ansi_colors:
        print("Error: ANSI color sequence generation failed.")
        sys.exit(1)

    c1, c2, c3, c4 = ansi_colors
    backup_file(BASHRC_PATH)

    # luka.bashrc の "# Luka Prompt Color Start"～"# Luka Prompt Color End" を置換
    with open(BASHRC_PATH, 'r') as f:
        lines = f.readlines()

    new_lines = []
    in_color_section = False
    start_tag = "# Luka Prompt Color Start"
    end_tag   = "# Luka Prompt Color End"

    for line in lines:
        line_stripped = line.strip()
        if line_stripped == start_tag:
            in_color_section = True
            new_lines.append(line)  # コメント行そのまま
            # ここで新色を追加
            if use_xterm256:
                new_lines.append(f"c1='\\e[38;5;{c1}m'\n")
                new_lines.append(f"c2='\\e[38;5;{c2}m'\n")
                new_lines.append(f"c3='\\e[38;5;{c3}m'\n")
                new_lines.append(f"c4='\\e[38;5;{c4}m'\n")
            else:
                # true-color
                new_lines.append(f"c1=$(fg {c1['r']} {c1['g']} {c1['b']})\n")
                new_lines.append(f"c2=$(fg {c2['r']} {c2['g']} {c2['b']})\n")
                new_lines.append(f"c3=$(fg {c3['r']} {c3['g']} {c3['b']})\n")
                new_lines.append(f"c4=$(fg {c4['r']} {c4['g']} {c4['b']})\n")

        elif line_stripped == end_tag:
            in_color_section = False
            new_lines.append(line)
        else:
            if not in_color_section:
                new_lines.append(line)

    # Luka Prompt Color セクションが無い場合、末尾に追加
    if not any(start_tag in ln for ln in lines):
        new_lines.append("\n" + start_tag + "\n")
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
        new_lines.append(end_tag + "\n")

    with open(BASHRC_PATH, 'w') as f:
        f.writelines(new_lines)

    print(f"Terminal color scheme set to '{scheme['name']}'.")
    print("Restart your terminal or run `reload` to apply.")
    if verbose:
        print("New terminal colors:")
        if use_xterm256:
            for i, c in enumerate([c1, c2, c3, c4], 1):
                print(f"c{i}: \033[38;5;{c}m█\033[0m")
        else:
            for i, c in enumerate([c1, c2, c3, c4], 1):
                print(f"c{i}: \033[38;2;{c['r']};{c['g']};{c['b']}m█\033[0m")

# -----------------------------------------------------------------------------
#  VimRC アップデート
# -----------------------------------------------------------------------------

def update_vimrc(scheme_name, verbose=False):
    """
    .vimrc を更新して colorscheme <scheme_name> を設定。
    """
    if not os.path.exists(VIMRC_PATH):
        print(f"Error: Vim configuration file '{VIMRC_PATH}' not found.")
        sys.exit(1)

    with open(VIMRC_PATH, 'r') as f:
        lines = f.readlines()

    found = False
    with open(VIMRC_PATH, 'w') as f:
        for line in lines:
            if line.strip().startswith('colorscheme'):
                f.write(f"colorscheme {scheme_name}\n")
                found = True
            else:
                f.write(line)
        if not found:
            f.write(f"\ncolorscheme {scheme_name}\n")

    if verbose:
        print(f".vimrc updated with colorscheme '{scheme_name}'.")

# -----------------------------------------------------------------------------
#  reset ロジック
# -----------------------------------------------------------------------------

def reset_vim_colorscheme(verbose=False):
    """
    Vimをデフォルトのカラースキームに戻す。
    """
    if not os.path.exists(VIMRC_PATH):
        print(f"Error: Vim configuration file '{VIMRC_PATH}' not found.")
        return

    with open(VIMRC_PATH, 'r') as f:
        lines = f.readlines()

    found = False
    with open(VIMRC_PATH, 'w') as f:
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
    ターミナル (PS1) カラースキームをデフォルトに戻す。
    """
    backup_file(BASHRC_PATH)

    prompt_start = "# Luka Prompt Color Start"
    prompt_end   = "# Luka Prompt Color End"

    # デフォルト4色
    default_colors = ["#87ffff", "#87ff00", "#ff7fff", "#feec90"]

    if use_xterm256:
        color_values = []
        for dc in default_colors:
            code = hex_to_xterm256(dc, xterm_colors)
            color_values.append(code if code is not None else 15)
    else:
        color_values = []
        for dc in default_colors:
            rgb = hex_to_rgb(dc)
            if rgb is None:
                color_values.append(None)
            else:
                color_values.append({"r": rgb[0], "g": rgb[1], "b": rgb[2]})

    with open(BASHRC_PATH, 'r') as f:
        lines = f.readlines()

    new_lines = []
    in_section = False
    for line in lines:
        if line.strip() == prompt_start:
            in_section = True
            new_lines.append(line)
            # デフォルト色設定
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
        elif line.strip() == prompt_end:
            in_section = False
            new_lines.append(line)
            continue

        if not in_section:
            new_lines.append(line)

    # セクションが無い場合は後ろに追加
    if not any(prompt_start in ln for ln in lines):
        new_lines.append("\n" + prompt_start + "\n")
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
        new_lines.append(prompt_end + "\n")

    with open(BASHRC_PATH, 'w') as f:
        f.writelines(new_lines)

    if verbose:
        print("Terminal color scheme reset to default.")

def reset_colorscheme(xterm_colors, use_xterm256=False, verbose=False):
    """
    Vim および ターミナルをデフォルトカラーにリセット。
    """
    reset_vim_colorscheme(verbose)
    reset_terminal_colorscheme(xterm_colors, use_xterm256, verbose)
    print("Vim and terminal color schemes reset to default.")
    print("Restart terminal or run `reload` to apply changes.")

# -----------------------------------------------------------------------------
#  メイン処理
# -----------------------------------------------------------------------------

def main():
    # スキーム一覧と xterm256 カラーを読み込み
    schemes      = load_color_schemes()
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
            print("Error: 'set' command requires a scheme name or index.")
            sys.exit(1)

        identifier = sys.argv[2]
        options    = sys.argv[3:]

        apply_vim_flag  = False
        apply_term_flag = False
        use_xterm256    = True   # デフォルトでは xterm256
        verbose         = False

        for opt in options:
            if opt == '--vim':
                apply_vim_flag = True
            elif opt == '--term':
                apply_term_flag = True
            elif opt in ('-t', '--true-color'):
                use_xterm256 = False
            elif opt in ('-v', '--verbose'):
                verbose = True
            else:
                print(f"Error: unknown option '{opt}'")
                sys.exit(1)

        # どちらも指定が無ければ両方に適用
        if not apply_vim_flag and not apply_term_flag:
            apply_vim_flag  = True
            apply_term_flag = True

        scheme = select_scheme(schemes, identifier)

        # Vim 適用
        if apply_vim_flag:
            backup_file(VIMRC_PATH)
            apply_vim_colorscheme(
                scheme,
                verbose=verbose,
                use_true_color=(not use_xterm256),
                xterm_colors=xterm_colors
            )

        # ターミナル適用
        if apply_term_flag:
            backup_file(BASHRC_PATH)
            apply_terminal_colorscheme(
                scheme,
                xterm_colors,
                use_xterm256,
                verbose=verbose
            )

        sys.exit(0)

    elif command_or_identifier == 'reset':
        options = sys.argv[2:]
        use_xterm256 = True
        verbose = False

        for opt in options:
            if opt in ('-t', '--true-color'):
                use_xterm256 = False
            elif opt in ('-v', '--verbose'):
                verbose = True
            else:
                print(f"Error: unknown option '{opt}'")
                sys.exit(1)

        reset_colorscheme(xterm_colors, use_xterm256, verbose)
        sys.exit(0)

    elif command_or_identifier in ('help', '--help'):
        show_help()
        sys.exit(0)

    else:
        # スキーム名にも見えない & コマンドでも無い
        print(f"Error: unknown command or identifier '{command_or_identifier}'.")
        show_help()
        sys.exit(1)

if __name__ == "__main__":
    main()
