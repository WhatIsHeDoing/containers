# Roadmap — containers

The container images behind WhatIsHeDoing projects, replacing eight unmaintained Docker Hub images built
between 2019 and 2021.

**Now:** CI publishes the images.
**Last updated:** 2026-10-08.

> Now holds unfinished work only, capped at three items. A finished item collapses to one Shipped line.

## Now

### CI publishes the images

GitHub Actions builds each architecture on a native runner, then runs the structure tests and
`osv-scanner`. It attaches an SBOM and provenance, signs with cosign, and pushes to GHCR with a Docker
Hub mirror. A weekly run rebuilds so base-image fixes land without a code change.

## Next

| Item                                     | Outcome                                                     | Waiting on              |
| ---------------------------------------- | ----------------------------------------------------------- | ----------------------- |
| [Legacy images retired][retire]          | Docker Hub visitors find current images, or the replacement | Docker Hub write access |
| [A repository verifies in the image][vf] | One repository's CI runs `just verify` inside the toolchain | CI publishing           |

[retire]: #legacy-images-retired
[vf]: #a-repository-verifies-in-the-image

### Legacy images retired

Mark the eight old images deprecated on Docker Hub, naming each replacement, and archive their five
source repositories. Delete the images only after a quiet period, since nothing reports who still
pulls them.

### A repository verifies in the image

Point one repository's CI job at the toolchain image through `container:`, so its local and CI gates
run in the same environment.

## Later

| Item                                     | Why not yet                                                           |
| ---------------------------------------- | --------------------------------------------------------------------- |
| Gate on fixable critical vulnerabilities | Nearly all 220 findings await Debian or upstream fixes; audit reports |
| A smaller toolchain                      | 817 MB works for CI; measure the layers with `dive` before cutting    |
| Dev Container Feature                    | Needs the published toolchain image first                             |
| `just upgrade` for base images           | Dependabot covers it until a local, cooldown-aware bump pays          |
| Managed by `agent-interface-kit`         | `aik` has no Docker ecosystem yet                                     |
| `LocalDataCentre` home lab               | A separate repository; revisit once CI publishes                      |

## Shipped

- Toolchain image, structure-tested on both architectures.

## Open questions

- Does anything still pull the Telerik reporting image?
- Should the site's Docker link point at GHCR instead of Docker Hub?
- Which licence? The old image repositories used the Unlicense; recent repositories carry none.
