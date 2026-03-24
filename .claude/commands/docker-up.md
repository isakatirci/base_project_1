---
description: Start all services with Docker Compose and verify health
---
## Start Services
!`docker compose up -d --build 2>&1 | tail -20`

## Container Status
!`docker compose ps`

## Health Check
Wait 30 seconds for services to initialize, then check:

1. **All containers running**: Verify 9 containers are up (product, recommendation, review, product-composite, gateway, auth-server, mongodb, mysql, rabbitmq)
2. **Gateway reachable**: `https://localhost:8443/actuator/health`
3. **Auth Server healthy**: `http://localhost:4004/actuator/health`
4. **RabbitMQ Management**: `http://localhost:15672`

Report any containers that failed to start with their logs:
!`docker compose logs --tail=10 2>&1 | grep -i "error\|fail\|exception" | head -20`
