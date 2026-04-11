# aigent-skills

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin with skills for architectural analysis and codebase understanding.

## Skills

### Codebase Overview

Produces a two-phase architectural analysis of any codebase:

1. **Phase 1 — Autonomous Survey:** Breadth-first exploration that maps project structure, dependencies, key flows, and design patterns. Outputs a written report with mermaid diagrams.
2. **Phase 2 — Interactive Deep Dives:** Guided exploration of specific areas identified in Phase 1, with subagent-dispatched analysis appended to the report.

Designed for experienced developers who want to understand *how a system is designed* — not a line-by-line code walkthrough.

**Trigger phrases:** "review this codebase", "analyze the architecture", "what patterns does this project use", "how is this project structured"

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
docs/                   # Specs and plans
Makefile                # Build and setup automation
.pre-commit-config.yaml # Pre-commit hook configuration
.gitleaks.toml          # Secret detection rules and allowlist
```

## License

Private — not currently licensed for redistribution.
