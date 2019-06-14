#!/bin/bash
set -e

source .docker/.external-volumes.rc

for volume in "${EXTERNAL_VOLUMES[@]}"; do
    docker volume create "${volume}"
done
