# sample-configuration
A sample configuration for deploying standard Libero services on a single VM with minimal defaults

## Usage

```
cp .env.dist .env
docker-compose up
```

Customize `.env` to:

- specify `REVISION_*` environment variables indicating the Docker image tags to use.
- override default options such as `PUBLIC_PORT`.
