#!/usr/bin/env bash
# Scan each Bake target's image, as `just build` loaded it, for known vulnerabilities.
set -euo pipefail

docker buildx bake --print 2>/dev/null |
    jq -r '.target[].tags[0]' |
    while read -r image; do
        osv-scanner scan image "$image"
    done
