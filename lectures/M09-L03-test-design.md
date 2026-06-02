---
title: "Designing test cases: black-box and glass-box"
lecture_no: 3
week: 9
duration_target_min: 25
concepts: [test-case design, input-space partitioning, boundary cases, black-box testing, glass-box testing, paths, code coverage, bisect_ppx]
keywords: [OCaml, testing, black-box, glass-box, boundary case, partition, path coverage, code coverage, bisect_ppx]
activity_question: "[max3] compares three ints with nested ifs, giving four paths through the code. Give four inputs [(x, y, z)], one per path. How would you check that your set really is path-complete?"
think_about_this: "A test suite with 100% code coverage runs every expression in the program at least once. Construct (mentally) a program plus a 100%-coverage suite that still misses an obvious bug. What does coverage actually measure?"
reading:
  - title: "Cornell CS3110, Black-box and Glass-box Testing"
    url: https://cs3110.github.io/textbook/chapters/correctness/black_glass_box.html
  - title: "bisect_ppx, the OCaml code-coverage tool"
    url: https://github.com/aantron/bisect_ppx
---

# Designing test cases: black-box and glass-box


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Designing test cases: black-box and glass-box</h2>
<p class="title-slide-label">Module 9 &middot; Lecture 3</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The previous lecture left us with specifications: for every
function, a contract saying what the result is, which inputs are
in bounds, and what gets raised when. A specification tells you
*what* to check. It does not tell you *on which inputs*. And the
input space of even a toy function is so much larger than any
test suite that "which inputs" is the question on which the whole
enterprise turns. A test suite is a sample; this lecture is about
sampling well.

The two techniques have memorable names. *Black-box testing*
chooses inputs by reading the specification and deliberately
ignoring the implementation: the code is a black box with only
its contract visible. *Glass-box testing* chooses inputs by
reading the implementation: the box is transparent, and we aim
tests at every path through the code. They sound like rivals;
they are complements, and the lecture ends with the tool,
`bisect_ppx`, that tells you how far your suite actually reaches.

:::slide

## What this lecture covers

- Why exhaustive testing is hopeless: the size of input spaces.
- **Black-box** design: boundaries and partitions, read from
  the spec.
- **Glass-box** design: paths, read from the implementation.
- Both, applied to data abstractions (producers, consumers,
  the rep invariant).
- **Coverage**: measuring what your suite exercises, with
  `bisect_ppx`.

:::

## You cannot test everything

Take the `Rational` module from the previous lecture. Its `add`
takes two rationals; each rational was made from two `int`s; an
OCaml `int` has 63 bits. So the input space of `add` has
$(2^{63})^4 = 2^{252}$ points. Checking one addition per
nanosecond, a complete sweep takes about $10^{59}$ years. The
universe is about $10^{10}$ years old. Exhaustive testing is not
"expensive"; it is not happening.

So every test suite, no matter how diligent, samples a
vanishingly small fraction of the input space. The question that
separates a good suite from a wasteful one: *do your samples
tell you anything new?* Running `add` on `(3, 4)` and `(5, 6)`
after you have already tested `(1, 2)` and `(1, 3)` tells you
almost nothing: the same code ran, the same way, on inputs that
are not interestingly different. A thousand such tests are a
thousand copies of one test.

:::slide

## You cannot test everything

- `Rational.add` takes two rationals, each two `int`s.
  - Input space: $(2^{63})^4 = 2^{252}$ points.
  - One test per nanosecond: about $10^{59}$ years.
- Every suite is a **sample** of a vast space.
- A thousand similar inputs are a thousand copies of one test.
- The craft: pick inputs that each tell you something **new**.

:::

## Partition the input space

The way out is a structural observation: input spaces are not
uniform. They divide into regions in which the code behaves *the
same way* for every point in the region. Within a region, one
sample is as good as a million; the information is in visiting
*every region*, not in revisiting one.

The regions come from two places, and the two sources give the
two techniques their names. The *specification* draws boundaries:
a requires clause splits "in bounds" from "out of bounds", a
raises clause splits "normal" from "exceptional", phrases like
"the first occurrence" split "occurs once" from "occurs many
times" from "does not occur". Reading region boundaries off the
spec is black-box design. The *implementation* also draws
boundaries: every `if` and every `match` splits the inputs that
go one way from the inputs that go the other. Reading those
boundaries off the code is glass-box design.

When your chosen inputs collectively visit all the interesting
regions, your suite has good *coverage* of the space. That word
will come back, made precise by a tool, at the end of the
lecture.

:::slide

## Partition the input space

- Input spaces split into **regions** of same-behaviour.
  - One sample per region is as good as a million.
- Two sources of region boundaries:
  - the **specification**: requires / raises clauses, "first
    occurrence", "empty" vs "non-empty" → black-box design.
  - the **implementation**: every `if`, every `match` arm
    → glass-box design.
- Good **coverage** = your samples visit every region.

:::

## Black-box design: boundaries and typical inputs

Black-box testing reads only the contract. The discipline: walk
through the specification clause by clause, and for each clause
ask "what is the *typical* case here, and where are the
*boundaries*?" Boundary cases (also called corner or edge cases)
are where bugs concentrate, because they are where the
implementer's mental picture was fuzziest: the empty list, the
single element, the value exactly at a threshold, the input that
makes the answer zero.

Here is a worked example. Specification:

```text
(** [longest_streak xs] is the length of the longest run of
    equal adjacent elements of [xs]. It is [0] for the empty
    list. Example: [longest_streak [4; 4; 7] = 2]. *)
val longest_streak : int list -> int
```

Reading the spec, not any code, here is a black-box case list:

:::slide

## Black-box example: `longest_streak`

"the length of the longest run of equal adjacent elements;
0 for the empty list"

| Region | Input | Expected |
| --- | --- | --- |
| empty (spec says!) | `[]` | `0` |
| one element | `[5]` | `1` |
| all equal | `[7; 7; 7]` | `3` |
| all distinct | `[1; 2; 3]` | `1` |
| run at the start | `[5; 5; 1; 2]` | `2` |
| run at the end | `[1; 2; 5; 5]` | `2` |
| tied runs | `[3; 3; 8; 8]` | `2` |
| equal but not adjacent | `[4; 1; 4; 1]` | `1` |

:::

Every row earns its place by being *behaviourally different*
from the others. The empty list is there because the spec
explicitly promises something about it (and if it had not, the
attempt to write this row would have exposed the spec hole, a
free benefit of black-box design: it reviews the spec while it
tests the code). "Equal but not adjacent" is there because the
word *adjacent* in the spec is load-bearing, and an implementer
who skimmed it would count `[4; 1; 4; 1]` as a streak of two.

The case list was designed without an implementation. Now any
implementation must face it. Here is one, with the whole table
as assertions:

```ocaml
let longest_streak xs =
  let rec go prev run best = function
    | [] -> best
    | x :: rest ->
        let run = if prev = Some x then run + 1 else 1 in
        go (Some x) run (max best run) rest
  in
  go None 0 0 xs

let () =
  assert (longest_streak [] = 0);
  assert (longest_streak [5] = 1);
  assert (longest_streak [7; 7; 7] = 3);
  assert (longest_streak [1; 2; 3] = 1);
  assert (longest_streak [5; 5; 1; 2] = 2);
  assert (longest_streak [1; 2; 5; 5] = 2);
  assert (longest_streak [3; 3; 8; 8] = 2);
  assert (longest_streak [4; 1; 4; 1] = 1);
  print_endline "black-box suite passed"
```

A useful property of this suite: it survives a complete rewrite
of `longest_streak`. The cases were derived from the contract,
so any implementation of the same contract should pass them,
and the suite can even be written *before* the implementation
exists. Tests that depend only on the spec are the most durable
tests you will write.

## Paths through the spec

When a specification has a requires clause, or otherwise
describes different treatments for different inputs, the
described conditions combine, and each *combination* is a region
deserving a test. Consider:

```text
(** [pad n c s] is [s], extended on the left with copies of
    [c] to length [n]; [s] itself if [String.length s >= n].
    Requires: [n >= 0]. *)
val pad : int -> char -> string -> string
```

Two conditions structure this spec: is `n` greater than the
length of `s`, or not; and is `s` empty, or not. Two binary
conditions give four "paths through the specification", and the
boundary `n = String.length s` rides along:

:::slide

## Paths through the spec: `pad`

"extend [s] on the left with [c] to length [n]; [s] itself
if it is already long enough. Requires: [n >= 0]."

| `n` vs `length s` | `s` | Input | Expected |
| --- | --- | --- | --- |
| `n >` | non-empty | `pad 5 '0' "42"` | `"00042"` |
| `n >` | empty | `pad 3 'x' ""` | `"xxx"` |
| `n <` | non-empty | `pad 2 '0' "1234"` | `"1234"` |
| `n =` (boundary) | non-empty | `pad 4 '0' "1234"` | `"1234"` |
| `n = 0` (boundary) | empty | `pad 0 'x' ""` | `""` |

- Conditions in the spec **combine**; test the combinations.
- The requires clause (`n >= 0`) marks inputs *not* to test.

:::

Note the last line of the slide. `pad (-3) 'x' "hi"` is not a
test case, because the contract promises nothing there. Writing
a test for it means inventing a behaviour the spec never
promised, and your test suite then forbids implementations the
spec allows. Requires clauses tell you where your test suite's
authority *ends*.

## Black-box design for data abstractions

A data abstraction needs one more black-box idea, because its
operations interact through hidden state. Sort the operations
into *producers*, which return values of the abstract type
(`Rational.make`, `add`, `div`), and *consumers*, which take
them (`add`, `div`, `equal`, `to_string`; note an operation can
be both). A value reaching a consumer always came from some
producer, and bugs hide in the *pairing*: `to_string` may be
fine on everything `make` produces and wrong on what `div`
produces (an un-normalised pair, say). One operation tested in
isolation never sees the bug.

So the black-box recipe for an abstraction: test every consumer
on values from every producer path that can reach it.

:::slide

## Data abstractions: producers × consumers

- **Producers** return the abstract type: `make`, `add`, `div`.
- **Consumers** take it: `add`, `div`, `equal`, `to_string`.
- Bugs hide in the **pairing**:
  - `to_string` fine on `make`'s output,
  - wrong on `div`'s (an un-normalised pair).
- Recipe: every consumer × every producer path.
  - `equal` on two `make`s, on `make` vs `add`, on `div`
    results.
  - `to_string` on `make`, on `add`, on `div` results.
  - and the raises path: `div` by the zero rational.

:::

## Glass-box design: cover the code's paths

Now turn the box transparent. Glass-box testing reads the
implementation and asks: which inputs would make execution flow
down each *path* through the code? Recall `max3` from the
opening lecture:

```ocaml
let max3 x y z =
  if x > y then
    if x > z then x else z
  else
    if y > z then y else z
```

Two nested conditionals; four ways through; each way returns a
different expression. Four representative inputs, one per path:

```ocaml
let () =
  assert (max3 9 4 2 = 9);  (* x > y, x > z: returns x *)
  assert (max3 5 3 8 = 8);  (* x > y, x <= z: returns z *)
  assert (max3 2 6 1 = 6);  (* x <= y, y > z: returns y *)
  assert (max3 2 6 9 = 9);  (* x <= y, y <= z: returns z *)
  print_endline "path-complete for max3"
```

A test set that makes every path run is *path-complete*. The
glass-box checklist generalises beyond `if`: every arm of every
`match` (you have known since the pattern-matching module that
the compiler warns when your *code* misses a case; glass-box
testing is the analogous discipline for your *tests*), the base
case and the recursive case of every recursive function, and
every point that can raise.

:::slide

## Glass-box: cover the implementation's paths

```ocaml
let max3 x y z =
  if x > y then
    if x > z then x else z
  else
    if y > z then y else z
```

- Four paths; one representative input each:
  - `max3 9 4 2 = 9` (returns `x`)
  - `max3 5 3 8 = 8` (returns first `z`)
  - `max3 2 6 1 = 6` (returns `y`)
  - `max3 2 6 9 = 9` (returns second `z`)
- The checklist: every `if` branch, every `match` arm, base +
  recursive cases, every raise point.

:::

## Path-complete is not correct

Glass-box testing has a blind spot, and it is exactly the
pitfall the opening lecture warned about: tests derived from
the implementation confirm that the code does what the code
does. Consider the laziest possible `max3`:

```ocaml
let bad_max3 x y z = x

let _ = bad_max3 9 4 2  (* = 9 *)
```

This implementation has exactly *one* path, so the single test
`bad_max3 9 4 2 = 9` is path-complete. Every expression ran;
every test passed; the function is wrong on two-thirds of its
input space. Path-completeness measured against a wrong
implementation certifies the wrong implementation.

The cure is to keep both lenses. Black-box cases for `max3`
would include "maximum in each position", and
`bad_max3 2 6 1 = 6` fails immediately. Glass-box tells you
your suite has reached all the code that exists; black-box
tells you the code that exists does what was promised. Neither
substitutes for the other.

:::slide

## Path-complete is not correct

```ocaml
let bad_max3 x y z = x
```

- One path, so ONE test is path-complete:
  - `bad_max3 9 4 2 = 9` passes. Suite green.
- Wrong on two-thirds of the input space.
- Glass-box: "my tests reached all the code."
- Black-box: "the code does what was promised."
- You need **both** lenses; neither substitutes.

:::

## Glass-box and the rep invariant

For data abstractions, the previous lecture's machinery joins
in. The *representation invariant* is a boundary-drawing device
of the best kind: it was written by the implementer to describe
exactly which concrete values are delicate.

Take the canonical-form `Rational_canon`: its RI demands a
positive denominator and lowest terms, and its `norm` helper
has distinct things to do depending on the input. Each is a
glass-box region: a negative denominator (the sign must
migrate to the numerator), a common factor (the gcd division
must fire), a zero numerator (`gcd 0 q` is `q`; does
normalising `0/7` produce `0/1`?). And `rep_ok` itself gives
the suite teeth: with checks on, a glass-box suite that drives
every operation over these regions will trip the invariant the
moment any path produces an illegal value.

:::slide

## Glass-box and the rep invariant

- The RI marks exactly the **delicate** concrete values.
- Each clause of the RI, each path of `norm`, is a region:
  - negative denominator: sign must migrate.
  - common factor: the gcd division must fire.
  - zero numerator: does `0/7` normalise to `0/1`?
- Drive every operation across these regions with `rep_ok`
  on: the invariant check turns a silent corruption into a
  failing test.

:::

## Measuring coverage: `bisect_ppx`

Glass-box design promises "a test for every path", but on a
real codebase, who keeps score? You cannot eyeball a
twenty-module project and know which expressions your suite
never ran. This is mechanisable, and the OCaml tool for it is
[`bisect_ppx`](https://github.com/aantron/bisect_ppx).

**Terminal, not browser.** Everything else in this lecture runs
in this page's cells. Coverage is the exception: `bisect_ppx`
works by *instrumenting your code at compile time*, so it needs
a real `dune` project and a shell. You can reproduce the
walkthrough below on your own machine, or in the terminal
embedded after it: a real Linux shell with `dune` and
`bisect_ppx` preinstalled, running inside this page.

The workflow has three steps. First, enable instrumentation for
the executable under test in the `dune` file:

```text
(executable
 (name test_streak)
 (instrumentation (backend bisect_ppx)))
```

Second, run the tests with instrumentation switched on. The
instrumented program records, for every expression, whether it
was ever evaluated, and dumps the record to a `.coverage` file
on exit:

```text
$ dune exec --instrument-with bisect_ppx ./test_streak.exe
black-box suite passed
$ ls
... bisect0001.coverage ...
```

Third, render the report:

```text
$ bisect-ppx-report html
$ open _coverage/index.html
```

The report shows your source with each expression coloured:
green for "ran under the suite", red for "never ran". Red is a
glass-box to-do list. The loop writes itself: run the suite,
open the report, find red code, ask "what input reaches this?",
add that case, re-run. (Delete the old `.coverage` files
between runs, or the report accumulates stale data.) Stop when
the red that remains is code you *decided* not to test, rather
than code you forgot.

### Try it: coverage in your browser

The terminal below boots a small Linux machine in this page and
starts in a ten-pin bowling scorer project whose library is
already instrumentation-enabled. Run its suite under coverage
and ask for the score:

- `dune runtest --instrument-with bisect_ppx` (this project's
  instrumented build comes pre-built in the image, so expect
  seconds; instrumenting a project from scratch, say `~/morse`,
  also links the instrumentation tool itself, which takes a
  minute or two).
- `bisect-ppx-report summary`: what fraction of the scorer did
  the tests reach?

The uncovered expressions are the scorer's input-validation
branches: the suite never feeds it an invalid game. That is
exactly the glass-box to-do list this section is about: decide
whether those branches deserve tests, write them in
`test/test_bowling.ml`, and watch the percentage move. For the
green-and-red view, run `bisect-ppx-report html && sync` and
then press the terminal's *coverage report* button: the page
lifts the report straight out of the VM's filesystem into a new
browser tab (the `sync` makes sure the freshly written report
has actually reached that filesystem).

:::vm-terminal dir=/root/bowling
:::

:::slide

## Measuring coverage: `bisect_ppx`

- Terminal, not browser: instrumentation is a build step.

```text
(executable
 (name test_streak)
 (instrumentation (backend bisect_ppx)))

$ dune exec --instrument-with bisect_ppx ./test_streak.exe
$ bisect-ppx-report html
$ open _coverage/index.html
```

- The report paints each expression:
  - **green**: ran under the suite.
  - **red**: never ran. A glass-box to-do list.

:::

:::slide

## The coverage loop

1. Run the suite with instrumentation.
2. Open the report; find **red** (unexecuted) code.
3. Ask: "what input reaches this expression?"
   - That question *is* glass-box design.
4. Add the case; delete old `.coverage` files; re-run.
5. Stop when the remaining red is a decision, not an
   accident.
- Coverage is a **signal**, not a goal: 100% green proves
  every expression ran, not that any answer was right.

:::

The last bullet deserves its own sentence, because teams really
do fall into this trap. Coverage measures *execution*, not
*checking*: a suite that calls every function and asserts
nothing is 100% green and 0% useful. `bad_max3` reached 100%
coverage with one vacuous-looking test. Chase regions and
boundaries; let the percentage follow.

## Black-box and glass-box, side by side

:::slide

## Black-box vs glass-box

| | Black-box | Glass-box |
| --- | --- | --- |
| Reads | the spec | the implementation |
| Finds | spec holes, wrong behaviour | unexercised code |
| Survives a rewrite? | yes | no (paths change) |
| Can precede the code? | yes | no |
| Blind spot | unreached code | wrong code, fully reached |

- Write black-box cases first; they outlive the implementation.
- Then glass-box (coverage report) to find what they missed.

:::

The order matters and is worth making a habit: black-box first,
from the spec, before or while the code is written; then a
coverage pass to find the paths the spec-derived cases never
reached. The next two lectures mechanise exactly this pairing:
the unit-testing framework gives the case lists a permanent,
runnable home, and property-based testing automates "many
inputs per region" beyond what any hand-written table achieves.

## Activity

:::quiz mcq id=M09-L03-q1
A colleague specifies: "`[longest_streak xs]` is the length of
the longest run of equal adjacent elements of `[xs]`," and
stops there. Which black-box test case, attempted against this
spec, *exposes a hole in the specification itself*?

- [ ] `longest_streak [7; 7; 7]`
- [ ] `longest_streak [4; 1; 4; 1]`
- [x] `longest_streak []`
- [ ] `longest_streak [3; 3; 8; 8]`

**Why:** to write the expected output for `longest_streak []`
you must know what the function promises on the empty list,
and this spec does not say. (Zero? An exception? The spec is
silent, so client and implementer may decide differently.)
The other three inputs have answers derivable from the spec as
given: 3, 1, and 2. Boundary-case thinking reviews the
specification for free: the case you cannot fill in is a
clause the spec forgot.
:::

:::quiz mcq id=M09-L03-q2
How many test cases does a *path-complete* suite need for the
following function?

```text
let categorise n =
  if n < 0 then "negative"
  else if n = 0 then "zero"
  else if n < 10 then "small"
  else "big"
```

- [ ] 2
- [ ] 3
- [x] 4
- [ ] 8

**Why:** a chain of `else if`s is *linear*, not a tree of
independent decisions: execution takes exactly one of the four
exits ("negative", "zero", "small", "big"), so four inputs,
one per exit (say `-5`, `0`, `7`, `99`), are path-complete.
The distractor 8 comes from treating the three conditions as
independent booleans ($2^3$); they are not, because reaching a
later test implies every earlier one was false. And remember
the lecture's warning: these four cases prove every path
*ran*, not that every path is *right*.
:::

:::quiz code id=M09-L03-q3
`max3` has four paths (two nested conditionals). Provide four
inputs, one per path, as a list of `(x, y, z)` triples. The
hidden tests instrument `max3`'s decisions and check that your
set is path-complete.

```ocaml
(* One triple per path through max3, in any order. *)
let my_cases : (int * int * int) list = []
```

```ocaml skip
let path (x, y, z) =
  if x > y then (if x > z then 1 else 2)
  else if y > z then 3
  else 4

let () =
  assert (List.length my_cases >= 4);
  let covered =
    List.sort_uniq compare (List.map path my_cases)
  in
  assert (covered = [1; 2; 3; 4]);
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```ocaml
let my_cases = [ (9, 4, 2); (5, 3, 8); (2, 6, 1); (2, 6, 9) ]
```

Reading off the structure of `max3`: `(9, 4, 2)` takes
`x > y` then `x > z` (returns `x`); `(5, 3, 8)` takes `x > y`
then `x <= z` (returns `z`); `(2, 6, 1)` takes `x <= y` then
`y > z` (returns `y`); `(2, 6, 9)` takes `x <= y` then
`y <= z` (returns `z` again, by the other route). The check
"did my set visit all four paths" is exactly what a coverage
tool mechanises; here the hidden test plays the role of
`bisect_ppx` by computing each input's path directly.

:::

## Common pitfalls

**Pitfall 1: testing only typical inputs.** The suite full of
"nice" three-element lists. Bugs live at the boundaries: empty,
singleton, equal elements, values at thresholds, `max_int`. If
no test in your suite makes the answer zero or empty, your
boundaries are untested.

**Pitfall 2: deriving every case from the implementation.** Pure
glass-box design inherits the implementer's blind spots: the
case the code forgot has no path, so no path-derived test covers
it. (`longest_streak` written without the "not adjacent" insight
contains no code for it to cover.) Spec first, code second.

**Pitfall 3: testing inside the requires clause.** A case for
`pad (-3) 'x' "hi"` asserts behaviour the contract never
promised. The suite now fails implementations the spec permits.
Where the contract is silent, the suite must be too.

**Pitfall 4: chasing the coverage percentage.** Coverage
measures what *ran*, not what was *checked*. Adding
assertion-free calls to push 87% to 100% produces a greener
report and no new knowledge. Treat red code as a question
("what input reaches this?"), never the percentage as a target.

**Pitfall 5: one operation at a time, for abstractions.** A
suite that tests `make` thoroughly, `add` thoroughly, and
`to_string` thoroughly, each in isolation, never observes
`to_string` *of* an `add` result. Pair producers with
consumers; the bugs are in the pairings.

:::slide

## Common pitfalls

1. **Only typical inputs**: boundaries (empty, equal, at the
   threshold) are where bugs live.
2. **All cases from the code**: the case the code forgot has
   no path to cover. Spec first.
3. **Testing inside the requires clause**: where the contract
   is silent, the suite must be too.
4. **Chasing the percentage**: coverage measures *ran*, not
   *checked*.
5. **Operations in isolation**: test producer × consumer
   pairings.

:::

## What's next

The case tables in this lecture ran as bare `assert`s: fine for
a page, unworkable for a project. A failing `assert` stops at
the first failure, reports a line number and nothing else, and
offers no way to run one suite of many. The
[next lecture](M09-L04-unit-testing.html) gives the designed
cases a proper home: OUnit2, where each row of a case table
becomes a named test case, failures report expected-versus-got,
and the whole suite runs from `dune`. The lecture after that
mechanises this one's *other* half: property-based testing
generates hundreds of inputs per region instead of the one
representative we picked by hand.

:::slide

## What's next

- Our case tables ran as bare `assert`s:
  - first failure stops everything; no names, no reporting.
- L4: **OUnit2**. Each table row becomes a named case;
  failures report expected vs got; suites run under `dune`.
- L5: **property-based testing**. Hundreds of generated
  inputs per region, not one hand-picked representative.

:::

## Reading

- **Cornell CS3110**, *Black-box and Glass-box Testing*:
  <https://cs3110.github.io/textbook/chapters/correctness/black_glass_box.html>
- **bisect_ppx**, README and usage documentation:
  <https://github.com/aantron/bisect_ppx>
- **Cornell CS3110**, *Specifications* (the source of the
  clauses this lecture reads boundaries from):
  <https://cs3110.github.io/textbook/chapters/correctness/specifications.html>

## Sources

This lecture's prose, worked examples, and quizzes are original
to this course. Cornell CS3110's chapter on black-box and
glass-box testing is the primary conceptual source for the
partition/boundary/path vocabulary and the bisect_ppx workflow;
its prose is CC BY-NC-ND licensed and has not been derivatively
reused. The `max3` function is a stock teaching example shared
with CS3110's chapter (and with this module's opening lecture);
`longest_streak`, `pad`, the producer/consumer grid on the
rational-number abstraction, and all quizzes are this course's
own. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
