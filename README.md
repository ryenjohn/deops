# NOTE
This my academy account, so Github username is not meet with my real username!

## Overview

This repository contains:

- A small FastAPI application in `app/`
- An optimized multi-stage `Dockerfile`
- GitHub Actions workflow to build and push images to GitHub Container Registry (GHCR)
- Deployment services with Docker compose `docker-compose.yml`

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
### Design Choices & Reasoning

Stage 1. Builder Stage
```
FROM python:3.11-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends build-essential
```
  - This stage contains tools required for building Python dependencies (e.g., compiling wheels)

  - Keeping these tools out of the final image makes it much smaller and more secure

Stage 1: Dependency Installation
```
COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt
```
  - Install dependencies into a temporary directory (/install)

  - Allows copying only the installed packages to the final image

  - Avoids pip cache → reduces size

Stage 2: Runtime Image
```
FROM python:3.11-slim
WORKDIR /app
```
  - Uses a fresh, clean Python 3.11 slim image

  - This stage does not include build tools → more secure & lightweight
  
Copy Only What Is Needed
```
COPY --from=builder /install /usr/local
COPY app ./app
```
  - Only runtime dependencies and source code are added to the final image

  - Keeps image size minimal

Expose 8080
```
EXPOSE 8080
```
  - Documents the port used by Uvicorn

  - Helps when running with Docker Compose or Kubernetes

Uvicorn Startup Command
```
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
```
  - Uvicorn is the recommended server for FastAPI

  - Binds to 0.0.0.0 → accessible inside Docker, Compose, or Kubernetes

  - Runs the API automatically when the container starts



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

### 8. Mock Deployment
```
echo "deployment..."
echo "docker pull ghcr.io/ryenjohn/ubuntu-v1:latest"
echo "docker compose up -d"
```
  This is a mock deployment step, used to simulate real CD.

  The step only prints commands instead of executing them.
  It demonstrates what a real deployment stage would do:

  - Pull updated image

  -Start containers using Docker Compose

  - Run the updated service

### Workflows Action in Github 
image registry
<img width="910" height="356" alt="image" src="https://github.com/user-attachments/assets/1a7e700d-d151-425d-88ee-6619deb2124a" />

workflows action ìmage`

<img width="1283" height="852" alt="image" src="https://github.com/user-attachments/assets/cf5e59c4-15a3-4c41-b6de-4ee799a4f6fe" />

It means everytime you update the projects to the Github, it will take take action and diplaying flow processing also a trigger.


---
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

### Simple API Access

Using Docker (container)
```
docker build -t ghcr.io/ryenjohn/hello-world-ghcr:latest .
docker run -p 8080:8080 

```
CLI/WEB `http://public-ipadress:8080/`

### Deployment service using Docker Compose
```
docker compose up -d
```
CLI/WEB `http://public-ipaddress:8080/`

### Repo structure

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





