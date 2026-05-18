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

Three classic problems, two list helpers, and a discussion of when
naive recursion is enough vs when you need the tail-recursive
variant.

:::slide

## Problem 1: Fibonacci, naively

```ocaml
let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)

let _ = fib 20
```

`int = 6765`. Two recursive calls per step. The call tree
*branches*: `fib 20` calls `fib 19` and `fib 18`; each of those
makes two more calls; and so on. The total number of calls is
exponential in `n`.

Try `fib 30`. It works, slowly. `fib 40` will take a while. `fib
50` is impractical.

:::

:::slide

## Why is naive Fibonacci so slow?

`fib 5` computes `fib 4 + fib 3`. `fib 4` recomputes `fib 3 + fib
2`. So `fib 3` is computed *twice*. Going down, `fib 2` is
computed three times. `fib 1` is computed five times. `fib 0`,
three.

The work blows up because we keep recomputing overlapping
sub-problems.

A faster fix: keep a *pair* `(a, b) = (fib (n-2), fib (n-1))` and
update them iteratively:

```ocaml
let fib n =
  let rec go a b k =
    if k = n then a
    else go b (a + b) (k + 1)
  in
  go 0 1 0

let _ = fib 50
```

`int = 12586269025`. Constant work per step. Linear in `n`. The
tail-recursive accumulator-pair pattern again.

:::

The two-accumulator trick is the canonical way to make Fibonacci
fast. It works for any recurrence that depends on the last *k*
values: keep a window of those values as the accumulator. Many
common sequences (Lucas, Padovan, etc.) yield to the same shape.

:::slide

## Problem 2: GCD by Euclid

```ocaml
let rec gcd a b =
  if b = 0 then a
  else gcd b (a mod b)

let _ = gcd 48 18
```

`int = 6`. The classic Euclidean algorithm. At each step, we
replace `(a, b)` with `(b, a mod b)`. The base case is when `b =
0`; then `a` is the GCD.

Termination: `a mod b < b` for positive `b`, so the second argument
strictly decreases. The argument is always non-negative (`mod`
returns a non-negative result for non-negative inputs in OCaml), so
it reaches zero in finite steps.

This is already tail-recursive: the recursive call is the final
expression.

:::

:::slide

## Problem 3: nth element of a list

```ocaml
let rec nth xs n =
  match xs with
  | [] -> failwith "nth: index out of range"
  | x :: rest -> if n = 0 then x else nth rest (n - 1)

let _ = nth [10; 20; 30; 40] 2
```

`int = 30`. The 0-indexed third element.

This is *almost* tail-recursive: the recursive call `nth rest
(n - 1)` is the final expression on the right branch of the `if`.
The else-branch on the empty list raises, which is fine.

For out-of-bounds, we use `failwith` which raises `Failure`. A
nicer API would return `'a option`; we'll see that in Module 4.

:::

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

`int = 15`. Standard accumulator pattern. Works on lists of any
length without overflowing the stack.

The standard library's `List.fold_left` generalizes this pattern;
we'll meet it in Module 6.

:::

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

`int list = [4; 3; 2; 1]`. Each element is prepended to the
accumulator. The first element of the input ends up *deepest* in
the accumulator, which is what we want for a reverse.

The standard library has this as `List.rev`.

:::

## When naive recursion is fine

Not every recursive function needs to be tail-recursive. If the
input is bounded (you know `n` is at most a few thousand), the
stack will not overflow and the simpler version is fine.

Tail recursion matters when:

- The input might be very large (lists with millions of elements,
  inputs in the millions).
- The function is called frequently and you want it to be cheap on
  any input.

For one-off computations on small data, write the natural recursive
form and move on.

:::slide

## Problem 6: counting digits

```ocaml
let rec count_digits n =
  if n < 10 then 1
  else 1 + count_digits (n / 10)

let _ = count_digits 12345
```

`int = 5`. Stripping one digit at a time; base case is a
single-digit number.

Negative inputs would loop forever (`-5 / 10` is `0` in some
languages but `-1` rounded toward zero in OCaml, hmm; check). Add
a guard for safety:

```ocaml
let count_digits n =
  let rec go n =
    if n < 10 then 1
    else 1 + go (n / 10)
  in
  go (abs n)
```

`abs` strips the sign before counting.

:::

:::slide

## Activity

Write a function `last : 'a list -> 'a option` that returns the
last element of a list, or `None` if the list is empty.

Make it tail-recursive (i.e., works on a one-million-element list
without stack overflow).

:::

:::slide

## Activity solution

```ocaml
let rec last = function
  | [] -> None
  | [x] -> Some x
  | _ :: rest -> last rest
```

Three cases:

- `[]`: empty list, no last element.
- `[x]`: single-element list, the only element is the last.
- `_ :: rest`: throw away the head, recur on the rest.

The recursive call `last rest` is the final expression in its case:
this *is* tail-recursive. OCaml will optimize it; no stack overflow
on million-element lists.

Why `option`? Because there is no sensible "last element of an
empty list" to return. `'a option` makes this explicit: the caller
must handle both `Some x` and `None`. We'll see more of `option`
in Module 4.

:::

:::slide

## What you should be able to do now

After Module 3 you can:

- Define functions, including anonymous functions with `fun`.
- Use partial application (`add 5`, `between 0 10`).
- Write recursive functions in their natural form, with base and
  recursive cases.
- Convert a non-tail-recursive function to tail-recursive with an
  accumulator.
- Use local helpers (`let rec go ... in`) and mutual recursion
  (`let rec X ... and Y ...`).

Module 4 turns to **data types**: tuples, records, variants, and
their recursive counterparts (the structure we use to model real
problems). Pattern matching, which we've been previewing, takes
center stage in Module 5.

:::

## Reading

- **Cornell CS3110**, *Recursion examples*:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
