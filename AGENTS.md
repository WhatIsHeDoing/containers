# Agent guide

## Agent interface (standard)

- Commands: `just --list` is the contract. Verify with `just verify`; Dependabot proposes base-image and
  action upgrades.
- Package manager: none. Homebrew installs the gate tools from the `Brewfile`.
- Cooldown: 7 days, applied by Dependabot.
- Commits: conventional, e.g. `feat(toolchain): add lychee`.
- Branch: a short-lived branch off `main` per change.
- Pre-push runs `just lint spellcheck`; hooks gate committed content only (staged files or the push
  range), never the whole working tree.
