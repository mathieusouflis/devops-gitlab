# Docker Compose at repo root; loads .env when present
COMPOSE ?= docker compose
-include .env

.PHONY: help up down down-v build rebuild ps logs logs-all restart stop start shell clean prune

.DEFAULT_GOAL := help

help: ## Show available targets and URLs
	@printf '\n  Docker containers\n\n'
	@echo '  App:    http://localhost:8088'
	@echo '  API:    http://localhost:3000'
	@echo '  Vite:   http://localhost:5173'
	@echo ''
	@echo 'Targets:'
	@grep -E '^[a-zA-Z0-9_.-]+:.*?## ' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-16s\033[0m %s\n", $$1, $$2}'
	@echo ''

up: ## Start all services in the background
	$(COMPOSE) up -d

down: ## Stop and remove containers
	$(COMPOSE) down

down-v: ## Full reset: containers, volumes, orphans, local images (then make rebuild)
	$(COMPOSE) down -v --remove-orphans --rmi local

build: ## Build images without starting
	$(COMPOSE) build

rebuild: ## Rebuild images without cache, then start
	$(COMPOSE) build --no-cache
	$(COMPOSE) up -d

ps: ## List containers and status
	$(COMPOSE) ps -a

logs: ## Follow logs; example make logs s=frontend or s=backend
	@if [ -n "$(s)" ]; then $(COMPOSE) logs -f "$(s)"; else $(COMPOSE) logs -f; fi

logs-all: ## Follow logs for all services with tail buffer
	$(COMPOSE) logs -f --tail=200

restart: ## Restart services; optional s=service name
	@if [ -n "$(s)" ]; then $(COMPOSE) restart "$(s)"; else $(COMPOSE) restart; fi

stop: ## Stop containers without removing them
	$(COMPOSE) stop

start: ## Start existing stopped containers
	$(COMPOSE) start

shell: ## Open sh in a container; requires s=service name
	@if [ -z "$(s)" ]; then echo 'Usage: make shell s=backend'; exit 1; fi
	$(COMPOSE) exec "$(s)" sh

clean: ## Stop project and remove locally built images
	$(COMPOSE) down --rmi local

prune: ## Run docker system prune on unused Docker data
	@echo 'Running docker system prune -f'
	docker system prune -f

# Terragrunt deploy (local) — set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, ECR_REPOSITORY_ARN in .env
TG_STAGING_DIR := devops/live/staging
TG_PROD_DIR    := devops/live/prod

.PHONY: deploy-staging deploy-prod destroy-staging destroy-prod _tg-apply _tg-destroy

deploy-staging: ## Run terragrunt apply for staging (reads creds from .env)
	@$(MAKE) _tg-apply TG_DIR=$(TG_STAGING_DIR)

deploy-prod: ## Run terragrunt apply for production (reads creds from .env)
	@$(MAKE) _tg-apply TG_DIR=$(TG_PROD_DIR)

destroy-staging: ## Run terragrunt destroy for staging (reads creds from .env)
	@$(MAKE) _tg-destroy TG_DIR=$(TG_STAGING_DIR)

destroy-prod: ## Run terragrunt destroy for production (reads creds from .env)
	@$(MAKE) _tg-destroy TG_DIR=$(TG_PROD_DIR)

_tg-apply:
	$(if $(TG_DIR),,$(error TG_DIR is not set))
	$(if $(AWS_ACCESS_KEY_ID),,$(error AWS_ACCESS_KEY_ID is not set — add it to .env))
	$(if $(AWS_SECRET_ACCESS_KEY),,$(error AWS_SECRET_ACCESS_KEY is not set — add it to .env))
	cd $(TG_DIR) && \
	AWS_ACCESS_KEY_ID="$(AWS_ACCESS_KEY_ID)" \
	AWS_SECRET_ACCESS_KEY="$(AWS_SECRET_ACCESS_KEY)" \
	TF_VAR_app_postgres_user="$(POSTGRES_USER)" \
	TF_VAR_app_postgres_password="$(POSTGRES_PASSWORD)" \
	TF_VAR_ecr_repository_arn="$(ECR_REPOSITORY_ARN)" \
	terragrunt apply --auto-approve

_tg-destroy:
	$(if $(TG_DIR),,$(error TG_DIR is not set))
	$(if $(AWS_ACCESS_KEY_ID),,$(error AWS_ACCESS_KEY_ID is not set — add it to .env))
	$(if $(AWS_SECRET_ACCESS_KEY),,$(error AWS_SECRET_ACCESS_KEY is not set — add it to .env))
	@echo "WARNING: this will destroy all resources in $(TG_DIR). Press Ctrl+C within 5s to abort."
	@sleep 5
	cd $(TG_DIR) && \
	AWS_ACCESS_KEY_ID="$(AWS_ACCESS_KEY_ID)" \
	AWS_SECRET_ACCESS_KEY="$(AWS_SECRET_ACCESS_KEY)" \
	TF_VAR_app_postgres_user="$(POSTGRES_USER)" \
	TF_VAR_app_postgres_password="$(POSTGRES_PASSWORD)" \
	TF_VAR_ecr_repository_arn="$(ECR_REPOSITORY_ARN)" \
	terragrunt destroy --auto-approve

# GitLab Runner (local)
RUNNER_COMPOSE ?= docker compose -f docker-compose.runner.yaml

.PHONY: runner-up runner-down runner-logs runner-unregister runner-reset runner-setup

runner-up: ## Start the local GitLab Runner and MinIO (services already registered)
	$(RUNNER_COMPOSE) up -d

runner-down: ## Stop the local GitLab Runner and MinIO
	$(RUNNER_COMPOSE) down

runner-unregister: ## Unregister and remove local runner config
	$(RUNNER_COMPOSE) run --rm gitlab-runner unregister --all-runners
	$(RUNNER_COMPOSE) down -v

runner-reset: ## Force-wipe runner, cache and MinIO volumes (fixes stale state; re-run runner-setup after)
	$(RUNNER_COMPOSE) down -v

runner-logs: ## Follow local GitLab Runner logs
	$(RUNNER_COMPOSE) logs -f

runner-setup: ## Full setup: start services, create cache bucket, register and configure runner (requires GITLAB_RUNNER_TOKEN)
	$(if $(GITLAB_RUNNER_TOKEN),,$(error GITLAB_RUNNER_TOKEN not set. Pass it as an argument or add it to .env))
	$(RUNNER_COMPOSE) up -d
	@docker run --rm --network runner-net \
		-e MC_HOST_local=http://minioadmin:minioadmin@minio:9000 \
		minio/mc mb --ignore-existing local/gitlab-runner-cache
	$(RUNNER_COMPOSE) run --rm gitlab-runner register \
		--non-interactive \
		--url https://gitlab.com \
		--token "$(GITLAB_RUNNER_TOKEN)" \
		--executor docker \
		--docker-image docker:27.0.3 \
		--docker-privileged \
		--description "local-$(shell hostname)"
	@$(RUNNER_COMPOSE) exec gitlab-runner \
		sed -i 's/\[runners\.cache\]/[runners.cache]\n  Type = "s3"\n  Shared = true/' \
		/etc/gitlab-runner/config.toml
	@$(RUNNER_COMPOSE) exec gitlab-runner \
		sed -i '/\[runners\.cache\.s3\]/a\    ServerAddress = "minio:9000"\n    AccessKey = "minioadmin"\n    SecretKey = "minioadmin"\n    BucketName = "gitlab-runner-cache"\n    Insecure = true' \
		/etc/gitlab-runner/config.toml
	$(RUNNER_COMPOSE) restart gitlab-runner
	@echo "Setup complete. Runner active. MinIO console: http://localhost:9001"
