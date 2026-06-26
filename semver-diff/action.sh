#!/usr/bin/env bash
# Inspiration from : https://github.com/fsaintjacques/semver-tool/blob/master/src/semver
#
set -eo pipefail

NAT='0|[1-9][0-9]*'
ALPHANUM='[0-9]*[A-Za-z-][0-9A-Za-z-]*'
IDENT="$NAT|$ALPHANUM"
FIELD='[0-9A-Za-z-]+'

SEMVER_REGEX="\
^[vV]?\
($NAT)\\.($NAT)\\.($NAT)\
(\\-(${IDENT})(\\.(${IDENT}))*)?\
(\\+${FIELD}(\\.${FIELD})*)?$"

readonly MSG_MAJOR=${TYPE_MAJOR:-feat!}
readonly MSG_MINOR=${TYPE_MINOR:-feat}
readonly MSG_PATCH=${TYPE_PATCH:-fix}

error() {
  echo -e ":error:$1"
  exit 1
}

__parse_version() {
  local version=$1
  if [[ "$version" =~ $SEMVER_REGEX ]]; then
    local major=${BASH_REMATCH[1]}
    local minor=${BASH_REMATCH[2]}
    local patch=${BASH_REMATCH[3]}
    local prere=${BASH_REMATCH[4]}
    local build=${BASH_REMATCH[8]}
    eval "$2=(\"$major\" \"$minor\" \"$patch\" \"$prere\" \"$build\")"
  else
    error "version $version does not match the semver scheme 'X.Y.Z(-PRERELEASE)(+BUILD)'"
  fi
}

__diff() {
  __parse_version "$1" v1_parts
  # shellcheck disable=SC2154
  local v1_major="${v1_parts[0]}"
  local v1_minor="${v1_parts[1]}"
  local v1_patch="${v1_parts[2]}"
  local v1_prere="${v1_parts[3]}"
  local v1_build="${v1_parts[4]}"

  __parse_version "$2" v2_parts
  # shellcheck disable=SC2154
  local v2_major="${v2_parts[0]}"
  local v2_minor="${v2_parts[1]}"
  local v2_patch="${v2_parts[2]}"
  local v2_prere="${v2_parts[3]}"
  local v2_build="${v2_parts[4]}"

  if [[ "${v1_major}" != "${v2_major}" ]]; then
    echo "major"
  elif [[ "${v1_minor}" != "${v2_minor}" ]]; then
    echo "minor"
  elif [[ "${v1_patch}" != "${v2_patch}" ]]; then
    echo "patch"
  elif [[ "${v1_prere}" != "${v2_prere}" ]]; then
    echo "prerelease"
  elif [[ "${v1_build}" != "${v2_build}" ]]; then
    echo "build"
  else
    echo "same"
  fi
}

__commit_type() {
  local diff="$1"
  if [[ "$diff" == "major" ]]; then
    echo "$MSG_MAJOR"
  elif [[ "$diff" == "minor" ]]; then
    echo "$MSG_MINOR"
  elif [[ "$diff" == "patch" ]]; then
    echo "$MSG_PATCH"
  else
    echo ""
  fi
}

diff=$(__diff "$SEMVER_TAG_ONE" "$SEMVER_TAG_TWO")
commit_type="$(__commit_type "$diff")"
if [[ -n "$GITHUB_OUTPUT" ]]; then
  echo "diff=$diff" | tee -a "$GITHUB_OUTPUT"
  echo "commit_type=$commit_type" | tee -a "$GITHUB_OUTPUT"
else
  echo "$diff == $commit_type"
fi
