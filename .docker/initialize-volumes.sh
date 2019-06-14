#!/bin/bash
set -e

source .docker/.volumes

for volume in "${volumes[@]}"; do
    docker volume create "${volume}"
done
