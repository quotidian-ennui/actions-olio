set positional-arguments := true
OS_NAME:=`uname -o | tr '[:upper:]' '[:lower:]'`

# show recipes
[private]
@help:
  just --list --list-prefix "  "

# Since we have that refer to their peers(e.g. dependabot-action-merge refers
# to pr-or-issue-comment) we rewrite the @main to be @tag, commit, tag and
# switch back to @main
# Tag & release
release push="localonly":
  #!/usr/bin/env bash
  set -eo pipefail

  switch_reference() {
    local from="$1"
    local to="$2"
    self_referencing=$(find . -name "*.yml" -exec grep -il "uses:.*olio.*" {} \;)
    for file in $self_referencing; do
      echo "pin $file to $to"
      sed -Ei "s#(quotidian-ennui\/actions-olio\/[^@]+)@$from#\1@${to}#g" "$file"
    done
    git commit -a -m "chore(release): update action references to ${to}"
  }

  git diff --quiet || (echo "--> git is dirty" && exit 1)
  push="{{ push }}"
  next="v$(git semver next --stable=false)"
  switch_reference "main" "$next"
  git tag "$next"
  switch_reference "$next" "main"
  case "$push" in
    push|github)
      git push --all
      git push --tags
      ;;
    *)
      ;;
  esac

