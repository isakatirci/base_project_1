---
description: Review the current branch diff for code quality, architecture compliance, and security
---
## Branch Changes
!`git diff --name-only main...HEAD`

## Detailed Diff
!`git diff main...HEAD`

## Review Criteria
Analyze the above changes as a Senior Principal Consultant specializing in Java/Spring microservices. Review for:

1. **Reactive Correctness**: No blocking calls in reactive chains, proper Mono/Flux usage, correct scheduler usage for JPA
2. **API Contract Compliance**: Interfaces in `api/` module respected, correct return types (Mono/Flux), proper exception usage
3. **Resilience Patterns**: CircuitBreaker, Retry, TimeLimiter properly configured — no single points of failure
4. **Event-Driven Design**: Idempotent consumers, proper Event<K,V> usage, Spring Cloud Stream bindings correct
5. **Security**: No credential leaks, OAuth2/JWT properly configured, .env not committed
6. **MapStruct Usage**: Mappers annotated correctly, no manual DTO conversion where MapStruct should be used
7. **Docker/K8s**: Dockerfile best practices, health checks present, resource limits set
8. **Testing**: Adequate test coverage, StepVerifier for reactive, integration tests with containers

Provide specific, actionable feedback per file with severity: CRITICAL / WARNING / SUGGESTION.
