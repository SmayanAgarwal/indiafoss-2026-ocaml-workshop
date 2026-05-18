---
title: "Literals: integers, floats, booleans, strings"
lecture_no: 1
week: 2
duration_target_min: 22
concepts: [primitive types, literal syntax, OCaml number representation, string syntax]
keywords: [OCaml, int, float, bool, string, literals, primitive types]
activity_question: "What is the type of [3 / 2] in OCaml? What does it evaluate to? Now: what is the type of [3.0 /. 2.0], and what does it evaluate to?"
think_about_this: "Why does OCaml use a separate operator [/.] for floating-point division, instead of letting [/] do the right thing depending on its operands?"
reading:
  - title: "Real World OCaml, Chapter 1: A Guided Tour (numbers section)"
    url: https://dev.realworldocaml.org/guided-tour.html
  - title: "Cornell CS3110, Basic types and values"
    url: https://cs3110.github.io/textbook/chapters/basics/expressions.html
---

# Literals

A literal is an expression that *is* its own value: `42`, `3.14`,
`true`, `"hello"`. Every program starts from literals and combines
them with operators and function calls. This lecture covers the four
primitive literal kinds in OCaml, the operators that go with each,
and a few gotchas that catch beginners.

The chapter prose elaborates on each slide. If you are watching the
video, the slides are the spine; the prose here is the longer-form
read for after you have watched.

:::slide

## Four primitive kinds

OCaml has four primitive value kinds we will use constantly:

| Type | Example literal | What it represents |
| --- | --- | --- |
| `int` | `42`, `-7`, `0` | A whole number, signed, 63-bit on 64-bit machines |
| `float` | `3.14`, `2.0`, `-0.5` | An IEEE-754 double-precision floating-point number |
| `bool` | `true`, `false` | A boolean |
| `string` | `"hello"`, `""` | A byte string |

Every literal has a *type* that the OCaml compiler infers
automatically. You never write `int x = 5;` in OCaml. You write
`let x = 5`, and the compiler figures out the type.

:::

## Integers

OCaml integers are *machine* integers, sized to fit a word minus one
bit. On a 64-bit machine that is 63 bits, range roughly
-4.6 × 10^18 to 4.6 × 10^18. The "missing" bit is reserved by the
runtime for tagging values (the same mechanism the garbage collector
uses to distinguish pointers from immediate integers).

You can write integer literals as decimal, hexadecimal (`0x`), octal
(`0o`), or binary (`0b`):

:::slide

## Integer literals

```ocaml
let dec = 255
let hex = 0xff
let oct = 0o377
let bin = 0b11111111
```

All four bindings have type `int` and value `255`. The base prefix is
syntactic; under the hood they're the same number.

Underscores are allowed for readability:

```ocaml
let million = 1_000_000
let mask    = 0xff_ff_ff_ff
```

:::

The `_` is purely visual; the compiler ignores it. This is the same
convention you may have seen in Rust, Java, or Python 3.6+.

For numbers that don't fit in 63 bits, OCaml has `Int64`, `Int32`, and
the `Zarith` library for arbitrary-precision integers. We won't need
them for the first half of the course.

:::slide

## Integer arithmetic

```ocaml
let _ = 2 + 3
let _ = 10 - 4
let _ = 6 * 7
let _ = 17 / 5
let _ = 17 mod 5
```

`+`, `-`, `*` behave as you'd expect. `/` does **truncating integer
division**: `17 / 5 = 3`, the remainder is dropped. `mod` gives the
remainder: `17 mod 5 = 2`.

Negative integer division truncates toward zero, not toward minus
infinity:

```ocaml
let _ = (-17) / 5
```

`int = -3`. Some languages (e.g., Python) round toward minus infinity
and would give `-4`. Be aware.

:::

## Floats

Floating-point numbers in OCaml are IEEE-754 double precision, 64
bits, same as JavaScript's only number type and C's `double`. They
have a decimal point in their literal syntax:

:::slide

## Float literals

```ocaml
let pi    = 3.14159
let half  = 0.5
let e_neg = 2.71828e-1   (* scientific: 2.71828 × 10⁻¹ *)
let tau   = 6.283185
```

All `float`. The `e-1` is the exponent suffix. A number with **no
decimal point** is an integer, not a float:

```ocaml
let bad = 3
```

`bad : int`, not `float`. If you wanted a float, write `3.0` or
`3.` (the trailing zero is optional after a dot).

:::

:::slide

## Float arithmetic uses different operators

```ocaml
let _ = 1.0 +. 2.5
let _ = 10.0 -. 3.0
let _ = 4.0 *. 2.5
let _ = 9.0 /. 4.0
```

Each one is the float-version operator: `+.`, `-.`, `*.`, `/.`. The
trailing `.` is part of the operator name.

Mixing types is a compile-time error:

```ocaml skip
let _ = 1 + 2.0
```

OCaml will say `This expression has type float but an expression was
expected of type int`. There is no implicit promotion. If you want
to add an `int` to a `float`, you convert explicitly:

```ocaml
let _ = float_of_int 1 +. 2.0
```

:::

Beginners often find the separate operators annoying. They are
deliberate. In languages with implicit numeric promotion (C, Java,
Python), the *same* `+` does six or seven different things depending
on operand types: integer add, floating-point add, string concat,
overloaded user-defined operators, etc. Reading code in those
languages requires knowing the types of all operands to know what
the operator means. OCaml separates them so that reading code is
unambiguous: when you see `+`, both sides are `int`.

This same design principle (different operators for genuinely different
operations) is also why string concatenation uses `^`, not `+`.

## Booleans

There are exactly two boolean values: `true` and `false`. The
relevant operators are `&&` (and), `||` (or), `not`, and the
comparisons `=`, `<>`, `<`, `<=`, `>`, `>=`.

:::slide

## Booleans

```ocaml
let _ = true && false
let _ = true || false
let _ = not true
let _ = 3 < 5 && 5 < 10
```

`&&` and `||` *short-circuit* the same way they do in C and Java.
`true || side_effect ()` does not call `side_effect`.

Equality uses **`=`**, not `==`:

```ocaml
let _ = "apple" = "apple"
```

`=` is **structural** equality: it compares values by content, so it
works for strings, lists, records, variants. `==` is **physical**
equality (pointer comparison) and you almost never want it. Stick
with `=`.

:::

The structural-vs-physical distinction is a real trap if you come
from Java or JavaScript, where `==` is the everyday equality
operator. In OCaml, `==` is for the rare case when you specifically
need to test whether two references point to the *same* allocation.
The compiler will let you use `==` on values for which it makes no
sense; it just won't do what you want.

## Strings

Strings in OCaml are sequences of bytes, written with double quotes.

:::slide

## String literals

```ocaml
let hello = "hello"
let empty = ""
let multi = "first line\nsecond line"
let quote = "she said \"hi\""
let path  = "C:\\Users\\kc"
```

Escape sequences: `\n` newline, `\t` tab, `\\` backslash, `\"` quote,
`\NNN` decimal byte, `\xHH` hex byte. Same as C.

```ocaml
let s = "first" ^ " " ^ "second"
```

`^` is concatenation. It is a separate operator from `+` because
strings and numbers are genuinely different operations.

:::

:::slide

## String length and access

```ocaml
let _ = String.length "OCaml"
```

`int = 5`. The `String` module is the standard library's collection
of string-manipulation functions.

```ocaml
let _ = String.get "OCaml" 0
```

`char = 'O'`. (Single quotes for `char` literals: a single byte.)
Indexing is zero-based. Out-of-bounds access raises
`Invalid_argument`.

:::

OCaml's `string` is a sequence of *bytes*, not Unicode characters.
For Unicode-aware work you reach for the `uutf` library; the standard
library's `String` only sees the raw bytes. Most code that just
needs to concatenate, slice, or search byte strings is happy with
plain `String`.

The chapter mode keeps showing this kind of "by the way" detail; in
the slides we keep it tighter. The point is the *primitive kinds*;
the libraries come later.

## Putting it together

:::slide

## A larger expression

```ocaml
let temperature_label c =
  if c < 0.0 then "freezing"
  else if c < 18.0 then "cold"
  else if c < 26.0 then "comfortable"
  else "hot"

let _ = temperature_label 22.5
```

A function with type `float -> string`. The body is one expression: a
chain of `if`/`then`/`else`. We will spend a whole lecture on `if` in
Module 2 Lecture 5; for now, notice that the same kind of literals
we've seen (`0.0`, `18.0`, `"freezing"`) combine into a working
function.

:::

:::slide

## Activity

What is the type and value of:

- `3 / 2`
- `3.0 /. 2.0`

Predict before running.

:::

:::slide

## Activity discussion

- `3 / 2` : `int = 1`. Integer division truncates.
- `3.0 /. 2.0` : `float = 1.5`. Float division does what you expect.

If your background is Python 3, where `/` always does true division
and `//` does floor division, this is the reverse: OCaml's `/`
on integers truncates by default, and there is no implicit cast.

:::

:::slide

## What's next

In the next lecture we look at **`let` bindings**: naming values,
nested bindings, and shadowing. The piece that makes a program more
than a one-liner.

:::

## Reading

- **Real World OCaml**, *A Guided Tour* (numbers section):
  <https://dev.realworldocaml.org/guided-tour.html>
- **Cornell CS3110**, *Basic types and values*:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
