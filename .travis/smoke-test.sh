#!/bin/bash
set -ex

COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-sample-configuration}"
HTTP_PORT="${HTTP_PORT:-8080}"

echo "Wait for containers health"
.scripts/docker/wait-healthy.sh "${COMPOSE_PROJECT_NAME}_dummy-api_fpm_1"
.scripts/docker/wait-healthy.sh "${COMPOSE_PROJECT_NAME}_browser_fpm_1"
.scripts/docker/wait-healthy.sh "${COMPOSE_PROJECT_NAME}_web_1"

echo "Smoke testing dummy-api"
[[ "$(curl -sS -H 'Host: unstable--dummy-api.libero.pub' "http://localhost:${HTTP_PORT}/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS -H 'Host: unstable--dummy-api.libero.pub' "http://localhost:${HTTP_PORT}/blog-articles/ping" 2>&1)" == "pong" ]]
[[ "$(curl -sS -H 'Host: unstable--dummy-api.libero.pub' "http://localhost:${HTTP_PORT}/blog-articles/items" --output /dev/null --write-out '%{http_code}' 2>&1)" == "200" ]]

echo "Smoke testing browser"
[[ "$(curl -sS -H 'Host: unstable.libero.pub' "http://localhost:${HTTP_PORT}/blog/post1" --output /dev/null --write-out '%{http_code}')" == "200" ]]
[[ "$(curl -sS --header 'Host: unstable.libero.pub' "http://localhost:${HTTP_PORT}/favicon.ico" --output /dev/null --write-out '%{http_code}')" == "200" ]]
