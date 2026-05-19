---
title: "Functors"
lecture_no: 6
week: 7
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

We have been writing functions that take values and return values
all course. Modules, the last two lectures introduced, are
collections of values, types, and helpers grouped under a name.
This lecture introduces the natural next step: *functions from
modules to modules*. In OCaml these are called *functors*, and
they are how the language expresses generic data structures and
algorithms.

The name "functor" comes from [category theory](https://en.wikipedia.org/wiki/Functor),
where a functor maps between categories: a kind of structure-preserving
function on whole structured things. OCaml's functors are simpler
than that: a functor is just a "function" from modules to modules.
The quotation marks are because modules and values live at
different levels in OCaml's type system, so a functor is not
interchangeable with a regular function. But conceptually, it is
the same idea.

The standard library uses functors everywhere. `Map.Make`,
`Set.Make`, and `Hashtbl.Make` are all functors. When you want a
map keyed by strings, you write `module M = Map.Make(String)`; the
result is a full map module specialised for string keys. This
lecture explains how that works and shows you how to write your
own.

## Why we need them

Most of the parameterisation we have done so far has been
*parametric polymorphism*: a function or type that works for any
element type without knowing anything about it. `List.map : ('a ->
'b) -> 'a list -> 'b list` is parametric in `'a` and `'b`; it
treats elements as opaque tokens and never looks inside them.

But many data structures cannot get away with that. A binary
search tree of `'a` needs to *compare* values of `'a` to decide
which side of a node to put them on. A hash table needs to *hash*
keys and compare them for equality. A sorted set needs an
ordering. Parametric polymorphism alone does not give you a
comparison function or a hash function: those would have to come
from somewhere.

:::slide

## Why we need them

- In Module 6 we wrote `List.map` once and used it on any element
  type.
- That's **parametric polymorphism**: the function doesn't depend
  on what `'a` is.
- More complex data structures can't get away with that: a binary
  search tree of `'a` needs to *compare* values of `'a`; a hash
  table needs to *hash* and compare them.
- Parametric polymorphism doesn't give you a compare or hash
  function.
- **Enter functors**: a functor takes a module providing the
  required operations and produces a data structure specialised to
  that module's type.

:::

Here is where functors come in. A functor takes as input a module
providing the required operations (`compare`, `hash`, whatever)
and produces a new module: the data structure specialised to that
input. The input module is the *parameter*; the output module is
the *instantiation*. You apply the functor by passing it an
argument module, exactly like calling a function.

## The pattern: Map.Make

The standard library's `Map` module is internally structured
around a functor called `Make`. Here is the everyday use:

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

The toplevel reports `"two"` for the existing key and `None` for
the missing one.

A few things to read out of that code. `Map.Make` is the functor.
Its *argument* is the inline module `struct type t = int; let
compare = Stdlib.compare end`. The argument module provides the
key type and a comparison function on that type. `Map.Make`
returns a full map module specialised to that key type: `empty`,
`add`, `find`, `find_opt`, `mem`, and all the other standard map
operations. We bind the result to the name `Int_map`.

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

- `Map.Make` is a **functor**.
- Its argument is a module providing a type `t` and a `compare`
  function.
- It returns a module specialised to that type: keys are `int`,
  values can be any type.

:::

The values of the map are still polymorphic. `Int_map.t` is
parameterised: an `int -> string` map and an `int -> bool` map
are different types, but both come from the same `Int_map`
module. The *key* type is fixed by the functor application; the
*value* type is parametric.

## Strings as keys

The standard `String` module already provides what `Map.Make`
needs: a type `t` (which happens to be `string`) and a
`String.compare` function. So we can pass it directly:

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

`Some 30` and `None`.

`String` has the right shape because the standard library is
designed for it: `String.t = string` and `String.compare` has the
required type `string -> string -> int`. The standard `Int`,
`Char`, and `Bytes` modules all satisfy the same interface; you
can use them as the argument to `Map.Make` directly.

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

- `String` already has the right shape: a type `t` aliased to
  `string` and a `String.compare`.
- We pass it directly.
- `Map.Make` specialises to give us a string-keyed map.

:::

## What does the functor look like inside?

Conceptually, `Map.Make` is defined something like this:

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
  end
end
```

`Make` takes a parameter `Key` of an inline signature: any module
with a type `t` and a `compare : t -> t -> int`. Inside `Make`,
the type `Key.t` and the function `Key.compare` are available;
the body of the functor implements the map (with a balanced
binary search tree, for the standard library's `Map`), referring
to `Key.compare` for ordering comparisons.

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

- `Make` is a functor: takes a module satisfying the small
  signature (a type `t` and a `compare`) and produces a full map
  module.
- The standard library's actual `Map.Make` is a few hundred lines
  implementing a balanced binary search tree.
- The *interface* is this same shape.

:::

The actual implementation in the OCaml standard library is a few
hundred lines of balanced-binary-search-tree code. But the
*interface* is the shape above. The functor decides "I need a key
type and a comparison on it"; the user supplies those; the
functor returns a full map.

## Writing your own functor

Here is a toy `Set` functor, building on the `ORDERED` signature
we wrote at the end of the previous lecture.

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

`true`, `false`. A working sorted-list set in about twenty lines,
parameterized over any ordered type.

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

`true`, `false`.

- A toy set in maybe twenty lines, parameterized over any ordered
  type.

:::

Notice the syntax: `module SetLite (E : ORDERED) = struct ...
end` declares a functor `SetLite`. The parameter `E` has signature
`ORDERED`; the parentheses around `(E : ORDERED)` are required. The
body of the functor is a structure, like any other module. Inside,
we reference `E.t` (the element type, abstract here) and
`E.compare` (the comparison function). The functor returns a
module with `elt`, `t`, `empty`, `mem`, `add`.

To apply the functor, write `SetLite (M)` where `M` is some
module satisfying `ORDERED`. We use an inline module to make
`Int_set`. The same trick works for any ordered type:
`SetLite (String)` would give us a string set,
`SetLite (Int_ord)` likewise if we had defined an `Int_ord`
module.

This is the pattern. Define a signature describing what your data
structure needs from the element type (`compare`, or `hash`, or
`equal` + `hash`, or `zero` + `+`); write a functor parameterized
by a module of that signature; instantiate the functor for each
concrete element type you want.

## Functors versus Java generics

A natural question: how does this compare to `List<E>` in Java or
`Vec<T>` in [Rust](https://www.rust-lang.org/)?

In Java, the standard library's `TreeSet<E>` requires `E` to
implement the `Comparable<E>` interface. That is the constraint
on the element type. The user writes `TreeSet<String>` and the
compiler checks that `String` implements `Comparable`. The same
information OCaml carries in a *module* (a type `t` and a
`compare` function), Java carries in an *interface* and a class
that implements it.

The two approaches are roughly equivalent in expressiveness for
the data-structure use case. The OCaml approach scales more
cleanly when you want to combine *multiple* constraints (an
ordered, hashable type with a default value, say): you just
expand the signature. It is also more flexible because a single
type can satisfy multiple module signatures in different ways
(provide two different orderings on the same type by writing two
modules). The Java approach is more familiar to programmers
arriving from C++ or C#, where generics are the everyday
mechanism.

:::slide

## Functors are how `Set` and `Map` stay generic

- There's **no `Set` type** in OCaml's stdlib that "just works for
  any type".
- There's `Set.Make`, which lets you *construct* a set type for
  any *ordered* type.
- The orderedness is the **constraint**; you provide it as a
  module.
- **Compare with Java**: `TreeSet<E>` requires `E` to implement
  `Comparable<E>`. Same idea, expressed as a Java *interface*
  rather than an OCaml *module type*.

:::

## Including a functor's output

A common pattern: you want a `Map`-like module that has *all* the
operations of a standard `Map`, *plus* a few of your own. The
`include` keyword from the previous lecture combines with functor
application to make this easy.

```ocaml skip
module Int_map = struct
  include Map.Make(Int)
  let pp pp_value fmt m =
    iter (fun k v -> Format.fprintf fmt "%d -> %a; " k pp_value v) m
end
```

`include Map.Make(Int)` runs the functor, gets back a full
int-keyed map module, and copies all its definitions into the
enclosing structure. The `let pp ...` then adds a printer on top.
The resulting `Int_map` is "everything `Map.Make(Int)` would have
given you, plus our `pp`."

:::slide

## Including a functor's output

- Build a module from a functor and want to extend it?
- Use `include` on the result:

```ocaml skip
module Int_map = struct
  include Map.Make(Int)
  let pp pp_value fmt m =
    iter (fun k v -> Format.fprintf fmt "%d -> %a; " k pp_value v) m
end
```

- Start with `Map.Make(Int)`.
- Include all its definitions.
- Add a `pp` function on top.
- The resulting `Int_map` is the **standard int-map plus our
  extension**.
- (This snippet uses `Format`, which we won't go into detail on
  here.)

:::

This pattern is *the* way to extend a standard library data
structure with project-specific helpers. You see it constantly in
real OCaml codebases.

## A quick check

:::quiz mcq
Why is the standard library's `Set` module a functor (`Set.Make`)
rather than a plain `Set` type parameterized by `'a`?

- [ ] To save memory.
- [ ] Because OCaml does not support polymorphic types.
- [x] Because a set needs an ordering on its elements, and
  parametric polymorphism alone does not provide one.
- [ ] To make the API more complicated.

**Why:** a balanced binary search tree, the standard
implementation of `Set`, needs to compare elements to keep itself
sorted. A polymorphic `'a Set.t` would have no way to know how to
compare two `'a`s. The functor takes the comparison as part of its
argument module, fixing the element type and the ordering in one
go.
:::

:::quiz mcq
What is the result of this snippet, supposing `Stdlib.compare`
gives the usual lexicographic ordering on strings?

```ocaml
module M = Map.Make(String)
let m = M.empty |> M.add "b" 2 |> M.add "a" 1
let _ = M.find "a" m
```

- [ ] `2`
- [x] `1`
- [ ] `Not_found`
- [ ] error

**Why:** the map associates `"a"` with `1` and `"b"` with `2`.
`M.find "a" m` returns the value bound to `"a"`, which is `1`.
The order of `add` calls does not matter for which value `"a"`
is bound to: `add` is a *functional* update (returns a new map),
and the most recent binding for a key wins.
:::

## Activity

:::slide

## Activity

Use `Map.Make(String)` to build a `string -> int` map. Insert
three entries. Look up an existing key and a missing one; report
both results.

:::

:::quiz code
Build a string-keyed map of ages. Fill in `lookup_known` to return
the age of an existing key and `lookup_missing` to return `None`
for a missing one.

```ocaml
module M = Map.Make(String)

let ages =
  M.empty
  |> M.add "alice" 30
  |> M.add "bob" 25
  |> M.add "carol" 28

let lookup_known () : int option = failwith "not implemented"
let lookup_missing () : int option = failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (lookup_known () = Some 30) "alice age";
  check (lookup_missing () = None) "dave missing";
  print_endline "all tests passed"
```
:::

Reference solution:

```ocaml skip
let lookup_known () = M.find_opt "alice" ages
let lookup_missing () = M.find_opt "dave" ages
```

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

- `M.find_opt` returns `int option`: `Some n` for found keys,
  `None` for missing.
- `M.find` raises `Not_found` instead.
- Same convention as Module 7 Lecture 3.

:::

A few things to notice. The `|>` operator chains the inserts left
to right, which is far more readable than the alternative `M.add
"alice" 30 (M.add "bob" 25 (M.add "carol" 28 M.empty))`. Each
`M.add` returns a *new* map; the old map is unchanged. (Inside,
`Map.Make` uses persistent balanced trees that share structure
between versions; the per-insert cost is O(log n), not O(n).)

The `_opt` suffix on `find_opt` is the same convention from M07-L03:
the raising form `M.find` is older; the optional form is the one to
reach for in new code.

## What's next

Lecture 7 is the tutorial for Module 7. We build a small
*functional queue* using the classic two-stack trick: keep two
lists, one for the front and one for the back in reverse order;
push onto the back and pop from the front, refilling the front
from the (reversed) back when it runs out. We package the queue
as a module with a signature hiding the representation, then turn
it into a functor parameterised by the element type. It is a
worked example that touches every piece of machinery from this
module.

:::slide

## What's next

Lecture 7 is the **tutorial** for Module 7.

- Build a small "functional queue" using two stacks.
- Package it as a module with an interface.
- Parameterize it as a functor.

:::

## Reading

- **Cornell CS3110**, *Functors*:
  <https://cs3110.github.io/textbook/chapters/modules/functors.html>
- **Real World OCaml**, *Functors*:
  <https://dev.realworldocaml.org/functors.html>
