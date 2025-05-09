#!/usr/bin/env bash
# -----------------------------------------------------------------------------
#  lpath.bash
#   - A function named 'lpath' for managing PATH entries.
#   - Author  : github.com/rxxuzi
#   - License : CC0
# -----------------------------------------------------------------------------

# lpath function for PATH management
lpath() {
    print_usage() {
        echo "Usage:"
        echo "  lpath +=  <path1> [<path2> ...]    : Add new path(s) to PATH (temporary)"
        echo "  lpath ++= <path1> [<path2> ...]    : Add new path(s) to PATH (persistent)"
        echo "  lpath -=  <path1> [<path2> ...]    : Remove path(s) from PATH"
        echo "  lpath !                            : Clean up duplicate paths in PATH"
        echo "  lpath list                         : List all paths in PATH"
        echo "  lpath help                         : Show this help message"
    }

    # 引数がなければUsage表示して終了
    if [ $# -lt 1 ]; then
        print_usage
        unset -f print_usage
        return 1
    fi

    local action="$1"
    shift 1  # actionの引数だけを先に取り除く(残りはパスなどの引数)

    # シェルプロファイルを自動判定
    local shell_profile
    if [ -n "$BASH_VERSION" ]; then
        shell_profile="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_profile="$HOME/.zshrc"
    else
        shell_profile="$HOME/.profile"
    fi

    # realpathの有無を判定し、なければフォールバック関数を定義
    if ! command -v realpath &>/dev/null; then
        realpath() {
            # シンボリックリンクなどを厳密に変換できない可能性がありますが、
            # 最低限のフォールバックとして利用します。
            local target="$1"
            if [ -d "$target" ]; then
                (cd "$target" && pwd)
            else
                local dir
                dir=$(dirname "$target")
                local base
                base=$(basename "$target")
                (cd "$dir" && echo "$(pwd)/$base")
            fi
        }
    fi

    case "$action" in
        #--------------------------------------------------
        # 1) 一時的にPATHへ追加
        #    lpath += <path1> [<path2> ...]
        #--------------------------------------------------
        "+="|"add")
            if [ $# -lt 1 ]; then
                echo "Error: No path provided for '+= (add)' command."
                print_usage
                unset -f print_usage
                return 1
            fi

            for p in "$lpath"; do
                local abs_path
                abs_path=$(realpath "$p")
                # 既にPATHに存在するかチェック
                if echo ":$PATH:" | grep -q ":$abs_path:"; then
                    echo "[SKIP]  Already in PATH: $abs_path"
                else
                    export PATH="$PATH:$abs_path"
                    echo "[ADD]   Added temporarily: $abs_path"
                fi
            done
            ;;
        #--------------------------------------------------
        # 2) 永続的にPATHへ追加
        #    lpath ++= <path1> [<path2> ...]
        #--------------------------------------------------
        "++="|"addp")
            if [ $# -lt 1 ]; then
                echo "Error: No path provided for '++=' command."
                print_usage
                unset -f print_usage
                return 1
            fi

            for p in "$lpath"; do
                local abs_persistent_path
                abs_persistent_path=$(realpath "$p")

                # まず一時的に追加
                if echo ":$PATH:" | grep -q ":$abs_persistent_path:"; then
                    echo "[SKIP]  Already in PATH: $abs_persistent_path"
                else
                    export PATH="$PATH:$abs_persistent_path"
                    echo "[ADD]   Added temporarily: $abs_persistent_path"
                fi

                # シェルプロファイルに書き込む(重複確認)
                if grep -Fxq "export PATH=\"\$PATH:$abs_persistent_path\"" "$shell_profile"; then
                    echo "[INFO]  Already in $shell_profile: $abs_persistent_path"
                else
                    echo "" >> "$shell_profile"
                    echo "# Added by lpath ++= command" >> "$shell_profile"
                    echo "export PATH=\"\$PATH:$abs_persistent_path\"" >> "$shell_profile"
                    echo "[SAVE]  Added persistently to $shell_profile: $abs_persistent_path"
                fi
            done
            ;;
        #--------------------------------------------------
        # 3) PATHから削除
        #    lpath -= <path1> [<path2> ...]
        #--------------------------------------------------
        "-="|"remove"|"del")
            if [ $# -lt 1 ]; then
                echo "Error: No path provided for '-=' command."
                print_usage
                unset -f print_usage
                return 1
            fi

            for p in "$lpath"; do
                local abs_remove
                abs_remove=$(realpath "$p")
                # 現在のPATHから削除
                local new_path
                new_path=$(echo "$PATH" | tr ':' '\n' | grep -v "^$abs_remove\$" | paste -sd ':' -)
                if [ "$new_path" = "$PATH" ]; then
                    echo "[SKIP]  Not found in PATH: $abs_remove"
                else
                    PATH="$new_path"
                    export PATH
                    echo "[DEL]   Removed from PATH: $abs_remove"
                fi

                # シェルプロファイルからも削除
                if grep -Fxq "export PATH=\"\$PATH:$abs_remove\"" "$shell_profile"; then
                    sed -i.bak "\|export PATH=\"\$PATH:$abs_remove\"|d" "$shell_profile"
                    echo "[SAVE]  Removed from $shell_profile: $abs_remove"
                fi
            done
            ;;
        #--------------------------------------------------
        # 4) PATHの重複クリーンアップ
        #    lpath !
        #--------------------------------------------------
        "!")
            local old_path="$PATH"
            PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | paste -sd ':' -)
            export PATH
            if [ "$PATH" = "$old_path" ]; then
                echo "[INFO]  No duplicates found. PATH is unchanged."
            else
                echo "[CLEAN] Duplicates removed from PATH."
            fi
            ;;
        #--------------------------------------------------
        # 5) PATHの一覧表示
        #    lpath list
        #--------------------------------------------------
        "list"|"-l")
            echo "PATH Entries:"
            IFS=':' read -ra ADDR <<< "$PATH"
            for i in "${!ADDR[@]}"; do
                printf "%d. %s\n" $((i+1)) "${ADDR[i]}"
            done
            ;;
        #--------------------------------------------------
        # 6) ヘルプ表示
        #    lpath help / --help / -h
        #--------------------------------------------------
        "help"|"--help"|"-h"|"?")
            print_usage
            unset -f print_usage
            return 0
            ;;
        #--------------------------------------------------
        # 上記以外のコマンドはUnknownとして扱う
        #--------------------------------------------------
        *)
            echo "Unknown command: $action"
            print_usage
            unset -f print_usage
            return 1
            ;;
    esac

    # ヘルパー関数をアンセットして外部からのアクセスを防ぐ
    unset -f print_usage
}
