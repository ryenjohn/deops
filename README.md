# Simple FastAPI App — Containerized & Deployed

A small FastAPI application packaged with Docker, built & pushed via GitHub Actions (GHCR), and deployable to Kubernetes.  
This README explains the Dockerfile design and reasoning, CI/CD workflow, deployment steps, and testing instructions.

---

## Project Overview

This repository contains:

- A small FastAPI application in `app/`
- An optimized multi-stage `Dockerfile`
- GitHub Actions workflow to build and push images to GitHub Container Registry (GHCR)
- Kubernetes manifests (`k8s/`) for Namespace, Deployment and Service
- `docker-compose.yml` (optional) for local compose-based deployment

---

## 1. Dockerfile — design & reasoning

### Dockerfile (example)
```dockerfile
# Stage 1: build/install deps
FROM python:3.11-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends build-essential

COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt

# Stage 2: runtime image
FROM python:3.11-slim
WORKDIR /app

COPY --from=builder /install /usr/local
COPY app ./app

EXPOSE 8080

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

