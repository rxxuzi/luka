# luka aliases.bash
# by rxxuzi

alias ls='ls --color=auto'
alias ip='ip --color=auto'
alias ll=' ls --human-readable --size -1 -S --classify -la --color=auto'
alias la='ls -A'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias 'cd..'='cd ..'
alias '..'='cd ..'
alias '...'='cd ../../../'
alias '....'='cd ../../../../'
alias '.....'='cd ../../../../'
alias '.4'='cd ../../../../'
alias '.5'='cd ../../../../..'
alias whatsup='service --status-all'  
alias mkdir='mkdir -pv'
alias cls='clear'
alias hg='history | grep $1'  
alias untar='tar -zxvf $1'
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias pscpu='ps auxf | sort -nr -k 3'
alias usage='du -ch | grep total'
alias totalusage='df -hl --total | grep total'
alias ports='netstat -tulanp'
alias myip='curl ifconfig.me'
alias serve='python3 -m http.server'
alias reload='source ~/.bashrc'
alias revenv='source venv/bin/activate'
alias py='python3'
alias '?'='f() { ls -lh "$1" && file "$1"; }; f'
alias verify='find . -type d -exec chmod 755 {} \; && find . -type f -exec chmod 644 {} \;'

mkcd() {
    mkdir -p "$1" && cd "$1"
}

mkvenv() {
    python3 -m venv "$1" && source "$1/bin/activate"
}

alias rmvim='function _rmvim() { rm -f "$1" && vim "$1"; }; _rmvim'
