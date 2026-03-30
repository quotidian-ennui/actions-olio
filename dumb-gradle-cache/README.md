# Dumb Gradle Cache

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
- uses: quotidian-ennui/actions-olio/dumb-gradle-cache@main
  name: gradle-cache
  with:
    writeable: ${{ github.ref == format('refs/heads/{0}', github.event.repository.default_branch) }}
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->
No outputs.
<!-- AUTO-DOC-OUTPUT:END -->
