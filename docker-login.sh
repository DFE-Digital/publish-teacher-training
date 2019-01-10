#!/bin/bash
set -e

if [ -z "$AZURE_CR_PASSWORD" ];
then
  echo "AZURE_CR_PASSWORD environment variable is required"
  exit 1
fi

echo "Logging in to docker host '$DOCKER_REGISTRY_HOST' ..."
echo "$AZURE_CR_PASSWORD" | docker login "$DOCKER_REGISTRY_HOST" -u="batdevcontainerregistry" --password-stdin
