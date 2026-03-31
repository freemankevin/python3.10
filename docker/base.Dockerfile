# =============================================================================
# Base Image Dockerfile - Python 运行环境基础镜像
# 包含系统依赖和常用工具，由 GitHub Actions 自动构建并推送到 Harbor
# =============================================================================
# 构建命令: docker build -f docker/base.Dockerfile -t harbor.cce.up.gz:443/cspon/python-base:3.10 .
# =============================================================================

FROM python:3.10-slim

# Labels for base image metadata
LABEL maintainer="DevOps Team" \
      image.type="base" \
      python.version="3.10" \
      description="Python 3.10 基础镜像，包含常用系统依赖"

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Configure pip to use Aliyun mirror (阿里云 PyPI 镜像)
RUN pip config set global.index-url https://mirrors.aliyun.com/pypi/simple/ \
    && pip config set install.trusted-host mirrors.aliyun.com

# Install system dependencies for Python applications
# - gcc: 编译 Python 包（如 psycopg2）
# - libpq-dev: PostgreSQL 开发库
# - curl: 健康检查和 HTTP 请求
# - 其他常用工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    # 编译工具
    gcc \
    g++ \
    make \
    # PostgreSQL 客户端库
    libpq-dev \
    libpq5 \
    # 常用工具
    curl \
    wget \
    # 网络工具
    ca-certificates \
    # 清理缓存
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create non-root user for security (所有应用共用)
RUN groupadd --gid 1000 appgroup && \
    useradd --uid 1000 --gid appgroup --shell /bin/bash --create-home appuser

# Create common directories
RUN mkdir -p /app /app/logs /opt/venv && \
    chown -R appuser:appgroup /app /opt/venv

# Set working directory
WORKDIR /app

# Default user
USER appuser