#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

MAJOR_MINOR=$(date -u +"%y%m")
git fetch origin --prune --force "+refs/tags/v${MAJOR_MINOR}.*:refs/tags/v${MAJOR_MINOR}.*"

for MICRO in $(seq 101 999); do
    if [ "${MICRO}" = "999" ]; then
        echo "Reached the last possible release. Something is off"
        exit 1
    fi
    VERSION=${MAJOR_MINOR}.0.${MICRO}
    if git tag "v${VERSION}" "${GITHUB_SHA}"; then
        if git push origin "refs/tags/v${VERSION}"; then
            break
        fi
        git tag -d "v${VERSION}"
        if ! git ls-remote --exit-code --tags origin "refs/tags/v${VERSION}"; then
            echo "Push failed and v${VERSION} does not exist on origin"
            exit 1
        fi
        git fetch origin --prune --force "+refs/tags/v${MAJOR_MINOR}.*:refs/tags/v${MAJOR_MINOR}.*"
    fi
done

echo "new_version=${VERSION}" >> "$GITHUB_OUTPUT"
