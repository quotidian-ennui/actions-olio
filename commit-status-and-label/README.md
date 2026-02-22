# commit-status-and-label

Updates a commit associated with a SHA with a commit status. If there is an associated PR with that commit then add a label to the PR that reflects the commit status

## Why

In this specific repository; how do you enable required checks (via branch protection) when you don't know _all the possible workflows_ that might run (i.e. if `docker-image-builder/*` doesn't change we won't run `test-docker-image-builder.yml`). This allows us to add a commit status; which then means that the 'context' can be marked as a required check in the branch protection rules.

## Usage

- Requires you to have at least `statuses:write`, `pull_requests:write` and perhaps `issues:write`, + `contents:write` permissions attached to the token.

```action
- name: Pending Status
  id: pending
  uses: quotidian-ennui/actions-olio/commit-status-and-label@main
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    sha: ${{ github.event.pull_request.head.sha }}
    state: "pending"
    # context: "Check"
    # prefix: "check_"
- name: Do the tests
  id: tests
  run: |
    echo "Doing the tests"
- name: Update Status
  id: pending
  uses: quotidian-ennui/actions-olio/commit-status-and-label@main
  if: success() || failure()
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    sha: ${{ github.event.pull_request.head.sha }}
    state: ${{ steps.tests.outcome }}
    # context: "Check"
    # prefix: "check_"
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|    INPUT     |  TYPE  | REQUIRED |         DEFAULT         |                                           DESCRIPTION                                           |
|--------------|--------|----------|-------------------------|-------------------------------------------------------------------------------------------------|
|   context    | string |  false   |        `"Check"`        |                     The context for the commit status <br>(default: Check)                      |
| label_prefix | string |  false   |       `"check_"`        |              The prefix for the label (adds a label if set, default is 'check_')                |
| pull_request | string |  false   |                         | The pull request number, if not <br>specified we'll try to find it <br>based on the commit SHA  |
|     sha      | string |   true   |                         |                                         The commit SHA                                          |
|    state     | string |   true   |                         |           The state for the commit status <br>(error | pending | failure | success)             |
|    token     | string |  false   | `"${{ github.token }}"` |                        The GitHub token to use for <br>authentication.                          |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->
No outputs.
<!-- AUTO-DOC-OUTPUT:END -->

## Notes

- Of course it's up to you to assign pretty colours to your labels.
- According to the documentation you may only add 1k states to a given commit sha. Bear that in mind if you're basically adding a commit status to the same SHA over and over.
- There is a timing issue if you have multiple triggered workflows that all use the same _context_ for the commit status. The context will transition to _success_ before all the actual checks have executed. You don't want to have automerge enabled if that's the case.
  - It happens in this project; if dependabot 'updates `actions/checkout`' then the 3 test- workflows that trigger on a PR will all update the same 'check' context. 'test-docker-image.yml' will always take the longest but the commit status has transitioned to `success` before it finishes.
- In the example above I'm passing in the 'outcome' from the tests job which is actually 'success | failure | skipped | cancelled'. Success and failure are valid commit statuses; skipped & cancelled are mapped to be 'error'.
- There's use of `actions/github-script`; I was going to use `gh` but I had permissions issues and though I don't enjoy doing javascript, I do know enough to get into trouble. In this instance I would have much preferred to use `bash` everywhere.

## Dependencies

It's a composite action that wraps the following actions:

- jwalton/gh-find-current-pr
- actions/github-script
- (octodemo-resources/github-commit-status) - I'm unsure as to whether to trust something called octodemo-resources so it's a github-script.
