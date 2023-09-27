#!/bin/sh
set -ue

FILE_PATHS="
    Dockerfile.dapper 
    go.mod 
    ./package/Dockerfile 
    ./pkg/apis/go.mod 
    ./pkg/settings/setting.go 
    ./scripts/package-env
"
LAST_COMMIT_MESSAGE=$(echo "$LAST_COMMIT_MESSAGE" | tr '[:upper:]' '[:lower:]')
DEFAULT_LAST_COMMIT_MESSAGE="last commit for final rc"
RELEASE_TITLE=$(echo "$RELEASE_TITLE")
BAD_FILES=false

if echo "$LAST_COMMIT_MESSAGE" | grep -q "$DEFAULT_LAST_COMMIT_MESSAGE" || echo "$RELEASE_TITLE" | grep -Eq '^Pre-release v2\.7\.[0-9]{1,100}-rc[1-9][0-9]{0,1}$'; then

    echo "Starting check..."

    for FILE in $FILE_PATHS; do
        if grep -q -E '\-rc[0-9]+' "$FILE"; then
            BAD_FILES=true
            echo "error: ${FILE} contains rc tags."
        fi

        if grep -q -Eo 'dev-v[0-9]+\.[0-9]+' "$FILE"; then
            BAD_FILES=true
            echo "error: ${FILE} contains dev dependencies."
        fi
    done

    if [ "${BAD_FILES}" = true ]; then
        echo "Check failed, some files don't match the expected dependencies for a GA release"
        exit 1
    fi

    echo "Check completed successfully"
    exit 0
fi

echo "Skipped check"
exit 0
