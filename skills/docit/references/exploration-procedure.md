# Exploration Procedure

Detailed procedures for Phase 1 (discovery) and Phase 2 (deep exploration) of docit.

## Web Search Fallback

Trigger when: README is < ~20 lines or missing AND no docs/ or ADR/ directories exist.

Search strategy:
1. Search for the project's GitHub URL — wiki pages, discussions, issues tagged "architecture" or "design"
2. Search `"{project name}" architecture` and `"{project name}" design`
3. Check package metadata for homepage/repository links and fetch those
4. Search for blog posts or conference talks about the project

When incorporating web-sourced findings:
- Label each finding with its source URL
- Treat as Inferred (not Observed)
- Note the source date if available
- If nothing useful found: "No external documentation found. Analysis derived entirely from code structure."

## Structural Analysis

### Directory Analysis

1. List the top-level directory layout
2. For each major directory, list one level deeper
3. Skip generated directories: `node_modules/`, `vendor/`, `target/`, `build/`, `dist/`,
   `.git/`, `__pycache__/`, `.next/`, `.nuxt/`, `venv/`, `.venv/`, `coverage/`

### Identifying Architectural Layers

**Layer-based (horizontal):**
- `controllers/`, `handlers/`, `routes/` → presentation layer
- `services/`, `usecases/`, `domain/`, `core/` → business logic layer
- `repositories/`, `dal/`, `persistence/`, `db/` → data access layer
- `middleware/`, `interceptors/` → cross-cutting concerns
- `models/`, `entities/`, `types/` → domain model

**Feature-based (vertical):**
- Each top-level directory represents a bounded context or feature
- Contains its own controller, service, repository sub-files

**Hybrid:**
- Combination of both, often with a shared infrastructure layer

## File Reading Strategy

Read for structure (imports, exports, signatures, interfaces) rather than implementation
bodies. Only read full function bodies when necessary to understand the next hop in a flow.

Priority order:
1. README / docs → package manifests → directory structure → entry points
2. One representative file per major module

**Read these file types to identify patterns:**
- Interface / trait / protocol definitions
- Base classes and abstract classes
- Configuration and wiring files (DI setup, module registration)
- Entry points and routers
- Directory-level index / barrel files

**Do NOT read at this stage:**
- Test files
- Generated code
- Vendor / dependency code
- Implementation details of concrete classes (unless needed to trace a flow)

## Finding Entry Points

Search in this order:
1. **Explicit main:** `main()`, `main.go`, `main.py`, `index.ts`, `app.ts`, `Program.cs`
2. **Framework entry:** route definitions, controller decorators, handler registrations
3. **CLI entry:** command definitions, argument parsers
4. **Event entry:** event listeners, message consumers, webhook handlers
5. **Scheduled entry:** cron jobs, scheduled tasks

## Pattern Recognition

### Design Patterns to Look For

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
| Clean / Hexagonal | Ports & adapters, dependency inversion, domain isolation |
| MVC / MVVM | Model-View-Controller separation, view models |
| Microservices | Multiple deployable units, service discovery, API gateway |
| Modular Monolith | Single deployment, clear module boundaries |
| Event-Driven | Message brokers, async processing, eventual consistency |
| Serverless | Function handlers, cloud function configs |
| Plugin / Extension | Plugin interfaces, extension points, dynamic loading |

## Dependency Analysis

### External Dependency Categorization

| Category | Examples |
|----------|----------|
| Framework | Express, Spring, Django, Gin, Actix |
| Persistence | Prisma, SQLAlchemy, GORM, TypeORM |
| Messaging | RabbitMQ client, Kafka client, Redis |
| Observability | OpenTelemetry, Prometheus, Datadog |
| Authentication | Passport, JWT libraries, OAuth clients |
| Testing | Jest, pytest, testify, JUnit |
| Build / Dev | Webpack, Vite, ESBuild, tsc |
| Utilities | Lodash, Apache Commons, etc. |

Focus on production dependencies. Note dev dependencies only if they reveal testing or
build patterns worth documenting.

### Internal Dependency Mapping

Examine import/require statements across modules to map which modules depend on which.
Focus on module-level relationships, not individual file imports.

Produce a layered diagram showing which modules can call which — arrow direction
indicates "depends on."
