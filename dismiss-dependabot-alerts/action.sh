#!/usr/bin/env bash
#
set -eo pipefail

export GH_PAGER="cat"

GH_REST_API_VERSION="X-GitHub-Api-Version: 2022-11-28"
GH_ACCEPT="Accept: application/vnd.github+json"
REASON_LIST="fix_started|inaccurate|no_bandwidth|not_used|tolerable_risk"
VULNS_JSON_REST_JQ='
  .[] |
  {
    "CVE": .security_advisory.cve_id,
    "GHSA": .security_advisory.ghsa_id,
    "alert_id": .number,
    "package" : .dependency.package.name,
    "severity": .security_advisory.severity
  }
'

gh_api() {
  gh api -H "$GH_REST_API_VERSION" -H "$GH_ACCEPT" "$@"
}

open_vulns_via_rest() {
  gh_api "repos/:owner/:repo/dependabot/alerts?state=open" | jq -c "$VULNS_JSON_REST_JQ"
}

reason_is_valid() {
  local reason="$1"
  if [[ ! "${reason}" =~ ^$REASON_LIST$ ]]; then
    return 1
  fi
  return 0
}

dismiss_alert() {
  local dismiss_entry="$1"
  local open_vulns="$2"
  local packages=()
  local vuln_id=""
  local comment=""
  local reason=""
  local gh_params=()
  local cve_id=""
  local ghsa_id=""
  local affected_package=""
  local alert_id=""

  vuln_id=$(echo "$dismiss_entry" | jq -r ".key")
  echo "- $vuln_id" >>"$GITHUB_STEP_SUMMARY"
  mapfile -t packages < <(echo "$dismiss_entry" | jq -r '.value.packages | .[]')
  comment="$(echo "$dismiss_entry" | jq -r ".value.comment")"
  reason="$(echo "$dismiss_entry" | jq -r ".value.reason")"
  if reason_is_valid "$reason"; then
    while read -r vuln; do
      cve_id="$(echo "$vuln" | jq -r ".CVE")"
      ghsa_id="$(echo "$vuln" | jq -r ".GHSA")"
      affected_package="$(echo "$vuln" | jq -r ".package")"
      alert_id="$(echo "$vuln" | jq -r ".alert_id")"
      # If the key matches either the CVE number or the GHSA ID then we check
      # the packages to see if we should ignore.
      if [[ "$vuln_id" == "$cve_id" || $vuln_id == "$ghsa_id" ]]; then
        # it's an intentional substring search.
        #shellcheck disable=SC2076
        if [[ " ${packages[*]} " =~ " ${affected_package} " ]]; then
          echo "  - Dismissing alert $alert_id as $reason" >>"$GITHUB_STEP_SUMMARY"
          gh_params=()
          gh_params+=("-f" "state=dismissed")
          gh_params+=("-f" "dismissed_reason=$reason")
          gh_params+=("-f" "dismissed_comment=$comment")
          gh_api --method PATCH "/repos/:owner/:repo/dependabot/alerts/$alert_id" "${gh_params[@]}"
        fi
      fi
    done <<<"$open_vulns"
  else
    echo "- $vuln_id does not contain a valid reason [$reason]; skip" >>"$GITHUB_STEP_SUMMARY"
  fi
}

dismiss_each_alert() {
  local alert_file="$1"
  local open_vulns="$2"

  cat "$alert_file" | yq -p yaml -o json | jq -c "to_entries | .[]" | while read -r entry; do
    dismiss_alert "$entry" "$open_vulns"
  done
}

GIT_ROOT="$(git rev-parse --show-toplevel)"
IGNORE_FILE="${ALERT_DISMISSAL_FILE:-$GIT_ROOT/.github/dismiss-alerts.yml}"

echo -e "# Dismiss Dependabot Alerts\n" >>"$GITHUB_STEP_SUMMARY"
if [[ -f "$IGNORE_FILE" ]]; then
  OPEN_VULNS="$(open_vulns_via_rest)"
  if [[ -n "$OPEN_VULNS" ]]; then
    dismiss_each_alert "$IGNORE_FILE" "$OPEN_VULNS"
  else
    echo "- No Open Alerts" >>"$GITHUB_STEP_SUMMARY"
  fi
else
  echo "> No Configuration file $IGNORE_FILE" >>"$GITHUB_STEP_SUMMARY"
fi
