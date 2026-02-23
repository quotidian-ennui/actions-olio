# repo-dispatch

Generates a repository dispatch event via _peter-evans/repository-dispatch_.

## Why

It essentially allows me to standardise on the client_payload for consistency across my repositories.

## Usage

- Bear in mind that issuing a repository dispatch via the action requires `contents:write` permissions.

```action
- name: dispatch
  id: dispatch
  uses: quotidian-ennui/actions-olio/repo-dispatch@main
  with:
    event_type: dependabot-build
    token: ${{ secrets.GITHUB_TOKEN }}
    sha: ${{ github.event.pull_request.head.sha || github.event.workflow_run.head_sha || github.sha }}
    ref: ${{ github.head_ref }}
    event_detail: |
      {
        "pull_request": "${{ steps.findpr.outputs.pr }}",
        "dependabot_automerge": "no",
        "dependabot_update_type": "version-update:semver-patch"
      }
```

Which results in a client_payload that looks something like:

```json
{
  "repository" : "quotidian-ennui/actions-olio",
  "base" : {
    "event_trigger" : "schedule | pull_request | push",
    "workflow" : "whatever your workflow is called",
    "workflow_run_url" : "https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}",
    "actor" : "The actor that triggered the event (dependabot[bot] for instance)",
    "ref" : "refs/heads/main",
    "sha": "SHA of the commit"
  },
  "detail": {
    "pull_request": "123",
    "dependabot_automerge": "no",
    "dependabot_update_type": "version-update:semver-patch"
  }
}

```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|    INPUT     |  TYPE  | REQUIRED |           DEFAULT            |                             DESCRIPTION                             |
|--------------|--------|----------|------------------------------|---------------------------------------------------------------------|
|    actor     | string |  false   |   `"${{ github.actor }}"`    | Override github.event.client_payload.base.actor with your own value |
| event_detail | string |  false   |                              |           Add data as github.event.client_payload.detail            |
|  event_type  | string |   true   |                              |            Used as the event_type in the dispatch event             |
|     ref      | string |  false   |                              |  Override github.event.client_payload.base.ref with your own value  |
|  repository  | string |  false   | `"${{ github.repository }}"` |         Override the default repository you want to send to         |
|     sha      | string |  false   |                              |  Override github.event.client_payload.base.sha with your own value  |
|    token     | string |  false   |   `"${{ github.token }}"`    |    Override the default token used to create the dispatch event.    |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->
No outputs.
<!-- AUTO-DOC-OUTPUT:END -->

## Notes

-  I explicitly pass the sha/actor/ref around because the processor of the downstream event has a context where the sha/ref/actor is based on 'last commit on the default branch' which can be be useless contextually.
    - If you have the SHA then you can almost always look up the associated PR (via _jwalton/gh-find-current-pr_).
    - If you have the ref then you can use this to checkout that branch in the checkout action
    - If you have the actor then you can use this to determine whether the event was triggered by a human or a bot.

> This is probably the most 'personal' action. While I'm not the type to break stuff for no reason, the format of the 'base' property of the client_payload is something that could easily change.

## Dependencies

- peter-evans/repository-dispatch