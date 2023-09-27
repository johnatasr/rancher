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

DEFAULT_LAST_COMMIT_MESSAGE="last commit for final rc"
COUNT_FILES=$(echo "$FILE_PATHS" | grep -c "$")  

echo "release: $RELEASE_TITLE"
echo "commit: $LAST_COMMIT_MESSAGE"

if echo "$RELEASE_TITLE" | grep -Eq '^Pre-release v2\.7\.[0-9]{1,100}-rc[1-9][0-9]{0,1}$' || echo "$LAST_COMMIT_MESSAGE" | grep -q "$DEFAULT_LAST_COMMIT_MESSAGE"; then

    echo "Starting check, $COUNT_FILES files detected..."

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
