1. Overview

This project demonstrates a complete CI/CD workflow for containerizing and deploying a simple API application.
It includes:

A lightweight FastAPI application

Optimized Dockerfile using multi-stage builds

GitHub Actions workflow for CI/CD that builds and pushes an image to GitHub Container Registry (GHCR)

Kubernetes manifests for deployment (Namespace, Deployment, Service)

---

2. Dockerfile Design & Reasoning
**Multi-stage build for smaller images**
The Dockerfile uses a builder stage to install dependencies and a final stage to keep the runtime image small.

**Python 3.11 slim base**
Using python:3.11-slim reduces size and improves security.

** Working directory structure**
/home/devops/workspace/app

**Uvicorn used as production ASGI server**
uvicorn app.main:app --host 0.0.0.0 --port 8080

# Stage 1: Build dependencies
FROM python:3.11-slim AS builder
WORKDIR /home/devops/workspace/app

RUN apt-get update && apt-get install -y --no-install-recommends build-essential

COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt

# Stage 2: Production image
FROM python:3.11-slim
WORKDIR /home/devops/workspace/app

COPY --from=builder /install /usr/local
COPY app ./app

EXPOSE 8080

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

