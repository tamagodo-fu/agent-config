---
type: regex
target: {source: file, path: mail.md}
match: contains
weight: 1
---
(?=[\s\S]*田村)(?=[\s\S]*10\s*月\s*31\s*日)(?=[\s\S]*180\s*万円)
