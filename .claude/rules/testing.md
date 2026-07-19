---
paths:
  - "**/*.py"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.sh"
---

# Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows

## Test-Driven Development

MANDATORY workflow:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Bug Fix Workflow

バグ修正は、**エンドユーザーの体験に可能な限り近い E2E 設定でバグを再現することから始める**。再現できて初めて真因に当たっていることが保証される。再現手順は再現テスト(RED)に落とし、TDD フローに接続する。

## Troubleshooting Test Failures

1. Check test isolation
2. Verify mocks are correct
3. Fix implementation, not tests (unless tests are wrong)

## Skill Support

- `tdd` skill - write-tests-first、新機能・バグ修正で使う
- `e2e` / `generate-e2e` skill - E2Eテスト生成・実行(プロジェクト固有のe2e skillがあれば優先)
