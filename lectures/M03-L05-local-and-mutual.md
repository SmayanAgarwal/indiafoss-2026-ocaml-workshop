---
title: "Local functions and mutual recursion"
lecture_no: 5
week: 3
duration_target_min: 22
concepts: [local let-bindings of functions, helper functions, mutual recursion, `and` keyword]
keywords: [OCaml, local functions, mutual recursion, and, helper, let rec ... and]
activity_question: "Write [is_even] and [is_odd] using mutual recursion, with no arithmetic except subtracting 1 and comparing to 0. What is the keyword that ties the two definitions together?"
think_about_this: "When is a helper function better as a local [let ... in] inside another function vs. a top-level definition? What changes when you make it top-level?"
reading:
  - title: "Cornell CS3110, Helper functions"
    url: https://cs3110.github.io/textbook/chapters/basics/functions.html
---

# Local functions and mutual recursion

Two related topics: how to *hide* a helper function inside another
function so it isn't part of your public API, and how to define
functions that call *each other*.

:::slide

## Local helpers with `let ... in`

You've already seen this in tail-recursive rewrites:

```ocaml
let factorial n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc * n) (n - 1)
  in
  go 1 n
```

`go` is defined *inside* the body of `factorial` with a `let rec
... in`. It is in scope only for the rest of that expression.
Outside `factorial`, the name `go` doesn't exist.

This is the right place for a helper that's only useful as
implementation detail of one outer function.

:::

The local helper pattern is core to readable OCaml. When you have a
function that needs an accumulator, or a different argument order
from what the caller expects, define the helper locally and shape
the outer function to be the API you want callers to see.

```ocaml
let reverse xs =
  let rec go acc = function
    | [] -> acc
    | x :: rest -> go (x :: acc) rest
  in
  go [] xs
```

The caller sees `reverse : 'a list -> 'a list`. They don't see `go`;
they don't need to know about `acc`. Local helpers let you build
that clean external shape.

:::slide

## Why not just top-level?

```ocaml
let rec factorial_go acc n =
  if n = 0 then acc
  else factorial_go (acc * n) (n - 1)

let factorial n = factorial_go 1 n
```

This works. The downside: `factorial_go` is now a public name.
Anyone reading your code or autocomplete-listing your module sees
it as an option. They might call it with `factorial_go 0 5` and get
`0`, which is a wrong answer that the API of `factorial` would have
prevented.

A local `let rec ... in` keeps the helper invisible to callers.
That's the *encapsulation* argument for local definitions, and the
default choice.

:::

:::slide

## When to make a helper top-level

Sometimes the "helper" is useful on its own:

```ocaml
let rec sum xs = match xs with
  | [] -> 0
  | x :: rest -> x + sum rest

let average xs =
  sum xs / List.length xs
```

`sum` is general-purpose; `average` uses it. Top-level. Both are
public.

Rule of thumb: if the helper has a meaningful name *other callers
might want*, make it top-level. If it's a tactical aid for one
function (an accumulator-passing version, an unfolded base case,
etc.), make it local.

:::

:::slide

## Mutual recursion

Two functions can call each other:

```ocaml
let rec is_even n =
  if n = 0 then true
  else is_odd (n - 1)
and is_odd n =
  if n = 0 then false
  else is_even (n - 1)

let _ = is_even 10
let _ = is_odd 10
```

`true, false`. Each function calls the other. The two are tied
together by the `and` keyword.

Without `and`, the first function couldn't see the second (because
the second isn't defined yet). With `and`, both names are brought
into scope simultaneously, and each can reference the other.

:::

:::slide

## Why `and`, not `let` twice?

```ocaml
let rec is_even n = if n = 0 then true  else is_odd  (n - 1)
let rec is_odd  n = if n = 0 then false else is_even (n - 1)
```

OCaml rejects the first line: `Unbound value is_odd`. At the time
the first `let rec` is processed, `is_odd` does not exist yet.

The `and` keyword threads multiple recursive definitions through a
single name-resolution step:

```
let rec X = ... and Y = ... and Z = ...
```

All of `X`, `Y`, `Z` are in scope inside each body. That's exactly
what mutual recursion requires.

:::

:::slide

## A real-world example: parsing a token

```ocaml
(* a tiny imaginary parser: read a number, possibly followed by an
   operator and another number *)

let rec read_number tokens =
  match tokens with
  | [] -> None
  | t :: rest -> read_op (int_of_string t) rest
and read_op n tokens =
  match tokens with
  | [] -> Some n
  | "+" :: rest -> begin match read_number rest with
                   | None -> None
                   | Some m -> Some (n + m)
                   end
  | _ -> None
```

`read_number` calls `read_op`, which calls `read_number`. The two
implement a small recursive-descent parser together. Mutual
recursion here is the natural fit.

:::

The two-function ping-pong is a frequent shape in parsers, tree
walkers (where each kind of node has its own handling but trees
nest), and state machines. Anything that has "alternating" or
"toggling" behaviour ends up wanting this.

:::slide

## Mutual recursion can also be local

```ocaml
let collatz n =
  let rec step n =
    if n = 1 then [1]
    else if n mod 2 = 0 then n :: step (n / 2)
    else n :: step (3 * n + 1)
  in
  step n
```

That example is single-recursive, but `let rec` and `and` work
inside an `in` expression the same way:

```ocaml
let demo () =
  let rec ping n =
    if n = 0 then "done"
    else pong (n - 1)
  and pong n = ping n
  in
  ping 5
```

`string = "done"`. The two local helpers refer to each other.

:::

:::slide

## Activity

Write `is_even` and `is_odd` using mutual recursion, with the only
arithmetic being "subtract 1 and compare to 0" (no `mod`, no `&&
even logic`):

```ocaml
let rec is_even n = ???
and is_odd n = ???
```

:::

:::slide

## Activity solution

```ocaml
let rec is_even n =
  if n = 0 then true
  else is_odd (n - 1)
and is_odd n =
  if n = 0 then false
  else is_even (n - 1)
```

`is_even 6` calls `is_odd 5`, which calls `is_even 4`, ..., down
to `is_odd 0` which is `false`... wait, let me retrace.

`is_even 6 → is_odd 5 → is_even 4 → is_odd 3 → is_even 2 → is_odd 1 → is_even 0 → true`.

`is_odd 6 → is_even 5 → is_odd 4 → ... → is_even 0 → true`... hmm,
let me recheck. `is_odd 0 = false`. `is_even 1 = is_odd 0 = false`.
`is_odd 2 = is_even 1 = false`. `is_even 3 = is_odd 2 = false`.
`is_odd 4 = is_even 3 = false`. `is_even 5 = is_odd 4 = false`.
`is_odd 6 = is_even 5 = false`. Correct: 6 is not odd.

Note: this isn't tail-recursive (the recursive call is in tail
position, but it's calling a *different* function; the OCaml
compiler handles tail-calls between mutually recursive functions
the same way, so this *is* in fact constant-stack).

For very large `n`, prefer `n mod 2 = 0`. But the mutual-recursion
version is a clean illustration of the pattern.

:::

:::slide

## What's next

Lecture 6: the **tutorial** for Module 3. We work through `fib`,
`gcd`, a small list utility, and the trade-offs between naive
recursion and tail recursion.

:::

## Reading

- **Cornell CS3110**, *Helper functions*:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
