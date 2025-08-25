#!/usr/bin/env bash

# Build
echo "🤖 Build"
docker build -f ./docker/test/Dockerfile -t xmlcoding .

# Run
echo "🏃‍♀️ Run"
docker run xmlcoding
