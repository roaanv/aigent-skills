---
name: noob-doc
description: >
  Generate comprehensive architecture documentation (noob.md) for junior engineers who are new to a codebase.
  Use this skill whenever the user asks to document a codebase, create onboarding docs, write architecture guides,
  generate "noob docs", explain a project's structure for new team members, or mentions wanting documentation
  that helps someone unfamiliar with the code get up to speed. Also use when users say things like
  "document this for a junior", "create a getting started guide for the codebase", "explain the architecture",
  "write developer onboarding docs", or "I need docs so new engineers can contribute".
---

# noob-doc: Architecture Documentation Generator

You are generating a comprehensive architecture document (`noob.md`) that will allow a junior engineer — who has never seen this codebase — to understand the system well enough to add significant features. The document must be self-contained: after reading it, the engineer should not need to ask "but how does X work?"

## Phase 1: Interview (2 minutes)

Before exploring, ask the user these questions to scope the work. Use AskUserQuestion with sensible defaults:

1. **Scope**: "What should the doc cover?"
   - Core architecture only (recommended for most projects)
   - Core + extension/plugin architecture
   - Everything including mobile apps, deployment, etc.

2. **Audience baseline**: "What can we assume the reader already knows?"
   - Default: "Knows the primary language and general backend/frontend concepts, but has never seen this codebase"
   - Let the user override (e.g., "knows React but not GraphQL")

3. **Output location**: "Where should I put the document?"
   - Default: `noob.md` in the repo root
   - Let the user specify a different path

4. **Feature implementation example**: "The doc will include a walkthrough of implementing a feature end-to-end (no code — just which files, classes, and methods to touch and why). Do you have a specific feature you'd like to see walked through, or should I suggest one that exercises as many parts of the codebase as possible?"
   - If the user provides a feature, record it for use in Phase 3 exploration and Phase 6 writing
   - If the user wants a suggestion, the AI will choose one after exploration is complete

If the user seems impatient or says "just go", skip the interview and use the defaults (AI-suggested feature for the implementation example).

## Phase 2: Reconnaissance

Before launching deep exploration, quickly identify the project's shape. This takes ~30 seconds and informs everything else.

### 2a. Detect project type and language

Run these in parallel:
- ls the root directory
- Read package.json / Cargo.toml / go.mod / pyproject.toml / build.gradle / pom.xml (whichever exists)
- Read README.md (first 100 lines)
- Read any CLAUDE.md / AGENTS.md / CONTRIBUTING.md (first 100 lines)
- Check for tsconfig.json / .eslintrc / rustfmt.toml / .editorconfig

From this, determine:
- **Primary language** (TypeScript, Python, Go, Rust, Java, etc.)
- **Framework** (Express, Django, Actix, Spring, etc.)
- **Build system** (pnpm, cargo, make, gradle, etc.)
- **Monorepo?** (workspace config, multiple packages)
- **Project type** (CLI tool, web server, library, full-stack app, etc.)

### 2b. Gather structural metadata

Run these in parallel while planning the exploration:

```bash
# Coupling analysis: which files change together
git log --stat --oneline -30

# Recent activity: what's being worked on
git log --all --oneline -20

# Build/test/run commands
# (read from package.json scripts, Makefile targets, or equivalent)
```

Also read:
- Build config (tsconfig.json, Cargo.toml, etc.) for module boundaries and path aliases
- Workspace config (pnpm-workspace.yaml, Cargo workspace, etc.) for monorepo structure

## Phase 3: Deep Exploration (parallel agents)

Launch up to 5 Explore agents in parallel. Adapt the agent focus areas to the project — these are starting points, not rigid categories.

**If the user specified a feature in Phase 1**, bias each agent to also note how their subsystem would be involved in implementing that feature (e.g., "if adding feature X, this subsystem would need…"). This contextual awareness will feed directly into the Feature Implementation Guide section.

| Agent | Focus | What to find |
|-------|-------|-------------|
| 1. Entry & Boot | Main entry point, CLI wiring, startup sequence | How the process starts and what gets initialized in what order |
| 2. Transport / Input | How external inputs arrive (HTTP, CLI, message queues, file watchers) | Request/event lifecycle from outside world to internal processing |
| 3. Core Business Logic | Main processing pipeline, domain models, key algorithms | The "heart" of the system — what it actually does |
| 4. Extension Points | Plugin system, middleware, hooks, event bus, module registration | How the system is extended without modifying core |
| 5. Shared Infrastructure | Types, utils, config, logging, error handling, security | Cross-cutting concerns everything depends on |

Each agent prompt should ask for:
- Key files and what they do
- Key interfaces/types defined
- How the module connects to adjacent modules
- Import/export relationships

**Important**: Tell each agent to be very thorough and to read full files, not just scan headers.

## Phase 4: LSP-Powered Type Mapping

If the project has an LSP available (check by trying a `hover` operation on a source file), use it to build a type map of the key abstractions:

### For TypeScript/JavaScript projects:
- `workspaceSymbol` — map all exported interfaces/types (this may return a lot; focus on the top-level module boundaries)
- `hover` on key type names found by exploration agents — get full type signatures
- `documentSymbol` on critical files — list all symbols
- `goToDefinition` — trace type hierarchies for the 3-5 most important types
- `findReferences` — understand where key interfaces are implemented

### For other languages:
- Try the same LSP operations; they work for Python, Go, Rust, Java, etc. if the LSP is configured
- If no LSP is available, fall back to Grep for type/class/interface definitions and Glob for file discovery

### What to map:
- The "lingua franca" types — the 3-5 types that flow through the entire system (e.g., Request/Response, Message/Event, Config)
- The extension point interfaces — what do plugins/extensions implement?
- The configuration type — what's configurable?

## Phase 5: Deep Reading

Based on agents' findings, read and understand these critical files (typically 10-20 files):

1. **Entry point(s)** — the first file that runs
2. **Core type definitions** — the types everything else depends on
3. **Main processing pipeline** — the function(s) that orchestrate the core flow
4. **Plugin/extension SDK** — what extensions implement
5. **Configuration type** — the master config shape
6. **A complete extension/plugin** — one real example of how the system is extended

Read each file thoroughly. Take notes on patterns, conventions, and design decisions.

## Phase 6: Write noob.md

Generate the document using Mermaid.js for diagrams. Use PlantUML only if Mermaid cannot express a particular diagram (rare — Mermaid handles sequence, graph, class, state, ER, and flowcharts).

### Document template

Adapt this structure to the project. Not every section applies to every project — skip sections that don't make sense, add sections that do.

```markdown
# [Project Name] Architecture Guide for New Engineers

> **Audience**: [from interview — e.g., "You know TypeScript and Node.js..."]
> You do **not** know this codebase. This document will fix that.

**Version**: [version] · **Runtime**: [runtime] · **Language**: [language]
**Build**: [build tool] · **Package manager**: [pm] · **Tests**: [test framework]

---

## Table of Contents
[auto-generate from sections]

## 1. What is [Project]?
[1-paragraph elevator pitch. What does it do? Who uses it? Why does it exist?]
[ASCII or Mermaid diagram showing the 10,000-foot view]

## 2. High-Level Architecture
[Mermaid graph TB showing major components and data flow]
[Layered architecture diagram if applicable]

## 3. Repository Layout
[Annotated directory tree — every important directory explained]
[Star (★) the most important directories]

## 4. Boot/Startup Sequence
[Mermaid sequence diagram: process start → "system ready"]
[Table: step | file | what happens]

## 5. Core Concepts
[Mermaid concept map linking key abstractions]
[Table: concept | what it is | where it lives]

## 6. [Main Processing Flow] (end-to-end)
[This section title should reflect what the project does:
 - For a web server: "Request Lifecycle"
 - For a message gateway: "Message Lifecycle"
 - For a compiler: "Compilation Pipeline"
 - For a CLI tool: "Command Execution Flow"]
[Detailed Mermaid sequence diagram with ALL steps]
[Annotated code walkthrough of the key types in this flow]

## 7-N. [Subsystem Deep Dives]
[One section per major subsystem. Include as needed:
 - Class/type diagrams (Mermaid classDiagram)
 - State machines (Mermaid stateDiagram)
 - Adapter/strategy patterns
 - Annotated code snippets]

## N+1. Configuration System
[Master config type with annotations]
[How config is loaded, validated, and accessed]

## N+2. Extension/Plugin Architecture
[Registration flow (Mermaid sequence diagram)]
[SDK interface with annotations]
[Complete minimal extension example using REAL project types]

## N+3. Security Model (if applicable)
[Layered security diagram]
[Key concepts: auth, authz, sandboxing, input validation]

## N+4. Key Patterns and Conventions
[Dependency injection pattern]
[Naming conventions]
[File organization conventions]
[Testing patterns]

## N+5. Walkthrough: Adding a [Feature Type]
[Pick a feature type that exercises the main extension point]
[Step-by-step guide with REAL code using REAL project types]
[This should be a complete, working example]

## N+6. Feature Implementation Guide

[This section walks through implementing a real feature WITHOUT any code.
It shows the reader which files, classes, and methods to touch and why —
teaching them to navigate the codebase by tracing a feature end-to-end.]

### Choosing the feature

- **If the user provided a feature in the Phase 1 interview**, use that feature.
- **If the user asked the AI to suggest one**, choose a user-facing feature that
  touches as many layers and subsystems as possible (e.g., API/transport, business
  logic, data access, configuration, tests). Then explain:
  - What the feature is and why it's valuable to end users
  - **Why this feature was chosen as the example** — which layers/subsystems it
    exercises and why that makes it an effective learning walkthrough

### Structure

**Opening**: A brief description of the feature and its user-facing value.

**Sequence diagram (if relevant)**: A Mermaid sequence diagram showing how the
feature's execution flows through the system's layers and components. This gives
the reader a bird's-eye view before diving into individual files.

**File-by-file narrative**: For each file that needs to be modified or created,
write a narrative subsection:

#### `path/to/file.ext` — modify | create

**Why this file is involved**: [1-2 sentences explaining this file's role in
the feature]

**What needs to happen**:
- `ClassName.methodName()` — [description of what should change and why,
  without showing code]
- `AnotherClass` — [description of a new method or field to add and its
  purpose]

[Order files in the sequence a developer would naturally work through them —
typically: types/interfaces first, then core logic, then transport/API layer,
then configuration, then tests.]

**Closing sequence diagram (if relevant)**: If the feature involves complex
interactions not captured in the opening diagram (e.g., async flows, event
propagation, error paths), add a second Mermaid sequence diagram here.

**Key considerations**: Briefly note any non-obvious concerns — e.g., backward
compatibility, migration needs, performance implications, security
considerations — without prescribing solutions.

## N+7. Development Commands
[Table: command | purpose]

## N+8. Glossary
[Every domain term defined — alphabetical]

## Architecture Decision Records
[Why key design choices were made]
[Format: decision, alternatives considered, rationale]
```

### Diagram guidelines

- **Every diagram must have a text explanation** — diagrams are overviews, text provides detail
- **Use Mermaid.js** for: sequence diagrams, flowcharts (graph), class diagrams, state diagrams, ER diagrams
- **Use PlantUML** only for: complex deployment diagrams, component diagrams with nested packages, or anything Mermaid genuinely cannot express
- **Annotated code snippets**: Include simplified versions of real types with inline comments explaining each field. Use the project's actual types, not made-up ones.

### Quality checklist

Before declaring the document complete, verify:
- [ ] A junior engineer reading this would understand how to add a new feature
- [ ] Every section has at least one diagram or code snippet
- [ ] The walkthrough section uses real project types and would actually work
- [ ] The feature implementation guide references only files/classes/methods that exist in the project
- [ ] The feature implementation guide contains NO code — only descriptions of what to change and why
- [ ] The feature implementation guide covers files across multiple layers/subsystems
- [ ] The glossary defines every non-obvious term used in the document
- [ ] All file paths referenced in the doc actually exist in the project
- [ ] The document is self-contained — no "see external docs" without explanation
