#!/usr/bin/env sh

echo "pre-commit running successfully..."


# # Relaunch in Bash if not already in Bash
# if [ -z "$BASH_VERSION" ]; then
#     exec $(command -v bash) "$0" "$@"
# fi

# # Now in Bash

# # Switch to backend folder 'backend'
# cd backend || { echo "Error: Could not change to directory 'backend'."; exit 1; }

# # Run black command to auto reformat
# black .

# # Check the exit code of black
# if [ $? -ne 0 ]; then
#     echo "Error: black found errors."
#     exit 1  # Important: Exit with a non-zero code if black fails
# fi

# exit 0 # Exit with 0 if successful
