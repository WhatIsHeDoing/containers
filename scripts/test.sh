#!/usr/bin/env bash
# Run each Bake target's structure tests against the image `just build` loaded, then, where the image
# carries a fixture repository, run that repository's gate inside it as a GitHub Actions job would.
set -euo pipefail

docker buildx bake --print 2>/dev/null |
    jq -r '.target[] | "\(.tags[0]) \(.context)"' |
    while read -r image context; do
        container-structure-test test --image "$image" --config "$context/structure-test.yaml"
        # Stdin stays closed so no step can read the rest of the target list.
        if [[ -d "$context/consumer" ]]; then
            bash scripts/consumer.sh "$image" "$context/consumer" </dev/null
        fi
    done
