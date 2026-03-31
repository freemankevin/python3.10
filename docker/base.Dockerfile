# =============================================================================
# Base Image - Python 3.10 Runtime with Pre-installed Dependencies
# Build: docker build -f docker/base.Dockerfile -t python-base:3.10 .
# =============================================================================

FROM python:3.10-slim

LABEL maintainer="DevOps Team" \
      image.type="base" \
      python.version="3.10"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    make \
    libpq-dev \
    libpq5 \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

WORKDIR /app

COPY requirements.txt .

RUN pip install --upgrade pip && pip install -r requirements.txt