#!/bin/bash
set -e

source .docker/list-volumes.sh

for volume in "${volumes[@]}"; do
    docker volume create "${volume}"
done
