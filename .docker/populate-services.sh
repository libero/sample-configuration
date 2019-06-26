#!/bin/bash
set -e

COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-sample-configuration}"
PUBLIC_PORT_HTTP="${PUBLIC_PORT_HTTP:-8080}"
PUBLIC_PORT_HTTPS="${PUBLIC_PORT_HTTPS:-8443}"

# HTTPS in real environments
# HTTP locally
https_configured="$(docker inspect "${COMPOSE_PROJECT_NAME}_web_1" | jq -r '.[0].NetworkSettings.Ports["443/tcp"]')"
if [ "$https_configured" != "null" ]; then
    api_gateway="https://unstable--api-gateway.libero.pub:${PUBLIC_PORT_HTTPS}"
else
    api_gateway="http://localhost:${PUBLIC_PORT_HTTP}"
fi

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

        put_response_code=$(curl \
            --verbose \
            --silent \
            --show-error \
            --output /dev/null \
            --request PUT \
            --header "Host: unstable--api-gateway.libero.pub" \
            "${api_gateway}/${service}/items/${id}/versions/${version}" \
            --upload-file "${file}" \
            --write-out '%{http_code}' \
        )
        [[ "${put_response_code}" == "204" ]]
    done
done

# Populate the search service
search_response_code=$(curl \
    --verbose \
    --silent \
    --show-error \
    --output /dev/null \
    --request POST \
    --header "Host: unstable--api-gateway.libero.pub" \
    "${api_gateway}/search/populate" \
    --write-out '%{http_code}'
)
[[ "${search_response_code}" == "200" ]]
