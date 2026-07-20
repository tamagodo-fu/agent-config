# Memory File Templates

## 1. Enterprise Policy Template

Location:
- macOS: `/Library/Application Support/ClaudeCode/CLAUDE.md`
- Linux: `/etc/claude-code/CLAUDE.md`
- Windows: `C:\Program Files\ClaudeCode\CLAUDE.md`

```markdown
# Enterprise Development Standards

## Security Requirements
- Never commit secrets or credentials
- All API endpoints require authentication
- Follow OWASP security guidelines

## Code Review Policy
- All changes require PR review
- Minimum 1 approval required
- CI must pass before merge

## Approved Technologies
- Languages: [list approved languages]
- Frameworks: [list approved frameworks]
- Cloud providers: [list approved providers]

## Compliance
- Follow data privacy regulations
- Log all data access
- Use approved logging formats
```

---

## 2. User Memory Template

Location: `~/.claude/CLAUDE.md`

```markdown
# Personal Preferences

## Communication Style
- Be concise and direct
- Use technical terminology
- Prefer code examples over explanations

## Coding Style
- Use 2-space indentation
- Prefer functional programming patterns
- Always add type annotations

## Preferred Tools
- Package manager: pnpm
- Test framework: vitest
- Linter: ESLint with strict config

## Workflow Preferences
- Create feature branches for changes
- Write tests before implementation
- Commit frequently with clear messages

## Language Preferences
- Primary: TypeScript
- Secondary: Python, Go
```

---

## 3. User Rules Templates

Location: `~/.claude/rules/`

### coding-style.md
```markdown
# Coding Style Preferences

## Formatting
- 2-space indentation
- Single quotes for strings
- Trailing commas in multiline
- Max line length: 100

## Naming
- camelCase for variables and functions
- PascalCase for classes and types
- SCREAMING_SNAKE for constants
- Descriptive names over abbreviations

## Comments
- Document "why", not "what"
- Use JSDoc for public APIs
- No commented-out code
```

### git-workflow.md
```markdown
# Git Workflow

## Commit Messages
- Use conventional commits format
- Start with type: feat, fix, docs, style, refactor, test, chore
- Keep subject under 50 characters
- Reference issue numbers

## Branching
- feature/[description] for new features
- fix/[description] for bug fixes
- chore/[description] for maintenance

## Pre-commit
- Run linter before commit
- Run tests for changed files
- Format code automatically
```

---

## 4. Project Memory Template

Location: `./CLAUDE.md` or `./.claude/CLAUDE.md`

```markdown
# Project: [Project Name]

## Overview
[Brief description of the project]

## Quick Commands
- Build: `npm run build`
- Test: `npm run test`
- Lint: `npm run lint`
- Dev: `npm run dev`

## Architecture
- Framework: [e.g., Next.js 14]
- Database: [e.g., PostgreSQL with Prisma]
- State: [e.g., Zustand]
- Styling: [e.g., Tailwind CSS]

## Directory Structure
```
src/
  components/   # React components
  hooks/        # Custom hooks
  lib/          # Utility functions
  api/          # API routes
  types/        # TypeScript types
```

## Key Patterns
- Use Server Components by default
- Client Components only when needed (interactivity, hooks)
- API routes for server-side logic
- Zod for validation

## External References
@README.md for project setup
@docs/CONTRIBUTING.md for contribution guidelines
```

---

## 5. Project Rules Templates

Location: `./.claude/rules/`

### api-design.md
```markdown
---
paths: src/api/**/*.ts
---

# API Design Rules

## Request Handling
- Validate all inputs with Zod
- Use standardized error responses
- Include request ID in responses

## Response Format
\`\`\`typescript
{
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
  };
}
\`\`\`

## Error Codes
- 400: Validation errors
- 401: Authentication required
- 403: Permission denied
- 404: Resource not found
- 500: Internal error
```

### testing.md
```markdown
---
paths: **/*.test.ts, **/*.spec.ts
---

# Testing Guidelines

## Structure
- Use describe blocks for grouping
- One assertion per test when possible
- Use meaningful test names

## Mocking
- Mock external dependencies
- Use factories for test data
- Reset mocks between tests

## Coverage
- Aim for 80% coverage
- Focus on critical paths
- Don't test implementation details
```

### components.md
```markdown
---
paths: src/components/**/*.tsx
---

# Component Guidelines

## Structure
- One component per file
- Export component as default
- Colocate styles and tests

## Props
- Use TypeScript interfaces
- Document required vs optional
- Provide sensible defaults

## State
- Prefer hooks over class state
- Lift state when shared
- Use context for global state
```

---

## 6. Local Memory Template

Location: `./CLAUDE.local.md`

```markdown
# Local Development Notes

## My Environment
- Node version: 20.x
- Database URL: localhost:5432
- API endpoint: http://localhost:3000

## Current Focus
- Working on: [feature/task]
- Branch: feature/my-feature
- Blocked by: [any blockers]

## Personal Shortcuts
- Test specific file: `npm test -- path/to/file`
- Debug mode: `DEBUG=* npm run dev`

## Local Credentials (DO NOT COMMIT)
- Test API key: [your test key]
- Sandbox URL: [your sandbox]

## Notes
- [Any personal notes about the project]
```
