#!/bin/bash
set -e

echo "Smoke testing dummy-api"
[[ "$(curl -sS -H 'Host: unstable--dummy-api.libero.pub' http://localhost:8080/ping 2>&1)" == "pong" ]]

echo "Smoke testing browser"
[[ "$(curl -sS -H 'Host: unstable.libero.pub' http://localhost:8080/articles/42 2>&1)" == "42" ]]
