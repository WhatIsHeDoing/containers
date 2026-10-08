# Containers

The container images behind WhatIsHeDoing projects, built, tested, scanned and signed from one repository.

## Toolchain

`ghcr.io/whatishedoing/toolchain` carries the linters and runtimes that WhatIsHeDoing repositories call
from `just verify`, for amd64 and arm64. Mount a repository at `/workspace` and run any of them:

```sh
docker run --rm --volume "$PWD:/workspace" ghcr.io/whatishedoing/toolchain markdownlint-cli2 "**/*.md"
```

Every merge to `main`, and a weekly rebuild, publishes three tags: `latest`, the build date, and
`sha-` with the first twelve characters of the commit. Pin by digest for builds that must repeat.

Each image carries an SBOM and build provenance, and cosign signs it in CI. Check that a pull came from
this repository's workflow:

```sh
cosign verify ghcr.io/whatishedoing/toolchain:latest \
    --certificate-identity https://github.com/WhatIsHeDoing/containers/.github/workflows/images.yml@refs/heads/main \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

Each tool in the image keeps its own licence, which the SBOM records.

## Layout

Each image lives in `images/<name>/`, beside the structure tests that gate it. `docker-bake.hcl` defines
every image's build, and the test and audit scripts take their list of images from it.

## Working here

Run `just setup` once to install the gate tools and git hooks. Before pushing, run `just verify`: it runs
the same gates as CI. Bare `just` lists every recipe.
