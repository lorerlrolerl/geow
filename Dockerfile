# Multi-stage Dockerfile for geow package development
FROM python:3.12-slim as base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pyproject.toml uv.lock* ./

# Install dependencies with uv
RUN uv sync --frozen

# Copy source code
COPY . .

# Install the package in editable mode
RUN uv pip install -e .

# Development stage
FROM base as dev

# Install development dependencies
RUN uv sync --group dev

# Install pre-commit hooks
RUN pre-commit install

# Expose port for documentation (if needed)
EXPOSE 8000

# Default command for development
CMD ["uv", "run", "pytest"]

# Test stage
FROM base as test

# Install test dependencies
RUN uv sync --group test

# Run tests
CMD ["uv", "run", "pytest", "--cov=src/geow", "--cov-report=html", "--cov-report=term"]

# Documentation stage
FROM base as docs

# Install documentation dependencies
RUN uv sync --group docs

# Build documentation
RUN uv run mkdocs build

# Serve documentation
CMD ["uv", "run", "mkdocs", "serve", "-a", "0.0.0.0:8000"]

# Production stage
FROM base as prod

# Install only runtime dependencies
RUN uv pip install --no-deps .

# Create non-root user
RUN useradd --create-home --shell /bin/bash app && \
    chown -R app:app /app
USER app

# Default command
CMD ["python", "-c", "import geow; print('Geow package loaded successfully')"]


