---
title: "Tutorial: Fibonacci, GCD, list helpers"
lecture_no: 6
week: 3
duration_target_min: 28
concepts: [worked recursive examples, tail vs naive recursion, memoization preview]
keywords: [OCaml, tutorial, fibonacci, gcd, list, recursion, tail recursion]
activity_question: "Write a tail-recursive function [last : 'a list -> 'a option] that returns the last element of a list (or [None] if empty). Why does this need an option return type?"
think_about_this: "When a function does not terminate on certain inputs (like negative arguments to factorial), should it crash, return a sentinel, or return an [option] / [result]? What does each choice cost the caller?"
reading:
  - title: "Cornell CS3110, Recursion examples"
    url: https://cs3110.github.io/textbook/chapters/basics/functions.html
---

# Tutorial for Module 3


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Tutorial: Fibonacci, GCD, list helpers</h2>
<p class="title-slide-label">Module 3 &middot; Lecture 6</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

This tutorial works through six small problems: Fibonacci (naive
and linear-time), GCD by Euclid, a list indexing function, a
tail-recursive sum, list reversal, and a digit-counting function.
None are individually hard; the point is to consolidate the
techniques from Module 3
([recursion](M03-L02-recursion.html),
[tail calls and accumulators](M03-L04-tail-recursion.html),
[local helpers](M03-L05-local-and-mutual.html)) and to make
explicit the choice between *naive recursive* and *tail-recursive*
implementations.

The general rule of thumb: write the naive recursive form first.
It is almost always the clearest expression of the algorithm and
it is what you should reach for in a sketch or a small script. If
the function will be called on large inputs (long lists, large
numbers, in hot paths), convert to tail-recursive form using the
[accumulator pattern](M03-L04-tail-recursion.html#the-accumulator-pattern)
from M03-L04. Most code never needs the conversion; practitioners
get a feel for which functions are likely to be called on big data
and rewrite those preemptively.

## Problem 1: Fibonacci, naively

The Fibonacci numbers are defined by `F(0) = 0`, `F(1) = 1`, and
`F(n) = F(n-1) + F(n-2)` for `n >= 2`. The natural recursive
translation:

```ocaml
let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)

let _ = fib 20
```

:::slide

## Problem 1: Fibonacci, naively

```ocaml
let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)

let _ = fib 20
```

- `int = 6765`.
- Two recursive calls per step; call tree branches.
- Total calls: exponential in `n`.
- `fib 30`: slow. `fib 40`: slower. `fib 50`: impractical.

:::

`fib 20` is `6765`. The function is correct and the code reads
exactly like the mathematical definition.

The trouble is performance. Each call to `fib n` (for `n >= 2`)
makes *two* recursive calls. So the work to compute `fib n` is
proportional to the number of nodes in a binary call tree of depth
`n`, which is exponential. Specifically, the number of function
calls to compute `fib n` is roughly `phi^n` where `phi = 1.618...`
is the golden ratio. So `fib 30` does about a million calls (takes
under a second), `fib 40` does about 150 million calls (takes
several seconds), `fib 50` does about 20 billion calls (takes
minutes). The naive `fib` is unusable for any `n` past 40 or so.

## Why is naive Fibonacci so slow?

The cause is *overlapping subproblems*. When `fib 5` computes `fib 4
+ fib 3`, the call to `fib 4` itself computes `fib 3 + fib 2`. So
`fib 3` is computed *twice* (once directly, once inside `fib 4`).
`fib 2` is computed three times, `fib 1` five times, `fib 0` three
times. The deeper the recursion, the more redundant work.

The fix is to compute each value only once and feed it forward. The
cleanest way in a pure-functional style is to carry the last *two*
values as an accumulator pair and update them as you go:

```ocaml
let fib n =
  let rec go a b k =
    if k = n then a
    else go b (a + b) (k + 1)
  in
  go 0 1 0

let _ = fib 50
```

:::slide

## Why is naive Fibonacci so slow?

- `fib 5` computes `fib 4 + fib 3`.
- `fib 4` recomputes `fib 3 + fib 2`. `fib 3` is computed twice.
- Overlapping sub-problems blow up the work.

Faster: keep a pair `(a, b) = (fib (n-2), fib (n-1))`:

```ocaml
let fib n =
  let rec go a b k =
    if k = n then a
    else go b (a + b) (k + 1)
  in
  go 0 1 0

let _ = fib 50
```

- `int = 12586269025`. Linear in `n`, constant work per step.
- Tail-recursive accumulator-pair pattern.

:::

`fib 50` now returns `12586269025` immediately. The trick: the
accumulator holds *two* values rather than one. At each step, `a`
is `fib k` and `b` is `fib (k+1)`. The recursive call advances both:
the new `a` is `b` (the previous `fib (k+1)`), the new `b` is `a +
b` (the next Fibonacci number, by the recurrence).

The two-accumulator trick is the canonical way to make Fibonacci
fast. It works for any recurrence that depends on the last *k*
values: keep a window of those values as the accumulator. Many
common sequences (Lucas numbers, Padovan numbers, etc.) yield to
the same shape. The general technique of caching intermediate
results is called *memoisation*; we will see it more thoroughly
when we get to mutable state in
[Module 7](M07-L01-references.html).

This `fib` is also tail-recursive (the recursive `go` call is the
last thing in the else-branch), so it runs in constant stack space.
You can call `fib 1_000_000` without blowing the stack, although the
result is a number with hundreds of thousands of digits and would
overflow OCaml's native `int` long before that.

## Problem 2: GCD by Euclid

The greatest common divisor of two non-negative integers is
computed by Euclid's algorithm: if `b` is zero, the GCD is `a`;
otherwise, the GCD of `(a, b)` equals the GCD of `(b, a mod b)`. The
translation is one line:

```ocaml
let rec gcd a b =
  if b = 0 then a
  else gcd b (a mod b)

let _ = gcd 48 18
```

:::slide

## Problem 2: GCD by Euclid

```ocaml
let rec gcd a b =
  if b = 0 then a
  else gcd b (a mod b)

let _ = gcd 48 18
```

- `int = 6`. Classic Euclidean algorithm.
- Each step replaces `(a, b)` with `(b, a mod b)`.
- Base case `b = 0`; then `a` is the GCD.
- Termination: `a mod b < b`, so the second argument strictly decreases.
- Already tail-recursive.

:::

`gcd 48 18` returns `6`. Trace: `gcd 48 18` -> `gcd 18 12` ->
`gcd 12 6` -> `gcd 6 0` -> `6`.

Two things to notice. First, the function is already tail-recursive
without any rewriting. The recursive call is the final expression
in the else-branch; there is no work after it. The accumulator
pattern is unnecessary because the accumulation happens "for free"
as the argument pair, which gets smaller with each call.

Second, termination is guaranteed by the standard fact that `a mod
b < b` for `b > 0`. So each recursive call strictly decreases the
second argument, with `0` as the floor. The recursion is at most
`O(log(min(a, b)))` deep, a beautiful property of Euclid's algorithm.

For negative inputs, the behaviour depends on OCaml's `mod`, which
follows C: the sign of the result matches the sign of the dividend.
So `gcd (-48) 18` actually works correctly here (the algorithm
self-corrects), but the conventional definition of GCD is for
non-negative inputs, and a defensive version would `abs`-wrap both
inputs before recursing.

## Problem 3: nth element of a list

The classic list indexing function: given a list `xs` and an index
`n`, return the `n`-th element (zero-indexed).

```ocaml
let rec nth xs n =
  match xs with
  | [] -> failwith "nth: index out of range"
  | x :: rest -> if n = 0 then x else nth rest (n - 1)

let _ = nth [10; 20; 30; 40] 2
```

:::slide

## Problem 3: nth element of a list

```ocaml
let rec nth xs n =
  match xs with
  | [] -> failwith "nth: index out of range"
  | x :: rest -> if n = 0 then x else nth rest (n - 1)

let _ = nth [10; 20; 30; 40] 2
```

- `int = 30`. The 0-indexed third element.
- Tail-recursive: `nth rest (n - 1)` is the final expression.
- Out-of-bounds: `failwith` raises `Failure`.
- A nicer API returns `'a option`; see Module 4.

:::

Result: `30`. The function walks down the list and the counter
together: each step strips one element and decrements `n`. When `n
hits `0`, the head is the answer. If we run out of list before
hitting `n = 0`, the index was out of range.

Two design points. First, the recursive call `nth rest (n - 1)` is
in tail position; the function is tail-recursive without any
rewriting. The only "post-call work" you might worry about is the
`if`, but the `if` runs *before* the recursive call (it chooses
between returning `x` and recursing); after the call, there is
nothing.

Second, the error handling. `failwith "nth: index out of range"`
raises a `Failure` exception. This is a common idiom for "the input
doesn't make sense and there's no reasonable return value." A
cleaner alternative is to return `'a option`: `Some x` if the index
is valid, `None` if not. The option-returning variant is what
`List.nth_opt` in the standard library does. We will see `option`
properly in [M04-L05](M04-L05-option-and-aliases.html). For this
tutorial, `failwith` is fine.

## Problem 4: a tail-recursive `sum` for lists

We saw this in passing in
[M03-L04](M03-L04-tail-recursion.html#the-accumulator-pattern).
Worth showing alone, because `sum` is the simplest list-fold and a
useful reference for the shape:

```ocaml
let sum xs =
  let rec go acc = function
    | [] -> acc
    | x :: rest -> go (acc + x) rest
  in
  go 0 xs

let _ = sum [1; 2; 3; 4; 5]
```

:::slide

## Problem 4: a tail-recursive `sum` for lists

```ocaml
let sum xs =
  let rec go acc = function
    | [] -> acc
    | x :: rest -> go (acc + x) rest
  in
  go 0 xs

let _ = sum [1; 2; 3; 4; 5]
```

- `int = 15`.
- Standard accumulator pattern; constant stack.
- Stdlib's `List.fold_left` generalizes this; see Module 6.

:::

Result: `15`. Standard accumulator pattern, local helper, constant
stack space. You can sum a list of a million integers without
worry.

Once you see this shape often enough, you notice that it generalises:
*walk a list, fold each element into a running result, return the
result at the end.* The standard library function `List.fold_left`
captures exactly this pattern, parameterised by the per-step
operation. With `List.fold_left`, the same sum is one line:
`List.fold_left (+) 0 xs`. We will see
[`fold_left`](M06-L04-fold.html) and its relatives in Module 6.

## Problem 5: reverse a list

To reverse a list tail-recursively, accumulate by prepending: each
element you see goes on the *front* of the accumulator. The first
element seen ends up *deepest* in the accumulator, which is exactly
where it belongs in the reversed list.

```ocaml
let reverse xs =
  let rec go acc = function
    | [] -> acc
    | x :: rest -> go (x :: acc) rest
  in
  go [] xs

let _ = reverse [1; 2; 3; 4]
```

:::slide

## Problem 5: reverse a list

```ocaml
let reverse xs =
  let rec go acc = function
    | [] -> acc
    | x :: rest -> go (x :: acc) rest
  in
  go [] xs

let _ = reverse [1; 2; 3; 4]
```

- `int list = [4; 3; 2; 1]`.
- Each element prepended to the accumulator.
- First input ends up deepest; that's what reverse wants.
- Stdlib: `List.rev`.

:::

Trace: `go [] [1;2;3;4]` -> `go [1] [2;3;4]` -> `go [2;1] [3;4]` ->
`go [3;2;1] [4]` -> `go [4;3;2;1] []` -> `[4;3;2;1]`. The first
element seen (`1`) ends up at the deepest position; the last seen
(`4`) ends up at the front. That is exactly the reverse.

The standard library provides this as `List.rev`. You should rarely
write your own; the stdlib version is well-tested and identical in
structure to the version above. Worth writing once for practice,
then leaning on the library afterwards.

## When naive recursion is fine

A pragmatic note: not every recursive function needs to be
tail-recursive. If the input is bounded (you know `n` is at most a
few thousand, or the list has at most a few hundred elements), the
naive recursive form runs in plenty of stack and reads cleaner. The
extra clarity of `let rec sum xs = match xs with | [] -> 0 | x ::
rest -> x + sum rest` over the accumulator form is real, and worth
the constant-factor stack use when stack use is not a problem.

Tail recursion matters when:

- The input might be very large: lists with millions of elements,
  numeric arguments in the millions, recursion that walks deep
  trees.
- The function is called frequently and you want it cheap on any
  input.
- You are writing library code others will call with unknown-sized
  inputs.

For one-off computations on small data, write the natural recursive
form and move on. You can rewrite to tail-recursive later if a
profiler or a stack overflow tells you to.

## Problem 6: counting digits

The number of digits in a non-negative integer is the number of
times you can divide it by 10 before reaching zero. The natural
recursion:

```ocaml
let rec count_digits n =
  if n < 10 then 1
  else 1 + count_digits (n / 10)

let _ = count_digits 12345
```

:::slide

## Problem 6: counting digits

```ocaml
let rec count_digits n =
  if n < 10 then 1
  else 1 + count_digits (n / 10)

let _ = count_digits 12345
```

- `int = 5`.
- Strips one digit at a time; base case is single-digit.
- Negative inputs misbehave: `<` is true at once, returning `1`.
- Guard with `abs`:

```ocaml
let count_digits n =
  let rec go n =
    if n < 10 then 1
    else 1 + go (n / 10)
  in
  go (abs n)
```

- `abs` strips the sign before counting.

:::

Result: `5`. The recursion strips one digit per step. The base case
is "a single-digit number" (`n < 10`), which catches both `0`
through `9` and recursive calls when the remaining `n` is below 10.

A subtle bug: negative inputs do not terminate cleanly. OCaml's `/`
truncates toward zero, so `(-12345) / 10` is `-1234` (not `-1235`).
The base test `n < 10` is true for all negatives, so the recursion
returns immediately with `1`, which is wrong. Even worse, with a
different base test like `n = 0`, you would get an infinite
recursion. The defensive version uses `abs`:

```ocaml
let count_digits n =
  let rec go n =
    if n < 10 then 1
    else 1 + go (n / 10)
  in
  go (abs n)
```

This strips the sign at the outermost call; the helper `go` only
ever sees non-negative inputs. The pattern (a defensive outer
function plus a local helper that handles only the well-behaved
case) is one we will see again. The helper is local because nobody
outside `count_digits` needs it; the outer function is the API.

Note that `count_digits 0` returns `1`, which matches the convention
that the integer `0` has one digit (the digit `0`). If you wanted a
different convention you would adjust the base case.

## Activity: `last` for lists

:::slide

## Activity

Write `last : 'a list -> 'a option`:

- Returns last element, or `None` if empty.
- Must be tail-recursive (works on a million-element list).

:::

Try this before reading the solution. The hint: the *last* element
of a non-empty list is "the head of a singleton," after you have
stripped the earlier elements. Recursion on the list shape, with a
special case for the singleton.

:::slide

## Activity solution

```ocaml
let rec last = function
  | [] -> None
  | [x] -> Some x
  | _ :: rest -> last rest
```

Three cases:

- `[]`: no last element.
- `[x]`: only element is the last.
- `_ :: rest`: drop head, recur.

- `last rest` is the final expression: tail-recursive.
- `option` makes the empty case explicit; covered in Module 4.

:::

Three pattern-match cases:

- `[]` -> `None`. The empty list has no last element. Returning
  `None` is the honest answer.
- `[x]` -> `Some x`. A singleton list's last element is its only
  element. The pattern `[x]` matches a list with exactly one
  element and binds that element to `x`. Equivalent to `x :: []`.
- `_ :: rest` -> `last rest`. Any longer list: strip the head, recur
  on the rest. The patterns are tried in order, so we already know
  this case has at least two elements (otherwise `[x]` would have
  matched).

The recursive call is in tail position (it is the entire body of its
case), so the function runs in constant stack space.

The `option` return type is the right choice here because there is
no sensible value of type `'a` to return for an empty list. We could
have raised an exception with `failwith`, but `option` makes the
empty case visible *in the type*, forcing callers to handle it. We
will see `option` in detail in
[M04-L05](M04-L05-option-and-aliases.html#the-option-type).

## A small code challenge

:::quiz code id=M03-L06-q1
Write `take : int -> 'a list -> 'a list` that returns the first `n`
elements of a list. If the list has fewer than `n` elements, return
the whole list. If `n <= 0`, return `[]`.

```ocaml
let rec take n xs =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (take 0 [1;2;3]    = [])         "n=0";
  check (take 2 [1;2;3;4]  = [1;2])      "n=2";
  check (take 5 [1;2;3]    = [1;2;3])    "n exceeds length";
  check (take 3 ([] : int list) = [])    "empty list";
  check (take (-1) [1;2;3] = [])         "n negative";
  print_endline "all tests passed"
```
:::

The natural recursive shape: three cases. If `n <= 0`, return `[]`.
If the list is empty, return `[]`. Otherwise, cons the head onto
`take (n - 1) rest`. This version is *not* tail-recursive (the cons
runs after the recursive call), which is fine for most uses; a
tail-recursive version would accumulate-then-reverse like the
[`map` in M03-L04](M03-L04-tail-recursion.html#when-clean-tail-recursion-is-hard).

## What you should be able to do now

:::slide

## What you should be able to do now

After Module 3 you can:

- Define functions, including anonymous functions with `fun`.
- Use partial application (`add 5`).
- Write recursive functions with base and recursive cases.
- Convert to tail-recursive with an accumulator.
- Use local helpers and mutual recursion.

Module 4: **data types** (tuples, records, variants, recursive).

:::

By the end of Module 3 you can:

- Define a function with `let`, anonymous-function form `fun x ->
  ...`, or the curried multi-argument form `let f x y z = ...`.
- Read function types: `int -> int -> int` is right-associative,
  meaning `int -> (int -> int)`. A multi-argument function is
  really a function of one argument returning a function.
- Partially apply a curried function: `add 5` is a function value.
- Write recursive functions with `let rec`, in their natural
  inductive form (base case plus recursive case that reduces
  toward it).
- Convert a non-tail-recursive function to tail-recursive using an
  accumulator parameter.
- Use local helpers via `let rec go ... in ...` and write mutually
  recursive functions with `let rec ... and ... = ...`.

[Module 4](M04-L01-tuples.html) turns to *data types*: tuples,
records, and variants (the algebraic data types that distinguish
ML-family languages from mainstream OOP). Pattern matching, which
we have previewed all through Module 3, takes centre stage in
[Module 5](M05-L01-basic-patterns.html).

## Reading

- **Cornell CS3110**, *Recursion examples*: the textbook's worked
  examples, with more variations on the patterns above:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
- **Real World OCaml**, *Lists and Patterns*: the corresponding
  chapter, with a heavy emphasis on the list-recursion idioms:
  <https://dev.realworldocaml.org/lists-and-patterns.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
