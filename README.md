# DevOps GitLab Monorepo

Monorepo for a small full-stack application and its delivery pipeline: a React 19 + Vite frontend, an Express 5 API, PostgreSQL, nginx, Docker Compose environments, GitLab CI jobs, and AWS infrastructure managed with Terraform and Terragrunt.

## What is in the repo

- `frontend/`: React SPA for the users CRUD UI.
- `backend/`: Express API with `/health` and `/users` endpoints backed by PostgreSQL.
- `devops/docker/`: Dockerfiles, nginx templates, and database initialization SQL.
- `devops/ci/gitlab/`: GitLab CI fragments for lint, test, build, security, publish, and deploy stages.
- `devops/aws/`: Terraform root and reusable AWS modules.
- `devops/live/`: Terragrunt environments for `staging` and `prod`.

## Workspace commands

The repository uses a pnpm workspace and Turbo at the root.

```bash
pnpm install
pnpm dev
pnpm build
pnpm lint
pnpm test
pnpm test:unit
pnpm test:integration
pnpm test:e2e
```

Root scripts orchestrate the package scripts declared in `frontend/package.json` and `backend/package.json`.

## Local development

### Option 1: Node.js processes on the host

Use this mode when you want to run Vite and Express directly without Docker.

1. Install Node.js LTS and pnpm.
2. Copy `.env.example.dev` to `.env`.
3. Install dependencies from the repository root:

   ```bash
   pnpm install
   ```

4. Start the workspace:

   ```bash
   pnpm dev
   ```

Typical values from `.env.example.dev`:

- frontend: `http://localhost:5173`
- backend: `http://localhost:3000`
- API base URL used by the frontend: `VITE_FRONTEND_API_URL=http://localhost:3000`

### Option 2: Docker Compose development stack

The repository contains several Compose files instead of a single default `docker-compose.yml`.

- `docker-compose.dev.yaml`: local development stack with bind mounts and Vite dev server
- `docker-compose.prod.yaml`: local production-like stack built from production Dockerfiles
- `docker-compose.ecr.yaml`: deployment stack used on AWS EC2 with images pulled from ECR
- `docker-compose.runner.yaml`: local GitLab Runner + MinIO cache

To run the development stack from the repository root:

1. Copy `.env.example` to `.env`.
2. Start Compose by overriding the Makefile `COMPOSE` variable:

   ```bash
   COMPOSE="docker compose -f docker-compose.dev.yaml" make up
   ```

3. Useful commands:

   ```bash
   COMPOSE="docker compose -f docker-compose.dev.yaml" make help
   COMPOSE="docker compose -f docker-compose.dev.yaml" make logs
   COMPOSE="docker compose -f docker-compose.dev.yaml" make logs s=backend
   COMPOSE="docker compose -f docker-compose.dev.yaml" make down
   ```

With the default values from `.env.example`, the exposed endpoints are:

- frontend through nginx: `http://localhost`
- backend direct access: `http://localhost:3000`
- frontend container port used by nginx: `8088`
- frontend API base URL: `/api`

## Testing

Backend tests are organized by scope and can be run through the workspace scripts:

- `pnpm test`: all tests
- `pnpm test:unit`: unit tests
- `pnpm test:integration`: integration tests
- `pnpm test:e2e`: end-to-end tests

JUnit XML reports are written under `backend/junit/`.

## CI/CD

The root `.gitlab-ci.yml` includes the pipeline fragments from `devops/ci/gitlab/` and defines these stages:

1. `lint`
2. `test`
3. `build`
4. `publish`
5. `deploy`

The split files currently are:

- `lint.yml`
- `test.yml`
- `build.yml`
- `security.yml`
- `publish-image.yml`
- `deploy.yml`

For local runner experiments, the Makefile also provides `runner-up`, `runner-down`, `runner-logs`, `runner-reset`, and `runner-setup` around `docker-compose.runner.yaml`.

## AWS infrastructure

AWS infrastructure code lives under `devops/aws/`.

- reusable modules: `modules/alb`, `modules/cloudwatch`, `modules/ec2`, `modules/iam`, `modules/s3_logs`, `modules/ssm`, `modules/vpc`
- Terragrunt live configuration: `devops/live/root.hcl`, `devops/live/staging/terragrunt.hcl`, `devops/live/prod/terragrunt.hcl`
- the EC2 deployment uses `docker-compose.ecr.yaml`

Typical validation flow from `devops/aws/`:

```bash
terraform init -backend=false
terraform validate
```

Typical Terragrunt usage from an environment directory such as `devops/live/prod/`:

```bash
source ../../aws/.env
terragrunt plan
```

## Documentation

- `backend/README.md`: backend API details, environment variables, and test scripts
- `frontend/README.md`: frontend runtime configuration and Vite workflow
- `docs/getting-started/README.md`: starter template that still needs to be customized if this repo wants a separate onboarding guide
