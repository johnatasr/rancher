#!/bin/sh
set -ue

badfiles="false"

for FILE in Dockerfile.dapper go.mod ./package/Dockerfile ./pkg/apis/go.mod ./pkg/settings/setting.go ./scripts/package-env; do
    if grep -q -E '\-rc[0-9]+' "$FILE"; then
        badfiles="true"
        echo "Error: ${FILE} contains rc tags."
    fi

    if grep -q -Eo 'dev-v[0-9]+\.[0-9]+' "$FILE"; then
        badfiles="true"
        echo "Error: ${FILE} contains dev dependencies."
    fi
done

if [ "${badfiles}" = "true" ]; then
  echo "Check failed, some files don't match the expected dependencies for a GA release"
  exit 1
fi

echo "Check completed successfully"
