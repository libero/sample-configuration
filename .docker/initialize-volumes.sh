#!/bin/bash
set -e

source .docker/.external-volumes.rc

for volume in "${volumes[@]}"; do
    docker volume create "${volume}"
done
