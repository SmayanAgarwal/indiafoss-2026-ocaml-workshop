---
title: "The state monad and parameterised state"
lecture_no: 3
week: 8
duration_target_min: 26
concepts: [state monad, threading state, gensym, parameterised state, type-encoded preconditions, typed stack machine]
keywords: [OCaml, state monad, gensym, parameterised monad, stack machine, let*]
activity_question: "Extend the typed stack machine with [dup] that duplicates the top of the stack (type [('a * 's, 'a * ('a * 's), unit) pstate]). Show a program that pushes 7, dups, then adds (top becomes 14)."
think_about_this: "The state monad threads one state type throughout. Parameterised state lets the type change per step. What programs become well-typed under the second that the first could not even express?"
reading:
  - title: "Cornell CS3110, Monads"
    url: https://cs3110.github.io/textbook/chapters/ds/monads.html
---

# The state monad and parameterised state


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">The state monad and parameterised state</h2>
<p class="title-slide-label">Module 8 &middot; Lecture 3</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The previous monads encoded *failure*
([option](M08-L01-option-monad.html),
[result](M08-L02-laws-list-result.html)) and *non-determinism* (the
list monad). The state monad is a different flavour of the same
machinery: it threads a piece of *ambient state* through a chain.
Each step receives the current state from the previous step and
returns a new state to the next, with no mutation. At the end of
the lecture we let the state's *type* itself change from step to
step, the *parameterised* state monad, which is the first bridge to
GADTs.

:::slide

## This lecture

- The **state monad**: thread state through a chain without
  mutation. `return`, `bind`, `get`, `put`, `run`.
- Worked example: a `gensym` that issues fresh names.
- State monad versus a plain `ref`.
- **Parameterised state**: when the state's *type* changes per
  step. A typed stack machine whose ill-typed programs are compile
  errors. The bridge to [GADTs](M08-L04-gadts-basics.html).

:::

## The type

A *stateful computation* producing an `'a` is a function from the
current state to a pair of (value, new state). We take the state to
be an `int` counter:

:::slide

## The type, `return`, and `bind`

```ocaml
type 'a state = int -> 'a * int

let return x : 'a state = fun s -> (x, s)

let bind (m : 'a state) (f : 'a -> 'b state) : 'b state =
  fun s ->
    let (a, s') = m s in
    (f a) s'

let ( let* ) = bind
```

- `return x`: leave the state unchanged, produce `x`.
- `bind m f`: run `m`, thread its output state `s'` into `f`.
- The state threading is *sequential*: `m`'s output state becomes
  `f`'s input state.

:::

A `'a state` value is a *function*: give it an `int` (the current
state), get back a pair of (value, next state). `return x` ignores
the state and hands back `x`, the analogue of `Some x` /`Ok x`.
`bind m f` runs `m` against the input state, gets `(a, s')`, then
runs `f a` against `s'`. That is the whole game.

We need two primitives to actually touch the state: one reads it,
one replaces it.

:::slide

## Two primitives: `get` and `put`

```ocaml
let get : int state = fun s -> (s, s)
let put new_s : unit state = fun _ -> ((), new_s)
let run (m : 'a state) (s : int) : 'a * int = m s
```

- `get`: returns the current state *as the value*; state unchanged.
- `put new_s`: discards the input state, sets it to `new_s`,
  produces `()`.
- `run m s`: the escape hatch. Give an initial state, get back
  `(final value, final state)`.

:::

## A worked example: gensym

A *gensym* returns a fresh symbol each time it is called: `x_1`,
`x_2`, `x_3`. The state monad parks "the next number to use":

:::slide

## gensym

```ocaml
type 'a state = int -> 'a * int
let return x : 'a state = fun s -> (x, s)
let bind (m : 'a state) (f : 'a -> 'b state) : 'b state =
  fun s -> let (a, s') = m s in (f a) s'
let ( let* ) = bind
let get : int state = fun s -> (s, s)
let put new_s : unit state = fun _ -> ((), new_s)
let run (m : 'a state) (s : int) : 'a * int = m s

let gensym prefix : string state =
  let* n = get in
  let* () = put (n + 1) in
  return (prefix ^ "_" ^ string_of_int n)

let program =
  let* a = gensym "x" in
  let* b = gensym "x" in
  let* c = gensym "y" in
  return (a, b, c)

let _ = run program 1   (* = (("x_1", "x_2", "y_3"), 4) *)
```

Read the current counter, increment it, return a fresh name.

:::

State starts at 1, ends at 4 (three calls used 1, 2, 3; 4 is the
next available). The key thing: *the user-facing code never
mentions the counter*. No `ref`, no `incr`; the state is implicit
in the `let*` plumbing, and each step's output state is kept
aligned with the next step's input state automatically.

## State monad versus `ref`

The `ref` version of gensym is shorter:

:::slide

## What you buy versus `ref`

```ocaml
let counter = ref 1
let gensym_ref prefix =
  let n = !counter in
  counter := n + 1;
  prefix ^ "_" ^ string_of_int n
```

Two lines, easy to write. But:

- Not pure: calling twice gives different answers; equational
  reasoning is gone for any function touching `counter`.
- Tests cannot reset without poking the implementation.
- Parallel code races on the cell.

:::

Pick by scale: a one-off counter, use `ref`; a whole module of
state-threading computations, the monad pays off (state in the
type, local reasoning per step); parallel code, the monad is safer
but more painful. Ask whether you want the state to be a *value*
(visible in types, threaded by the monad) or a *side effect*
(invisible, mutated in place). Both are legitimate.

You can hide the `get`/`put` ritual behind a domain-specific
helper, defined against the *same* `'a state` monad:

:::slide

## Hiding get/put behind a helper

```ocaml
let fresh prefix : string state =
  fun s -> (prefix ^ "_" ^ string_of_int s, s + 1)

let prog =
  let* a = fresh "x" in
  let* b = fresh "y" in
  let* c = fresh "z" in
  return [a; b; c]

let _ = run prog 1   (* = (["x_1"; "y_2"; "z_3"], 4) *)
```

- No new monad: `fresh` is just another `'a state` value, reusing
  `return`, `bind`, `let*`, and `run` from above.
- The user-facing program is three `let*`s and a `return`; `get`
  and `put` do not appear.

:::

This is the common pattern: rather than exposing raw `get`/`put`,
you wrap them in helpers (`fresh`, `next_token`, `read_byte`) that
name what the state means. The state monad shows up under many such
names: a PRNG (state is the seed), a parser (state is the unread
input), a type checker (state is the environment plus a
fresh-variable counter). The wrapper type, `return`, `bind`, `let*`
are always the same; only the state varies.

## When the state's *type* should change

The state monad above threads a *single* state type `'a state =
int -> 'a * int`: the state is always an `int`. But sometimes the
state's type should change between steps. Imagine a small stack
machine: `push 5` turns a stack of shape `'s` into one of shape
`int * 's`; `add` turns `int * (int * 's)` into `int * 's`. The
state's *type* is the running shape of the stack. To track that, we
give the state monad two state type parameters, `'pre` and `'post`:

:::slide

## Parameterised state: two state types

```ocaml
type ('pre, 'post, 'a) pstate = 'pre -> 'a * 'post

let preturn x : ('s, 's, 'a) pstate = fun s -> (x, s)

let pbind (m : ('p, 'q, 'a) pstate) (f : 'a -> ('q, 'r, 'b) pstate)
  : ('p, 'r, 'b) pstate =
  fun s ->
    let (a, s') = m s in
    (f a) s'

let ( let* ) = pbind
```

- Three type parameters: pre-state, post-state, value.
- `preturn`: state type unchanged (`'s` in and out).
- `pbind`: the *post-state* `'q` of the first step is the
  *pre-state* of the second. Types thread through the chain:
  `'p -> 'q -> 'r`.

:::

Same machinery as the state monad's `bind`, three type variables
where there was one. The runtime behaviour is identical; the types
are richer. We model a stack as a *nested pair* with `unit` at the
bottom, so the type records the whole shape:

:::slide

## Stack as a nested pair, with informative operations

```ocaml
let push (x : 'a) : ('s, 'a * 's, unit) pstate =
  fun s -> ((), (x, s))

let add : (int * (int * 's), int * 's, unit) pstate =
  fun (x, (y, s)) -> ((), (x + y, s))

let run (m : ('pre, 'post, 'a) pstate) (s : 'pre) : 'a * 'post = m s
```

- Empty stack `()`; `(5, ())` is one int; `(1, (2, ()))` is two.
- `push x`: input stack `'s`, output `'a * 's`. Adds one element.
- `add`: input *must* be `int * (int * 's)`, output `int * 's`.
  Consumes two ints, produces one. The precondition is in the type.

:::

`push x` always succeeds: any stack accepts a value on top. `add`
is fussier: its type `int * (int * 's)` demands at least two `int`s
on top. Run two pushes and an add and the types line up:

:::slide

## A well-typed program

```ocaml
let prog =
  let* () = push 4 in
  let* () = push 5 in
  add

let _ = run prog ()   (* = ((), (9, ())) *)
```

- Value `()` (add returns nothing useful); final stack `(9, ())`.
- Start `()` : `unit`; after `push 4` : `int * unit`; after
  `push 5` : `int * (int * unit)`; `add` consumes both -> `(9, ())`
  : `int * unit`.

The compiler verifies the *shape* of the stack at every point is
what the next operation needs.

:::

Push a `bool` instead, and `add` can no longer apply. The mismatch
is a *compile* error, not a runtime one:

:::slide

## An ill-typed program is rejected at compile time

```ocaml skip
let bad_prog =
  let* () = push 4 in
  let* () = push true in  (* stack: bool * (int * unit) *)
  add                     (* add wants int * (int * 's) *)
```

```text
Error: This expression has type
         (bool * (int * unit), 'a, 'b) pstate
       but an expression was expected of type
         (int * (int * 'c), 'd, 'e) pstate
       Type bool is not compatible with type int
```

- `add` wants two ints on top; after `push true` the top is `bool`.
- The program will not even build.

:::

This is the payoff. "A stack machine that needs two ints on top to
add" is a constraint that lives in the *type* of the operation, and
the compiler enforces it before any code runs. The same idea
underlies WebAssembly's per-instruction stack typing, session types
(a client cannot `send` before `connect`), and typed builders.

:::slide

## Bridge to GADTs

- Parameterised state encodes preconditions in the *type
  parameters of a function*.
- GADTs (next lecture) encode them in the *type parameters of a
  constructor*.
- Both say: "the type witnesses what state we are in."

:::

The stack machine is one step short of a GADT: the state type *is*
a witness for the shape of the stack at this point. The
[next lecture](M08-L04-gadts-basics.html) makes the pattern
first-class, with constructors that carry such witnesses inline and
pattern matching that refines them.

## A quick check

:::quiz mcq id=M08-L03-q2
After `run program 1` in the gensym example the result is
`(("x_1", "x_2", "y_3"), 4)`. Why does the state end at `4` and not
`3`?

- [ ] The counter is off-by-one due to a bug.
- [ ] OCaml indexing is one-based.
- [x] After producing `y_3`, gensym set the state to `4` for the
  next caller.
- [ ] `run` adds 1 to the final state.

**Why:** each call reads the current `n`, sets the state to `n +
1`, and produces a name using `n`. After producing `y_3` the state
was set to `4`. The final state is the "next available", not the
"last used".
:::

:::quiz mcq id=M08-L03-q3
Why does the ill-typed `let* () = push true in add` fail at compile
time rather than runtime?

- [ ] OCaml runs the type checker at runtime for safety.
- [x] `add`'s type says the input state must be `int * (int *
  's)`. After `push true` the input is `bool * 's`. The compiler
  refuses to match `bool` against `int`.
- [ ] The bool is allocated dynamically.
- [ ] `add` raises an exception immediately.

**Why:** parameterised state encodes each operation's precondition
in its type. `add` says "I take a state shaped `int * (int * 's)`",
so the compiler rejects any preceding chain that does not produce
such a state. No runtime check; the error is caught at compile
time.
:::

:::slide

## Activity

Extend the stack machine with `dup`, which duplicates the top of
the stack: it takes an `'a * 's` state and produces an `'a * ('a *
's)` state. Then write a program that pushes 7, dups, and adds (top
becomes 14). Do not use a `ref`; thread the state with `let*`.

:::

:::solution

:::slide

## Activity solution

```ocaml
type ('pre, 'post, 'a) pstate = 'pre -> 'a * 'post
let preturn x : ('s, 's, 'a) pstate = fun s -> (x, s)
let pbind (m : ('p, 'q, 'a) pstate) (f : 'a -> ('q, 'r, 'b) pstate)
  : ('p, 'r, 'b) pstate =
  fun s -> let (a, s') = m s in (f a) s'
let ( let* ) = pbind
let push (x : 'a) : ('s, 'a * 's, unit) pstate = fun s -> ((), (x, s))
let add : (int * (int * 's), int * 's, unit) pstate =
  fun (x, (y, s)) -> ((), (x + y, s))
let run (m : ('pre, 'post, 'a) pstate) (s : 'pre) : 'a * 'post = m s

let dup : ('a * 's, 'a * ('a * 's), unit) pstate =
  fun (x, s) -> ((), (x, (x, s)))

let prog =
  let* () = push 7 in
  let* () = dup in
  add

let _ = run prog ()   (* = ((), (14, ())) *)
```

- `dup` takes `(x, s)` and returns `(x, (x, s))`: two copies on top.
- The duplicated `7`s are `int`s, so `add` applies and gives `14`.

:::

:::

A code quiz on the plain state monad:

:::quiz code id=M08-L03-q1
Write `incr_state : unit state` that increments the state by 1 and
produces `()`. Use `get` and `put`.

```ocaml
type 'a state = int -> 'a * int
let return x : 'a state = fun s -> (x, s)
let bind (m : 'a state) (f : 'a -> 'b state) : 'b state =
  fun s -> let (a, s') = m s in (f a) s'
let ( let* ) = bind
let get : int state = fun s -> (s, s)
let put new_s : unit state = fun _ -> ((), new_s)
let run (m : 'a state) (s : int) : 'a * int = m s

let incr_state : unit state =
  fun _ -> failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let prog =
  let* () = incr_state in
  let* () = incr_state in
  let* () = incr_state in
  return ()
let () =
  let (_, final) = run prog 10 in
  check (final = 13) "incremented three times from 10";
  let (_, final) = run prog 0 in
  check (final = 3) "incremented three times from 0";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let incr_state =
  let* n = get in
  put (n + 1)
```

Read the state into `n`, then set it to `n + 1`. The value of `put`
is `()`, which is what `incr_state` should produce.

:::

## What is next

:::slide

## What is next

Lecture 4: **GADTs**, the second half of the module.

- Variant constructors that carry their own type indices.
- Pattern matching that refines the index per branch.
- The same idea as the stack-machine state types, made
  first-class.

:::

The [next lecture](M08-L04-gadts-basics.html) starts the GADT half.
The parameterised-state pattern reappears there in rigorous form:
GADT constructors carry type witnesses, pattern matching refines
them, and the compiler tracks state-like information through
expressions naturally.

## Reading

- **Cornell CS3110**, *Monads*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>

## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. The state-monad and parameterised-state framing draw
on the CS3100 monads notebook
(`_references/cs3100_m20/lectures/lec15_monads/`), used here as a
private structural reference; the surface code, comments, and
explanations are written from scratch. Cornell CS3110 and Real
World OCaml are CC BY-NC-ND-licensed and have not been derivatively
reused. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
