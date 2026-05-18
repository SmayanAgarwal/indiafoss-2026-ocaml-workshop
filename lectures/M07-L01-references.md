---
title: "Mutable references"
lecture_no: 1
week: 7
duration_target_min: 22
concepts: [mutation, ref, !, :=, side effects, when to use mutation]
keywords: [OCaml, ref, mutation, side effects, !, :=]
activity_question: "Write a function [make_counter : unit -> (unit -> int)] that returns a closure giving the next integer each time it's called: [1; 2; 3; ...]."
think_about_this: "OCaml is functional-first but supports mutation via [ref]. When you reach for mutation, what property are you giving up? When does the trade pay off?"
reading:
  - title: "Cornell CS3110, References"
    url: https://cs3110.github.io/textbook/chapters/mut/refs.html
---

# Mutable references

For six modules we have been writing OCaml with no mutation. Every
value is immutable; new states are new values. This module
introduces the *opt-in* mutation that OCaml provides for the cases
where you genuinely want it. The simplest mechanism is the **`ref`
cell**.

:::slide

## A `ref` is a mutable box

```ocaml
let counter = ref 0

let () = counter := 1
let () = counter := 2
let _ = !counter
```

`int = 2`.

- `ref x` creates a mutable cell holding `x`.
- `!cell` reads the current value (dereferencing).
- `cell := y` writes a new value into the cell.

The cell itself has type `int ref`. The contents (`!counter`) have
type `int`.

:::

:::slide

## Why three operators?

In C and Python, you'd write `counter = 1` for both creation and
update. OCaml separates them:

- **Creation**: `let counter = ref 0` binds a *name* to a *fresh
  cell* containing 0.
- **Read**: `!counter` reads from the cell.
- **Write**: `counter := 1` writes to the cell.

This is the same distinction C makes implicitly with pointers:
`int *p = malloc(sizeof(int)); *p = 0;` is the create step;
`*p = 1` is the write; `*p` is the read. OCaml just makes it
explicit at the syntax level.

:::

:::slide

## Mutation breaks equational reasoning

```ocaml
let counter = ref 0
let get_next () = counter := !counter + 1; !counter

let _ = get_next ()
let _ = get_next ()
let _ = get_next ()
```

`1`, `2`, `3`. `get_next ()` is *not* equal to `get_next ()`: the
first call returns 1, the second returns 2. We can't replace one
call by its result without changing the program's behaviour.

That's the cost of mutation: the equational reasoning we had with
pure functions (Module 2) is gone for code that touches a `ref`.

:::

This is why OCaml is *functional-first*: it makes mutation
available, but the default is immutability. Code that doesn't touch
a `ref` can be reasoned about as math; code that does has to be
read more carefully.

:::slide

## When `ref` is the right tool

- **Counters, accumulators in imperative-flavoured loops.** When
  the natural way to express a computation is "step through, update
  this variable", `ref` is fine.
- **Caches**. A memoization table that grows across calls.
- **Recursive references** (rarely needed but possible).
- **Interop with code that expects mutation** (callbacks, GUI
  state).

Most everyday OCaml code uses no `ref`s at all. We reach for them
when the alternative is awkward.

:::

:::slide

## A small example: a one-shot

```ocaml
let make_once () =
  let used = ref false in
  fun () ->
    if !used then None
    else begin
      used := true;
      Some "first call"
    end

let f = make_once ()
let _ = f ()
let _ = f ()
let _ = f ()
```

`Some "first call"`, `None`, `None`. The closure captures `used`;
the first call sets it, subsequent calls see it set and return
`None`.

This pattern (private mutable state inside a function, shared by
all calls to that function) is one of the cleanest uses of `ref`.

:::

:::slide

## A `ref` is just a record with one mutable field

The type `'a ref` is literally:

```ocaml skip
type 'a ref = { mutable contents : 'a }
```

The operators `!` and `:=` are just shorthand:

- `!r` is `r.contents`.
- `r := x` is `r.contents <- x`.

So `ref` isn't a magic builtin; it's a record with one mutable
field, packaged for convenience. Anywhere you'd want named
mutable state, you can use a `mutable` record field directly:

```ocaml
type counter = { mutable n : int }

let c = { n = 0 }
let () = c.n <- c.n + 1
let () = c.n <- c.n + 1
let _ = c.n
```

`int = 2`. The `<-` is the assignment operator for mutable record
fields.

:::

:::slide

## Sequencing side effects

When you do several side-effecting things in a row, you sequence
them with `;` (the *statement* semicolon, distinct from `;;`):

```ocaml
let r = ref 0

let () =
  r := 1;
  r := 2;
  r := 3
```

Each `;` says "do this, then that". The left-hand side of each
`;` must have type `unit` (the value `()`).

If you have a non-unit expression in sequence (`r := 1; 5; r :=
2`), OCaml warns: the value `5` is being thrown away. Wrap it in
`let _ = 5` or `ignore 5` to silence.

:::

:::slide

## Activity

Write `make_counter : unit -> (unit -> int)` that returns a closure
yielding the next integer on each call: first call returns `1`,
second `2`, third `3`, and so on.

:::

:::slide

## Activity solution

```ocaml
let make_counter () =
  let n = ref 0 in
  fun () -> incr n; !n

let next = make_counter ()
let _ = next ()
let _ = next ()
let _ = next ()
```

`1`, `2`, `3`.

The closure captures `n`. Each call increments and reads. `incr n`
is shorthand for `n := !n + 1`; `decr` exists too for the other
direction.

Two different counters made from `make_counter ()` have *independent*
state:

```ocaml
let make_counter () =
  let n = ref 0 in
  fun () -> incr n; !n

let a = make_counter ()
let b = make_counter ()
let _ = a (), a (), a (), b (), b ()
```

`(1, 2, 3, 1, 2)`. The closures don't share their `n`.

:::

:::slide

## What's next

Lecture 2: **mutable records and arrays**. Beyond the one-cell
`ref`, OCaml has mutable fields on records (as we've seen) and
fixed-size mutable arrays. Both for code that genuinely needs
in-place updates.

:::

## Reading

- **Cornell CS3110**, *References*:
  <https://cs3110.github.io/textbook/chapters/mut/refs.html>
