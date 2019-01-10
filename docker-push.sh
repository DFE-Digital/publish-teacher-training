#!/bin/bash
set -e

if [ -z "$TRAVIS_BRANCH" ];
then
  echo "TRAVIS_BRANCH environment variable is required"
  exit 1
fi

source config.sh

DOCKER_REGISTRY_HOST=$DOCKER_REGISTRY_HOST ./docker-login.sh

echo "Running docker push to $DOCKER_PATH:$TRAVIS_BRANCH ..."
docker tag "$DOCKER_PATH:latest" "$DOCKER_PATH:$TRAVIS_BRANCH"
docker push "$DOCKER_PATH"
