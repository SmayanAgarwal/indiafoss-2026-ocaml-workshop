---
title: "Tail recursion and accumulators"
lecture_no: 4
week: 3
duration_target_min: 25
concepts: [tail call, tail-recursive functions, accumulator pattern, stack frames]
keywords: [OCaml, tail recursion, accumulator, stack overflow, optimization]
activity_question: "Rewrite [let rec sum n = if n = 0 then 0 else n + sum (n - 1)] as a tail-recursive function using an accumulator."
think_about_this: "Why does the compiler need to *recognize* a tail call, instead of optimizing every recursive call? What does a non-tail call need to keep on the stack that a tail call doesn't?"
reading:
  - title: "Cornell CS3110, Tail recursion"
    url: https://cs3110.github.io/textbook/chapters/basics/functions.html
---

# Tail recursion and accumulators

The naive `factorial` and `sum` we wrote in Lecture 2 work fine for
small inputs and crash with a stack overflow for big ones. This
lecture shows why, and how to rewrite them in a form that runs in
constant stack space: **tail recursion**.

You will rewrite real OCaml code in this style routinely. The
pattern is small (an extra parameter, an `aux` helper) but the
payoff is large (your functions stop crashing on big inputs).

:::slide

## What a stack overflow looks like

```ocaml
let rec sum_to n =
  if n = 0 then 0
  else n + sum_to (n - 1)

let _ = sum_to 1_000_000
```

This will crash with `Stack overflow during evaluation`.

Why? Each call to `sum_to` allocates a stack frame to remember
*what to do with the recursive result*. The recursive case is
`n + sum_to (n - 1)`. After `sum_to (n - 1)` returns, we still
need to add `n` to its result. To do that, we must remember `n`
across the recursive call.

One million recursive calls means one million stack frames, each
holding a copy of `n`. The stack runs out.

:::

:::slide

## A tail call is a recursive call with nothing left to do

A function call is **in tail position** if its result is the
*final* result of the enclosing function: nothing happens after
the call returns.

```ocaml
let rec f n = if n = 0 then 0 else f (n - 1)    (* tail call *)
let rec g n = if n = 0 then 0 else 1 + g (n - 1)  (* NOT tail call *)
```

In `f`, when `f (n - 1)` returns, `f` immediately returns the same
value. The compiler does not need to keep a stack frame for the
outer call.

In `g`, when `g (n - 1)` returns, we still need to compute `1 +
...`. The outer frame must persist.

:::

:::slide

## OCaml optimizes tail calls

When OCaml's compiler sees a recursive call in tail position, it
*reuses* the current stack frame instead of allocating a new one.
This is the **tail-call optimization** (TCO). Effect: a
tail-recursive function uses *constant* stack space, no matter how
many recursive calls it makes.

You don't need to enable this; it happens automatically. You just
need to write your recursion in tail form.

:::

:::slide

## The accumulator pattern

To turn `sum_to` into a tail-recursive function, we move the
"work" *before* the recursive call instead of after it. We pass
the running total as an extra parameter.

```ocaml
let sum_to n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc + n) (n - 1)
  in
  go 0 n

let _ = sum_to 1_000_000
```

`int = 500000500000`. No stack overflow.

The helper `go` takes the running total (`acc`) and the remaining
work (`n`). At each step it adds `n` to the accumulator, then recurs
on `(acc + n, n - 1)`. The recursive call is the *final*
expression in the else-branch: tail call.

:::

The accumulator pattern is the canonical way to turn a
non-tail-recursive function into a tail-recursive one. You add an
extra parameter that carries the partial result; the function
returns that parameter when it hits the base case.

:::slide

## Walking through it

`sum_to 4` calls `go 0 4`.

```
go 0 4  =>  go (0+4) 3  =>  go 4 3
go 4 3  =>  go (4+3) 2  =>  go 7 2
go 7 2  =>  go (7+2) 1  =>  go 9 1
go 9 1  =>  go (9+1) 0  =>  go 10 0
go 10 0 =>  10                          (base case hit)
```

Each step computes the new accumulator *before* the recursive call.
By the time we reach `n = 0`, the accumulator holds the full sum.

This is exactly the loop a procedural language would write:
`int acc = 0; for (int i = n; i > 0; i--) acc += i; return acc;`.
The tail-recursive form is the same loop, written without
mutation.

:::

:::slide

## Factorial, tail-recursive

```ocaml
let factorial n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc * n) (n - 1)
  in
  go 1 n

let _ = factorial 10
```

`int = 3628800`. Same pattern: the running product is passed as
`acc`. Base case: return `acc`.

Note: `factorial 100` overflows OCaml's `int` (the math, not the
stack). For arbitrary-precision factorial you'd reach for `Zarith`.

:::

:::slide

## Length of a list, tail-recursive

```ocaml
let length xs =
  let rec go acc = function
    | [] -> acc
    | _ :: rest -> go (acc + 1) rest
  in
  go 0 xs

let _ = length [10; 20; 30; 40]
```

`int = 4`. The accumulator counts how many elements we've
*already* seen. When we hit `[]` we return the count.

This is the form `List.length` is written in inside the standard
library. It runs in constant stack space regardless of list length.

:::

:::slide

## When you can't easily go tail-recursive

Some functions resist a clean accumulator rewrite, because the
"work after the recursive call" is not associative-commutative.

```ocaml
let rec map f = function
  | [] -> []
  | x :: rest -> f x :: map f rest
```

`f x :: map f rest` is *not* tail-recursive (we still need to
prepend `f x` after the recursive call). A tail-recursive version
requires building the list in reverse, then reversing at the end:

```ocaml
let map f xs =
  let rec go acc = function
    | [] -> List.rev acc
    | x :: rest -> go (f x :: acc) rest
  in
  go [] xs
```

We accumulate in reverse, then `List.rev` at the end. Two passes
through the list, but constant stack.

For very long lists, this is the right shape. The standard library's
`List.map` is *not* tail-recursive for historical reasons; for very
long lists, reach for `List.rev (List.rev_map f xs)` instead.

:::

:::slide

## A heuristic for spotting tail calls

After the recursive call returns, is there *any* computation left in
the function?

- If yes, it is **not** a tail call.
- If no, it is a tail call.

Test it on each of these:

```ocaml
let rec a n = if n = 0 then 0 else a (n - 1) + 1
let rec b n = if n = 0 then 0 else 1 + b (n - 1)
let rec c n = if n = 0 then 0 else if n > 100 then c (n - 100) else c (n - 1)
```

`a`: not tail (we add `1` after). `b`: not tail. `c`: yes, both
branches' recursive calls are the final expressions.

:::

:::slide

## Activity

Rewrite this in tail-recursive form using an accumulator:

```ocaml
let rec sum n =
  if n = 0 then 0
  else n + sum (n - 1)
```

:::

:::slide

## Activity solution

```ocaml
let sum n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc + n) (n - 1)
  in
  go 0 n
```

The shape:

- New top-level function with the original signature.
- Inner helper `go` with an extra parameter `acc`.
- Base case returns `acc`.
- Recursive case folds the current step into `acc` and recurs.

This shape will become muscle memory by Module 4.

:::

:::slide

## What's next

Lecture 5: **local functions and mutual recursion**. We make the
`go`-inside-a-function pattern explicit, and write functions that
refer to *each other*.

:::

## Reading

- **Cornell CS3110**, *Tail recursion*:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
