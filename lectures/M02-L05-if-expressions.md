---
title: "`if`/`then`/`else` as an expression"
lecture_no: 5
week: 2
duration_target_min: 25
concepts: [if as expression, expression-oriented language, branches must agree, type rule for if]
keywords: [OCaml, if expression, conditional, branches, expression-oriented]
activity_question: "Why does OCaml reject [if x > 0 then \"positive\" else 0]? Explain the rule the compiler is enforcing."
think_about_this: "In C and Java, [if (...) {} else {}] is a *statement*: it does something but has no value. OCaml's [if] is an *expression*: it has a value, just like [1 + 2]. What changes in how you write programs once [if] is an expression?"
reading:
  - title: "Cornell CS3110, Conditional expressions"
    url: https://cs3110.github.io/textbook/chapters/basics/expressions.html
---

# `if`/`then`/`else` as an expression

This lecture introduces conditionals. In OCaml, **`if` is an
expression**: it has a value, just like `1 + 2` or `"hello"`. This is
a small syntactic difference from C and Java, with a big consequence
for how you write code.

:::slide

## In C, `if` is a statement

```c
int abs_val;
if (x < 0) abs_val = -x; else abs_val = x;
```

The `if`/`else` *does something* (assigns to `abs_val`), but it has
no value. You can't write `int abs_val = if (x < 0) -x else x;` in
C.

This is why you need a *separate declaration* (`int abs_val;`) and
then a *separate statement* that fills it in. Two pieces of code
where one might do.

:::

:::slide

## In OCaml, `if` is an expression

```ocaml
let abs_val = if x < 0 then -x else x
```

`if x < 0 then -x else x` is an *expression*. It has a type, a value,
and you can bind it to a name, return it from a function, or pass it
to another function.

No separate "first declare, then fill in". The expression *is* the
value you want.

:::

This change cascades. Every place you wanted to compute a value
conditionally, you can now do it in one expression. Functions stay
small. Mutation stops being necessary in cases where C *forced* you
to mutate. You'll see this pattern in nearly every OCaml program.

:::slide

## The shape

```
if E1 then E2 else E3
```

Three sub-expressions:

- `E1` is the **condition**. Must have type `bool`.
- `E2` is the **then-branch**. Has some type `T`.
- `E3` is the **else-branch**. Must have **the same type `T`** as
  `E2`.

The whole `if`/`then`/`else` expression has type `T`.

```ocaml
let _ = if true then 13 else 14
```

`int = 13`. The condition is `bool`, both branches are `int`, so
the whole expression is `int`.

:::

:::slide

## The branches must agree

```ocaml
let _ = if true then 13 else 13.4
```

OCaml rejects this:

```
Error: This expression has type float but an expression was expected
       of type int
```

The then-branch is `int`, the else-branch is `float`. The compiler
cannot give the whole expression a single type. If it accepted this,
the type of the `if` would depend on which branch ran, which is a
dynamic-not-static property.

So OCaml says: if you want to mix types, decide up front, and
convert one side.

:::

:::slide

## Fix: convert one side

```ocaml
let _ = if true then 13.0 else 13.4
```

`float = 13.0`. Both branches are now `float`.

Or:

```ocaml
let _ = if true then 13 else int_of_float 13.4
```

`int = 13`. Both branches are now `int`.

The choice depends on what you want the answer to be. The compiler
will not pick for you.

:::

This rule (both branches must have the same type) is the
"static-not-dynamic" part of `if`/`then`/`else`. The compiler is not
allowed to wait until runtime to find out which branch fires; it
must give the whole expression a type *before* running it. That
forces the two branches to agree.

:::slide

## Inference rule, written out

A useful piece of notation: the **typing rule** for `if`.

```
  E1 : bool      E2 : T      E3 : T
  ---------------------------------
        if E1 then E2 else E3 : T
```

Read the bar as "if the things above hold, then the thing below
holds". The premises (above the bar) are: `E1` has type `bool`, `E2`
has type `T`, `E3` has type `T`. The conclusion (below the bar) is:
the whole expression has type `T`.

You will see inference rules a lot in this course. They are the
precise way to write what we've been saying in English.

:::

:::slide

## A typical use

```ocaml
let grade_letter score =
  if score >= 90 then "A"
  else if score >= 80 then "B"
  else if score >= 70 then "C"
  else if score >= 60 then "D"
  else "F"

let _ = grade_letter 87
```

`string = "B"`. A chain of `if`/`then`/`else` is one big expression
whose type is `string` (all branches return strings).

This is the shape you use whenever you want to "compute X based on
input Y". It replaces what would be a `switch` or a nested `if`/
`else` in an imperative language.

:::

:::slide

## `if` without `else`

You can write `if cond then expr` with no `else`. But the type rule
is strict: the omitted `else` is treated as `else ()` (the unit
value), so `expr` must have type `unit`.

```ocaml
let warn_if_negative x =
  if x < 0 then print_endline "warning: negative"
```

`val warn_if_negative : int -> unit`. The body has type `unit` (one
side is `print_endline ...`, the other side is the implicit
`()`). When `x` is positive, nothing is printed and the function
returns `()`.

You only use one-armed `if` for side effects (printing, mutating).
For computing a value, you always need both branches.

:::

:::slide

## Branches can themselves be `if`s

```ocaml
let sign x =
  if x > 0 then 1
  else if x < 0 then -1
  else 0
```

The "else if" is just `else (if ... then ... else ...)`. The
expression nests:

```ocaml
let sign x =
  if x > 0 then 1
  else (if x < 0 then -1 else 0)
```

Same thing, with the nesting made explicit by parens. Idiomatic OCaml
leaves the parens off and reads top-to-bottom: `if`, `else if`,
`else if`, `else`.

:::

:::slide

## Branches can return functions, or lists, or anything

`if` is an expression, so it has a value, and that value can be
*anything* of the agreed-upon type.

```ocaml
let pick mode =
  if mode = "double" then (fun x -> x * 2)
  else (fun x -> x + 1)

let f = pick "double"
let _ = f 7
```

`int = 14`. The two branches are functions; the whole `if` returns
a function; `pick` has type `string -> int -> int`.

This kind of "compute which function to apply" pattern is verbose in
C and Java (you'd need an interface, or function pointers, or a
switch). In OCaml it's just a value: an `if`-expression returning
two different functions, picked at runtime.

:::

:::slide

## Activity

Why does OCaml reject the following? Be precise about which rule is
violated.

```ocaml
let label x =
  if x > 0 then "positive"
  else 0
```

:::

:::slide

## Activity discussion

The `if` expression's two branches don't have the same type:

- Then-branch: `"positive"` is `string`.
- Else-branch: `0` is `int`.

The typing rule for `if` requires both branches to share a type `T`.
There is no `T` that is both `string` and `int`. The compiler
reports:

```
Error: This expression has type int but an expression was expected
       of type string
```

To fix, decide whether `label` should return a `string` (then change
the else to `"non-positive"` or similar) or an `int`.

:::

:::slide

## What's next

Lecture 6 is the **tutorial** for Module 2: we work through several
small programs end to end, using everything from this module
(literals, `let`, types, operators, `if`), and meet a few of the
type errors that show up in practice.

:::

## Reading

- **Cornell CS3110**, *Conditional expressions*:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
