#!/bin/sh
set -ue
 
release_title=$(echo "$RELEASE_TITLE" | tr '[:upper:]' '[:lower:]')
badfiles="false"

if echo "$release_title" | grep -Eq '^(release v([0-9]{1,2}|100)\.[0-9]{1,100}\.[0-9]{1,100}|v([0-9]{1,2}|100)\.[0-9]{1,100}\.[0-9]{1,100})$'; then
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
    return
fi

echo "Skipped check"
