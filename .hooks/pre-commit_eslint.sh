#!/usr/bin/env bash

# Switch to frontend folder 'frontend'
cd frontend || { echo "Error: Could not change to directory 'frontend'."; exit 1; }

# Run npm script to lint and fix eslint issues
npm run lint:fix

# Check the exit code of eslint
if [ $? -ne 0 ]; then
    echo "Error: eslint found errors."
    exit 1  # Important: Exit with a non-zero code if eslint fails
fi

exit 0 # Exit with 0 if successful
