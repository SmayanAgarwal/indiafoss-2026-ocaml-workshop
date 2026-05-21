---
title: "Property-based testing with QCheck"
lecture_no: 3
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

[Lecture 2](M09-L02-unit-testing.html) gave you OUnit2 and a habit
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

```ocaml skip
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

```ocaml skip
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

```ocaml skip
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

## The input-space problem

There is a question we have been ducking. When we wrote

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

The framework Cornell CS3110 uses for this is *paths through the
specification* (see the `Reading` section's pointer to *Black-box
and glass-box testing*). The idea is to look at the spec and
identify the disjoint *regions* of input space where the function
behaves differently: empty input, singleton input, "happy path",
boundary case, error case. PBT does not free you from that
thinking; it changes *where* you do it. Instead of writing 20
hand-picked inputs, you write a generator that *covers each
region*.

Three practical reactions to the distribution problem:

**Reaction 1: read your statistics.** Add `QCheck.collect` to
your property and inspect the distribution. If lengths cluster in
one bucket, the generator is not exercising the others. CS3110
calls this *coverage*; we discussed it briefly in the previous
section.

**Reaction 2: bias the generator.** Use `QCheck.frequency` to
weight cases so that interesting inputs appear more often:

```ocaml
let biased_list_gen : int list QCheck.arbitrary =
  let open QCheck in
  let small = list_of_size (Gen.return 0) int in
  let medium = list_of_size (Gen.int_range 1 10) int in
  let large = list_of_size (Gen.int_range 100 200) int in
  QCheck.choose [small; medium; large]
```

The `choose` combinator picks uniformly among the listed
generators. To weight them, use the `QCheck.frequency` family:
give each generator a positive integer weight and the picker
samples in proportion to those weights. A small list shows up
often, a large list shows up rarely, but *both* are exercised.

**Reaction 3: generate inputs that already satisfy the
invariant.** If the bug fires on sorted lists, generate sorted
lists deliberately, not random ones that happen to be sorted.
That is the central topic of the next section.

:::slide

## Three reactions to the distribution problem

1. **Read your statistics**: `QCheck.collect` reports the
   distribution of generated inputs.
2. **Bias the generator**: `QCheck.frequency` weights cases so
   the interesting regions are visited often.
3. **Generate inputs that satisfy the invariant**: build a
   generator whose outputs are *by construction* in the region
   you care about. See next section.

:::

## Generating values that satisfy an invariant

The single hardest skill in PBT is writing a generator that
produces inputs satisfying a non-trivial precondition or
invariant. "Generate a sorted array" is not "generate an array";
"generate a valid red-black tree" is far harder than "generate a
tree." The default `QCheck.list int` produces something that has
*almost certainly* none of the structural properties you want.

Three escalating examples, with running code.

### Example A: a sorted array

The naive approach is rejection sampling: generate a random
array, check if it is sorted, retry if not. For length-3 arrays
of small integers this works (about one in six are sorted); for
length-20 arrays the rejection rate is ~99.999999% and the
generator stalls.

The correct approach is *constructive*: build something that is
sorted *by construction*. Two natural recipes.

**Recipe A1: generate, then sort.** Generate a random list, then
apply `List.sort compare` and return the result. The output is
guaranteed sorted.

```ocaml
let sorted_int_list_gen : int list QCheck.arbitrary =
  QCheck.(map (fun xs -> List.sort compare xs) (list int))
```

`QCheck.map` lifts a function `'a -> 'b` over a generator,
producing an `'b QCheck.arbitrary`. The body says: "generate a
random list, then sort it." Every output of this generator is
sorted. The cost is one `List.sort` per test, which is cheap.

A caveat: this generator visits *every* sorted list eventually,
but the distribution is biased toward lists that are
*permutations of typical random inputs*. Lists with all equal
elements are unlikely; lists where consecutive elements differ
by exactly 1 are unlikely; lists of all `min_int` will never
occur. For most properties this is fine; for properties that
fire on specific shapes (a run of equal elements, perhaps), you
may want recipe A2.

**Recipe A2: prefix-sum of non-negative increments.** Start with
an initial value, generate a list of non-negative increments,
take the running sum. The output is sorted *and* you control the
distribution of gaps.

```ocaml
let sorted_int_list_via_prefix_sum_gen : int list QCheck.arbitrary =
  let open QCheck in
  map
    (fun (start, gaps) ->
       let _, acc =
         List.fold_left
           (fun (cur, acc) gap ->
              let next = cur + gap in
              (next, next :: acc))
           (start, [start])
           gaps
       in
       List.rev acc)
    (pair small_int (list small_nat))
```

Read the body: pick a starting integer and a list of small non-
negative gaps; fold over the gaps accumulating a running prefix
sum; reverse the accumulator. The result is a sorted list whose
*first* element is `start` and whose remaining elements are
spaced by the random gaps.

If you want a generator for sorted lists with possible
duplicates, the gaps can be zero. If you want strictly
increasing, use `small_int` (which can be zero, but rarely) with
a small constant `+1` to force a strict increase. The point is
that the distribution is now *in your hands*, not the framework's.

```ocaml
let test_binary_search_finds_existing =
  QCheck.Test.make
    ~name:"binary_search finds elements present in a sorted list"
    QCheck.(pair sorted_int_list_gen small_int)
    (fun (xs, idx) ->
       match xs with
       | [] -> true (* trivially: nothing to find *)
       | _ ->
         let n = List.length xs in
         let i = abs idx mod n in
         let target = List.nth xs i in
         (* property: a value present in the list is findable *)
         List.mem target xs)
```

The property reads naturally because the precondition (sorted
input) is built into the generator. If we had used
`QCheck.(list int)` and added `QCheck.assume (is_sorted xs)`, the
test would have skipped 99% of generated inputs. By baking the
invariant into the generator, every single test exercises the
function on a relevant input.

:::slide

## Sorted-list generators: two recipes

```ocaml
(* Recipe A1: generate, then sort *)
let sorted_a =
  QCheck.(map (fun xs -> List.sort compare xs) (list int))

(* Recipe A2: prefix-sum of non-negative increments *)
let sorted_b =
  QCheck.(map
    (fun (start, gaps) ->
       List.fold_left (fun acc g ->
         (match acc with
          | x :: _ -> (x + g) :: acc
          | [] -> [start]))
         [start] gaps
       |> List.rev)
    (pair small_int (list small_nat)))
```

- A1: simple, cheap, biased toward random-shape distributions.
- A2: more control over gap distribution.
- Both produce *only* sorted lists; no rejection.

:::

### Example B: a balanced binary search tree

Now the harder case. We want to test operations on a balanced
binary search tree (BST): `mem`, `delete`, `union`, `inorder`,
balance-after-rebalance, and so on. Every operation has an
implicit precondition: *the input tree is itself a valid BST*. If
we generate a random tree shape and stuff random integers into
it, we get a tree that violates the BST invariant (some left
child larger than its parent, some right child smaller). The
test exercises the function on garbage input; its results tell
us nothing about behaviour on real BSTs.

How do you generate a valid BST?

**Recipe B1: insert random keys into an empty tree.** This is the
*operation-based generator* pattern, and it is the canonical way
to generate values of a complex algebraic data structure that
has a non-trivial invariant. Use the well-tested `insert`
operation of the data structure to *build* the value; the
operation itself preserves the invariant, so the output is valid
by construction.

```ocaml
(* A simple unbalanced BST for illustration. The same technique
   works for red-black, AVL, etc.: just call the real insert. *)
type tree = Leaf | Node of tree * int * tree

let rec insert t x =
  match t with
  | Leaf -> Node (Leaf, x, Leaf)
  | Node (l, y, r) ->
    if x < y then Node (insert l x, y, r)
    else if x > y then Node (l, y, insert r x)
    else t  (* already present *)

let bst_gen : tree QCheck.arbitrary =
  QCheck.(map
    (fun xs -> List.fold_left insert Leaf xs)
    (list int))
```

That is it. A list of random integers folded with `insert` over
the empty tree produces *exactly* the BSTs that `insert` itself
can produce; the BST invariant is preserved by `insert` (we
trust this from the implementation of `insert`); therefore every
generated tree is a valid BST.

The properties we can now write are the interesting ones:

```ocaml
let rec inorder = function
  | Leaf -> []
  | Node (l, x, r) -> inorder l @ [x] @ inorder r

let is_sorted xs =
  let rec go = function
    | [] | [_] -> true
    | a :: (b :: _ as t) -> a <= b && go t
  in
  go xs

let test_inorder_is_sorted =
  QCheck.Test.make
    ~name:"in-order traversal of a BST is sorted"
    bst_gen
    (fun t -> is_sorted (inorder t))
```

The property is the *defining* invariant of a BST: an in-order
traversal yields a sorted sequence. It is mathematically trivial
to state, but writing it required a generator that produces only
valid BSTs. Random tree-shaped data would have failed this
property immediately, but the failure would tell us nothing
useful: the input was not a BST in the first place.

There is a subtle question to address with this generator: are
we testing `insert` against itself? Not quite. We are testing
*other operations* (like `inorder`) on values produced by
`insert`. If `insert` had a bug, the generated trees might not
satisfy the BST invariant, and the property `is_sorted (inorder
t)` would catch *that bug too*. Operation-based generators are
in fact a beautiful self-checking technique: they exercise the
constructor *and* the consumer simultaneously.

The same recipe scales to red-black, AVL, splay, and any other
self-balancing tree. Use the library's `insert` (and `delete`,
if you want to test deletion). The invariant is whatever the
library promises; the generator inherits it from the operations.

```ocaml skip
(* Sketch: the same recipe for a red-black tree from a library *)
let rb_tree_gen : Rb.t QCheck.arbitrary =
  QCheck.(map
    (fun xs -> List.fold_left Rb.insert Rb.empty xs)
    (list int))

let test_rb_tree_height_logarithmic =
  QCheck.Test.make
    ~name:"red-black tree height is O(log n)"
    rb_tree_gen
    (fun t ->
       let n = Rb.cardinality t in
       let h = Rb.height t in
       n = 0 || h <= 2 * int_of_float (log (float_of_int n) /. log 2.0) + 2)
```

Every generated tree is a valid red-black tree because `Rb.insert`
maintains the red-black invariant. The property checks a *derived*
invariant (height is logarithmic in size). If the implementation of
`insert` ever fails to rebalance correctly, the height bound is
violated and the property catches it. We did not have to write a
"generate-a-valid-red-black-tree-from-scratch" generator; we let
`insert` do that work.

**Recipe B2: generate the shape directly with invariants
threaded through.** A more advanced approach, useful when you
want a *uniform* distribution over valid values rather than the
distribution induced by repeated insertion. For BSTs, generate a
sorted list of integers, then build a balanced BST by repeated
midpoint splitting:

```ocaml
let balanced_bst_from_sorted xs =
  let arr = Array.of_list xs in
  let rec go lo hi =
    if lo >= hi then Leaf
    else
      let mid = (lo + hi) / 2 in
      Node (go lo mid, arr.(mid), go (mid + 1) hi)
  in
  go 0 (Array.length arr)

let balanced_bst_gen : tree QCheck.arbitrary =
  QCheck.(map balanced_bst_from_sorted
    (map
      (fun xs -> List.sort_uniq compare xs)
      (list int)))
```

This generator produces only *balanced* BSTs (height differs by
at most 1 between sibling subtrees, by midpoint construction).
The distribution is different from B1: B1 produces the
distribution-of-insertion-orders, which on uniformly random
keys is not balanced; B2 produces balanced trees with a uniform
distribution over the key set. Choose B1 when you want to
exercise *what the insert operation actually produces*; choose
B2 when you want to test, say, traversal operations on canonical
balanced shapes.

:::slide

## Generator for a valid BST

```ocaml
let bst_gen : tree QCheck.arbitrary =
  QCheck.(map
    (fun xs -> List.fold_left insert Leaf xs)
    (list int))
```

Use the data structure's *own* insert function as the generator.

- Every output is a valid BST (because `insert` preserves the
  invariant).
- The same recipe works for red-black, AVL, splay, etc.
- Bonus: a bug in `insert` will show up via the consumer
  properties (`inorder t` should be sorted, height should be
  logarithmic, ...).

:::

### Example C: other invariants in passing

The same patterns generalise. A few sketches.

**Acyclic graph.** Generate vertices as `0 .. n-1`. For each
ordered pair `(i, j)` with `i < j`, decide independently whether
to include the edge. The resulting graph is a DAG by
construction because no edge points backward in the vertex
ordering.

```ocaml
let dag_gen : (int * int) list QCheck.arbitrary =
  let open QCheck in
  small_int >>= fun n ->
  let pairs = ref [] in
  for i = 0 to n - 1 do
    for j = i + 1 to n - 1 do
      pairs := (i, j) :: !pairs
    done
  done;
  list_of_size (Gen.int_range 0 (List.length !pairs)) (oneofl !pairs)
  |> map (fun edges -> List.sort_uniq compare edges)
```

The point is the *invariant by construction*: by only adding
edges from a smaller-indexed vertex to a larger one, acyclicity
is guaranteed.

**Valid arithmetic expression tree (no division by zero).**
Recursively build expression trees, but in the `Div` case
generate the right-hand side from `Gen.int_range 1 max_int` or
`Gen.int_range min_int (-1)`, never including 0. The generator
encodes the precondition "no zero divisor anywhere" by
construction.

**JSON value with a specific schema.** Generate at each step the
constructor allowed by the schema's grammar; recurse with the
schema's children. The generator *is* the grammar.

The shared pattern: don't generate-then-filter, *generate-by-
construction*. Filtering with `QCheck.assume` works when most
inputs already satisfy the precondition (e.g. "non-empty list");
it does not work when the precondition is restrictive (e.g.
"sorted, balanced, acyclic"). For those, build the structure to
satisfy the invariant from the start.

:::slide

## The general pattern

| Invariant | Generator pattern |
| --- | --- |
| Sorted list | `map List.sort (list int)` |
| Valid BST | Fold `insert` over a random list |
| Balanced BST | Sort, then midpoint-split |
| DAG | Edges only from low to high vertex index |
| Non-zero divisor | Pick from `int_range 1 max_int` |
| Schema-valid JSON | Generator mirrors the grammar |

**Don't generate-then-filter. Generate-by-construction.**

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

## Custom arbitraries

Up to now we have built generators by composing the built-in
combinators (`QCheck.map`, `QCheck.pair`, `QCheck.list`). For
custom types you eventually want a `'a QCheck.arbitrary` of your
own, with a generator, a printer, and (optionally) a shrinker
bundled together.

The constructor:

```ocaml
val QCheck.make :
  ?print:('a -> string) ->
  ?shrink:('a -> 'a QCheck.Iter.t) ->
  'a QCheck.Gen.t ->
  'a QCheck.arbitrary
```

Three things in one bundle:

- A `Gen.t`: a function `Random.State.t -> 'a` that pulls one
  pseudorandom value.
- A `print`: turns a value into a string for failure messages.
- A `shrink`: produces an `Iter.t` of one-step-smaller
  candidates.

A worked example: a `tree` ADT with two constructors.

```ocaml
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let rec tree_gen depth elem_gen =
  let open QCheck.Gen in
  if depth <= 0 then return Leaf
  else
    frequency [
      1, return Leaf;
      3, (let* x = elem_gen in
          let* l = tree_gen (depth - 1) elem_gen in
          let* r = tree_gen (depth - 1) elem_gen in
          return (Node (l, x, r)));
    ]

let rec tree_to_string elem_to_string = function
  | Leaf -> "Leaf"
  | Node (l, x, r) ->
    Printf.sprintf "Node (%s, %s, %s)"
      (tree_to_string elem_to_string l)
      (elem_to_string x)
      (tree_to_string elem_to_string r)

let rec tree_shrink shrink_elem = function
  | Leaf -> QCheck.Iter.empty
  | Node (l, x, r) ->
    let open QCheck.Iter in
    (* Drop a sub-tree: replace the whole node by either child *)
    of_list [l; r] <+>
    (* Or shrink the element *)
    (shrink_elem x >|= fun x' -> Node (l, x', r)) <+>
    (* Or shrink the left sub-tree *)
    (tree_shrink shrink_elem l >|= fun l' -> Node (l', x, r)) <+>
    (* Or shrink the right sub-tree *)
    (tree_shrink shrink_elem r >|= fun r' -> Node (l, x, r'))

let tree_arb : int tree QCheck.arbitrary =
  QCheck.make
    ~print:(tree_to_string string_of_int)
    ~shrink:(tree_shrink QCheck.Shrink.int)
    (tree_gen 4 QCheck.Gen.small_int)
```

The three pieces:

- `tree_gen depth elem_gen`: a generator parameterised by a
  recursion depth and a generator for elements. `frequency`
  weights the Leaf and Node cases (here, 1 leaf for every 3
  nodes); the depth bound prevents infinite trees. The
  `let*` is QCheck's monadic let-binding for `Gen.t`.

- `tree_to_string`: a recursive pretty-printer. Without this,
  failure messages say `<opaque>`, which is useless. *Always
  write a printer* for your custom arbitraries; it is the
  difference between a useful and a useless failure message.

- `tree_shrink`: the recursive shrinker. The structure: at a
  `Node`, try replacing the whole node with either child
  (drops a level of the tree), then try shrinking the element,
  then try shrinking each sub-tree. The result is a stream of
  smaller candidates explored in this order.

Once `tree_arb` exists, properties on it write themselves:

```ocaml
let rec size = function Leaf -> 0 | Node (l, _, r) -> 1 + size l + size r
let rec mirror = function
  | Leaf -> Leaf
  | Node (l, x, r) -> Node (mirror r, x, mirror l)

let test_mirror_size_preserved =
  QCheck.Test.make
    ~name:"mirror preserves size"
    tree_arb
    (fun t -> size (mirror t) = size t)

let test_mirror_involutive =
  QCheck.Test.make
    ~name:"mirror is its own inverse"
    tree_arb
    (fun t -> mirror (mirror t) = t)
```

Two properties, one for each side of the law. The custom
arbitrary makes both possible without rewriting any plumbing.

:::slide

## A custom arbitrary, end to end

```ocaml
let tree_arb : int tree QCheck.arbitrary =
  QCheck.make
    ~print:tree_to_string_int
    ~shrink:(tree_shrink QCheck.Shrink.int)
    (tree_gen 4 QCheck.Gen.small_int)
```

Three pieces:

1. **Generator**: recursive, with frequency weights and a
   depth bound to avoid infinite trees.
2. **Printer**: pretty-prints values into failure messages.
3. **Shrinker**: tries to replace a Node by a child, then
   shrinks the element, then shrinks each sub-tree.

With `tree_arb` in hand, properties on `tree` are one-liners.

:::

### When you need this vs. when you don't

The minor-but-real cost of a full `arbitrary` is the printer and
shrinker. Both can be omitted (the defaults are "print
`<opaque>`" and "no shrinking"), but failure messages get
substantially worse. The good rule: if the type appears in *any*
property, write the printer; if the type appears in *more than
one* property and the test suite is non-trivial, write the
shrinker too.

The built-in arbitraries (`QCheck.int`, `QCheck.list`, etc.)
already bundle all three. You only need this machinery when you
build for a *custom* type that QCheck does not know about.

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

:::quiz mcq id=M09-L03-q1
A colleague writes a `dedup : int list -> int list` and a single
QCheck property:

```ocaml skip
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

:::quiz mcq id=M09-L03-q2
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

:::quiz code id=M09-L03-q3
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

[Lecture 4](M09-L04-model-based-testing.html) answers this with
*model-based testing*: test a sophisticated stateful
implementation against a simple reference implementation, by
generating random sequences of operations and asserting
observable equivalence at each step. It is the canonical PBT
pattern for stateful code, and it cleanly extends what we have
built in this lecture.

[Lecture 5](M09-L05-tutorial.html) then puts unit testing and
property-based testing together on a single, larger example: a
function from Modules 1-8 of this course. You will see a full
test suite (OUnit2 cases plus QCheck properties), watch QCheck
find a bug in a deliberately broken implementation, and finish
with a working test file you could copy into your own project.

:::slide

## What's next

- L4: **model-based testing.** Test a stateful hash table
  against a list-based reference.
- L5: **tutorial.** OUnit2 + QCheck on a real M01-M08 function.
- A deliberately buggy implementation; watch the shrinker find
  it.
- A complete `dune` test file you can copy.

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
