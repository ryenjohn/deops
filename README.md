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

### Dockerfile 
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
```
Why this design?

Multi-stage build: dependencies installed in a builder stage and copied to the runtime stage. This keeps the final image smaller and avoids shipping build tools.

python:3.11-slim base: smaller attack surface and image size compared to full images.

Install only what’s needed: pip install --prefix=/install -r requirements.txt isolates installed packages and avoids dev artifacts in the final image.

Explicit EXPOSE 8080 and uvicorn command: app listens on 0.0.0.0:8080 so Kubernetes and Docker can route traffic correctly.

WORKDIR /app: predictable container filesystem layout.

Tip: Keep requirements.txt minimal and freeze versions for reproducible builds.

---
## 2. CI/CD — GitHub Actions workflow explanation
 Purpose:

- Automatically build Docker image on push to master

- Push image to GHCR (ghcr.io/<username>/<image>:tag)
  

### Secrets required (Repository → Settings → Secrets)

- GH_PAT — GitHub Personal Access Token with read:packages (and repo if repo is private)

### Workflows (.github/workflows/docker-build.yml)

```yml

name: Build and Push Docker Image

on:
  push:
    branches: ["master"]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Login to GHCR
        run: echo "${{ secrets.GH_PAT }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin

      - name: Build image
        run: docker build -t ghcr.io/${{ github.repository_owner }}/simple-fastapi:latest .

      - name: Push image
        run: docker push ghcr.io/${{ github.repository_owner }}/simple-fastapi:latest

      - name: Mock deployment
        run: |
          echo "Deployment would run here (mock)."
```
### Notes
- Using ${{ secrets.GH_PAT }} avoids storing credentials in plaintext.

- workflow_dispatch lets you trigger the pipeline manually from the Actions UI.

- You can tag images with commit SHA for traceability (e.g., :${{ github.sha }}).

## 3. Deployment steps
### A: Docker Compose

```yml

version: "3.9"
services:
  api:
    image: ghcr.io/<your-username>/simple-fastapi:latest
    ports:
      - "8080:8080"
```

### RUN
```docker compose up -d```

## 4. Testing instructions

### 1. Create & activate venv:
## Local (without Docker)
```
python -m venv venv
source venv/bin/activate    # Linux/macOS
venv\Scripts\activate       # Windows
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8080
```
### 2. http://127.0.0.1:8080/

## Using Docker (local container)
```
docker build -t simple-fastapi .
docker run -p 8080:8080 simple-fastapi
curl http://localhost:8080/
```
## Using Docker Compose

```
docker compose up -d
curl http://<server-ip>:8080/
```

# Repo structure

├── app/
│   ├── main.py
│   └── __init__.py
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── .github/
│   └── workflows/
│       └── docker-build.yml
└── README.md







