# sample-configuration
A sample configuration for deploying standard Libero services on a single VM with minimal defaults

## Usage

```
cp .env.dist .env
.docker/initialize-volumes.sh
docker-compose pull
docker-compose up
```

Load applications at:

- https://localhost:8080 (`browser`)
- https://localhost:8081 (`api-gateway`)
- https://localhost:8082 (`pattern-library`)
- https://localhost:8083 (`dummy-api`)
- https://localhost:8085 (`jats-ingester`)

Customize `.env` to:

- specify `REVISION_*` environment variables indicating the Docker image tags to use.
- override default options such as `PUBLIC_PORT_HTTP`.
