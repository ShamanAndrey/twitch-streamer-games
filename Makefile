.PHONY: help build up down dev prod clean logs shell db-shell db-studio test lint format

# Default target
help:
	@echo "Available commands:"
	@echo "  build     - Build Docker images"
	@echo "  up        - Start production services"
	@echo "  down      - Stop all services"
	@echo "  dev       - Start development services"
	@echo "  prod      - Start production services with nginx"
	@echo "  clean     - Remove all containers, images, and volumes"
	@echo "  logs      - Show logs for all services"
	@echo "  shell     - Open shell in app container"
	@echo "  db-shell  - Open shell in database container"
	@echo "  db-studio - Start database studio (development)"
	@echo "  test      - Run tests"
	@echo "  lint      - Run linting"
	@echo "  format    - Format code"

# Build Docker images
build:
	docker-compose build

# Start production services
up:
	docker-compose up -d

# Stop all services
down:
	docker-compose down

# Start development services
dev:
	docker-compose -f docker-compose.dev.yml up -d

# Start production services with nginx
prod:
	docker-compose --profile production up -d

# Clean up everything
clean:
	docker-compose down -v --rmi all
	docker system prune -f

# Show logs
logs:
	docker-compose logs -f

# Open shell in app container
shell:
	docker-compose exec app sh

# Open shell in database container
db-shell:
	docker-compose exec postgres psql -U postgres -d $(shell grep DB_NAME .docker.env 2>/dev/null | cut -d'=' -f2 || echo "twitch_streamer_games")

# Start database studio
db-studio:
	docker-compose -f docker-compose.dev.yml --profile tools up -d db-studio

# Run tests
test:
	docker-compose exec app npm test

# Run linting
lint:
	docker-compose exec app npm run lint

# Format code
format:
	docker-compose exec app npm run format:write

# Development database operations
db-generate:
	docker-compose exec app npm run db:generate

db-migrate:
	docker-compose exec app npm run db:migrate

db-push:
	docker-compose exec app npm run db:push

# Quick start for new contributors
quickstart:
	@echo "Setting up development environment..."
	@if [ ! -f .docker.env ]; then \
		cp .docker.env.example .docker.env; \
		echo "Created .docker.env from template. Please edit with your settings."; \
	fi
	@echo "Starting development services..."
	@make dev
	@echo "Starting database studio..."
	@make db-studio
	@echo "Development environment ready!"
	@echo "App: http://localhost:3000"
	@echo "Database Studio: http://localhost:4983"
	@echo "Database: localhost:5432"

