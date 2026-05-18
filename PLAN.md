# NPTEL course plan: 3100 → NPTEL lecture mapping

Working document, iterate as needed. **NPTEL lecture** = one ~25 min on-camera
video = one webpage under `lectures/weekNN-<topic>/LNN-<slug>.md`. **3100
lecture** = source video on the [CS3100 playlist](https://www.youtube.com/playlist?list=PLt0HgEXFOHdkE-NTs87s7QjwYwqeihb-D),
transcripts under `_references/_video/`.

NPTEL constraints (binding):
- Each video 20-30 min (hard cap 30)
- ~2.5-3 hrs of video per week
- Week = 5-7 videos + ~30-min tutorial that walks through assignment-style problems
- Activity-question and reading list per video
- License CC-BY-NC-SA -- redraw any reused imagery

3100 lectures 01-33 are the OCaml material; 34+ are Prolog and not used here.

---

## Week 1 — Intro to Functional Programming

| #  | NPTEL lecture                                  | 3100 source                  | x-ocaml cells |
| -- | ---------------------------------------------- | ---------------------------- | ------------- |
| L1 | Course introduction & what to expect           | (new, framing)               | none          |
| L2 | Why programming languages? Why FP?             | 3100 Lec 01 (Why PL?)        | 1-2 demos     |
| L3 | A tour of OCaml: values, expressions, the toplevel | 3100 Lec 02 (front half)     | many          |
| L4 | Hello, world: writing your first program       | (new + 3100 Lec 03 ideas)    | many          |
| L5 | Activity-question recap + tutorial             | (curated examples)           | many          |

Note: 3100 Lec 03 is *Setting up the notebooks*. NPTEL uses the in-browser
x-ocaml runtime so there is no install step; we keep the spirit (running
small programs) and replace the setup mechanics.

---

## Week 2 — Expressions

3100 Lec 02 covers expressions + functions; it's split across two NPTEL weeks.

| #  | NPTEL lecture                                  | 3100 source                  | x-ocaml cells |
| -- | ---------------------------------------------- | ---------------------------- | ------------- |
| L1 | Literals: integers, floats, booleans, strings  | Lec 02 §1                    | many          |
| L2 | `let` bindings and shadowing                   | Lec 02 §2                    | many          |
| L3 | Static vs dynamic semantics; type inference    | Lec 02 §3                    | many          |
| L4 | Operators, precedence, common pitfalls         | Lec 02 §4                    | many          |
| L5 | `if`/`then`/`else` as an expression            | Lec 02 §5                    | many          |
| L6 | Tutorial: small expression exercises           | (new examples)               | many          |

---

## Week 3 — Functions

3100 Lec 02 tail + Lec 04 + Lec 05.

| #  | NPTEL lecture                                  | 3100 source                  | x-ocaml cells |
| -- | ---------------------------------------------- | ---------------------------- | ------------- |
| L1 | Functions as values; anonymous functions       | Lec 04 §1                    | many          |
| L2 | Recursion                                       | Lec 04 §2-3                  | many          |
| L3 | Currying and partial application               | Lec 05 §1                    | many          |
| L4 | Tail recursion and accumulators                | Lec 05 §2                    | many          |
| L5 | Local functions and mutual recursion           | Lec 05 §3                    | many          |
| L6 | Tutorial: fib, gcd, list helpers               | (new)                        | many          |

---

## Week 4 — Data types

3100 Lec 06 + 07.

| #  | NPTEL lecture                                  | 3100 source                  | x-ocaml cells |
| -- | ---------------------------------------------- | ---------------------------- | ------------- |
| L1 | Tuples                                         | Lec 06 §1                    | many          |
| L2 | Records                                        | Lec 06 §2                    | many          |
| L3 | Variants (sum types)                           | Lec 06 §3                    | many          |
| L4 | Recursive types: lists, trees                  | Lec 06 §4 + Lec 07 §1        | many          |
| L5 | Type abbreviations and `option`                | Lec 07 §2                    | many          |
| L6 | Tutorial: model a simple shape ADT             | (new)                        | many          |

---

## Week 5 — Pattern matching

3100 Lec 07 tail + 08.

| #  | NPTEL lecture                                  | 3100 source                  | x-ocaml cells |
| -- | ---------------------------------------------- | ---------------------------- | ------------- |
| L1 | Basic patterns; the wildcard                   | Lec 08 §1                    | many          |
| L2 | Nested patterns; or-patterns                   | Lec 08 §2                    | many          |
| L3 | Guards (`when`-clauses)                        | Lec 08 §3                    | many          |
| L4 | Exhaustiveness checking                        | Lec 08 §4                    | many          |
| L5 | Matching records and variants                  | Lec 07 §3-4                  | many          |
| L6 | Tutorial: walk an AST                          | (new)                        | many          |

---

## Week 6 — Higher-order programming

3100 Lec 10 tail + 11.

| #  | NPTEL lecture                                  | 3100 source                  | x-ocaml cells |
| -- | ---------------------------------------------- | ---------------------------- | ------------- |
| L1 | Functions as values, revisited                 | Lec 10 §3                    | many          |
| L2 | `map`                                          | Lec 11 §1                    | many          |
| L3 | `filter`                                       | Lec 11 §2                    | many          |
| L4 | `fold`                                         | Lec 11 §3                    | many          |
| L5 | Function composition; pipelines                | Lec 11 §4                    | many          |
| L6 | Tutorial: rebuild parts of `List`              | (new)                        | many          |

---

## Week 7 — Side-effects, Modules

3100 Lec 09 (Exceptions) + Lec 20-23 (side effects & modules).

| #  | NPTEL lecture                                  | 3100 source                  | x-ocaml cells |
| -- | ---------------------------------------------- | ---------------------------- | ------------- |
| L1 | Mutable references                             | Lec 20 §1                    | many          |
| L2 | Mutable records and arrays                     | Lec 20 §2                    | many          |
| L3 | Exceptions                                     | Lec 09                       | many          |
| L4 | Module basics; opening modules                 | Lec 22 §1                    | many          |
| L5 | Module signatures and abstraction              | Lec 22 §2 + Lec 23 §1        | many          |
| L6 | Functors                                       | Lec 23 §2                    | many          |
| L7 | Tutorial: a queue functor                      | (new)                        | many          |

---

## Week 8 — Monads, GADTs

3100 Lec 27-33. 3100 Lec 24-26 (streams) is not in the NPTEL syllabus; treat
it as optional supplementary material if a week feels light.

| #  | NPTEL lecture                                  | 3100 source                  | x-ocaml cells |
| -- | ---------------------------------------------- | ---------------------------- | ------------- |
| L1 | Sequencing computations: motivation            | Lec 27 §1                    | many          |
| L2 | The option monad; `let*` and bind              | Lec 27 §2 + Lec 29 §1        | many          |
| L3 | Result monad; error propagation                | Lec 29 §2                    | many          |
| L4 | A state monad                                  | (new + Lec 29 ideas)         | many          |
| L5 | GADTs: motivation and basics                   | Lec 31 + Lec 32              | many          |
| L6 | GADTs: type-safe interpreters / printf         | Lec 33                       | many          |
| L7 | Tutorial: a tiny well-typed expression evaluator | (new)                       | many          |

Note: lambda calculus material (3100 Lec 11-19) is theoretical foundation,
not in the NPTEL syllabus. We mention lambda abstraction in passing in Week
3 / Week 6 but do not dedicate weeks to it. Free reference for motivated
students.

---

## Week 9 — Secure programming: Runtime, GC, UB, Buffer overflow

**No 3100 source.** New material drawing on the instructor's Multicore-OCaml
expertise.

| #  | NPTEL lecture                                  | x-ocaml cells | Notes |
| -- | ---------------------------------------------- | ------------- | ----- |
| L1 | The OCaml runtime: bytecode vs native; closures | a few         | mostly diagrams |
| L2 | The garbage collector: minor + major heap      | a few         | `Gc` module demo |
| L3 | Undefined behaviour in C: a tour               | screencap     | external C demos |
| L4 | Buffer overflow and memory unsafety            | screencap     | external C demos |
| L5 | How OCaml prevents the above by construction   | many          |
| L6 | Tutorial: profiling allocations with `Gc`      | many          |

---

## Week 10 — Memory Safety, Interfacing with C

**No 3100 source.** New material.

| #  | NPTEL lecture                                  | x-ocaml cells | Notes |
| -- | ---------------------------------------------- | ------------- | ----- |
| L1 | What memory safety means in OCaml              | a few         |
| L2 | Bigarray and unboxed data                      | many          |
| L3 | The C FFI: external declarations               | screencap     | needs native demo |
| L4 | Marshalling vs safe interop                    | a few         |
| L5 | Case study: wrapping a C library safely        | screencap     |
| L6 | Tutorial: a small FFI binding                  | screencap     |

---

## Week 11 — Unikernel OS

**No 3100 source.** New material; in-browser execution is not realistic for
unikernels, so this week leans on screencast demos of MirageOS.

| #  | NPTEL lecture                                  | Notes |
| -- | ---------------------------------------------- | ----- |
| L1 | What is a unikernel?                           | concepts |
| L2 | MirageOS: a tour                                | recorded demo |
| L3 | Hello-world unikernel                          | recorded demo |
| L4 | Composing libraries; functorial OS interface   | concepts + demo |
| L5 | Deployment models; security stories            | concepts |
| L6 | Tutorial: configuring a small unikernel        | recorded demo |

---

## Week 12 — Concurrency, capabilities, DRF

**No 3100 source.** OxCaml capsules + Eio. Likely needs cherry-picking from
the user's OxCaml branch and `kc-toplevel-extend` js_of_ocaml fork to ship
the libraries into the in-browser toplevel (see the *Shrinking the OxCaml
bundle* blog post).

| #  | NPTEL lecture                                  | x-ocaml cells | Notes |
| -- | ---------------------------------------------- | ------------- | ----- |
| L1 | Concurrency in OCaml: a tour                   | many          | Eio basics |
| L2 | Effect handlers                                | many          | needs effects worker |
| L3 | Domains and parallelism                        | a few         | browser worker is single-domain; screencast for parallelism |
| L4 | Capability-based security                      | many          | OxCaml capsules |
| L5 | Data-race freedom guarantees                   | many          | OxCaml modes |
| L6 | Tutorial: a DRF-by-construction mutex          | many          |

---

## Numbers

- Total NPTEL lectures: **77** (counting all 12 weeks at 6-7 each)
- Roughly **30 hrs** of finished video, within NPTEL's spec
- 3100 source covers Weeks 1-8 well; Weeks 9-12 are new content

## Open questions

- Should Week 8 include the `streams` material (3100 Lec 24-26) at all,
  or drop it cleanly?
- Should we keep a single Lambda-Calculus aside in Week 6 (one NPTEL
  lecture giving the connection), or drop it?
- Weeks 10-12: how much native-demo screencast vs in-browser?
- Activity questions + readings for every NPTEL lecture: deferrable to
  per-lecture authoring time, but should be on the radar.
