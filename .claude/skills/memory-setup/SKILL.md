---
name: memory-setup
description: Creates and manages CLAUDE.md files and rules for Claude Code memory system. Use when setting up project memory, user preferences, enterprise policies, or modular rules. Triggers on "create CLAUDE.md", "setup memory", "add rules", "project instructions".
---

# Claude Code Memory Setup

Create and manage memory files for Claude Code based on purpose and location.

## Memory Types Overview

| Type | Location | Shared | Purpose |
|------|----------|--------|---------|
| **Enterprise** | System-wide | Org | IT-managed policies |
| **User** | `~/.claude/CLAUDE.md` | You (all projects) | Personal preferences |
| **User Rules** | `~/.claude/rules/*.md` | You (all projects) | Modular personal rules |
| **Project** | `./CLAUDE.md` | Team | Shared project instructions |
| **Project Rules** | `./.claude/rules/*.md` | Team | Modular project rules |
| **Local** | `./CLAUDE.local.md` | You (project) | Private project preferences |

## Quick Start

### 1. Identify the Right Location

Ask these questions:
- **Who needs this?** → Team (Project) vs Just me (User/Local)
- **Which projects?** → All (User) vs This one (Project/Local)
- **Version control?** → Yes (Project) vs No (Local)

### 2. Create Memory File

Use the workflow for the identified type:

```
/memory-setup [type]
```

Types: `enterprise`, `user`, `user-rules`, `project`, `project-rules`, `local`

## Reference Files

- **[TEMPLATES.md](references/TEMPLATES.md)** - Ready-to-use templates for each type
- **[RULES-GUIDE.md](references/RULES-GUIDE.md)** - Creating modular `.claude/rules/`
- **[IMPORTS.md](references/IMPORTS.md)** - Using `@path` imports
- **[BEST-PRACTICES.md](references/BEST-PRACTICES.md)** - Writing effective memory

## Common Workflows

### Setup New Project Memory
1. Create `./.claude/` directory
2. Create `CLAUDE.md` with project guidelines
3. Add `rules/` subdirectory for modular rules
4. Add `.gitignore` entries for local files

### Setup Personal Preferences
1. Edit `~/.claude/CLAUDE.md`
2. Add personal coding style and preferences
3. Create `~/.claude/rules/` for modular personal rules

### Add Conditional Rules
Create path-specific rules with YAML frontmatter:
```markdown
---
paths: src/api/**/*.ts
---
# API Rules
- Validate all inputs
- Use standard error format
```

## Priority Order (lowest to highest)

1. Enterprise policy (system-wide)
2. User memory (`~/.claude/CLAUDE.md`)
3. User rules (`~/.claude/rules/`)
4. Project memory (`./CLAUDE.md`)
5. Project rules (`./.claude/rules/`)
6. Local memory (`./CLAUDE.local.md`)

Higher priority rules override lower ones.

## File Lookup Behavior

Claude Code discovers memories by:
1. Starting from current working directory
2. Recursing up to (not including) root `/`
3. Loading all `CLAUDE.md` and `CLAUDE.local.md` found
4. Loading rules from `.claude/rules/` directories
