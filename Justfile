set positional-arguments := true
set unstable := true
set script-interpreter := ['/usr/bin/env', 'bash']

OS_NAME := `uname -o | tr '[:upper:]' '[:lower:]'`

# show recipes
[private]
@help:
    just --list --list-prefix "  "

[doc("Show next version as proposed by git-semver")]
[script]
next:
    #
    set -eo pipefail

    bumpMinor() {
      local version="$1"
      local majorVersion
      local minorVersion
      majorVersion=$(echo "$version " | sed -E 's#^([0-9]+)\.([0-9]+)\.([0-9]+).*$#\1#')
      minorVersion=$(echo "$version " | sed -E 's#^([0-9]+)\.([0-9]+)\.([0-9]+).*$#\2#')
      minorVersion=$((minorVersion + 1))
      echo "$majorVersion.$minorVersion.0"
    }

    bumpPatch() {
      local version="$1"
      local majorVersion
      local minorVersion
      local patchVersion

      majorVersion=$(echo "$version" | sed -E 's#^([0-9]+)\.([0-9]+)\.([0-9]+).*$#\1#')
      minorVersion=$(echo "$version" | sed -E 's#^([0-9]+)\.([0-9]+)\.([0-9]+).*$#\2#')
      patchVersion=$(echo "$version" | sed -E 's#^([0-9]+)\.([0-9]+)\.([0-9]+).*$#\3#')
      patchVersion=$((patchVersion + 1))
      echo "$majorVersion.$minorVersion.$patchVersion"
    }

    lastTag=$(git tag -l | sort -rV | head -n1)
    lastTaggedVersion=${lastTag#"v"}
    majorVersion=$(echo "$lastTaggedVersion" | sed -E 's#^([0-9]+)\.([0-9]+)\.([0-9]+).*$#\1#')
    semver_arg=""
    if [[ -z "$majorVersion" || "$majorVersion" = "0" ]]; then
      semver_arg="--stable=false"
    fi

    # git semver only works if this branch has the latest tag in its history.
    # FATA[0000] Latest tag is not on HEAD...
    computedVersion=$(git semver next "$semver_arg" 2>/dev/null || true)
    if [[ -n "$computedVersion" ]]; then
      if [[ "$computedVersion" == "$lastTaggedVersion" ]]; then
        bumpMinor "$lastTaggedVersion"
      else
        echo "$computedVersion"
      fi
    else
      closestAncestorTag=$(git describe --abbrev=0)
      closestTagVersion=${closestAncestorTag#"v"}
      bumpPatch "$closestTagVersion"
    fi

[doc('auto-generate tag and release')]
[script]
autotag push="localonly":
    #
    set -eo pipefail

    next="$(just next)"
    just release $next "{{ push }}"

# Since we have that refer to their peers(e.g. dependabot-action-merge refers
# to pr-or-issue-comment) we rewrite the @main to be @tag, commit, tag and
# switch back to @main
[doc('Tag & release')]
[script]
release tag push="localonly":
    #
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
    next=$(echo "{{ tag }}" | sed -E 's/^v?/v/')
    switch_reference "main" "$next"
    git tag "$next" -m"release $next"
    switch_reference "$next" "main"
    case "$push" in
      push|github|gh)
        git push --all
        git push --tags
        ;;
      *)
        ;;
    esac
