---
name: repo-to-html
description: Create or extend polished HTML technical deep-dive documentation for any software project. Use this when the user wants a codebase explained in depth, wants architecture and component relationships documented, wants slideshow- or presentation-friendly HTML output, or wants to iteratively add new sections, diagrams, and answers to an existing deep-dive documentation set.
---

# Repo Deep Dive Docs

## Overview

Use this skill when the user wants durable documentation for understanding a codebase, not just a chat answer. The default output is a polished multi-page HTML doc site that explains architecture, major components, extensibility, relationships between areas, and practical guidance for making significant changes.

This skill also supports iterative updates. If the user asks follow-up questions after the initial documentation is generated, extend the existing documentation set in place instead of creating a disconnected second deliverable.

## Clarify First

Before doing substantial work, ask the minimum clarifying questions needed to lock the output format and update mode.

Ask about:

1. Output location and folder name, if the user did not specify one.
2. Output shape:
   - single self-contained slide-style HTML page, or
   - small multi-page HTML doc site with shared navigation.
3. Whether this is:
   - a fresh documentation pass, or
   - an addition/update to an existing documentation set.

Recommended default if the user does not care:

- multi-page HTML doc site
- shared stylesheet
- optional embedded SVG diagrams
- ability to extend the same docs later

If the user explicitly asks to “add” to existing docs, first read the existing documentation files and preserve their style, navigation, naming, and visual system.

## Workflow

### 1. Discover the project shape

Read the repo before writing documentation. Build understanding from actual files, not guesses.

Start with:

- workspace/package manifests
- root README and project instructions
- top-level directories
- package or app READMEs
- major entrypoints
- core architecture files

Prefer fast repo inspection tools such as:

- `rg --files`
- `find` for high-level directory maps
- `sed -n` or similar for targeted file reads

Identify:

- primary runtime layers
- package/app boundaries
- key entrypoints
- persistence model
- extension/plugin/customization seams
- UI surfaces
- operational tooling surfaces

### 2. Build the architecture model

The documentation should explain:

- high-level components or areas
- how those areas interrelate
- the main dependency spine or layering
- important patterns and conventions
- stable seams vs surface-level implementation details
- where to make different classes of changes

Separate:

- foundational abstractions
- product-specific assembly
- delivery surfaces or consumers

### 3. Generate HTML documentation

Default to a readable, presentation-friendly HTML deliverable.

Preferred structure for a fresh pass:

- landing page
- architecture page
- packages/components page
- extensibility page
- surfaces/integrations page
- change guide or reading order page

Use:

- one shared stylesheet
- clear navigation between pages
- strong section hierarchy
- cards, callouts, and diagrams where helpful

If the user asks for slide behavior, a single-page deck is acceptable. Otherwise prefer the multi-page doc site because it works better as durable reference material.

### 4. Support iterative additions

When the user asks follow-up questions after docs already exist:

1. Read the existing docs first.
2. Determine whether the new request should:
   - add a section to an existing page,
   - add a new page, or
   - revise an existing explanation/diagram.
3. Keep visual language, navigation, and terminology consistent.
4. Prefer extending the existing information architecture over fragmenting it.
5. If new questions expose missing architectural detail, revise earlier pages instead of only appending new material.

Examples of valid iterative additions:

- deeper persistence internals
- event flow diagrams
- additional package deep dives
- deployment/runtime topology
- decision trees for where changes belong

## Presentation And Readability Guidance

Do not re-research this by default. Use the following guidance unless the user asks for a different visual style.

### Core readability rules

- Use descriptive headings that make sections scannable without surrounding context.
- Keep each section focused on one main idea.
- Break dense explanations into short paragraphs, lists, cards, or diagrams.
- Prefer strong visual hierarchy over decorative complexity.
- Use high contrast and generous spacing.
- Keep line lengths readable.
- Use callouts for key conclusions and decision rules.
- Use diagrams when relationships, flows, or layering are easier to grasp visually than in prose.

### Presentation-oriented rules

- Make pages work both as reading material and as walk-through material.
- Keep hero sections concise and orienting.
- Avoid dumping long walls of text near the top of a page.
- Put the most important idea early on each page.
- Use navigation that lets a presenter jump directly to a topic.
- Favor a small number of strong visuals over many weak ones.

### Good default visual system

- shared stylesheet
- warm or neutral background with strong contrast
- one accent color plus one secondary emphasis color
- serif or editorial-feeling typography for long-form reading
- sans-serif for labels, nav, and diagrams
- rounded panels/cards with subtle borders and shadows

## Diagram Guidance

When diagrams would materially help, prefer embedded SVG so the output stays self-contained and editable.

Good diagram candidates:

- dependency spine
- runtime flow
- session persistence model
- branching/tree model
- extension lifecycle
- event flow
- package dependency map
- change-decision flow

SVG diagrams should:

- have an `aria-label`
- use a consistent shared style
- prioritize legibility over decoration

## Update Mode

When extending existing docs:

- preserve filenames unless a restructure is clearly better
- preserve navigation labels unless they are actively misleading
- reuse the shared stylesheet
- add new shared diagram styles there rather than per page when possible

If the existing documentation is poor or inconsistent, it is acceptable to refactor the docs structure while adding the new content, but keep the user informed.

## Deliverable Expectations

The final documentation should help a senior engineer:

- navigate the codebase
- understand the architecture and patterns
- understand extensibility/customization mechanisms
- identify the major components and their relationships
- know where to make substantial changes

The result should be durable documentation, not just a transcript of what you read.

## References

Read this only when you need the baked-in style guidance in more detail:

- `references/presentation-guidelines.md`
