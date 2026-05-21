# Review notes: judgment-call items

Auto-applied small fixes have already landed in commits `95e3849`
(M01-M08), `7533f7c` (M10-M12), `74ef688` (M09 expansion), and
`a911565` (M09 review pass). This file tracks the items the five
student-perspective review agents flagged as needing a judgment
call.

Conventions:
- `[ ]` open: still needs your call.
- `[x]` resolved: applied, with a one-line note pointing at the
  commit or describing what changed.
- `[~]` rejected: won't do, with a one-line reason.

## Open (needs your call)

These are the items I left alone because the trade-off is real
and I want your read before changing structure or voice.

- [ ] **M04-L05** type-abbrev half stapled on. The lecture is
  titled "`option`, `result`, and type abbreviations"; the
  abbreviation half currently sits after the option/result
  treatment and reads like an appendix. Options for the
  reorganisation: (a) split into two lectures; (b) lead with
  abbreviations as the lightweight intro, then the heavier
  `option`/`result`; (c) leave as-is and accept the stapled feel.
- [ ] **M04-L05** option intro density. The first introduction
  of `option` packs definition + `None`/`Some` semantics + idioms
  + comparison to `null` into a single block. Possible
  decomposition: a tight intro section (just the type and a
  one-line example), then a separate "idioms" section. Trade-off
  is lecture length.
- [ ] **M05-L05** q2 has a genuinely ambiguous answer. The MCQ
  asks how to extract `url` from a variant; option 2 (separate
  clauses) is marked correct, and the explanation acknowledges
  option 3 (or-pattern across constructors) also compiles. Best
  options: (a) reword to "which is the most idiomatic" rather
  than "which correctly extracts"; (b) drop option 3 entirely;
  (c) make it a multi-select.
- [ ] **M08-L04** state-monad rewrite count. The lecture has four
  successive sections that all rewrite gensym (the bare worked
  example, the "vs. ref" framing, the "hides the plumbing"
  rewrite, the "labelled" rewrite). Worth keeping all four for
  the contrast they expose, or trimming to two (canonical + one
  refinement)?
- [ ] **M08-L05** type-annotation pacing. The GADT-basics
  lecture introduces GADT syntax, type-safe construction, pattern
  matching with type refinement, and phantom types in quick
  succession. Add one more worked example, or accept the pace
  given that L06 elaborates with use cases?
- [ ] **M09-L03** "Custom arbitraries" section (lines 1356-
  1505) reads as bolted on after the shrinker section. The
  worked `tree` example duplicates L05's `expr` generator
  structurally. Options: (a) trim by half (cut the printer/
  shrinker repetition); (b) move it to L04 as a prelude to the
  command generators; (c) merge with the shrinker section since
  custom arbitraries *are* generator + printer + shrinker
  bundled.
- [ ] **M09-L03** input-space and invariant-generation stretch
  (lines 678-1154, ~470 lines) is the heaviest part of the
  35-min lecture. Candidates for trimming: recipe A2 (prefix-sum
  sorted lists, duplicate of A1) or recipe B2 (balanced-BST
  midpoint splitting, duplicate of B1's operation-based
  generator). Cutting one each would save ~100-150 lines.
- [ ] **M09-L04** `Ht` implementation (lines 178-263): 70+
  lines of mutable state, linear probing, tombstones, and
  resize before the testing harness begins. For a 25-min lecture
  about *testing*, this is a lot of unrelated code to digest
  first. Options: (a) compress to a sketch with the full version
  in an appendix; (b) link to an external file; (c) keep as-is
  because students need to see the SUT to understand the test.
- [ ] **M10-L01** UB categories slide overlap. The four UB
  categories on the slide (memory, integer, aliasing, lifetime)
  partially overlap with the four bug classes enumerated later
  (use-after-free, buffer overflow, uninitialised read,
  double-free). Either merge them into one taxonomy, or sharpen
  the distinction between "categories of UB" and "specific bugs
  that fall in each category."
- [ ] **M10-L02** ROP/heap-spray diagram offset annotation. The
  diagram could use an explicit annotation showing the offset
  arithmetic (saved-rip offset, gadget chain layout), not just
  the high-level shape. Adding this means redrawing the diagram.
- [ ] **M11-L04** Girard footnote placement. The Girard / Linear
  Logic origin footnote currently sits at the end of the
  lecture (lines 444-477). Move it as a margin aside near the
  first mention of "linearity" so the historical hook lands
  when the word appears? The in-memory mock note is already
  present at lines 108-141; no action needed there.
- [ ] **M12-L01** iceberg metaphor used at lines 169, 254-288,
  378, 477. Multiple reinforcements vs. one canonical use; pick
  whether the metaphor earns four mentions or works better as
  one set-piece.
- [ ] **M12-L02** ASCII layer diagrams: the lecture currently
  describes layers in prose ("kernel below it, kernel code runs
  with full hardware privilege" etc.). An ASCII layer diagram
  for "user code -> library OS -> hypervisor -> hardware" would
  help. Holding off because ASCII art needs careful layout in
  both chapter and slide modes; want your read on whether to
  use ASCII or commission an SVG.
- [ ] **M12-L03** EPT/RVI jargon at lines 74 and 270. Two
  mentions in the same lecture, both correct, but the reader
  meets EPT (Intel) and RVI (AMD) without a one-line gloss on
  what "second-level page tables" actually do. Worth one
  paragraph, or skip because most students will not need it?
- [ ] **M12-L04** industrial-users list at lines 224-261 runs
  long. Worth trimming, or keep as written because the variety
  is the point?

## Resolved

- [x] **M01-L01** sieve forward-ref: rejected. Agent misread the
  example; finite `int list` with `List.filter` and pattern
  matching, both already hyperlinked as forward refs.
- [x] **M03-L02** let-rec mental model: rejected. Agent
  misattributed; M03-L02 covers single-function recursion only.
  L02 lines 128-144 already carry the mental-model passage.
- [~] **M03-L03** operator-prefix worked example: rejected.
  Already done. Line 305 has `List.fold_left (+) 0 xs` as the
  higher-order use of the prefix form.
- [~] **M03-L04** `List.map` tail-rec aside placement: rejected.
  The aside sits at lines 488-510, at the *end* of the lecture
  after the canonical tail-rec walkthrough. Placement is fine.
- [~] **M03-L06** count_digits negative: rejected. Already
  discussed at length (lines 430, 450-466) with a defensive
  `abs`-wrap version.
- [~] **M04-L04** fold_left in JSON: rejected. No `fold_left`
  references in the file; agent's flag was wrong.
- [x] **M04-L05** type-abbrev / option intro: see Open.
- [~] **M05-L02** or-pattern slide: rejected. The slide is
  intentionally minimal; the chapter elaborates with the variants
  case and the `|`-separator vs. `|`-combinator distinction.
  Dual-mode design, not a defect.
- [x] **M05-L05** q2: see Open.
- [x] **M06-L01** sentence stub: rejected. Line-wrap false
  positive; the sentence "a function is a value the same way
  `42` is a value, with the same rights to be named..." is
  well-formed across the wrap.
- [x] **M06-L04** fold argument-order table: applied. Added a
  side-by-side `fold_left` / `fold_right` table after the
  argument-order discussion.
- [~] **M06-L05** `@@` operator value: rejected. The current
  text already explains the deeply-nested-expression motivation
  (lines 192-197) and recommends `|>` as the default. Adding a
  contrived complex example would oversell the operator.
- [x] **M07-L05** SML ALL-CAPS aside: applied. Reworded the
  convention paragraph so the slide and chapter agree (uppercase
  conventional; many codebases use ALL CAPS, others CamelCase;
  pick whichever your codebase uses).
- [~] **M07-L06** functor-as-function hedging: rejected. The
  framing is consistent across the lecture ("a functor takes a
  module as an argument").
- [~] **M08-L01..L02** monad-laws hand-off: rejected. L01 line
  261-264 mentions briefly with a forward link; L02 line 369-386
  has the dedicated "Monad laws (a teaser)" section. The handoff
  is clean.
- [x] **M08-L04** state-monad rewrite count: see Open.
- [x] **M08-L05** type-annotation pacing: see Open.
- [x] **M09-L03** "Custom arbitraries" section: see Open.
- [x] **M09-L03** `dag_gen` `>>=` unexplained: applied. Added a
  one-line gloss immediately before the code block tying `>>=`
  to the `let*` form used earlier.
- [x] **M09-L03** input-space stretch: see Open.
- [x] **M09-L04** `Ht` implementation length: see Open.
- [x] **M09-L05** entry-point bug: applied. Added a code
  comment flagging the `run_test_tt_main`-exits issue and
  reworded the surrounding prose so a copy-paster sees the
  warning before running the code.
- [x] **M09-L05** "Result" parenthetical: applied. Rewrote the
  expected/got annotations to name the bug directly ("correct:
  a -. b" vs "bad_eval: b -. a").
- [x] **M10-L01** UB categories slide overlap: see Open.
- [x] **M10-L02** ROP/heap-spray diagram offset: see Open.
- [x] **M11-L01** contention/portability one-liner: rejected.
  Already present at lines 337-353 with a "Contention and
  portability, briefly" section that defers to the CS6868
  handout.
- [x] **M11-L01** forward ref to `Modes.Aliased.t`: applied.
  Added a one-paragraph forward pointer in the
  "syntax-is-evolving" note that gives the wrapper its
  rationale and points to M11-L03.
- [~] **M11-L03** closure-capture submoding: rejected. Lines
  458-474 already explain the rule ("a closure that captures a
  unique value is itself given the mode `once`...The two axes
  cooperate: capturing a unique value automatically downgrades
  the closure's linearity to `once`").
- [x] **M11-L04** in-memory mock note + Girard footnote: in-
  memory mock note already present (lines 108-141); Girard
  placement: see Open.
- [x] **M11-L05** open-exactly-once + Zerologon: applied.
  Added a sentence after the "(automatic)" framing explaining
  it falls out of `open_`'s constructor; replaced the Zerologon
  name-drop with an attached CVE link and a one-line
  description of the bug class.
- [x] **M12-L01** iceberg metaphor: see Open.
- [x] **M12-L02** ASCII layer diagrams: see Open.
- [x] **M12-L03** EPT/RVI jargon: see Open.
- [x] **M12-L04** industrial-users / slower-than-C: slower-than-C
  hedge applied (added a link to the Benchmarks Game and the
  "treat 1.5x-2x as order-of-magnitude, not a precise figure"
  qualifier); industrial-users list trim: see Open.
- [x] **M12-L05** `Lwt.Infix` introduction: applied. Added a
  one-paragraph gloss immediately before the code block tying
  `>>=` back to the QCheck-generator `>>=` introduced in M09-L03.
- [~] **M12-L05** Fiat-Crypto / Coq gloss: rejected. Already
  present at lines 303-307 ("Fiat-Crypto is a project that
  *proves*, in the Coq proof assistant, that the C code...").

## Browser smoke verification (still pending)

- [ ] **M09-L03** `point_shrink` and `tree_arb` cells use
  `QCheck.Iter.t`, `<+>`, `>|=`, and `let*` inside `QCheck.Gen`.
  Confirm `QCheck.Iter` and `QCheck.Gen.Let_syntax` are exposed
  in the in-browser bundle.
- [ ] **M09-L03** `dag_gen` uses `>>=` on `QCheck` directly;
  verify in scope or needs `let open QCheck.Gen in`.
- [ ] **M09-L04** hash-table module with mutual
  `let rec ... and ...` and mutable state: smoke-test that it
  parses and runs in the in-browser toplevel.
- [ ] **M09-L04** `Queue2`, `Qref`, model-based-test harness
  blocks: smoke-test they parse in `<x-ocaml>`.
- [ ] **M11-L04, M11-L05** never had a browser smoke pass
  (M11-L01..L03 verified earlier in the session).
