# M06–M07 Cross-Course Audit Triage

**Audit date**: 2026-05-25  
**Scope**: M06 (6 lectures) + M07 (9 lectures), applying M05 lens (cold opens, bullets, function invocations, forward concepts, activity freshness, below-floor slides)  
**Constraint**: READ-ONLY. Triage only; no fixes applied.

---

## Module 06: Higher-order programming (6 lectures, 79 slides, ~2.0 h video)

### M06-L01 Functions, revisited (13 slides)

- **grandfathered**: Cold open present; "From M3, leaned on" slide establishes framing. ✓
- **grandfathered**: Slides use bullets exclusively; no prose violations. ✓
- **grandfathered**: `twice` defined with invocations on same slide; `make_adder` same. ✓
- **grandfathered**: No forward concepts (refs, exceptions, modules, monads, GADTs, effects). ✓
- **grandfathered**: Activity (`twice` function) fresh; not worked through prior. ✓

### M06-L02 `map`: transform every element (14 slides)

- **grandfathered**: Cold open present; "This lecture: `map`" establishes scope. ✓
- **grandfathered**: Slides use bullets; examples show input–output pairs. ✓
- **grandfathered**: `map` defined with invocations; `zip_with` activity is fresh (not in lecture body). ✓
- **consider**: Tail-recursion digression (non-tail-recursive vs accumulator version) is pedagogically valuable but could be deferred or separated into a distinct "Advanced" subsection to clarify what is required for all readers. Current placement is inline with the main definition discussion.
- **grandfathered**: No forward concepts. ✓

### M06-L03 `filter`: keep what passes the predicate (12 slides)

- **grandfathered**: Cold open present; "This lecture: `filter`" establishes scope. ✓
- **grandfathered**: Slides use bullets consistently. ✓
- **grandfathered**: `filter` defined with invocations; `unique` activity is fresh. ✓
- **must-fix**: **Below floor (12 slides / 18 min).** RECORDING-ESTIMATES lists M06-L03 at 12 slides / 18 min, below the 20-min NPTEL floor. Recommend growing by ~3 slides: add a worked example pairing `filter` + `map` (e.g. "extract and transform book titles"), explicit slide on `filter_map` vs `filter + map` trade-offs, and comparison table (length, type, order preservation). Sketch: 15 slides / 23 min.
- **grandfathered**: No forward concepts. ✓

### M06-L04 `fold`: reduce a list to a single value (14 slides)

- **grandfathered**: Cold open present; "This lecture: `fold`" establishes scope. ✓
- **grandfathered**: Slides use bullets; code cells show input/output. ✓
- **grandfathered**: `fold_right` defined with invocations; no reuse in activity. ✓
- **grandfathered**: No forward concepts. ✓
- **consider**: The "When fold is overkill" section (around line 548) is cut off mid-sentence in the current draft. Complete this section to clarify the threshold between reaching for `fold` vs simpler tools.

### M06-L05 Function composition and pipelines (13 slides)

- **grandfathered**: Cold open present; "This lecture: pipelines and composition" establishes scope. ✓
- **grandfathered**: Slides use bullets; no prose inside :::slide fences. ✓
- **grandfathered**: `compose` defined with invocation on same slide; activity is fresh. ✓
- **grandfathered**: No forward concepts. ✓

### M06-L06 Tutorial: rebuild parts of `List` (13 slides)

- **grandfathered**: Cold open present; "What this tutorial does" framing slide. ✓
- **grandfathered**: Slides use bullets; tutorial structure is clear. ✓
- **grandfathered**: Tutorial exercises are novel implementations, not lecture-worked examples. ✓
- **grandfathered**: No forward concepts. ✓

---

## Module 07: Side effects and modular programming (9 lectures, 125 slides, ~3.2 h video)

### M07-L01 Mutable references (15 slides)

- **grandfathered**: Cold open present; "Six modules without mutation" establishes context. ✓
- **grandfathered**: Slides use bullets exclusively. ✓
- **grandfathered**: `counter` defined with `!` and `:=` invocations on same slides. ✓
- **grandfathered**: No forward concepts (exceptions, modules, monads not taught here). ✓
- **grandfathered**: Activity (`make_counter` closure with counter) is fresh. ✓

### M07-L02 Mutable records and arrays (14 slides)

- **grandfathered**: Cold open present; "This lecture: arrays and mutation" framing. ✓
- **grandfathered**: Slides use bullets; examples are clear. ✓
- **grandfathered**: No forward concepts. ✓
- **grandfathered**: Activity (mutation over array accumulator) is fresh. ✓

### M07-L03 Exceptions (12 slides)

- **grandfathered**: Cold open present; "This lecture: exceptions" establishes scope. ✓
- **grandfathered**: Slides use bullets. ✓
- **grandfathered**: `raise`, `try...with` defined with invocations on same/adjacent slides. ✓
- **must-fix**: **Below floor (12 slides / 18 min).** RECORDING-ESTIMATES lists M07-L03 at 12 slides / 18 min, below 20-min floor. Recommend growing by ~2–3 slides: add a comparison table (exceptions vs option vs result—when to pick each), a worked example showing exception chain propagation, or a discussion of the "exception cost" (hidden in type signature). Sketch: 14–15 slides / 21–23 min.
- **consider**: The "When to choose exceptions vs option/result" section could be expanded into a dedicated slide with concrete decision tree (Is the caller expected to handle this? Is this a rare error or normal control flow?).

### M07-L04 Streams and laziness (13 slides)

- **grandfathered**: Cold open present; "This lecture: streams and laziness" framing. ✓
- **grandfathered**: Slides use bullets; recursive lazy definition slide is clear. ✓
- **grandfathered**: No forward concepts. ✓
- **grandfathered**: Activity (`sieve` for primes) is fresh. ✓

### M07-L05 Memoization (12 slides)

- **grandfathered**: Cold open present; "This lecture: memoization" framing. ✓
- **grandfathered**: Slides use bullets. ✓
- **grandfathered**: No forward concepts. ✓
- **must-fix**: **Below floor (12 slides / 18 min).** RECORDING-ESTIMATES lists M07-L05 at 12 slides / 18 min, below 20-min floor. Recommend growing by ~2–3 slides: benchmark a memoised Fibonacci against the naive version (with timing), add a slide on the trade-off (space for time), or show a cache-miss example. This would concretize the "why memoization matters" motivation. Sketch: 14–15 slides / 21–23 min.

### M07-L06 Module basics (15 slides)

- **grandfathered**: Cold open present; "This lecture: module basics" framing. ✓
- **grandfathered**: Slides use bullets; examples are clear. ✓
- **grandfathered**: No forward concepts. ✓
- **grandfathered**: Activity is fresh. ✓

### M07-L07 Module signatures (16 slides)

- **grandfathered**: Cold open present; "This lecture: module signatures" framing. ✓
- **grandfathered**: Slides use bullets; signature examples are concise. ✓
- **grandfathered**: No forward concepts. ✓
- **grandfathered**: Activity is fresh. ✓

### M07-L08 Functors (13 slides)

- **grandfathered**: Cold open present; "This lecture: functors" framing. ✓
- **grandfathered**: Slides use bullets; motivation ("Why we need them") is clear. ✓
- **grandfathered**: No forward concepts. ✓
- **grandfathered**: Activity is fresh. ✓

### M07-L09 Tutorial: a queue functor (15 slides)

- **grandfathered**: Cold open present; "What this tutorial does" framing. ✓
- **grandfathered**: Slides use bullets; tutorial structure is clear. ✓
- **grandfathered**: No forward concepts. ✓
- **grandfathered**: Activity (custom queue implementation) is fresh. ✓

---

## Summary

**Must-fix count:**
- M06: 0 items
- M07: 2 items (below-floor slides)
- **Total must-fix: 2 items**

**Below-floor lectures (20-min NPTEL minimum):**
- M06-L03 (`filter`): 12 slides / 18 min → recommend 15 slides / 23 min (+3 slides)
- M07-L03 (`exceptions`): 12 slides / 18 min → recommend 14–15 slides / 21–23 min (+2–3 slides)
- M07-L05 (`memoization`): 12 slides / 18 min → recommend 14–15 slides / 21–23 min (+2–3 slides)

**Cold-open compliance:** All 15 lectures ✓  
**Activity freshness:** All 15 lectures ✓  
**Forward concepts:** No violations (M06 mentions modules/functors only in forward pointers; M07 does not teach monads/GADTs/effects) ✓  
**Bullets-not-prose:** All lectures ✓

**Estimated polish effort (must-fix only):** ~3–4 author-hours total.
- M06-L03: +0.5 h (add 3 worked slides with explanatory prose)
- M07-L03: +0.75 h (add decision table + worked example)
- M07-L05: +0.75 h (add benchmarked Fib + trade-off discussion)

**Notes:**
- No cold-open violations detected (all lectures have title → framing before content).
- No activity-reuse violations detected (activities ask for fresh functions not worked in lecture body).
- Consider-level items are pedagogical refinements, not compliance issues.
- M06-L02 tail-recursion discussion is valuable; placement is acceptable.
- M06-L04 "When fold is overkill" section appears incomplete in the draft.

