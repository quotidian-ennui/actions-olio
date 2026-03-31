# Setup Java + Gradle

Because of the license change here to the gradle caching action: <https://github.com/gradle/actions>

I don't really care _that much_ about the license change, but hey, we can use actions/cache to naively and stupidly cache the gradle things and let gradle do the right thing; realistically you could just use the caching out of `actions/setup-java` instead but here we have explicit control as to when the cache is writeable or not.

Of course there is _nuance_

- you probably don't want to run in daemon mode because otherwise the daemon is reponsible for managing when to delete stale wrappers and the like and who knows when that will be.
- you can setup gradle with your own custom init-scripts as per their documentation `gradleUserHome/init.d/cache-settings.init.gradle` (but that's more setup work)

```text

beforeSettings { settings ->
  settings.caches {
    releasedWrappers.removeUnusedEntriesAfterDays = 5
    snapshotWrappers.removeUnusedEntriesAfterDays = 5
    downloadedResources.removeUnusedEntriesAfterDays = 30
    createdResources.removeUnusedEntriesAfterDays = 10
    buildCache.removeUnusedEntriesAfterDays = 5
    daemonLogs.removeUnusedEntriesAfterDays = 5
    cleanup = Cleanup.ALWAYS
  }
}
```

## Usage

```yaml
- uses: quotidian-ennui/actions-olio/setup-java-gradle@main
  name: setup-java
  with:
    java-version: "21"
    distribution: "temurin"
    writeable: ${{ github.ref == format('refs/heads/{0}', github.event.repository.default_branch) }}
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|              INPUT               |  TYPE  | REQUIRED |   DEFAULT    |                                                                                                   DESCRIPTION                                                                                                   |
|----------------------------------|--------|----------|--------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|           distribution           | string |  false   | `"temurin"`  |                                                                                             Which Java Distribution                                                                                             |
|     gradle-dependency-graph      | string |  false   | `"disabled"` |                               The gradle action dependency graph value (disabled,generate,generate-and-submit,generate-submit-and-upload,generate-and-upload,download-and-submit)                               |
|        gradle-job-summary        | string |  false   |  `"always"`  |                                      Specifies when a Job Summary should be inluded in the action results. Valid values are 'never', 'always' (default), and 'on-failure'.                                      |
| gradle-job-summary-as-pr-comment | string |  false   |  `"never"`   | Specifies when each Job Summary should be added as a PR comment. Valid values are 'never' (default), 'always', and 'on-failure'. No action will be taken if the workflow was not triggered from a pull request. |
|           java-version           | string |  false   |    `"21"`    |                                                                                               Which Java Version                                                                                                |
|            writeable             | string |  false   |  `"false"`   |                                                                                          Treat the cache as writeable                                                                                           |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->
No outputs.
<!-- AUTO-DOC-OUTPUT:END -->
