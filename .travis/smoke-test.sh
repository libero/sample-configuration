#!/bin/bash
set -ex

COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-sampleconfiguration}"

.scripts/docker/wait-healthy.sh "${COMPOSE_PROJECT_NAME}_dummy-api_fpm_1"
echo "Smoke testing dummy-api"
[[ "$(curl -sS -H 'Host: unstable--dummy-api.libero.pub' http://localhost:8080/ping 2>&1)" == "pong" ]]

.scripts/docker/wait-healthy.sh "${COMPOSE_PROJECT_NAME}_browser_fpm_1"
echo "Smoke testing browser"
[[ "$(curl -sS -H 'Host: unstable.libero.pub' http://localhost:8080/articles/42 2>&1)" == "42" ]]
[[ "$(curl -sS --header 'Host: unstable.libero.pub' http://localhost:8080/favicon.ico --output /dev/null --write-out '%{http_code}')" == "200" ]]
