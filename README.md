# actions-olio

It's a gallimaufry of actions; it might even have been a melange; perhaps an olio is best because it's short and easy to spell.

Essentially this is a repo where I have actions that I share between my personal repositories. Feel free to use them, fork it, whatever. This is for scratching my own itches around github actions and trying out new things.

> Like the work of a short-order cook there's nothing particular unique about what I'm doing, it's a combination of other peoples actions. I'm just putting them together in a way that works for me.

Some of these actions may graduate to their own repos if they become more generally useful.

- I may (or may not) tag & release these actions en-masse
  - If I do tag then it'll be an explicit semver (v1.0.0 etc) with no additional tags like `@v1`, `@v1.1`.
  - Not that I don't enjoy the convenience that something like `@v1` gives me but I've seen far too many things _break_ because someone thought things were more compatible than they were...

## Action List

Not because they're that interesting, but I have made a documentation effort so you can evaluate whether you want to use them or not.

The source of the actions themselves are of course self-documenting :roll_eyes: (and you'll need to refer to them to see all the inputs + outputs).

- [docker-image-builder](./docker-image-builder/README.md)
- [repo-dispatch](./repo-dispatch/README.md)
- [generate-dependabot-config](./generate-dependabot-config/README.md)
- [pr-or-issue-comment](./pr-or-issue-comment/README.md)
- [commit-status-and-label](./commit-status-and-label/README.md)
- [default-updatecli](./default-updatecli/README.md)
- [pr-trigger](./pr-trigger/README.md)
- [dependabot-merge](./dependabot-merge/README.md)
