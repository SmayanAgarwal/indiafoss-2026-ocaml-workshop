---
title: "Sequencing computations: motivation for monads"
lecture_no: 1
week: 8
duration_target_min: 22
concepts: [pyramid of doom, sequencing failures, monad shape, bind]
keywords: [OCaml, monad, sequencing, bind, option, let*]
activity_question: "Take the nested [match ... with None -> None | Some x -> ...] pattern and write a helper [bind : 'a option -> ('a -> 'b option) -> 'b option] that captures it. Use it to flatten a four-step optional pipeline."
think_about_this: "What other shapes besides 'maybe a value' might want the same kind of sequencing helper? List three."
reading:
  - title: "Cornell CS3110, Monads"
    url: https://cs3110.github.io/textbook/chapters/ds/monads.html
---

# Sequencing computations

This module is about a pattern that shows up everywhere once you
look: *sequencing computations that might fail*. The shapes we
already have (`option`, `result`, exceptions) all express
"something might go wrong"; what we don't have yet is a clean way
to *chain* such computations without the code becoming a pyramid.

This lecture sets up the problem. The next four show different
solutions.

:::slide

## The pyramid of doom

Suppose four steps, each returning an `option`:

```ocaml
let parse_int s = int_of_string_opt s
let twice x = Some (x * 2)
let small x = if x < 100 then Some x else None
let print_num x = print_endline (string_of_int x); Some ()

let demo s =
  match parse_int s with
  | None -> None
  | Some x ->
      match twice x with
      | None -> None
      | Some y ->
          match small y with
          | None -> None
          | Some z -> print_num z

let _ = demo "5"
let _ = demo "frog"
let _ = demo "100"
```

The third call prints nothing because `100 * 2 = 200` is rejected
by `small`.

Notice the *shape*: four steps, four `match`es, four `None -> None`
clauses. The actual logic is buried in the right-hand sides.

:::

:::slide

## What we want

Each step's pattern is the same: "if previous was `None`, give up;
otherwise, unwrap, run the next step". A helper would let us write
it once:

```ocaml
let bind opt f =
  match opt with
  | None -> None
  | Some x -> f x

let parse_int s = int_of_string_opt s
let twice x = Some (x * 2)
let small x = if x < 100 then Some x else None
let print_num x = print_endline (string_of_int x); Some ()

let demo s =
  bind (parse_int s) (fun x ->
  bind (twice x) (fun y ->
  bind (small y) (fun z ->
  print_num z)))

let _ = demo "5"
```

Each step is one line: `bind (this) (fun x -> rest)`. The "what to
do if `None`" logic is captured once, in `bind`.

:::

:::slide

## `let*` syntax (preview)

The nested `bind` is still slightly heavy. OCaml has a sugar for
it (`let*`) that we'll cover in Lecture 2:

```ocaml
let ( let* ) opt f =
  match opt with
  | None -> None
  | Some x -> f x

let parse_int s = int_of_string_opt s
let twice x = Some (x * 2)
let small x = if x < 100 then Some x else None
let print_num x = print_endline (string_of_int x); Some ()

let demo s =
  let* x = parse_int s in
  let* y = twice x in
  let* z = small y in
  print_num z

let _ = demo "5"
```

That reads almost like ordinary `let ... in ...` sequencing.
Behind the scenes it's exactly the nested `bind`s from before.

This is what people mean by "an option monad". The *shape* is:
(`return : 'a -> 'a option`) + (`bind : 'a option -> ('a -> 'b
option) -> 'b option`). Anything with that shape is a monad.

:::

The word "monad" sounds intimidating. The reality is a small
two-function pattern: `return` (lift a value into the shape) and
`bind` (use a value inside the shape to produce the next stage).
That's it. We'll see it for `option`, `result`, state, and others.

:::slide

## Why this matters

In Module 4 we said `option` is OCaml's answer to null. The
trade-off was: option-flavoured code requires lots of `match`
statements. The pyramid of doom is exactly that trade-off in
practice.

Monad-shaped helpers make the trade-off cheap. You get the
type-safety of `option` *and* code that reads top-to-bottom like
ordinary sequential code. That's the win.

The same pattern lifts to other shapes (`result`, `Lwt`/`Async`
promises, parsers, state). Each one is a different monad; the
notation is the same.

:::

:::slide

## Three monads we'll cover this module

- **Option monad** (Lecture 2): `'a option`. Sequence "maybe a
  value" steps.
- **Result monad** (Lecture 3): `('a, 'e) result`. Like option, but
  the failure case carries info.
- **State monad** (Lecture 4): `state -> 'a * state`. Threads a
  hidden state through a chain of computations.

After those, Lectures 5-6 cover GADTs, a more advanced type-system
feature that's loosely connected to monads (used together for
"typed embedded DSLs").

:::

:::slide

## Activity

Take the nested `match ... with | None -> None | Some x -> ...`
pattern and write `bind : 'a option -> ('a -> 'b option) -> 'b option`.

Use it to chain three optional steps in a flat pipeline.

:::

:::slide

## Activity solution

```ocaml
let bind opt f =
  match opt with
  | None -> None
  | Some x -> f x

let parse_int s = int_of_string_opt s
let double x = Some (x * 2)
let positive x = if x > 0 then Some x else None

let pipeline s =
  bind (parse_int s) (fun x ->
  bind (double x) (fun y ->
  positive y))

let _ = pipeline "5"
let _ = pipeline "frog"
let _ = pipeline "-3"
```

`Some 10`, `None`, `None`.

`bind` captures the "if `None`, abort; otherwise, unwrap and pass
on" logic. Three steps, three `bind`s, no nested `match`.

:::

:::slide

## What's next

Lecture 2: the **option monad** in detail, including the `let*`
sugar that makes monadic code look like ordinary `let`-sequenced
code.

:::

## Reading

- **Cornell CS3110**, *Monads*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>
