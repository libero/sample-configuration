#!/bin/bash
set -e

ENVIRONMENT_NAME="${ENVIRONMENT_NAME:-unstable}"
PUBLIC_PORT_HTTP="${PUBLIC_PORT_HTTP:-8080}"
PUBLIC_PORT_HTTPS="${PUBLIC_PORT_HTTPS:-8443}"
POPULATE_CONTENT_STORES="${POPULATE_CONTENT_STORES:-}"

# HTTPS in real environments
# HTTP locally
https_configured="$(docker inspect "$(docker-compose ps --quiet web)" | jq -r '.[0].NetworkSettings.Ports["443/tcp"]')"
if [ "$https_configured" != "null" ]; then
    api_gateway="https://${ENVIRONMENT_NAME}--api-gateway.libero.pub:${PUBLIC_PORT_HTTPS}"
else
    api_gateway="http://localhost:${PUBLIC_PORT_HTTP}"
fi

# Populate the content services
if [ -n "${POPULATE_CONTENT_STORES}" ]; then
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
                --header "Host: ${ENVIRONMENT_NAME}--api-gateway.libero.pub" \
                "${api_gateway}/${service}/items/${id}/versions/${version}" \
                --upload-file "${file}" \
                --write-out '%{http_code}' \
            )
            [[ "${put_response_code}" == "204" ]]
        done
    done
fi

# Populate the search service
search_response_code=$(curl \
    --verbose \
    --silent \
    --show-error \
    --output /dev/null \
    --request POST \
    --header "Host: ${ENVIRONMENT_NAME}--api-gateway.libero.pub" \
    "${api_gateway}/search/populate" \
    --write-out '%{http_code}'
)
[[ "${search_response_code}" == "200" ]]
