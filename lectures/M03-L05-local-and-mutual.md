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

- `go` is defined *inside* `factorial` with `let rec ... in`.
- In scope only for the rest of that expression.
- Outside `factorial`, the name `go` doesn't exist.
- Right place for a helper that's only useful as implementation detail of one outer function.

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

- This works.
- Downside: `factorial_go` is now a public name.
- Anyone reading your code or using autocomplete sees it.
- They might call `factorial_go 0 5` and get `0`: wrong answer that the `factorial` API would have prevented.
- A local `let rec ... in` keeps the helper invisible to callers.
- The *encapsulation* argument for local definitions, and the default choice.

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

- `sum` is general-purpose; `average` uses it.
- Both top-level, both public.

Rule of thumb:

- Helper has a meaningful name *other callers might want*: top-level.
- Tactical aid for one function (accumulator-passing version, unfolded base case): local.

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

- `true, false`.
- Each function calls the other.
- Tied together by the `and` keyword.
- Without `and`, the first couldn't see the second (not defined yet).
- With `and`, both names are in scope simultaneously and can reference each other.

:::

:::slide

## Why `and`, not `let` twice?

```ocaml
let rec is_even n = if n = 0 then true  else is_odd  (n - 1)
let rec is_odd  n = if n = 0 then false else is_even (n - 1)
```

- OCaml rejects the first line: `Unbound value is_odd`.
- When the first `let rec` is processed, `is_odd` doesn't exist yet.
- The `and` keyword threads multiple recursive definitions through one name-resolution step:

```
let rec X = ... and Y = ... and Z = ...
```

- All of `X`, `Y`, `Z` are in scope inside each body.
- Exactly what mutual recursion requires.

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

- `read_number` calls `read_op`, which calls `read_number`.
- Together they implement a small recursive-descent parser.
- Mutual recursion is the natural fit.

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

- Single-recursive example.
- `let rec` and `and` work inside `in` expressions the same way:

```ocaml
let demo () =
  let rec ping n =
    if n = 0 then "done"
    else pong (n - 1)
  and pong n = ping n
  in
  ping 5
```

- `string = "done"`.
- The two local helpers refer to each other.

:::

:::slide

## Activity

Write `is_even` and `is_odd` using mutual recursion, with the only
arithmetic being "subtract 1 and compare to 0" (no `mod`, no `&&
even logic`):

```ocaml skip
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

Trace for `is_even 6`:

- `is_even 6 → is_odd 5 → is_even 4 → is_odd 3 → is_even 2 → is_odd 1 → is_even 0 → true`.

Trace for `is_odd 6`:

- `is_odd 0 = false`.
- `is_even 1 = is_odd 0 = false`.
- `is_odd 2 = is_even 1 = false`.
- `is_even 3 = is_odd 2 = false`.
- `is_odd 4 = is_even 3 = false`.
- `is_even 5 = is_odd 4 = false`.
- `is_odd 6 = is_even 5 = false`. Correct: 6 is not odd.

Notes:

- This is in tail position (calling a *different* function).
- OCaml handles tail calls between mutually recursive functions the same way.
- So this *is* constant-stack.
- For large `n`, prefer `n mod 2 = 0`.
- The mutual-recursion version is a clean illustration of the pattern.

:::

:::slide

## What's next

Lecture 6: the **tutorial** for Module 3.

- Work through `fib`, `gcd`, and a small list utility.
- Trade-offs between naive recursion and tail recursion.

:::

## Reading

- **Cornell CS3110**, *Helper functions*:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
