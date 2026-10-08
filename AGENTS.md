# Agent guide

## Agent interface (standard)

- Commands: `just --list` is the contract. Verify with `just verify`, and scan the built images with
  `just audit`. Dependabot proposes upgrades to base images, tool images and actions.
- Package manager: none at the root. Homebrew installs the gate tools from the `Brewfile`; inside an
  image, npm and uv install from their lockfiles.
- Cooldown: 7 days, applied by Dependabot.
- Commits: conventional, e.g. `feat(toolchain): add lychee`.
- Branch: a short-lived branch off `main` per change.
- Pre-push runs `just lint spellcheck`; hooks gate committed content only (staged files or the push
  range), never the whole working tree.
