# Stage 1: Build dependencies
FROM python:3.11-slim AS builder
WORKDIR /app

# Install build tools (for some libraries) — optional optimization
RUN apt-get update && apt-get install -y --no-install-recommends build-essential

# Install dependencies into /install directory
COPY requirements.txt .
RUN pip install --prefix=/install -r requirements.txt

# Stage 2: Production image
FROM python:3.11-slim
WORKDIR /app

# Copy installed Python packages
COPY --from=builder /install /usr/local

# Copy application source
COPY app ./app

EXPOSE 8080

# Run the app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]

