#!/bin/bash
set -e

# source this file to set up environment for use by other scripts

export DOCKER_REGISTRY_HOST="batdevcontainerregistry.azurecr.io"
export DOCKER_REGISTRY_IMAGE="manage-courses-backend"

export DOCKER_PATH="$DOCKER_REGISTRY_HOST/$DOCKER_REGISTRY_IMAGE"
