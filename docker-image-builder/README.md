# docker-image-builder

Builds a docker image and optionally pushes it to docker.io & ghcr.io if you provide the credentials for those registries.

## Why

I use it in my personal projects where I'm building docker images (https://github.com/quotidian-ennui/docker-activemq/blob/main/.github/workflows/docker-build-image.yml). Doing it as an action removes the need for copy pasta on my part.


## Usage

- Requires you to have contents:read & packages:write permissions attached to the token (packages:write required to publish to ghcr).

Defaults are the values in parentheses

```action
- name: docker-build-push
  uses: quotidian-ennui/actions-olio/docker-image-builder@main
  with:
    registry_push: true | (false)
    load_locally: (false) | true
    dockerfile: /path/to/Dockerfile
    image_tag_suffix: suffix to add to the version if any ('')
    image_platforms: platforms to build for (linux/amd64)
    ghcr_image_name: your image name on ghcr.io
    dockerhub_image_name: your image on hub.docker.com
    ghcr_user: ${{ github.repository_owner }}
    ghcr_token: ${{ secrets.GITHUB_TOKEN }}
    dockerhub_user: ${{ secrets.DOCKERHUB_USER }}
    dockerhub_token: ${{ secrets.DOCKERHUB_TOKEN }}
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|        INPUT         |  TYPE  | REQUIRED |     DEFAULT     |                                                 DESCRIPTION                                                 |
|----------------------|--------|----------|-----------------|-------------------------------------------------------------------------------------------------------------|
|      cache_from      | string |  false   |                 |   List of external cache sources for build-push-action (e.g., user/app:cache, type=local,src=path/to/dir)   |
|       cache_to       | string |  false   |                 | List of cache export destinations for build-push-action (e.g., user/app:cache, type=local,dest=path/to/dir) |
|      dockerfile      | string |   true   |                 |                                           Path to the dockerfile                                            |
| dockerhub_image_name | string |  false   |                 |                                            Dockerhub image name                                             |
|   dockerhub_token    | string |  false   |                 |                                               Dockerhub token                                               |
|    dockerhub_user    | string |  false   |                 |                                             Dockerhub username                                              |
|   ghcr_image_name    | string |  false   |                 |                            Github container registry image name (ghcr.io/x/y/z)                             |
|      ghcr_token      | string |  false   |                 |                                   Token for the github container registry                                   |
|      ghcr_user       | string |  false   |                 |                                     Github container registry username                                      |
|   image_platforms    | string |  false   | `"linux/amd64"` |                                           Platforms to build for                                            |
|   image_tag_suffix   | string |  false   |                 |                                          Suffix for the image name                                          |
|     load_locally     | string |  false   |    `"false"`    |                   Whether to load the image locally if you want to use it in a later step                   |
|    registry_push     | string |  false   |    `"false"`    |                                       Whether to push to the registry                                       |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->

|   OUTPUT   |  TYPE  |          DESCRIPTION           |
|------------|--------|--------------------------------|
| image_tags | string |          Docker tags           |
|    json    | string | JSON output of tags and labels |
|   labels   | string |         Docker labels          |
|  version   | string |      Docker image version      |

<!-- AUTO-DOC-OUTPUT:END -->

## Notes

- `load_locally` is the equivalent to passing in `--load` to the docker buildx commandline with all its attendant caveats. As a feature I consider it dangerous since there is every chance there will be information leakage if you don't clear up after yourself. I use it so that I can [test the action itself](../.github/workflows/test-docker-image-builder.yml) and I have no images that aren't already public...

## Dependencies

It's a composite action that wraps the following actions:

- docker/setup-qemu-action
- docker/setup-buildx-action
- docker/login-action
- docker/metadata-action
- docker/build-push-action
