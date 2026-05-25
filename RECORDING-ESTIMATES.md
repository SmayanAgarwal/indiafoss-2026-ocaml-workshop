# Recording-time estimates

## Calibration and assumptions

- **Final video length per lecture**: computed as `slide_count
  x 1.5 min`, where slide_count is `grep -c '^:::slide'` of the
  current lecture draft. The 1.5 factor was calibrated against
  M01's per-lecture ratio (average 1.49) and confirmed across
  the M02/M03/M04 polish passes.
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

Re-estimated 2026-05-25 by `grep -c '^:::slide'` of the current
M01 drafts. M01 is not yet polished; the slide counts reflect the
current draft state. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M01-L01 | Course introduction: what you'll learn, how it's run | 13 | 20 | 28 |
| M01-L02 | Why functional programming? | 19 | 29 | 41 |
| M01-L03 | A tour of OCaml: values, types, and the toplevel | 17 | 26 | 36 |
| M01-L04 | Your first OCaml program: hello, world (and beyond) | 14 | 21 | 29 |
| M01-L05 | Tutorial: temperature conversions and small expressions | 13 | 20 | 28 |
| **M01 total** | | **76** | **116** | **162** |
| | | | **(1.9 h)** | **(2.7 h)** |

M01-L01 and M01-L05 sit right at the NPTEL 20-min floor (13
slides each). The other three lectures land cleanly in the
20-30 min band.

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

Re-estimated 2026-05-22 / 23 / 24 / 25 after the M04 polish passes
(M04-L01 constructing-and-extracting split; M04-L02 access-field
and function-parameter slides each split, mutable-record-fields
deferred to M07-L01; M04-L03 stripped of pattern-matching content
per CS3100_m25 lec05 / lec06 split, with type aliases moved up
from the old M04-L05; M04-L04 opening rewritten to follow
CS3100_m25 lec05 progression `intlist` -> `stringlist` -> `'a
lst` -> type variables -> polymorphism -> built-in `'a list`, and
walks / evaluator deferred to M05). The old M04-L05
(option-and-aliases) was tiny once pattern matching was removed,
so its option / result content was folded into M04-L04. The single
JSON tutorial was retired on 2026-05-24 in favour of two more
domain-relevant tutorials: M04-L05 (a tiny AST for OCaml) and
M04-L06 (a tiny file system). The 2026-05-25 pass introduced the
"make illegal states unrepresentable" slogan in M04-L04 (after
option is introduced) and tightened the M04-L05 closing. M04 now
has six lectures. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M04-L01 | Tuples | 17 | 26 | 36 |
| M04-L02 | Records | 17 | 26 | 36 |
| M04-L03 | Variants (sum types) | 9 | 14 | 20 |
| M04-L04 | Recursive types, polymorphism, option / result | 24 | 36 | 50 |
| M04-L05 | Tutorial: a tiny AST for OCaml | 16 | 24 | 34 |
| M04-L06 | Tutorial: a tiny file system | 14 | 21 | 30 |
| **M04 total** | | **97** | **147** | **206** |
| | | | **(2.5 h)** | **(3.4 h)** |

M04-L04 is the longest lecture in the course at 36 video min; it
overruns the NPTEL 30-min upper bound. KC has chosen to keep it
as one lecture rather than split (the content arc from intlist
all the way to result is best taken in one sitting), but if the
recorded delivery overshoots, a natural cut point is "Null: the
billion-dollar mistake" - everything before is recursive /
parameterised variants, everything after is `option` / `result`
design.

M04-L03 is below the NPTEL 20-min lower bound at 9 slides / 14
min and is the thinnest standalone lecture in the polished
modules. See the sweep notes below.

M04-L05 and M04-L06 are construction-only tutorials on two
different domains so the audience sees the same toolkit twice;
walks / evaluators for both ASTs and file systems land in M05.

### M05: Pattern matching (6 lectures)

Re-estimated 2026-05-25 after the M05 restructure. Two structural
changes: a new M05-L02 *Pattern matching on lists and trees* was
inserted to give list and tree patterns their own home, and the
old records-variants lecture was retired by folding its unique
content (record-pattern shorthand `{ field; _ }`, field renaming,
inline records inside constructors, and the diagonal idiom) into
M05-L03. The L06 tutorial was also rewritten from an ad-hoc
arithmetic AST to an interpreter for the
[M04-L05 AST](M04-L05-tutorial.html) (extended with `If` so the
existing `Bool` constructor flows somewhere). Slide counts are
the current draft state. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M05-L01 | Basic patterns: literals, variables, wildcards | 20 | 30 | 42 |
| M05-L02 | Pattern matching on lists and trees | 16 | 24 | 34 |
| M05-L03 | Nested patterns, records, inline records, or-patterns | 21 | 32 | 45 |
| M05-L04 | Guards: when-clauses on patterns | 11 | 17 | 24 |
| M05-L05 | Exhaustiveness checking | 13 | 20 | 28 |
| M05-L06 | Tutorial: an interpreter for the M04-L05 AST | 16 | 24 | 34 |
| **M05 total** | | **97** | **147** | **207** |
| | | | **(2.5 h)** | **(3.5 h)** |

M05-L01 sits right at the NPTEL 30-min ceiling at 30 video min
and is the longest in M05. M05-L04 (10 slides / 15 min) and
M05-L05 (11 slides / 17 min) both sit below the 20-min floor.
M05-L02 lands cleanly in the 20-30 min band at 24 min; the L07
rewrite holds at 21 min. The thin-lecture imbalance shifted
from L01-vs-others to the guards/exhaustiveness pair, which
will likely be addressed in their polish pass.

### M06: Higher-order programming (6 lectures)

Re-estimated 2026-05-25 by `grep -c '^:::slide'` of the current
M06 drafts. M06 is not yet polished; the slide counts reflect the
current draft state. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M06-L01 | Functions as values, revisited | 13 | 20 | 28 |
| M06-L02 | `map`: transform every element | 14 | 21 | 29 |
| M06-L03 | `filter`: keep what passes the predicate | 12 | 18 | 25 |
| M06-L04 | `fold`: reduce a list to a single value | 14 | 21 | 29 |
| M06-L05 | Function composition and pipelines | 13 | 20 | 28 |
| M06-L06 | Tutorial: rebuild parts of `List` | 13 | 20 | 28 |
| **M06 total** | | **79** | **120** | **167** |
| | | | **(2.0 h)** | **(2.8 h)** |

M06-L03 (12 slides / 18 min) sits below the NPTEL 20-min floor.
M06-L01, L05 and L06 (13 slides / 20 min) sit right at the
floor. The whole module currently runs short for higher-order
content; the polish pass will likely grow it.

### M07: Side effects and modular programming (9 lectures)

Re-estimated 2026-05-25 by `grep -c '^:::slide'` of the current
M07 drafts. M07 is not yet polished; the slide counts reflect the
current draft state (including the M07-L04 streams-and-laziness
and M07-L05 memoization lectures added on 2026-05-23). Estimate
uses slide_count x 1.5 min.

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M07-L01 | Mutable references | 15 | 23 | 32 |
| M07-L02 | Mutable records and arrays | 14 | 21 | 29 |
| M07-L03 | Exceptions | 12 | 18 | 25 |
| M07-L04 | Streams and laziness | 13 | 20 | 28 |
| M07-L05 | Memoization | 12 | 18 | 25 |
| M07-L06 | Module basics | 15 | 23 | 32 |
| M07-L07 | Module signatures | 16 | 24 | 34 |
| M07-L08 | Functors | 13 | 20 | 28 |
| M07-L09 | Tutorial: a queue functor | 15 | 23 | 32 |
| **M07 total** | | **125** | **190** | **265** |
| | | | **(3.2 h)** | **(4.4 h)** |

M07-L03 and M07-L05 (12 slides / 18 min) sit below the NPTEL
20-min floor. M07-L04 and M07-L08 (13 slides / 20 min) sit right
at the floor.

### M08: Monads and GADTs (7 lectures)

Re-estimated 2026-05-25 by `grep -c '^:::slide'` of the current
M08 drafts. M08 is not yet polished; the slide counts reflect the
current draft state. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M08-L01 | Sequencing computations: motivation for monads | 10 | 15 | 21 |
| M08-L02 | The option monad and `let*` sugar | 13 | 20 | 28 |
| M08-L03 | The result monad: errors with information | 16 | 24 | 34 |
| M08-L04 | The state monad | 16 | 24 | 34 |
| M08-L05 | GADTs: variants with type-level information | 14 | 21 | 29 |
| M08-L06 | GADTs: use cases beyond toy interpreters | 11 | 17 | 24 |
| M08-L07 | Tutorial: a tiny well-typed evaluator | 13 | 20 | 28 |
| **M08 total** | | **93** | **141** | **198** |
| | | | **(2.4 h)** | **(3.3 h)** |

M08-L01 (10 slides / 15 min) and M08-L06 (11 slides / 17 min)
sit below the NPTEL 20-min floor. M08-L02 and M08-L07 (13 slides
/ 20 min) sit right at the floor.

### M09: Testing (5 lectures)

Re-estimated 2026-05-25 by `grep -c '^:::slide'` of the current
M09 drafts. M09 is not yet polished; the slide counts reflect the
current draft state (and now include M09-L04 model-based testing
as a distinct lecture, with the tutorial at L05). Estimate uses
slide_count x 1.5 min.

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M09-L01 | Why test a type-safe program? | 11 | 17 | 24 |
| M09-L02 | Unit testing in OCaml with OUnit2 | 15 | 23 | 32 |
| M09-L03 | Property-based testing with QCheck | 21 | 32 | 45 |
| M09-L04 | Model-based testing | 16 | 24 | 34 |
| M09-L05 | Tutorial: testing the expr evaluator with OUnit2 and QCheck | 11 | 17 | 24 |
| **M09 total** | | **74** | **113** | **159** |
| | | | **(1.9 h)** | **(2.7 h)** |

M09-L03 (21 slides / 32 min) overruns the NPTEL 30-min ceiling.
M09-L01 and M09-L05 (11 slides / 17 min each) sit below the
20-min floor.

### M10: Memory safety and security (5 lectures)

Re-estimated 2026-05-25 by `grep -c '^:::slide'` of the current
M10 drafts. M10 is not yet polished; the slide counts reflect the
current draft state. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M10-L01 | Undefined behaviour and the C memory-safety zoo | 8 | 12 | 17 |
| M10-L02 | Memory bugs as security incidents | 17 | 26 | 36 |
| M10-L03 | How OCaml rules them out by construction | 13 | 20 | 28 |
| M10-L04 | Where OCaml itself has UB | 15 | 23 | 32 |
| M10-L05 | Tutorial: walking Heartbleed end to end | 11 | 17 | 24 |
| **M10 total** | | **64** | **98** | **137** |
| | | | **(1.6 h)** | **(2.3 h)** |

M10-L01 (8 slides / 12 min) is the thinnest lecture in the
course and well below the NPTEL 20-min floor. M10-L05 (11
slides / 17 min) also sits below the floor. M10-L03 (13 slides
/ 20 min) sits right at the floor.

### M11: OxCaml: type-level extensions of safety (5 lectures)

Re-estimated 2026-05-25 by `grep -c '^:::slide'` of the current
M11 drafts. M11 is not yet polished; the slide counts reflect the
current draft state. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M11-L01 | Modes as the type-level continuation of safety | 10 | 15 | 21 |
| M11-L02 | Locality: safe stack allocation | 13 | 20 | 28 |
| M11-L03 | Uniqueness: use-after-free at the type level | 14 | 21 | 29 |
| M11-L04 | Linearity: use exactly once | 11 | 17 | 24 |
| M11-L05 | Tutorial: a resource-management API | 13 | 20 | 28 |
| **M11 total** | | **61** | **93** | **130** |
| | | | **(1.6 h)** | **(2.2 h)** |

M11-L01 (10 slides / 15 min) and M11-L04 (11 slides / 17 min)
sit below the NPTEL 20-min floor. M11-L02 and M11-L05 (13
slides / 20 min) sit right at the floor.

### M12: Unikernels (MirageOS) (5 lectures)

Re-estimated 2026-05-25 by `grep -c '^:::slide'` of the current
M12 drafts. M12 is not yet polished; the slide counts reflect the
current draft state. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | Video (min) | Recording (min) |
|---|---|---:|---:|---:|
| M12-L01 | Why do we need an OS? | 10 | 15 | 21 |
| M12-L02 | Ingredient 1: Library OS | 10 | 15 | 21 |
| M12-L03 | Ingredient 2: Virtualisation | 10 | 15 | 21 |
| M12-L04 | Ingredient 3: OCaml for systems | 10 | 15 | 21 |
| M12-L05 | MirageOS = Library OS + Virtualisation + OCaml | 12 | 18 | 25 |
| **M12 total** | | **52** | **78** | **109** |
| | | | **(1.3 h)** | **(1.8 h)** |

All four ingredient lectures (M12-L01..L04, 10 slides / 15 min
each) sit well below the NPTEL 20-min floor; M12-L05 (12 slides
/ 18 min) is also below. M12 is the shortest module currently
and will need to grow during the polish pass.

## Sweep: lectures with low slide counts (2026-05-25)

At the calibrated slide_count x 1.5 cadence, anything under ~14
slides runs short of the NPTEL 20-min floor, and anything under
~10 slides is awkwardly thin for a standalone lecture. Counts
below are from a `grep -c '^:::slide'` sweep of all 71 lectures.

**Polished modules (numbers reflect today's lecture state):**

| Lecture | Slides | Video (min) | Status |
|---|---:|---:|---|
| M04-L03 Variants | 9 | 14 | **Too thin.** KC's call. Options: expand with a worked `tcp_state` / `shape` design example; absorb into M04-L04 (pushes L04 to ~46 min, too long); or rebalance L03/L04 by splitting L04 and shuffling. Pending KC decision. |
| M02-L06 Tutorial | 11 | 17 | Borderline; tutorials run light by design. Acceptable. |
| M03-L05 Local and mutual | 11 | 17 | Borderline. Post-list-removal shrinkage; OK to leave per current note. |
| M03-L06 Tutorial | 11 | 17 | Borderline; same reason. |
| M03-L04 Tail recursion | 12 | 18 | Borderline. Post-list-removal shrinkage; OK to leave per current note. |

**Unpolished modules (slide counts reflect the current draft
state; expect movement during each module's polish pass):**

| Lecture | Slides |
|---|---:|
| M10-L01 Undefined behaviour and the C memory-safety zoo | 8 |
| M08-L01 Sequencing computations | 10 |
| M11-L01 Modes as the type-level continuation of safety | 10 |
| M12-L01..L04 (Why OS, Library OS, Virtualisation, OCaml for systems) | 10 each |
| M08-L06 GADTs use cases | 11 |
| M09-L01 Why test a type-safe program? | 11 |
| M09-L05 Tutorial | 11 |
| M10-L05 Tutorial: Heartbleed | 11 |
| M11-L04 Linearity | 11 |
| M06-L03 Filter | 12 |
| M07-L03 Exceptions | 12 |
| M07-L05 Memoization | 12 |
| M12-L05 MirageOS = Library OS + Virtualisation + OCaml | 12 |

After the 2026-05-25 sweep, all per-module tables above use
slide_count x 1.5 from the current drafts; these unpolished rows
will move once each module's polish pass lands. Re-check at
polish time per module.

## Course totals

- **Final video**: 1499 min (25.0 hours) across
  71 lectures and 12 modules.
- **Estimated recording time**: 2098 min (35.0 hours)
  at the 1.4× multiplier.

The 25.0 hours of final video falls under NPTEL's ~30 hr target;
that is expected, since the original sketch reserved a margin,
the M03 list-removal pass plus the secure-systems half landed on
the lower end of the 25-min-per-lecture window, and several
unpolished modules (notably M10, M11, M12) currently run thin
and will grow during their polish passes. Numbers reflect the
2026-05-22 re-estimate for M02, M03, and M04 (slide_count x
1.5), the 2026-05-23 addition of M07-L04 and M07-L05, the
2026-05-24 M04 tutorial swap (JSON tutorial retired; M04-L05 AST
+ M04-L06 file-system tutorials added), the 2026-05-25 M04
polish (slogan introduction in L04; L01 and L02 slide-count
drift up by one each; L04 grew by two slides), the 2026-05-25
M05 slide-count re-estimate (`grep -c '^:::slide'` over the
current drafts, no polish pass yet), the 2026-05-25
slide-count re-estimate of M01, M06, M07, M08, M09, M10, M11,
and M12 (same `grep -c '^:::slide'` sweep, no polish passes
yet), and the 2026-05-25 M05 restructure (new M05-L02
*Pattern matching on lists and trees* inserted; old L02..L06
renumbered to L03..L07; L07 tutorial rewritten as an
interpreter for the M04-L05 AST). All per-module tables now
use slide_count x 1.5 from the current drafts; no module
relies on the authoring-time `duration_target_min` any more.

## Studio session planning

If a studio session is **6 effective hours** of recording
(roughly 4.3 hours of recording time after breaks, lighting
resets and slide-load lulls), the schedule comes out to:

- **35.0 hours of recording / 4.3 hours per day = ~8.1 studio days.**

Per-week breakdown if you want to spread across multiple
sessions:

| Module | Recording (h) | Studio days @ 4.3 h |
|---|---:|---:|
| M01 Intro to functional programming | 2.7 | 0.6 |
| M02 Expressions | 3.1 | 0.7 |
| M03 Functions | 2.8 | 0.7 |
| M04 Data types | 3.4 | 0.8 |
| M05 Pattern matching | 3.5 | 0.8 |
| M06 Higher-order programming | 2.8 | 0.7 |
| M07 Side effects and modular programming | 4.4 | 1.0 |
| M08 Monads and GADTs | 3.3 | 0.8 |
| M09 Testing | 2.7 | 0.6 |
| M10 Memory safety and security | 2.3 | 0.5 |
| M11 OxCaml: type-level extensions of safety | 2.2 | 0.5 |
| M12 Unikernels (MirageOS) | 1.8 | 0.4 |
| **Total** | **35.1** | **8.2** |

## Caveats

- M11 and M12 carry higher-risk content (OxCaml mode
  syntax that has shifted across releases; MirageOS demos that
  need pre-recorded build casts). Allow an extra 20-30 min per
  M11/M12 lecture for whiteboard/diagram setup; the 1.4×
  multiplier may be optimistic for those modules specifically.
- Several lectures currently sit under the NPTEL 20-min floor;
  see the sweep section above for the full list. The unpolished
  modules (M06-M12) account for most of them, and the per-module
  polish passes are expected to grow them.
- Tutorial lectures (every module's L06 / L07 / Ln) historically
  targeted 28 min; the current re-estimated counts have them
  closer to the floor than the ceiling, so the polish passes may
  push some back up toward 30 min. Trim deliberately if the live
  demo runs long.
- The 1.4× multiplier excludes pre-recording prep (rehearsing
  the lecture, loading slides into the studio rig, mic check).
  Add a constant ~30 min per studio session for that overhead.
