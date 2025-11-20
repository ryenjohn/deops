# Simple Containerized API

This project demonstrates:
1. A simple API
2. Containerization using Docker
3. CI pipeline to build & push image
4. Deployment using Docker Compose (or Kubernetes)

---

## 1. Application Overview

The API is built with FastAPI and exposes one endpoint:

GET / → returns JSON response:
{
  "message": "Hello from containerized API!"
}

---

## 2. Dockerfile Design

A multi-stage Dockerfile is used to:
- Reduce final image size
- Install dependencies in a temporary builder image
- Copy only required packages to production image
- Use `python:3.11-slim` for minimal footprint

Benefits:
- Smaller image
- Faster deployments
- Secure (no compilers in final image)

---

## 3. CI/CD Workflow

GitHub Actions workflow does:

1. Checkout the repository  
2. Login to Docker Hub using secrets  
3. Build Docker image  
4. Push to Docker registry  
5. (Optional) Mock deploy

Trigger:
- Runs automatically on push to `main`

---

## 4. Deployment Instructions

### Option A — Docker Compose

1. Install Docker
2. Run:


API URL:  
http://localhost:8080/

---

### Option B — Kubernetes (Bonus)

Apply all manifests:


Service URL (NodePort):  
http://localhost:30080/

---

## 5. Testing the API

Test with curl:

curl http://localhost:8080/


Expected:

  {"message":"Hello from containerized API!"}

  
---

## 6. Repository Structure (Recommended)

.
├── app/
│ └── main.py
├── requirements.txt
├── Dockerfile
├── docker-compose.yml
├── k8s/
│ ├── namespace.yaml
│ ├── deployment.yaml
│ └── service.yaml
├── .github/
│ └── workflows/
│ └── docker-build.yml
└── README.md



---

# Submission

Please provide your GitHub repository URL once uploaded.
