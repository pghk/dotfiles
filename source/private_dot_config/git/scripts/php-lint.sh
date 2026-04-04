#!/bin/bash

echo "Running pre-commit checks..."
for file in $(git diff-index --name-only HEAD); do
    if [[ $file =~ \.php$ ]]; then
        message=$(php -l $file)
        if [[ $message == Errors* ]]; then
            echo "Commit aborted."
            exit 1
        fi
    fi
done
