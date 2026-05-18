---
title: "Tutorial: temperature conversions and small expressions"
lecture_no: 5
week: 1
duration_target_min: 25
concepts: [walkthrough, problem solving, debugging type errors, build-and-run loop]
keywords: [OCaml, tutorial, temperature, conversion, type error, beginner OCaml]
activity_question: "Write a function [bmi : float -> float -> float] that takes a mass in kilograms and a height in metres, and returns the body mass index (mass divided by height squared). Test it with [bmi 70.0 1.75]."
think_about_this: "When OCaml gives you a type error, the error message names the file, line, and *expected vs. actual* types. Why does naming what was expected before what was actual matter more than the other way around?"
reading:
  - title: "Cornell CS3110, Basics chapter (revisit if anything in Module 1 felt thin)"
    url: https://cs3110.github.io/textbook/chapters/basics/index.html
---

# Tutorial: small expressions, end to end

This is the tutorial video for Module 1. We will work through a few
small problems start to finish, and pause on the type errors you are
likely to hit while you are getting comfortable.

The cells on this page are all editable. Try changing things and see
what the compiler says.

:::slide

## Problem 1: Celsius to Kelvin

Write a function that converts a temperature in degrees Celsius to
Kelvin (add 273.15).

```ocaml
let kelvin_of_celsius c = c +. 273.15
```

Try it:

```ocaml
let _ = kelvin_of_celsius 100.0
```

The toplevel reports `float = 373.15`. Boiling point of water,
in Kelvin.

:::

:::slide

## Problem 1 type-check

What is the type of `kelvin_of_celsius`?

```ocaml
let kelvin_of_celsius c = c +. 273.15
```

`float -> float`. The `+.` operator forces `c` to be `float`, and the
result of `+.` is `float`, so the function is `float -> float`.

If you had accidentally written `c + 273.15`, OCaml would have
complained: `+` is integer addition, and `273.15` is not an integer.
The error would have read:

```
This expression has type float but an expression was expected of type int
```

:::

:::slide

## Problem 2: Round-trip

Convert Celsius to Kelvin and back. Verify you get the same number.

```ocaml
let kelvin_of_celsius c = c +. 273.15
let celsius_of_kelvin k = k -. 273.15

let original = 36.6
let there_and_back = celsius_of_kelvin (kelvin_of_celsius original)
```

Run it. The toplevel reports `there_and_back = 36.6` (or thereabouts;
see next slide).

:::

:::slide

## Float precision aside

Sometimes `there_and_back` is not *exactly* `36.6`. Floats are stored
with finite precision, and `+. 273.15 -. 273.15` can introduce a tiny
rounding error.

```ocaml
let _ = 0.1 +. 0.2
```

`float = 0.300000000000000044`, not `0.3`. This is true in every
language that uses IEEE 754 floats, including Python and JavaScript.

When you compare floats, prefer "close enough":

```ocaml
let close a b = abs_float (a -. b) < 1e-9
```

:::

:::slide

## Problem 3: a more useful predicate

A "healthy" daytime temperature for a city is between 15 and 30 °C.
Write a function that tells you whether a given Celsius value is in
that range.

```ocaml
let is_comfortable c = c >= 15.0 && c <= 30.0
```

```ocaml
let _ = is_comfortable 22.0
```

```ocaml
let _ = is_comfortable 38.0
```

`true` and `false`. The function's type, inferred, is
`float -> bool`.

:::

:::slide

## Problem 4: combining functions

Now compose. We have temperatures in Kelvin from a sensor, and want a
Celsius-flavoured comfort check.

```ocaml
let kelvin_of_celsius c = c +. 273.15
let celsius_of_kelvin k = k -. 273.15
let is_comfortable c = c >= 15.0 && c <= 30.0

let is_comfortable_kelvin k =
  is_comfortable (celsius_of_kelvin k)

let _ = is_comfortable_kelvin 295.15  (* 22 °C *)
```

`true`. Notice that `is_comfortable_kelvin` is built by *applying*
`is_comfortable` to the *result* of `celsius_of_kelvin`. No new logic;
just composition.

:::

:::slide

## Reading a type error

Type errors are noisy at first. Let's deliberately write one.

```ocaml skip
let bad c = c + 273.15
```

The toplevel will say something like:

```
Error: This expression has type float but an expression was expected
       of type int because it is in the result of an integer
       application
```

Three pieces of information:

- the offending expression (`273.15`)
- the actual type (`float`)
- the expected type (`int`)
- *why* the expected type is what it is

In this case "because of integer `+`". Fix: use `+.`.

:::

:::slide

## Activity

Write a function `bmi` that takes a mass in kilograms and a height in
metres, and returns the body mass index (mass divided by height squared).

```ocaml skip
(* fill in *)
let bmi mass height = ???
```

Test it with `bmi 70.0 1.75`. Expected answer: about `22.86`.

:::

:::slide

## Activity solution

```ocaml
let bmi mass height = mass /. (height *. height)
```

```ocaml
let _ = bmi 70.0 1.75
```

The toplevel reports `float = 22.857142857142854`. Close to the
expected `22.86`; the trailing digits are float precision noise.

The inferred type is `float -> float -> float`. Two floats in, one
float out.

:::

:::slide

## What you should be able to do now

- Write a small function in OCaml and run it.
- Read the type the toplevel reports.
- Recognise when a type error is asking for `+.` rather than `+`.
- Compose two functions by feeding one's result into the next.

That's the foundation. Module 2 dives into the structure of OCaml
expressions in more depth: literals, `let` bindings, operators,
`if`/`then`/`else`. We start writing real (small) programs.

:::

## Reading

- **Cornell CS3110, Basics chapter** revisit if anything in Module 1
  felt thin: <https://cs3110.github.io/textbook/chapters/basics/index.html>
