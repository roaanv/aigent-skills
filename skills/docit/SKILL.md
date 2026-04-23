---
name: docit
description: >
  Generate polished HTML architecture documentation for any codebase. Use when the user
  asks to "document this codebase", "create architecture docs", "explain this project",
  "generate HTML docs", "create a deep dive", "help new engineers understand this",
  "write onboarding documentation", "document this for a junior", "create a getting
  started guide", "explain the architecture", "create developer docs", "review this
  codebase", "analyze the architecture", "what patterns does this project use",
  "how is this project structured", "explain this codebase in depth",
  "document the architecture", "create deep-dive documentation",
  "generate an HTML doc site for this repo", "add a section to the existing docs",
  "create presentation-friendly documentation", "write architecture guides",
  "generate noob docs", "explain a project for new team members", or wants durable
  reference material explaining how a project is designed.
---

# docit

Generate polished multi-page HTML documentation for any codebase. Adapts depth and
framing to the intended audience. Supports both fresh documentation passes and
iterative extension of existing docs.

## What This Skill Produces

A multi-page HTML doc site (default) or single self-contained HTML page, covering:

- Architecture overview with SVG diagrams
- Component and package map
- Extensibility and plugin model
- Key flows and patterns
- Practical change guide
- Transferable design principles

Optional sections (off by default, enabled during clarification):
- Feature implementation guide — which files/classes to touch for a new feature, no code
- Dev commands table
- Glossary of domain terms

## Phase 0: Clarify First

Ask the minimum questions needed before doing substantial work. Use sensible defaults
so the user can say "just go" and get a reasonable result.

1. **Audience** — "Who will read these docs?"
   - Experienced engineers unfamiliar with this codebase (default)
   - Junior engineers onboarding to the project
   - Mixed / general audience

2. **Output location** — "Where should I put the docs?"
   - Default: `docs/docit/` in the repo root

3. **Mode** — "Is this a fresh documentation pass, or should I add to existing docs?"
   - Fresh (default)
   - Extend existing docs in place

4. **Optional sections** (offer as a list; all off by default):
   - Feature implementation guide — walks through which files to touch for a concrete
     feature end-to-end (no code, just navigation)
   - Dev commands — table of all build/test/run commands
   - Glossary — every domain term defined alphabetically

5. **Feature example** (only ask if feature guide was selected):
   - "Do you have a specific feature to walk through, or should I choose one that
     exercises as many architectural layers as possible?"

If the user says "just go", skip the interview and use all defaults. If a feature guide
is requested but no feature is specified, choose one after exploration.

## Phase 1: Discover Project Shape

Read the repo before writing anything. Run these in parallel:

- List root directory
- Read README.md (first 100 lines)
- Read package manifests — whichever exist: `package.json`, `go.mod`, `Cargo.toml`,
  `pyproject.toml`, `pom.xml`, `build.gradle`, `mix.exs`, `composer.json`, `Gemfile`
- Read `CLAUDE.md` / `AGENTS.md` / `CONTRIBUTING.md` if present (first 100 lines)
- List any `docs/`, `doc/`, `ADR/`, or `architecture/` directories
- Run `git log --stat --oneline -30` — coupling signals (which files change together)
- Run `git log --all --oneline -20` — recent activity (what's being worked on)

From this, determine:
- Primary language(s) and framework(s)
- Build system and package manager
- Project type (CLI, web server, library, full-stack app, monorepo)
- Module/package boundaries
- Monorepo structure if applicable

### Web Search Fallback

Trigger when README is < ~20 lines or missing AND no docs directory exists:

1. Search for the project's GitHub URL — wiki pages, architecture discussions, issues
2. Search `"{project name}" architecture` and `"{project name}" design`
3. Check package metadata for homepage/repository links and fetch those

Label all web-sourced findings with their source URL. Treat as Inferred.
If web search yields nothing useful, note: "Analysis derived entirely from code structure."

See `references/exploration-procedure.md` for detailed file-reading strategies,
pattern recognition tables, and dependency categorization.

## Phase 2: Deep Exploration

Launch 5 Explore agents in parallel. Adapt focus areas to the actual project — these
categories are starting points, not rigid boxes.

If a **feature guide** was requested, instruct each agent to also note how their
subsystem would be involved in implementing the chosen feature.

| Agent | Focus | What to find |
|-------|-------|-------------|
| 1. Entry & Boot | Main entry point, startup sequence | How the process starts; initialization order |
| 2. Transport / Input | HTTP handlers, CLI args, message queues, file watchers | Request/event lifecycle from outside world to internal processing |
| 3. Core Business Logic | Processing pipeline, domain models, key algorithms | The "heart" of the system — what it actually does |
| 4. Extension Points | Plugin system, middleware, hooks, event bus, module registration | How the system is extended without modifying core |
| 5. Shared Infrastructure | Types, config, logging, error handling, utilities | Cross-cutting concerns everything else depends on |

Each agent should report:
- Key files and what they do
- Key interfaces and types defined
- How the module connects to adjacent modules
- Import/export relationships

Tell each agent to be thorough and read full files where needed.

## Phase 3: Type Mapping

Identify the key abstractions that flow through the system.

If an LSP is available (test with a `hover` operation on any source file):
- `workspaceSymbol` — map exported interfaces/types at module boundaries
- `hover` on key type names — full type signatures
- `documentSymbol` on 3-5 critical files — complete symbol list
- `goToDefinition` — trace type hierarchies for the 3-5 most important types
- `findReferences` — understand where key interfaces are implemented

If no LSP is available, use grep to find type/class/interface definitions.

Map:
- The 3-5 "lingua franca" types that flow through the entire system
- Extension point interfaces (what plugins or adapters implement)
- Configuration type shape

## Phase 4: Deep Reading

Based on agent findings, read 10-20 critical files thoroughly:

1. Entry point(s) — the first file(s) that run
2. Core type definitions — what everything depends on
3. Main processing pipeline — the function(s) that orchestrate core flow
4. Extension/plugin SDK — what extensions implement
5. Configuration type — master config shape
6. One complete real extension or plugin

Take notes on patterns, conventions, and design decisions.

## Phase 5: Generate HTML Documentation

Default: multi-page HTML doc site. Single self-contained page only if explicitly requested.

Write all output to the confirmed output directory.

### Page Structure (default multi-page)

| Page | Filename | Content |
|------|----------|---------|
| Landing | `index.html` | Project identity, elevator pitch, 10,000-foot view diagram |
| Architecture | `architecture.html` | Components, layers, dependency spine, key patterns, transferable principles |
| Components | `components.html` | Per-package/module deep dives, type relationships |
| Extensibility | `extensibility.html` | Plugin/extension model, registration flow, SDK interfaces |
| Surfaces | `surfaces.html` | API surfaces, integrations, delivery mechanisms, UI surfaces |
| Change Guide | `changes.html` | Decision flow for where different classes of changes belong |

Optional pages (generate only if selected in Phase 0):

| Page | Filename | When |
|------|----------|------|
| Feature Guide | `feature-guide.html` | Feature implementation guide selected |
| Dev Commands | `commands.html` | Dev commands selected |
| Glossary | `glossary.html` | Glossary selected |

Include a shared `styles.css` in the same output directory.

### Visual and Layout Requirements

Follow `references/presentation-guidelines.md` for detailed visual guidance. Defaults:

- Shared `styles.css` across all pages — no per-page styles except minor overrides
- Warm or neutral background with high contrast text
- One accent color + one secondary emphasis color
- Serif or editorial typography for long-form text; sans-serif for nav, labels, captions
- Rounded cards with subtle borders and shadows
- Generous spacing; readable line lengths (65-80 characters)
- Navigation consistent on every page — plain anchor links, no JavaScript required

### Diagrams

Prefer **embedded SVG** so output stays self-contained and editable.

Every SVG must have an `aria-label`. Use a consistent shared visual style across all
diagrams (stroke weight, color palette, font family).

Good diagram candidates:
- Dependency spine / layered architecture
- Runtime flow / request lifecycle sequence
- Extension lifecycle / plugin registration flow
- Event or message flow
- Component relationship map
- Change-decision flowchart (for the change guide page)

Every diagram must have a text explanation alongside it — diagrams are overviews,
prose provides the detail.

### Content Quality Rules

**Fact vs. Inference separation** — clearly distinguish throughout all pages:
- **Observed:** directly evident from code — file structure, imports, interfaces, explicit patterns
- **Inferred:** why choices were likely made. Label as inference. Web-sourced context
  includes the source URL.

**Language translation** — if the codebase uses a language outside the assumed reader's
background, map language-specific idioms to equivalents in a familiar language. Example:
"This Elixir GenServer is analogous to a long-running service with an internal message
queue in Java."

**Neutral tone** — describe architectural trade-offs factually (e.g., "event sourcing
adds replay capability but increases write complexity") without judging whether a
choice is good or bad.

**Self-contained** — the reader should not need external sources to understand the docs.

### Architecture Page: Transferable Principles

At the bottom of `architecture.html`, synthesize 3-7 general design principles derived
from this codebase. Each principle must be:

- **General** — applicable beyond this specific project
- **Actionable** — something the reader could apply when designing their own system
- **Grounded** — with a reference to how this codebase implements it

Present each as a callout card:
> **[Principle name]** — [General statement of the principle]
> *As seen here:* [Specific component or pattern reference]

Aim for quality over quantity. Only include principles that are genuinely non-obvious.

### Boot Sequence (include when relevant)

If the startup sequence is non-trivial (initialization order matters, services are
wired in specific steps), include on the architecture page:
- An SVG sequence diagram from process start to "ready"
- A table: Step | File | What happens

### Feature Implementation Guide (if selected)

On `feature-guide.html`, walk through implementing the chosen feature with **no code** —
only which files, classes, and methods to touch and why.

Structure:
1. Brief description of the feature and its user-facing value
2. If the AI chose the feature: explain which layers it exercises and why it was chosen
   as an instructive example
3. SVG flow diagram showing how the feature execution traverses system layers
4. File-by-file narrative, ordered: types/interfaces → core logic → transport/API →
   config → tests

For each file:
```
path/to/file.ext — modify | create

Why this file is involved: [1-2 sentences]

What needs to happen:
- ClassName.methodName() — [what should change and why, no code]
- AnotherClass — [new method or field to add and its purpose]
```

5. Key considerations: non-obvious concerns (backward compatibility, migration needs,
   performance implications, security) without prescribing solutions.

### Quality Checklist

Before declaring documentation complete:

- [ ] Every page leads with its main takeaway
- [ ] Every diagram has a text explanation
- [ ] Fact/inference separation is applied consistently
- [ ] Navigation appears on every page and works correctly
- [ ] All file paths referenced actually exist in the project
- [ ] Stylesheet is shared — no isolated per-page styles
- [ ] A developer unfamiliar with the project can understand the architecture after reading
- [ ] If feature guide generated: contains NO code, only descriptions of what to change and why
- [ ] If feature guide generated: covers files across multiple architectural layers
- [ ] If glossary generated: defines every non-obvious term used in the documentation
- [ ] If junior audience: boot sequence is documented; dev commands table is present

## Update Mode

When the user asks to extend existing docs:

1. Read all existing HTML files first
2. Preserve filenames, navigation labels, and visual language unless actively misleading
3. Determine whether new content should:
   - Add a section to an existing page
   - Add a new page
   - Revise an existing explanation or diagram
4. Update `styles.css` for new shared diagram styles rather than adding per-page styles
5. If new findings change the architectural story, revise earlier pages rather than
   only appending — keep the documentation coherent, not merely accumulated
6. Keep terminology consistent with what already exists

If the existing documentation is inconsistent or poor quality, it is acceptable to
refactor the structure while adding new content — but inform the user.

## Edge Cases

- **Minimal docs:** Trigger web search fallback. State if analysis is code-only.
- **Libraries (no entry points):** Shift from flow tracing to public API surface analysis.
  Map interface boundaries and extension points instead.
- **Monorepos:** Map all services/packages in Phase 1. Deep-explore the primary service
  in Phases 2-4. Document others on the components page with lighter coverage.
- **Trivially small codebases:** Acknowledge this honestly. Still provide value via
  pattern identification, dependency choices, and design decisions at small scale.
- **Existing docit output:** If the output directory already exists, ask whether to
  start fresh or extend.

## References

- `references/presentation-guidelines.md` — Visual design and readability guidance
- `references/exploration-procedure.md` — Detailed discovery steps, file-reading
  strategy, pattern recognition tables, dependency categorization
