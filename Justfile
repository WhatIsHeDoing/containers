[doc('List all available recipes')]
[group('meta')]
default:
    @just --list

# `&&` so hooks run after the body: on a fresh machine `brew bundle` is what installs lefthook.
[doc('Install the gate tools and git hooks')]
[group('setup')]
[macos]
setup: && hooks
    brew bundle

[doc('Install the gate tools and git hooks')]
[group('setup')]
[linux]
setup:
    @echo "See Brewfile for the tools; install them, then run 'just hooks'."

[doc('Install the git hooks')]
[group('setup')]
hooks:
    lefthook install

[doc('Run every gate CI runs')]
[group('check')]
verify: lint spellcheck

[doc('Lint every file type and check formatting, without writing')]
[group('check')]
lint: markdown yaml format-check

[doc('Lint Markdown')]
[group('check')]
markdown:
    markdownlint-cli2 "**/*.md"

[doc('Lint YAML')]
[group('check')]
yaml:
    yamllint --strict .

[doc('Check formatting without writing')]
[group('check')]
format-check:
    just --fmt --check

[doc('Apply the fixes the formatters can make')]
[group('check')]
format:
    just --fmt
    markdownlint-cli2 --fix "**/*.md"

[doc('Spell-check the tree in British English')]
[group('check')]
spellcheck:
    cspell lint --no-progress --gitignore .
