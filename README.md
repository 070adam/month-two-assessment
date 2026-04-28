# MuchToDo Container Assessment

This repository contains the Docker and Kubernetes setup for the MuchToDo backend API.

## Application layout

The Go backend lives in:

```text
Server/MuchToDo
```

The API listens on port `8080` and connects to MongoDB using environment variables.

## What is included

- Multi-stage `Dockerfile`
- `docker-compose.yml` for local development
- Kubernetes manifests under `kubernetes/`
- Helper scripts under `scripts/`
- Kind cluster config in `kind-config.yaml`

## Local Docker development

### 1. Build the image

```bash
./scripts/docker-build.sh
```

### 2. Start the stack

```bash
./scripts/docker-run.sh
```

The application will be available at:

```text
http://localhost:8080
http://localhost:8080/health
```

MongoDB will be available on `localhost:27017`.

## Kubernetes on Kind

### 1. Create the cluster

```bash
kind create cluster --name muchtodo --config kind-config.yaml
```

### 2. Build and load the backend image

```bash
docker build -t muchtodo-backend:latest -f Dockerfile .
kind load docker-image muchtodo-backend:latest --name muchtodo
```

### 3. Install ingress-nginx for Kind

The deployment script applies the Kind-compatible ingress controller manifest automatically. If you prefer to do it manually, apply the ingress-nginx Kind manifest before creating the Ingress resource.

### 4. Deploy everything

```bash
./scripts/k8s-deploy.sh
```

### 5. Check the app

NodePort access:

```text
http://localhost:30080/health
```

Ingress access:

```text
http://muchtodo.local/
```

If your machine does not resolve `muchtodo.local`, add it to your hosts file and point it to `127.0.0.1`.

## Environment variables

### Backend

- `PORT`
- `DB_NAME`
- `MONGO_URI`
- `JWT_SECRET_KEY`
- `JWT_EXPIRATION_HOURS`
- `ENABLE_CACHE`
- `LOG_LEVEL`
- `LOG_FORMAT`

### MongoDB

- `MONGO_INITDB_ROOT_USERNAME`
- `MONGO_INITDB_ROOT_PASSWORD`
- `MONGO_INITDB_DATABASE`

## Evidence checklist

Create screenshots of:

- Docker build finishing successfully
- `docker compose` running
- `/health` responding in Docker Compose
- Kind cluster creation
- Kubernetes pods running
- Services and ingress listing
- App reachable through NodePort or ingress
Store the screenshots in the `evidence/` folder.

## Cleanup

```bash
./scripts/k8s-cleanup.sh
```
## Errors
I encountered errors in the docker 
compose health check, Pinging was unsuccessful. 
The same was seen in the reachablity test for Nodeport.