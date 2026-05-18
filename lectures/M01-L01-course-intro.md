---
title: "Course introduction: what you'll learn, how it's run"
lecture_no: 1
week: 1
duration_target_min: 15
concepts: [course logistics, syllabus overview, in-browser dev environment, grading]
keywords: [OCaml, NPTEL, functional programming, course intro, syllabus, FP]
activity_question: "How is the certification score split between weekly assignments and the final exam?"
think_about_this: "Why do you think the course bothers to teach functional programming at all, when most software you've used is written in imperative languages?"
reading:
  - title: "Functional Programming in OCaml (Cornell CS3110)"
    url: https://cs3110.github.io/textbook/
  - title: "Real World OCaml"
    url: https://dev.realworldocaml.org/
---

# Course introduction

Welcome to **Functional Programming with OCaml**. This first video is short
and almost entirely logistics: what we are going to cover, who the course
is aimed at, how it is graded, and how you will run the code in your
browser without installing anything.

The lectures that follow are where the actual content begins.

:::slide

## Functional Programming with OCaml

A 12-week NPTEL course on functional programming, taught through OCaml,
with a strong second half on secure systems software.

K. C. Sivaramakrishnan, IIT Madras. Most students call me KC.

:::

:::slide

## Who is this course for?

- Undergraduate and postgraduate students in CS and related disciplines.
- Systems engineers, software developers, researchers.
- Anyone who wants to build robust, reliable, type-safe software.

**Prerequisites:** C programming, basic data structures and algorithms.
Nothing more.

:::

:::slide

## What you'll learn

```
┌────────────── 8 weeks: functional programming in OCaml ──────────────┐  ┌── 4 weeks: secure systems ──┐
│ W1  Intro     │ W3  Functions     │ W5  Pattern match │ W7  Side fx, │  │ W9   Runtime, GC, UB         │
│ W2  Express'n │ W4  Data types    │ W6  Higher-order  │     modules  │  │ W10  Memory safety, C FFI    │
│               │                   │                   │ W8  Monads,  │  │ W11  Unikernel OS            │
│               │                   │                   │     GADTs    │  │ W12  Concurrency, capability │
└──────────────────────────────────────────────────────────────────────┘  └──────────────────────────────┘
```

By the end you will write idiomatic OCaml, reason equationally about
your code, and understand how OCaml's design choices buy you safety in
domains where C and C++ traditionally fail.

:::

:::slide

## Why OCaml?

- A **functional-first** language with a serious type system.
- **Practical:** used at Tarides, Jane Street, Bloomberg, Facebook (Hack/Flow),
  Docker, Mozilla, and across academia.
- **Fast:** native code performance close to C, with garbage collection
  and no undefined behaviour in the safe fragment.
- **A great teaching language** for ideas you will see again in Rust,
  Scala, Haskell, Swift, Kotlin, TypeScript.

:::

:::slide

## Run code right in this page

Every lecture has runnable OCaml cells. Click **Run** and the code
evaluates; the result appears below it.

```ocaml
let greeting who = "hello, " ^ who
let () = print_endline (greeting "NPTEL")
```

Edit the cell. Run again. Try things. Nothing to install.

:::

:::notes
Click Run live so the audience sees [hello, NPTEL] appear inline. If
they ask: the OCaml toplevel runs in their browser via [x-ocaml]; no
server, no install, everything stays on their machine.
:::

:::slide

## A taste: primes from a list

```ocaml
let rec sieve = function
  | [] -> []
  | p :: rest ->
      p :: sieve (List.filter (fun n -> n mod p <> 0) rest)

let rec range a b = if a > b then [] else a :: range (a + 1) b

let _ = sieve (range 2 50)
```

Press **Run.** You should see the primes up to 50 come out.

You will write code like this from scratch by Week 6. For now, just
enjoy the output and notice how short the program is.

:::

:::notes
This is the teaching sieve, not the efficient one. It's quadratic in
the number of primes and allocates a fresh list at every step. Worth
mentioning offhand if anyone asks; do not labour it. The point is
"five lines, runnable, OCaml", not algorithmic efficiency.
:::

:::slide

## How the course is graded

- **25%** weekly assignments. One assignment per week, due roughly a
  week after the corresponding videos appear.
- **75%** final certification exam. Two paper sets exist; you sit one.
- You need **40%** overall to receive a certificate.

The proctored final exam is conducted in person by NPTEL; the
assignments are submitted online via the SWAYAM portal.

:::

:::slide

## The structure of each week

Every week of the course follows the same shape:

- **5 to 7 short videos**, 20 to 30 minutes each. One concept per video.
- **A tutorial video** at the end of the week that walks through
  problems of the same flavour as that week's assignment.
- **One assignment** released alongside the videos.
- **A discussion forum** on the NPTEL platform, checked daily.

:::

:::slide

## What is *not* in this course

- We are not building a production system from scratch.
- We are not surveying every language feature OCaml has; we cover the
  ones that matter for clear, type-safe code.
- We are not doing pure type theory; we will use a little, where it
  helps. The course is engineering-flavoured.

If you want either of the first two, the Cornell CS3110 textbook and
*Real World OCaml* are excellent follow-on reading.

:::

:::slide

## What's next

In the next video we ask **why functional programming**: what makes it
worth your time at all, given that you can already write programs in
the languages you know.

:::

## Reading

- Cornell **CS3110** textbook chapter 1 (free, online):
  <https://cs3110.github.io/textbook/>
- **Real World OCaml** (free, online): <https://dev.realworldocaml.org/>
- The NPTEL course page (you're already there).
