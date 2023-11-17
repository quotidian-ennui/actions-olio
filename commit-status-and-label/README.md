# commit-status-and-label

Updates a commit associated with a SHA with a commit status. If there is an associated PR with that commit then add a label to the PR that reflects the commit status

## Why

In this specific repository; how do you enable required checks (via branch protection) when you don't know _all the possible workflows_ that might run (i.e. if `docker-image-builder/*` doesn't change we won't run `test-docker-image-builder.yml`). This allows us to add a commit status; which then means that the 'context' can be marked as a required check in the branch protection rules.

## Usage

- Requires you to have at least `statuses:write`, `issues:write`, `pull_requests:write` and probably `contents:write` permissions attached to the token.

```action
- name: Pending Status
  id: pending
  uses: quotdian-ennui/actions-olio/commit-status-and-label@main
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    sha: ${{ github.event.pull_request.head.sha }}
    state: "pending"
    # context: "Check"
    # prefix: "check"
- name: Do the tests
  id: tests
  run: |
    echo "Doing the tests"
- name: Update Status
  id: pending
  uses: quotdian-ennui/actions-olio/commit-status-and-label@main
  if: success() || failure()
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    sha: ${{ github.event.pull_request.head.sha }}
    state: ${{ steps.tests.outcome }}
    # context: "Check"
    # prefix: "check"
```

## Notes

- Of course it's up to you to assign pretty colours to your labels.
- There is a potential timing issue if you have multiple triggered workflows that all use the same _context_ for the commit status. Not entirely sure what happens vis-a-vis branch protection rules there.
- In the example above I'm passing in the 'outcome' from the tests job which might actually be 'success | failure | skipped | cancelled'. Success and failure are self-evidently supported; skipped & cancelled are taken to be 'error'.
- There's use of `actions/github-script`; I was going to use `gh` but I had permissions issues and though I don't enjoy doing javascript, I do know enough to get into trouble. In this instance I would have much preferred to use `bash` everywhere.

## Dependencies

It's a composite action that wraps the following actions:

- jwalton/gh-find-current-pr
- actions/github-script
- octodemo-resources/github-commit-status (but this could easily be actions/github-script again).