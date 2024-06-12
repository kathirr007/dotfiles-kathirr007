# Prombt line display

# Default one
# PS1='\[\033]0;$TITLEPREFIX:${PWD//[^[:ascii:]]/?}\007\]\n\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]\n$'
PS1='\[\033]0;$TITLEPREFIX:${PWD//[^[:ascii:]]/?}\007\]\n\[\033[32m\]\u\e[1;37m\]-@-\[\033[0m\]\[\033[1;33m\]\W\[\033[1;36m\]`__git_ps1`\[\033[0m\]\n└─$\[\033[0m\]'

# PS1='\[\033[0;32m\]\[\033[0m\033[0;32m\]\u\[\033[0;36m\] @ \[\033[0;36m\]\h \w\[\033[0;32m\]$(__git_ps1)\n\[\033[0;32m\]└─\[\033[0m\033[0;32m\] \$\[\033[0m\033[0;32m\] ▶\[\033[0m\] '
# PS1='\[\033[0;32m\]\[\033[0m\033[0;32m\]\u\[\033[0;36m\] @ \w\[\033[0;32m\]\n$(git branch 2>/dev/null | grep "^*" | colrm 1 2)\[\033[0;32m\]└─\[\033[0m\033[0;32m\] \$\[\033[0m\033[0;32m\]\[\033[0m\] '

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

# export PS1="\[\033[0;36m\]\W\[\033[0;32m\]\`parse_git_branch\`\\[\033[0;32m\]\n└─\[\033[0m\033[0;32m\]\[\033[0m\] "
# export PS1="\[\033[1;92m\]@-\[\033[0m\]\[\033[33m\]\W\[\033[1;36m\]`__git_ps1`\[\033[0m\]\n\[\033[1;37m\]└─$\[\033[0m\] "



# Path to the bash it configuration
export BASH_IT="/c/Users/Editplace/.bash_it"

# Lock and Load a custom theme file
# location /.bash_it/themes/
export BASH_IT_THEME='clean'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
# export BASH_IT_REMOTE='bash-it'

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Set Xterm/screen/Tmux title with only a short hostname.
# Uncomment this (or set SHORT_HOSTNAME to something else),
# Will otherwise fall back on $HOSTNAME.
#export SHORT_HOSTNAME=$(hostname -s)

# Set Xterm/screen/Tmux title with only a short username.
# Uncomment this (or set SHORT_USER to something else),
# Will otherwise fall back on $USER.
#export SHORT_USER=${USER:0:8}

# Set Xterm/screen/Tmux title with shortened command and directory.
# Uncomment this to set.
#export SHORT_TERM_LINE=true

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#export VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
# export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Load Bash It
# source "$BASH_IT"/bash_it.sh
#
#Colorize bash terminal
LS_COLORS="ow=01;36;40" && export LS_COLORS

export TERM=xterm-256color

zeal-docs-fix() {
    pushd "$HOME/.local/share/Zeal/Zeal/docsets" >/dev/null || return
    find . -iname 'react-main*.js' -exec rm '{}' \;
    popd >/dev/null || exit
}

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
alias yst='yarn start'
alias nrd='npm run dev'
alias nrs='npm run serve'
alias pd='pnpm dev'
alias ps='pnpm serve'
alias pst='pnpm start'
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
# Generate prisma for Brightreturn
alias pnppgbr='pnppg ./apps/brightreturn/prisma/schema.prisma'
# Generate prisma for Brighdrive
alias pnppgbdr='pnppg ./apps/brightdrive/prisma/schema.prisma'
# Generate prisma for Brighdesk
alias pnppgbdsk='pnppg ./apps/brightdesk/prisma/schema.prisma'
# Generate prisma for all BR services
alias pnppgall='pnppg ./apps/brightreturn/prisma/schema.prisma && pnppg ./apps/brightdrive/prisma/schema.prisma && pnppg ./apps/brightdesk/prisma/schema.prisma'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
