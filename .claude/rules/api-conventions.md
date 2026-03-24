---
paths:
  - "api/src/**/*.java"
  - "microservices/**/services/**/*.java"
  - "microservices/**/persistence/**/*.java"
---
# API Design Conventions

## Interface-First Design
- All REST endpoints are defined as Java interfaces in `api/` module
- Service implementations in microservices implement these interfaces
- This enables shared contract across composite service (WebClient) and core services

## REST Endpoints
- GET endpoints use `@GetMapping` with `produces = "application/json"`
- Accept `@RequestHeader HttpHeaders` for distributed tracing propagation
- Support optional query params: `delay` (fault injection), `faultPercent` (chaos testing)
- Use `@PathVariable` for resource identifiers

## Event-Driven Messaging
- Use `Event<K, V>` record from `se.magnus.api.event` for async commands
- Event types: `CREATE`, `DELETE` — use enum `Event.Type`
- Events are published via Spring Cloud Stream bindings
- Consumers process events idempotently

## Data Layer
- MongoDB services: Use `ReactiveMongoRepository`, reactive operations throughout
- MySQL services: Use `JpaRepository` + `Schedulers.boundedElastic()` wrapper
- Entity mapping: MapStruct mappers convert between API DTOs and persistence entities
- Unique index enforcement for deduplication (e.g., productId)

## Resilience (product-composite-service)
- CircuitBreaker: Configured via config-repo, not annotations
- Retry: Use `spring-retry` for transient failures
- TimeLimiter: Configurable timeout per operation
- Fallback: Provide degraded response, never throw to client on circuit open
