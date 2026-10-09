#!/usr/bin/env bash
# Scan each Bake target's image, as `just build` loaded it, for known vulnerabilities.
# An image scan reads no config by default, so name the file that records the accepted ones.
set -euo pipefail

docker buildx bake --print 2>/dev/null |
    jq -r '.target[].tags[0]' |
    while read -r image; do
        osv-scanner scan image --config osv-scanner.toml "$image"
    done
