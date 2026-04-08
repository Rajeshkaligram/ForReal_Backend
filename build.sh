#!/bin/bash

set -e  # Exit on any error

echo "Starting build process..."

# Skip npm build for API backend - not needed for API functionality
echo "Skipping npm build (API backend doesn't require frontend assets)"

echo "Build completed successfully!"
