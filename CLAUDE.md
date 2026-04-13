# aigent-skills — Claude Code Instructions

## Adding a new skill

When a new skill is added under `skills/`, update the README to document it:

1. **Summary table** — add a row to the table at the top of the Skills section:
   ```
   | [Skill Name](#skill-name) | `/aigent-skills:<skill-name>` | One-line description |
   ```

2. **Skill section** — add a `### Skill Name` section with:
   - A prose description of what the skill does (1–3 sentences)
   - `**Invoke:** /aigent-skills:<skill-name>`
   - `**Trigger phrases:**` — a comma-separated list of natural-language phrases that invoke the skill automatically, drawn from the skill's `description` frontmatter

3. **Project structure diagram** — add the new skill directory and its contents (e.g. `SKILL.md`, `references/`) to the tree in the Project structure section.
