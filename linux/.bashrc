# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${BRANCH}${STAT}]"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

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

if [ "$color_prompt" = yes ]; then

    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]-@-\[\033[01;34m\]\W\[\033[00m\]\$(__git_ps1)\n\[$(tput bold)\]\[$(tput setaf 5)\]└─$\[$(tput sgr0)\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

source /etc/bash_completion.d/git-prompt
PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u\[\033[00m\]-@-\[$(tput setaf 3)\]\[$(tput bold)\]\W\[$(tput sgr0)\]\[$(tput setaf 4)\]\[$(tput bold)\]\$(__git_ps1)\[$(tput sgr0)\]\n\[$(tput bold)\]\[$(tput setaf 5)\]└─$\[$(tput sgr0)\]"

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Aliases
alias delRenCurr="find ./*.mp4 -type f -not -name '*FFB*.mp4' -delete ; find ./ -depth -name '*_FFB.mp4*' -execdir bash -c 'mv -i '$1' '${1//_FFB.mp4/.mp4}' bash {} \;"

alias g='git'
alias gst='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gpl='git pull'
alias gpod='git pull origin develop'
alias gup='git pull --rebase'
alias gps='git push'
alias gpsuo='git push --set-upstream origin'
alias gd='git diff'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcmsg='git commit -m'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcm='git checkout master'
alias gr='git remote'
alias grv='git remote -v'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grset='git remote set-url'
alias grup='git remote update'
alias grbi='git rebase -i'
alias grbc='git rebase --continue'
alias grba='git rebase --abort'
alias gb='git branch'
alias gba='git branch -a'
alias gcount='git shortlog -sn'
alias gcl='git config --list'
alias gcp='git cherry-pick'
alias glg='git log --stat --max-count=10'
alias glgg='git log --graph --max-count=10'
alias glgga='git log --graph --decorate --all'
alias glo='git log --oneline --decorate --color'
alias glog='git log --oneline --decorate --color --graph'
alias gss='git status -s'
alias ga='git add'
alias gaa='git add .'
alias gam='git commit -a -m'
alias gau='git commit -u'
alias gm='git merge'
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias gclean='git reset --hard && git clean -dfx'
alias gwc='git whatchanged -p --abbrev-commit --pretty=medium'
# Start browser sync server in current directory
alias bsss="browser-sync start -s --no-open"
# Start browser sync server in current directory and watch all files
alias bsssw="browser-sync start -s -f . --no-open"
# Start browser sync server in current directory in given port number and watch specific files
alias bsssp='_bsssp(){ browser-sync start --server --files "**/*.css, **/*.html, **/*.js, !node_modules/**/*" --port "$1" --no-open;}; _bsssp'
# Start browser sync server in current directory with directory listings in given port number and watch specific files
alias bssspd='_bssspd(){ browser-sync start --server --files "**/*.css, **/*.html, **/*.js, !node_modules/**/*" --directory --port "$1" --no-open;}; _bssspd'
alias mkcd='_mkcd(){ mkdir "$1"; cd "$1";}; _mkcd'
alias npdp='npx prisma db push'
alias nps='npx prisma studio'
alias npg='npx prisma generate'
alias yd='yarn dev'
alias ys='yarn serve'
alias nrd='npm run dev'
alias nrs='npm run serve'
alias pd='pnpm dev'
alias ps='pnpm serve'
alias elint='_elint(){ "$1";}; _elint'
# Start nest server for the given project
alias nssp='_nssp(){ nest start "$1" --watch;}; _nssp'
alias gcmssg='_gcmssg(){ git commit -m "$1" "$2";}; _gcmssg'
# Start prisma migrate for the given schema
alias pnppm='_pnppm(){ pnpx prisma migrate dev --name init --schema="$1";}; _pnppm'
# Start prisma generate for the given schema
alias pnppg='_pnppg(){ pnpx prisma generate --schema="$1";}; _pnppg'
# Start prisma studio for the given schema
alias pnpps='_pnpps(){ pnpx prisma studio --schema="$1";}; _pnpps'
# Start prisma db push for the given schema
alias pnpdp='_pnpdp(){ pnpx prisma db push --schema="$1";}; _pnpdp'
# Generate prisma for all BR services
alias pnppgall='pnppg ./apps/brightreturn/prisma/schema.prisma && pnppg ./apps/brightdrive/prisma/schema.prisma && pnppg ./apps/brightdesk/prisma/schema.prisma'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# pnpm
export PNPM_HOME="/home/kathirr007/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end