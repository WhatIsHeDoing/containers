# Agent guide

## Agent interface (standard)

- Commands: `just --list` is the contract. Verify with `just verify`, and scan the built images with
  `just audit`. Dependabot proposes upgrades to base images, tool images and actions.
- Package manager: none at the root. Homebrew installs the gate tools from the `Brewfile`. Inside an
  image, apk installs the runtimes from Wolfi, and npm and uv install the tools from their lockfiles.
- Cooldown: 14 days by default, 7 for patches and 30 for majors, applied by Dependabot.
- CI: `.github/workflows/images.yml` builds and tests each architecture natively, lints inside the
  toolchain it just built, and on `main` publishes the tested images as one signed index.
- Commits: conventional, e.g. `feat(toolchain): add lychee`.
- Branch: a short-lived branch off `main` per change.
- Pre-push runs `just lint spellcheck`; hooks gate committed content only (staged files or the push
  range), never the whole working tree.
