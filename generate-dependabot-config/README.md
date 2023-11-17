# generate-dependabot-config

Generates `.github/dependabot.yml` from a `.github/dependabot.template.yml` using makeshift/generate-dependabot-glob-action and raises a pull request

## Why

github-actions that don't live in `./github/workflows` don't get automatically tracked by dependabot unless you have the explicit directory configured in your dependabot.yml. It's too much like hard work to keep updating dependabot.yml. Your use case is where you have multiple Dockerfiles in different directories or multiple action actions defined in the same repository (like this repo).

## Usage

- Requires you to have `contents:write` & `pull_requests:write` permissions attached to the token.
- Examine [dependabot.template.yml](.github/dependabot.template.yml) if you want to see it in use in this repo.

```action
name: Regenerate Dependabot Config

on:
  push:
    branches:
      - main
    paths:
      - "**/action.yml"
      - "**/Dockerfile"
      - ".github/dependabot.template.yml"
  workflow_dispatch:

defaults:
  run:
    shell: bash

permissions:
  contents: write
  pull-requests: write

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  regenerate-dependabot-yml:
    name: Regenerate Dependabot yaml
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4.1.1
      - name: generate-dependabot-config
        uses: quotidian-ennui/actions-olio/generate-dependabot-config@main
        with:
          token: ${{ github.token }}
```

## Notes

- It uses `yq` under the covers to extract the directories that have been added or removed. The 'first diff' in this list is used as part of the commit message. This just leaves us with a slightly better conventional commit message.
    - If you change dependabot.template.yml so that things that don't require globbing has changed then your commit message will contain empty brackets (I might get round to making that better).

## Dependencies

It's a composite action that wraps the following actions:

- makeshift/generate-dependabot-glob-action
- actionsx/prettier (because makeshift has formatting opinions, prettier has opinions and I have opinions; prettier saves time if you use megalinter)
- peter-evans/create-pull-request

