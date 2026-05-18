---
title: "Your first OCaml program: hello, world (and beyond)"
lecture_no: 4
week: 1
duration_target_min: 20
concepts: [print_endline, top-level evaluation, let bindings as statements, the unit type]
keywords: [OCaml, hello world, print_endline, unit, let, beginner OCaml]
activity_question: "If [let () = print_endline \"hi\"] prints \"hi\", what does [let () = ()] do? Predict before running."
think_about_this: "Why does OCaml use the unit value [()] for the result of [print_endline] instead of returning a void / null / None?"
reading:
  - title: "Real World OCaml, Chapter 1: A Guided Tour"
    url: https://dev.realworldocaml.org/guided-tour.html
  - title: "Cornell CS3110, The OCaml toplevel"
    url: https://cs3110.github.io/textbook/chapters/basics/intro.html
---

# Your first OCaml program

The shortest interesting OCaml program prints a line of text. This
lecture introduces the simplest building blocks of programs you can
actually run.

:::slide

## Hello, world

```ocaml
let () = print_endline "hello, world"
```

Click **Run**.

The toplevel prints `hello, world` and reports `val () : unit = ()`.

We just wrote an executable program.

:::

:::slide

## Reading the line

```ocaml
let () = print_endline "hello, world"
```

Parsed left to right:

- `let () = ...` binds the result of the right-hand side to the
  pattern `()` (the only value of the `unit` type).
- `print_endline "hello, world"` is a function call. The function is
  `print_endline`. Its argument is the string `"hello, world"`. Its
  return value is `()`.

The `let () = ...` form says: *evaluate the right-hand side for its
side effect, and assert that its value is unit*.

:::

:::slide

## What is `unit`?

`unit` is OCaml's "no useful value" type. It has exactly one value,
written `()` (an empty tuple). Functions that exist for their side
effects (printing, writing a file, mutating a counter) return `unit`.

```ocaml
let _ = print_endline "first"
let _ = print_endline "second"
let _ = print_endline "third"
```

Three side-effecting calls, each returning `()`.

:::

:::notes
Some students find unit weird at first. The analogy is C's [void]:
"this function returns nothing useful, but the call exists for the
effect." Unlike C, OCaml's unit *is* a real value (you can store it,
pattern-match against it), it's just the only one of its type.
:::

:::slide

## A program is a sequence of `let` bindings

```ocaml
let greeting = "hello, "
let name = "NPTEL"
let () = print_endline (greeting ^ name)
```

Three `let` lines. The first two bind values. The third binds the
unit result of a print. Run it.

The order matters: each `let` can refer to names bound above it.

:::

:::slide

## Naming a value, then using it

```ocaml
let pi = 3.14159
let radius = 5.0
let area = pi *. radius *. radius
let () = print_endline (Printf.sprintf "area = %.4f" area)
```

`Printf.sprintf` returns a formatted string; `print_endline` prints
it. The format specifier `%.4f` means "a float, four digits after the
decimal point".

:::

:::slide

## What happens if you forget `let ()`?

```ocaml
print_endline "hello"
```

This is **a top-level expression** without a `let`. The toplevel will
accept it (and print). At the *file* level (when you save this to a
`.ml` file and compile) you need `let () = print_endline "hello"` so
the compiler knows the result is unit.

A useful habit: even in the toplevel, prefer `let () = ...` for
side-effecting calls. It documents intent and catches accidents like
this:

```ocaml
let () = 42
```

OCaml refuses to compile that, because `42` is not unit.

:::

:::slide

## A small interactive program

```ocaml
let square x = x * x
let cube x = x * x * x

let () =
  print_endline (Printf.sprintf "square 5 = %d" (square 5));
  print_endline (Printf.sprintf "cube 5   = %d" (cube 5));
  print_endline (Printf.sprintf "square 5 + cube 5 = %d" (square 5 + cube 5))
```

Two helper functions and then a single `let ()` that *sequences*
three prints. The `;` between statements sequences side-effecting
expressions.

Run it; expect three lines of output.

:::

:::slide

## Two semicolons are different from one

- `;` (single) sequences side-effecting expressions: "do this, then
  that". The left side **must be unit**.
- `;;` (double) is the toplevel's "end of input" marker. You see it
  in tutorials and books that show toplevel transcripts. You almost
  never need it in source files; the compiler infers where each
  expression ends.

```ocaml
let () =
  print_endline "first";
  print_endline "second"
```

One `;`. Two prints. One `let ()`.

:::

:::slide

## Activity

What does this program print?

```ocaml
let () =
  print_endline "A";
  print_endline "B"

let () = print_endline "C"
```

Predict before pressing Run.

:::

:::slide

## Activity discussion

`A`, then `B`, then `C`.

Top-level `let` bindings execute **in order, top to bottom**. The
first `let ()` runs its sequenced body (`A` then `B`), then the second
`let ()` runs (`C`).

This is what makes an OCaml program: a sequence of top-level
bindings, evaluated once each, in source order.

:::

:::slide

## What's next

In the next lecture we look at the **type system**: what `int`,
`float`, `string`, `bool` give you that dynamically typed languages
hide, and how OCaml infers types you never had to write.

:::

## Reading

- **Real World OCaml**, *A Guided Tour*: <https://dev.realworldocaml.org/guided-tour.html>
- **Cornell CS3110**, *The OCaml toplevel*:
  <https://cs3110.github.io/textbook/chapters/basics/intro.html>
