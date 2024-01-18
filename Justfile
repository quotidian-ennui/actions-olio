set positional-arguments := true
OS_NAME:=`uname -o | tr '[:upper:]' '[:lower:]'`

# show recipes
[private]
@help:
  just --list --list-prefix "  "

# Tag & release
release push="localonly":
  #!/usr/bin/env bash
  set -eo pipefail

  push="{{ push }}"
  next=$(git semver next --stable=false)
  git tag "v$next"
  case "$push" in
    push|github)
      git push --all
      git push --tags
      ;;
    *)
      ;;
  esac

