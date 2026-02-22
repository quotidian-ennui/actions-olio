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
  uses: quotidian-ennui/actions-olio/dependabot-merge@main
  with:
    token: ${{ steps.app-token.outputs.token }}
    automerge_level: "semver-patch|semver-minor"
    change_filter: ".github/workflows/**"
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|          INPUT           |  TYPE  | REQUIRED |            DEFAULT             |                                     DESCRIPTION                                     |
|--------------------------|--------|----------|--------------------------------|-------------------------------------------------------------------------------------|
|     automerge_level      | string |  false   | `semver-patch"\|"semver-minor` | The semver level to allow automerge <br>up to (default semver-patch|semver-minor).  |
|      change_filter       | string |  false   |    `".github/workflows/**"`    |                 The filter to use finding source <br>file changes.                  |
|     filter_separator     | string |  false   |             `"\n"`             |             The separator to use when splitting <br>the change_filter.              |
|     merge_commentary     | string |  false   |                                |      Additional context to add to generated <br>comments. (defaults to blank)       |
|       merge_flags        | string |  false   |                                |                        additional merge_flags (e.g. --auto)                         |
|                          |        |          |                                |                                                                                     |
|    merge_max_attempts    | string |  false   |             `"2"`              |                           Max Merge Attempts (default 2)                            |
|                          |        |          |                                |                                                                                     |
| merge_retry_wait_seconds | string |  false   |             `"60"`             |                        Wait between each retry (default 60s)                        |
|                          |        |          |                                |                                                                                     |
|  merge_timeout_seconds   | string |  false   |             `"60"`             |                                Timeout (default 60s)                                |
|                          |        |          |                                |                                                                                     |
|          token           | string |  false   |    `"${{ github.token }}"`     |                The github token to use when <br>committing changes                  |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->
No outputs.
<!-- AUTO-DOC-OUTPUT:END -->

## Dependencies

It's a composite action that wraps the following actions:

- tj-actions/changed-files
- ./pr-or-issue-comment
