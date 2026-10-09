#!/usr/bin/env bash
# Run a fixture repository's `just verify` inside an image the way a GitHub Actions `container:` job
# would: as UID 1001, which has no passwd entry, with `tail -f /dev/null` as the entrypoint, each step
# through `sh -e`, and the runner's own Node mounted at /__e to host JavaScript actions. The network
# stays off, so the image must carry everything its hooks need.
set -euo pipefail

image=${1:?usage: consumer.sh IMAGE FIXTURE}
fixture=${2:?usage: consumer.sh IMAGE FIXTURE}
context=$(dirname "$fixture")

actions_node=toolchain-actions-node:test
docker buildx build --quiet --load --target actions-node --tag "$actions_node" "$context" >/dev/null

# Tmpfs mounts stand in for the runner's bind mounts, so nothing the job writes reaches the host.
container=$(docker run --detach --network none --user 1001 --env HOME=/github/home --env CI=true \
    --tmpfs /__w:exec,mode=1777,size=512m \
    --tmpfs /__e:exec,mode=1777,size=256m \
    --tmpfs /github/home:mode=1777,size=128m \
    --entrypoint tail "$image" -f /dev/null)
trap 'docker rm --force "$container" >/dev/null' EXIT

step() {
    docker exec --workdir /__w/repository "$container" sh -e -c "$1"
}

docker exec "$container" mkdir -p /__w/repository /__e/node24/bin
# COPYFILE_DISABLE and --no-xattrs keep macOS metadata out of the archive.
COPYFILE_DISABLE=1 tar --no-xattrs --create --directory "$fixture" . |
    docker exec --interactive --workdir /__w/repository "$container" tar -x
docker run --rm --entrypoint cat "$actions_node" /usr/local/bin/node |
    docker exec --interactive "$container" sh -e -c 'cat > /__e/node24/bin/node && chmod +x /__e/node24/bin/node'

# actions/checkout runs on the runner's Node and drives the image's git.
docker exec "$container" /__e/node24/bin/node --eval \
    "process.stdout.write(require('node:child_process').execFileSync('git', ['--version']))"
step 'git init --quiet && git add . && git -c user.name=probe -c user.email=probe@example.com commit --quiet --message fixture'
step 'just verify'
