# Car Marketplace Microservices

A Java 21 + Spring Boot 3 monorepo for a used car marketplace university cloud computing project.

## Repository Structure

- `services/user-service` - JWT auth, registration/login, user CRUD, PostgreSQL
- `services/listing-service` - car listing CRUD, PostgreSQL
- `services/prediction-service` - placeholder car price prediction API
- `infrastructure/kubernetes` - Kubernetes manifests
- `infrastructure/docker` - Docker-related support files
- `infrastructure/docs` - environment examples and docs

## Architecture

- Database-per-service pattern:
  - user-service -> `userdb`
  - listing-service -> `listingdb`
- Each microservice is a separate Gradle project.
- Each service includes layered packages:
  - `controller`, `service`, `repository`, `dto`, `entity`, `security`
- Environment-variable based configuration in `application.yml`.
- Spring Boot Actuator health endpoint exposed at `/actuator/health`.

## Local Development

### Prerequisites

- Java 21
- Docker and Docker Compose

### Run with Docker Compose

```bash
docker compose up --build
```

Services:

- User service: `http://localhost:8081`
- Listing service: `http://localhost:8082`
- Prediction service: `http://localhost:8083`

## API Overview

### User Service

- `POST /auth/register`
- `POST /auth/login`
- `GET /users`
- `GET /users/{id}`
- `POST /users`
- `PUT /users/{id}`
- `DELETE /users/{id}`

### Listing Service

- `GET /cars`
- `GET /cars/{id}`
- `POST /cars`
- `PUT /cars/{id}`
- `DELETE /cars/{id}`

### Prediction Service

- `POST /predictions/price`

## Kubernetes

Manifests are under `infrastructure/kubernetes` and include:

- Deployment
- Service
- ConfigMap
- Secret
- Ingress routes:
  - `/auth` -> `user-service`
  - `/cars` -> `listing-service`

Apply manifests (example):

```bash
kubectl apply -f infrastructure/kubernetes/user-service/
kubectl apply -f infrastructure/kubernetes/listing-service/
kubectl apply -f infrastructure/kubernetes/prediction-service/
kubectl apply -f infrastructure/kubernetes/ingress.yaml
```

## Environment Variables

See `infrastructure/docs/env.example` for example configuration values.
