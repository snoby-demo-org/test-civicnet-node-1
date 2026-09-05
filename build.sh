#!/bin/bash
set -euo pipefail

# Build the CivicNet node image from the LOCAL source tree (./civicnet),
# so whatever you've edited in the working tree is what gets baked in.
#
# Usage:
#   ./build.sh                          # build local tree, tag with local commit SHA
#   TAG=mytag ./build.sh                # tag with a custom name
#   NO_CACHE=1 ./build.sh               # full rebuild, no layer cache
#   DOCKERFILE=Other ./build.sh         # alternate Dockerfile

SRC_DIR="${SRC_DIR:-civicnet}"
DOCKERFILE="${DOCKERFILE:-Dockerfile}"

# Tag defaults to the local source tree's current commit SHA (so you can tell
# which build is which). Falls back to 'local' if not a git checkout.
if git -C "${SRC_DIR}" rev-parse --short HEAD >/dev/null 2>&1; then
  LOCAL_SHA="$(git -C "${SRC_DIR}" rev-parse --short HEAD)"
else
  LOCAL_SHA="local"
fi

TAG="${TAG:-${LOCAL_SHA}}"
NO_CACHE="${NO_CACHE:-0}"

echo "Building iotapi322/civicnet:${TAG} from local source ${SRC_DIR}/ (@ ${LOCAL_SHA})"

docker_args=(
  -f "${DOCKERFILE}"
  -t "iotapi322/civicnet:${TAG}"
  .
)

if [[ "${NO_CACHE}" == "1" ]]; then
  docker_args=(--no-cache "${docker_args[@]}")
fi

docker build "${docker_args[@]}"
