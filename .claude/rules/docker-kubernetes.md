---
paths:
  - "**/Dockerfile"
  - "**/docker-compose*.yml"
  - "kubernetes/**"
  - "config-repo/**"
---
# Docker, Kubernetes & Infrastructure

## Docker
- Image naming: `hands-on/{service-name}` (e.g., `hands-on/product-service`)
- Dockerfile pattern: Multi-stage build with `eclipse-temurin` base for Java 21
- Memory limits: 512MB for services, 1024MB for Zipkin
- Always use health checks with `wget` or `curl` for readiness

## Docker Compose
- Environment variables from `.env` file (RABBITMQ_USR, MONGODB_USR, MYSQL_USR, etc.)
- Config-repo mounted as volume: `$PWD/config-repo:/config-repo`
- Profiles: `docker-compose.yml` (RabbitMQ), `docker-compose-kafka.yml` (Kafka)
- `docker-compose-partitions.yml` for partition-based messaging
- Service dependencies: Use `condition: service_healthy` for ordered startup

## Spring Config
- All YAML configs in `config-repo/` — one file per service
- `SPRING_CONFIG_LOCATION` env var points to config-repo mount
- `SPRING_PROFILES_ACTIVE=docker` activates container-specific config
- Sensitive values injected via environment variables, never in YAML files

## Kubernetes / Helm
- Helm charts in `kubernetes/helm/` with structure: common, components, environments
- Namespace: `hands-on` (defined in `hands-on-namespace.yml`)
- Istio service mesh for mTLS, traffic management, and telemetry
- Istio configs: `istio-telemetry.yml`, `istio-tracing.yml`
- Resilience tests: `kubernetes/resilience-tests/`
- Routing/canary tests: `kubernetes/routing-tests/`

## Security
- Gateway TLS on port 8443 with JKS keystore (password from `GATEWAY_TLS_PWD`)
- OAuth2 Authorization Server on port 4004
- Never hardcode credentials in Docker/K8s manifests — use secrets
- Auth0 integration scripts in `auth0/` for multi-tenant setup
