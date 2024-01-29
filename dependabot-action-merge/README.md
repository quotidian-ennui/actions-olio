# dependabot-action-merge

Merge dependabot updates to `.github/workflows`

## Why

If you have secrets, then you need to add all your secrets to the dependabot context. I don't, I just have secrets, which means that I use repository dispatch to trigger a workflow running in the right context. That means you can't use something like the fastify dependabot action...


## Usage

- Requires you to have `contents:write` & `pull_requests:write` permissions attached to the token (depending on what you're doing).
- If you are updating `./.github/workflows` then you probably need to have a github application.
- There's an implicit relationship between this action and the `./repo-dispatch` action. The `./repo-dispatch` action will create a `client_payload` that will be used by this action to determine what to do.
```action
- name: Checkout
  uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
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
```

## Dependencies

It's a composite action that wraps the following actions:

- tj-actions/changed-files
- ./pr-or-issue-comment
