# If not running interactively, don't do anything
[ -z "$PS1" ] && return

HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
PROMPT_COMMAND='history -a'
HISTSIZE=100000
HISTFILESIZE=100000
shopt -s checkwinsize
shopt -s cmdhist
shopt -s cdspell

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
# We have color support; assume it's compliant with Ecma-48
# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
# a case would tend to support setf rather than setaf.)
color_prompt=yes
    else
color_prompt=
    fi
fi

function parse_git_branch {
git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

function git_unadded_new {
if git rev-parse --is-inside-work-tree &> /dev/null
then
if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]
then
echo ""
else
echo "[] "
fi
fi
}

function git_needs_commit {
if [[ "git rev-parse --is-inside-work-tree &> /dev/null)" != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
then
# Default: off - these are potentially expensive on big repositories
git diff-index --cached --quiet --ignore-submodules HEAD 2> /dev/null
(( $? && $? != 128 )) && echo "๏ "
fi
}

function git_modified_files {
        if [[ "git rev-parse --is-inside-work-tree &> /dev/null)" != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
        then
                # Default: off - these are potentially expensive on big repositories
                git diff --no-ext-diff --ignore-submodules --quiet --exit-code || echo "༅ "
        fi
}

if [ `id -u` = 0 ]; then
COLOUR="04;01;31m"
PATH_COLOUR="04;01;31m"
TIME_COLOUR="0;31m"
else
COLOUR="01;32m"
PATH_COLOUR="01;34m"
TIME_COLOUR="0;33m"
fi

BOLD_RED="01;31m"
BOLD_GREEN="01;32m"
BOLD_BLUE="01;34m"

PS1='\[\033[$TIME_COLOUR\]$(date +%H:%M)\[\033[00m\] ${debian_chroot:+($debian_chroot)}\[\033[$COLOUR\]\u@\h\[\033[00m\]: \[\033[01;$PATH_COLOUR\]\w\[\033[00m\]\[\033[01;35m\] $(parse_git_branch)\[\033[00m\]\[\033[$BOLD_RED\]$(git_unadded_new)\[\033[00m\]\[\033[$BOLD_GREEN\]$(git_needs_commit)\[\033[00m\]\[\033[$BOLD_BLUE\]$(git_modified_files)\[\033[00m\]\n$ '

unset color_prompt force_color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

if [ -x /usr/bin/dircolors ]; then
test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=always'

    alias grep='grep --color=always'
    alias fgrep='fgrep --color=always'
    alias egrep='egrep --color=always'
fi

alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'
alias less='less -R'
alias g='git'
alias phpunit='phpunit --colors'
alias py='python'
alias uctag="ctags -R --exclude='.git' ."
alias pg_start="launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
alias pg_stop="launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist"
alias clock='while sleep 1;do tput sc;tput cup 0 $(($(tput cols)-29));date;tput rc;done &'
alias hash='openssl rand -base64'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f ~/bashrc/.git-completion.bash ]; then
    source ~/bashrc/.git-completion.bash
fi

#. /etc/bash_completion.d/django_bash_completion
export PYTHONSTARTUP=~/.pythonrc
export DJANGO_COLORS="light"

# pip bash completion start
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip
# pip bash completion end

_ssh() 
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(grep '^Host' ~/.ssh/config | grep -v '[?*]' | cut -d ' ' -f 2-)

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F _ssh ssh

PATH=/usr/local/Cellar:$PATH
PATH=/usr/local/bin:$PATH
PATH=/usr/local/php5/bin:$PATH
PATH=$PATH:/usr/local/sbin
PATH=$PATH:$HOME/bin
PATH=/usr/local/opt/mysql-client/bin:$PATH

export WORKON_HOME=$HOME/Envs
export VIRTUALENVWRAPPER_HOOK_DIR="$WORKON_HOME"
export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python
export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib:$LD_LIBRARY_PATH
export PATH=/usr/lib/oracle/12.1/client64/bin:$PATH
export ORACLE_HOME=/usr/lib/oracle/12.1/client64/
export DYLD_LIBRARY_PATH=$ORACLE_HOME
export OCI_LIB=/usr/lib/oracle/12.1/client64/lib
export BASH_SILENCE_DEPRECATION_WARNING=1
source /usr/local/bin/virtualenvwrapper.sh

#PATH=/Applications/Postgres.app/Contents/MacOS/bin:$PATH

source ~/.django_bash_completion.sh


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/miloud.belarbi/google-cloud-sdk/path.bash.inc' ]; then . '/Users/miloud.belarbi/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/miloud.belarbi/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/miloud.belarbi/google-cloud-sdk/completion.bash.inc'; fi
