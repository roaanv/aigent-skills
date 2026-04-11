---
name: Codebase Overview
description: >
  This skill should be used when the user asks to "review this codebase",
  "analyze the architecture", "what patterns does this project use",
  "help me understand this system", "give me an architectural overview",
  "how is this project structured", or wants to learn how an unfamiliar
  codebase is designed at a high level. Produces a two-phase architectural
  analysis: autonomous survey followed by interactive deep dives.
---

# Codebase Overview

Produce a high-level architectural analysis of a codebase. Designed for experienced
developers (Java/C#/Python/TypeScript/Go background) who want to learn how unfamiliar
systems are designed — not how they are implemented line-by-line.

The goal: extract enough architectural understanding to inform the user's own system
design work in that domain.

## What This Skill Is NOT

- Not a code quality reviewer — no "this is bad/good" judgments
- Not a refactoring tool — no code generation or change suggestions
- Not a line-by-line code explainer — stays at the component/pattern level
- Read-only analysis — the only file created is the overview document

## Optional Parameters

- **model** — override the session model for subagents (inherits session model by default).
  Subagents inherit the same model. Do not switch models between subtasks.
- **focus** — bias the survey toward a specific area (e.g. "agent orchestration layer").
  When provided, still perform the full breadth-first survey but allocate more depth
  to the focused area (trace additional flows, read more files from that subsystem).

## Two-Phase Process

### Phase 1: Autonomous Survey

Run a breadth-first exploration without user interaction. Follow these steps in order:

1. **Project Identity** — Read README, docs, ADRs, package manifests. Identify language(s),
   framework(s), build system, repo structure. If local docs are insufficient (README < ~20
   lines or missing, no docs/ADR directories), trigger a web search fallback for external
   documentation. See `references/phase1-analysis.md` for detailed procedures.

2. **Structural Map** — Analyze top-level directory layout and one level deeper. Identify
   architectural layers and module boundaries. Produce a mermaid component diagram.

3. **Dependency Analysis** — Categorize external dependencies by purpose. Map internal
   module relationships. Produce a mermaid dependency graph.

4. **Key Flow Tracing** — Identify 2-3 primary entry points. Trace each flow at the
   component level (not line-by-line). Produce mermaid sequence diagrams. For monorepos,
   trace flows in the primary service; flag others for Phase 2.

5. **Pattern Recognition** — Identify design patterns (repository, factory, strategy,
   observer, middleware, CQRS, etc.) and architectural patterns (hexagonal, clean
   architecture, MVC, microservices, etc.). Note unusual or noteworthy choices.

6. **Initial Report** — Assemble findings using the template in
   `references/document-template.md`. Present conversationally in the terminal AND
   simultaneously write to `docs/architecture-overview.md` as a working draft (create
   the `docs/` directory if it does not exist).

**File reading strategy:** Read for structure (imports, exports, signatures, interfaces),
not implementation bodies. Priority: README/docs -> package manifests -> directory structure
-> entry points -> one representative file per major module.

### Phase 2: Interactive Deep Dives

After presenting the Phase 1 report, transition to interactive mode.
See `references/phase2-deep-dives.md` for detailed procedures.

1. **Suggest areas** — Generate 3-5 specific suggestions for deeper exploration based on
   what Phase 1 actually found. These must be specific to this codebase, not generic.

2. **Execute deep dives** — For each user request, dispatch a focused subagent to explore
   the area. Present findings conversationally AND append to the working draft under
   `## Deep Dive: {topic}`. Generate new mermaid diagrams when structure is worth visualizing.

3. **Finalize** — When the user signals completion ("finalize", "wrap it up"), synthesize
   the Transferable Principles section, ask if the user wants to reorganize/trim the
   document, and save the final version.

## Analysis Principles

### Fact vs. Inference Separation

All analysis must clearly distinguish between:
- **Observed (fact):** directly evident from code — file structure, imports, interfaces, explicit patterns
- **Inferred (reasoning):** why choices were likely made, labeled as inference. Web-sourced
  context includes the source URL.

### Language Translation

When the codebase uses a language outside the user's primary languages
(Java/C#/Python/TypeScript/Go), map language-specific idioms to equivalents in familiar
languages. Example: "This Elixir GenServer is analogous to a long-running service with
an internal message queue in Java."

### Neutral Tone

Describe architectural trade-offs factually (e.g. "event sourcing adds complexity but
provides a full audit trail") without judging whether a choice is good or bad.

### Mermaid Diagrams

Always include mermaid diagrams for: component relationships, internal dependency graphs,
and key flow sequence diagrams. See `references/document-template.md` for diagram format
examples.

## Edge Cases

- **Minimal docs:** Web search fallback fires. If nothing found externally, note that
  analysis is derived entirely from code structure.
- **Libraries (no entry points):** Shift from flow tracing to public API surface analysis.
  Map interface boundaries and extension points.
- **Trivially small codebases:** Acknowledge honestly. Still provide value: patterns,
  dependency choices, design decisions at the small scale.
- **Monorepos:** Map all services/packages in Phase 1. Flow-trace the primary/largest
  service. Flag others for Phase 2.
- **Re-invocation:** If `docs/architecture-overview.md` exists, ask whether to start
  fresh or continue from the existing document.

## Additional Resources

### Reference Files

For detailed procedures and templates, consult:
- **`references/phase1-analysis.md`** — Detailed Phase 1 analysis steps, file reading
  strategy, web search fallback logic, pattern recognition guide
- **`references/phase2-deep-dives.md`** — Deep dive types and execution, subagent dispatch,
  transition prompts, finalization and transferable principles synthesis
- **`references/document-template.md`** — Complete output document template with mermaid
  diagram examples and fact/inference formatting
