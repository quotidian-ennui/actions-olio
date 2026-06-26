# semver-diff

Simple action to diff the changes between 2 semantic versions. This takes its inspiration from <https://github.com/fsaintjacques/semver-tool> which
is a pure bash play on semver tooling.

## Why

Because sometimes you want to generate a `feat!` conventional commit message based on whether the semantic versions differ on the major version. I generally use it to differentiate when a dependency that isn't managed by dependabot or similar raises a pull request

> Note that there's no differentional between pre-release / build semver changes when it comes to generating the conventional commit type. That will only be reflected in the `diff` output.

## Usage

```action
- name: semver-diff
  id: semver-diff
  uses: quotidian-ennui/actions-olio/semver-diff@main
  with:
    first: ${{ some.initial.tag }}
    second: ${{ some.other.tag }}
    type-major: feat(deps)!
    type-minor: feat(deps)
    type-patch: chore(deps)
- name: Create Pull Request
  uses: peter-evans/create-pull-request@5f6978faf089d4d20b00c7766989d076bb2fc7f1 # v8.1.1
  with:
    commit-message: "${{ steps.semver-diff.outputs.commit-type }}: Upgrade to ${{ some.other.tag }}"
    title: "${{ steps.semver-diff.outputs.commit-type }}: Upgrade to ${{ some.other.tag }}"
    labels: dependencies
    reviewers: ${{ github.repository_owner }}
    body: |
      Automated upgrade to ${{ some.other.tag }}.
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|   INPUT    |  TYPE  | REQUIRED |  DEFAULT  |               DESCRIPTION                |
|------------|--------|----------|-----------|------------------------------------------|
|   first    | string |   true   |           |              The first tag               |
|   second   | string |   true   |           |              The second tag              |
| type-major | string |  false   | `"feat!"` | The conventional type for a major change |
| type-minor | string |  false   | `"feat"`  | The conventional type for a minor change |
| type-patch | string |  false   |  `"fix"`  | The conventional type for a patch change |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->

|   OUTPUT    |  TYPE  |                        DESCRIPTION                        |
|-------------|--------|-----------------------------------------------------------|
| commit-type | string | The conventional commit type that corresponds to the diff |
|    diff     | string |               The diff -  major,minor,patch               |

<!-- AUTO-DOC-OUTPUT:END -->

## Dependencies

It's a composite action that runs a script. It will require `yq`, `jq` and `gh` which are all available as part of the standard baseline runner image.

## References

- <https://github.com/fsaintjacques/semver-tool>
