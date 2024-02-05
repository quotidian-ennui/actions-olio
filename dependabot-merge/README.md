# dependabot-action-merge

Merge dependabot updates to files that match a filter up to the corresponding update-type

## Why

If you have secrets, then you need to add all your secrets to the dependabot context. I don't, I just have secrets, which means that I use repository dispatch to trigger a workflow running in the right context. That means you can't use something like the fastify dependabot action...

It's used in this repository to merge dependabot updates to actions & workflows (see [.github/workflows/dependabot-merge.yml](../.github/workflows/dependabot-merge.yml)).

## Usage

- Requires you to have `contents:write` & `pull_requests:write` permissions attached to the token (depending on what you're doing).
- If you are updating `./.github/workflows` then you probably need to have a github application.
- There's an implicit relationship between this action and the [pr-trigger](../pr-trigger) action since we're expecting that to feed this.

```action
- name: Checkout
  uses: actions/checkout@v4.1.1
  with:
    ref: ${{ github.event.client_payload.base.ref }}
- name: "Create Token"
  uses: actions/create-github-app-token@v1.6.4
  id: app-token
  with:
    app-id: ${{ vars.WORKFLOW_UPDATE_APP_ID }}
    private-key: ${{ secrets.WORKFLOW_UPDATE_KEY }}
    owner: ${{ github.repository_owner }}
- name: Attempt Merge
  id: dependabot_merge
  uses: quotidian-ennui/actions-olio/dependabot-action-merge@main
  with:
    token: ${{ steps.app-token.outputs.token }}
    automerge_level: "semver-patch|semver-minor"
    change_filter: ".github/workflows/**"
```

## Dependencies

It's a composite action that wraps the following actions:

- tj-actions/changed-files
- ./pr-or-issue-comment
