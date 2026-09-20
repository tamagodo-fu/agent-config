---
type: regex
target: {source: file, path: report.md}
match: contains
weight: 1
---
(?=[\s\S]*リトライ)(?=[\s\S]*7\s*月\s*9\s*日)(?=[\s\S]*0\.8\s*[%％])(?=[\s\S]*8\s*月\s*6\s*日)
