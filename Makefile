.PHONY: help install install-dev test lint format clean build docker-build docker-run docker-test docker-docs version-bump release

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install package dependencies
	uv sync

install-dev: ## Install development dependencies
	uv sync --group dev

test: ## Run tests
	uv run pytest

test-cov: ## Run tests with coverage
	uv run pytest --cov=src/geow --cov-report=html --cov-report=term

lint: ## Run linting checks
	uv run ruff check .
	uv run pyright

format: ## Format code
	uv run ruff format .
	uv run ruff check --fix .

clean: ## Clean build artifacts
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	rm -rf .pytest_cache/
	rm -rf .coverage
	rm -rf htmlcov/
	rm -rf .ruff_cache/

build: ## Build package
	uv run python -m build

docker-build: ## Build Docker image
	docker build -t geow:latest .

docker-run: ## Run Docker container
	docker run -it --rm geow:latest

docker-test: ## Run tests in Docker
	docker-compose --profile testing run --rm test

docker-docs: ## Serve documentation in Docker
	docker-compose --profile documentation run --rm docs

docker-dev: ## Run development environment in Docker
	docker-compose --profile development run --rm dev



release: ## Create a new release
	@echo "Creating release with semantic-release..."
	uv run semantic-release publish

version: ## Show current version
	@uv run semantic-release version --print

changelog: ## Generate changelog
	@uv run semantic-release changelog

pre-commit: ## Install pre-commit hooks
	uv run pre-commit install

pre-commit-run: ## Run pre-commit on all files
	uv run pre-commit run --all-files

docs-build: ## Build documentation
	uv run mkdocs build

docs-serve: ## Serve documentation locally
	uv run mkdocs serve

check: ## Run all checks (lint, test, format)
	@echo "Running all checks..."
	@make lint
	@make test
	@make format
	@echo "All checks completed!"

ci: ## Run CI checks locally
	@echo "Running CI checks..."
	@make lint
	@make test-cov
	@make build
	@echo "CI checks completed!"