
## Overview

This repository contains:

- A small FastAPI application in `app/`
- An optimized multi-stage `Dockerfile`
- GitHub Actions workflow to build and push images to GitHub Container Registry (GHCR)
- Deployment services with Docker compose

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
### Why this design?

  Multi-stage build: dependencies installed in a builder stage and copied to the runtime stage. This keeps the final image smaller and avoids shipping build tools.
  
  python:3.11-slim base: smaller attack surface and image size compared to full images.
  
  Install only what’s needed: pip install --prefix=/install -r requirements.txt isolates installed packages and avoids dev artifacts in the final image.
  
  Explicit EXPOSE 8080 and uvicorn command: app listens on 0.0.0.0:8080 so Kubernetes and Docker can route traffic correctly.
  
  WORKDIR /app: predictable container filesystem layout.
---
## 2. CI/CD — workflow explanation

  A CI/CD workflow is an automated process that helps development teams build, test, and deliver software faster and more reliably. It stands for Continuous Integration (CI), where code changes are automatically     merged and tested, and Continuous Delivery/Deployment (CD), which automates the release of those changes to a production environment. By using a CI/CD pipeline, developers can detect issues earlier, reduce manual work, and release updates more frequently. 

Workflows Action (.github/workflows/docker-build.yml)

```yml
name: Docker Image CI for GHCR

on:
  push:
    branches:
      - master

jobs:
  build_and_publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Login to GHCR
        run: echo "${{ secrets.GH_PAT }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin

      - name: Build Docker image
        run: docker build -f Dockerfile -t ghcr.io/ryenjohn/hello-world-ghcr:latest .

      - name: Push Docker image
        run: docker push ghcr.io/ryenjohn/hello-world-ghcr:latest

```

### 1. Workflow Name:
```
name: Docker Image CI for GHCR
```
This sets a human-readable name for your GitHub Actions workflow.
It helps you identify the pipeline in the GitHub Actions dashboard.

### 2. When the workflow runs
```
on:
  push:
    branches:
      - master

```
This means:

  The workflow runs automatically every time you push code to the master branch.

  If you commit or push a new change, the CI builds a new Docker image.


### 3. Job Definition
```
jobs:
  build_and_publish:
    runs-on: ubuntu-latest
```
- The workflow defines one job named build_and_publish.
- GitHub will run this job on a virtual machine using Ubuntu Linux.

### 4. Checkout source code
```
- uses: actions/checkout@v4
```
  This action clones your repository inside the GitHub Actions runner.
  Your Dockerfile and app code become available for building.

### 5. Login to GHCR
```
- name: Login to GHCR
  run: echo "${{ secrets.GH_PAT }}" | docker login ghcr.io -u ${{ github.actor }} --password-stdin
```
This authenticates Docker to GitHub Container Registry (GHCR).

  - ${{ secrets.GH_PAT }} → my personal access token stored securely in GitHub Secrets

  - ${{ github.actor }} → my GitHub username

  - docker login → logs in to the registry so you can push images

### 6. Build docker image
```
- name: Build Docker image
  run: docker build -f Dockerfile -t ghcr.io/ryenjohn/hello-world-ghcr:latest .
```
  This command:

  - Reads your Dockerfile (-f Dockerfile)

  - Builds the container image from the current folder (.)

  - Tags it as ghcr.io/ryenjohn/hello-world-ghcr:latest

### 7. Pust Docker Image
```
- name: Push Docker image
  run: docker push ghcr.io/ryenjohn/hello-world-ghcr:latest
```
  Once pushed:

  - You can run the image anywhere (Docker, K8s, etc.)

  - Kubernetes can pull this image for deployment

  - GHCR shows the image under Packages → hello-world-ghcr

### Workflows Action in Github

<img width="1283" height="852" alt="image" src="https://github.com/user-attachments/assets/cf5e59c4-15a3-4c41-b6de-4ee799a4f6fe" />


## 3. Deployment steps (Docker compose)

### 1. Create a YML file which name "docker-compose.yml"

```yml
services:
  api:
    image: ghcr.io/ryenjohn/hello-world-ghcr:latest
    ports:
      - "8080:8080"
```
### 2. Authenticate to GHCR
```
docker login ghcr.io -u ryenjohn -p GH_PAT
```
'GH_PAT' is Github personal Token

### 3. Start the Application
Running command to deploy service
```docker compose up -d```
Note: Running this command where your docker-compose.yml placed.

### 4. Verify Running Containers
```
docker ps
```

## 4. Testing instructions

### 1. Simple API Access

Using Docker (container)
```
docker build -t ghcr.io/ryenjohn/hello-world-ghcr:latest .
docker run -p 8080:8080 

```
CLI/WEB "http://public-ipadress:8080/"

### 2. Deployment service using Docker Compose
```
docker compose up -d
```
CLI/WEB "http://public-ipaddress:8080/"

### 3. Repo structure

workspace
├── app/
│   ├── main.py
│   └── __init__.py
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
├── .github/
│   └── workflows/
│       └── docker-build.yml
└── README.md

---





