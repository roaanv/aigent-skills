# aigent-skills

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin with skills for architectural analysis, onboarding documentation, and iOS/macOS deployment automation.

## Skills

| Skill | Invoke with | Purpose |
|-------|-------------|---------|
| [Codebase Overview](#codebase-overview) | `/aigent-skills:codebase-overview` | Two-phase architectural analysis with mermaid diagrams |
| [Noob Doc](#noob-doc) | `/aigent-skills:noob-doc` | Generate onboarding documentation for junior engineers |
| [Fastlane Setup](#fastlane-setup) | `/aigent-skills:fastlane-setup` | One-time fastlane initialization for iOS/macOS projects |
| [Fastlane Deploy](#fastlane-deploy) | `/aigent-skills:fastlane-deploy` | Build and upload to TestFlight or the App Store |
| [Repo to HTML](#repo-to-html) | `/aigent-skills:repo-to-html` | Create polished HTML technical deep-dive documentation for any software project |
| [Docit](#docit) | `/aigent-skills:docit` | Combined HTML architecture documentation — adapts to experienced devs or juniors, with optional feature guides, glossary, and dev commands |

Each skill can be invoked two ways:

1. **Explicitly** by its qualified name (shown in the table above) — deterministic; bypasses trigger-phrase matching.
2. **Implicitly** by using one of the natural-language trigger phrases listed under each skill — Claude Code matches the request against the skill's description and invokes it automatically.

### Codebase Overview

Produces a two-phase architectural analysis of any codebase:

1. **Phase 1 — Autonomous Survey:** Breadth-first exploration that maps project structure, dependencies, key flows, and design patterns. Outputs a written report with mermaid diagrams.
2. **Phase 2 — Interactive Deep Dives:** Guided exploration of specific areas identified in Phase 1, with subagent-dispatched analysis appended to the report.

Designed for experienced developers who want to understand *how a system is designed* — not a line-by-line code walkthrough.

**Invoke:** `/aigent-skills:codebase-overview`
**Trigger phrases:** "review this codebase", "analyze the architecture", "what patterns does this project use", "how is this project structured"

### Noob Doc

Generates a comprehensive `noob.md` architecture document aimed at a junior engineer who has never seen the codebase. Runs a short scoping interview, then produces self-contained onboarding documentation covering structure, key flows, and conventions — enough for a new contributor to add significant features without further hand-holding.

**Invoke:** `/aigent-skills:noob-doc`
**Trigger phrases:** "document this codebase", "write onboarding docs", "create a getting started guide", "explain the architecture for a junior", "generate noob docs"

### Fastlane Setup

One-time initialization of [fastlane](https://fastlane.tools) for an iOS or macOS project. Detects the Xcode project or workspace, installs fastlane, generates a `Fastfile` with `beta` (TestFlight) and `release` (App Store) lanes, and configures code signing via [match](https://docs.fastlane.tools/actions/match/). Leaves the project with a working deployment pipeline.

**Invoke:** `/aigent-skills:fastlane-setup`
**Trigger phrases:** "set up fastlane", "configure fastlane", "initialize fastlane for deployment", "set up code signing", "configure TestFlight", "prepare for App Store deployment"

### Fastlane Deploy

Runs the full build-and-upload pipeline for an iOS or macOS app: preflight checks, auto-increments the build number, syncs code signing, builds, and uploads to TestFlight (beta) or the App Store (release). Requires that Fastlane Setup has already been run on the project.

**Invoke:** `/aigent-skills:fastlane-deploy`
**Trigger phrases:** "deploy to TestFlight", "upload to TestFlight", "submit to App Store", "release the app", "push a beta build", "ship a build", "deploy with fastlane"

### Repo to HTML

Creates or extends polished multi-page HTML technical documentation for any software codebase. Explores the repo structure, builds an architecture model, then generates a self-contained doc site with navigation, diagrams, and a change guide — presentation-friendly by default. Supports iterative updates: follow-up questions extend the existing documentation set in place rather than creating a disconnected second deliverable.

**Invoke:** `/aigent-skills:repo-to-html`
**Trigger phrases:** "explain this codebase in depth", "document the architecture", "create deep-dive documentation", "generate an HTML doc site for this repo", "add a section to the existing docs", "create presentation-friendly documentation"

### Docit

Combines the strengths of Codebase Overview, Noob Doc, and Repo to HTML into a single skill. Generates a polished multi-page HTML doc site for any codebase, adapting depth and framing based on the intended audience (experienced engineers or juniors). Covers architecture, components, extensibility, key flows, patterns, and practical change guidance. Optional sections include a feature implementation guide (which files to touch for a new feature, no code), a dev commands table, and a glossary. Also supports extending existing docs in place.

**Invoke:** `/aigent-skills:docit`
**Trigger phrases:** "document this codebase", "create architecture docs", "explain this project", "generate HTML docs", "write onboarding documentation", "document this for a junior", "create a getting started guide", "explain the architecture", "create deep-dive documentation", "review this codebase", "help new engineers understand this"

## Installation

### From GitHub

In Claude Code, add the repository as a marketplace source, then install the plugin:

```
/plugin marketplace add roaanv/aigent-skills
/plugin install aigent-skills@roaanv-aigent-skills
```

After installation, reload plugins in your current session:

```
/reload-plugins
```

### For local development

To load the plugin for the current session only (not persisted):

```bash
claude --plugin-dir /path/to/aigent-skills
```

## Development

### Prerequisites

- [gitleaks](https://github.com/gitleaks/gitleaks) (secret detection)
- Python 3.x (for pre-commit)

### Setup

```bash
git clone https://github.com/roaanv/aigent-skills.git
cd aigent-skills
make setup
```

`make setup` installs the [pre-commit](https://pre-commit.com/) framework and activates a gitleaks hook that blocks commits containing hardcoded secrets.

### Available Make targets

| Target | Description |
|--------|-------------|
| `make setup` | Install dependencies and configure git hooks |
| `make lint` | Run all pre-commit hooks against all files |
| `make scan-secrets` | Run gitleaks against the full repo history |
| `make help` | Show all available targets |

## Project structure

```
.claude-plugin/
  plugin.json          # Plugin manifest (name, version, author)
  marketplace.json     # Marketplace catalog (enables install from GitHub)
skills/
  codebase-overview/
    SKILL.md            # Skill definition and instructions
    references/         # Supporting templates and procedures
  noob-doc/
    SKILL.md            # Junior-engineer onboarding doc generator
  fastlane-setup/
    SKILL.md            # One-time fastlane project initialization
    references/         # Prerequisites, project detection, Fastfile templates, match setup
  fastlane-deploy/
    SKILL.md            # TestFlight / App Store deployment pipeline
    references/         # Preflight checks, deploy steps, error diagnosis
  repo-to-html/
    SKILL.md            # HTML deep-dive documentation generator
    references/         # Presentation and readability guidelines
  docit/
    SKILL.md            # Combined HTML architecture documentation generator
    references/         # Presentation guidelines and exploration procedure
docs/                   # Specs and plans
Makefile                # Build and setup automation
.pre-commit-config.yaml # Pre-commit hook configuration
.gitleaks.toml          # Secret detection rules and allowlist
```

## License

Private — not currently licensed for redistribution.
