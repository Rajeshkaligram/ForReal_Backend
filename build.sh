#!/bin/bash

# Install dependencies
npm install --legacy-peer-deps

# Run production build (this will install additional deps if needed)
npm run production

# Run production build again in case deps were installed
npm run production
