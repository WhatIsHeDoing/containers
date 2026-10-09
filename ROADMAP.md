# Roadmap — containers

The container images behind WhatIsHeDoing projects, replacing eight unmaintained Docker Hub images built
between 2019 and 2021.

**Now:** A repository verifies in the image.
**Last updated:** 2026-10-09.

> Now holds unfinished work only, capped at three items. A finished item collapses to one Shipped line.

## Now

### A repository verifies in the image

Point one repository's CI job at the toolchain image through `container:`, so its local and CI gates
run in the same environment. The image runs as UID 1000, and GitHub mounts the workspace for root, so
expect to set the job's user.

## Next

| Item                                     | Outcome                                             | Waiting on |
| ---------------------------------------- | --------------------------------------------------- | ---------- |
| [A push-scoped Docker Hub token][hubkey] | The mirror outlives the token it logs in with today | Nothing    |

[hubkey]: #a-push-scoped-docker-hub-token

### A push-scoped Docker Hub token

The `release` environment's `DOCKERHUB_TOKEN` is a broader token that lapses around January 2027.
After that, the login step fails the publish job, though GHCR has its signed index by then. Replace it
with a token that can only push, before it lapses.

## Later

| Item                                     | Why not yet                                                           |
| ---------------------------------------- | --------------------------------------------------------------------- |
| Gate on fixable critical vulnerabilities | Nearly all 220 findings await Debian or upstream fixes; audit reports |
| Drop the `braces` waiver and overrides   | Each waits on a fixed upstream release; the waiver lapses 2027-01-09  |
| A smaller toolchain                      | 817 MB works for CI; measure the layers with `dive` before cutting    |
| Dev Container Feature                    | Waits on one repository using the image in CI                         |
| `just upgrade` for base images           | Dependabot covers it until a local, cooldown-aware bump pays          |
| Managed by `agent-interface-kit`         | `aik` has no Docker ecosystem yet                                     |
| `LocalDataCentre` home lab               | A separate repository with its own Compose stack                      |
| Delete the eight old Docker Hub images   | Nothing reports who still pulls them, so wait out a quiet period      |

## Shipped

- Toolchain mirrored to Docker Hub, signed, from every `main` publish (acc59a4).
- Eight old Docker Hub images deprecated, each naming its replacement.
- CI publishes signed, attested, multi-arch images to GHCR (0422924).
- Five legacy source repositories archived, each naming its replacement.
- Toolchain image, structure-tested on both architectures (403888b).

## Open questions

- Which licence? The proposal is `MIT OR Apache-2.0`, as Chuck uses.
