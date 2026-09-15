# Security Guidelines

## Mandatory Security Checks

Before ANY commit, inspect every changed file for common secret material (API keys, passwords, tokens, private keys, credentials, and sensitive endpoints). Then apply the controls relevant to the interfaces affected by the diff:
- [ ] No hardcoded secrets in any changed file
- [ ] Untrusted inputs validated at the affected boundary
- [ ] Database queries parameterized where SQL is changed
- [ ] Untrusted HTML sanitized where rendering is changed
- [ ] CSRF protection verified where state-changing browser endpoints are changed
- [ ] Authentication/authorization verified where protected resources or permissions are changed
- [ ] Rate limiting verified where abuse-sensitive public endpoints are added or changed
- [ ] Changed error paths don't leak sensitive data

## Secret Management

```typescript
// NEVER: Hardcoded secrets
const apiKey = "sk-proj-xxxxx"

// ALWAYS: Environment variables
const apiKey = process.env.OPENAI_API_KEY

if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

## Security Response Protocol

If security issue found:
1. STOP immediately
2. Use the **security-review** skill if available
3. If the existing request authorizes changes, fix CRITICAL issues before continuing; otherwise report them before resuming other work
4. Rotate exposed secrets within existing authorization; if access or approval is missing, report the required rotation without exposing the values
5. Search the relevant codebase for the same exposure or vulnerability class, and report any fixes outside the authorized scope
