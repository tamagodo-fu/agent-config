---
paths:
  - "**/*.py"
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/*.sh"
---

# Coding Style

## Simplicity First (CRITICAL)

問題を解く最小のコード。投機的なものはゼロ。
- 求められていない機能・単一用途の抽象・要求外の「柔軟性/設定可能性」を足さない。
- 起こり得ないケースのエラー処理を書かない。現実に起きる失敗(外部I/O・parse・network)だけ握る。
- 既存を触る時は必要な行だけ。隣接の"改善"・無関係なリファクタ・整形をしない。掃除は自分の変更が生んだ未使用だけ。
- 無関係な問題(UI崩れ・lint・test失敗・flaky)に気づいても黙って直さない。自分の diff には含めず、**発見として報告**する(直すかはユーザーが判断)。
- 200行が50行になるなら書き直す。「senior engineer が overcomplicated と言うか?」→ Yes なら簡素化。

## Technical Decisions

技術判断では開発コスト(実装労力)を大きく重み付けしない。品質・堅牢性・スケーラビリティ・長期保守性を優先する。ただし **Simplicity First に従属**: 品質優先を理由に投機的な抽象・要求外の柔軟性を足すのは不可。

## Immutability (CRITICAL)

ALWAYS create new objects/values, NEVER mutate in place:

```javascript
// WRONG: Mutation
function updateUser(user, name) {
  user.name = name  // MUTATION!
  return user
}

// CORRECT: Immutability
function updateUser(user, name) {
  return { ...user, name }
}
```

```python
# WRONG: Mutation
def update_user(user: dict, name: str) -> dict:
    user["name"] = name  # MUTATION!
    return user

# CORRECT: Immutability (dataclass推奨ならdataclasses.replaceも可)
def update_user(user: dict, name: str) -> dict:
    return {**user, "name": name}
```

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large components/modules
- Organize by feature/domain, not by type

## Input Validation

外部/信頼できない入力は検証する。内部・起こり得ない入力には足さない(Simplicity First)。

```typescript
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  age: z.number().int().min(0).max(150)
})

const validated = schema.parse(input)
```

```python
from pydantic import BaseModel, EmailStr, Field

class UserInput(BaseModel):
    email: EmailStr
    age: int = Field(ge=0, le=150)

validated = UserInput.model_validate(input_data)
```

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] 現実に起きる失敗だけ処理(不可能シナリオは書かない)
- [ ] No debug print/console.log statements left in
- [ ] No hardcoded values
- [ ] No mutation (immutable patterns used)
