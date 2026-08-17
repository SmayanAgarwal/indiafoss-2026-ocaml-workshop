---
title: "Modules"
lecture_no: 3
week: 3
duration_target_min: 145
concepts: []
keywords: []
reading:
  - title: "The OCaml manual, The module system"
    url: https://ocaml.org/manual/5.5/moduleexamples.html
  - title: "Cornell CS3110, Modular Programming"
    url: https://cs3110.github.io/textbook/chapters/modules/intro.html
---


# Modules

## Structures

### Defining structures

All OCaml programs are organised into *modules*. The simplest form
of module is a *structure*. You can think of structures as
collections of definitions. Structures can be created using the
`module` and `struct` keywords:

:::slide

## Defining structures

```ocaml
module M = struct
  type t = T
  let x = T
end
```

- All OCaml programs are organised into modules; a structure is
  the simplest form of module.
- Structures are collections of definitions.
- Created using the `module` and `struct` keywords.

:::

### Accessing structure components

The components of a module can be accessed using the `.` operator:

```ocaml
let y = M.x
```

Note that the `.` operator works for types as well as values: the
`y` variable defined above has type `M.t`.

### Files as structures

In OCaml every source file defines a structure. For example, a
file called `foo.ml` would be treated as the definition of a
module called `Foo`. We have already used such modules in earlier
examples: for instance the `List.map` function of the standard
library is defined in a file called
[`list.ml`](https://github.com/ocaml/ocaml/blob/trunk/stdlib/list.ml#L90).

## Signatures and abstraction

Just as all values in OCaml have a type, all modules have a
*module type*. As you can see from the output, the module `M`
defined above has the module type:

```
sig
  type t = T
  val x : t
end
```

This means that it contains a variant type `t` with a single `T`
constructor, and a value `x` of type `t`. The module types of
structures, like the one above, are often called *signatures*.

### Signature ascription

Whilst OCaml will infer the module type of a structure from its
definition, you can also ascribe it a more restricted signature.
This allows us to hide some of the details of the structure:

:::slide

## Signature ascription

```ocaml
module IntSet : sig
  type t
  val empty: t
  val mem: int -> t -> bool
  val add: int -> t -> t
end = struct
  type t = int list

  let empty = []

  let mem i s =
    let is_i j = (i = j) in
      List.exists is_i s

  let add i s =
    if mem i s then s
    else i :: s
end
```

- OCaml infers a structure's module type by default, but you can
  ascribe a more restricted signature.
- This hides some of the details of the structure.
- Here `IntSet` has a type `t` representing sets of integers.
- Omitting the definition of `t` hides the implementation, so
  users cannot depend on it being a list.

:::

Here we create an `IntSet` module with a type `t` representing
sets of integers.

```ocaml
let s = IntSet.add 6 (IntSet.add 5 IntSet.empty)

let b = IntSet.mem 6 s
```

By not including the defintion of `t` in the signature, we hide
the implementation of `IntSet`. This means that users of our set
type cannot depend on the fact we have implemented it using lists.

```ocaml skip
let r = 4 :: s
```
```mdx-error
Line 1, characters 13-14:
Error: This expression has type IntSet.t
       but an expression was expected of type int list
```

Later we can switch to a more efficient implementation using trees
safe in the knowledge that this will not break existing code using
`IntSet`.

Types with hiddent definitions, like `t` above, are called
abstract types. OCaml's support for abstraction is one of its most
important and powerful features.

### Signatures for files

To add a signature to the module represented by a file we add an
interface file. For example, if a file called `foo.ml` defines a
structure called `Foo` then `foo.mli` defines the signature of
`Foo`. Corresponding to the
[`list.ml`](https://github.com/ocaml/ocaml/blob/trunk/stdlib/list.ml)
in the OCaml standar library, we have
[`list.mli`](https://github.com/ocaml/ocaml/blob/trunk/stdlib/list.mli)
which describes the signature of the list interface.

## Functors

In OCaml, functors are module level functions that take modules as
arguments and return other modules as results. We had earlier seen
an identity function:

```ocaml
let id (x : int) = x
```

that takes some integer and returns the same. We can define a
similar identity functor at the module level. First, let us define
a module type which only containts the type alias for `int` type.

```ocaml
module type Int = sig
  type t = int
end
```

Now we can define the functor as follows:

:::slide

## Defining a functor

```ocaml
module Id (X: Int) : Int = X
```

- Functors are module-level functions: they take modules as
  arguments and return modules as results.
- `Int` is a module type containing just the type alias for `int`.
- `Id` is a functor from a module of type `Int` to another module
  of type `Int`.

:::

The type says that `Id` is a functor which takes a module of type
`Int` and returns another module of the same module type `Int`.
We can apply the functor to a module that satisfies this signature
as follows:

```ocaml
module S = Id(struct type t = int let v = 10 end)
```

More usefully, with the help of functors we can define a set data
structure over arbitrary data type:

:::slide

## A generic `Set` functor

```ocaml
module Set (Content: sig type t end): sig
  type t
  val empty: t
  val mem: Content.t -> t -> bool
  val add: Content.t -> t -> t
end = struct
  type t = Content.t list

  let empty : t = []

  let mem i s =
    let is_i j = (i = j) in
      List.exists is_i s

  let add i s =
    if mem i s then s
    else i :: s
end
```

- With functors we can define a set data structure over an
  arbitrary data type.
- Applying `Set` to a module providing an integer type gives a set
  of integers; applying it to a module providing floats gives a
  set of floats.

:::

We can use this to create a set of integers:

```ocaml
module IntSet = Set(struct type t = int end)
```

```ocaml
let is = IntSet.add 1 (IntSet.add 2 (IntSet.empty))
```

or floats:

```ocaml
module FloatSet = Set(struct type t = float end)
```

```ocaml
let fs = FloatSet.add 0.1 (FloatSet.add 0.2 (FloatSet.empty))
```

or set of set of integers:

```ocaml
module IntSetSet = Set(IntSet)
```

```ocaml
let iis = IntSetSet.add is IntSetSet.empty
```
