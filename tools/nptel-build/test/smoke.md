---
title: "Integration test fixture"
lecture_no: 0
week: 0
duration_target_min: 1
concepts: [integration test]
keywords: [test]
activity_question: "Did everything render?"
think_about_this: "Anything missing?"
reading:
  - title: "cmarkit"
    url: https://erratique.ch/software/cmarkit/doc/Cmarkit/index.html
---

# Fixture

Outside-slide prose.

```ocaml init=true
let shared = "hello"
```

:::slide

## Slide 1

```ocaml
print_endline shared
```

:::notes
speaker
:::

:::

:::slide

## Slide 2

:::fragment
- first
:::

```ocaml
let _ = 1 + 1
```

:::
