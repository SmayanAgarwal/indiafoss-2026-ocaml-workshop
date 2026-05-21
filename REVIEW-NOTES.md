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

- [~] **M04-L05** type-abbrev half stapled on: leave-as-is per
  KC. All three pieces are part of M04's data-type vocabulary
  and the explicit cross-topic lecture is fine at the end of
  the module.
- [~] **M04-L05** option intro density: rejected. Intro (37-82)
  is paced reasonably; idioms section starts at line 159. The
  "Why not null" motivation in between is contrast, not
  idiom-as-intro. Agent's flag does not stand.
- [x] **M05-L05** q2: applied. Dropped the or-pattern-across-
  constructors option entirely and rewrote the rationale; the
  remaining three options are unambiguous. (Multi-select MCQ
  support deferred; the toolchain currently hardcodes single-
  select radios.)
- [~] **M08-L04** state-monad rewrite count: rejected per KC.
  On a re-pass there are three versions (bare gensym; ref
  comparison; clean gensym), not four, and each earns its place.
- [x] **M08-L05** type-annotation pacing: applied. Added a
  "take a breath" paragraph at the top of the "Pattern matching
  with type refinement" section, naming it as the centerpiece
  and signalling the eval walkthrough below.
- [x] **M09-L03** "Custom arbitraries" section: applied. Trimmed
  ~50 lines: dropped the formal QCheck.make signature intro
  (reader has already seen it used four times), dropped the
  slide that re-itemised generator/printer/shrinker, kept the
  tree_arb worked example as a single integrated walkthrough
  with a forward-reference to L04/L05 where the pattern recurs.
  Section renamed from "Custom arbitraries" to "Bundling
  generator, printer, and shrinker" to reflect the trim.
- [~] **M09-L03** input-space stretch: leave-as-is per KC. On
  a re-pass each recipe earns its place: A2 illustrates building
  by accumulation; B2 illustrates structural construction with
  a different distribution from B1 (B1 = induced-by-insertion
  order, B2 = balanced/uniform). A 35-min lecture has room for
  thorough coverage of the hardest topic.
- [~] **M09-L04** Ht implementation length: leave-as-is per KC.
  The 70-line SUT is the right scale (simple enough to read,
  complex enough to have plausible bugs in resize/tombstone
  timing). The lecture explicitly tells readers to skim. The
  testing point lands harder with the full SUT in view.
- [x] **M10-L01** UB categories slide overlap: applied.
  Strengthened the slide's closing line to name the four memory
  bugs that live inside categories (1) and (4) explicitly, so
  a slide-only reader sees the connection without having to
  pivot to the chapter prose.
- [x] **M10-L02** ROP/heap-spray diagrams: applied. Annotated
  the existing type-confusion ASCII diagram with explicit
  offset-0/8/16 labels so the slide's "load *(w+8); call it"
  arithmetic aligns visually. Added a new ASCII stack-layout
  diagram in the ROP step showing the gadget chain at offsets
  %rsp + 0/8/16/24, making concrete why "each `ret` pops the
  next gadget" actually works.
- [~] **M11-L04** Girard footnote placement: leave-as-is per
  KC. The intro forward-pointer at line 47 already names Girard
  and the end-section pays off the pointer; the existing
  structure works.
- [~] **M12-L01** iceberg metaphor: leave-as-is per KC. The
  four uses form a foreshadow / develop / visualise / conclude
  arc; each mention earns its place.
- [x] **M12-L02** ASCII layer diagrams: applied. Duplicated the
  conventional-kernel and library-OS ASCII boxes from the slides
  into the chapter prose at the "Picture: a single coloured
  box..." paragraph, so chapter readers see the diagram inline
  without toggling to slide mode. (The slide versions stay.)
- [~] **M12-L03** EPT/RVI jargon: rejected per KC. Both
  acronyms are defined inline at first mention (line 74); NPT
  and "second-level page tables" are not used in the lecture.
  Standard define-at-first-use discipline; no defect.
- [~] **M12-L04** industrial-users list: leave-as-is per KC.
  Ten entries across diverse industries (finance, compilers,
  security, blockchain, SEO, dev tools) is the answer to "is
  this a research toy?"; cutting weakens the breadth argument.

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
