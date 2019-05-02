#!/bin/bash
set -e

HTTP_PORT_GATEWAY="${HTTP_PORT_GATEWAY:-8081}"

# Populate the content services

content_services=(
    blog-articles
    scholarly-articles
)
for service in "${content_services[@]}"; do
    echo "Populating ${service}"
    files=($(find ".docker/${service}/data" -name "*.xml" -print | sort))

    for file in "${files[@]}"; do
        filename=$(basename -- "${file}")
        path=$(dirname -- "${file}")

        id=${path##*/}
        version=${filename%.*}

        [[ "$(curl --verbose --silent --show-error --request PUT http://localhost:${HTTP_PORT_GATEWAY}/${service}/items/${id}/versions/${version} --upload-file ${file} --write-out '%{http_code}')" == "204" ]]
    done
done

# Populate the search service

curl --verbose --silent --show-error --request POST http://localhost:${HTTP_PORT_GATEWAY}/search/populate
