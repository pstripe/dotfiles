if ! command -q go
  return
end

set -x GOPATH (go env GOPATH)
fish_add_path "$GOPATH/bin"
