# Containers

The container images behind WhatIsHeDoing projects, built, tested and scanned from one repository.

## Layout

Each image lives in `images/<name>/`, beside the structure tests that gate it. `docker-bake.hcl` defines
every image's build, and the test and audit scripts take their list of images from it.

## Working here

Run `just setup` once to install the gate tools and git hooks. Before pushing, run `just verify`: it runs
the same gates as CI. Bare `just` lists every recipe.
