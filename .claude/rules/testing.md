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

## Coverage は規模とリスクで judgment

一律 80% ・全種テスト必須にしない。**コアロジック/壊れると痛い箇所は厚く**、小さなユーティリティに E2E は不要。変更が影響する境界と失敗時の損失に応じて、最小限で意味のある検証を選ぶ:
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows(重要なユーザーフローに絞る)

## Test-Driven Development

新機能・バグ修正の既定ワークフロー。変更が機械的で、既存チェックだけで十分な低リスク作業では judgment で簡略化してよい:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)

## Bug Fix Workflow

バグ修正は、まずユーザーが観測した不具合を最小構成で再現し、再現手順を可能な限り自動テスト(RED)に落とす。複数コンポーネントの連携や画面操作そのものが原因候補である重要フローでは E2E を使う。局所的なロジック不具合では unit / integration の再現で十分と判断してよい。

## Troubleshooting Test Failures

1. Check test isolation
2. Verify mocks are correct
3. Fix implementation, not tests (unless tests are wrong)

変更に関連する必須チェックが通ったら検証を終える。新しい変更、失敗、未解決の懸念がない限り、根拠なくテスト範囲を広げたり同じチェックを繰り返したりしない。

## Skill Support

- `tdd` skill - write-tests-first が有用で、利用可能な場合に使う
- `e2e` / `generate-e2e` skill - E2E が適切で、利用可能な場合に使う(プロジェクト固有のe2e skillがあれば優先)
