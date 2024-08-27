#!/bin/sh

set -o errexit
set -o nounset
set -o xtrace

MAJOR_MINOR=$(date -u +"%y%m")
git fetch origin --prune 'refs/tags/*:refs/tags/*'

for MICRO in $(seq 101 999); do
    if [ "${MICRO}" = "999" ]; then
        echo "Reached the last possible release. Something is off"
        exit 1
    fi
    VERSION=${MAJOR_MINOR}.0.${MICRO}
    if git tag "v${VERSION}" "${GITHUB_SHA}" && git push origin "refs/tags/v${VERSION}"; then
        break
    fi
done

echo "new_version=${VERSION}" >> "$GITHUB_OUTPUT"
