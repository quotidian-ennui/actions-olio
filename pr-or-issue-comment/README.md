# pr-or-issue-comment

Updates an existing comment or creates a new comment on an issue/pull request.

## Why

Sometimes, the activity from a github action is pretty mysterious. It's nice to be able to leave a comment on the issue or pull request that triggered the action.

## Usage

- Requires you to have `issues:write` & `pull_requests:write` permissions attached to the token (depending on what you're doing).

```action
- name: comment
  id: comment
  uses: quotidian-ennui/actions-olio/pr-or-issue-comment@main
  if: success() || failure()
  with:
    issue_number: ${{ steps.findpr.outputs.pr }}
    body: |
      Overall workflow status : ${{ steps.whatever.outcome }}
      Check out the [workflow run](https://github.com/${{ github.repository }}/actions/runs/${{ github.run_id }}) for more details.
    token: ${{ secrets.GITHUB_TOKEN }}
    search_term: "unique-search-term"
    edit_mode: (replace) | append
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|    INPUT     |  TYPE  | REQUIRED |                                DEFAULT                                |                                                                     DESCRIPTION                                                                     |
|--------------|--------|----------|-----------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------|
|     body     | string |  false   |                                                                       |                                                             The contents of the comment                                                             |
|  body_path   | string |  false   |                                                                       |                                      A file location that contains the <br>body to be used as the <br>comment                                       |
|  edit_mode   | string |  false   |                              `"replace"`                              | The edit mode to use when <br>updating an existing comment. Valid values <br>are 'replace' and 'append'. If not <br>set, the default is 'replace'.  |
| issue_number | string |  false   |                                                                       |                               The issue number to use, if <br>not set will try and use <br>value in github context.                                 |
|  repository  | string |  false   |                     `"${{ github.repository }}"`                      |                             Override the repository (your token needs to allow it) default is <br>'github.repository'                               |
| search_term  | string |  false   | `"pr-comment: workflow=${{ github.workflow }} job=${{ github.job }}"` |                The search term that allows us <br>to update an existing comment; if <br>not found then a new comment <br>is created                 |
|    token     | string |  false   |                        `"${{ github.token }}"`                        |                                                The GITHUB token to use default <br>is github.token                                                  |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->

|   OUTPUT   |  TYPE  |                       DESCRIPTION                       |
|------------|--------|---------------------------------------------------------|
| comment_id | string | The ID of the comment that <br>was created or updated.  |

<!-- AUTO-DOC-OUTPUT:END -->


## Notes

- `search_term` is essentially embedded into the comment wrapped by a XML comment tag. This defaults to some combination of `github.workflow` & `github.job` which may be unique enough provided you only have a single commment action in that particular workflow/job combination.
- `edit_mode` is as per peter-evans/create-or-update-comment. It defaults to _replace_ in this composite action.

## Dependencies

It's a composite action that wraps the following actions:

- peter-evans/find-comment
- peter-evans/create-or-update-comment
