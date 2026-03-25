# AGENTS.md — Codebase Guide for AI Coding Agents

## Repository Overview

Full-stack seabird GPS data management system. Services:
- **`wizard/`** — Python backend (PyWebIO + data pipeline). Package manager: `uv`.
- **`admin/`** — React/TypeScript frontend (react-admin + Vite). Package manager: `pnpm`.
- **`db/`** — PostgreSQL migrations via `dbmate`.
- **`nginx/`** — Nginx reverse proxy (production).
- **`docker-compose.yml`** — Orchestrates all services (PostgREST, Traefik, PostgreSQL, S3-compatible storage).

---

## Build / Lint / Test Commands

### Python (`wizard/`)

```bash
# Install dependencies
uv sync

# Run the wizard app
uv run wizard

# Run background tasks
uv run tasks

# Lint (ruff — auto-fixes on save)
uv run ruff check .
uv run ruff check --fix .

# Format
uv run black .

# Run all tests
uv run pytest

# Run a single test file
uv run pytest tests/test_foo.py

# Run a single test by name
uv run pytest tests/test_foo.py::test_my_function

# Run tests with verbose output
uv run pytest -v

# Pre-commit hooks (from wizard/ directory)
pre-commit run --all-files
```

### TypeScript/React (`admin/`)

```bash
# Install dependencies
pnpm install

# Development server
pnpm dev

# Production build
pnpm build

# Lint (ESLint)
pnpm lint

# Preview production build
pnpm preview
```

### Docker (full stack)

```bash
# Generate secrets (first-time setup)
docker compose --file setup/docker-compose.yml build
docker compose --file setup/docker-compose.yml run --rm setup

# Run the full stack
docker compose --env-file secrets/docker --env-file secrets/tokens up --build

# Build a specific service
docker compose build wizard
docker compose build admin
```

---

## Python Code Style (`wizard/`)

### Ruff Configuration
Configured in `wizard/pyproject.toml`. Active rule sets:
- `E`, `W` — pycodestyle errors/warnings
- `I` — isort (import sorting)
- `F` — pyflakes
- `UP` — pyupgrade (modern syntax)
- `S` — bandit (security)
- `B` — bugbear
- `A` — flake8-builtins (no shadowing builtins)
- `COM` — flake8-commas (trailing commas enforced; COM812 ignored)
- `LOG` — logging best practices
- `PTH` — use `pathlib` instead of `os.path`
- `Q` — flake8-quotes
- `E501` is ignored — no enforced line length limit.
- `fix = true` — ruff auto-fixes where possible.

### Formatting
- **Formatter**: `black` (via pre-commit). Do not fight black's formatting decisions.
- **Import order**: managed by `isort` (via pre-commit) and `ruff I` rules.
  - Standard library → third-party → local imports, separated by blank lines.
  - Use `import type` where applicable (Python 3.11+ `from __future__ import annotations` or `TYPE_CHECKING`).

### Naming Conventions
- `snake_case` for functions, variables, module names.
- `UPPER_SNAKE_CASE` for module-level constants (e.g. `POSTGREST_URL`, `S3_BUCKET`).
- `PascalCase` for classes.

### Types & Annotations
- Python `>=3.11` is required. Use modern union syntax `X | Y` instead of `Optional[X]`.
- Use `pathlib.Path` / `upath.UPath` for file paths — never `os.path` (PTH rules enforced).
- Prefer `UPath` (from `universal-pathlib`) for S3-compatible paths.

### Logging
- Use `structlog` exclusively. Never use `print()` or the stdlib `logging` module directly.
- Obtain a logger at module level: `log = structlog.get_logger()` (or via `configure_logger()`).
- Pass context as keyword arguments: `log.info("event description", key=value, ...)`.
- Log level is configured via the `LOGGING` environment variable (default `"INFO"`).

### Error Handling
- Use `response.raise_for_status()` after HTTP requests.
- Catch specific exceptions where possible; only use broad `except Exception as e:` as a last resort, and always log with context.
- Integrate Sentry conditionally: Sentry is initialized only when `SENTRY_DSN` env var is set.

### Environment / Configuration
- All configuration comes from environment variables via `django-environ` (`Env()`).
- Provide sensible defaults where safe (`default=None`, `default="INFO"`).
- Required secrets (no default) will raise at startup if missing — this is intentional.

---

## TypeScript / React Code Style (`admin/`)

### TypeScript Configuration
- Strict mode enabled (`"strict": true`) in `tsconfig.app.json`.
- `noUnusedLocals: true`, `noUnusedParameters: true` — no dead code.
- Target: `ES2022`, module resolution: `bundler`.
- Use `import type { Foo }` for type-only imports.

### Naming Conventions
- `PascalCase` for React components and exported types/interfaces.
- `camelCase` for functions, variables, hooks, and non-component exports.
- Files: `PascalCase.tsx` for components, `camelCase.ts` for utilities/providers.

### Components
- All components are `const` arrow functions: `const MyComponent = () => { ... }`.
- Export list/show/edit variants per resource as named exports (`AnimalList`, `AnimalShow`, `AnimalEdit`).
- Export singleton providers (authProvider, dataProvider) as default exports.

### Linting & Formatting
- **Linter**: ESLint v9 with `typescript-eslint` v8 and `eslint-plugin-react-hooks`.
- **Formatter**: Biome (`@biomejs/biome` 2.3.15) is installed as a devDependency.
- Run `pnpm lint` before committing.

### Data & Auth Patterns
- Data layer: `@raphiniert/ra-data-postgrest` PostgREST adapter, proxied at `/postgrest`.
- Auth: JWT signed client-side with `jose` using HS256; stored in `localStorage`.
- Composite primary keys declared in `dataProvider.ts` via the `primaryKeys` map.

---

## Database (`db/`)

- Migrations managed by `dbmate`. Migration files live in `db/migrations/`.
- PostgreSQL 16 with PostGIS 3.4.
- PostgREST v10 exposes the database as a REST API.
- SQL functions use `RAISE EXCEPTION USING errcode = sqlstate, message = sqlerrm, detail = row_to_json(new)` for structured error propagation.

---

## Pre-commit Hooks

Root-level (all files):
- `check-added-large-files`, `check-yaml`, `end-of-file-fixer`, `trailing-whitespace`

`wizard/` additional hooks:
- `black` (formatter), `isort` (import sorting), `ruff` (linter)

Run hooks manually:
```bash
# Root hooks
pre-commit run --all-files

# Wizard hooks (from wizard/ directory)
pre-commit run --all-files -c .pre-commit-config.yaml
```

---

## CI/CD

- GitHub Actions: `.github/workflows/docker-publish.yml`
- Triggers on every push, every PR, and manual dispatch.
- Builds and pushes 4 Docker images to GHCR (`ghcr.io/ninanor/`):
  `seabird-dbmate`, `seabird-wizard`, `seabird-nginx`, `seabird-admin`.
- No automated test step in CI — tests must be run locally before pushing.
