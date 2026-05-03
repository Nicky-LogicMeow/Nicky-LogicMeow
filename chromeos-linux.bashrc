# ~/.bashrc for ChromeOS Linux mode (Crostini)
# Copy this file to ~/.bashrc inside the Linux terminal:
#   cp chromeos-linux.bashrc ~/.bashrc
# Then reload it:
#   source ~/.bashrc

# If not running interactively, do not do anything.
case "$-" in
    *i*) ;;
    *) return ;;
esac

# Load the default Debian bash settings when they exist.
if [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
fi

# Load common user-local tools when available.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# History: keep a long, shared, useful command history.
HISTSIZE=20000
HISTFILESIZE=40000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%F %T  "
shopt -s histappend

# Keep history fresh across terminal tabs.
PROMPT_COMMAND="history -a; history -c; history -r${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# Friendlier shell behavior.
shopt -s checkwinsize
shopt -s autocd 2> /dev/null || true
set -o notify

# Colors and useful defaults.
if command -v dircolors > /dev/null 2>&1; then
    eval "$(dircolors -b)"
fi

export CLICOLOR=1
export LESS="-R"
export GPG_TTY="$(tty 2> /dev/null)"

# Prefer user-local scripts.
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
esac

case ":$PATH:" in
    *":$HOME/bin:"*) ;;
    *) PATH="$HOME/bin:$PATH" ;;
esac

export PATH

# ChromeOS/Crostini paths.
export CHROMEOS_FILES="/mnt/chromeos/MyFiles"
export CHROMEOS_DOWNLOADS="/mnt/chromeos/MyFiles/Downloads"
export CHROMEOS_GOOGLE_DRIVE="/mnt/chromeos/GoogleDrive/MyDrive"

# Navigation and listing aliases.
alias cls='clear'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias l='ls -CF'
alias la='ls -A'
alias lsa='ls -A'
alias ll='ls -alF'
alias lt='ls -altr'
alias md='mkdir -p'

# ChromeOS-friendly shortcuts.
_chromeos_cd() {
    if [ -z "$1" ]; then
        return 2
    fi

    if [ ! -d "$1" ]; then
        printf "ChromeOS path not found: %s\n" "$1" >&2
        printf "Share the folder with Linux from the ChromeOS Files app first.\n" >&2
        return 1
    fi

    cd "$1" || return
}

myfiles() {
    _chromeos_cd "$CHROMEOS_FILES"
}

downloads() {
    _chromeos_cd "$CHROMEOS_DOWNLOADS"
}

drive() {
    _chromeos_cd "$CHROMEOS_GOOGLE_DRIVE"
}

alias open='xdg-open'
alias openhere='xdg-open .'

# Search helpers. Use rg when installed, keep grep fallback too.
alias findit='grep -rnw . -e'
if command -v rg > /dev/null 2>&1; then
    alias rgit='rg --hidden --glob "!.git"'
fi

# Nicer tool aliases when installed on Debian/Crostini.
command -v batcat > /dev/null 2>&1 && alias cat='batcat --paging=never'
command -v eza > /dev/null 2>&1 && alias ls='eza --group-directories-first'
command -v xclip > /dev/null 2>&1 && alias clip='xclip -selection clipboard'

# Git basics.
alias g='git'
alias gs='git status'
alias gst='git status --short --branch'
alias ga='git add'
alias gall='git add .'
alias gap='git add -p'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gps='git push'
alias gpl='git pull'
alias gf='git fetch --all --prune'

# Git branches and checkout.
alias gb='git branch'
alias gba='git branch -a'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gsc='git switch -c'

# Git diffs and logs.
alias gd='git diff'
alias gds='git diff --staged'
alias gdc='git diff --cached'
alias gl='git log --oneline --decorate --graph --all -20'
alias glg='git log --graph --pretty=format:"%C(yellow)%h%Creset %C(auto)%d%Creset %s %Cgreen(%cr) %Cblue<%an>%Creset" --all'
alias last='git log -1 HEAD --stat'

# Git undo helpers.
alias gunstage='git restore --staged'
alias gwip='git add . && git commit -m "wip"'

# Show the current Git branch with a dirty marker.
parse_git_branch() {
    local branch dirty

    branch="$(git symbolic-ref --short HEAD 2> /dev/null || git rev-parse --short HEAD 2> /dev/null)" || return

    if ! git diff --quiet --ignore-submodules -- 2> /dev/null || \
       ! git diff --cached --quiet --ignore-submodules -- 2> /dev/null; then
        dirty="*"
    fi

    printf " (%s%s)" "$branch" "$dirty"
}

# Jump to the top of the current Git repository.
croot() {
    local root
    root="$(git rev-parse --show-toplevel 2> /dev/null)" || {
        printf "Not inside a Git repository\n" >&2
        return 1
    }
    cd "$root" || return
}

# Print each PATH entry on its own line.
path() {
    printf "%s\n" "${PATH//:/$'\n'}"
}

# Make a directory and cd into it.
mkcd() {
    if [ -z "$1" ]; then
        printf "Usage: mkcd <directory>\n" >&2
        return 2
    fi

    mkdir -p "$1" && cd "$1" || return
}

# Soft-reset the last commit, or the last N commits with: gundo 3
gundo() {
    git reset --soft "HEAD~${1:-1}"
}

# Show useful repo info quickly.
ginfo() {
    git status --short --branch
    printf "\nRecent commits:\n"
    git log --oneline --decorate -5
}

# Quick apt maintenance helpers for Debian-based Crostini containers.
aptup() {
    sudo apt update && sudo apt upgrade
}

aptin() {
    sudo apt install "$@"
}

# Prompt: user@penguin:/path (branch*) $
export PS1='\[\e[1;32m\]\u@penguin\[\e[m\]:\[\e[1;34m\]\w\[\e[1;33m\]$(parse_git_branch)\[\e[m\]$ '
