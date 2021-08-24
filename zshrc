zmodload zsh/datetime

path=(
    /usr/local/opt/python/libexec/bin
    /usr/local/bin
    /usr/local/sbin
    $HOME/bin
    /usr/bin
    /usr/X11/bin
    /usr/sbin
    /bin
    /sbin
)

# History settings
HISTFILE=~/.zhistory
SAVEHIST=1000
HISTSIZE=1000
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt histignorespace
setopt append_history

setopt printexitvalue
setopt nohup

# some paranoid
#setopt no_rm_star_silent
#setopt no_clobber

# hashing
setopt hash_all
setopt hash_cmds

# no beeps
#unsetopt beep
#unsetopt histbeep

###############################################################################
#
#                                   Aliases
#
###############################################################################
alias ll="ls -lha"
alias k="kubectl"
alias upper="tr '[:lower:]' '[:upper:]'"
alias gcmc-curl="curl -s -H 'Authorization: Token 71718056f712b21a0297D846c129D07848d359a2'"
#if [ -x "/usr/local/bin/vim" -o -x "/usr/pkg/bin/vim" ]; then
#    alias vi=vim
#fi
#alias sudo="sudo -E"
#alias sockstat="lsof -Pni"
#alias wanip="dig +short myip.opendns.com @resolver1.opendns.com"
# system specific settings
#system=`uname`
#case $system in
#    Linux)
#        alias ls="ls --color=auto"
#        alias su="su -p"
#        ;;
#    FreeBSD)
#        alias ls="ls -G"
#        alias su="su -m"
#        unalias sockstat
#        ;;
#    Darwin)
#        alias ls="ls -G"
#        alias su="su -m"
#        alias xclip="pbcopy"
#        export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/CurrentJDK/Home
#        export PIP_DOWNLOAD_CACHE=$HOME/Library/Caches/pip-downloads
#        if [[ -d /usr/texbin ]]; then
#            PATH=$PATH:/usr/texbin
#        fi
#        ;;
#esac


# knife section
alias kcu="knife cookbook upload"
alias kdc="knife data bag from file components"
alias kda="knife data bag from file architecture"

# git section
alias git-graph="git log --graph --oneline --all"
#alias g="git"
#alias gs="git status"
#alias gd="git diff"
#alias gf="git flow"
#alias gl="git log"
#alias git-side-project="git config --local user.email myas@ptpm.ru"
#alias gcd='cd $(git rev-parse --show-toplevel)'
## pythonic
#alias pep8all='git ls-files  \*.py | xargs -n1 pep8 -r'
#alias pfall='git ls-files  \*.py | xargs -n1 pyflakes'
#alias pep8mod='git diff --name-only | grep .py$ | xargs -n1 pep8 -r'
#alias pfmod='git diff --name-only | grep .py$ | xargs -n1 pyflakes'

# hg section
alias hcd='cd $(hg root)'
alias hgl="hg log -G -f -T '\x1b[31m{node|short}\x1b[33m:{branches} \x1b[37m- {desc|firstline} \x1b[32m({date|age}) \x1b[34;1m<{author|person}>\x1b[37m\n' | less -R"
alias hgla="hg log -G -T '\x1b[31m{node|short}\x1b[33m:{branches} \x1b[37m- {desc|firstline} \x1b[32m({date|age}) \x1b[34;1m<{author|person}>\x1b[37m\n' | less -R"

###############################################################################
#
# Env
#
###############################################################################
export EDITOR=vi
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export WORKSPACE=~/workspace/genesys/iubuilder-workspace
export IUB_TEST_NODE_IMAGE=amazonlinux:2                    # required by mock

###############################################################################
#
#                               Key Bindings
#
###############################################################################
bindkey -e
bindkey "^?" backward-delete-char   # backspace


###############################################################################
#
#                               Functions
#
###############################################################################
# event functinos
precmd_functions=()
preexec_functions=()
chpwd_functions=()

# git branch functions
zgit_branch=""
zgit_update() {
    zgit_branch=`git branch --no-color 2>/dev/null | sed -n '/^*/ {s/^* //;p;}'`
    if [ -n "$zgit_branch" ]; then
        zgit_branch=" [$zgit_branch]"
    fi
}
zgit_checked_update() {
    [[ -z "$gitupdate" ]] && return
    unset gitupdate
    zgit_update
}
zgit_preexec_hook() {
    if [[ $2 == git\ * ]]; then
        gitupdate=1
    fi
}
zhg_branch=""
zhg_update() {
    zhg_branch=`hg branch 2>/dev/null`
    if [ -n "$zhg_branch" ]; then
        local zhg_bm=`hg bookmark 2>/dev/null | sed -n '/ \*/ {s/ \* //;s/ .*//;p;}'`
        zhg_branch=" [$zhg_branch:$zhg_bm]"
    fi
}
zhg_checked_update() {
    [[ -z "$hgupdate" ]] && return
    unset hgupdate
    zhg_update
}
zhg_preexec_hook() {
    if [[ $2 == hg\ * ]]; then
        hgupdate=1
    fi
}

if which git > /dev/null; then
    chpwd_functions+=(zgit_update)
    precmd_functions+=(zgit_checked_update)
    preexec_functions+=(zgit_preexec_hook)
fi
if which hg > /dev/null; then
    chpwd_functions+=(zhg_update)
    precmd_functions+=(zhg_checked_update)
    preexec_functions+=(zhg_preexec_hook)
fi

###############################################################################
#
#                            Prompt & Title
#
###############################################################################
# prompt
setprompt()
{
    case $TERM in
        xterm*|linux|screen|cons25)
            setopt promptsubst
            if [ -z $SSH_TTY ]; then
                PS1=%{%(!.$fg_bold[red].$fg_bold[green])%}%n\
%{$fg_bold[white]%}:%1~
            else
                PS1=%{%(!.$fg_bold[red].$fg_bold[green])%}%n\
%{$fg_bold[white]%}\@%{$fg_bold[yellow]%}%m%{$fg_bold[white]%}:%1~
            fi
            PS1=$PS1%{$fg_bold[cyan]%}'${zgit_branch}'
            PS1=$PS1%{$fg_bold[magenta]%}'${zhg_branch}'
            PS1=$PS1%{%(!.$fg_bold[red].$fg_bold[green])%}%(!.#.}\>)\ \
%{$fg_no_bold[white]%}
            PS2=\>
            RPROMPT=%d
            ;;
        *)
            PS1=%n%#\
            ;;
    esac
}
setprompt

# Terminal title
termtitle_command() {
    [ -t 1 ] || return
    print -Pn "\e]0;%n@%m:%~ $1\a"
}
termtitle_prompt() {
    [ -t 1 ] || return
    print -Pn "\e]0;%n@%m:%~\a"
}
case $TERM in
    xterm* | rxvt*)
        preexec_functions+=(termtitle_command)
        precmd_functions+=(termtitle_prompt)
        ;;
esac

###############################################################################
#
#                               Completition
#
###############################################################################
#hosts=(herd1-msk tiger dev2)
#zstyle '*' hosts $hosts
zstyle :compinstall filename '/home/$USER/.zshrc'
autoload -U colors && colors
autoload -U compinit
compinit

# compinstall for Amazone Web Services (aws)
[ -f /usr/local/bin/aws_zsh_completer.sh ] && source /usr/local/bin/aws_zsh_completer.sh

# compinstall for git
#[ -f ~/dotfiles/git-flow-completion.zsh ] && source ~/dotfiles/git-flow-completion.zsh

# XXX # init chef-vm
# XXX #eval "$(~/.chefvm/bin/chefvm init -)"
# XXX export PATH="$PATH:/Users/inc/.chefvm/bin"
# XXX source "/Users/inc/.chefvm/libexec/../completions/chefvm.zsh"
# XXX chefvm() {
# XXX   local command="$1"
# XXX   if [ "$#" -gt 0 ]; then
# XXX     shift
# XXX   fi
# XXX   case "$command" in
# XXX   shell)
# XXX     eval `chefvm "sh-$command" "$@"`;;
# XXX   *)
# XXX     command chefvm "$command" "$@";;
# XXX   esac
# XXX }
# XXX chefvm setup
# XXX
# XXX return 0
###############################################################################


# navigation
#setopt auto_cd
#cdpath=(. ~/work/devel)

## zen options for dumb terminals
#if [[ $TERM == "dumb" ]]; then
#    unalias ls
#    unsetopt zle
#fi
#
## psgrep
#psg() {
#    ps ax -ww | grep $* | grep -v grep
#}

#local WORDCHARS=""

autoload -U +X bashcompinit && bashcompinit
