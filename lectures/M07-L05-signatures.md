---
title: "Module signatures"
lecture_no: 5
week: 7
duration_target_min: 22
concepts: [signatures, sig...end, .mli files, abstraction, abstract types]
keywords: [OCaml, signature, sig, mli, abstract type, encapsulation]
activity_question: "Define a module [Counter] that exposes only [next : unit -> int] and [reset : unit -> unit]; hide the internal ref. Verify that external code cannot read or mutate the ref directly."
think_about_this: "A signature is the type-level description of a module. Once you constrain a module by a signature, what changes from the compiler's perspective? What can external callers stop relying on?"
reading:
  - title: "Cornell CS3110, Signatures"
    url: https://cs3110.github.io/textbook/chapters/modules/encapsulation.html
---

# Module signatures

A signature is a type-level *description* of a module: a list of
the names it exposes and their types. By constraining a module to
a signature, you hide implementation details: callers see only
what the signature lists.

This is how OCaml expresses encapsulation. The pattern is the same
shape as a Java `interface` or a Haskell type class, but it lives
at the *module* level rather than the value level.

:::slide

## A signature

```ocaml
module type COUNTER = sig
  val next : unit -> int
  val reset : unit -> unit
end
```

That's a signature: a `sig ... end` block listing values (here,
`next` and `reset`) with their types.

By convention, signature names are ALL CAPS. The type itself is
just a description; it doesn't have an implementation yet.

:::

:::slide

## A module conforming to a signature

```ocaml
module type COUNTER = sig
  val next : unit -> int
  val reset : unit -> unit
end

module Counter : COUNTER = struct
  let n = ref 0
  let next () = incr n; !n
  let reset () = n := 0
end

let _ = Counter.next ()
let _ = Counter.next ()
let () = Counter.reset ()
let _ = Counter.next ()
```

`1`, `2`, `1`. The module compiles because every value listed in
`COUNTER` (`next`, `reset`) is provided by the struct. The internal
`n` is *not* listed in the signature, so it's hidden:

```ocaml skip
let _ = !Counter.n  (* error: Unbound value Counter.n *)
```

The signature is acting as a *type-level wall* between the
implementation and the outside world.

:::

:::slide

## Why hide internals?

Two reasons:

- **Invariants**. If you let external code touch the ref directly,
  they might do `Counter.n := -100`. The signature prevents this:
  the only way to interact with the counter is through `next` and
  `reset`, which maintain whatever invariants you decided on
  (monotonic increase, non-negative, ...).
- **Change**. If you decide later to store `n` as a different
  type (a Zarith integer, an atomic counter, a database row), no
  external code breaks: they only see the `next` and `reset`
  functions, which still have the same types.

:::

The first point is the *encapsulation* argument. The second is the
*abstraction* argument. Both are reasons to write signatures, and
both are why the OCaml standard library exposes types through their
operations rather than as raw records.

:::slide

## Abstract types

A signature can hide not just *values* but the *type* of a
module's representation:

```ocaml
module type STACK = sig
  type 'a t
  val empty : 'a t
  val push : 'a -> 'a t -> 'a t
  val pop : 'a t -> ('a * 'a t) option
end

module Stack : STACK = struct
  type 'a t = 'a list
  let empty = []
  let push x s = x :: s
  let pop = function
    | [] -> None
    | x :: rest -> Some (x, rest)
end

let s = Stack.push 1 (Stack.push 2 (Stack.push 3 Stack.empty))
let _ = Stack.pop s
```

`Some (1, ...)`. From outside, `Stack.t` is an *abstract* type:
you don't know it's a list. You can only manipulate stacks through
the operations `empty`, `push`, `pop`.

If you change the representation later (to a `Dynarray`, to two
lists for amortized cost), no external code notices.

:::

:::slide

## `.mli` files: the same idea, in a separate file

In a real project, `foo.ml` is the implementation and `foo.mli` is
the interface. The compiler enforces that `foo.ml` matches `foo.mli`.

```
(* counter.mli *)
val next : unit -> int
val reset : unit -> unit

(* counter.ml *)
let n = ref 0
let next () = incr n; !n
let reset () = n := 0
```

This is the same pattern as the inline signature, with the
benefits of: living in a separate file (the interface is a clean
read), only the things in `.mli` are visible to other modules.

For the toplevel cells in these lectures we use inline signatures;
in your projects you'll see `.mli` files everywhere.

:::

:::slide

## `include`: inherit another module

```ocaml
module Greet = struct
  let hello name = "hello, " ^ name
end

module Greet_extended = struct
  include Greet
  let shout name = String.uppercase_ascii (hello name)
end

let _ = Greet_extended.hello "alice"
let _ = Greet_extended.shout "alice"
```

`"hello, alice"`, `"HELLO, ALICE"`.

`include Greet` copies all of `Greet`'s definitions into
`Greet_extended`, which can then add new ones (like `shout`).

Useful for extending standard library modules, or for layering
modules where one is "everything in A plus a bit more".

:::

:::slide

## Module type aliasing

You can name a complex signature:

```ocaml
module type ORDERED = sig
  type t
  val compare : t -> t -> int
end

module Int_ord : ORDERED = struct
  type t = int
  let compare = Stdlib.compare
end

module String_ord : ORDERED = struct
  type t = string
  let compare = String.compare
end
```

Two modules implementing the same signature. We've encoded what
in Haskell is called a "type class" (`Ord`) by hand: a module
with a `compare` operation on its abstract type.

This is also the basis of functors, which we cover next.

:::

:::slide

## Activity

Define a `Counter` module that exposes only `next : unit -> int`
and `reset : unit -> unit`. Verify that external code cannot read
the internal ref directly.

:::

:::slide

## Activity solution

```ocaml
module type COUNTER = sig
  val next : unit -> int
  val reset : unit -> unit
end

module Counter : COUNTER = struct
  let n = ref 0
  let next () = incr n; !n
  let reset () = n := 0
end

let _ = Counter.next ()
let _ = Counter.next ()
let () = Counter.reset ()
let _ = Counter.next ()
```

`1`, `2`, `1`.

If we try `let _ = !Counter.n` we get a compile error: `Unbound
value Counter.n`. The signature hides it. We can only interact
through `next` and `reset`.

:::

:::slide

## What's next

Lecture 6: **functors**. A functor is a module that takes another
module as an argument and produces a new module. The way OCaml
expresses "parameterize over a type with its operations".

:::

## Reading

- **Cornell CS3110**, *Signatures*:
  <https://cs3110.github.io/textbook/chapters/modules/encapsulation.html>
