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

# エイリアスと関数の読み込み
. ~/luka/src/bashrc/aliases.bash
. ~/luka/src/bashrc/func.bashrc

# 不要な関数と変数のクリーンアップ
unset -f fg bg
unset bold reset
unset c1 c2 c3 c4

# luka bash end