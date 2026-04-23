# Presentation And Readability Guidelines

Use this guidance when generating HTML technical documentation intended to be both easy to read and easy to present.

## Goals

The output should:

- be easy to skim
- be easy to present to others
- support repeated extension over time
- help the reader move from orientation to deep detail

## Structure

Prefer this progression:

1. Orientation
2. Architecture spine
3. Component or package map
4. Extensibility/customization model
5. Delivery surfaces or integrations
6. Practical change guide

For multi-page sites, keep each page centered on one topic.

## Content Design

- Use headings that carry real meaning, not generic titles like "Details".
- Lead each page with the main takeaway.
- Keep paragraphs short.
- Use lists when the information is naturally list-shaped.
- Use callouts for thesis statements, caveats, and decision rules.
- Use diagrams for relationships, flows, and layered architecture.

## Visual Design

- Use a shared stylesheet.
- Maintain consistent page chrome and navigation.
- Favor calm, high-contrast backgrounds.
- Use typography with a clear distinction between long-form text and interface labels.
- Keep decorative effects subtle.

## Diagrams

Preferred format: embedded SVG.

Recommended diagrams:

- runtime flow
- dependency layering
- session tree/branching
- extension lifecycle
- event flow
- decision flow for where code changes belong

## Iterative Extension

When updating an existing doc set:

- keep terminology consistent
- preserve navigation unless it needs improvement
- update earlier pages if new findings change the architectural story
- add new diagrams only where they materially improve understanding

## Style References Used To Derive These Rules

These were previously used to derive the baked-in guidance:

- University of Michigan slide deck best practices
- Newcastle University readability guidance
- University of Washington presentation guidance
- ACS scannability guidance
