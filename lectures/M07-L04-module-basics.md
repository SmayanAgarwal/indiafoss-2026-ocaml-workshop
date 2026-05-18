---
title: "Module basics"
lecture_no: 4
week: 7
duration_target_min: 22
concepts: [modules, struct, namespacing, opening, naming hygiene]
keywords: [OCaml, module, struct, open, namespace]
activity_question: "Define a module [Stack] that maintains an integer stack with [push : int -> unit], [pop : unit -> int option], and [peek : unit -> int option]. Use a ref inside the module."
think_about_this: "A module groups definitions and a *namespace* under a name. What other languages give you both, and how does OCaml's module system differ from them?"
reading:
  - title: "Cornell CS3110, Modules"
    url: https://cs3110.github.io/textbook/chapters/modules/modules.html
---

# Module basics

A module groups related definitions (types, values, sub-modules)
under a single name. Modules are how OCaml organizes code at scale:
the standard library is a tree of modules (`List`, `String`,
`Array`, `Option`, ...), and a real OCaml project is a tree of
your own modules using and being used by them.

This lecture introduces the syntax. Lecture 5 covers signatures
(the interface side). Lecture 6 covers functors (parameterized
modules).

:::slide

## Inline modules

```ocaml
module Greet = struct
  let hello name = "hello, " ^ name
  let goodbye name = "goodbye, " ^ name
end

let _ = Greet.hello "world"
let _ = Greet.goodbye "world"
```

`"hello, world"`, `"goodbye, world"`.

A module is `module Name = struct ... end`. Inside the struct, you
write top-level definitions just like in a `.ml` file. Outside, you
access them with `Name.value`.

:::

:::slide

## Each `.ml` file is a module

When you write code in a file `foo.ml`, OCaml automatically wraps
it in `module Foo = struct ... end`. Other files reference its
contents as `Foo.x`, `Foo.f`, etc.

This is how the standard library is organized: `list.ml` exposes
the `List` module, `string.ml` exposes `String`, etc.

For now we'll use inline modules (`module M = struct ... end`) in
the toplevel cells to keep examples self-contained.

:::

:::slide

## Modules contain types too

```ocaml
module Color = struct
  type t = Red | Green | Blue
  let to_string = function
    | Red -> "red"
    | Green -> "green"
    | Blue -> "blue"
end

let c : Color.t = Color.Red
let _ = Color.to_string c
```

`"red"`. The `Color` module exposes a type `t` and a function
`to_string`. From outside we write `Color.t` for the type and
`Color.Red` for the constructor.

By convention, a module that's mainly about a type names that
type `t` (so it's `Color.t`, not `Color.color`).

:::

:::slide

## `open` brings names into scope

If you use `Greet.hello` and `Greet.goodbye` repeatedly, you can
*open* the module to drop the prefix:

```ocaml
module Greet = struct
  let hello name = "hello, " ^ name
  let goodbye name = "goodbye, " ^ name
end

let _ =
  let open Greet in
  hello "alice" ^ "; " ^ goodbye "alice"
```

`"hello, alice; goodbye, alice"`.

`let open M in expr` opens `M` inside `expr` only. Outside, `Greet`
is still required as a prefix. This is the *local open*; it's
preferred over the global `open M` because it makes the scope of
the open visible.

:::

:::slide

## When *not* to `open`

Global `open M` brings every name from `M` into the rest of the
file. For small modules, fine. For big ones (`open List`,
`open Stdlib`), it can hide where a name comes from.

A middle ground: `M.()` (apply notation) or `M.[...]` (list
syntax) lets you use module-specific forms briefly:

```ocaml
let _ = List.[1; 2; 3]
let _ = String.length "x" + String.length "yy"
```

`[1; 2; 3]`, `3`. The first is unnecessary here (lists are
top-level) but shows the syntax. The second avoids the verbose
prefix without opening.

:::

:::slide

## Hiding internals

Inside a module you can define *helpers* that aren't meant to be
called from outside. Without an interface (next lecture), every
definition is visible. With an interface, you control what
escapes:

```ocaml
module Counter = struct
  let n = ref 0
  let next () = incr n; !n
  let reset () = n := 0
end

let _ = Counter.next ()
let _ = Counter.next ()
let _ = !Counter.n  (* leaks: external code can poke at n directly *)
```

`1`, `2`, `2`. The `n` ref is visible from outside. We'll see how
to hide it in Lecture 5 with module signatures.

:::

:::slide

## Modules can nest

```ocaml
module Geometry = struct
  module Point = struct
    type t = { x : float; y : float }
    let origin = { x = 0.0; y = 0.0 }
    let make x y = { x; y }
  end

  module Vector = struct
    type t = { dx : float; dy : float }
    let zero = { dx = 0.0; dy = 0.0 }
  end
end

let p = Geometry.Point.make 3.0 4.0
let _ = p.Geometry.Point.x
```

`float = 3.0`. Sub-modules organize a tree of related concepts;
access goes through the full path.

For a real project this is heavy; usually each `.ml` file is one
module and the file system gives you the tree.

:::

:::slide

## Modules are values, sort of

OCaml modules are not first-class values *by default*; you can't
pass them around like ints. There are extensions (*first-class
modules*) that let you, but for the basic Module 7 toolkit, modules
exist at *compile time* and are used statically.

The "function-like" thing that takes a module and returns a module
is called a **functor**; we'll see those in Lecture 6.

:::

:::slide

## Activity

Define a module `Stack` with a mutable integer stack: `push : int
-> unit`, `pop : unit -> int option`, `peek : unit -> int option`.

:::

:::slide

## Activity solution

```ocaml
module Stack = struct
  let s = ref []
  let push x = s := x :: !s
  let pop () =
    match !s with
    | [] -> None
    | x :: rest -> s := rest; Some x
  let peek () =
    match !s with
    | [] -> None
    | x :: _ -> Some x
end

let () = Stack.push 1
let () = Stack.push 2
let () = Stack.push 3
let _ = Stack.peek ()
let _ = Stack.pop ()
let _ = Stack.pop ()
```

`Some 3`, `Some 3`, `Some 2`. We push 1, 2, 3 (top is 3); peek
gives `Some 3`; pop removes and returns 3, then 2.

There's *one* stack, shared by every caller. That's the simplest
design; for multiple independent stacks we'd parameterize.

:::

:::slide

## What's next

Lecture 5: **module signatures**. A signature (`sig ... end` or a
`.mli` file) is a type-level description of a module: which names
escape, with which types. The basis of OCaml's encapsulation
story.

:::

## Reading

- **Cornell CS3110**, *Modules*:
  <https://cs3110.github.io/textbook/chapters/modules/modules.html>
