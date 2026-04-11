# Phase 1: Autonomous Survey — Detailed Procedures

## Applying the Focus Parameter

When a `focus` hint is provided (e.g. "agent orchestration layer"), still perform ALL
steps below in full. Adjust depth allocation as follows:

- **Step 2 (Structural Map):** Go two levels deep into the focused area instead of one
- **Step 4 (Flow Tracing):** Trace additional flows through the focused subsystem beyond
  the default 2-3. Prioritize flows that enter or exit the focused area.
- **Step 5 (Pattern Recognition):** Read more files from the focused subsystem — examine
  not just representative files but all key interfaces and abstractions within it

The rest of the survey proceeds at normal breadth-first depth.

## Step 1: Project Identity

### Local Documentation Scan

Read in this order, stopping when sufficient context is gathered:

1. **README.md / README** — project purpose, tech stack, setup instructions
2. **docs/ or doc/ directory** — architecture docs, guides, ADRs
3. **CONTRIBUTING.md** — reveals build process, testing conventions, code organization
4. **ARCHITECTURE.md or similar** — explicit architectural documentation
5. **Package manifests** — detect by language:
   - JavaScript/TypeScript: `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - Python: `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt`, `Pipfile`
   - Go: `go.mod`, `go.sum`
   - Rust: `Cargo.toml`, `Cargo.lock`
   - Java: `pom.xml`, `build.gradle`, `build.gradle.kts`
   - C#/.NET: `*.csproj`, `*.sln`, `Directory.Build.props`
   - Ruby: `Gemfile`, `*.gemspec`
   - PHP: `composer.json`
   - Elixir: `mix.exs`
6. **Configuration files** — `docker-compose.yml`, `Makefile`, `Dockerfile`, CI configs
   (`.github/workflows/`, `.circleci/`, `Jenkinsfile`)
7. **Monorepo indicators** — workspace configs, `lerna.json`, Nx config, Turborepo config,
   multiple `go.mod` files, Bazel `BUILD` files

### Web Search Fallback

Trigger when: README is < ~20 lines or missing AND no docs/ or ADR/ directories exist.

Search strategy:
1. Search for the project's GitHub URL — look for wiki pages, discussions, and issues
   tagged with "architecture" or "design"
2. Search for `"{project name}" architecture` or `"{project name}" design`
3. Check package metadata for homepage/repository URLs and search those
4. Search for blog posts or conference talks about the project

When incorporating web-sourced findings:
- Label each finding with its source URL
- Place in the "Inferred" category of the analysis
- Note the date of the source if available
- If web search yields nothing useful, state explicitly: "No external documentation found.
  Analysis below is derived entirely from code structure."

## Step 2: Structural Map

### Directory Analysis

1. List the top-level directory layout using `ls` or glob
2. For each major directory, list one level deeper
3. Ignore generated directories: `node_modules/`, `vendor/`, `target/`, `build/`, `dist/`,
   `.git/`, `__pycache__/`, `.next/`, `.nuxt/`, `venv/`, `.venv/`

### Identifying Architectural Layers

Look for these common organizational patterns:

**Layer-based (horizontal):**
- `controllers/`, `handlers/`, `routes/` → presentation layer
- `services/`, `usecases/`, `domain/`, `core/` → business logic layer
- `repositories/`, `dal/`, `persistence/`, `db/` → data access layer
- `middleware/`, `interceptors/` → cross-cutting concerns
- `models/`, `entities/`, `types/` → domain model

**Feature-based (vertical):**
- Each top-level directory represents a bounded context or feature
- Contains its own controller, service, repository within the feature directory

**Hybrid:**
- Combination of both, often with shared infrastructure

### Component Diagram

Produce a mermaid component diagram showing:
- Major components/modules as boxes
- Dependencies between them as arrows
- External systems they interact with
- Layer boundaries if applicable

## Step 3: Dependency Analysis

### External Dependencies

Read the primary package manifest and categorize each dependency:

| Category | Examples |
|----------|----------|
| Framework | Express, Spring, Django, Gin, Actix |
| Persistence | Prisma, SQLAlchemy, GORM, TypeORM |
| Messaging | RabbitMQ client, Kafka client, Redis |
| Observability | OpenTelemetry, Prometheus, Datadog |
| Authentication | Passport, JWT libraries, OAuth clients |
| Testing | Jest, pytest, testify, JUnit |
| Build/Dev | Webpack, Vite, ESBuild, tsc |
| Utilities | Lodash, Apache Commons, etc. |

Focus on production dependencies. Dev dependencies are worth noting if they reveal
testing or build patterns.

### Internal Dependencies

Examine import/require statements across modules to map which modules depend on which.
Focus on module-level dependencies, not file-level.

Produce a mermaid graph showing internal module dependencies with arrow direction
indicating "depends on."

## Step 4: Key Flow Tracing

### Finding Entry Points

Search for entry points in this order:

1. **Explicit main:** `main()`, `main.go`, `main.py`, `index.ts`, `app.ts`, `Program.cs`
2. **Framework entry:** route definitions, controller decorators, handler registrations
3. **CLI entry:** command definitions, argument parsers
4. **Event entry:** event listeners, message consumers, webhook handlers
5. **Scheduled entry:** cron jobs, scheduled tasks

### Tracing a Flow

For each entry point, trace at the component level:
1. Where does the request/event enter?
2. What validates or preprocesses it?
3. What business logic processes it?
4. What external systems does it interact with?
5. What does it return or produce?

Read function signatures and imports to trace the flow — do NOT read function bodies
unless the signature alone is insufficient to determine the next component.

### Sequence Diagrams

Produce a mermaid sequence diagram for each flow showing:
- Actors/components as participants
- Messages/calls between them (with meaningful labels)
- Return values where architecturally significant
- External system interactions

## Step 5: Pattern Recognition

### Design Patterns to Look For

Examine code structure (not implementation) for these patterns:

| Pattern | Indicators |
|---------|-----------|
| Repository | Classes/interfaces named `*Repository`, `*Repo`, `*Store`, `*DAO` |
| Factory | Classes named `*Factory`, `create*` methods returning interfaces |
| Strategy | Interfaces with multiple implementations, runtime selection |
| Observer/Event | Event emitters, listeners, subscribers, pub/sub |
| Middleware/Pipeline | Chain of handlers, `use()`, `pipe()` |
| Decorator | Wrapper classes, annotations/decorators modifying behavior |
| Dependency Injection | Constructor injection, DI containers, providers |
| CQRS | Separate command/query models, command handlers |
| Event Sourcing | Event stores, event replay, aggregate roots |
| Saga/Orchestration | Multi-step workflows, compensating transactions |

### Architectural Patterns to Identify

| Pattern | Indicators |
|---------|-----------|
| Clean/Hexagonal | Ports & adapters, dependency inversion, domain isolation |
| MVC/MVVM | Model-View-Controller separation, view models |
| Microservices | Multiple deployable units, service discovery, API gateway |
| Modular Monolith | Single deployment, clear module boundaries |
| Event-Driven | Message brokers, async processing, eventual consistency |
| Serverless | Function handlers, cloud function configs |
| Plugin/Extension | Plugin interfaces, extension points, dynamic loading |

### File Reading Strategy for Patterns

Read these file types to identify patterns:
- Interface/trait/protocol definitions
- Base classes and abstract classes
- Configuration and wiring files (DI setup, module registration)
- Entry points and routers
- Directory-level index/barrel files

Do NOT read:
- Test files (at this stage)
- Generated code
- Vendor/dependency code
- Implementation details of concrete classes
