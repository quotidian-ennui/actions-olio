# pr-trigger

Create a standardised `pr-trigger` repository dispatch event

## Why

Dependabot creates PRs. I have secrets. I don't put secrets into dependabot's context even though I should.

If that means nothing to you, then you don't need this action.

## Usage

- Requires you to have `contents:write` & `pull_requests:read` permissions attached to the token (depending on what you're doing).
- This uses the repo-dispatch action (so check its dependencies).

```action
jobs:
  dispatch:
    permissions:
      contents: write
      pull-requests: read
    runs-on: ubuntu-latest
    name: PR Trigger
    steps:
      - name: dispatch
        uses: quotidian-ennui/actions-olio/pr-trigger@main
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|   INPUT    |  TYPE  | REQUIRED |         DEFAULT         |                         DESCRIPTION                          |
|------------|--------|----------|-------------------------|--------------------------------------------------------------|
| event_type | string |  false   |     `"pr-trigger"`      |                The type of event to dispatch                 |
|   token    | string |  false   | `"${{ github.token }}"` | The github token to use when issuing the repository dispatch |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->
No outputs.
<!-- AUTO-DOC-OUTPUT:END -->