---
title: "The state monad"
lecture_no: 4
week: 8
duration_target_min: 24
concepts: [state monad, threading state, gensym, functional state]
keywords: [OCaml, state monad, gensym, threaded state, let*]
activity_question: "Use the state monad to build a function [gensym : string -> string] that returns a fresh identifier each time (\"x_1\", \"x_2\", \"x_3\", ...). What is the state, and what is the value returned by each step?"
think_about_this: "The state monad threads state without mutation. What does this buy you that a [ref] would not? Where would you choose the [ref] approach over the monad?"
reading:
  - title: "Cornell CS3110, State monad"
    url: https://cs3110.github.io/textbook/chapters/ds/monads.html
---

# The state monad

Sometimes you want to pass a piece of "ambient" state through a
chain of computations: a counter, a random seed, a parser
position. The **state monad** captures this pattern without
mutation.

:::slide

## The type

A "stateful computation that produces an `'a`" is a function:

```
state -> ('a * state)
```

- Takes the current state.
- Returns both a value and the *new* state.
- Each step in the chain receives the state from the previous, and produces the state for the next.

We'll make the state an `int` for concreteness (a counter):

```ocaml
type 'a state = int -> 'a * int

let return x : 'a state = fun s -> (x, s)

let bind (m : 'a state) (f : 'a -> 'b state) : 'b state =
  fun s ->
    let (a, s') = m s in
    (f a) s'

let ( let* ) = bind
```

`bind` runs `m`, threads its state into `f`, and `f` returns the
final state.

:::

:::slide

## Two primitive operations

```ocaml
type 'a state = int -> 'a * int

let get : int state = fun s -> (s, s)

let put new_s : unit state = fun _ -> ((), new_s)

let run (m : 'a state) (s : int) : 'a * int = m s
```

- `get` returns the current state without changing it (the value *is* the state).
- `put new_s` sets the state to `new_s` (the value is unit).
- `run` is the escape: give it an initial state, get back a final value and final state.

:::

:::slide

## A worked example: gensym

A "gensym" generates fresh names: `x_1`, `x_2`, `x_3`, ...

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

let program =
  let* a = gensym "x" in
  let* b = gensym "x" in
  let* c = gensym "y" in
  return (a, b, c)

let _ = run program 1
```

`(("x_1", "x_2", "y_3"), 4)`.

- State starts at `1` and ends at `4` (we called `gensym` three times).
- The three names are fresh and ordered.
- The monad threads the counter through; no `ref` involved.

:::

This is "imperative-looking code without mutation". Each `let*` is
sequenced; the state passes from one step to the next; no mutable
cell exists. If you re-run with a different starting state, you get
a different result, deterministically.

:::slide

## What you bought vs `ref`

The `ref` version:

```ocaml
let counter = ref 1
let gensym_ref prefix =
  let n = !counter in
  counter := n + 1;
  prefix ^ "_" ^ string_of_int n

let _ = gensym_ref "x"
let _ = gensym_ref "x"
let _ = gensym_ref "y"
```

Two-line function. Easy to write. And:

- The function is *not* pure. Calling it twice gives different
  answers.
- Equational reasoning is gone for any function that touches
  `counter`.
- Tests can't reset the counter without poking at the
  implementation.
- If you ever fork a parallel computation, the counter races.

- State monad version is purer (the counter is data, not a side effect).
- At small scales it's overkill.
- At larger scales (a type-inference pass that needs fresh variable names, a compiler pass with many threaded counters) it pays off.

:::

:::slide

## A "labelled" version

- You can hide the threaded plumbing further.
- Make the types more specific:

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

let prog =
  let* a = fresh "x" in
  let* b = fresh "y" in
  let* c = fresh "z" in
  return [a; b; c]

let _ = run prog 1
```

`(["x_1"; "y_2"; "z_3"], 4)`.

- The state-passing logic is a one-liner inside `fresh`.
- The user sees just `let* a = fresh "x" in ...`.

:::

:::slide

## Why this matters beyond gensym

The state monad shows up under various names in real code:

- **Random**: state is the PRNG seed, threaded through generators.
- **Parser**: state is the unread portion of the input.
- **Type checker**: state is the type environment plus fresh-type-
  variable counter.
- **Web request handling**: state is the request context.

- In all of them, the monad encodes "thread this through every step".
- The user doesn't pass the state explicitly at each call site.

:::

:::slide

## Activity

Use the state monad to build a `gensym : string -> string state`
that returns a fresh identifier each time. Run a program that uses
it three times and inspect the final state.

:::

:::slide

## Activity solution

```ocaml
type 'a state = int -> 'a * int
let return x : 'a state = fun s -> (x, s)
let bind m f s = let (a, s') = m s in (f a) s'
let ( let* ) = bind
let get s = (s, s)
let put n _ = ((), n)
let run m initial = m initial

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

`(["v_0"; "v_1"; "v_2"], 3)`.

- State starts at `0`, three calls, state ends at `3`.
- Three fresh names produced.
- The state is hidden inside the `let*` chain.
- The caller doesn't explicitly pass a counter around; the monad does it.

:::

:::slide

## What's next

Lectures 5-6: **GADTs**.

- A more advanced type-system feature that lets variant constructors carry type-level information.
- Used heavily in tiny well-typed interpreters.
- The Module 8 tutorial combines GADTs with everything we've seen.

:::

## Reading

- **Cornell CS3110**, *State monad*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>
