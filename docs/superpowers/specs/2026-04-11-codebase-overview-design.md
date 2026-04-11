# Codebase Overview Skill — Design Specification

> Date: 2026-04-11
> Status: Draft
> Skill name: `codebase-overview`

## Purpose

A Claude Code skill that produces a high-level architectural analysis of a codebase. Designed for experienced developers (Java/C#/Python/TypeScript/Go background) who want to learn how unfamiliar systems are designed — not how they're implemented line-by-line.

The goal is to extract enough architectural understanding from a project to inform the user's own system design work in that domain.

## Non-Goals

- No code generation, refactoring suggestions, or implementation guidance
- No code quality judgments ("this is bad/good")
- No line-by-line implementation analysis
- No modification of project files (except creating the overview document)
- No repo cloning or acquisition — the user is already inside the project

## Approach: Adaptive Two-Phase

### Phase 1 — Autonomous Survey

A breadth-first exploration that produces a structured architectural overview. Runs without user interaction.

### Phase 2 — Interactive Deep Dives

User-directed exploration of specific areas identified in Phase 1. Each deep dive is a focused subagent investigation that reports back and appends to the working document.

## Invocation

**Trigger phrases:** "review this codebase", "analyze the architecture", "what patterns does this project use", "help me understand this system"

**Precondition:** User is inside a cloned repository.

**Optional parameters:**
- `model` — override the session model for the skill and its subagents (defaults to inheriting the session model)
- `focus` — a hint to bias the survey toward a specific area (e.g. "agent orchestration layer"). When provided, Phase 1 still performs the full breadth-first survey but allocates more depth to the focused area (e.g. traces additional flows through it, reads more files from that subsystem). Not required.

## Phase 1: Autonomous Survey

### Step 1: Project Identity

- Read README, CONTRIBUTING, docs/, ADRs, any architecture documentation
- Read package manifests (package.json, go.mod, Cargo.toml, pyproject.toml, pom.xml, build.gradle, etc.)
- Identify language(s), framework(s), build system
- Check for monorepo indicators (workspaces, multiple modules)
- **Web search fallback:** If local documentation is insufficient (README < ~20 lines or missing, no docs/ADR directories), search the web for:
  - The repo's GitHub page (wiki, discussions, issues with "architecture"/"design" labels)
  - Project name + "architecture" or "design"
  - Any project website found in package metadata
  - Web-sourced findings are labeled with source URL and placed in the "Inferred" category
  - If web search also yields nothing: note that analysis is derived entirely from code structure

### Step 2: Structural Map

- Analyze top-level directory layout and one level deeper into each major directory
- Identify architectural layers (e.g. presentation/business/data, or domain-based boundaries)
- Map module/package boundaries
- Produce a **mermaid component diagram** showing major components and their relationships

### Step 3: Dependency Analysis

- **External dependencies:** categorized by purpose (framework, persistence, messaging, observability, testing, etc.)
- **Internal dependencies:** how modules/packages depend on each other
- Produce a **mermaid dependency graph** of internal module relationships

### Step 4: Key Flow Tracing

- Identify 2-3 primary entry points (main(), HTTP handlers, CLI commands, event listeners, etc.)
- Trace each flow at the component level: "request enters here -> validated by X -> processed by Y -> persisted by Z"
- Produce a **mermaid sequence diagram** for each traced flow
- For monorepos: trace flows in the primary/largest service; flag others for Phase 2

### Step 5: Pattern Recognition

- Identify **design patterns** in use (repository, factory, strategy, observer, middleware pipeline, CQRS, event sourcing, etc.)
- Identify **architectural patterns** (hexagonal, clean architecture, MVC, microservices, monolith, modular monolith, etc.)
- Note unusual or noteworthy structural choices

### Step 6: Initial Report

Assemble findings into a structured report:
- Present conversationally in the terminal
- Simultaneously write to `docs/architecture-overview.md` as a working draft (so the user can view rendered mermaid diagrams alongside the conversation)

### File Reading Strategy

Phase 1 reads files strategically to manage context:
- **Priority order:** README/docs -> package manifests -> top-level directory structure -> entry point files -> one representative file from each major module
- **Read for structure:** imports, exports, class/function signatures, interfaces — not implementation bodies
- **Monorepo handling:** map all services/packages but only flow-trace the primary one

## Phase 2: Interactive Deep Dives

### Transition

After presenting the Phase 1 report, the skill suggests areas worth exploring based on what it found. Suggestions are specific to this codebase, not generic.

### Deep Dive Mechanics

- Each deep dive dispatches a focused subagent to explore the requested area
- Findings are presented conversationally AND appended to the working draft under `## Deep Dive: {topic}`
- Each deep dive follows the same fact/inference separation as Phase 1
- New mermaid diagrams are generated when the deep dive reveals structure worth visualizing

### Types of Deep Dives

- **"Trace the {X} flow"** — follow a specific flow end-to-end through all layers
- **"How does {component} work?"** — examine a subsystem's internal design
- **"What pattern is used for {X}?"** — identify and explain the design pattern behind a specific concern
- **"Compare this to how you'd do it in {language}"** — map the approach to Java/C#/Python/TS/Go equivalents
- **"What are the trade-offs of this approach?"** — analyze alternatives and why they likely weren't chosen
- Any freeform architectural question

### Exit Condition

User signals they're done exploring (e.g. "finalize", "that's enough", "wrap it up").

## Finalization

1. Synthesize a **Transferable Principles** section — domain-independent principles distilled from the analysis, each stated as a general rule with a reference to how this codebase implements it
2. Ask the user if they want to reorganize or trim the document
3. Save the final version of `docs/architecture-overview.md`

## Output Document Structure

```markdown
# Architecture Overview: {project name}
> Generated: {date} | Language(s): {langs} | Framework(s): {frameworks}

## Project Identity
Purpose, tech stack, build system, repo structure (mono/poly)

## System Architecture
Architectural style, layer descriptions
(mermaid component diagram)

## Component Map
| Component | Responsibility | Key Files |
Boundary descriptions — what each component owns, how they communicate

## Dependency Landscape
### External
Dependencies grouped by category
### Internal
(mermaid dependency graph)

## Key Flows
### Flow 1: {name}
Description, trigger, outcome
(mermaid sequence diagram)
### Flow 2: {name}
...

## Design Patterns & Choices
### Observed
- Pattern: {name} — where it appears, how it's used
### Inferred
- Choice: {description} — likely rationale (labeled as inference, with source if web-sourced)

## Language-Specific Notes
(only present if the codebase uses a language outside Java/C#/Python/TS/Go)
Idioms mapped to familiar equivalents

## Deep Dives
### {topic 1}
(findings from interactive exploration)
### {topic 2}
...

## Transferable Principles
Distilled, domain-independent principles.
Each principle stated as a general rule with a reference
to how this codebase implements it.
```

## Analysis Principles

### Fact vs. Inference Separation

All analysis clearly distinguishes between:
- **Observed (fact):** directly evident from the code — file structure, imports, interfaces, explicit patterns
- **Inferred (reasoning):** why choices were likely made, labeled as inference. Web-sourced context includes the source URL.

### Language Translation

When the codebase uses a language outside the user's primary languages (Java/C#/Python/TypeScript/Go), language-specific idioms are mapped to equivalents in familiar languages. Example: "This Elixir GenServer is analogous to a long-running service with an internal message queue."

### Neutral Tone

The skill describes architectural trade-offs factually (e.g. "event sourcing adds complexity but provides a full audit trail") without judging whether a choice is good or bad.

## Edge Cases

### Minimal Documentation
- Web search fallback fires
- If nothing found externally: analysis proceeds from code structure alone, stated explicitly

### No Obvious Entry Points (Libraries)
- Shift from flow tracing to public API surface analysis
- Map the library's interface boundaries and extension points instead

### Trivially Small Codebases
- Acknowledge honestly: "This is a focused utility — here's what it does and how, but there isn't a multi-component architecture to analyze."
- Still provide value: patterns used, dependency choices, design decisions at the small scale

### Monorepos
- Phase 1 maps all services/packages
- Flow tracing focuses on the primary/largest service
- Other services flagged as available for Phase 2 deep dives

### Re-invocation
- If `docs/architecture-overview.md` already exists, ask: "An existing overview was found from {date}. Do you want to start fresh or continue exploring from where you left off?"

## Model Configuration

- The skill inherits the user's current session model by default
- An optional `model` parameter allows explicit override
- Subagents inherit the same model (session default or override)
- No automatic model-switching between subtasks
