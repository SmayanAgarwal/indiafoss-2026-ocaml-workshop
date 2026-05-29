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

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M01-L01 | Course introduction: what you'll learn, how it's run | 13 | 3 | 0 | 20 | 28 |
| M01-L02 | Why functional programming? | 19 | 2 | 0 | 29 | 41 |
| M01-L03 | A tour of OCaml: values, types, and the toplevel | 17 | 2 | 1 | 26 | 36 |
| M01-L04 | Your first OCaml program: hello, world (and beyond) | 14 | 2 | 1 | 21 | 29 |
| M01-L05 | Tutorial: temperature conversions and small expressions | 13 | 1 | 1 | 20 | 28 |
| **M01 total** | | **76** | **10** | **3** | **116** | **162** |
| | | | | | **(1.9 h)** | **(2.7 h)** |

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

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M02-L01 | Literals: integers, floats, booleans, strings | 20 | 2 | 0 | 30 | 42 |
| M02-L02 | `let` bindings and shadowing | 16 | 1 | 1 | 24 | 34 |
| M02-L03 | Static vs dynamic semantics, and type inference | 15 | 3 | 0 | 23 | 32 |
| M02-L04 | Operators, precedence, and common pitfalls | 13 | 1 | 1 | 20 | 28 |
| M02-L05 | `if`/`then`/`else` as an expression | 14 | 2 | 1 | 21 | 29 |
| M02-L06 | Tutorial: small expressions, end to end | 11 | 0 | 2 | 17 | 24 |
| **M02 total** | | **89** | **9** | **5** | **135** | **189** |
| | | | | | **(2.2 h)** | **(3.1 h)** |

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

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M03-L01 | Functions as values, and anonymous functions | 18 | 2 | 1 | 27 | 38 |
| M03-L02 | Recursion | 15 | 1 | 1 | 23 | 32 |
| M03-L03 | Currying and partial application | 14 | 2 | 1 | 21 | 29 |
| M03-L04 | Tail recursion and accumulators | 12 | 1 | 1 | 18 | 25 |
| M03-L05 | Local functions and mutual recursion | 10 | 2 | 1 | 15 | 21 |
| M03-L06 | Tutorial: Fibonacci, GCD, power, digits | 11 | 2 | 1 | 17 | 24 |
| **M03 total** | | **80** | **10** | **6** | **121** | **169** |
| | | | | | **(2.0 h)** | **(2.8 h)** |

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

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M04-L01 | Tuples | 17 | 2 | 1 | 26 | 36 |
| M04-L02 | Records | 17 | 1 | 1 | 26 | 36 |
| M04-L03 | Variants (sum types) | 9 | 1 | 1 | 14 | 20 |
| M04-L04 | Recursive types, polymorphism, option / result | 24 | 2 | 1 | 36 | 50 |
| M04-L05 | Tutorial: a tiny AST for OCaml | 16 | 3 | 0 | 24 | 34 |
| M04-L06 | Tutorial: a tiny file system | 14 | 3 | 0 | 21 | 30 |
| **M04 total** | | **97** | **12** | **4** | **147** | **206** |
| | | | | | **(2.5 h)** | **(3.4 h)** |

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

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M05-L01 | Basic patterns: literals, variables, wildcards | 20 | 2 | 1 | 30 | 42 |
| M05-L02 | Pattern matching on lists and trees | 16 | 2 | 1 | 24 | 34 |
| M05-L03 | Nested patterns, records, inline records, or-patterns | 22 | 2 | 1 | 33 | 46 |
| M05-L04 | Guards: when-clauses on patterns | 12 | 2 | 1 | 18 | 25 |
| M05-L05 | Exhaustiveness checking | 13 | 2 | 1 | 20 | 28 |
| M05-L06 | Tutorial: an interpreter for the M04-L05 AST | 20 | 2 | 1 | 30 | 42 |
| **M05 total** | | **103** | **12** | **6** | **155** | **217** |
| | | | | | **(2.6 h)** | **(3.6 h)** |

M05-L01 sits right at the NPTEL 30-min ceiling at 30 video min
and is the longest in M05. M05-L04 (12 slides / 18 min) and
M05-L05 (13 slides / 20 min) both sit at or below the 20-min floor.
M05-L02 lands cleanly in the 20-30 min band at 24 min; the L07
rewrite holds at 21 min. The thin-lecture imbalance shifted
from L01-vs-others to the guards/exhaustiveness pair, which
will likely be addressed in their polish pass.

### M06: Higher-order programming (6 lectures + 1 practice)

Re-estimated 2026-05-26 after the M06 polish pass that addressed
KC's author comments and the audit's must-fix items: M06-L01
function-composition slide + activity replaced with `flip` (fresh
combinator); M06-L02 `rev` is not magic slide; M06-L03 `mem` is
not magic + sort/sweep alternative for `unique`; M06-L04 split
the sum/all_true slide, added `fold_right` definition +
step-by-step + cons-cell slides, added side-by-side tree
visualisations for `fold_right` and `fold_left` lifted from
CS3100. Inline-result-comment sweep applied across M06 lectures.
2026-05-29: added M06-L07 Practice. Part 1 (Problems 1 to 9)
adapted from CS3100 Assignment 1; Part 2 (Problems 10 to 15) is
original higher-order practice (partition, flat_map, compose_all,
run_length_encode, running_sum, sum_sq_evens) following on from
the M06 pipelines lecture and fold tutorial; Part 3 (Problems 16
to 17) is original AST-optimisation practice (constant_fold,
simplify) over the arithmetic AST from the M04/M05 tutorials.
Practice chapters carry no slides and are not recorded; they are
in-browser worksheets only and do not count toward recording time.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M06-L01 | Functions as values, revisited | 14 | 2 | 1 | 21 | 29 |
| M06-L02 | `map`: transform every element | 15 | 2 | 1 | 23 | 32 |
| M06-L03 | `filter`: keep what passes the predicate | 14 | 2 | 1 | 21 | 29 |
| M06-L04 | `fold`: reduce a list to a single value | 22 | 2 | 1 | 33 | 46 |
| M06-L05 | Function composition and pipelines | 13 | 2 | 1 | 20 | 28 |
| M06-L06 | Tutorial: fold across data structures | 18 | 2 | 1 | 27 | 38 |
| **M06 total** | | **96** | **12** | **6** | **145** | **202** |
| | | | | | **(2.3 h)** | **(3.2 h)** |
| M06-L07 | Practice: recursion, higher-order functions, and syntax trees (not recorded) | 0 | 0 | 17 | 0 | 0 |

M06-L04 overruns the NPTEL 30-min ceiling at 22 slides / 33 min
after the 2026-05-26 sweep (added the map_via_fold split, the
subtlety slide, and the tree-visualisation slides). Natural cut
if delivery runs long: between the fold_left and fold_right
halves. M06-L05 and L06 sit at the 20-min floor and will likely
grow during their own polish passes. M06-L07 is a Practice
chapter: a slide-free, video-free in-browser worksheet of nine
problems with collapsible reference solutions, so it adds nothing
to the recording total.

### M07: Side effects and modular programming (9 lectures + 1 practice)

Re-estimated 2026-05-28. M07-L01 picked up two aliasing/equality
slides and two ticket-dispenser slides during KC review. M07-L02
picked up a `while`-loop example slide and split the
`Array.iter`/`Array.map` slide into two. Previously, on
2026-05-27, the L01/L02 audit against CS3100 lec12 had added the
CS3100 heap diagram, kept the value-restriction trio, and moved
the "ref is a record with one mutable field" reveal (chapter
section + 2 slides) out into M07-L02 where mutable record fields
are properly introduced. M07-L02 picked that up, plus the
doubly-linked list worked example and a default-to-immutable
closing slide. Earlier re-estimate on 2026-05-25 included the
M07-L04 streams and M07-L05 memoization lectures added on
2026-05-23. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M07-L01 | Mutable references | 22 | 3 | 1 | 33 | 46 |
| M07-L02 | Mutable records and arrays | 22 | 2 | 1 | 33 | 46 |
| M07-L03 | Exceptions | 18 | 2 | 1 | 27 | 38 |
| M07-L04 | Streams and laziness | 19 | 2 | 1 | 29 | 40 |
| M07-L05 | Memoization | 18 | 2 | 1 | 27 | 38 |
| M07-L06 | Module basics | 15 | 2 | 1 | 23 | 32 |
| M07-L07 | Module signatures | 16 | 2 | 1 | 24 | 34 |
| M07-L08 | Functors | 13 | 2 | 1 | 20 | 28 |
| M07-L09 | Tutorial: a queue functor | 15 | 2 | 1 | 23 | 32 |
| **M07 total** | | **158** | **19** | **9** | **240** | **334** |
| | | | | | **(3.9 h)** | **(5.5 h)** |
| M07-L10 | Practice: mutability, modules, and streams (not recorded) | 0 | 0 | 8 | 0 | 0 |

M07-L01 and M07-L02 (22 slides / 33 min each) now sit just above
the NPTEL 30-min ceiling. Natural cuts if delivery runs long:
L01's ticket-dispenser broken/hoisted pair (one slide could
carry both in less detail), or the eta-expansion slide (most
skippable of the value-restriction trio); L02's `while`-loop
slide (only added to make the syntax box honest) or the
default-to-immutable closing slide. M07-L03 was restructured on
2026-05-28 to introduce `raise` and `try ... with` *before* the
built-in-exceptions tour (the old order showed `try` in an
example before explaining it); slide count went 12 -> 16. Same
day's polish pass merged the standalone wrappers section back
into Raising and de-duped the When-not-to-use slide (no slide
delta), then added a nested-`try ... with` example and slide
to bring the count to 17, then added an `assert` /
`Assert_failure` slide and rewrote the exception/option/result
comparison around a runnable `List.assoc` lookup example to bring
the count to 18.
M07-L08 (13 slides / 20 min) sits right at the floor; M07-L04
grew to 19 slides on 2026-05-29 (from 13): the combined
map/filter/zip slide was split into three (one function per
slide); the `Lazy.t` slide was broken into thunk-reruns /
`lazy`-delays / `Lazy.force`-caches, each motivated separately
with a print-based example; the Fibonacci section was split
into a thunk-stream version (correct but exponential) followed
by the lazy-stream fix (linear), mirroring CS3100 lec14; and a
`time_it` timing slide was added that races thunk `fibs` against
lazy `lfibs` (the two race cells are `ocaml skip` so they run
on a Run click, not on page load or in `dune runtest`).
M07-L05 grew to 15 slides on 2026-05-29 (from 12): `time_it`
switched to `Unix.gettimeofday` reporting ms; the slow-function
demo uses `fib 37` (a clearly slow ~100 ms jsoo run) instead of a
busy-loop; the slow-function and first-attempt-fails slides were
each split in two (setup vs demo / attempt vs why); and a
"where plain `memo` pays off" slide was added showing
`List.map (memo slow_id)` over a duplicate-heavy query list
(browser-verified ~880 ms unmemoized vs ~220 ms memoized, a true
8-slow vs 2-slow contrast since the inline `memo slow_id` gets a
fresh cache). M07-L10 (added 2026-05-29) is a Practice chapter:
a slide-free, video-free in-browser worksheet of eight problems
across the three module threads (mutability, modules/functors,
streams), with collapsible reference solutions, so it adds
nothing to the recording total. Part 2 (modules/functors:
`Showable`, the `MakeNode` doubly-linked-list-node functor, a
functional heap) is drawn from CS3100's mutability-and-modules
and monads assignments; Parts 1 and 3 are original.

### M08: Monads and GADTs (10 lectures)

Re-estimated 2026-05-25 by `grep -c '^:::slide'` of the current
M08 drafts. M08 grew from 7 to 10 lectures (added L03 monad laws +
list monad, L06 parameterised state, L09 hlists + witnesses; the
renumbered existing files are L04, L05, L07, L08, L10). Estimate
uses slide_count x 1.5 min.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M08-L01 | Sequencing computations: motivation for monads | 13 | 2 | 1 | 20 | 28 |
| M08-L02 | The option monad and `let*` sugar | 13 | 2 | 1 | 20 | 28 |
| M08-L03 | Monad laws and the list monad | 19 | 2 | 1 | 29 | 40 |
| M08-L04 | The result monad: errors with information | 16 | 2 | 1 | 24 | 34 |
| M08-L05 | The state monad | 16 | 2 | 1 | 24 | 34 |
| M08-L06 | Parameterised state and a typed stack machine | 14 | 2 | 1 | 21 | 29 |
| M08-L07 | GADTs: variants with type-level information | 14 | 2 | 1 | 21 | 29 |
| M08-L08 | GADTs: use cases beyond toy interpreters | 11 | 2 | 1 | 17 | 24 |
| M08-L09 | GADTs: hlists and witnesses | 15 | 2 | 1 | 23 | 32 |
| M08-L10 | Tutorial: a tiny well-typed evaluator | 16 | 2 | 1 | 24 | 34 |
| **M08 total** | | **147** | **20** | **10** | **221** | **309** |
| | | | | | **(3.7 h)** | **(5.2 h)** |

M08-L08 (11 slides / 17 min) sits below the NPTEL 20-min floor;
M08-L03 (19 slides / 29 min) is the heaviest lecture and rides
the 30-min ceiling. Other lectures land comfortably between the
floor and ceiling.

### M09: Concurrency and Testing (8 lectures)

Re-estimated 2026-05-25 after the M09 restructure: the module
was renamed from "Testing" to "Concurrency and Testing"; the
existing L03 was split into L03 (QCheck basics + shrinking)
and a new L04 (custom generators + stateful PBT); model-based
testing moved from L04 to L05; two new concurrency lectures
(L06 effect handlers, L07 fibers and lightweight concurrency)
were inserted; the tutorial moved from L05 to L08 and was
extended with effect-handler stubs. Estimate uses
slide_count x 1.5 min.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M09-L01 | Why test a type-safe (and concurrent) program? | 13 | 3 | 0 | 20 | 28 |
| M09-L02 | Unit testing in OCaml with OUnit2 | 15 | 2 | 1 | 23 | 32 |
| M09-L03 | Property-based testing with QCheck: basics and shrinking | 17 | 2 | 1 | 26 | 36 |
| M09-L04 | Custom generators and stateful property tests | 13 | 2 | 1 | 20 | 28 |
| M09-L05 | Model-based testing | 16 | 2 | 1 | 24 | 34 |
| M09-L06 | Effect handlers for concurrency | 15 | 2 | 1 | 23 | 32 |
| M09-L07 | Fibers and lightweight concurrency | 13 | 2 | 1 | 20 | 28 |
| M09-L08 | Tutorial: testing the expr evaluator with OUnit2, QCheck, and effect-handler stubs | 14 | 1 | 1 | 21 | 30 |
| **M09 total** | | **116** | **16** | **7** | **174** | **244** |
| | | | | | **(2.9 h)** | **(4.1 h)** |

All M09 lectures now land in the 20-36 min band. L03 still
overruns the NPTEL 30-min ceiling slightly (26 min was 32 min
pre-split, so the split helped but L03 is still on the heavy
side). L04 and L07 sit at the 20-min floor; both are
introductions that hand off to the following lecture so the
weight is appropriate.

### M10: Memory safety and security (6 lectures)

Re-estimated 2026-05-25 after the M10 expansion: L01 grew from 8
to 13 slides (Rust comparison, expanded zoo, worked UAF
example); L03 grew from 13 to 15 slides (GC vs borrow checker,
moving-GC tagging); a new L05 "Resource safety: file
descriptors, sockets, and buffers" was inserted; the old L05
tutorial was renumbered L06 and grew from 11 to 14 slides
(leaks-vs-corruption, FFI + Ctypes, modes forward pointer).
Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M10-L01 | Undefined behaviour and the C memory-safety zoo | 13 | 2 | 0 | 20 | 28 |
| M10-L02 | Memory bugs as security incidents | 17 | 2 | 0 | 26 | 36 |
| M10-L03 | How OCaml rules them out by construction | 15 | 2 | 1 | 23 | 32 |
| M10-L04 | Where OCaml itself has UB | 15 | 2 | 0 | 23 | 32 |
| M10-L05 | Resource safety: file descriptors, sockets, and buffers | 15 | 2 | 1 | 23 | 32 |
| M10-L06 | Tutorial: walking Heartbleed end to end | 14 | 2 | 1 | 21 | 30 |
| **M10 total** | | **89** | **12** | **3** | **134** | **187** |
| | | | | | **(2.2 h)** | **(3.1 h)** |

All M10 lectures now land in the 20-30 min NPTEL band; the
expansion added 36 video min and 1 lecture (no thin
sub-20-min outliers remain).

### M11: OxCaml: type-level extensions of safety (7 lectures)

Re-estimated 2026-05-25 after the M11 expansion: L01 grew from
10 to 14 slides (all five mode axes introduced upfront with
forward pointers); a new L03 *Portability: data-race freedom
across domains* was inserted (15 slides); L03 uniqueness was
renumbered L04 and grew from 14 to 16 slides (file-descriptor
protocol slide and unique `File_descr` worked example); L04
linearity was renumbered L05 and grew from 11 to 13 slides
(send-once channel, no-aliasing-vs-no-dropping contrast); a new
L06 *Contention: synchronisation at compile time* was inserted
(17 slides); the old L05 tutorial was renumbered L07 and grew
from 13 to 15 slides (portability+contention integration into
the API; closing-thoughts slide forward-pointing to M12).
Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M11-L01 | Modes as the type-level continuation of safety | 14 | 2 | 0 | 21 | 29 |
| M11-L02 | Locality: safe stack allocation | 13 | 2 | 0 | 20 | 28 |
| M11-L03 | Portability: data-race freedom across domains | 15 | 2 | 0 | 23 | 32 |
| M11-L04 | Uniqueness: use-after-free at the type level | 16 | 2 | 0 | 24 | 34 |
| M11-L05 | Linearity: use exactly once | 13 | 2 | 0 | 20 | 28 |
| M11-L06 | Contention: synchronisation at compile time | 17 | 2 | 0 | 26 | 36 |
| M11-L07 | Tutorial: a resource-management API | 15 | 2 | 1 | 23 | 32 |
| **M11 total** | | **103** | **14** | **1** | **157** | **219** |
| | | | | | **(2.6 h)** | **(3.7 h)** |

All M11 lectures now land in the 20-30 min NPTEL band; the
expansion added 64 video min and 2 lectures (no thin
sub-20-min outliers remain). The two new lectures bring the
concurrency-safety story (portability + contention) into the
module proper, where it previously had to be hand-waved away
in M11-L01.

### M12: Unikernels (MirageOS) (6 lectures)

Re-estimated 2026-05-25 after the M12 expansion: L01 grew from
10 to 13 slides (TCB-growth timeline, attack-surface argument,
worked HTTP-request trace); L02 grew from 10 to 14 slides
(library modules a libOS picks from, ClickOS, other library-OS
research efforts, leaner-but-more-responsibility trade-off); L03
grew from 10 to 14 slides (Solo5 hypercall ABI, Solo5 backends
table, KVM as the canonical backend, VM-vs-container spectrum);
L04 grew from 10 to 15 slides (GC inside a unikernel, memory
safety as first line of defence, M10/M11 forward pointers,
predictability for servers, OCaml-vs-C trade-off); L05 holds at
12 slides (KC is rewriting it separately); a new L06 *Bob the
Bin Man: a worked unikernel example* (13 slides) walks one tiny
HTTP unikernel end to end. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M12-L01 | Why do we need an OS? | 13 | 2 | 0 | 20 | 28 |
| M12-L02 | Ingredient 1: Library OS | 14 | 2 | 0 | 21 | 29 |
| M12-L03 | Ingredient 2: Virtualisation | 14 | 2 | 0 | 21 | 29 |
| M12-L04 | Ingredient 3: OCaml for systems | 15 | 2 | 0 | 23 | 32 |
| M12-L05 | MirageOS = Library OS + Virtualisation + OCaml | 12 | 2 | 0 | 18 | 25 |
| M12-L06 | Bob the Bin Man: a worked unikernel example | 13 | 2 | 0 | 20 | 28 |
| **M12 total** | | **81** | **12** | **0** | **122** | **171** |
| | | | | | **(2.0 h)** | **(2.8 h)** |

M12-L01..L04 and L06 all land in the 20-30 min NPTEL band.
M12-L05 (12 slides / 18 min) is still under the 20-min floor;
KC is rewriting it separately and will revise this row when the
L05 work is committed.

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
| M08-L08 GADTs use cases | 11 |
| M12-L05 MirageOS = Library OS + Virtualisation + OCaml | 12 |

(M07-L03 and M07-L05 were lifted out of this list by the
2026-05-29 M07 polish pass, which brought them to 18 and 14
slides respectively.)

(M10's previously-thin entries L01 and L05, and M11's
previously-thin entries L01 and L04 (now L05), were lifted out
of this list by the 2026-05-25 M10 and M11 expansions. M12-L01
through L04 were lifted out by the 2026-05-25 M12 expansion;
only M12-L05 remains thin, pending KC's separate rewrite.
M06-L03 was lifted out by the 2026-05-26 M06 polish, which also
expanded M06-L01/L02/L04.)

After the 2026-05-25 sweep, all per-module tables above use
slide_count x 1.5 from the current drafts; these unpolished rows
will move once each module's polish pass lands. Re-check at
polish time per module.

## Course totals

- **Final video**: 1831 min (30.5 hours) across
  81 lectures and 12 modules.
- **Estimated recording time**: 2565 min (42.8 hours)
  at the 1.4x multiplier.

The 30.5 hours of final video meets NPTEL's ~30 hr target
after the 2026-05-25 M09 restructure (+3 lectures, +61 video
min for effect-handler concurrency), the M10 expansion (+1
lecture, +36 video min for resource safety; M10 grew from 5 to
6 lectures with L01/L03/L06 also growing), the 2026-05-25 M11
expansion (+2 lectures, +64 video min for portability and
contention; M11 grew from 5 to 7 lectures with all four
existing lectures also growing), and the 2026-05-25 M12
expansion (+1 lecture, +44 video min for TCB-growth /
ClickOS / Solo5 ABI / GC-in-a-unikernel / Bob-the-Bin-Man;
M12 grew from 5 to 6 lectures with M12-L01..L04 also growing,
and L05 held for KC's separate rewrite). The M08
monads-and-GADTs polish on 2026-05-25 took the module from
7 to 10 lectures and added 1.3 h of video (new M08-L03 monad
laws and list monad, M08-L06 parameterised state and a typed
stack machine, M08-L09 hlists and witnesses). Numbers reflect
the
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

- **42.8 hours of recording / 4.3 hours per day = ~9.9 studio days.**

Per-week breakdown if you want to spread across multiple
sessions:

| Module | Recording (h) | Studio days @ 4.3 h |
|---|---:|---:|
| M01 Intro to functional programming | 2.7 | 0.6 |
| M02 Expressions | 3.1 | 0.7 |
| M03 Functions | 2.8 | 0.7 |
| M04 Data types | 3.4 | 0.8 |
| M05 Pattern matching | 3.6 | 0.8 |
| M06 Higher-order programming | 3.2 | 0.7 |
| M07 Side effects and modular programming | 4.8 | 1.1 |
| M08 Monads and GADTs | 5.2 | 1.2 |
| M09 Concurrency and Testing | 4.1 | 1.0 |
| M10 Memory safety and security | 3.1 | 0.7 |
| M11 OxCaml: type-level extensions of safety | 3.7 | 0.9 |
| M12 Unikernels (MirageOS) | 2.8 | 0.7 |
| **Total** | **42.8** | **9.9** |

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
