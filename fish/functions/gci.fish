function gci --wraps='git branch --sort=authordate | fxf | xargs git switch' --description 'alias gci=git branch --sort=authordate | fxf | xargs git switch'
  git branch --sort=authordate | fzf | xargs git switch
end
