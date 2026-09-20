---
type: regex
target: {source: file, path: memo.md}
match: contains
weight: 1
---
(?=[\s\S]*北関東)(?=[\s\S]*11\s*月\s*14\s*日)(?=[\s\S]*3,?200\s*万円)(?=[\s\S]*900\s*万円)(?=[\s\S]*6\s*時間)(?=[\s\S]*2\s*時間)
