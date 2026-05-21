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


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Local functions and mutual recursion</h2>
<p class="title-slide-label">Module 3 &middot; Lecture 5</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

Two related topics in this lecture. The first is *local* function
definitions: helpers defined inside another function with
`let ... in`, scoped only to that outer function. The second is
*mutual recursion*: two or more functions that call each other,
glued together with the `and` keyword. Both are ordinary features
of day-to-day OCaml; you have already seen the first in passing
(every tail-recursive function in
[M03-L04](M03-L04-tail-recursion.html#the-accumulator-pattern)
used a local helper), and the second turns up the moment you
write a parser, a tree walker, or the classic `is_even` /
`is_odd` example.

Neither topic is conceptually deep. The point of the lecture is to
give you the conventions: when to make a helper local vs.
top-level, and what the `and` keyword does and why it has to exist.

## Local helpers: definitions inside `let ... in`

We saw `let rec go ... in ...` in every tail-recursive rewrite in
[M03-L04](M03-L04-tail-recursion.html#the-accumulator-pattern).
The keyword combination defines `go` only inside the body of the
outer function:

```ocaml
let factorial n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc * n) (n - 1)
  in
  go 1 n
```

The shape: an outer function `factorial` with the API you want
callers to see, an inner helper `go` doing the real work, and a
call `go 1 n` to start the recursion. The name `go` is *not* visible
outside `factorial`; you cannot call `go 1 5` from somewhere else
in the file.

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

- `go` defined *inside* `factorial` with `let rec ... in`.
- In scope only for the rest of that expression.
- Right place for an implementation-detail helper.

:::

The encapsulation matters more than it might first appear. Once a
name is part of a file's top-level scope, anyone reading the file
sees it. It autocompletes. It shows up in error messages. It might
get exported in an `.mli` (interface file), to be discussed in
[Module 7](M07-L05-signatures.html). If the helper is genuinely an
implementation detail of one function, all of that is noise. Local
definitions keep the top-level surface clean.

The local helper pattern is core to readable OCaml. When you have a
function that needs an accumulator, or a different argument order
from what the caller expects, define the helper locally and shape
the outer function to be the API you want callers to see. Here is
another standard example, the tail-recursive `reverse`:

```ocaml
let reverse xs =
  let rec go acc = function
    | [] -> acc
    | x :: rest -> go (x :: acc) rest
  in
  go [] xs
```

The caller sees `reverse : 'a list -> 'a list`. They do not see
`go`; they do not need to know about `acc`. Local helpers let you
build that clean external shape.

## Why not just top-level?

You can, of course, write the same thing with a top-level helper:

```ocaml
let rec factorial_go acc n =
  if n = 0 then acc
  else factorial_go (acc * n) (n - 1)

let factorial n = factorial_go 1 n
```

It works. The factorial function behaves exactly the same. But the
helper `factorial_go` is now a public name. Anyone reading the file
or using IDE autocomplete will see it. They might call
`factorial_go 0 5` and get `0` (because the accumulator starts at
zero, and `0 * anything` is zero). That is a wrong answer the
`factorial` API would have prevented.

:::slide

## Why not just top-level?

```ocaml
let rec factorial_go acc n =
  if n = 0 then acc
  else factorial_go (acc * n) (n - 1)

let factorial n = factorial_go 1 n
```

- This works.
- Downside: `factorial_go` is a public name.
- Callers could pass `factorial_go 0 5` and silently get `0`.
- A local `let rec ... in` hides the helper.
- Encapsulation: the default choice.

:::

This is the same argument as for `private` methods in object-oriented
languages, or `static` functions in C: by default, hide
implementation details. Expose only the API. In OCaml the
hiding-mechanism for functions inside another function is `let ...
in`; the hiding-mechanism for functions inside a module is the
[`.mli` file](M07-L05-signatures.html#signatures-in-mli-files).
Both exist for the same reason: smaller surface, fewer ways for
callers to misuse the code.

## When to make a helper top-level

The other end of the trade-off: sometimes the "helper" is genuinely
useful on its own. If multiple callers want to sum a list, `sum`
should be top-level. If one caller wants to compute the average and
needs a sum along the way, you do not want a private accumulator
hidden inside `average`; you want a public `sum` that anyone can
reuse.

```ocaml
let rec sum xs = match xs with
  | [] -> 0
  | x :: rest -> x + sum rest

let average xs =
  sum xs / List.length xs
```

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

- Reusable name other callers might want: top-level.
- Tactical helper for one function: local.

:::

The rule of thumb:

- *Top-level* if the helper has a meaningful, reusable name that other
  callers might want. `sum`, `last`, `find`, `gcd`. The function
  stands on its own.
- *Local* if the helper is a tactical aid for one outer function: an
  accumulator-passing version, an unfolded base case, a renamed-and-reordered
  variant. `go`, `aux`, `loop`. Nobody outside the
  outer function would want to call it.

You will get a feel for this with practice. The bias in idiomatic
OCaml is toward locals: if in doubt, hide it. You can always promote
a local helper to top-level if a second caller materialises. Going
the other way (making a top-level function local) is harder, because
you do not know who is already using it.

## Mutual recursion: two functions calling each other

Sometimes the natural shape of a problem is not "one function calls
itself" but "two functions call each other." The classic, slightly
contrived example is parity by recursion:

```ocaml
let rec is_even n =
  if n = 0 then true
  else is_odd (n - 1)
and is_odd n =
  if n = 0 then false
  else is_even (n - 1)
```

`is_even 10` is `true`. `is_odd 10` is `false`. Each function calls
the other, not itself: `is_even`'s recursive case calls `is_odd`,
and vice versa. The recursion alternates between the two functions
until one of them hits the base case.

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
- Tied together by `and`.
- Both names in scope simultaneously inside both bodies.

:::

The new piece of syntax is the `and` keyword joining the two
definitions. The combined declaration is one big `let rec`:
`let rec is_even ... and is_odd ...`. Both names are introduced
together, and both names are in scope inside *both* bodies. That is
exactly what mutual recursion needs.

## Why `and` has to exist

Suppose you tried to write the two functions as separate `let rec`s:

```ocaml
let rec is_even n = if n = 0 then true  else is_odd  (n - 1)
let rec is_odd  n = if n = 0 then false else is_even (n - 1)
```

OCaml rejects the first line: `Unbound value is_odd`. The reason is
the same one we saw for `let rec` vs. plain `let` in
[M03-L02](M03-L02-recursion.html#why-let-rec-and-not-just-let):
a `let rec` brings the name being defined into scope inside its
own body, but not *other* names that have not been defined yet.
When the compiler processes the first `let rec is_even`, the name
`is_odd` does not exist yet, so the reference to `is_odd` in
`is_even`'s body fails.

:::slide

## Why `and`, not `let` twice?

```ocaml
let rec is_even n = if n = 0 then true  else is_odd  (n - 1)
let rec is_odd  n = if n = 0 then false else is_even (n - 1)
```

- OCaml rejects the first line: `Unbound value is_odd`.
- When `let rec is_even` is processed, `is_odd` doesn't exist yet.
- `and` threads multiple definitions through one name-resolution step:

```
let rec X = ... and Y = ... and Z = ...
```

- All names in scope inside each body.

:::

The `and` keyword joins multiple recursive definitions into a single
declaration. All the names introduced by the joined declaration are
visible inside *all* the bodies. There is no limit to how many
functions can be joined: `let rec f = ... and g = ... and h = ...
and ...`. Two is by far the most common; three or four show up in
parsers and tree walkers; more than that is unusual.

A subtle property worth noting: `and` does *not* mean "evaluate
sequentially." All the bodies are processed by the type checker
together, with all the names already in scope. There is no left-to-right
dependency. You can write the definitions in any order; the
compiler will figure out which calls which.

## A real-world example: a tiny parser

The two-function ping-pong is not as artificial as `is_even` /
`is_odd` suggests. The shape shows up the moment you write a
recursive-descent parser, where each grammar rule is a function and
the rules call each other.

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

- `read_number` calls `read_op` calls `read_number`.
- A small recursive-descent parser; mutual recursion is the natural fit.

:::

`read_number` reads a number, then hands off to `read_op` to look
for an operator. `read_op` reads an operator and a right-hand-side,
hands back to `read_number` to parse that right-hand-side, and so
on. The two functions implement two states of a small state machine.
This is the natural shape; trying to write it as a single function
with a flag parameter would be uglier and harder to extend to more
grammar rules.

The same shape arises in:

- Tree walkers where each kind of node has its own handler, and the
  trees nest. For instance, in a small language with expressions and
  statements, `eval_expr` may need to call `eval_stmt` (for a block
  expression) and vice versa.
- State machines with multiple states.
- The classic "alternating list" structures (a list of A's and B's
  where they alternate). The data type itself is mutually recursive,
  and the functions that walk it are too.

We will see all of these in
[Module 4](M04-L04-recursive-types.html) (recursive data types)
and [Module 5](M05-L01-basic-patterns.html) (pattern matching).

## Mutual recursion can be local too

Just as a single recursive function can be local with `let rec ... in`,
a set of mutually recursive functions can be local with
`let rec ... and ... in`:

```ocaml
let demo () =
  let rec ping n =
    if n = 0 then "done"
    else pong (n - 1)
  and pong n = ping n
  in
  ping 5
```

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
- `let rec ... and ...` works inside `let ... in` too:

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
- Local helpers can refer to each other.

:::

The syntax is exactly the same: `let rec X = ... and Y = ... in
body`. Both `X` and `Y` are local to the surrounding expression.
Outside `demo ()`, neither `ping` nor `pong` exists.

The slide also shows `collatz`, with a single (not mutual) local
recursive helper, as a reminder that the local pattern works without
`and` too. The Collatz function takes a positive integer and
generates the Collatz sequence: halve it if even, triple-and-add-one
if odd, stop at 1. The conjecture is that the sequence reaches 1
for every positive starting value. The conjecture is unproven; for
our purposes, the function is a small example of `let rec ... in`
with a list-building recursion.

## Activity: `is_even` and `is_odd` by mutual recursion

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

Try this yourself before reading the solution. The constraint forbids
the obvious `n mod 2 = 0` definition, forcing you into mutual
recursion: `is_even n` calls `is_odd (n - 1)`; `is_odd n` calls
`is_even (n - 1)`. The base cases pin down the truth: zero is even,
zero is not odd.

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

- `is_even 6, is_odd 5, is_even 4, is_odd 3, is_even 2, is_odd 1, is_even 0, true`.

- Recursive calls are in tail position (calling the *other* function).
- TCO works between mutually recursive functions: constant stack.
- For large `n`, prefer `n mod 2 = 0`; this is just illustration.

:::

One important property of this example: the recursive calls
(`is_odd (n - 1)` inside `is_even`, and vice versa) are in tail
position. Recall the rule from
[M03-L04](M03-L04-tail-recursion.html#what-is-a-tail-call): a
call is in tail position if its result is the immediate result
of the enclosing function. In both bodies, the recursive call to
the *other* function is the last thing that happens; there is no
further work.

OCaml's tail-call optimisation handles tail calls *between* mutually
recursive functions, not just self-calls. So `is_even 1_000_000`
runs in constant stack space. The function alternates between two
frames as it descends, but neither frame ever stays around; each
recursive tail call reuses the current frame for the next call.

In real code you would write `n mod 2 = 0`, of course. The
mutual-recursion version is here as a clean illustration of the
pattern: two functions, two base cases, two recursive cases that
hand off to each other.

## A code challenge

:::quiz code id=M03-L05-q1
Define `count_evens` and `count_odds` using mutual recursion. Each
takes an `int list` and returns the count of even (or odd) values.
Treat negative numbers correctly: `-4` is even, `-3` is odd. Use
`mod` to test parity of a single element if you wish.

```ocaml
let rec count_evens xs =
  failwith "not implemented"
and count_odds xs =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (count_evens []           = 0) "empty evens";
  check (count_odds  []           = 0) "empty odds";
  check (count_evens [1;2;3;4]    = 2) "1234 evens";
  check (count_odds  [1;2;3;4]    = 2) "1234 odds";
  check (count_evens [-2;-3;0;7]  = 2) "negatives evens";
  check (count_odds  [-2;-3;0;7]  = 2) "negatives odds";
  print_endline "all tests passed"
```
:::

There are several reasonable solutions. One uses mutual recursion
directly:

```ocaml skip
let rec count_evens = function
  | [] -> 0
  | x :: rest ->
    if x mod 2 = 0 then 1 + count_evens rest else count_odds rest
and count_odds = function
  | [] -> 0
  | x :: rest ->
    if x mod 2 = 0 then count_evens rest else 1 + count_odds rest
```

Each function walks the list, counting the matches and handing off
to the other when it sees a non-match. This is contrived (two
separate walks would be simpler), but it exercises the mutual-recursion
machinery.

## What's next

:::slide

## What's next

Lecture 6: the **tutorial** for Module 3.

- Work through `fib`, `gcd`, and small list utilities.
- Trade-offs: naive vs tail recursion.

:::

The next lecture, [M03-L06](M03-L06-tutorial.html), is the
tutorial for Module 3. We will work through several classic small
problems: Fibonacci (naive and fast), GCD by Euclid, list helpers
(sum, reverse, nth, last), and a digit-counting function. The
goal is to consolidate the techniques (recursion, accumulators,
local helpers) on problems you have probably seen in some form
before, and to discuss when each approach is the right choice.

## Reading

- **Cornell CS3110**, *Helper functions* and *Mutual recursion*:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
