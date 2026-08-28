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

:::quiz mcq id=M03-L03-q2
Why does restricting `IntSet`'s signature to omit the definition
of `t` matter?

- [ ] It makes `IntSet.add` run faster.
- [x] It hides the implementation detail that `t = int list`, so
      client code cannot depend on it, and the implementation can
      later change (say, to a tree) without breaking callers.
- [ ] It's required syntax; OCaml refuses to compile a module
      signature without hiding at least one type.
- [ ] It prevents `IntSet` from ever being used as a functor
      argument.

**Why:** this is *abstraction*: as long as callers only use the
names published in the signature (`empty`, `mem`, `add`, and the
opaque type `t`), the module's author is free to change how `t`
is represented internally. Nothing outside the module can
type-check code that assumes `t` is secretly a list.
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

:::quiz mcq id=M03-L03-q3
Why does `4 :: s` fail to type-check here, even though `IntSet.t`
is implemented as `int list` under the hood?

- [x] Outside the module, `IntSet.t` is an opaque type; the
      signature does not say it equals `int list`, so the type
      checker treats the two as unrelated.
- [ ] `::` only works inside `struct ... end` blocks.
- [ ] `4` should have been written `4.0`.
- [ ] `IntSet` is a functor, so its values can't be consed onto a
      list.

**Why:** type-checking only ever looks at the *signature* a
module was given, never its hidden implementation. Since the
signature declares `type t` with no equation, `IntSet.t` and
`int list` are, as far as the compiler is concerned, two distinct
types, so `::` (which needs both sides to agree) is rejected —
exactly the protection abstraction is meant to provide.
:::

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

:::quiz mcq id=M03-L03-q1
If a source file is named `math_utils.ml`, what module name does
OCaml automatically give it?

- [x] `Math_utils` — OCaml capitalises just the first letter of
      the file's base name; module names must start with a
      capital letter.
- [ ] `MathUtils` — camelCase, as in many other languages.
- [ ] `math_utils` — exactly the file's base name.
- [ ] `Math_Utils` — every underscore-separated word gets
      capitalised.

**Why:** OCaml derives a file's module name by capitalising only
the first letter; the rest of the name (including underscores) is
left unchanged. So `math_utils.ml` becomes module `Math_utils`,
`list.ml` becomes `List`, and `foo.ml` becomes `Foo`.
:::
