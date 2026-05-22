# Recording-time estimates

## Calibration and assumptions

- **Final video length per lecture**: read from each lecture's
  `duration_target_min:` frontmatter field. These targets were
  set at authoring time to fit each lecture's content at KC's
  measured speaking pace.
- **Speaking pace**: ~160 words per minute, measured from the
  CS3100 video transcripts at `_references/_video/01-*` and
  `_references/_video/02-*` (51 min / 8,391 words = 164 wpm;
  53.4 min / 8,274 words = 155 wpm).
- **Recording-time multiplier**: **1.4×** the final video. Built
  in: occasional retakes (you have a 50+ hr CS3100 backlog so
  delivery is well-practised), per-lecture studio setup (mic,
  slides, cell warm-up), and a short reset between lectures.
  Adjust up to 1.6-1.8× if NPTEL wants a stricter retake
  policy; adjust down toward 1.1-1.2× if you do single-take.
- **NPTEL constraint**: each video 20-30 min; ~30 hrs total
  across 12 weeks. Final-recording deadline 30 June 2026.

## Per-lecture table

### M01: Intro to functional programming (5 lectures)

| Lecture | Topic | Video (min) | Recording (min) |
|---|---|---:|---:|
| M01-L01 | Course introduction: what you'll learn, how it's run | 15 | 21 |
| M01-L02 | Why functional programming? | 25 | 35 |
| M01-L03 | A tour of OCaml: values, types, and the toplevel | 25 | 35 |
| M01-L04 | Your first OCaml program: hello, world (and beyond) | 20 | 28 |
| M01-L05 | Tutorial: temperature conversions and small expressions | 25 | 35 |
| **M01 total** | | **110** | **154** |
| | | **(1.8 h)** | **(2.6 h)** |

### M02: Expressions (6 lectures)

Re-estimated 2026-05-22 after the M02 polish pass (Expressions /
Values intro, six primitive literal kinds, derivation tree,
operator-precedence compaction, in_range quiz, static-block
parens example, shipping_label demo fix). Estimate uses
slide_count x 1.5 min, calibrated against M01's per-lecture
ratio (average 1.49).

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M02-L01 | Literals: integers, floats, booleans, strings | 20 | 30 | 42 |
| M02-L02 | `let` bindings and shadowing | 16 | 24 | 34 |
| M02-L03 | Static vs dynamic semantics, and type inference | 15 | 23 | 32 |
| M02-L04 | Operators, precedence, and common pitfalls | 13 | 20 | 28 |
| M02-L05 | `if`/`then`/`else` as an expression | 14 | 21 | 29 |
| M02-L06 | Tutorial: small expressions, end to end | 11 | 17 | 24 |
| **M02 total** | | **89** | **135** | **189** |
| | | | **(2.2 h)** | **(3.1 h)** |

M02-L01 sits at the 30 min NPTEL upper bound (the Expressions /
Values / six-literal-kinds opening grew the lecture). M02-L06 is
just below the 20 min lower bound; that is fine for a tutorial
but worth flagging if NPTEL wants strict 20-30 min videos. The
old M02 estimate was 145 video min / 205 recording min, so the
polish net-shrunk M02 by about 10 video minutes.

### M03: Functions (6 lectures)

Re-estimated 2026-05-22 after the M03 polish pass (closure
formalisation, anonymous-fn split, polymorphism forward pointer,
sum_to demo input 10_000, tail-rec map deferred to M06-L02,
list-length dropped, M03-L05 list-free with mod3 activity,
M03-L06 list-free with fast_power and is_prime).

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M03-L01 | Functions as values, and anonymous functions | 18 | 27 | 38 |
| M03-L02 | Recursion | 15 | 23 | 32 |
| M03-L03 | Currying and partial application | 14 | 21 | 29 |
| M03-L04 | Tail recursion and accumulators | 12 | 18 | 25 |
| M03-L05 | Local functions and mutual recursion | 10 | 15 | 21 |
| M03-L06 | Tutorial: Fibonacci, GCD, power, digits | 11 | 17 | 24 |
| **M03 total** | | **80** | **121** | **169** |
| | | | **(2.0 h)** | **(2.8 h)** |

M03-L05 and M03-L06 drop just below the NPTEL 20 min lower
bound. Both are post-list-removal, so the shrinkage is real
content reduction, not slide-density change. Both have headroom
to grow if NPTEL wants strict 20 min minimums (more worked
examples, more tracing, etc.). The old M03 estimate was 148 video
min / 209 recording min, so the polish net-shrunk M03 by about
27 video minutes, driven by the M03-L04 / L05 / L06 list-removal.

### M04: Data types (6 lectures)

| Lecture | Topic | Video (min) | Recording (min) |
|---|---|---:|---:|
| M04-L01 | Tuples | 22 | 31 |
| M04-L02 | Records | 22 | 31 |
| M04-L03 | Variants (sum types) | 24 | 34 |
| M04-L04 | Recursive types: lists, trees, expressions | 25 | 35 |
| M04-L05 | `option`, `result`, and type abbreviations | 22 | 31 |
| M04-L06 | Tutorial: a tiny JSON-like value type | 28 | 40 |
| **M04 total** | | **143** | **202** |
| | | **(2.4 h)** | **(3.4 h)** |

### M05: Pattern matching (6 lectures)

| Lecture | Topic | Video (min) | Recording (min) |
|---|---|---:|---:|
| M05-L01 | Basic patterns: literals, variables, wildcards | 22 | 31 |
| M05-L02 | Nested patterns and or-patterns | 22 | 31 |
| M05-L03 | Guards: when-clauses on patterns | 20 | 28 |
| M05-L04 | Exhaustiveness checking | 22 | 31 |
| M05-L05 | Matching records, variants, and combined shapes | 22 | 31 |
| M05-L06 | Tutorial: walking an arithmetic expression AST | 28 | 40 |
| **M05 total** | | **136** | **192** |
| | | **(2.3 h)** | **(3.2 h)** |

### M06: Higher-order programming (6 lectures)

| Lecture | Topic | Video (min) | Recording (min) |
|---|---|---:|---:|
| M06-L01 | Functions as values, revisited | 20 | 28 |
| M06-L02 | `map`: transform every element | 22 | 31 |
| M06-L03 | `filter`: keep what passes the predicate | 20 | 28 |
| M06-L04 | `fold`: reduce a list to a single value | 25 | 35 |
| M06-L05 | Function composition and pipelines | 20 | 28 |
| M06-L06 | Tutorial: rebuild parts of `List` | 28 | 40 |
| **M06 total** | | **135** | **190** |
| | | **(2.2 h)** | **(3.2 h)** |

### M07: Side effects and modular programming (7 lectures)

| Lecture | Topic | Video (min) | Recording (min) |
|---|---|---:|---:|
| M07-L01 | Mutable references | 22 | 31 |
| M07-L02 | Mutable records and arrays | 22 | 31 |
| M07-L03 | Exceptions | 22 | 31 |
| M07-L04 | Module basics | 22 | 31 |
| M07-L05 | Module signatures | 22 | 31 |
| M07-L06 | Functors | 24 | 34 |
| M07-L07 | Tutorial: a queue functor | 28 | 40 |
| **M07 total** | | **162** | **229** |
| | | **(2.7 h)** | **(3.8 h)** |

### M08: Monads and GADTs (7 lectures)

| Lecture | Topic | Video (min) | Recording (min) |
|---|---|---:|---:|
| M08-L01 | Sequencing computations: motivation for monads | 22 | 31 |
| M08-L02 | The option monad and `let*` sugar | 24 | 34 |
| M08-L03 | The result monad: errors with information | 22 | 31 |
| M08-L04 | The state monad | 24 | 34 |
| M08-L05 | GADTs: variants with type-level information | 24 | 34 |
| M08-L06 | GADTs: use cases beyond toy interpreters | 22 | 31 |
| M08-L07 | Tutorial: a tiny well-typed evaluator | 28 | 40 |
| **M08 total** | | **166** | **235** |
| | | **(2.8 h)** | **(3.9 h)** |

### M09: Testing (4 lectures)

| Lecture | Topic | Video (min) | Recording (min) |
|---|---|---:|---:|
| M09-L01 | Why test a type-safe program? | 25 | 35 |
| M09-L02 | Unit testing in OCaml with OUnit2 | 25 | 35 |
| M09-L03 | Property-based testing with QCheck | 25 | 35 |
| M09-L04 | Tutorial: testing the expr evaluator with OUnit2 and QCheck | 25 | 35 |
| **M09 total** | | **100** | **140** |
| | | **(1.7 h)** | **(2.3 h)** |

### M10: Memory safety and security (5 lectures)

| Lecture | Topic | Video (min) | Recording (min) |
|---|---|---:|---:|
| M10-L01 | Undefined behaviour and the C memory-safety zoo | 25 | 35 |
| M10-L02 | Memory bugs as security incidents | 25 | 35 |
| M10-L03 | How OCaml rules them out by construction | 25 | 35 |
| M10-L04 | Where OCaml itself has UB | 25 | 35 |
| M10-L05 | Tutorial: walking Heartbleed end to end | 25 | 35 |
| **M10 total** | | **125** | **175** |
| | | **(2.1 h)** | **(2.9 h)** |

### M11: OxCaml: type-level extensions of safety (5 lectures)

| Lecture | Topic | Video (min) | Recording (min) |
|---|---|---:|---:|
| M11-L01 | Modes as the type-level continuation of safety | 25 | 35 |
| M11-L02 | Locality — safe stack allocation | 25 | 35 |
| M11-L03 | Uniqueness — use-after-free at the type level | 25 | 35 |
| M11-L04 | Linearity — use exactly once | 25 | 35 |
| M11-L05 | Tutorial — a resource-management API | 25 | 35 |
| **M11 total** | | **125** | **175** |
| | | **(2.1 h)** | **(2.9 h)** |

### M12: Unikernels (MirageOS) (5 lectures)

| Lecture | Topic | Video (min) | Recording (min) |
|---|---|---:|---:|
| M12-L01 | Why do we need an OS? | 25 | 35 |
| M12-L02 | Ingredient 1: Library OS | 25 | 35 |
| M12-L03 | Ingredient 2: Virtualisation | 25 | 35 |
| M12-L04 | Ingredient 3: OCaml for systems | 25 | 35 |
| M12-L05 | MirageOS = Library OS + Virtualisation + OCaml | 25 | 35 |
| **M12 total** | | **125** | **175** |
| | | **(2.1 h)** | **(2.9 h)** |

## Course totals

- **Final video**: 1583 min (26.4 hours) across
  68 lectures and 12 modules.
- **Estimated recording time**: 2225 min (37.1 hours)
  at the 1.4× multiplier.

The 26.4 hours of final video falls slightly under NPTEL's ~30
hr target; that is expected, since the original sketch reserved
a margin, and the M03 list-removal pass plus the secure-systems
half landed on the lower end of the 25-min-per-lecture window.
Numbers reflect the 2026-05-22 re-estimate for M02 and M03
(slide_count x 1.5); M01 and M04+ still use the authoring-time
duration_target_min.

## Studio session planning

If a studio session is **6 effective hours** of recording
(roughly 4.3 hours of recording time after breaks, lighting
resets and slide-load lulls), the schedule comes out to:

- **37 hours of recording / 4.3 hours per day = ~9 studio days.**

Per-week breakdown if you want to spread across multiple
sessions:

| Module | Recording (h) | Studio days @ 4.3 h |
|---|---:|---:|
| M01 Intro to functional programming | 2.6 | 0.6 |
| M02 Expressions | 3.1 | 0.7 |
| M03 Functions | 2.8 | 0.7 |
| M04 Data types | 3.4 | 0.8 |
| M05 Pattern matching | 3.2 | 0.7 |
| M06 Higher-order programming | 3.2 | 0.7 |
| M07 Side effects and modular programming | 3.8 | 0.9 |
| M08 Monads and GADTs | 3.9 | 0.9 |
| M09 Testing | 2.3 | 0.5 |
| M10 Memory safety and security | 2.9 | 0.7 |
| M11 OxCaml: type-level extensions of safety | 2.9 | 0.7 |
| M12 Unikernels (MirageOS) | 2.9 | 0.7 |
| **Total** | **38.0** | **8.8** |

## Caveats

- M11 and M12 carry higher-risk content (OxCaml mode
  syntax that has shifted across releases; MirageOS demos that
  need pre-recorded build casts). Allow an extra 20-30 min per
  M11/M12 lecture for whiteboard/diagram setup; the 1.4×
  multiplier may be optimistic for those modules specifically.
- M01-L01 is the only lecture under 20 min (15 min). NPTEL
  accepts it as the short opener; if a stricter floor is
  required, fold the next-lecture-preview content into it.
- The Tutorial lectures (every module's L06 / L07 / Ln) all
  target 28 min. They sit at the upper edge of the 30 min
  ceiling; trim deliberately if the live demo runs long.
- The 1.4× multiplier excludes pre-recording prep (rehearsing
  the lecture, loading slides into the studio rig, mic check).
  Add a constant ~30 min per studio session for that overhead.
