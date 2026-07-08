# LLMism audit of the lecture handouts

> **Status (2026-07-08): all 100 findings applied.** Edits are in the
> working tree (uncommitted). Build clean, `dune runtest` green (29 unit
> + 19 integration), the one lengthened slide (M04-L03 "What's next")
> checked at 1280x800 with room to spare, and the recorded M09 lectures
> touched only in off-slide chapter prose. Two mild residuals the audit
> never flagged were left for review: `M01-L02:752` "the elegant Lisp
> dialect", `M01-L02:313` "it genuinely is". This table is retained as
> the record of what changed.

A pass over all 80 lecture files (`lectures/M*-L*.md`) looking for prose
that reads as machine-generated: hype adjectives, appended evaluative
flourishes, contrastive padding, marketing openers, importance
announcements, and reader meta-narration. See `LLMISM-PATTERNS.md` for
the pattern catalogue and the greps that back each category.

**100 findings** across the book. The prose is mostly plain and in the
house voice; there is no `—` em-dash anywhere, no "Let's dive in", no
"Moreover/Furthermore" filler. What remains clusters into a few
repeating tics, listed under *Cross-cutting* below, plus per-lecture
one-offs in the module tables.

## How to read this

- **Severity is a recommendation, not a verdict.** Per the usual audit
  posture: I flag, you pick by number, I apply. Nothing here is edited
  yet.
  - **M** (must-fix, 31): unambiguous house-style violations, chiefly
    the globally-proscribed hype words (`genuinely`, `elegant`,
    `compelling`, `beautiful`) used decoratively, and the canonical
    "worth holding in mind" flourish family. The fix is almost always a
    word- or clause-deletion with no meaning lost.
  - **C** (consider, 69): judgment calls. Borderline adjectives, an
    idiom that may be authorial voice (`under the hood`), a contrastive
    frame whose underlying point is real. You know which of these are
    deliberate.
- **Line numbers are verified** against the current source (grepped from
  the exact quote), not the drafting agents' first pass.
- **Recorded lectures.** M09-L01 through M09-L04 are recorded and their
  slides are frozen. The four M09-L01/L04 findings below all sit in
  **chapter-only prose between slide blocks**, not on any slide, so
  fixing them does not cause slide/video drift. Verify before editing
  anything that turns out to be on a slide.

## Cross-cutting patterns (decide once, apply everywhere)

These are the same tic repeated. Each is one decision.

### 1. `genuinely` as an empty intensifier (17 instances) — recommend delete all

`genuinely` is on the global avoid-list. In every case below it is
decorative emphasis; deleting the word leaves the sentence intact.

`M01-L04:391`, `M02-L01:434`, `M02-L06:541`, `M04-L06:60`,
`M04-L06:353`, `M05-L04:415`, `M08-L01:382`, `M09-L01:138`,
`M09-L05:567`, `M09-L05:1108`, `M09-L07:650`, `M09-L07:664`,
`M09-L07:694`, `M11-L03:73`, `M11-L05:545`, `M12-L01:287`,
`M12-L02:723`.

(Not flagged: `M07-L01:309` and `M07-L02:972`, where `genuinely` carries
the module's real-need-vs-habit contrast. Left alone deliberately.)

### 2. `elegant` / `compelling` / `beautiful` decorative adjectives (7) — recommend delete/replace

Also on the avoid-list; used as aesthetic judgments, not technical
properties. `elegant`: `M05-L03:759`, `M07-L09:48`, `M12-L01:632`.
`compelling`: `M05-L03:893`. `beautiful`/`beautifully`: `M08-L01:40`,
`M09-L01:347`, `M09-L06:887`.

### 3. `under the hood` (8 instances) — sweep to "internally", or keep as voice

This idiom recurs consistently and may be your voice rather than filler.
Every instance just means "internally". One decision: sweep the lot or
keep them. `M03-L02:220`, `M04-L02:338`, `M04-L03:397`, `M07-L01:165`,
`M07-L02:160`, `M07-L03:611`, `M07-L04:488`, `M09-L05:889`.

### 4. The "worth {noting, internalising, keeping, naming, holding, pausing on, carrying}" flourish family (15)

The appended value-announcement Shriram flagged on M02-L01. Each wraps
content that stands on its own; drop the wrapper, keep the content.
`M01-L01:655`, `M01-L02:694`, `M02-L03:106`, `M03-L01:282`,
`M04-L01:364`, `M04-L02:42`, `M04-L02:58`, `M05-L05:597`,
`M11-L02:156`, `M11-L04:159`, `M12-L01:285`, `M12-L01:449`,
`M12-L02:162`, `M12-L02:213`, `M12-L04:692`.

### 5. Importance-announcement lead-ins (7)

"The striking thing:", "The key thing:", "The crux:", "a subtle but
important point", "the single most important sentence" — labels that
pre-announce a point as notable instead of just stating it. Bold or
state the substance, not the label. `M03-L01:352`, `M04-L03:307`,
`M08-L02:188`, `M08-L03:216`, `M08-L06:189`, `M10-L05:471`,
`M12-L02:622`.

### 6. The "X is powerful, but …" contrastive-power frame (4)

`powerful` as rhetorical setup for a trade-off. State the trade-off
directly. `M04-L03:542`, `M05-L04:369`, `M06-L04:702`; plus the
toolkit-hype variant below.

### 7. Toolkit-hype cluster in M06 (6)

M06 repeats "a small but powerful toolkit", "a remarkable amount of…",
"a surprising amount of…", "dramatically more readable". A stock LLM
register; one sweep of the module fixes all. `M06-L01:72`,
`M06-L03:38`, `M06-L05:29`, `M06-L05:45`, `M06-L06:30`, `M06-L06:36`.

### 8. `journey` course-arc cliché (2, both M12)

`M12-L03:1010`, `M12-L04:703`. Replace with "the course" / "Module 12".

## Findings by module

Severity: **M** = recommend fix; **C** = judgment call.

### M01

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M01-L01:103 | C | triad | "build robust, reliable, type-safe software" | drop a near-synonym: "build reliable, type-safe software" |
| M01-L01:200 | C | hype adj | "one of the more profound differences" | drop "profound": "one of the larger differences" |
| M01-L01:655 | C | flourish opener | "It is worth being explicit about scope." | delete; lead with "There are several large topics this course does not cover." |
| M01-L02:228 | C | hype adj | "an excellent appetite-builder" | drop "excellent" |
| M01-L02:690 | M | hype adj | "a real and remarkable property" | "a real property" (or name it) |
| M01-L02:694 | C | flourish opener | "It is worth being clear-eyed about the costs." | delete; lead with "Functional programming is not a free lunch." |
| M01-L03:60 | M | marketing word | "make that play frictionless" | "make that easy" / "keep experimenting cheap" |
| M01-L03:597 | C | importance announcement | "This is a much bigger deal than it might sound." | delete; go straight to the Java/OCaml comparison |
| M01-L03:820 | C | value-announcement | "the punchline of the lecture, and it is worth memorising" | state it: "The operator drives the inference." |
| M01-L04:391 | M | genuinely | "is genuinely useful as a teaching case" | delete "genuinely" |

### M02

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M02-L01:434 | M | genuinely | "operator overloading is genuinely expensive" | delete "genuinely" |
| M02-L03:106 | M | flourish | "They are two questions, both worth answering." | cut the tail: "They are two questions." |
| M02-L04:350 | C | cliché intensifier | "make the parse intent crystal clear" | "make the parse intent clear" |
| M02-L06:541 | M | genuinely | "feel like a genuinely different language" | delete "genuinely" |

### M03

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M03-L01:230 | C | hype adj | "makes something striking explicit" | drop "striking": "makes this explicit" |
| M03-L01:282 | C | flourish | "A small corner of this idea worth naming" | introduce directly: "A related case: a thunk is…" |
| M03-L01:352 | C | importance announcement | "Here is the subtle and important property." | "Here is the subtle part." |
| M03-L01:735 | C | superlative | "one of the most useful tools in functional programming" | state plainly: "used constantly in FP" |
| M03-L02:220 | C | idiom (see X-cut #3) | "written this way under the hood" | drop "under the hood" |
| M03-L03:229 | C | decorative adj | "That is the pleasant form." | "That form reads more directly." (or delete) |

### M04

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M04-L01:364 | C | flourish | "This is worth pausing on, because it is the single largest source" | drop opener; lead with "This is the single largest source of confusion…" |
| M04-L02:42 | C | flourish | "two differences worth internalising up front" | "The semantics differs in two ways:" |
| M04-L02:58 | C | flourish (slide) | "Two semantic twists worth internalising:" | "Two semantic differences:" |
| M04-L02:321 | C | importance announcement | "Functional update is a quiet but important feature." | lead with the content |
| M04-L02:338 | C | idiom | "under the hood, OCaml allocates a new" | drop "under the hood" |
| M04-L03:307 | C | importance announcement | "A subtle but important point:" | drop opener; state the point |
| M04-L03:395 | C | contrastive padding | "not a corner feature you reach for occasionally. They are pervasive" | "Variants are pervasive in OCaml:" |
| M04-L03:397 | C | idiom | "are all variants under the hood." | drop "under the hood" |
| M04-L03:542 | C | hype + contrastive (slide) | "makes ADTs powerful, not just labelled" | "lets ADTs describe unbounded data, not just fixed alternatives" |
| M04-L06:60 | M | genuinely | "That is genuinely it." | "That is it." |
| M04-L06:353 | M | genuinely | "this is genuinely \"no value\"" | delete "genuinely" |

### M05

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M05-L03:759 | M | elegant | "you write quite elegant clauses" | "This lets you write compact clauses:" |
| M05-L03:893 | M | compelling | "The most compelling use of `as`" | "The main use of `as` is with or-patterns." |
| M05-L04:415 | M | genuinely | "the pattern language is genuinely not enough" | delete "genuinely" |
| M05-L04:369 | C | contrastive-power frame | "Guards are powerful, but they are not free." | "Guards extend what you can express, but they are not free." |
| M05-L05:597 | C | flourish (restates rule) | "This is a strong rule worth internalising:" | "The rule:" (or delete; it repeats L566) |
| M05-L06:500 | C | meta-narration | "Now that `eval` is defined, let us run it" | "With `eval` defined, we can run it on a few small expressions." |

### M06

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M06-L01:72 | C | hype (see X-cut #7) | "a remarkable amount of mileage opens up" | drop the flourish; keep the concrete list after the colon |
| M06-L01:551 | C | ornamental metaphor | "a recurring background hum throughout this module" | "we will see it again throughout this module" |
| M06-L03:38 | C | hype (X-cut #7) | "a remarkable amount of everyday list manipulation" | "covers much of everyday list manipulation" (also slide L51) |
| M06-L03:243 | C | empty intensifier | "This matters more than you might initially think" | replace with the concrete sorted/chronological example |
| M06-L03:300 | M | enthusiasm cliché | "one of those \"where was this all my life\" functions" | "`filter_map` is worth knowing well." |
| M06-L03:409 | C | unverifiable claim | "people call OCaml programming \"functional querying\"" | trim to the select-where naming already given |
| M06-L04:702 | C | contrastive-power frame | "Folds are powerful, but power has a cost" | name the trade-off: a non-trivial fold is harder to read than a map/filter chain |
| M06-L04:918 | C | adjective stack (reading) | "a beautifully written paper showing how powerful `fold`" | "shows how general `fold` is. Optional." |
| M06-L05:29 | C | hype (X-cut #7) | "a small but powerful toolkit" | "a small toolkit: map, filter, fold…" |
| M06-L05:45 | C | filler adverb | "dramatically more readable" | drop "dramatically" |
| M06-L06:30 | C | hype (X-cut #7) | "a small but powerful toolkit" | "a small toolkit" |
| M06-L06:36 | C | hype (X-cut #7) | "a surprising amount of list processing" | "enough to express much list processing" |

### M07

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M07-L01:165 | C | idiom (X-cut #3) | "under the hood, they really are three different operations" | "internally, they really are three different operations" |
| M07-L02:160 | C | idiom | "what `ref` uses under the hood." | "…what `ref` uses internally." |
| M07-L03:530 | C | hype adj | "the vast majority of `try … with` clauses" | drop "vast": "most of the `try … with` clauses" |
| M07-L03:611 | C | idiom | "Under the hood, all exception constructors share a single type" | "Internally, all exception constructors share a single type, `exn`." |
| M07-L04:488 | C | idiom | "syntactic sugar; under the hood," | "…syntactic sugar; internally," |
| M07-L09:48 | M | elegant | "small, elegant data structure" | drop "elegant" |

### M08

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M08-L01:40 | M | beautiful | "a beautiful subject but not what we are doing here" | "a deep field in its own right but not what we are doing here" |
| M08-L01:225 | C | "magic" cliché | "is where the magic happens" | say what it does: "is what turns on the sugar." (note: the lecture runs a deliberate "not magic" motif later, so you may want to keep the word) |
| M08-L01:382 | M | genuinely | "`let*` genuinely beats a single `match`" | delete "genuinely" |
| M08-L02:188 | C | importance announcement | "The striking thing: the same `let*`…" | drop the prefix; state it |
| M08-L03:216 | C | importance announcement | "The key thing: the user-facing code never mentions" | drop the prefix |
| M08-L04:209 | C | pacing filler | "A breath before the next bit." | delete |
| M08-L04:341 | C | hype | "it is a massive win" | "the difference is large:" |
| M08-L05:517 | C | appended flourish | "uses them heavily and to great effect" | "uses them heavily." |
| M08-L06:189 | C | importance announcement | "**The crux:** witness list and hlist share one index" | bold the substance, not the label |
| M08-L07:433 | C | overstatement | "together they cover the full spectrum" | "together they cover both compile-time and runtime failures." |
| M08-L07:656 | C | evaluative summary | "This is the lesson of Module 8 distilled:" | "The lesson of Module 8:" (also: prefer a descriptive name over the number) |

### M09  (L01–L04 recorded; findings below are all chapter prose, off-slide)

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M09-L01:138 | M | genuinely | "the list is genuinely impressive" | "Eight modules in, the list is long." |
| M09-L01:347 | M | beautifully | "shows them off beautifully" | "demonstrates them in detail" |
| M09-L01:498 | C | filler intensifier | "The answer is yes, emphatically." | "The answer is yes." |
| M09-L04:460 | C | "shines" | "it shines where the output is messy" | "it is most useful where the output is messy or evolving" |
| M09-L05:567 | M | genuinely | "genuinely hard to write incorrectly" | delete "genuinely" |
| M09-L05:889 | C | idiom opener | "Now we go under the hood." | "Now we look at how the shrinker works." |
| M09-L05:1108 | M | genuinely | "make PBT genuinely productive for working programmers" | delete "genuinely" |
| M09-L05:1274 | C | "shines" | "PBT shines there." | "PBT works well there." |
| M09-L06:887 | M | beautifully | "scales beautifully to any data structure" | "scales to any data structure with a clean interface." |
| M09-L07:650 | M | genuinely | "into something genuinely tested" | delete "genuinely" |
| M09-L07:664 | M | genuinely | "float algebra genuinely breaks" | "float algebra breaks:" |
| M09-L07:694 | M | genuinely | "distributivity genuinely fails outside the finite range" | delete "genuinely" |
| M09-L07:776 | M | theatrical opener | "Now the dramatic part." | delete; start with "Suppose someone refactors `eval`…" |

### M10

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M10-L05:471 | C | importance announcement | "The single most important sentence in the module:" | "The module in one sentence:" |

(M10-L01 through M10-L04: clean.)

### M11

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M11-L01:336 | C | marketing verb | "the key that unlocks safe stack allocation" | "locality is also what makes safe stack allocation possible" |
| M11-L01:695 | C | superlative flourish | "This is the most striking use of the feature." | delete (or "This is a notable use of the feature.") |
| M11-L02:156 | C | flourish opener | "it is worth being clear about what" | "Before the worked example, be clear about what…" |
| M11-L03:73 | M | genuinely | "are genuinely different" | "…but are different." / "…but are distinct." |
| M11-L04:159 | C | flourish | "it is worth meeting both names now" | "so we meet both names now" |
| M11-L04:406 | C | intensifier + idiom | "mode crossing really earns its keep" | "The contention axis is where mode crossing matters most." |
| M11-L05:545 | M | genuinely | "the runtime race is genuinely gone" | "the runtime race is gone" |

(M11-L06, M11-L07: clean.)

### M12

| Line | Sev | Pattern | Quote | Suggested fix |
|---|---|---|---|---|
| M12-L01:86 | C | hedge opener | "the job of an operating system is, at its core, very small to state" | drop "at its core" |
| M12-L01:285 | M | flourish | "Two readings of this curve are worth keeping in mind." | "The curve has two readings." |
| M12-L01:287 | M | genuinely | "which is genuinely useful" | "which is useful." |
| M12-L01:449 | C | flourish + meta | "The mental picture worth carrying out of this lecture" | "The mental picture from this lecture is the monolithic-OS iceberg." |
| M12-L01:632 | M | elegant | "They have elegant designs" | "Their designs are clean, and one (seL4) is formally verified." |
| M12-L02:162 | C | flourish | "Three of them are worth naming explicitly:" | "Three consequences stand out:" |
| M12-L02:213 | C | flourish | "it is worth knowing that it has a history" | fold into the justification |
| M12-L02:622 | C | importance announcement | "One language-level design point deserves its own moment" | "One language-level design point makes 'OCaml as the OS' practical…" |
| M12-L02:723 | M | genuinely | "is genuinely deployable" | "…is deployable;" |
| M12-L03:1008 | C | adjective pile | "a coherent, minimal, fast, auditable platform" | "a small, fast, auditable platform." |
| M12-L03:1010 | C | journey cliché | "That is the journey, end to end." | "That is the course, end to end." |
| M12-L04:692 | M | flourish (canonical) | "It is worth holding both halves of that claim in mind." | "The claim has two halves." |
| M12-L04:703 | C | journey cliché | "That is the journey of Module 12:" | "That is Module 12: from the iceberg…" |

## Bycatch (not LLMisms, noticed in passing)

- **Lecture/module numbers in prose** (against the "descriptive names,
  not numbers" hygiene rule): `M08-L07:656` "the lesson of Module 8",
  `M12-L04:703` "the journey of Module 12". Consider descriptive
  phrasing.

## Files with no findings

M01-L05, M02-L02, M02-L05, M03-L04, M03-L05, M03-L06, M03-L07, M04-L04,
M04-L05, M05-L01, M05-L02, M05-L07, M06-L02, M06-L07, M07-L05, M07-L06,
M07-L07, M07-L08, M07-L10, M08-L08, M09-L02, M09-L03, M09-L08, M10-L01,
M10-L02, M10-L03, M10-L04, M11-L06, M11-L07.
