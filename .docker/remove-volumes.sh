#!/bin/bash
set -e

source .docker/.external-volumes.rc

for volume in "${EXTERNAL_VOLUMES[@]}"; do
    if [ "$(docker volume ls --quiet --filter name="${volume}")" == "${volume}" ]; then
        docker volume rm "${volume}"
    fi
done
