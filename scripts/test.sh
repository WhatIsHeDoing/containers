#!/usr/bin/env bash
# Run each Bake target's structure tests against the image `just build` loaded.
set -euo pipefail

docker buildx bake --print 2>/dev/null |
    jq -r '.target[] | "\(.tags[0]) \(.context)"' |
    while read -r image context; do
        container-structure-test test --image "$image" --config "$context/structure-test.yaml"
    done
