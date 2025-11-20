# Overview

This project demonstrates how to:

Containerize a simple application using Docker

Automate image building and pushing with GitHub Actions

Deploy the application using Kubernetes

Provide clear documentation for setup, deployment, and testing

# 1. Dockerfile Design & Reasoning
Dockerfile Summary

Explain:

Base image choice

Why you used multi-stage build (if used)

How you optimized image size

Ports exposed

CMD vs ENTRYPOINT decisions

"Dockerfile"
Stage 1: Build dependencies
FROM python:3.11-slim AS builder
WORKDIR /home/devops/workspace/app

RUN apt-get update && apt-get install -y --no-install-recommends build-essential

COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt

Stage 2: Production image
FROM python:3.11-slim
WORKDIR /home/devops/workspace/app

COPY --from=builder /install /usr/local
COPY app ./app

EXPOSE 8080

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
