# Review notes: judgment-call items still open

These are the items the five student-perspective review agents
flagged as **not auto-applicable**: they need a judgment call on
voice, structure, or whether the suggestion is worth taking at
all. Auto-applied small fixes have already landed in commits
`95e3849` (M01-M08) and `7533f7c` (M10-M12); the M09 testing
expansion landed in `74ef688`.

The natural way to resolve these is to either drop a
`<!-- KC: ... -->` comment in the relevant lecture file, edit
directly, or strike out the item here with a one-line reason.

Conventions for this file:
- `[ ]` open; `[x]` resolved (with a one-line note); `[~]`
  rejected (won't do, with a reason).
- One bullet per item; reference the lecture file and the
  suggestion summary.

## M01-M08

- [ ] **M01-L01** sieve forward-ref: the prime-sieve example
  references concepts (lazy lists, infinite streams) before they
  exist in the course. Either gloss with a forward pointer or
  drop the demo.
- [ ] **M03-L02** let-rec mental model: the lecture jumps from
  recursive `let` to mutual recursion without a small "what does
  the recursive binding actually see at the call site" mental-model
  paragraph.
- [ ] **M03-L03** operator-prefix worked example: the section on
  `(+)`/`(::)`/etc. could use one worked example threading the
  conversion through a higher-order use.
- [ ] **M03-L04** `List.map` tail-recursion aside placement: the
  aside arrives before the reader has internalised the non-TR
  version; consider moving after the canonical definition.
- [ ] **M03-L06** `count_digits` negative discussion: spec is
  silent on negatives; either define the behaviour or note it as
  an exercise extension.
- [ ] **M04-L04** `fold_left` in JSON depth before introduction:
  the JSON walker uses `fold_left` before the lecture has shown
  it; either forward-define or rewrite with recursion.
- [ ] **M04-L05** type-abbrev half stapled on: the section on
  type abbreviations feels glued onto the variant introduction;
  consider promoting or moving.
- [ ] **M04-L05** `option` intro density: too much packed into
  the first introduction of `option`; consider splitting the
  "intro" from the "idioms".
- [ ] **M05-L02** or-pattern slide: the slide on or-patterns is
  thin compared to its chapter counterpart.
- [ ] **M05-L05** q2 ambiguous answer: one quiz option is
  defensible as correct under a generous reading.
- [ ] **M06-L01** sentence stub: there's a sentence that trails
  off mid-clause; tracked separately as a literal typo / stub.
- [ ] **M06-L04** fold argument-order table: a small reference
  table comparing `fold_left`/`fold_right` argument order would
  help students who keep flipping the signs.
- [ ] **M06-L05** `@@` operator value: the section on `@@` could
  show a case where it materially improves readability vs. just
  saving parens.
- [ ] **M07-L05** SML ALL-CAPS aside: the aside on SML's
  ALL-CAPS constructor convention may be more distracting than
  useful; consider trimming.
- [ ] **M07-L06** functor-as-function hedging: the "a functor is
  a function over modules" framing is hedged in three places;
  pick one phrasing and stick with it.
- [ ] **M08-L01..L02** monad-laws hand-off: the laws are stated
  in L01 and re-stated in L02; either consolidate or make the
  re-statement deliberate (with a forward-reference rationale).
- [ ] **M08-L04** state-monad rewrite count: too many rewrites of
  the same example; consider keeping one canonical version and
  pointing back.
- [ ] **M08-L05** type-annotation pacing: the section moves
  fast; consider one extra worked example or a slow-down
  paragraph.

## M09 (review pass not yet run)

- [ ] **M09-L01..L05** never had a student-perspective review
  pass; an agent is running on this now.

## M10-M12

- [ ] **M10-L01** UB categories slide overlap: the four UB
  categories on the slide overlap with the four bug classes
  enumerated later; either merge or sharpen the distinction.
- [ ] **M10-L02** ROP/heap-spray diagram offset annotation: the
  diagram could use an explicit annotation showing the offset
  arithmetic, not just the high-level shape.
- [ ] **M11-L01** contention/portability one-liner: the
  contention and portability axes get a passing mention but no
  one-liner; either add one or note "deferred to research course".
- [ ] **M11-L01** forward reference to `Modes.Aliased.t`: the
  wrapper is used in L03 without being introduced; add a forward
  pointer at the L01 mode-axis tour.
- [ ] **M11-L03** closure-capture submoding explanation: the
  closure-capture pitfall is shown but the *why* (submoding of
  captured values) is implicit; add a one-paragraph gloss.
- [ ] **M11-L04** in-memory mock note + Girard footnote
  placement: the in-memory Handle mock should carry a "we're
  mocking the filesystem here, real fs comes via Unix" note; the
  Girard footnote (Linear Logic origins) currently sits at the
  end and might be more impactful as a margin aside near the
  first mention of "linearity".
- [ ] **M11-L05** "open exactly once" why-automatic gloss +
  Zerologon citation: the "the compiler made me do this" framing
  needs a sentence on *why* (linearity prevents leaks); the
  Zerologon CVE reference could be a concrete attached citation
  rather than a passing name-drop.
- [ ] **M12-L01** iceberg-as-stage-direction: the iceberg
  metaphor is used both as a slide and a chapter aside; pick one.
- [ ] **M12-L02** ASCII layer diagrams: currently uses prose; an
  ASCII layer diagram for "user code -> library OS -> hypervisor
  -> hardware" would help.
- [ ] **M12-L03** EPT/RVI jargon overload: EPT, RVI, NPT, second-
  level page tables all show up in two paragraphs; either define
  them all up front or pick one term and stick with it.
- [ ] **M12-L04** industrial-users trim + 1.5-2x slower-than-C
  hedge: the industrial-users list is long; the "1.5-2x slower
  than C" claim could use a citation or a sharper hedge.
- [ ] **M12-L05** `Lwt.Infix` introduction + Fiat-Crypto/Coq
  gloss: `Lwt.Infix` appears without being introduced;
  Fiat-Crypto is mentioned without a one-line gloss on Coq.

## Browser smoke verification (pending)

- [ ] **M09-L03** `point_shrink` and `tree_arb` cells use
  `QCheck.Iter.t`, `<+>`, `>|=`, and `let*` inside `QCheck.Gen`.
  Confirm `QCheck.Iter` and `QCheck.Gen.Let_syntax` are exposed
  in the in-browser bundle.
- [ ] **M09-L03** `dag_gen` uses `>>=` on `QCheck` directly;
  verify in scope or needs `let open QCheck.Gen in`.
- [ ] **M09-L04** hash-table module with mutual `let rec ... and ...`
  and mutable state: smoke-test that it parses and runs in the
  in-browser toplevel.
- [ ] **M09-L04** `Queue2`, `Qref`, model-based-test harness
  blocks: smoke-test they parse in `<x-ocaml>`.
- [ ] **M11-L04, M11-L05** never had a browser smoke pass
  (M11-L01..L03 verified earlier in the session).
