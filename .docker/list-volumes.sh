volumes=()
while IFS='' read -r line; do volumes+=("$line"); done < <(docker run --interactive --rm linkyard/yaml:1.1.0 /bin/bash -c "spruce json | jq --raw-output '.volumes | with_entries(select(.value.external == true )) | keys[]'" < docker-compose.yml)
export volumes
