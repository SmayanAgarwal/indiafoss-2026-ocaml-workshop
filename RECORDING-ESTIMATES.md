# Recording-time estimates

## Calibration and assumptions

- **Final video length per lecture**: computed as `slide_count
  x 1.5 min`, where slide_count is `grep -c '^:::slide'` of the
  current lecture draft. The 1.5 factor was calibrated against
  M01's per-lecture ratio (average 1.49) and confirmed across
  the M02/M03/M04 polish passes.
- **Speaking pace**: ~160 words per minute, measured from two
  CS3100 video transcripts (51 min / 8,391 words = 164 wpm;
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
| M02-L01 | Literals: integers, floats, booleans, strings | 21 | 2 | 0 | 32 | 45 |
| M02-L02 | `let` bindings and shadowing | 19 | 1 | 1 | 29 | 41 |
| M02-L03 | Static vs dynamic semantics, and type inference | 15 | 3 | 0 | 23 | 32 |
| M02-L04 | Operators, precedence, and common pitfalls | 14 | 1 | 1 | 21 | 29 |
| M02-L05 | `if`/`then`/`else` as an expression | 14 | 2 | 1 | 21 | 29 |
| M02-L06 | Tutorial: small expressions, end to end | 11 | 0 | 2 | 17 | 24 |
| **M02 total** | | **94** | **9** | **5** | **143** | **200** |
| | | | | | **(2.2 h)** | **(3.1 h)** |

M02-L01 now edges just over the 30 min NPTEL upper bound (32 min;
the Expressions / Values / six-literal-kinds opening grew the
lecture). M02-L06 is just below the 20 min lower bound; that is
fine for a tutorial but worth flagging if NPTEL wants strict
20-30 min videos. The current M02 estimate is 143 video min /
200 recording min.

### M03: Functions (6 lectures)

Re-estimated 2026-05-22 after the M03 polish pass (closure
formalisation, anonymous-fn split, polymorphism forward pointer,
sum_to demo input 10_000, tail-rec map deferred to M06-L02,
list-length dropped, M03-L05 list-free with mod3 activity,
M03-L06 list-free with fast_power and is_prime).

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M03-L01 | Functions as values, and anonymous functions | 20 | 2 | 1 | 30 | 42 |
| M03-L02 | Recursion | 16 | 1 | 1 | 24 | 34 |
| M03-L03 | Currying and partial application | 15 | 2 | 1 | 23 | 32 |
| M03-L04 | Tail recursion and accumulators | 12 | 1 | 1 | 18 | 25 |
| M03-L05 | Local functions and mutual recursion | 11 | 2 | 1 | 17 | 24 |
| M03-L06 | Tutorial: Fibonacci, GCD, power, digits | 11 | 2 | 1 | 17 | 24 |
| **M03 total** | | **85** | **10** | **6** | **129** | **181** |
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
| M04-L03 | Variants (sum types) | 11 | 1 | 1 | 17 | 24 |
| M04-L04 | Recursive types, polymorphism, option / result | 24 | 2 | 1 | 36 | 50 |
| M04-L05 | Tutorial: a tiny AST for OCaml | 16 | 3 | 0 | 24 | 34 |
| M04-L06 | Tutorial: a tiny file system | 14 | 3 | 0 | 21 | 29 |
| **M04 total** | | **99** | **12** | **4** | **150** | **209** |
| | | | | | **(2.5 h)** | **(3.4 h)** |

M04-L04 is the longest lecture in the course at 36 video min; it
overruns the NPTEL 30-min upper bound. KC has chosen to keep it
as one lecture rather than split (the content arc from intlist
all the way to result is best taken in one sitting), but if the
recorded delivery overshoots, a natural cut point is "Null: the
billion-dollar mistake" - everything before is recursive /
parameterised variants, everything after is `option` / `result`
design.

M04-L03 is below the NPTEL 20-min lower bound at 11 slides / 17
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
2026-05-23. On 2026-05-30, M07-L09 grew from 15 to 21 slides: an
illustrated two-stack-queue trace, the example runs split onto
their own slides (implementation, sealed, string-queue), a
runnable string-queue example, and a second activity (a queue of
queues of integers) with a worked example run. Estimate uses
slide_count x 1.5 min.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M07-L01 | Mutable references | 22 | 3 | 1 | 33 | 46 |
| M07-L02 | Mutable records and arrays | 22 | 2 | 1 | 33 | 46 |
| M07-L03 | Exceptions | 18 | 2 | 1 | 27 | 38 |
| M07-L04 | Streams and laziness | 19 | 2 | 1 | 29 | 41 |
| M07-L05 | Memoization | 18 | 2 | 1 | 27 | 38 |
| M07-L06 | Module basics | 15 | 2 | 1 | 23 | 32 |
| M07-L07 | Module signatures | 18 | 2 | 1 | 27 | 38 |
| M07-L08 | Functors | 15 | 2 | 1 | 23 | 32 |
| M07-L09 | Tutorial: a queue functor | 21 | 2 | 1 | 32 | 45 |
| **M07 total** | | **168** | **19** | **9** | **254** | **356** |
| | | | | | **(4.2 h)** | **(5.9 h)** |
| M07-L10 | Practice: mutability, modules, and streams (not recorded) | 0 | 0 | 19 | 0 | 0 |

M07-L01 and M07-L02 (22 slides / 33 min each) and M07-L09 (21
slides / 32 min) now sit above the NPTEL 30-min ceiling. Natural
cuts if delivery runs long: L01's ticket-dispenser broken/hoisted
pair (one slide could carry both in less detail), or the
eta-expansion slide (most skippable of the value-restriction
trio); L02's `while`-loop slide (only added to make the syntax box
honest) or the default-to-immutable closing slide; L09's run
slides could fold back into their definition slides, or the
string-queue run could merge with "What's notable". M07-L03 was restructured on
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
M07-L08 (15 slides / 23 min) sits right at the floor; M07-L04
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
a slide-free, video-free in-browser worksheet of nineteen
problems across the three module threads (7 mutability,
6 modules/functors, 6 streams), with collapsible reference
solutions, so it adds nothing to the recording total. Part 2
(modules/functors: `Showable`, the `MakeNode` / `MakeList`
doubly-linked list, `MakeSet`/`MakeDict`, a functional heap) is
drawn from CS3100's mutability-and-modules and monads assignments
plus the `Set.Make`/`Map.Make` shape; Parts 1 and 3 are original.

### M08: Monads and GADTs (7 lectures + practice sheet)

Re-estimated 2026-06-06 by `grep -c '^:::slide'` of the current
M08 drafts; the post-compression polish passes (notably the
2026-06-02 L05 type-level aside and growth across L01-L05) had
drifted the 2026-05-31 numbers. M08 was **compressed from 10
back to 7 lectures** (6 lectures + 1 tutorial), merging the
repetitive monad half (option+sequencing -> L01;
laws+list+result -> L02; state+parameterised -> L03) and
renumbering the GADT half + tutorial to L04-L07. The 2026-06-02
M08-L08 practice sheet (state-monad refs, length-indexed lists,
typed interpreter) is deliberately slide-free and book-only, so
it adds no video or recording time and is excluded from the
table. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M08-L01 | The option monad and `let*` | 15 | 2 | 1 | 23 | 32 |
| M08-L02 | Monad laws, the list monad, the result monad | 16 | 2 | 1 | 24 | 34 |
| M08-L03 | The state monad and parameterised state | 22 | 2 | 1 | 33 | 46 |
| M08-L04 | GADTs: basics | 17 | 2 | 1 | 26 | 36 |
| M08-L05 | GADTs: use cases | 19 | 2 | 1 | 29 | 41 |
| M08-L06 | GADTs: hlists, witnesses, and `printf` | 14 | 2 | 1 | 21 | 29 |
| M08-L07 | Tutorial: a tiny well-typed evaluator | 17 | 2 | 1 | 26 | 36 |
| **M08 total** | | **120** | **14** | **7** | **182** | **254** |
| | | | | | **(3.0 h)** | **(4.2 h)** |

M08-L03 now tops the module at 33 min, just over the NPTEL
30-min ceiling; a natural cut point if the recorded delivery
overshoots is the parameterised-state half. M08-L06 sits
nearest the 20-min floor.

### M09: Testing (7 lectures)

Re-estimated 2026-06-05 after the depth trim: the custom-
generators lecture (old L06) was dropped outright (too deep for
this course; its distribution material now lives as a short
"Beyond the built-in generators" note in L05, and the tutorial
teaches its own `gen_expr` inline), old L07/L08 renumbered to
L06/L07, and model-based testing was rewritten around a mutable
two-list queue vs a plain-list reference (the open-addressing
hash table moved to the activity). The same pass added the
L03 path-audit slides (the opening lecture's five tests miss a
path; seeded-mutant demo) and the L05 sort-property and
why-shrinking slides. This followed the 2026-06-04 L04 recast
(16 -> 13 slides), the L02/L03/L08 slide polish, and the
2026-06-02 testing-only restructure. Module slide count moved
125 -> 138 (polish) -> 135 (L04 recast) -> 124 (depth trim,
net of the new L03/L05 slides). Re-counted 2026-06-06 after the
L07 trim: differential testing (the optimiser-vs-eval part) was
dropped from the tutorial (a tutorial should not introduce a new
technique), the four QCheck properties became three (the Add
commutativity property was factually wrong: IEEE-754 addition
commutes exactly), the activity became a Neg-extension exercise
on the expr generator, and the suite/property cells went live
in-browser. The cut paid for per-case slides (the four OUnit2
cases), per-property live-cell slides, and a
planted-bug/anchored-property pair; the dune-stanza slide was
dropped. A follow-up pass (same day) made the generator's leaves
include `infinity` and `nan` (the spec names them; KC), switched
the comparisons to NaN-aware `same_float` agreement, and made
distributivity a finite-domain conditional, adding a
leaf-distribution slide; the common-pitfalls slide was dropped
(the chapter section stays). L07: 17 -> 19 slides; module
126 -> 128. Estimate uses slide_count x 1.5 min.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M09-L01 | Why test a type-safe program? | 15 | 3 | 0 | 23 | 32 |
| M09-L02 | Specifications and invariants | 20 | 2 | 1 | 30 | 42 |
| M09-L03 | Designing test cases: black-box and glass-box | 23 | 2 | 1 | 35 | 49 |
| M09-L04 | Unit testing | 13 | 1 | 1 | 20 | 28 |
| M09-L05 | Property-based testing with QCheck: basics and shrinking | 19 | 2 | 1 | 29 | 41 |
| M09-L06 | Model-based testing | 19 | 2 | 1 | 29 | 41 |
| M09-L07 | Tutorial: testing the expr evaluator with OUnit2 and QCheck | 19 | 1 | 1 | 29 | 41 |
| **M09 total** | | **128** | **13** | **6** | **195** | **274** |
| | | | | | **(3.3 h)** | **(4.6 h)** |

L02 and L03 now top the module at 30 min each: L02 carries
both specifications and the AF/RI material, L03 carries
black-box, glass-box, and a live coverage walkthrough. Each has
a clean split point (L02: specs | invariants; L03: design |
coverage) if a polish pass needs to bring them under the 30-min
ceiling. L01 sits at 23 min as the module opener.

### M10: Memory safety and security (5 lectures)

Rewritten 2026-06-06 to a 5-lecture structure with live C demos
(in-browser VM, `/root/m10`) and TikZ figures. The old L01 (UB
zoo) and L02 (security incidents) fused into one motivation
lecture; a new short L03 covers data races as UB; the old L04
(escape hatches) and L05 (resource safety) fused into one; the
tutorial is now L05. Estimate uses slide_count x 1.5 min. M10's
slides are unusually dense (figures, code, live demos), so real
timings trend to the upper end of each estimate.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M10-L01 | What memory safety is, and why it is a security story | 20 | 3 | 0 | 30 | 42 |
| M10-L02 | Memory safety by construction | 14 | 2 | 1 | 21 | 29 |
| M10-L03 | Data races are undefined behaviour | 11 | 3 | 1 | 17 | 24 |
| M10-L04 | Where OCaml itself has UB | 18 | 4 | 1 | 27 | 38 |
| M10-L05 | Tutorial: walking Heartbleed end to end | 16 | 2 | 1 | 24 | 34 |
| **M10 total** | | **79** | **14** | **4** | **119** | **167** |
| | | | | | **(2.0 h)** | **(2.8 h)** |

The module sits right at the ~2 h video budget set for the
rewrite. L03 (17 min by the slide proxy) is the deliberately short
data-race lecture; its figure- and transcript-dense slides run
closer to 20 min in practice. L03 was deepened on 2026-06-07
(precise race definition; the memory model's local-DRF /
bounded-in-space-and-time story; a third MCQ) and again on
2026-06-08 (a dedicated sequential-consistency / DRF-SC slide
ahead of the comparison table). L04 was reworked on 2026-06-08:
the resource-safety story runs as live mock-handle cells (open /
use / close by hand, the `Fun.protect` combinator, an example use,
and a global-ref leak that motivates a stronger type system) rather
than two static slides; it grew to 19 slides, then trimmed to 18 by
dropping the escaping-handle figure (redundant with the live leak
demo) and folding the forward-pointer slide into "Where it breaks
down". L05 grew on 2026-06-08 from 13 to 16 slides:
the slides now carry the OpenSSL handler, the full OCaml
`handle_heartbeat` (with a live `Bytes.sub` bounds-check raise), and
the "why this keeps happening" thesis, which had been chapter-only.

### M11: OxCaml: type-level extensions of safety (6 lectures)

Re-estimated 2026-06-08 after dropping the standalone modes-intro
lecture (KC: it was an all-preview tour, no teaching). The old
M11-L01 *Modes as the type-level continuation of safety* is gone;
its only durable content (what OxCaml and a mode are) survives as
three intro slides folded onto the front of the locality lecture,
which is now the module opener. No upfront enumeration of the five
axes: each axis is introduced where it is taught. The module now
runs locality, uniqueness, linearity, portability, contention,
tutorial (concurrency axes adjacent, per KC). Every code block is a
live cell against the x-oxcaml bundle (worker + 4 MB `portable.js`
extension, so `Domain.Safe.spawn`, `Portable.Atomic` and the
capsule API run in-browser); linearity is titled *use at most once*
with the leak claim corrected (a dropped `once` value compiles);
the tutorial carries a "where is uniqueness?" design-note slide.

Re-aligned 2026-06-08 to KC's CS6868 OxCaml slides/handout
(narrative + exact code). L01 grew 15 to 17 slides: the
"Control + Safe / modes are how, types are what" framing, and a
performance arc (`[@zero_alloc]`, the zero-alloc *failure*, unboxed
`float#`) shown as static `text` blocks since the native flambda
check and unboxed floats do not run in the in-browser toplevel.
L05 gained KC's capsules payoff (the vanilla `unsafe_insert`
motivation + the runnable `Capsule.Data` gensym, verified live)
and shed a redundant bridge slide, net unchanged at 17. L01 then
grew 17 to 20 on KC's pedagogy note: lead with the C `return &x`
escaping bug (from M10), a "what locality mode captures" concept
slide, and the compiler rejecting the escape, all *before* the
global/local mechanics. L01 now sits at the 30-min ceiling and is
the natural split candidate if recorded delivery overruns.

A 2026-06-11 review pass on L03-L06 moved the press-Run example
and rejection code onto slides so the deck carries the payoff
moments (KC's inline comments on L03; same principle applied to
L04/L05). KC follow-ups the same day: self-descriptive slide
titles for video-only viewers; L03's modular-reasoning material
restructured as per-signature slides (`Free_unique` then
`Free_once`, each with its submoding bullets); the L03
"three bugs" summary table and the Girard history slide dropped.
Echo-aware overflow checks (navigate per slide; bulk reads
under-measure past reveal's viewDistance) forced three splits.

Later the same day, KC reordered the concurrency pair to match
CS6868: **contention is now L04 and portability is L05**, with
both lectures realigned to the CS6868 Part 2 slides. Contention
gained the deep-contention rule (Rule 2, the `box`/array
laundering demo), a brief two-axes naming slide, and a live
write-to-a-contended-atomic demo; it lost the parallel-counter
section (redundant with M10's counter and the gensym payoff) and,
per KC ("this is not a concurrency course"), the vanilla-mutex
motivation and the capsules arc. Portability now states the
capture rule in its real vocabulary (captures are treated as
`contended`), gained the two-step data-race argument slide and
the `Portable.Atomic` "first working program" (with the
stdlib-Atomic-lacks-annotations takeaway), and lost the
stdlib-atomic non-fix station and the portability mode-crossing
table. Finally, L06 was rewritten around a single BRACKETED
example (KC): `with_handle` with a sealed module (no exposed
open/close), the handle at `@ local`, the callback at `@ once`;
three attack demos (stash, return, close: the last is unwritable,
"Unbound value Handle.close"); the buffer design exercise and the
Conn-pool extension were cut, and the capstone now reads the real
`capsule` `with_password` signature as the production pattern
where `unique` ownership travels between brackets. Estimate uses
slide_count x 1.5 min.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M11-L01 | Locality: safe stack allocation (opens with OxCaml/modes intro) | 22 | 2 | 0 | 33 | 46 |
| M11-L02 | Uniqueness: the only reference | 12 | 2 | 0 | 18 | 25 |
| M11-L03 | Linearity: use at most once (+ uniqueness synthesis) | 19 | 2 | 0 | 29 | 41 |
| M11-L04 | Contention: synchronisation at compile time | 15 | 2 | 0 | 23 | 32 |
| M11-L05 | Portability: data-race freedom across domains | 13 | 2 | 0 | 20 | 28 |
| M11-L06 | Tutorial: a resource-management API | 14 | 2 | 0 | 21 | 29 |
| **M11 total** | | **95** | **12** | **0** | **144** | **201** |
| | | | | | **(2.4 h)** | **(3.4 h)** |

L01 is now 22 slides / ~33 video min, over the NPTEL 30-min ceiling
after KC's 2026-06-09 review additions (the live M10 escaping-handle
before/after, the C crash example, a `use_locally` slide, a triangle
perimeter slide, and code on the polyline slides). **KC decision
(2026-06-09): leave as one lecture**, over-ceiling is acceptable
here. (If a future split is ever wanted, the natural cut is **L01a**
OxCaml intro + the M10 escaping handle + locality basics
(global/local, `stack_`, escape) and **L01b** `exclave_`, mode
crossing, the polyline, the zero-alloc/unboxed performance arc.)

Apart from L01 (accepted over-ceiling, above), the M11 lectures
land in the 20-30 min NPTEL band. Dropping the modes-intro lecture
removed ~21 min of preview video; the OxCaml and modes framing now
lives where the audience first needs it, at the top of locality.

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
predictability for servers, OCaml-vs-C trade-off); a new L06 *Bob
the Bin Man: a worked unikernel example* (13 slides) walks one
tiny HTTP unikernel end to end. Estimate uses slide_count x 1.5
min.

Restructured 2026-06-12 (KC): the three ingredient lectures
(library OS, virtualisation, OCaml-for-systems) squashed into one
background lecture, dropping the talk-era advocacy content
(industrial OCaml, performance pitch, web-server benchmark,
government memos as slides) that this audience does not need;
the old L05/L06 renamed to L03/L04. M12 is now four lectures.

| Lecture | Topic | Slides | MCQ | Code | Video (min) | Recording (min) |
|---|---|---:|---:|---:|---:|---:|
| M12-L01 | Why do we need an OS? | 12 | 2 | 0 | 18 | 25 |
| M12-L02 | MirageOS Unikernel Background | 16 | 2 | 0 | 24 | 34 |
| M12-L03 | MirageOS Basics | 21 | 2 | 0 | 32 | 45 |
| M12-L04 | Suresh the Stationmaster: a worked unikernel example | 16 | 1 | 1 | 24 | 34 |
| **M12 total** | | **65** | **7** | **1** | **98** | **138** |
| | | | | | **(1.6 h)** | **(2.2 h)** |

M12-L02 and M12-L04 sit comfortably in the 20-30 min NPTEL band.
M12-L03 at 21 slides / ~32 min is the longest lecture in the
course (two of those slides are quick live-cell beats, so the
x1.5 average overstates it; still the one to watch in the
studio). M12-L01 (12 slides / 18 min) sits just under the 20-min
floor; its image-heavy slides talk longer than the x1.5 average,
so this is likely fine in practice.

## Sweep: lectures with low slide counts (2026-05-25)

At the calibrated slide_count x 1.5 cadence, anything under ~14
slides runs short of the NPTEL 20-min floor, and anything under
~10 slides is awkwardly thin for a standalone lecture. Counts
below are from a `grep -c '^:::slide'` sweep of all 78 recorded
lectures.

**Polished modules (numbers reflect today's lecture state):**

| Lecture | Slides | Video (min) | Status |
|---|---:|---:|---|
| M04-L03 Variants | 11 | 17 | Grew two slides since first flagged, so it now sits in the borderline tier rather than under the ~10-slide line. **KC decision (2026-05-31): leave as-is** at 17 min, borderline-but-acceptable for a standalone lecture. |
| M02-L06 Tutorial | 11 | 17 | Borderline; tutorials run light by design. Acceptable. |
| M03-L05 Local and mutual | 11 | 17 | Borderline. Post-list-removal shrinkage; OK to leave per current note. |
| M03-L06 Tutorial | 11 | 17 | Borderline; same reason. |
| M03-L04 Tail recursion | 12 | 18 | Borderline. Post-list-removal shrinkage; OK to leave per current note. |

**Unpolished modules (slide counts reflect the current draft
state; expect movement during each module's polish pass):**

| Lecture | Slides |
|---|---:|
| M08-L05 GADTs use cases | 9 |
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

- **Final video**: 1879 min (31.3 hours) across
  79 lectures and 12 modules (plus the slide-free M08 practice
  sheet, which has no video).
- **Estimated recording time**: 2624 min (43.7 hours)
  at the 1.4x multiplier.

The 31.3 hours of final video meets NPTEL's ~30 hr target
after the 2026-05-25 M09 restructure (+3 lectures, +61 video
min for effect-handler concurrency), the 2026-06-02 M09
restructure (concurrency removed from the course entirely;
M09 became a pure 8-lecture testing module with new lectures
on specifications/invariants and test-case design, and a
differential-testing tutorial part; net +13 video min vs the
previous M09 estimate, lecture count unchanged), the 2026-06-04
M09 slide polish (worked examples carried onto slides in L02 and
L03, plus the embedded coverage terminal; M09 grew 125 -> 138
slides, +19 video / +26 recording min, no new lectures) and the
2026-06-04 L04 recast (the OUnit2 tool manual became the concept
lecture "Unit testing"; L04 shrank 16 -> 13 slides, M09
138 -> 135, -4 video / -6 recording min), the 2026-06-05 M09
depth trim (custom-generators lecture dropped, model-based
testing rewritten around a queue, L03/L05 gained audit and
shrinking slides; M09 went 8 -> 7 lectures, 135 -> 126 slides,
-13 video / -17 recording min), the M10
expansion (+1
lecture, +36 video min for resource safety; M10 grew from 5 to
6 lectures with L01/L03/L06 also growing), the 2026-05-25 M11
expansion (+2 lectures, +64 video min for portability and
contention; M11 grew from 5 to 7 lectures with all four
existing lectures also growing), and the 2026-05-25 M12
expansion (+1 lecture, +44 video min for TCB-growth /
ClickOS / Solo5 ABI / GC-in-a-unikernel / Bob-the-Bin-Man;
M12 grew from 5 to 6 lectures with M12-L01..L04 also growing,
and L05 held for KC's separate rewrite). The M08
monads-and-GADTs module was expanded to 10 lectures on
2026-05-25 and then **re-compressed to 7** on 2026-05-31
(6 lectures + 1 tutorial), merging the repetitive monad half
and curating to a ~3 h budget; this removed ~2 h of recording
time, though the post-compression polish (and the 2026-06-02
L05 type-level material) grew it back to 3.0 h video by the
2026-06-06 re-count. Numbers reflect
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

- **42.9 hours of recording / 4.3 hours per day = ~10 studio days.**

Per-week breakdown if you want to spread across multiple
sessions:

| Module | Recording (h) | Studio days @ 4.3 h |
|---|---:|---:|
| M01 Intro to functional programming | 2.7 | 0.6 |
| M02 Expressions | 3.3 | 0.8 |
| M03 Functions | 3.0 | 0.7 |
| M04 Data types | 3.5 | 0.8 |
| M05 Pattern matching | 3.6 | 0.8 |
| M06 Higher-order programming | 3.4 | 0.8 |
| M07 Side effects and modular programming | 5.9 | 1.4 |
| M08 Monads and GADTs | 3.3 | 0.8 |
| M09 Testing | 4.8 | 1.1 |
| M10 Memory safety and security | 3.2 | 0.7 |
| M11 OxCaml: type-level extensions of safety | 3.5 | 0.8 |
| M12 Unikernels (MirageOS) | 2.9 | 0.7 |
| **Total** | **42.9** | **10.0** |

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
