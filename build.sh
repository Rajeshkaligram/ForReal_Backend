#!/bin/bash

set -e  # Exit on any error

echo "Starting build process..."

# Install dependencies with verbose output
echo "Installing npm dependencies..."
npm install --legacy-peer-deps --verbose

# Install additional Laravel Mix dependencies explicitly
echo "Installing Laravel Mix dependencies..."
npm install sass-loader@^12.1.0 webpack-cli@^4.10.0 --save-dev --legacy-peer-deps --verbose

# Run production build
echo "Running production build..."
npm run production --verbose

echo "Build completed successfully!"
