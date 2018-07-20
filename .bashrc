# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if [ -f ~/.bashrc_ge ]; then
  . ~/.bashrc_ge
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias cdgit='cd ~/Documents/code/'
alias lsa='ls -a'
alias gerp='grep'
export LESS="-R -F -X $LESS"
export LESSOPEN='|~/.lessfilter %s'

if [ ! -e ~/tmp ]; then
  mkdir ~/tmp
fi

function gits(){
  git status
}
function gitl(){
  git log
}
function gitfetch(){
  git pull
  git fetch
  prune=$(git remote prune origin)
  prune_return=$?
  echo ${prune}
  if [[ ! ${prune_return} ]]; then
    return
  fi
  items=$(echo "${prune}" | grep '[pruned]' | awk '{print $3}' | awk -F '/' '{print $2}')
  for i in ${items}; do
    echo "DELETING LOCAL BRANCH ${i}"
    git branch -D ${i}
  done
} # end function gitfetch

function gitpush(){
  git push origin $(git branch | grep '*' | awk '{print $2}')
} # end function gitpush

function gitpull(){
  git pull origin $(git branch | grep '*' | awk '{print $2}')
} # end function gitpull

function gitcheckoutb(){
  # $1 = string branch
  branch=$1
  if [[ "$branch" == '' ]]; then
    branch=$(git rev-parse --abbrev-ref HEAD)
  fi
  git checkout -b $branch
  if [[ $? -eq 128 ]]; then
    git checkout $branch
  fi
  git pull origin $branch
  gitfetch
} # end function gitcheckoutb

function gitcommit(){
  # $1 = commit message
  gitaddf
  git commit -a -m "$1"
}

function gitcommitp(){
  # $1 = commit message
  gitcommit "$1"
  gitpush
}

function gitaddf(){
  git add -Af
}

function gitrmtag(){
  # $1 = string tag to delete
  git tag -d $1
  git push origin :refs/tags/$1
} # end function gitrmtag

function gittag(){
  # $1 tag
  # $2 comment
  git tag -a $1 -m "$2"
}

function gitcheckoutm() {
  git checkout master
  gitfetch
} # end function gitcheckoutmaster

function markdownelinks() {
  # $1 = path to markdown file
  # $2 = converter (pandoc, markdown_py
  converter=$2
  if [ "$converter" == '' ]; then
    converter='markdown_py'
  fi
  echo "<html><body>$($converter $1)</body></html>" | elinks
}

function sshportforward() {
  # $1 targetip
  # $2 proxyip
  # $3 localport
  # $4 remoteport
  # $5 ssh options
  if [[ "$*" =~ .*--help.* || "$*" =~ .*-h.* ]]; then
    cat <<-'EOF'
$1 targetip
$2 proxyip
$3 localport
$4 remoteport
$5 sshoptions
EOF
    return
  fi
  ssh $5 $2 -fNCL $3:$1:$4
}
function sshportforwardkill() {
  # $1 port
  ps -ef | grep -E 'ssh.*L' | grep "$1" | awk '{print $2}'| xargs kill
}
shopt -s cdspell
