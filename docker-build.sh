#!/bin/bash

set -euo pipefail

# without tag, e.g. "polyneme/mongogrant"
IMAGE_NAME="$1"

GIT_COMMIT=$(set -e && git rev-parse --short HEAD)
GIT_BRANCH=$(set -e && git rev-parse --abbrev-ref HEAD)

# Use default Git branch to pre-warm build cache for new branches.
GIT_DEFAULT_BRANCH=$(git rev-parse --abbrev-ref origin/HEAD || echo origin/master)
GIT_DEFAULT_BRANCH=$(basename "${GIT_DEFAULT_BRANCH}")

IMAGE_WITH_COMMIT="${IMAGE_NAME}:commit-${GIT_COMMIT}"
IMAGE_WITH_BRANCH="${IMAGE_NAME}:${GIT_BRANCH}"
IMAGE_WITH_DEFAULT_BRANCH="${IMAGE_NAME}:${GIT_DEFAULT_BRANCH}"

docker pull "${IMAGE_WITH_BRANCH}" || true
docker pull "${IMAGE_WITH_DEFAULT_BRANCH}" || true

docker image build \
       -t "${IMAGE_WITH_COMMIT}" \
       -t "${IMAGE_WITH_BRANCH}" \
       --cache-from "${IMAGE_WITH_BRANCH}" \
       --cache-from "${IMAGE_WITH_DEFAULT_BRANCH}" \
       --label "git-commit=${GIT_COMMIT}" \
       --label "git-branch=${GIT_BRANCH}" \
       .

docker push "${IMAGE_WITH_BRANCH}"
docker push "${IMAGE_WITH_COMMIT}"
