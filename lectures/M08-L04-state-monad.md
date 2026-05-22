---
title: "The state monad"
lecture_no: 4
week: 8
duration_target_min: 24
concepts: [state monad, threading state, gensym, functional state]
keywords: [OCaml, state monad, gensym, threaded state, let*]
activity_question: "Use the state monad to build a function [gensym : string -> string state] that returns a fresh identifier each time (\"x_1\", \"x_2\", \"x_3\", ...). What is the state, and what is the value returned by each step?"
think_about_this: "The state monad threads state without mutation. What does this buy you that a [ref] would not? Where would you choose the [ref] approach over the monad?"
reading:
  - title: "Cornell CS3110, State monad"
    url: https://cs3110.github.io/textbook/chapters/ds/monads.html
---

# The state monad


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">The state monad</h2>
<p class="title-slide-label">Module 8 &middot; Lecture 4</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The previous two lectures used monads for *failure*:
[option](M08-L02-option-monad.html) and
[result](M08-L03-result-monad.html) both encode "this step may or
may not produce a value". The state monad is a different flavour
of the same machinery: rather than failure, it encodes *threaded
state*. Each step of a chain receives the current state from the
previous step and returns a new state to the next.

Why would we want this? Plenty of computations need to thread a
piece of state without it being a parameter of every function:

- A counter that issues fresh identifiers (`x_1`, `x_2`, `x_3`,
  ...) without colliding.
- A parser that tracks the unread portion of the input.
- A pseudo-random number generator that updates its seed on each
  call.
- A type checker that maintains a type environment plus a
  fresh-type-variable counter.

In every case the state is "ambient": you do not want it cluttering
every function signature, but it has to be threaded through
deterministically. [Reference cells](M07-L01-references.html) give
you one solution: use a `ref` and mutate it. The state monad gives
you a different solution: encode the threading in the type, and let
the monad plumbing do it. We will compare both at the end.

## The type

A *stateful computation* that produces an `'a` is a function from
the current state to the pair of (final value, final state):

:::slide

## The type

A "stateful computation that produces an `'a`" is a function:

```
state -> ('a * state)
```

Each step takes the current state and returns both a value and the
*new* state. We make the state an `int` (a counter):

```ocaml
type 'a state = int -> 'a * int
```

:::

:::slide

## `return` and `bind` for state

```ocaml
let return x : 'a state = fun s -> (x, s)

let bind (m : 'a state) (f : 'a -> 'b state) : 'b state =
  fun s ->
    let (a, s') = m s in
    (f a) s'

let ( let* ) = bind
```

- `return x`: leave state unchanged, produce value `x`.
- `bind m f`: run `m`, thread its output state into `f`.

:::

Read the definitions slowly. A `'a state` value is a *function*:
give it an `int` (the current state), get back a pair (a value of
type `'a`, plus the next `int` state). The type alias hides the
function; the function is the value.

`return x` is the simplest possible stateful computation: it
ignores the input state, produces the value `x`, and returns the
same state unchanged. "I have no effect on the state; here is
this value." It is the analogue of
[`Some x` for option](M08-L02-option-monad.html#definition), or
[`Ok x` for result](M08-L03-result-monad.html#definition).

`bind m f` is where the state threading happens. We call `m`
first, passing the input state `s`; we get back `(a, s')`, where
`a` is `m`'s value and `s'` is the state `m` left behind. We then
call `f a`, which returns another stateful computation; we run
that against `s'` and return its result. The threading is
*sequential*: `m`'s output state becomes `f`'s input state. That
is the whole game.

The `let* = bind` line, as before, lets us write monadic code
that reads like ordinary [`let`-bindings](M02-L02-let-bindings.html).

## Two primitives: `get` and `put`

We will need two helpers to actually *do* anything with the state.
The first reads the current state into the value position; the
second sets the state to a new value.

:::slide

## Two primitive operations

```ocaml
type 'a state = int -> 'a * int

let get : int state = fun s -> (s, s)

let put new_s : unit state = fun _ -> ((), new_s)

let run (m : 'a state) (s : int) : 'a * int = m s
```

- `get`: returns the current state *as the value*; state unchanged.
- `put new_s`: discards the input state, sets state to `new_s`,
  produces `()`.
- `run m s`: the escape hatch. Give an initial state, get back
  `(final value, final state)`.

:::

`get` is a computation whose *value* is the current state. Think
of the input `s` as "the state right now"; `get` returns `(s, s)`,
which says "the value is `s`, and the state after this step is
still `s`". Inside a `let*`, `let* n = get in ...` binds `n` to
the current counter without changing it.

`put new_s` is a computation whose *value* is `()` (we do not care
about a value; we ran for the side-effect of changing state).
Inside a `let*`, `let* () = put 99 in ...` resets the counter to
99 and continues.

`run` is the way you escape from monadic code back to plain OCaml.
Given an initial state, it executes the whole `'a state` chain
and returns the pair `(final value, final state)`. Outside of
`run`, you are still inside the monad; inside, you get an ordinary
OCaml value back.

## A worked example: gensym

A *gensym* is a function that returns a fresh symbol each time it
is called: `x_1`, `x_2`, `x_3`, and so on. Each call has to pick a
number nobody else has used. The state monad gives us a place to
park "the next number to use":

:::slide

## A worked example: gensym

```ocaml
type 'a state = int -> 'a * int
let return x : 'a state = fun s -> (x, s)
let bind (m : 'a state) (f : 'a -> 'b state) : 'b state =
  fun s ->
    let (a, s') = m s in
    (f a) s'
let ( let* ) = bind
let get : int state = fun s -> (s, s)
let put new_s : unit state = fun _ -> ((), new_s)
let run (m : 'a state) (s : int) : 'a * int = m s

let gensym prefix : string state =
  let* n = get in
  let* () = put (n + 1) in
  return (prefix ^ "_" ^ string_of_int n)
```

`gensym`: read current counter, increment it, return a fresh name.

:::

:::slide

## Running gensym three times

```ocaml
let program =
  let* a = gensym "x" in
  let* b = gensym "x" in
  let* c = gensym "y" in
  return (a, b, c)

let _ = run program 1
```

`(("x_1", "x_2", "y_3"), 4)`. State starts at 1, ends at 4 (three
calls); names are fresh and ordered; no `ref`, no mutation, the
counter is threaded through the `let*` chain.

:::

Read `gensym` line by line. The first line, `let* n = get in`,
captures the current state into the local name `n`. The second
line, `let* () = put (n + 1) in`, sets the state to `n + 1` (so
the *next* gensym will see a bigger number). The third line,
`return (prefix ^ ...)`, produces the final string and leaves the
state alone (since `return` does not touch state).

The "program" then calls `gensym` three times. Read top to bottom:
get a name, get a name, get a name, return all three as a tuple.
Behind the scenes the counter is threaded through every step. The
final `run program 1` says "start with the counter at 1"; the
result tells us the three names produced and that the counter
ended at 4 (1, 2, 3 were used; 4 is the next available).

The key thing to notice: *the user-facing code never mentions the
counter*. There is no `let counter = ref 1` and no `incr counter`.
The state is implicit in the `let*` plumbing. If you forgot a step
or doubled one up, the wiring would still be correct because the
monad keeps each step's output state aligned with the next step's
input state.

## State monad versus `ref`

The `ref` version of gensym is much shorter:

:::slide

## What you bought versus `ref`

The `ref` version:

```ocaml
let counter = ref 1
let gensym_ref prefix =
  let n = !counter in
  counter := n + 1;
  prefix ^ "_" ^ string_of_int n
```

Two-line function, easy to write. But:

- Not pure: calling twice gives different answers.
- Equational reasoning gone for any function touching `counter`.
- Tests can't reset without poking the implementation.
- Parallel code races on the counter.

:::

:::slide

## Pick `ref` vs state monad by scale

- Small one-off counter: `ref` is fine.
- A whole module of state-threading computations: the monad pays
  off (state in the type, local reasoning at each step).
- Parallel / concurrent code: the monad is safer but more painful;
  `ref` is shorter but races.

:::

The `ref` version is shorter and easier to write. The state-monad
version is purer (no hidden side effect) and explicit (the type
`'a state` advertises "this computation touches state"). Pick
based on what your code is going to look like at scale:

- Small one-off counter: `ref` is fine.
- Whole module of computations that thread state: the monad
  starts paying off, because the state is in the type rather than
  in a global cell, and you can reason locally about each step.
- Parallel/concurrent code: the monad is more painful but safer;
  the `ref` is shorter but introduces a race.

There is no universal right answer. Real OCaml code uses both. A
helpful frame: ask whether you want the state to be a *value*
(visible in types, threaded by the monad) or a *side effect*
(invisible in types, mutated in place). Both are legitimate; they
make different trade-offs.

## A version that hides the plumbing

You can hide the get/put/return ceremony inside small helpers. Here
is a slightly cleaner gensym that does not need the `let* n = get
in let* () = put (n + 1) in` ritual:

:::slide

## A "labelled" version: the monad

```ocaml
type counter_state = int
type 'a t = counter_state -> 'a * counter_state

let return x : 'a t = fun s -> (x, s)
let bind (m : 'a t) (f : 'a -> 'b t) : 'b t =
  fun s ->
    let (a, s') = m s in
    (f a) s'
let ( let* ) = bind

let fresh prefix : string t =
  fun s -> (prefix ^ "_" ^ string_of_int s, s + 1)

let run m initial = m initial
```

`fresh` is a one-liner that names the convention: increments the
counter and returns the next prefixed name.

:::

:::slide

## Using the labelled version

```ocaml
let prog =
  let* a = fresh "x" in
  let* b = fresh "y" in
  let* c = fresh "z" in
  return [a; b; c]

let _ = run prog 1
```

`(["x_1"; "y_2"; "z_3"], 4)`. The user-facing program is three
`let*`s and a `return`; `get` and `put` don't appear.

:::

`fresh` is the "do one tick of the state monad" helper, specialised
to "produce a fresh name". The user-facing program does not see
`get` or `put` at all. This is a common pattern: rather than
exposing the raw `get` and `put` primitives to callers, you wrap
them in domain-specific helpers (`fresh`, `next_token`, `read_byte`)
that describe what the state means in your application.

## Where the state monad shows up

A short tour of the places this pattern appears, often by other
names:

:::slide

## Where this matters beyond gensym

The state monad shows up in real code, often under other names:

- **Random**: state is the PRNG seed.
- **Parser**: state is the unread portion of the input.
- **Type checker**: state is the type environment plus a fresh
  variable counter.
- **Web request handling**: state is the request context.
- **Property-based testing**: state is the test seed plus
  shrinking history.

- In each: state threads through every step.
- The user does not pass it explicitly at every call site.

:::

In a parser, the state is `string * int` (the input string plus
the current position). Each combinator returns "value parsed
plus new position", which is exactly the `'a state` shape. Real
parser-combinator libraries like [Angstrom](https://github.com/inhabitedtype/angstrom)
or [MParser](https://github.com/cakeplus/mparser) lift this idea
to a serious tool. In a type checker, the state is `env *
fresh_counter`, threaded through every step of inference. Modern
language implementations bury this in monadic abstractions that
look very much like the gensym pattern above, scaled up.

<!-- TODO: parser-combinator example and type-checker pipeline are
     out of scope for this course; tighten if a future module covers
     parsers in detail. -->


The monad shape, in all these cases, is the same: a wrapper type,
`return`, `bind`, `let*`. The state itself varies wildly; the
plumbing does not.

## A quick check

:::quiz mcq id=M08-L04-q3
After running `run program 1` in the gensym example, the result is
`(("x_1", "x_2", "y_3"), 4)`. Why does the state end at `4` and
not at `3`?

- [ ] The counter is off-by-one due to a bug.
- [ ] OCaml indexing is one-based.
- [x] After producing `y_3`, the gensym set the state to `4` for
  the next caller.
- [ ] `run` adds 1 to the final state.

**Why:** each call to `gensym` reads the current `n`, sets the
state to `n + 1`, and produces a name using `n`. After producing
`y_3`, the state was set to `4`. The next call to gensym (if any)
would produce `_4` and set the state to `5`. The final state is
the "next available", not the "last used".
:::

:::quiz mcq id=M08-L04-q2
What is the type of `get` in our state monad?

- [ ] `int -> int`
- [ ] `int -> unit`
- [x] `int state` (which is `int -> int * int`)
- [ ] `unit state`

**Why:** `get` is a stateful computation whose *value* is the
state itself. So its result type as a `state`-monad value is `int
state`, which unfolds to `int -> int * int`. Reading the
definition: `let get s = (s, s)`: input state `s`, value `s`,
new state `s` (unchanged).
:::

:::slide

## Activity

Use the state monad to build a `gensym : string -> string state`
that returns a fresh identifier each time. Run a program that uses
it three times and inspect the final state.

:::

:::slide

## Activity solution: setup

```ocaml
type 'a state = int -> 'a * int
let return x : 'a state = fun s -> (x, s)
let bind m f s = let (a, s') = m s in (f a) s'
let ( let* ) = bind
let get s = (s, s)
let put n _ = ((), n)
let run m initial = m initial
```

The seven definitions: the type, monad operations, and primitives.

:::

:::slide

## Activity solution: gensym

```ocaml
let gensym prefix : string state =
  let* n = get in
  let* () = put (n + 1) in
  return (prefix ^ "_" ^ string_of_int n)

let program =
  let* a = gensym "v" in
  let* b = gensym "v" in
  let* c = gensym "v" in
  return [a; b; c]

let _ = run program 0
```

`(["v_0"; "v_1"; "v_2"], 3)`. Counter threaded through `let*`,
no `ref` in sight.

:::

A code quiz to consolidate:

:::quiz code id=M08-L04-q1
Write `incr_state : unit state` that increments the state by 1
and produces `()`. Use `get` and `put`.

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

Two lines: read the state into `n`, then set the state to `n + 1`.
The value of `put` is `()`, which is what `incr_state` should
produce.

:::

## What is next

:::slide

## What is next

Lectures 5-6: **GADTs**.

- A more advanced type-system feature.
- Variant constructors that carry type-level information.
- Used in tiny well-typed interpreters and type-safe APIs.
- The Module 8 tutorial combines GADTs with the monad pattern.

:::

We have seen three monads with the same `let*` shape:
[`option`](M08-L02-option-monad.html),
[`result`](M08-L03-result-monad.html), and `state`. The
[next](M08-L05-gadts-basics.html)
[two](M08-L06-gadts-use-cases.html) lectures change direction
entirely and study a different advanced feature: generalized
algebraic data types. They are not part of the monad story
mechanically, but they often appear in the same kinds of code
(small embedded languages with typed ASTs), and the
[tutorial in lecture 7](M08-L07-tutorial.html) brings the two
threads together.

## Reading

- **Cornell CS3110**, *State monad*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
