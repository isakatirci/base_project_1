---
paths:
  - "**/*.java"
  - "**/pom.xml"
---
# Java & Spring Code Style

## Language & Framework
- Java 21 — use records, sealed classes, pattern matching where appropriate
- Spring Boot 3.5 with WebFlux (reactive stack)
- Never mix blocking and non-blocking code in reactive pipelines

## Naming & Structure
- Package root: `se.magnus`
- Service implementations: `se.magnus.microservices.core.{domain}.services`
- Controllers implement interfaces from `se.magnus.api.core.{domain}`
- Entity classes: `{Domain}Entity` in `persistence/` package
- Mapper interfaces: `{Domain}Mapper` using MapStruct `@Mapper(componentModel = "spring")`

## Reactive Patterns
- Return `Mono<T>` for single items, `Flux<T>` for collections
- Use `subscribeOn(Schedulers.boundedElastic())` for blocking JPA calls (review-service)
- Chain operators: `map`, `flatMap`, `zipWith` — never call `.block()`
- Error handling: `onErrorMap()` to translate exceptions in reactive chains

## Exception Handling
- Use project exceptions: `NotFoundException`, `InvalidInputException`, `BadRequestException`
- `GlobalControllerExceptionHandler` in util module handles all REST error responses
- Response format: `HttpErrorInfo(httpStatus, path, message)`
- Never expose stack traces or internal details to clients

## Dependencies
- Shared modules `api` and `util` are project dependencies (version: `${project.version}`)
- MapStruct annotation processor must be in `maven-compiler-plugin` config
- Use Spring Cloud Stream for messaging abstraction (RabbitMQ/Kafka)
- Resilience4j for circuit breaker, retry, rate limiter, time limiter

## Testing
- Unit tests: JUnit 5 + Mockito
- Integration tests: `@SpringBootTest` with embedded containers
- Reactive tests: `StepVerifier` for Mono/Flux assertions
- Always test both happy path and error scenarios
