# dismiss-dependabot-alert

Dismiss dependabot alerts based on some configuration

## Why

You want to keep a record of all the CVEs that you've dismissed _next to your source code_ because you were using snyk (other 3rd part tools are available) and now you've moved to github and dependabot security has started hassling you.

This action allows you have a configuration file that looks like this:

```yaml
# This is the 'CVE' or GHSA ID.
"CVE-2024-6763":
  # a list of packages
  packages:
    - org.eclipse.jetty:jetty-http
  # Can be one of: fix_started, inaccurate, no_bandwidth, not_used, tolerable_risk
  reason: inaccurate
  # Short comment for the dismissal reason
  comment: Transitive from wiremock which can't be upgraded to jetty-12 because of GAV changes and only used in tests
"CVE-2026-1002":
  packages:
    - io.vertx:vertx-core
  reason: not_used
  comment: Do not expose a StaticHandler externally.
"GHSA-72hv-8253-57qq":
  packages:
    - "com.fasterxml.jackson.core:jackson-core"
  reason: not_used
  comment: Do not use jackson async so unaffected
```
## Usage

- Requires you to have `contents:write` & `pull_requests:write`

```action
- name: Checkout
  uses: actions/checkout@v6.0.2
  with:
    persist-credentials: false
- name: "Create Token"
  uses: actions/create-github-app-token@v2.2.1
  id: app-token
  with:
    app-id: ${{ vars.WORKFLOW_UPDATE_APP_ID }}
    private-key: ${{ secrets.WORKFLOW_UPDATE_KEY }}
    owner: ${{ github.repository_owner }}
- name: Dismiss Dependabot Alerts
  id: dismiss_alert
  uses: quotidian-ennui/actions-olio/dismiss-dependabot-alert@main
  with:
    token: ${{ steps.app-token.outputs.token }}
    dismissal_file: "/path/to/file"
```

## Inputs

## Outputs

## Dependencies

It's a composite action that runs a script. It will require `yq`, `jq` and `gh`
