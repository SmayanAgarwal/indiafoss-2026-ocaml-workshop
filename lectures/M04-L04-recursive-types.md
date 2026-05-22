---
title: "Recursive types: lists, trees, expressions"
lecture_no: 4
week: 4
duration_target_min: 25
concepts: [recursive types, list, tree, ADT, expression trees, structural induction]
keywords: [OCaml, recursive types, list, tree, ADT, expression]
activity_question: "Extend the [expr] type with a [Sub] constructor (two sub-expressions, like [Add] and [Mul]) and construct a value representing [(7 - 3) - 2]."
think_about_this: "If you compare a value of type [int list] and a value of type [int tree], can [=] tell them apart? What property of structural equality lets one operator handle both?"
reading:
  - title: "Cornell CS3110, Lists"
    url: https://cs3110.github.io/textbook/chapters/data/lists.html
  - title: "Cornell CS3110, Trees"
    url: https://cs3110.github.io/textbook/chapters/data/trees.html
---

# Recursive types


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Recursive types: lists, trees, expressions</h2>
<p class="title-slide-label">Module 4 &middot; Lecture 4</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

A variant becomes much more interesting when one of its constructors
carries a value of *the same type* being defined. That single
self-reference is what makes it possible to describe data of
*unbounded size* with a *fixed* type declaration: lists of any
length, trees of any depth, arithmetic expressions of any
complexity. This lecture covers the canonical recursive shapes,
how OCaml encodes them, and how to walk them with recursive
functions.

We have already met recursion at the *function* level
([M03-L02](M03-L02-recursion.html)). This lecture connects it
with recursion at the *type* level. The two go together: a
recursive type asks for a recursive function to process it, and
the structural shape of the recursion mirrors the shape of the
type. Once you see the connection, writing functions on recursive
data becomes almost mechanical.

[Module 5](M05-L01-basic-patterns.html) will lean heavily on
this: pattern matching on recursive variants is the everyday tool
for processing structured data.
[Module 6](M06-L02-map.html) generalises with higher-order
combinators like `map` and [`fold`](M06-L04-fold.html). The
foundation, the *types themselves*, is what we introduce now.

## A first recursive variant: a list of integers

Start with a list of *integers*. Conceptually, a list is either
empty, or has a head element and a *smaller list* of the same
kind. As a variant:

```ocaml
type intlist =
  | INil
  | ICons of int * intlist
```

`INil` is the empty list. `ICons` carries an `int` (the head) and
another `intlist` (the tail). The interesting bit is that the type
`intlist` appears *inside its own definition*; that is the
"recursive variant" property, and it is what lets one type
declaration describe lists of any length:

```ocaml
type intlist = INil | ICons of int * intlist

let ints = ICons (1, ICons (2, ICons (3, INil)))
```

The names `Nil` and `Cons` (with various prefixes / spellings)
come from Lisp, which used them in the 1950s for exactly this
shape.

:::slide

## A first recursive variant: a list of integers

```ocaml
type intlist =
  | INil
  | ICons of int * intlist

let ints = ICons (1, ICons (2, ICons (3, INil)))
```

- `INil`: empty list.
- `ICons`: head `int` plus a *tail* `intlist`.
- `intlist` appears inside its own definition: **recursive
  variant**.
- One declaration; any length of integer list.

:::

## A list of strings

Suppose we now want a list of *strings*. The shape is the same;
only the element type changes:

```ocaml
type stringlist =
  | SNil
  | SCons of string * stringlist

let strs = SCons ("hello", SCons ("world", SNil))
```

The duplication is starting to feel mechanical. If we also want
`pointlist`, `shapelist`, `userlist`, every type would have its
own copy of the same two-case shape. OCaml has a way to write the
shape *once*, with the element type as a parameter.

:::slide

## A list of strings

```ocaml
type stringlist =
  | SNil
  | SCons of string * stringlist

let strs = SCons ("hello", SCons ("world", SNil))
```

- Same shape as `intlist`; only the element type changed.
- Imagine writing `pointlist`, `shapelist`, `userlist`, ...
- We want **one declaration**, parameterised by the element type.

:::

## Parameterised variants

The trick is to leave the element type as a parameter on the left
of the `=`, using OCaml's *type-variable* syntax: a single quote
followed by an identifier.

```ocaml
type 'a lst =
  | Nil
  | Cons of 'a * 'a lst

let ints = Cons (1, Cons (2, Cons (3, Nil)))
let strs = Cons ("hello", Cons ("world", Nil))
```

One declaration. The same `Nil` and `Cons` work for integers,
strings, points, shapes, whatever. The compiler infers the type
of each value:

- `ints : int lst`
- `strs : string lst`

The element type is fixed *per value*, not per declaration. There
is no way to mix integers and strings inside the same list:
`Cons (1, Cons ("oops", Nil))` would be a type error. Each `'a`
inside a single value is the *same* type.

:::slide

## Parameterised variants

```ocaml
type 'a lst =
  | Nil
  | Cons of 'a * 'a lst

let ints = Cons (1, Cons (2, Nil))
let strs = Cons ("hello", Cons ("world", Nil))
```

- One declaration; any element type.
- `ints : int lst`, `strs : string lst`.
- Inside a single value, every `'a` is the **same** type.

:::

## `'a` is a type variable

The `'a` in `'a lst` is OCaml's syntax for a *type variable*. The
naming convention:

- A regular **variable** is a name standing for an unknown
  *value*. (We have been writing `x`, `n`, `s` for these.)
- A **type variable** is a name standing for an unknown *type*.

OCaml writes type variables with a single quote followed by an
identifier: `'a`, `'b`, `'key`, `'value`. The convention is to
use `'a` and `'b` most of the time, pronounced "alpha" and "beta"
(or just "quote a" and "quote b"). Other languages have the same
idea under different syntax:

- Java: `List<T>`.
- C++: `std::vector<T>`.
- Rust: `Vec<T>`.

OCaml's `'a` is to types what `let x = ...` is to values: a name
standing in for "any one"; the actual choice is made at each use
site.

:::slide

## `'a` is a type variable

- **Variable**: name standing for an unknown value (`x`, `n`).
- **Type variable**: name standing for an unknown type (`'a`,
  `'b`).
- OCaml syntax: single quote, then identifier.
  Pronounced "alpha", "beta", or "quote a", "quote b".
- Same idea: Java `List<T>`, C++ `std::vector<T>`, Rust `Vec<T>`.

:::

## Polymorphism

A definition that contains type variables is *polymorphic*. The
word decomposes: *poly* = many, *morph* = shape. A polymorphic
definition has many shapes; a single declaration covers them all.

- `'a lst` is a polymorphic data type. One declaration, many
  instantiations: `int lst`, `string lst`, `shape lst`, ...
- In `'a lst`, the `lst` part is called a *type constructor*: it
  takes a type (like `int`) and constructs a type (`int lst`).
- This is the same idea as Java generics and C++ template
  instantiation, where one definition is reused at many element
  types.

We will see polymorphic *functions* throughout the rest of the
course. The simplest example is the identity function:

```ocaml
let id x = x
```

The toplevel reports `val id : 'a -> 'a`. One definition; works
at every choice of `'a`.

:::slide

## Polymorphism

- A definition with type variables is **polymorphic**.
  - *poly* = many, *morph* = shape.
- `'a lst` is a polymorphic data type:
  `int lst`, `string lst`, `shape lst`, ...
- `lst` is a **type constructor**: takes a type, gives a type.
- Same idea as Java generics, C++ templates, Rust generics.

```ocaml
let id x = x
```

- `val id : 'a -> 'a`. One definition; every choice of `'a`.

:::

## OCaml's built-in lists are just variants

The standard library defines `list` as a parameterised recursive
variant of exactly the shape we just built:

```text
type 'a list =
  | []
  | (::) of 'a * 'a list
```

`[]` and `::` are constructors, just like our `Nil` and `Cons`.
The only thing special is a small amount of *syntactic sugar*:

- The constructors are written as `[]` and `::` instead of
  alphabetic identifiers. (Most variant constructors must start
  with a capital letter; `[]` and `::` are special-cased.)
- `::` is an infix operator: `1 :: rest` rather than `:: (1, rest)`.
- The bracket literal `[1; 2; 3]` desugars to
  `1 :: 2 :: 3 :: []`.

Strip the sugar and `list` is a normal parameterised variant.

:::slide

## OCaml's built-in lists are just variants

```text
type 'a list =
  | []
  | (::) of 'a * 'a list
```

- `[]` and `::` are constructors.
- `::` is infix; `[1; 2; 3]` desugars to `1 :: 2 :: 3 :: []`.
- Strip the sugar and it is a normal parameterised variant.

:::

A value of type `'a list` is one of two shapes:

- `[]`: the empty list.
- `x :: rest`: an element `x` (of type `'a`) prepended to another
  `'a list` named `rest`.

The recursion is in the second constructor: the cons cell carries
a tail, which is itself a list, which can itself be empty or
another cons cell, and so on. The single self-reference is how
lists of arbitrary length fit in a type declaration of two cases.

## Lists in practice

Because cons prepends an element to an existing list, building a
new list by adding a head is cheap:

```ocaml
let xs = [10; 20; 30]
let ys = 0 :: xs
let _ = ys
```

`ys` is `[0; 10; 20; 30]`. The new value *shares* its tail with
`xs`: no copying happens. Lists are immutable, so this sharing is
safe. Now rebind `xs` to something completely different:

```ocaml
let xs = [99; 99; 99]
let _ = ys
```

`ys` is still `[0; 10; 20; 30]`. The earlier `let ys = 0 :: xs`
captured the *value* `xs` was bound to at that moment (the list
`[10; 20; 30]`), not the *name* `xs`. Rebinding `xs` later does
not change what `ys` points at. This is the same shadowing-is-not-mutation
point from
[M02-L02](M02-L02-let-bindings.html#why-shadowing-differs-from-mutation-closures-see-the-old-value),
applied to lists.

:::slide

## Lists in practice

```ocaml
let xs = [10; 20; 30]
let ys = 0 :: xs
let _ = ys
```

- `int list = [0; 10; 20; 30]`.
- `ys` shares its tail with `xs` (no copy).

Now rebind `xs`:

```ocaml
let xs = [99; 99; 99]
let _ = ys
```

- `ys` is *still* `[0; 10; 20; 30]`.
- `ys` captured the **value** at binding time, not the name `xs`.

:::

The "sharing tails" property is important. Prepending is `O(1)`:
allocate one cons cell, point its tail at the existing list, done.
Appending to the *end* is `O(n)` because you have to walk to the
end first to find the empty list that needs replacing. This is why
OCaml programmers think of lists *head-first*: you grow them by
prepending, you walk them by stripping off the head.

If you find yourself constantly appending to the end of a list,
you probably want a different data structure (an array, a Queue,
or a reversed list that you reverse once at the end).

## A binary tree

The next-simplest recursive variant is a binary tree:

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
```

Two constructors: `Leaf` (the empty tree) and `Node` (a left
subtree, a value, and a right subtree). The recursive references
appear *twice* in `Node`, which is why trees can branch.

A concrete tree:

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree

let example =
  Node (
    Node (Leaf, 1, Leaf),
    2,
    Node (Leaf, 3, Node (Leaf, 4, Leaf)))
```

Drawing this tree:

```
        2
       / \
      1   3
           \
            4
```

The four `Leaf` constructors are the empty-subtree placeholders at
the bottom. They make the tree's shape explicit: every node has
exactly two children, even if one (or both) of them is empty.

:::slide

## A binary tree: the type

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
```

- `Leaf`: empty. `Node`: left, value, right.
- Like a list, but **two** recursive references inside `Node`.
- `'a tree` works for any element type, just like `'a list`.

:::

:::slide

## A binary tree: an example

```ocaml
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree
let example =
  Node (
    Node (Leaf, 1, Leaf),
    2,
    Node (Leaf, 3, Node (Leaf, 4, Leaf)))
```

```text
    2
   / \
  1   3
       \
        4
```

:::

A list is, in a sense, a *unary* tree: each cons cell has a value
and *one* successor (the tail). A binary tree has each node with
*two* successors. You can generalise further: ternary trees, $n$-ary
trees, even trees with an unbounded number of children (called
*rose trees*, which we will see in a moment).

## Mutual recursion at the type level

Two types can be mutually recursive (each referring to the other).
The keyword is `and`, just like for
[mutual recursion of functions in M03-L05](M03-L05-local-and-mutual.html#mutual-recursion-two-functions-calling-each-other).
A small example: a "rose tree" or "n-ary tree," where each node
has a value and an arbitrary number of children:

```ocaml
type 'a forest = 'a rose_tree list
and  'a rose_tree = Rose of 'a * 'a forest
```

A rose tree carries a value and a *forest* of children; a forest
is a list of rose trees. Each definition refers to the other; the
`and` ties them together into one declaration.

:::slide

## Mutual recursion at the type level

Two types can refer to each other:

```ocaml
type 'a forest = 'a rose_tree list
and  'a rose_tree = Rose of 'a * 'a forest
```

- `rose_tree`: value and a *forest* of children.
- `forest`: list of rose trees.
- `and` ties them together.
- Models a node-labelled tree with **any number** of children.

:::

The same `and` keyword serves three purposes in OCaml: mutual
recursion of `let` bindings, mutual recursion of `type` declarations,
and (we will see in [Module 7](M07-L06-module-basics.html)) mutual
recursion of `module` declarations. The intuition is the same in
each case: the names introduced together are all in scope for each
other.

## Modelling arithmetic expressions

A recursive variant can model entire mini-languages. The classic
example is arithmetic expressions: a *number*, or an *addition*
of two sub-expressions, or a *multiplication* of two
sub-expressions:

```ocaml
type expr =
  | Num of int
  | Add of expr * expr
  | Mul of expr * expr

let e = Add (Num 3, Mul (Num 4, Num 5))
```

The value `e` represents the arithmetic expression `3 + (4 *
5)`. The `Add` and `Mul` constructors are recursive: their
payloads are themselves `expr` values, which can be any shape
allowed by the type. With three constructors we can describe
expressions of any depth.

This same recipe (variants for the kinds of node, recursion for
the nesting) is how interpreters, parsers, type checkers, JSON
representations, regex ASTs, configuration languages, and network
protocol decoders are all modelled in OCaml. Once we have pattern
matching, evaluating one of these shapes is straightforward
(`Module 5` has the tools; the
[M05-L06 tutorial](M05-L06-tutorial.html) walks an `expr`
evaluator end-to-end).

:::slide

## Modelling arithmetic expressions

```ocaml
type expr =
  | Num of int
  | Add of expr * expr
  | Mul of expr * expr

let e = Add (Num 3, Mul (Num 4, Num 5))
```

- `e` represents `3 + (4 * 5)`.
- `Add` and `Mul` are recursive: payloads are themselves `expr`.
- Same recipe: JSON, regex, configs, network protocols.
- Walking and evaluating: M05 pattern matching.

:::

## Where this is going

We now have variants for *kinds*, recursion for *nesting*, and
type variables for *polymorphism*. The missing piece is how to
*walk* one of these structures: take an `'a list`, an `'a tree`,
or an `expr` apart and compute something with it. That step is
*pattern matching*, and it gets a whole module of its own:

- [Module 5](M05-L01-basic-patterns.html) introduces pattern
  matching properly: literals, variables, wildcards, nested
  patterns, guards, and exhaustiveness.
- Once we have it, structural recursion (function shape mirrors
  type shape, base case for terminal constructors, recursive
  case for recursive ones) becomes the natural way to write
  every function on a recursive variant.
- [Module 6](M06-L02-map.html) generalises that pattern with
  higher-order combinators (`map`, `filter`, `fold`).

For Module 4, we are done with the *shapes*. Module 5 picks up
the *walks*.

## A short check

:::quiz mcq id=M04-L04-q2
Given:

```ocaml
type expr =
  | Num of int
  | Add of expr * expr
  | Mul of expr * expr
```

Which of these are **valid** values of type `expr`?

- [x] `Num 0`
- [x] `Add (Num 1, Num 2)`
- [x] `Mul (Add (Num 1, Num 2), Num 3)`
- [ ] `Add (1, 2)`

**Why:** `Num`, `Add`, and `Mul` all take payloads that are
themselves `expr`. So `Add` accepts two `expr`s, not two `int`s
directly. `Add (Num 1, Num 2)` is well-typed; `Add (1, 2)` is
not. The recursive nesting (`Mul` of `Add` of `Num`s) is exactly
what makes this a *recursive* variant.
:::

## Activity

:::slide

## Activity

Extend the `expr` type below with a `Sub` constructor that
represents subtraction (two sub-expressions, like `Add` and
`Mul`). Then construct a value representing `(7 - 3) - 2`.

```text
type expr =
  | Num of int
  | Add of expr * expr
  | Mul of expr * expr
  (* add Sub here *)
```

:::

:::slide

## Activity solution

```ocaml
type expr =
  | Num of int
  | Add of expr * expr
  | Mul of expr * expr
  | Sub of expr * expr

let e = Sub (Sub (Num 7, Num 3), Num 2)
```

- One new constructor, same recursive payload shape.
- The value nests `Sub` inside `Sub`: `(7 - 3) - 2`.
- Walking and evaluating this comes in M05.

:::

## What's next

:::slide

## What's next

Lecture 5: **`option`** and **`result`** as the two everyday
utility variants.
Then the tutorial.

:::

We now have variants, records, tuples, recursive variants, and
polymorphism. The [next lecture](M04-L05-option-and-aliases.html)
introduces the two utility variants you will use every day:
`option` ("maybe a value") and `result` ("a value, or an error").
Then the [module tutorial](M04-L06-tutorial.html) puts all of it
together. Walking these data shapes (the step we have been
deferring throughout M04-L03 and M04-L04) starts in
[Module 5](M05-L01-basic-patterns.html), where pattern matching
gets its own treatment.

## Reading

- **Cornell CS3110**, *Lists*:
  <https://cs3110.github.io/textbook/chapters/data/lists.html>
- **Cornell CS3110**, *Trees*:
  <https://cs3110.github.io/textbook/chapters/data/trees.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
