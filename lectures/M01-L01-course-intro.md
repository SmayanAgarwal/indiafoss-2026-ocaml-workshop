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

<svg viewBox="0 0 960 220" xmlns="http://www.w3.org/2000/svg" role="img"
     aria-label="12-module course roadmap"
     style="max-width: 100%; height: auto; display: block; margin: 0 auto;">
  <style>
    .nptel-roadmap text { font-family: ui-sans-serif, system-ui, sans-serif; }
    .nptel-roadmap .grp-label { font-size: 13px; fill: #444; font-weight: 600; }
    .nptel-roadmap .week-no   { font-size: 14px; font-weight: 700; }
    .nptel-roadmap .topic     { font-size: 11px; }
    .nptel-roadmap .fp rect   { fill: #e8f0e6; stroke: #3a6c52; }
    .nptel-roadmap .sec rect  { fill: #fbeed2; stroke: #b97a18; }
    .nptel-roadmap .fp text   { fill: #2a4a3c; }
    .nptel-roadmap .sec text  { fill: #6f4711; }
    .nptel-roadmap .bracket   { stroke: #777; fill: none; stroke-width: 1.2; }
  </style>
  <g class="nptel-roadmap">
    <path class="bracket" d="M 30 60 L 30 50 L 622 50 L 622 60" />
    <text class="grp-label" x="326" y="42" text-anchor="middle">8 modules: functional programming in OCaml</text>
    <path class="bracket" d="M 638 60 L 638 50 L 930 50 L 930 60" />
    <text class="grp-label" x="784" y="42" text-anchor="middle">4 modules: secure systems</text>

    <g class="fp">
      <g transform="translate(30,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M1</text><text class="topic" x="35" y="42" text-anchor="middle">Intro</text></g>
      <g transform="translate(106,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M2</text><text class="topic" x="35" y="42" text-anchor="middle">Expressions</text></g>
      <g transform="translate(182,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M3</text><text class="topic" x="35" y="42" text-anchor="middle">Functions</text></g>
      <g transform="translate(258,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M4</text><text class="topic" x="35" y="42" text-anchor="middle">Data types</text></g>
      <g transform="translate(334,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M5</text><text class="topic" x="35" y="42" text-anchor="middle">Pattern match</text></g>
      <g transform="translate(410,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M6</text><text class="topic" x="35" y="42" text-anchor="middle">Higher-order</text></g>
      <g transform="translate(486,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M7</text><text class="topic" x="35" y="40" text-anchor="middle">Side effects,</text><text class="topic" x="35" y="54" text-anchor="middle">modules</text></g>
      <g transform="translate(562,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M8</text><text class="topic" x="35" y="40" text-anchor="middle">Monads,</text><text class="topic" x="35" y="54" text-anchor="middle">GADTs</text></g>
    </g>
    <g class="sec">
      <g transform="translate(638,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M9</text><text class="topic" x="35" y="40" text-anchor="middle">Runtime,</text><text class="topic" x="35" y="54" text-anchor="middle">GC, UB</text></g>
      <g transform="translate(714,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M10</text><text class="topic" x="35" y="40" text-anchor="middle">Memory</text><text class="topic" x="35" y="54" text-anchor="middle">safety, C FFI</text></g>
      <g transform="translate(790,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M11</text><text class="topic" x="35" y="40" text-anchor="middle">Unikernel</text><text class="topic" x="35" y="54" text-anchor="middle">OS</text></g>
      <g transform="translate(866,70)"><rect width="70" height="65" rx="4"/><text class="week-no" x="35" y="22" text-anchor="middle">M12</text><text class="topic" x="35" y="40" text-anchor="middle">Concurrency,</text><text class="topic" x="35" y="54" text-anchor="middle">capabilities</text></g>
    </g>
  </g>
</svg>

By the end:

- You write **idiomatic OCaml**.
- You **reason equationally** about your code.
- You understand how OCaml's design choices buy you safety where
  C and C++ traditionally fail.

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

- Every lecture has **runnable OCaml cells.**
- Click **Run** — output appears inline.
- Edit any cell, Run again.
- Nothing to install.

```ocaml
let greeting who = "hello, " ^ who
let () = print_endline (greeting "NPTEL")
```

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

- Next video: **why functional programming?**
- The case for it, given that you can already write programs.

:::

## Reading

- Cornell **CS3110** textbook chapter 1 (free, online):
  <https://cs3110.github.io/textbook/>
- **Real World OCaml** (free, online): <https://dev.realworldocaml.org/>
- The NPTEL course page (you're already there).
