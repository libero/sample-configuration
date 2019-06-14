#!/bin/bash
set -e

source .docker/.external-volumes.rc

for volume in "${volumes[@]}"; do
    # if the volume is existing, grep matches it in the 1-item list
    if docker volume ls --quiet --filter name="${volume}" | grep "${volume}"; then
        docker volume rm "${volume}"
    fi
done
