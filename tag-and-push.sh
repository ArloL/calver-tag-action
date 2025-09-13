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
        else
            git tag -d "v${VERSION}" 2>/dev/null || true
            git ls-remote --tags origin "v${MAJOR_MINOR}.*"
            git fetch origin --prune --force "+refs/tags/v${MAJOR_MINOR}.*:refs/tags/v${MAJOR_MINOR}.*"
        fi
    fi
done

echo "new_version=${VERSION}" >> "$GITHUB_OUTPUT"
