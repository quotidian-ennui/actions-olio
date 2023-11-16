set positional-arguments := true
OS_NAME:=`uname -o | tr '[:upper:]' '[:lower:]'`

# show recipes
[private]
@help:
  just --list --list-prefix "  "

# pin github action to versions to hash (just pin repo-dispatch/action.yml)
[no-cd]
pin *args: check_npm_env
  #!/usr/bin/env bash
  set -eo pipefail
  if [[ -z "$1" ]]; then echo "missing file to pin; abort"; exit 1; fi
  npx pin-github-action -i "$1"
  sed -i -e "s|pin@||" "$1"

[private]
[no-cd]
[no-exit-message]
check_npm_env:
  #!/usr/bin/env bash
  set -eo pipefail

  if [[ "{{ OS_NAME }}" == "msys" ]]; then echo "npm/npx on windows git+bash, are you mad?; abort"; exit 1; fi
  which npm >/dev/null 2>&1 || { echo "npm not found; abort"; exit 1; }
  which npx >/dev/null 2>&1 || { echo "npx not found; abort"; exit 1; }
