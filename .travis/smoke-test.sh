#!/bin/bash
set -ex

ENVIRONMENT_NAME="${ENVIRONMENT_NAME:-unstable}"
PUBLIC_PORT_HTTP="${PUBLIC_PORT_HTTP:-8080}"
PUBLIC_PORT_HTTPS="${PUBLIC_PORT_HTTPS:-8443}"

echo "Wait for containers health"
services=(
    jats-ingester_postgres
    jats-ingester_webserver
    jats-ingester_worker
    blog-articles_postgres
    blog-articles_fpm
    blog-articles_web
    scholarly-articles_postgres
    scholarly-articles_fpm
    scholarly-articles_web
    search_elasticsearch
    search_wsgi
    search_web
    api-gateway
    dummy-api_fpm
    browser_fpm
    pattern-library
    web
)
for service in "${services[@]}"; do
    .scripts/docker/wait-healthy.sh "$(docker-compose ps --quiet "${service}")" 240
done

# HTTPS in real environments
# HTTP locally
https_configured="$(docker inspect "$(docker-compose ps --quiet web)"| jq -r '.[0].NetworkSettings.Ports["443/tcp"]')"
if [ "$https_configured" != "null" ]; then
    jats_ingester="https://${ENVIRONMENT_NAME}--jats-ingester.libero.pub:${PUBLIC_PORT_HTTPS}"
    api_gateway="https://${ENVIRONMENT_NAME}--api-gateway.libero.pub:${PUBLIC_PORT_HTTPS}"
    dummy_api="https://${ENVIRONMENT_NAME}--dummy-api.libero.pub:${PUBLIC_PORT_HTTPS}"
    browser="https://${ENVIRONMENT_NAME}.libero.pub:${PUBLIC_PORT_HTTPS}"
    pattern_library="https://${ENVIRONMENT_NAME}--pattern-library.libero.pub:${PUBLIC_PORT_HTTPS}"
else
    jats_ingester="http://localhost:${PUBLIC_PORT_HTTP}"
    api_gateway="http://localhost:${PUBLIC_PORT_HTTP}"
    dummy_api="http://localhost:${PUBLIC_PORT_HTTP}"
    browser="http://localhost:${PUBLIC_PORT_HTTP}"
    pattern_library="http://localhost:${PUBLIC_PORT_HTTP}"
fi

echo "Smoke testing jats-ingester"
[[ "$(curl -sS -H "Host: ${ENVIRONMENT_NAME}--jats-ingester.libero.pub" "${jats_ingester}/admin/" --output /dev/null --write-out '%{http_code}' 2>&1)" == "200" ]]

echo "Smoke testing api-gateway (blog-articles content-store)"
[[ "$(curl -sS -H "Host: ${ENVIRONMENT_NAME}--api-gateway.libero.pub" "${api_gateway}/blog-articles/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS -H "Host: ${ENVIRONMENT_NAME}--api-gateway.libero.pub" "${api_gateway}/blog-articles/items" --output /dev/null --write-out '%{http_code}' 2>&1)" == "200" ]]

echo "Smoke testing api-gateway (scholarly-articles content-store)"
[[ "$(curl -sS -H "Host: ${ENVIRONMENT_NAME}--api-gateway.libero.pub" "${api_gateway}/scholarly-articles/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS -H "Host: ${ENVIRONMENT_NAME}--api-gateway.libero.pub" "${api_gateway}/scholarly-articles/items" --output /dev/null --write-out '%{http_code}' 2>&1)" == "200" ]]

echo "Smoke testing api-gateway (search)"
[[ "$(curl -sS -H "Host: ${ENVIRONMENT_NAME}--api-gateway.libero.pub" "${api_gateway}/search/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS -H "Host: ${ENVIRONMENT_NAME}--api-gateway.libero.pub" "${api_gateway}/search" --output /dev/null --write-out '%{http_code}' 2>&1)" == "200" ]]

echo "Smoke testing dummy-api"
[[ "$(curl -sS -H "Host: ${ENVIRONMENT_NAME}--dummy-api.libero.pub" "${dummy_api}/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS -H "Host: ${ENVIRONMENT_NAME}--dummy-api.libero.pub" "${dummy_api}/blog-articles/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS -H "Host: ${ENVIRONMENT_NAME}--dummy-api.libero.pub" "${dummy_api}/blog-articles/items" --output /dev/null --write-out '%{http_code}' 2>&1)" == "200" ]]

echo "Smoke testing browser"
[[ "$(curl -sS -H "Host: ${ENVIRONMENT_NAME}.libero.pub" "${browser}" --output /dev/null --write-out '%{http_code}')" == "200" ]]
[[ "$(curl -sS --header "Host: ${ENVIRONMENT_NAME}.libero.pub" "${browser}/favicon.ico" --output /dev/null --write-out '%{http_code}')" == "200" ]]

echo "Smoke testing pattern library"
[[ "$(curl -sS --header "Host: ${ENVIRONMENT_NAME}--pattern-library.libero.pub" "${pattern_library}" --output /dev/null --write-out '%{http_code}')" == "200" ]]
