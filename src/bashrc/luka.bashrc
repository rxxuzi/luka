# luka bashrc
export LUKA_SOURCED=1

fg() { printf '\[\e[38;2;%s;%s;%sm\]' "$1" "$2" "$3"; }
bg() { printf '\[\e[48;2;%s;%s;%sm\]' "$1" "$2" "$3"; }

# テキスト属性
reset='\[\e[0m\]'
bold='\[\e[1m\]'

# Luka Prompt Color Section
# Luka Prompt Color Start
c1=$(fg 100 255 100) 
c2=$(fg 100 100 255) 
c3=$(fg 255 255 255) 
c4=$(fg 50 50 255) 
# Luka Prompt Color End

# パスのエクスポート
export PATH="$PATH:~/luka/bin"

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes

if [ "$color_prompt" = yes ]; then
    VIRTUAL_ENV_DISABLE_PROMPT=1
    if [ "$EUID" -eq 0 ]; then 
        c1=$(fg 255 0 0)  # root user is red term
    fi
    
    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PS1=$c1'┌──${debian_chroot:+($debian_chroot)──}${VIRTUAL_ENV:+('$bold'$(basename $VIRTUAL_ENV)'$c1')}('$c2'\u'$c1')-['$bold$c3'\w'$c1']\n'$c1'└─'$c4'\$'$reset' '
            ;;
        oneline)
            PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}'$c2'\u'$reset':'$c1$bold'\w'$reset'\$ '
            ;;
        backtrack)
            PS1='${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV)) }${debian_chroot:+($debian_chroot)}'$c1'\u@\h'$reset':'$c2'\w'$reset'\$ '
            ;;
        minimal)
            PS1=$c1'\u'$reset':'$c2'\w'$reset'\$ '
            ;;
        classic)
            PS1=$c1'\u@\h'$reset' '$c2'\w'$reset'\$ '
            ;;
        *)
            PS1=$c1'┌──${debian_chroot:+($debian_chroot)──}${VIRTUAL_ENV:+('$bold'$(basename $VIRTUAL_ENV)'$c1')}('$c2'\u\h'$prompt_color')-['$bold'\w'$prompt_color']\n'$prompt_color'└─'$c2'\$'$reset' '
            ;;
    esac
    
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi


unset color_prompt force_color_prompt

# NEWLINE_BEFORE_PROMPT が yes の場合、プロンプトの前に改行を入れる
if [ "$NEWLINE_BEFORE_PROMPT" = yes ]; then
    PROMPT_COMMAND='echo'
fi

# xtermの場合、タイトルを user@host:dir に設定
case "$TERM" in
    xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
        ;;
    *)
        ;;
esac

# エイリアスの読み込み
. ~/luka/src/bashrc/aliases.bash

# 不要な関数と変数のクリーンアップ
unset -f fg bg
unset bold reset
unset c1 c2 c3 c4

# lpath command
lpath() {
    local num_args=$#
    if [ "$num_args" -lt 1 ]; then
        echo "Usage:"
        echo "  lpath += <path>   : Add a new path to PATH"
        echo "  lpath -= <path>   : Remove a path from PATH"
        echo "  lpath !           : Clean up duplicate paths in PATH"
        echo "  lpath list        : List all paths in PATH"
        echo "  lpath help        : Show this help message"
        return 1
    fi

    local action="$1"
    local path="$2"

    case "$action" in
        "+="|"add")
            if [ -z "$path" ]; then
                echo "Error: No path provided for 'add' command."
                echo "Usage: lpath += <path> or lpath add <path>"
                return 1
            fi
            local abs_path
            abs_path=$(realpath -m "$path")
            if echo ":$PATH:" | grep -q ":$abs_path:"; then
                echo "Path already exists: $abs_path"
            else
                export PATH="$PATH:$abs_path"
                echo "Path added: $abs_path"
            fi
            ;;
        "-="|"remove"|"del")
            if [ -z "$path" ]; then
                echo "Error: No path provided for 'remove' command."
                echo "Usage: lpath -= <path> or lpath remove <path> or lpath del <path>"
                return 1
            fi
            local abs_remove
            abs_remove=$(realpath -m "$path")
            export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "^$abs_remove$" | paste -sd ':' -)
            echo "Path removed: $abs_remove"
            ;;
        "!")
            export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | paste -sd ':' -)
            echo "PATH has been cleaned up. Duplicates removed."
            ;;
        "list"|"-l")
            echo "PATH Entries:"
            IFS=':' read -ra ADDR <<< "$PATH"
            for i in "${!ADDR[@]}"; do
                printf "%d. %s (%s)\n" $((i+1)) "${ADDR[i]}" "$(realpath -m "${ADDR[i]}")"
            done
            ;;
        "help"|"--help"|"-h")
            echo "Usage:"
            echo "  lpath += <path>   : Add a new path to PATH"
            echo "  lpath + <path>    : Add a new path to PATH"
            echo "  lpath -= <path>   : Remove a path from PATH"
            echo "  lpath - <path>    : Remove a path from PATH"
            echo "  lpath !           : Clean up duplicate paths in PATH"
            echo "  lpath list        : List all paths in PATH"
            echo "  lpath help        : Show this help message"
            return 0
            ;;
        *)
            echo "Unknown command: $action"
            echo "Use 'lpath help' to see available commands."
            return 1
            ;;
    esac
}

# luka bash end

