set positional-arguments
set unstable
set script-interpreter := ['/usr/bin/env', 'bash']

DEPENDABOT_FILE := justfile_directory() / ".github/dependabot.yml"
ROOT_README := justfile_directory() / "README.md"

# show recipes
[private]
@help:
    just --list --list-prefix "  "

[doc("Show proposed release notes")]
[group("doc")]
[group("release")]
[script]
changelog *args="--unreleased":
    #
    set -eo pipefail
    top=$(git rev-parse --show-toplevel)
    pushd "$top" >/dev/null
    if [[ -s "cliff.toml" ]]; then
      git cliff "$@"
    else
      git cliff --config "~/.config/git-cliff/default-cliff.toml" "$@"
    fi
    popd >/dev/null

[doc("Show next version as proposed by git-semver")]
[group("release")]
[script]
next:
    #shellcheck disable=SC2148
    set -eo pipefail

    VERSION_REGEXP_MAJOR='s#^([0-9]+)\.([0-9]+)\.([0-9]+).*$#\1#'
    VERSION_REGEXP_MINOR='s#^([0-9]+)\.([0-9]+)\.([0-9]+).*$#\2#'
    VERSION_REGEXP_PATCH='s#^([0-9]+)\.([0-9]+)\.([0-9]+).*$#\3#'
    bumpMinor() {
      local version="$1"
      local majorVersion
      local minorVersion
      majorVersion=$(echo "$version " | sed -E "$VERSION_REGEXP_MAJOR")
      minorVersion=$(echo "$version " | sed -E "$VERSION_REGEXP_MINOR")
      minorVersion=$((minorVersion + 1))
      echo "$majorVersion.$minorVersion.0"
    }

    bumpPatch() {
      local version="$1"
      local majorVersion
      local minorVersion
      local patchVersion

      majorVersion=$(echo "$version" | sed -E "$VERSION_REGEXP_MAJOR")
      minorVersion=$(echo "$version" | sed -E "$VERSION_REGEXP_MINOR")
      patchVersion=$(echo "$version" | sed -E "$VERSION_REGEXP_PATCH")
      patchVersion=$((patchVersion + 1))
      echo "$majorVersion.$minorVersion.$patchVersion"
    }

    lastTag=$(git tag -l | sort -rV | head -n1)
    lastTaggedVersion=${lastTag#"v"}
    majorVersion=$(echo "$lastTaggedVersion" | sed -E "$VERSION_REGEXP_MAJOR")
    semver_arg=""
    if [[ -z "$majorVersion" || "$majorVersion" = "0" ]]; then
      semver_arg="--stable=false"
    fi

    # git semver only works if this branch has the latest tag in its history.
    # FATA[0000] Latest tag is not on HEAD...
    computedVersion=$(git semver next "$semver_arg" 2>/dev/null || true)
    if [[ -n "$computedVersion" ]]; then
      if [[ "$computedVersion" == "$lastTaggedVersion" ]]; then
        bumpPatch "$lastTaggedVersion"
      else
        echo "$computedVersion"
      fi
    else
      closestAncestorTag=$(git describe --abbrev=0)
      closestTagVersion=${closestAncestorTag#"v"}
      bumpPatch "$closestTagVersion"
    fi

[doc('run autodoc')]
[group("doc")]
[script]
autodoc:
    #shellcheck disable=SC2148
    set -eo pipefail

    mapfile -t action_files < <(find "." -type f -name "action.yml")
    for action in "${action_files[@]}"; do
      readme="$(dirname "$action")/README.md"
      auto-doc --colMaxWords 100 --filename "$action" --output "$readme"
    done

[doc('auto-generate tag and release')]
[group("release")]
[script]
please-release push="localonly":
    #shellcheck disable=SC2148
    set -eo pipefail

    next="$(just next)"
    just release "$next" "{{ push }}"

alias autotag := please-release

# Since we have that refer to their peers(e.g. dependabot-action-merge refers
# to pr-or-issue-comment) we rewrite the @main to be @tag, commit, tag and
# switch back to @main
[doc('Tag & release')]
[group("release")]
[script]
release tag push="localonly":
    #shellcheck disable=SC2148
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

    check_uptodate() {
      default_branch=$(git remote show "origin" | grep 'HEAD branch' | cut -d' ' -f5)
      remote_hash=$(git ls-remote origin "refs/heads/$default_branch" | cut -f1)
      local_hash=$(git rev-parse "$(git branch --show-current)")
      if [[ "$remote_hash" != "$local_hash" ]]; then
        echo "⚠️ Remote hash differs, are we up to date?"
        exit 1
      fi
    }

    git diff --quiet || (echo "⚠️ git is dirty" && exit 1)
    check_uptodate
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

alias update-dependabot := dependabot

[doc('Update dependabot configuration')]
[group("helpers")]
[script]
dependabot:
    #shellcheck disable=SC2148
    set -eo pipefail

    readonly YQ_UPDATE_SCRIPT='
      (
        .updates[]
        | select(.["package-ecosystem"] == "github-actions" and .["commit-message"].prefix == "deps: ")
        | .directories
      ) = (strenv(ACTION_DIRS) | split("\n") | map(select(length > 0)))
    '
    readonly DEPENDABOT_FILE="{{ DEPENDABOT_FILE }}"

    mapfile -t action_dirs < <(find . -type f -name "action.yml" -printf '%h\n' | sed -E 's#^\./##' | sort -u)
    if [[ "${#action_dirs[@]}" -gt 0 ]]; then
      action_dirs_nl=$(printf '%s\n' "${action_dirs[@]}")
      temp_file=$(mktemp --tmpdir dependabot.XXXXXX.yml)
      trap 'rm -f "$temp_file"' EXIT
      ACTION_DIRS="$action_dirs_nl" yq eval "$YQ_UPDATE_SCRIPT" "$DEPENDABOT_FILE" > "$temp_file"
      if [[ -s "$temp_file" ]]; then
        mv "$temp_file" "$DEPENDABOT_FILE"
      fi
      trap - EXIT
    fi

[doc('Update top-level README nested action links')]
[group("doc")]
[script]
readme:
    #shellcheck disable=SC2148
    set -eo pipefail

    readonly ROOT_README="{{ ROOT_README }}"
    readonly START_MARKER='<!-- README_GENERATOR_START -->'
    readonly END_MARKER='<!-- README_GENERATOR_END -->'
    readonly AWK_UPDATE_SCRIPT='
        $0 == start {
          print
          if (length(content) > 0) {
            printf "%s", content
          }
          in_block = 1
          next
        }
        $0 == end {
          in_block = 0
          print
          next
        }
        !in_block { print }
    '
    mapfile -t nested_readmes < <(find . -mindepth 2 -maxdepth 2 -type f -name "README.md" -printf '%P\n' | sort)

    if [[ "${#nested_readmes[@]}" -gt 0 ]]; then
      bullets=""
      for readme_path in "${nested_readmes[@]}"; do
        item_name="${readme_path%/README.md}"
        item_name="${item_name##*/}"
        bullets+="- [${item_name}](./${readme_path})"$'\n'
      done

      temp_file=$(mktemp --tmpdir readme.XXXXXX.md)
      trap 'rm -f "$temp_file"' EXIT

      awk -v start="$START_MARKER" -v end="$END_MARKER" -v content="$bullets" \
        "$AWK_UPDATE_SCRIPT" "$ROOT_README" > "$temp_file"

      if [[ -s "$temp_file" ]]; then
        mv "$temp_file" "$ROOT_README"
      fi
      trap - EXIT
    fi

[doc('readme & dependabot')]
[group("helpers")]
pre-commit: readme dependabot
