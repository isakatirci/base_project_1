# Project: Microservices with Spring Boot & Spring Cloud (Chapter 20)

## Commands
mvn clean install -DskipTests       # Full build (skip tests)
mvn clean verify                     # Build + run all tests
mvn test -pl microservices/product-service  # Test single module
docker compose up -d --build         # Start all services (Docker)
docker compose down                  # Stop all services
docker compose -f docker-compose-kafka.yml up -d  # Start with Kafka
.\test-em-all.ps1                    # End-to-end integration tests

## Architecture
- **Reactive Microservices**: Spring Boot 3.5, Java 21, WebFlux (Mono/Flux)
- **API Module** (`api/`): Shared interfaces (ProductService, ReviewService, RecommendationService), DTOs, Event model, custom exceptions
- **Util Module** (`util/`): GlobalControllerExceptionHandler, HttpErrorInfo, ServiceUtil
- **Core Services** (`microservices/`):
  - `product-service`: MongoDB (reactive), RabbitMQ/Kafka consumer
  - `recommendation-service`: MongoDB (reactive), RabbitMQ/Kafka consumer
  - `review-service`: MySQL (JPA), RabbitMQ/Kafka consumer
  - `product-composite-service`: Orchestrator, Resilience4j (CircuitBreaker, Retry, TimeLimiter)
- **Spring Cloud** (`spring-cloud/`):
  - `gateway`: Spring Cloud Gateway, TLS (8443), OAuth2 resource server
  - `authorization-server`: Spring Authorization Server (OAuth2/OIDC)
- **Config**: Centralized in `config-repo/` (mounted as volume)
- **Infra**: Docker Compose, Kubernetes + Helm + Istio, Zipkin distributed tracing
- **Messaging**: RabbitMQ (default) or Kafka (profile-based), event-driven via Spring Cloud Stream
- **Databases**: MongoDB (product, recommendation), MySQL (review)

## Conventions
- Package root: `se.magnus` (api, util, microservices, springcloud.gateway)
- API contracts are Java interfaces in `api/` module — implementations in respective services
- Use MapStruct for entity↔DTO mapping (annotation processor configured in pom.xml)
- Reactive types: Always return `Mono<T>` or `Flux<T>` from service interfaces
- Event-driven: Use `Event<K,V>` record from `se.magnus.api.event` for async messaging
- Exception hierarchy: `BadRequestException`, `InvalidInputException`, `NotFoundException`, `EventProcessingException`
- Docker images: `hands-on/{service-name}` naming convention
- Config profiles: `docker` profile for containerized, default for local
- All YAML configs externalized in `config-repo/`, never hardcoded

## Watch out for
- `.env` file contains DB/MQ credentials — NEVER commit production secrets
- Microservice source code may need generation via `create-projects.ps1`
- Docker Compose requires `.env` file with RABBITMQ_USR, MONGODB_USR, MYSQL_USR, GATEWAY_TLS_PWD
- Gateway listens on HTTPS port 8443 with self-signed TLS cert
- MapStruct requires annotation processor in maven-compiler-plugin config
- Resilience4j configs are in `config-repo/product-composite.yml`, not in application code
- Kubernetes deployment uses Helm charts in `kubernetes/helm/` with environments separation
- Auth0 integration scripts in `auth0/` folder — requires tenant setup
