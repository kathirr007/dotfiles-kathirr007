#!/usr/bin/env bash

echo "pre-commit running successfully..."


# # !!!Attention!!!
# # if the config file path for mypy is app/*.py, mypy checks all folders except tests, assuming because of the rest of the files is being discovered through the imports in main.py.
# # config file contains the correct path to check all folders.

# cd backend || { echo "Error: Could not change to directory 'backend'."; exit 1; }

# mypy --config-file="pyproject.toml"

# # Check the exit code of mypy
# if [ $? -ne 0 ]; then
#     echo "Error: mypy found errors."
#     exit 1  # Important: Exit with a non-zero code if mypy fails
# fi

# exit 0 # Exit with 0 if successful
