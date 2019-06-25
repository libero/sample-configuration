#!/bin/bash
set -e

HTTP_PORT="${HTTP_PORT:-8080}"

# Populate the content services

content_services=(
    blog-articles
    scholarly-articles
)
for service in "${content_services[@]}"; do
    echo "Populating ${service}"

    files=()
    while IFS='' read -r line; do files+=("$line"); done < <(find ".docker/${service}/data" -name "*.xml" -print | sort)

    for file in "${files[@]}"; do
        id=$(basename "$(dirname "${file}")")
        version=$(basename -- "${file%.*}")

        [[ "$(curl --verbose --silent --show-error --output /dev/null --request PUT --header "Host: unstable--api-gateway.libero.pub" "http://localhost:${HTTP_PORT}/${service}/items/${id}/versions/${version}" --upload-file "${file}" --write-out '%{http_code}')" == "204" ]]
    done
done

# Populate the search service

[[ "$(curl --verbose --silent --show-error --output /dev/null --request POST --header "Host: unstable--api-gateway.libero.pub" "http://localhost:${HTTP_PORT}/search/populate" --write-out '%{http_code}')" == "200" ]]
