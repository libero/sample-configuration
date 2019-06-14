#!/bin/bash
set -e

source .docker/.external-volumes.rc

for volume in "${volumes[@]}"; do
    if docker volume ls --filter name="${volume}" | grep "${volume}"; then
        docker volume rm "${volume}"
    fi
done
