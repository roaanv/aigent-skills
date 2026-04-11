# Phase 2: Interactive Deep Dives — Detailed Procedures

## Transition from Phase 1

After presenting the Phase 1 report, transition to interactive mode with a prompt like:

> "That's the high-level picture. What areas would you like to explore further?
> Based on what I found, here are some areas that look architecturally interesting:"
>
> - {suggestion 1 — specific to what was found}
> - {suggestion 2 — specific to what was found}
> - {suggestion 3 — specific to what was found}
>
> "Or ask about anything else you see in the overview."

### Generating Suggestions

Suggestions must be specific to THIS codebase, not generic. Generate them by identifying:

1. **Complex components** — modules with many internal dependencies or that many other
   modules depend on
2. **Unusual patterns** — anything that deviates from the dominant architectural style
3. **Critical paths** — flows that touch the most components or involve external systems
4. **Interesting boundaries** — where the architecture shifts style (e.g. sync to async,
   monolith to microservice boundary)
5. **Unfamiliar patterns** — patterns the user might not have seen in their primary
   languages (Java/C#/Python/TypeScript/Go)

## Deep Dive Execution

### General Procedure

For each user request:

1. Identify which files and modules are relevant to the requested topic
2. Dispatch a subagent using the **Agent tool** (subagent_type: "Explore" for
   read-only investigation) with a focused prompt (see templates below). The subagent
   inherits the session model unless a model override was specified at invocation.
3. Present findings conversationally in the terminal
4. Append findings to the working draft under `## Deep Dive: {topic}`
5. Include new mermaid diagrams when the deep dive reveals visualizable structure

### Deep Dive Types and Subagent Prompts

#### "Trace the {X} flow"

Goal: Follow a specific flow end-to-end through all layers.

Subagent prompt template:
> "Trace the {X} flow in this codebase end-to-end. Start from the entry point and
> follow it through every component it touches. For each step, note: the component
> name, what it does to the data/request, and what it passes to the next component.
> Report the file path where each component lives. Produce a mermaid sequence diagram
> of the complete flow. Focus on the architectural flow, not implementation details.
> Clearly label anything you infer vs. directly observe."

#### "How does {component} work?"

Goal: Examine a subsystem's internal design and boundaries.

Subagent prompt template:
> "Analyze the internal design of the {component} subsystem. Identify: its public
> interface (what other components can call), its internal structure (sub-components,
> classes, key abstractions), its dependencies (what it imports/uses), and its design
> patterns. Report file paths for key files. Produce a mermaid diagram of its internal
> structure if it has multiple sub-components. Focus on design, not implementation.
> Clearly label inferences."

#### "What pattern is used for {X}?"

Goal: Identify and explain the design pattern behind a specific concern.

Subagent prompt template:
> "Identify the design pattern used for {X} in this codebase. Explain: what the pattern
> is, how it's structured here (key classes/interfaces/functions involved with file paths),
> and what problem it solves. If the codebase uses a language outside Java/C#/Python/
> TypeScript/Go, map the pattern to an equivalent in one of those languages. Clearly
> label inferences about why this pattern was chosen."

#### "Compare this to how you'd do it in {language}"

Goal: Map the approach to the user's familiar languages.

Subagent prompt template:
> "Analyze how {aspect} is implemented in this codebase. Then describe how the same
> architectural approach would typically be implemented in {language}, including:
> which libraries/frameworks are commonly used, what the equivalent abstractions are,
> and where the approaches would differ due to language capabilities. Focus on
> architectural equivalence, not line-by-line translation."

#### "What are the trade-offs of this approach?"

Goal: Analyze alternatives and why they likely weren't chosen.

Subagent prompt template:
> "Analyze the approach used for {aspect} in this codebase. Describe: what approach
> is used (observed), what alternative approaches exist for solving the same problem,
> the trade-offs of each alternative vs. what was chosen, and any indicators in the
> code for why this approach was selected. Present trade-offs as neutral factual
> comparisons, not quality judgments. Clearly label inferences."

#### Freeform Questions

For questions that don't match a template, construct a subagent prompt that:
1. States the specific question to answer
2. Instructs the subagent to focus on architecture, not implementation
3. Requires fact/inference separation
4. Requests mermaid diagrams if the answer involves structure
5. Asks for language translation if relevant

### Updating the Working Draft

After each deep dive, append to `docs/architecture-overview.md`:

```markdown
## Deep Dive: {topic title}

{Findings in the same fact/inference format as Phase 1}

{Mermaid diagrams if applicable}
```

Maintain consistent formatting with the Phase 1 sections.

## Finalization

Triggered when the user signals completion (e.g. "finalize", "wrap it up", "that's enough").

### Step 1: Synthesize Transferable Principles

Review all findings (Phase 1 + all deep dives) and extract domain-independent principles.

Each principle should be:
- **General** — applicable beyond this specific codebase
- **Actionable** — something the user could apply when designing their own system
- **Grounded** — with a reference back to how this codebase implements it

Format:
```markdown
## Transferable Principles

### 1. {Principle name}

{General statement of the principle}

**As seen here:** {How this codebase implements it, with specific component references}
```

Aim for 3-7 principles. Quality over quantity — only include principles that are
genuinely transferable and non-obvious.

### Step 2: Offer Document Cleanup

Ask the user:
> "The overview document is complete. Would you like me to reorganize or trim
> anything before we finalize? For example, I can reorder deep dives, remove
> sections that weren't useful, or add a table of contents."

### Step 3: Save Final Document

Write the final version to `docs/architecture-overview.md`. If the user specified
a custom path, use that instead.
