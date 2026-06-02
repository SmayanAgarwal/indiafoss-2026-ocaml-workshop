---
title: "Property-based testing with QCheck"
lecture_no: 5
week: 9
duration_target_min: 35
concepts: [property-based testing, QCheck, generators, shrinking, properties, invariants, equational reasoning, custom arbitraries, input space, balanced trees]
keywords: [OCaml, QCheck, property-based testing, PBT, QuickCheck, generators, shrinking, counterexample, sorted array, balanced BST, red-black tree, custom arbitrary, distribution, input space]
activity_question: "Suppose someone tells you their implementation of List.rev passes the property [rev (rev xs) = xs] on 1000 random inputs. Is the implementation necessarily correct? What other properties would you want to check before you believe them?"
think_about_this: "Why is property-based testing more useful in a functional language than in an imperative one? What is it about purity and equational reasoning that makes properties easier to *state*, never mind check?"
reading:
  - title: "QCheck on GitHub (README, tutorial, API)"
    url: https://github.com/c-cube/qcheck
  - title: "QCheck API documentation"
    url: https://c-cube.github.io/qcheck/
  - title: "Hughes, QuickCheck: A Lightweight Tool for Random Testing of Haskell Programs (2000)"
    url: https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/quick.pdf
---

# Property-based testing with QCheck


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Property-based testing with QCheck</h2>
<p class="title-slide-label">Module 9 &middot; Lecture 5</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

[Lecture 4](M09-L04-unit-testing.html) gave you OUnit2 and a habit
for it: pick an input, write down its expected output, compare,
report. The hand-written assertions in `test_lifo_three` exercise
a stack on three specific inputs out of the infinite number of
ways someone might use a stack. The five `max3` assertions in
[L1](M09-L01-why-test-typed-code.html#a-small-concrete-demonstration)
exercise the function on five specific triples out of the trillions
of `int * int * int` values.

That gap is the topic of this lecture. There is a fundamental
limit to unit testing: *you can only check the cases you thought
of.* A bug that only fires on an input you did not consider sits
quietly in the code, passing your test suite, until a user finds
it.

Property-based testing closes that gap by inverting the
relationship between the test author and the inputs. Instead of
writing down a list of (input, expected output) pairs, you write
down a *property*: a relationship between inputs and outputs that
should hold *for any* input. A property-based testing library
then *generates* inputs and checks the property on each one.
A few hundred random inputs cost you almost nothing and exercise
corners you would never have written by hand.

This lecture is the introduction to the OCaml flavour of that
idea: the [QCheck](https://github.com/c-cube/qcheck) library.

:::slide

## What this lecture covers

- The **limit of unit testing**: you only check the cases you
  thought of.
- **Property-based testing (PBT)**: write a property, let the
  library generate inputs.
- **QCheck**, OCaml's PBT library: generators, properties,
  shrinking, statistics.
- Worked examples on **`List.rev`** and **`List.sort`**.
- Why **functional programming and PBT fit together** especially
  well.

:::

## The limit of hand-written tests

Let us sharpen the problem. We have a function:

```ocaml
let rec rev = function
  | [] -> []
  | x :: xs -> rev xs @ [x]
```

We write a unit-test suite for it:

```ocaml
let () =
  assert (rev [] = []);
  assert (rev [1] = [1]);
  assert (rev [1; 2] = [2; 1]);
  assert (rev [1; 2; 3] = [3; 2; 1]);
  print_endline "rev tests passed"
```

Four assertions. The function passes all four. Are we done?

Maybe. The implementation is right. But we tested it on four
inputs whose answer was obvious to write by hand. We did not test
it on:

- a list of length 100,
- a list with duplicates,
- a list of strings (instead of `int`s),
- a list where every element is the same,
- a list whose elements are pairs.

In each of these, the function would have worked, but we did not
*check*. And if the implementation had a subtle bug, that bug
might only fire on, say, lists of length 100 or more (a recursion-
depth issue, perhaps), or on lists with duplicates (a hash-set
bug). Our four-case test suite would not catch it.

The right reaction is not "write fifty more cases." That is
exhausting and quickly hits diminishing returns: there are
infinitely many lists, and you do not know which finite subset is
representative. The right reaction is to step back and ask: what
should *be* true of `rev`, no matter what list we apply it to?
And then let a machine generate the lists.

:::slide

## The limit of unit testing

```ocaml
let () =
  assert (rev [] = []);
  assert (rev [1] = [1]);
  assert (rev [1; 2] = [2; 1]);
  assert (rev [1; 2; 3] = [3; 2; 1])
```

- Four cases. All pass.
- Did we check length 100? Duplicates? `string list`? Pairs?
- The right step is not "write fifty more cases."
- The right step is: state a *property* and let the library
  generate inputs.

:::

## Properties: what should be true of `rev`?

A *property* is a statement that should hold for *every* input of
some shape. For `rev`, three obvious properties:

1. **Involution**: `rev (rev xs) = xs` for every list `xs`.
2. **Length preservation**: `List.length (rev xs) = List.length xs`.
3. **Permutation**: the multiset of elements is unchanged.

The first is the most striking. It captures something that has to
be true *by the meaning* of `rev`: reversing twice gets you back.
Notice that we did not write down *what* `rev` produces; we wrote
down a *relationship* the output bears to the input. This is a
key feature of properties: they often abstract over the answer.
You do not say "rev of `[1; 2; 3]` is `[3; 2; 1]`"; you say "rev
is self-inverse." The first form needs you to pick an input and
work out the answer. The second form does not.

The second property, length preservation, is a *consequence* of
the contract of `rev`: it rearranges elements, it does not add or
drop any. If a buggy `rev` ever returned a list of a different
length, this property would catch it without us having to write
down the exact answer.

The third, permutation, is even more specific: it says the
*elements* are the same, just in a different order. Combined with
length preservation, it pins down a much smaller space of
possible behaviours. ("Returns a list with the same elements in
the same multiset" plus "involution under composition with
itself" essentially fixes `rev` uniquely, up to handling of
non-comparable elements.)

:::slide

## Properties of `rev`

For *every* list `xs`:

1. `rev (rev xs) = xs`  (involution)
2. `List.length (rev xs) = List.length xs`  (length preserved)
3. The multiset of elements is unchanged  (permutation)

- A property is a statement that should hold for *every* input.
- Often abstracts over the answer ("self-inverse" rather than
  "exactly that list").
- Several properties together approximate a specification.

:::

## QCheck: the API in one example

Now the OCaml part. The [QCheck](https://github.com/c-cube/qcheck)
library lets us write the involution property like this:

```ocaml
let test_rev_involutive =
  QCheck.Test.make
    ~name:"rev is involutive"
    ~count:1000
    QCheck.(list int)
    (fun xs -> rev (rev xs) = xs)
```

Five pieces:

- **`QCheck.Test.make`** is the constructor for a property-based
  test. It returns a `QCheck.Test.t` you can hand to the runner.
- **`~name`** is the display string in the output. Same role as
  the name on an OUnit2 case.
- **`~count`** is how many random inputs to try. Default is 100;
  we bumped it to 1000 because cheap.
- **`QCheck.(list int)`** is a *generator*: a recipe for producing
  random `int list`s. `QCheck.int` is a generator for random ints;
  `QCheck.list g` lifts a generator `g` over elements into a
  generator for lists of elements.
- **`(fun xs -> ...)`** is the *property*: a function that
  receives a generated input and returns a `bool`. `true` means
  the property held; `false` means it failed.

To run the test:

```text
(* QCheck_runner lives in the separate [qcheck] opam package and
   is not bundled into the in-browser toplevel; this snippet is
   for the dune-based project setup. In a cell, run a single
   property with [QCheck.Test.check_exn test_rev_involutive]. *)
let () =
  QCheck_runner.run_tests_main [test_rev_involutive]
```

`QCheck_runner.run_tests_main` is the entry point; it parses CLI
flags (so you get `-v`, `-s` for seed, etc. for free) and prints
results. A passing run reports something like:

```
random seed: 42
Law rev is involutive: OK (passed 1000 tests).
```

A thousand random lists, all satisfying `rev (rev xs) = xs`. We
have not exhausted the input space (no machine can; there are
infinitely many lists), but the law has held against 1000
adversaries we did not pick, which is a stronger signal than four
hand-picked cases.

:::slide

## QCheck in one example

```ocaml
let test_rev_involutive =
  QCheck.Test.make
    ~name:"rev is involutive"
    ~count:1000
    QCheck.(list int)
    (fun xs -> rev (rev xs) = xs)

let () = QCheck_runner.run_tests_main [test_rev_involutive]
```

- `QCheck.Test.make` constructs the test.
- Generator: `QCheck.(list int)` produces random `int list`s.
- Property: a function `'a -> bool`. Returns `true` if the input
  satisfies the law.

:::

## Generators

The library's interesting work is in its generators. A
[`QCheck.arbitrary 'a`](https://c-cube.github.io/qcheck/) is a
value bundling three things: a random producer of `'a` values, a
*printer* (for failure messages), and a *shrinker* (more on
shrinking in a moment).

The basic generators are exactly what you expect:

- `QCheck.int`: a uniformly random `int`.
- `QCheck.small_int`: small positive `int`s (handy for sizes).
- `QCheck.bool`: `true` or `false`.
- `QCheck.string`: a random string.
- `QCheck.float`: a random `float`, including `infinity` and `nan`.

And combinators that build bigger generators out of smaller ones:

- `QCheck.list g`: a list of values from `g`.
- `QCheck.array g`: an array of values from `g`.
- `QCheck.pair g1 g2`: a pair.
- `QCheck.option g`: `None` half the time, `Some (g ())` the rest.
- `QCheck.oneof [g1; g2; ...]`: pick one of the given generators.
- `QCheck.map f g`: produce `f (g ())`.

These compose: `QCheck.(list (pair int string))` is a generator for
random lists of (int, string) pairs.

```ocaml
let gen_int_pair_list : (int * string) list QCheck.arbitrary =
  QCheck.(list (pair int string))
```

Each test you write picks a generator that matches the type of
input the function under test expects, and that is most of the
configuration work.

:::slide

## Generators

| Generator | Produces |
| --- | --- |
| `QCheck.int` | uniform `int` |
| `QCheck.small_int` | small positive `int` |
| `QCheck.bool` | `true` / `false` |
| `QCheck.string` | random string |
| `QCheck.float` | random `float` (incl. `nan`, `infinity`) |

Combinators:

- `list g`, `array g`, `pair g1 g2`, `option g`
- `oneof [g1; g2; ...]`, `map f g`

These compose: `QCheck.(list (pair int string))`.

:::

## Properties are pure functions

Notice that the property `fun xs -> rev (rev xs) = xs` is a
*pure* OCaml function. No state, no IO, just an input and a
boolean output. QCheck does not need any special syntax; it just
calls the function 1000 times on 1000 different inputs.

This is exactly the reason that property-based testing fits so
neatly into functional programming. In an imperative language,
properties have to navigate state: you set up the world, you run
the function, you compare *the world before and after*. In OCaml,
the function takes its arguments and returns its result; the
property is the relationship between the two, expressible as a
single expression. There is no setup, no teardown, no shared
state.

Better still: in a pure language, the property *literally is the
spec*. The OCaml expression `rev (rev xs) = xs` is the same
mathematical statement a textbook would write. You can read it
aloud, you can manipulate it equationally, you can prove things
about it. PBT inherits this clarity from the language. In
Python, where everything could mutate, the same property reads
"call rev on xs, save the result; call rev on that, save *that*
result; compare to the original xs; oh also check that nothing
secretly mutated xs along the way."

:::slide

## Why FP makes PBT natural

A property is a pure function `'a -> bool`.

- **No state**: no setup-teardown ceremony.
- **No mutation**: the input cannot be changed by the call.
- **Equational**: `rev (rev xs) = xs` *is* the spec, in code.

In imperative languages PBT works, but you spend energy fighting
mutation. Here, the property reads exactly like the textbook law.

:::

## A second example: `List.sort`

The sort property is richer because "sorted" by itself is too weak
to pin down behaviour. A function that returns the empty list on
every input is "sorted" trivially. To capture `List.sort` we need
*two* properties: the output is sorted, AND the output is a
permutation of the input.

```ocaml
let is_sorted xs =
  let rec go = function
    | [] | [_] -> true
    | a :: b :: rest -> a <= b && go (b :: rest)
  in
  go xs

let same_multiset xs ys =
  List.sort compare xs = List.sort compare ys

let test_sort_sorted =
  QCheck.Test.make
    ~name:"sort produces a sorted list"
    QCheck.(list int)
    (fun xs -> is_sorted (List.sort compare xs))

let test_sort_permutation =
  QCheck.Test.make
    ~name:"sort preserves the multiset"
    QCheck.(list int)
    (fun xs -> same_multiset (List.sort compare xs) xs)

let test_sort_length =
  QCheck.Test.make
    ~name:"sort preserves length"
    QCheck.(list int)
    (fun xs -> List.length (List.sort compare xs) = List.length xs)
```

Three properties. Each one would be satisfied by some wrong
function, but a function that satisfies *all three* is genuinely
hard to write incorrectly.

- "produces a sorted list" by itself is satisfied by `fun _ -> []`.
- "preserves the multiset" by itself is satisfied by `fun xs -> xs`
  (the identity).
- "preserves length" by itself is satisfied by *many* functions
  (the identity, `rev`, ...).

Together, only sort-like functions survive.

:::slide

## `List.sort`: three properties together

```ocaml
let test_sort_sorted =
  QCheck.Test.make ~name:"sorted"
    QCheck.(list int)
    (fun xs -> is_sorted (List.sort compare xs))

let test_sort_permutation =
  QCheck.Test.make ~name:"permutation"
    QCheck.(list int)
    (fun xs -> same_multiset (List.sort compare xs) xs)

let test_sort_length =
  QCheck.Test.make ~name:"length"
    QCheck.(list int)
    (fun xs -> List.length (List.sort compare xs) = List.length xs)
```

- "sorted" alone is satisfied by `fun _ -> []`.
- "permutation" alone is satisfied by `fun xs -> xs`.
- Together: nearly pin down sort.

:::

This is the *art* of property-based testing: choosing a small set
of properties whose conjunction approximates the specification.
For most data-structure operations, three or four properties
suffice. For more complex code (a parser, a query planner), you
might write a dozen. Each property is small; each is independent;
each contributes one constraint.

## Shrinking: finding the smallest counterexample

The most important feature of QCheck (and of QuickCheck more
generally) is *shrinking*. When the library finds an input that
fails the property, it does not just report "this 17-element list
broke things." It actively tries to *minimise* the failing input:
"can I delete one element and still see the failure? Can I delete
another? Can I replace this element with a smaller one?" The
result is the smallest failing input the library can find,
typically a one or two element list, which is far easier to
debug.

Let us see this in action with a *deliberately buggy* sort. A
common rookie mistake: forgetting the singleton case in a
merge-sort-like implementation.

```text
let rec bad_sort = function
  | [] -> []
  (* missing case: | [x] -> [x] *)
  | xs ->
    let n = List.length xs / 2 in
    let left = List.filteri (fun i _ -> i < n) xs in
    let right = List.filteri (fun i _ -> i >= n) xs in
    merge (bad_sort left) (bad_sort right)
```

If `xs` has length 1, then `n = 0`, `left = []`, `right = xs`. So
`bad_sort [x]` calls `bad_sort []` (returns `[]`) and `bad_sort
[x]` (recurses), forever. Stack overflow on any non-empty input.

We give QCheck the same three properties as before, pointed at
`bad_sort`:

```text
let test_bad_sort_sorted =
  QCheck.Test.make
    ~name:"bad_sort produces a sorted list"
    QCheck.(list int)
    (fun xs -> is_sorted (bad_sort xs))
```

Run it. QCheck explores random lists. Some are empty (returns
empty, trivially sorted). Most are non-empty. The first non-empty
list it generates causes a stack overflow. QCheck catches the
exception, marks the test failed, and starts shrinking.

Shrinking proceeds roughly as follows:

1. The original failing input was, say, `[3; -5; 0; 17; 42]` (5
   elements).
2. Can we drop one? Try `[-5; 0; 17; 42]` (drop first). Fails.
   Smaller input. Continue.
3. Drop another. Try `[0; 17; 42]`. Fails. Keep going.
4. Down to `[17; 42]`. Fails. Smaller.
5. Down to `[42]`. Fails. Smaller still.
6. Down to `[]`. *Passes* (bad_sort handles the empty case). So
   `[]` is not a counterexample. The shrinker stops here and
   reports `[42]`, or whatever single-element list it converged
   on, as the minimal counterexample.

The output looks something like:

```
random seed: 42
Law bad_sort produces a sorted list: ERROR (5 shrink steps).
Test bad_sort produces a sorted list failed on input: [42].
Uncaught exception: Stack_overflow.
```

Eight characters of input. The bug is *obvious* now: "a single-
element list overflows the stack." Without shrinking, the original
failing input would have been 17 elements wide, and the bug would
have been buried in irrelevant noise. The shrinker is what makes
PBT *debuggable*.

:::slide

## Shrinking finds the minimal counterexample

A deliberately buggy `bad_sort` forgets the `[x]` case. On any
single-element list it loops forever.

QCheck on it:

```
random seed: 42
Law sort is sorted: ERROR (5 shrink steps).
Test sort is sorted failed on input: [42].
Uncaught exception: Stack_overflow.
```

- Random input that triggered the bug was 5+ elements wide.
- Shrinker repeatedly minimises until further reduction passes.
- Reported counterexample: `[42]`. Bug is obvious.

:::

The shrinker is built into the library's generators. When you use
`QCheck.(list int)`, the resulting `arbitrary` value carries a
shrinking strategy: drop elements, replace elements with smaller
ones. If you write a custom generator (`QCheck.map` over an int,
or `QCheck.make` with a custom random function), you can supply
a custom shrinker; if you do not, QCheck has a sensible default.

For the level of this lecture, you almost never need to write a
shrinker by hand. The built-in generators come with reasonable
ones, and your time is better spent on properties than on
shrinkers. We mention shrinking because it is what makes PBT
output *actionable*, but the day-to-day reality is "use the
default shrinker, point at your property, watch QCheck do the
work."

## Statistics and distributions

A subtle question: how do you know QCheck is exploring inputs
*usefully*? If 90 percent of the lists it generates are length 0,
it has not tested very much.

QCheck addresses this with statistics. Every generator can be
profiled with `QCheck.Print` (printers) and `QCheck.Stats`
(distribution annotations). The flag `-s` to the runner reports
the distribution of generated inputs:

```
random seed: 42
collect:
  length 0:    87 cases (8.7%)
  length 1-5: 423 cases (42.3%)
  length 6-15: 367 cases (36.7%)
  length 16-50: 123 cases (12.3%)
Law rev is involutive: OK (passed 1000 tests).
```

This gives you a sanity check on coverage. If you discover all
1000 generated lists were length 0, that is a signal to tweak the
generator. (For `QCheck.list int` the default is reasonable; for
custom generators, watch this.)

:::slide

## Statistics: are we testing usefully?

```
collect:
  length 0:    87 cases (8.7%)
  length 1-5: 423 cases (42.3%)
  length 6-15: 367 cases (36.7%)
  length 16-50: 123 cases (12.3%)
```

- QCheck reports the distribution of generated inputs.
- Sanity check: are we actually testing what we think?
- For built-in generators the distribution is sensible; watch
  this when you build custom ones.

:::

## Equational reasoning gives properties for free

Coming back to *why* this works so naturally in OCaml: in a pure
functional language, every law you can state in a textbook is a
property you can hand to QCheck.

For lists:

- `List.length (xs @ ys) = List.length xs + List.length ys`
- `List.rev (xs @ ys) = List.rev ys @ List.rev xs`
- `List.map f (List.map g xs) = List.map (fun x -> f (g x)) xs`
- `List.fold_left f a (xs @ ys) = List.fold_left f (List.fold_left f a xs) ys`

For functions:

- `(fun x -> f (g x)) = compose f g`
- `id (f x) = f x`
- `f (id x) = f x`

For numeric operators:

- `x + y = y + x`
- `(x + y) + z = x + (y + z)`

Each one is a single line of OCaml turned into a QCheck property.
The equational nature of functional code means *the laws ARE the
properties*. In an imperative language you would write
"compute lhs, store it; compute rhs, store it; compare." Here
the law is itself executable.

This is the deepest reason testing-by-property is more popular in
the FP world than elsewhere. The language gives you a vocabulary
of pure functions, and the testing library hands that vocabulary
straight to a fuzzer.

## Negative properties: preconditions

Sometimes a property only holds for *some* inputs, not all. For
example, "the head of a list equals its first element" is true
only for non-empty lists. QCheck supports this with
*preconditions* via `QCheck.assume`:

```ocaml
let test_hd_first =
  QCheck.Test.make
    ~name:"hd returns first element"
    QCheck.(list int)
    (fun xs ->
       QCheck.assume (xs <> []);
       List.hd xs = List.nth xs 0)
```

When the generated input fails the precondition, QCheck *skips*
that input and generates another. The case still counts as
checked but does not exercise the property. If too many inputs
fail the precondition (because the generator produces them rarely),
QCheck gives up and warns you. That is your signal to write a
*custom* generator that produces only inputs in the precondition's
range, rather than rejecting most of what the default generator
makes.

:::slide

## Preconditions

```ocaml
let test_hd_first =
  QCheck.Test.make ~name:"hd returns first"
    QCheck.(list int)
    (fun xs ->
       QCheck.assume (xs <> []);
       List.hd xs = List.nth xs 0)
```

- `QCheck.assume` skips inputs that fail the precondition.
- If too many skips, QCheck warns: write a custom generator
  instead.

:::

## A note on what comes next

What we have so far is enough to write *interesting* properties
for any pure function whose input fits one of QCheck's built-in
generators (lists of ints, strings, pairs, options). For real
codebases, two pieces are still missing:

- a way to **bias the input distribution** so the interesting
  region of the input space gets exercised (sorted lists, valid
  BSTs, schema-conformant JSON);
- a way to test **stateful APIs** where a single call is not
  the unit of testing.

Both are the topic of [Lecture 6](M09-L06-custom-generators-stateful.html).
The intuition for why this matters appears at the end of this
lecture under "When PBT does not help"; the *how* lives in L04.

## The input-space problem (preview)

Before we close out, one observation that motivates L04. When we
wrote

```ocaml
QCheck.Test.make ~count:1000 QCheck.(list int)
  (fun xs -> rev (rev xs) = xs)
```

we said "QCheck generates 1000 random `int list`s." That sentence
hides the most important question in PBT: *which* 1000 random
lists? Out of the infinitely many possible inputs, the library
picks a sample; the quality of the test depends entirely on
whether that sample is representative of the inputs that
actually exercise the function.

Take a function that sorts. A list with three random integers,
generated independently, is *almost certainly* not sorted. The
sorter has to do something. But the *interesting* sorting bugs
fire on inputs the default generator visits rarely:

- the *already-sorted* list (does the sorter detect this and
  short-circuit, or perform redundant work?);
- the *reverse-sorted* list (worst case for many algorithms);
- a list with many duplicates (does the comparison handle ties?);
- a list of length 0, 1, 2 (boundary conditions);
- a list near `min_int` or `max_int` (overflow-adjacent).

A uniformly random `(list int)` of length 7 visits the random
*permutation* region of the input space densely and the boundary
regions sparsely. The bug at the boundary may go undetected for
1000 trials and then surface in production, on a customer's
already-sorted input.

This is *the* distribution problem. Random does not mean
"uniformly explores the interesting cases." Random means "uniform
in some specific way, often a way that misses interesting cases."

:::slide

## The input-space problem

```ocaml
QCheck.(list int)  (* what does this actually generate? *)
```

For `List.sort`, the *interesting* cases are at boundaries:

- already-sorted, reverse-sorted
- many duplicates
- length 0, 1, 2
- near `min_int` / `max_int`

The default generator visits the *permutation* region densely
and the boundary regions rarely. PBT can pass 1000 trials and
still miss a boundary bug.

:::
## Shrinking, in depth

We introduced shrinking informally with the `bad_sort` example: a
failing multi-element list got shrunk to a 1-element list, and the
bug was obvious in the small witness. Now we go under the hood.

### Why shrinking matters

When a generator finds a counterexample, it almost never finds
the *minimal* one. The first failing list might have 7 elements,
6 of which are irrelevant noise. The reported failure should be
"`[3]`", not "`[42; -17; 0; 3; 99; -2; 8]`". The difference is
the difference between a tractable bug report and an
intractable one.

Shrinking is the process of *minimising* the failing input
while preserving the failure. It is a search procedure:

1. Start with the witness the generator found.
2. Propose a smaller candidate (drop an element, halve a
   number, ...).
3. Re-run the property on the candidate.
4. If the candidate fails, recurse with it as the new witness.
5. If the candidate passes, try a different reduction.
6. Stop when no further reduction fails.

The result is a *local minimum* of "things that still fail."
Not necessarily the globally smallest, but small enough.

### How QCheck shrinks each type

QCheck's built-in `arbitrary`s come with shrinking baked in. The
default behaviour for the standard types:

**Integers.** Shrink toward zero. Given `n = 42`, try `0`, then
`21`, then `32` (half-way), and so on by bisection. If the bug
fires only on negative numbers, the shrinker walks `-42` -> `0`
-> `-21` -> ..., converging on the smallest negative that still
fails (often `-1`).

**Booleans.** Shrink `true` to `false`. (`false` is the "smaller"
value in QCheck's convention, by alphabetical / numerical order
of constructors.)

**Strings.** Shrink by deleting characters; once minimum-length
is reached, shrink each remaining character (toward `'a'` or
similar). A failing 20-character string converges to a 0 or 1
character string in a few steps.

**Lists.** Shrink in two phases:

1. *Structural.* Try dropping single elements, then pairs, then
   halves. A failing list of length 7 might shrink to length 6,
   then 4, then 2, then 1.
2. *Element-wise.* Once the list is at its minimum length, shrink
   each element individually (using the element's shrinker).

**Pairs, options.** Shrink each component independently, then
the whole.

**Sum types.** If a value is `Some x`, try `None`. If it is
`Inr y`, try `Inl ...`. Then recurse into the component.

The shrinkers compose: `QCheck.(list (pair int (option string)))`
inherits a shrinker that descends into the list, then into each
pair, then into each `option`, then into the integer or string,
all by minimising at each level.

:::slide

## Built-in shrinking, by type

| Type | Shrinks toward |
| --- | --- |
| `int` | `0` by bisection |
| `bool` | `false` |
| `string` | empty / `"a"` by deletion |
| `'a list` | drop elements, then shrink each |
| `'a option` | `None`, then shrink `'a` |
| `('a, 'b) result` | `Error _`, then shrink |
| pairs, tuples | each component independently |

The shrinkers compose recursively for compound types.

:::

### The integer-shrink-toward-zero heuristic

A specific case worth pinning down. When QCheck shrinks an
integer, it does *not* try every smaller value (that would be
useless for `min_int`); it bisects toward zero. The sequence for
`n = 100`:

```
100 -> 0 (try the limit)
100 -> 50 (try the halfway point)
100 -> 75
...
```

If `0` already fails the property, the shrinker reports `0` and
stops. If `0` passes but `50` fails, the search converges
between `0` and `50`. The result is logarithmic in the magnitude
of the original number, which means even very large
counterexamples shrink to small ones in a handful of steps.

The heuristic *is* a heuristic: it can miss the true minimum.
If the bug fires only on prime numbers and the bisection avoids
primes, the shrunk witness might be larger than the smallest
failing prime. In practice this is rare, and the shrinker's
local minimum is usually small enough to debug.

### When you need a custom shrinker

If you build a custom generator with `QCheck.make` and do not
pass a shrinker, the resulting arbitrary has *no* shrinking.
QCheck reports the original failing input verbatim. For
toy properties this is fine; for nontrivial ones the failure
message becomes hard to read.

You supply a custom shrinker by providing the optional `~shrink`
argument to `QCheck.make`:

```ocaml
type point = { x : int; y : int }

let point_shrink : point -> point QCheck.Iter.t =
  fun p ->
    let open QCheck.Iter in
    let shrink_int = QCheck.Shrink.int in
    (shrink_int p.x >|= fun x -> { p with x }) <+>
    (shrink_int p.y >|= fun y -> { p with y })

let point_gen : point QCheck.arbitrary =
  let open QCheck in
  make ~shrink:point_shrink
    Gen.(pair small_int small_int >|= fun (x, y) -> { x; y })
```

Read this carefully because the types are subtle:

- `QCheck.Iter.t` is QCheck's stream type for shrink candidates.
  A shrinker takes a value `'a` and returns an `'a QCheck.Iter.t`
  containing all "one-step-smaller" candidates.
- `QCheck.Shrink.int` is the integer shrinker: `int -> int Iter.t`.
  Calling it on `42` gives a stream of `[0; 21; 32; 37; 40; 41]`,
  in roughly that order.
- `>|=` lifts a transformation over an `Iter.t`. Applied to the
  result of `shrink_int p.x`, we get a stream of new `point`s
  with `x` shrunk and `y` left alone.
- `<+>` concatenates two `Iter.t`s: first try shrinking `x`, then
  try shrinking `y`. The shrinker explores both axes.

When QCheck finds a failing `point`, it walks this `Iter.t`,
re-running the property on each candidate. The minimal failing
point in the stream becomes the new witness, and the process
recurses.

For most code you do *not* write custom shrinkers; the built-in
ones for `int`, `list`, `string`, etc., handle nearly every
case. The above example is what you do when you have a custom
record type and want a small failure message instead of "
{ x = -83729; y = 47119 }
".

:::slide

## Custom shrinker (when you need one)

```ocaml
let point_shrink p =
  let open QCheck.Iter in
  (QCheck.Shrink.int p.x >|= fun x -> { p with x }) <+>
  (QCheck.Shrink.int p.y >|= fun y -> { p with y })

let point_gen =
  QCheck.make ~shrink:point_shrink (* ... *)
```

- `QCheck.Iter.t` is the stream of one-step-smaller candidates.
- `<+>` concatenates two streams.
- For built-in types, you almost never need to write this.
- For custom records / variants, write it once; QCheck does the
  rest.

:::

### Why "smallest failure" is more useful than "first failure"

A final note on shrinking's value. The original QuickCheck paper
made the point that *random testing without shrinking* is much
less useful than random testing *with* shrinking, even though
the random-generation work is the same. The reason: programmers
don't care about a 200-character string that crashes the parser;
they care about *which character* in that string caused the
crash. Shrinking turns "huge counterexample" into "minimal
counterexample," which is what a debugger needs.

If you take one thing from QCheck's API, take the shrinker. The
generator does the search; the shrinker does the diagnosis.

## When PBT does not help

PBT is not a universal solvent. There are cases where unit tests
still win.

**Specific known cases.** "What does `sort [3; 1; 2]` return?" is
a unit test, not a property. PBT cannot tell you the *answer* to
that specific question.

**Where the spec IS a list of cases.** Some functions are defined
by a finite table (the days of the week, the bytecode opcodes).
There is no "for all" structure to abstract over; a hand-written
case per row is more honest.

**Cases where generators are expensive.** If generating a valid
input is itself a multi-step process (parse, normalise, validate),
a hand-written corpus of representative inputs may be cheaper than
a custom generator.

**Cases where the property is just "the output equals the
expected output."** That is unit testing dressed in PBT clothes,
without any of the benefit.

The right reflex is: unit tests for *known specific cases*; PBT
for *invariants*. They are complementary, just like types and
tests.

:::slide

## When PBT does not help

- **Specific cases**: "sort [3; 1; 2] = [1; 2; 3]" is a unit test,
  not a property.
- **Tabular specs**: a finite enumerated table is unit-test
  shaped.
- **Expensive valid input**: writing a generator may cost more
  than a corpus.
- **The "property" is just expected = actual**: that is a unit
  test in disguise.

PBT is for *invariants*. Unit tests are for *cases*.

:::

## A short history

PBT was introduced by Koen Claessen and John Hughes in the
[QuickCheck](https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/quick.pdf)
library for Haskell, published in ICFP 2000. The idea has since
been ported to dozens of languages:
[Hypothesis](https://hypothesis.readthedocs.io/) in Python,
[fast-check](https://github.com/dubzzz/fast-check) in
JavaScript, [proptest](https://github.com/proptest-rs/proptest) in
Rust, and many others. OCaml's
[QCheck](https://github.com/c-cube/qcheck) (by Simon Cruanes and
contributors) is the direct descendant of QuickCheck, with OCaml-
idiomatic conventions.

The intellectual contribution of QuickCheck was not the random
testing itself: random testing predates QuickCheck by decades. It
was *the combination of random generation with automatic shrinking
inside a strong type system*. The type system makes it possible to
auto-generate inputs for any type, and shrinking makes the
counterexamples small enough to debug. Together they make PBT
genuinely productive for working programmers, not just a research
curiosity.

## Activity

:::quiz mcq id=M09-L05-q1
A colleague writes a `dedup : int list -> int list` and a single
QCheck property:

```text
let test = QCheck.Test.make QCheck.(list int)
  (fun xs -> List.length (dedup xs) <= List.length xs)
```

The property passes on 1000 random inputs. What is the strongest
conclusion you can draw about `dedup`?

- [ ] `dedup` is correct.
- [ ] `dedup` is incorrect; one property is never enough.
- [x] `dedup` returns lists of length at most the input length;
  many incorrect implementations also satisfy this property.
- [ ] `dedup` returns the correct multiset of elements.

**Why:** the property only states that the output is no longer
than the input. `fun _ -> []` satisfies it (length 0 is at most
any length). So does the identity. So does "return the first
element only." A single weak property cannot replace a
specification; you need *several* properties whose conjunction
constrains behaviour. Length-no-longer-than is one constraint;
"every element of the output appears in the input", "no
duplicates in the output", and "every input element appears in
the output" would together pin `dedup` down.
:::

:::quiz mcq id=M09-L05-q2
QCheck runs a property on a buggy function and reports:

```
Test failed on input: [3].
```

The function was tested with `QCheck.(list int)`, which generates
random lists of random length. The reported input is a one-element
list, but the *random* input that triggered the bug was, the
seed log suggests, a 12-element list. What happened?

- [ ] QCheck regenerated the input from a smaller seed.
- [x] QCheck *shrunk* the failing 12-element input down to the
  smallest input that still fails, namely `[3]`.
- [ ] The 12-element input did not actually fail; QCheck mis-
  reported.
- [ ] The bug fires randomly and the seed determines which
  inputs trigger it.

**Why:** shrinking is QCheck's process of repeatedly minimising
a failing input. After finding a 12-element counterexample, it
tries dropping elements, replacing elements with smaller ones,
and so on, until further reduction would make the property pass.
The reported `[3]` is the *minimal* witnessed failure. This is
the central feature that makes PBT actionable: the original
random failure is usually too noisy to debug; the shrunk
witness is usually the bug in its purest form.
:::

:::quiz code id=M09-L05-q3
Write a QCheck property that captures: *concatenating the empty
list to any list yields the original list.* Use the generator
`QCheck.(list int)`. Name the property `"empty is right identity
for @"`.

The body of the test should be a function `xs -> bool` returning
`true` when the law holds.

```ocaml
let test_concat_empty_right =
  failwith "not implemented"
```

```ocaml skip
let () =
  (* The student's test must, when applied to any list, hold. *)
  let prop xs = xs @ [] = xs in
  assert (prop []);
  assert (prop [1]);
  assert (prop [1; 2; 3]);
  assert (prop [-7; 0; 42]);
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```ocaml
let test_concat_empty_right =
  QCheck.Test.make
    ~name:"empty is right identity for @"
    QCheck.(list int)
    (fun xs -> xs @ [] = xs)
```

Four lines. The property `xs @ [] = xs` is a one-line statement
of a list-monoid law; it is exactly the kind of equational
property functional code makes easy to state.

:::

## Common pitfalls

**Pitfall 1: too few properties.** A function with one property
that "passes" is barely more tested than a function without
properties at all. State several. The conjunction is what
constrains behaviour.

**Pitfall 2: tautological properties.** Watch for properties that
hold of any function with the right type. `fun xs -> List.length
(rev xs) >= 0` is true of every list, including the wrong ones.
The property has to *exclude* implementations.

**Pitfall 3: properties that depend on the implementation.** "rev
allocates a new list" depends on the implementation, not the
spec. Phrase properties in terms of *observable behaviour*.

**Pitfall 4: too-narrow generators.** If `QCheck.small_int` only
produces 0-9 but the bug fires on `min_int`, the bug will not be
caught. Default generators are reasonable; custom ones need
thought.

**Pitfall 5: confusing "passed 1000 cases" with "proved".** PBT
gives you evidence, not proof. A bug that fires only on inputs
with a specific shape (e.g. a deeply nested record) may evade
1000 random inputs. PBT is a *sieve*, not a verifier.

:::slide

## Common pitfalls

1. **Too few properties**: one law barely constrains anything.
2. **Tautological properties**: hold of any function with the
   right type.
3. **Implementation-bound properties**: should phrase in terms
   of behaviour.
4. **Too-narrow generators**: tweak when bugs persist.
5. **"Passed N cases" ≠ "proved"**: PBT is a sieve, not a
   verifier.

:::

## What's next

So far the things we have tested are *pure functions*: an input
goes in, an output comes out, no state. PBT shines there. But
much of real software is stateful: a hash table you `add` to and
`remove` from, a queue you `enqueue` and `dequeue`, a file you
`read` and `write`. How do you write a property for a *stateful*
data structure, where each operation depends on every operation
that came before?

[Lecture 6](M09-L06-custom-generators-stateful.html) builds the
generator toolkit: sorted lists, valid BSTs, DAGs, JSON
matching a schema; how to bundle a generator, printer, and
shrinker for a custom recursive type; and the first taste of
testing stateful APIs by generating *sequences of commands*.

[Lecture 7](M09-L07-model-based-testing.html) goes further with
*model-based testing*: test a sophisticated stateful
implementation against a simple reference implementation, by
generating random sequences of operations and asserting
observable equivalence at each step. It is the canonical PBT
pattern for stateful code, and it cleanly extends what we have
built in this lecture.

[Lecture 8](M09-L08-tutorial.html) puts unit testing and
property-based testing together on a single, larger example: a
function from earlier in the course (the M05-L06 evaluator),
with a deliberately broken implementation that QCheck finds in
seconds.

:::slide

## What's next

- L4: **custom generators and stateful PBT.** Sorted lists,
  valid BSTs, DAGs by construction; command-sequence
  generators.
- L5: **model-based testing.** A custom hash table vs. a
  list-based reference.
- L8: **tutorial.** OUnit2 + QCheck on the M05-L06 evaluator;
  a deliberately buggy version found by the shrinker.

:::

## Reading

- **QCheck**, the OCaml property-based testing library used in
  this lecture. README, tutorial, and API docs are all in the
  upstream repository:
  <https://github.com/c-cube/qcheck>
- **QCheck API documentation**, generated from the source:
  <https://c-cube.github.io/qcheck/>
- **Claessen and Hughes**, *QuickCheck: A Lightweight Tool for
  Random Testing of Haskell Programs*, ICFP 2000. The paper that
  introduced PBT and the combination of random generation with
  automatic shrinking:
  <https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/quick.pdf>
- **Cornell CS3110**, *Randomized testing with QCheck*. Source
  for the abstraction layering (generator, arbitrary, property)
  used in this lecture:
  <https://cs3110.github.io/textbook/chapters/correctness/randomized.html>
- **Cornell CS3110**, *Black-box and glass-box testing*. The
  framework of "paths through the specification" we used in the
  input-space section:
  <https://cs3110.github.io/textbook/chapters/correctness/black_glass_box.html>
- **Real World OCaml**, *Testing*. The Quickcheck section
  discusses distribution choice and how `ppx_quickcheck` derives
  generators automatically:
  <https://dev.realworldocaml.org/testing.html>

## Sources

This lecture's prose, worked examples, and quizzes are original
to this course. The QCheck library by Simon Cruanes and
contributors is BSD-2-Clause licensed; we link to its
repository and use its public API surface, with no derivative
reuse of its prose. The QuickCheck origin paper (Claessen and
Hughes) is the canonical reference for the technique itself;
we cite it for context. Cornell CS3110's randomized-testing
and black-box-testing chapters are CC BY-NC-ND licensed and
have not been derivatively reused; the *paths through the
specification* framing we use in the input-space section
follows their pedagogical sequence with our own examples and
prose, and we link to both for further reading. Real World
OCaml's Testing chapter has a parallel discussion of Quickcheck
distribution choice that we link to but have not reused. The
`bad_sort` example (missing singleton case) and the sorted-list,
operation-based-BST, and DAG-by-vertex-order generator recipes
are folklore in the PBT community, presented here in our own
words and OCaml.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
