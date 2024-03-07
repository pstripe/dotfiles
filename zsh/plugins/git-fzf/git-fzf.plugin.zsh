function git-delete-branches() {
  # FIXME: cancel does not work
  git branch |
    rg --invert-match '\*' |
    cut -c 3- |
    fzf --multi --preview="git log {} --" |
    xargs --no-run-if-empty git branch --delete --force
}

function git-checkout-branch() {
  local branch
  branch=$(git branch | cut -c 3- | fzf)

  if [ -n "$branch" ]; then
    git checkout $branch
  fi
}

alias gcfzf=git-checkout-branch
