#!/bin/bash
set -e

source .docker/list-volumes.sh

for volume in "${volumes[@]}"; do
    if docker volume ls --filter name="${volume}" | grep "${volume}"; then
        docker volume rm "${volume}"
    fi
done
