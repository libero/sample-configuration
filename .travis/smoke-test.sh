#!/bin/bash
set -ex

COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-sample-configuration}"
HTTP_PORT="${HTTP_PORT:-8080}"
HTTP_PORT_GATEWAY="${HTTP_PORT_GATEWAY:-8081}"
HTTP_PORT_JATS_INGESTER="${HTTP_PORT_JATS_INGESTER:-8085}"

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
    .scripts/docker/wait-healthy.sh "${COMPOSE_PROJECT_NAME}_${service}_1" 240
done

echo "Smoke testing jats-ingester"
[[ "$(curl -sS "http://localhost:${HTTP_PORT_JATS_INGESTER}/" --output /dev/null --write-out '%{http_code}' 2>&1)" == "200" ]]

echo "Smoke testing api-gateway (blog-articles content-store)"
[[ "$(curl -sS "http://localhost:${HTTP_PORT_GATEWAY}/blog-articles/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS "http://localhost:${HTTP_PORT_GATEWAY}/blog-articles/items" --output /dev/null --write-out '%{http_code}' 2>&1)" == "200" ]]

echo "Smoke testing api-gateway (scholarly-articles content-store)"
[[ "$(curl -sS "http://localhost:${HTTP_PORT_GATEWAY}/scholarly-articles/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS "http://localhost:${HTTP_PORT_GATEWAY}/scholarly-articles/items" --output /dev/null --write-out '%{http_code}' 2>&1)" == "200" ]]

echo "Smoke testing api-gateway (search)"
[[ "$(curl -sS "http://localhost:${HTTP_PORT_GATEWAY}/search/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS "http://localhost:${HTTP_PORT_GATEWAY}/search" --output /dev/null --write-out '%{http_code}' 2>&1)" == "200" ]]

echo "Smoke testing dummy-api"
[[ "$(curl -sS -H 'Host: unstable--dummy-api.libero.pub' "http://localhost:${HTTP_PORT}/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS -H 'Host: unstable--dummy-api.libero.pub' "http://localhost:${HTTP_PORT}/blog-articles/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS -H 'Host: unstable--dummy-api.libero.pub' "http://localhost:${HTTP_PORT}/blog-articles/items" --output /dev/null --write-out '%{http_code}' 2>&1)" == "200" ]]

echo "Smoke testing browser"
[[ "$(curl -sS -H 'Host: unstable.libero.pub' "http://localhost:${HTTP_PORT}/" --output /dev/null --write-out '%{http_code}')" == "200" ]]
[[ "$(curl -sS --header 'Host: unstable.libero.pub' "http://localhost:${HTTP_PORT}/favicon.ico" --output /dev/null --write-out '%{http_code}')" == "200" ]]

echo "Smoke testing pattern library"
[[ "$(curl -sS --header 'Host: unstable--pattern-library.libero.pub' "http://localhost:${HTTP_PORT}" --output /dev/null --write-out '%{http_code}')" == "200" ]]
