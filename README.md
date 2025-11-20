1. Overview

'This project demonstrates a complete CI/CD workflow for containerizing and deploying a simple API application.
It includes:

A lightweight FastAPI application

Optimized Dockerfile using multi-stage builds

GitHub Actions workflow for CI/CD that builds and pushes an image to GitHub Container Registry (GHCR)

Kubernetes manifests for deployment (Namespace, Deployment, Service)'

---

2. Dockerfile Design & Reasoning
Multi-stage build for smaller images

The Dockerfile uses a builder stage to install dependencies and a final stage to keep the runtime image small.

Python 3.11 slim base

Using python:3.11-slim reduces size and improves security.

 Working directory structure
