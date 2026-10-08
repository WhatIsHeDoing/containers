# Docker's default builder handles one platform at a time, so clear the list to build the engine's
# own. `platform=local` means the client's instead: darwin on a Mac. CI builds both architectures.
native_platform := "--set '*.platform='"

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
verify: lint spellcheck build test

[doc('Lint every file type and check formatting, without writing')]
[group('check')]
lint: lint-files buildkit-check

[doc('Lint every file without Docker, as CI does inside the toolchain image')]
[group('check')]
lint-files: hadolint scripts markdown yaml workflows format-check

[doc('Lint Dockerfiles for best practice')]
[group('check')]
hadolint:
    hadolint images/*/Dockerfile

[doc('Run BuildKit checks without building; every build also fails on them')]
[group('check')]
buildkit-check:
    docker buildx bake --call check {{ native_platform }}

[doc('Lint GitHub Actions workflows and audit them for supply-chain risks')]
[group('check')]
workflows:
    actionlint
    zizmor .github/workflows

[doc('Lint and format-check the shell scripts')]
[group('check')]
scripts:
    shellcheck scripts/*.sh
    shfmt --diff scripts/*.sh

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
    shfmt --write scripts/*.sh
    markdownlint-cli2 --fix "**/*.md"

[doc('Spell-check the tree in British English')]
[group('check')]
spellcheck:
    cspell lint --no-progress --gitignore --dot .

[doc("Build every image for this machine's platform and load it into Docker")]
[group('build')]
build:
    docker buildx bake --load {{ native_platform }}

[doc('Run each image structure tests against the loaded build')]
[group('check')]
test: build
    bash scripts/test.sh

[doc('Scan each loaded image for known vulnerabilities')]
[group('check')]
audit: build
    bash scripts/audit.sh
