# default-updatecli

Execute updatecli with default configuration

## Why

> This is an action that's very personal since the defaults refer to an explicit github app that I've created so that I can make modifications to github actions.

## Usage

- Requires you to have `contents:write` & `pull_requests:write` permissions attached to the token (depending on what you're doing).
- If you are updating `./.github/workflows` then you probably need to have a github application.

```action
- name: "Create Token"
  uses: actions/create-github-app-token@86576b355dd19da0519e0bdb63d8edb5bcf76a25 # v1.7.0
  id: app-token
  with:
    app-id: ${{ vars.WORKFLOW_UPDATE_APP_ID }}
    private-key: ${{ secrets.WORKFLOW_UPDATE_KEY }}
    owner: ${{ github.repository_owner }}
- name: updatecli
  uses: ./default-updatecli
  with:
    token: ${{ steps.app-token.outputs.token }}
    github_user: qe-repo-updater[bot]
    github_email: 152897211+qe-repo-updater[bot]@users.noreply.github.com
```

## Dependencies

It's a composite action that wraps the following actions:

- updatecli/updatecli-action
