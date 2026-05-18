---
title: "Functors"
lecture_no: 6
week: 7
duration_target_name: 24
duration_target_min: 24
concepts: [functors, parameterized modules, Map.Make, generic data structures]
keywords: [OCaml, functor, Map.Make, Set.Make, parameterized modules]
activity_question: "Use [Map.Make(String)] to build a string -> int map. Insert three entries. Then look up an existing key and a missing one; what types do you get back?"
think_about_this: "A functor is 'a module that takes a module as an argument'. Why is this strictly more powerful than just parameterizing over a *type*?"
reading:
  - title: "Cornell CS3110, Functors"
    url: https://cs3110.github.io/textbook/chapters/modules/functors.html
---

# Functors

A **functor** is a module that takes another module as an argument
and produces a new module. They are OCaml's way of writing generic
data structures and algorithms that depend on *both* a type and
the operations on that type.

The OCaml standard library's `Map.Make`, `Set.Make`, and
`Hashtbl.Make` are functors. You use them constantly when you
work with associative data.

:::slide

## Why we need them

In Module 6 we wrote `List.map` once and used it on any element
type. That's *parametric polymorphism*: the function doesn't
depend on what `'a` is.

For more complex data structures, you can't get away with that.
A binary search tree of `'a` needs to *compare* values of `'a`; a
hash table needs to *hash* and compare them. Parametric
polymorphism doesn't give you a compare or hash function.

Enter functors: a functor takes a module that includes the
required operations and produces a data structure specialised to
that module's type.

:::

:::slide

## The pattern: `Map.Make`

```ocaml
module Int_map = Map.Make(struct
  type t = int
  let compare = Stdlib.compare
end)

let m =
  Int_map.empty
  |> Int_map.add 1 "one"
  |> Int_map.add 2 "two"
  |> Int_map.add 3 "three"

let _ = Int_map.find 2 m
let _ = Int_map.find_opt 999 m
```

`"two"`, `None`.

`Map.Make` is a functor. Its argument is a module providing a
type `t` and a `compare` function. It returns a module specialised
to that type: keys are `int`, values can be any type.

:::

:::slide

## The same with strings

```ocaml
module String_map = Map.Make(String)

let m =
  String_map.empty
  |> String_map.add "alice" 30
  |> String_map.add "bob" 25
  |> String_map.add "carol" 28

let _ = String_map.find_opt "alice" m
let _ = String_map.find_opt "dave" m
```

`Some 30`, `None`.

`String` already has the right shape (type `t` aliased to
`string`, and `String.compare`), so we pass it directly. `Map.Make`
specialises to give us a string-keyed map.

:::

:::slide

## What does the functor look like inside?

Conceptually:

```ocaml skip
module Map = struct
  module Make (Key : sig
    type t
    val compare : t -> t -> int
  end) = struct
    type key = Key.t
    type 'a t = ...  (* balanced tree implementation *)
    let empty = ...
    let add k v m = ...
    let find k m = ...
    let find_opt k m = ...
    ...
  end
end
```

`Make` is a functor: it takes a module satisfying the small
signature (a type `t` and a `compare`) and produces a full map
module.

The standard library's actual `Map.Make` is a few hundred lines
implementing a balanced binary search tree, but the *interface* is
this same shape.

:::

:::slide

## Writing your own functor

A toy `Set` functor:

```ocaml
module type ORDERED = sig
  type t
  val compare : t -> t -> int
end

module SetLite (E : ORDERED) = struct
  type elt = E.t
  type t = elt list  (* sorted, no duplicates *)

  let empty = []

  let rec mem x = function
    | [] -> false
    | y :: rest ->
        let c = E.compare x y in
        c = 0 || (c > 0 && mem x rest)

  let rec add x = function
    | [] -> [x]
    | y :: rest as ys ->
        let c = E.compare x y in
        if c = 0 then ys
        else if c < 0 then x :: ys
        else y :: add x rest
end

module Int_set = SetLite (struct
  type t = int
  let compare = Stdlib.compare
end)

let s = Int_set.add 5 (Int_set.add 2 (Int_set.add 8 Int_set.empty))
let _ = Int_set.mem 5 s
let _ = Int_set.mem 99 s
```

`true`, `false`. We built a toy set in maybe twenty lines,
parameterized over any ordered type.

:::

This is the pattern. Define a signature describing what your data
structure needs from the element type (`compare`, or `hash`, or
`zero` + `+`); write a functor parameterized by a module of that
signature; instantiate the functor for each concrete element type
you want.

:::slide

## Functors are how `Set` and `Map` stay generic

There's no `Set` type in OCaml's standard library that "just
works for any type". There's `Set.Make` which lets you
*construct* a set type for any *ordered* type. The orderedness is
the constraint; you provide it as a module.

Compare with Java: `TreeSet<E>` requires `E` to implement
`Comparable<E>`. Same idea, expressed as a Java *interface* rather
than an OCaml *module type*.

:::

:::slide

## Including a functor's output

If you build a module from a functor and want to extend it, you
can `include` the result:

```ocaml
module Int_map = struct
  include Map.Make(Int)
  let pp pp_value fmt m =
    iter (fun k v -> Format.fprintf fmt "%d -> %a; " k pp_value v) m
end
```

We start with `Map.Make(Int)`, include all its definitions, and
add a `pp` function on top. The resulting `Int_map` is the
standard int-map plus our extension.

(Note: this snippet uses `Format`, which we won't go into detail
on here.)

:::

:::slide

## Activity

Use `Map.Make(String)` to build a `string -> int` map. Insert
three entries. Look up an existing key and a missing one; report
both results.

:::

:::slide

## Activity solution

```ocaml
module M = Map.Make(String)

let ages =
  M.empty
  |> M.add "alice" 30
  |> M.add "bob" 25
  |> M.add "carol" 28

let _ = M.find_opt "alice" ages
let _ = M.find_opt "dave" ages
```

`Some 30`, `None`.

`M.find_opt` returns `int option`: `Some n` for found keys, `None`
for missing. `M.find` raises `Not_found` instead (same convention
as Module 7 Lecture 3).

:::

:::slide

## What's next

Lecture 7 is the **tutorial** for Module 7. We build a small
"functional queue" using two stacks, package it as a module with
an interface, and parameterize it as a functor.

:::

## Reading

- **Cornell CS3110**, *Functors*:
  <https://cs3110.github.io/textbook/chapters/modules/functors.html>
