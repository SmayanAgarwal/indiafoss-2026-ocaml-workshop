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

- `if`/`else` **does something** (assigns) but has **no value**.
- Can't write `int abs_val = if (x < 0) -x else x;` in C.
- Forces a separate declaration plus a separate statement.
- Two pieces of code where one might do.

:::

:::slide

## In OCaml, `if` is an expression

```ocaml skip
let abs_val = if x < 0 then -x else x
```

- `if x < 0 then -x else x` is an **expression**.
- Has a type and a value.
- Can be bound, returned, or passed as an argument.
- No "first declare, then fill in": the expression **is** the value.

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

- `E1` **condition**: must be `bool`.
- `E2` **then-branch**: some type `T`.
- `E3` **else-branch**: must be the **same `T`** as `E2`.
- Whole expression: type `T`.

```ocaml
let _ = if true then 13 else 14
```

- Result `int = 13`.
- Condition `bool`, both branches `int`, whole expression `int`.

:::

:::slide

## The branches must agree

```ocaml skip
let _ = if true then 13 else 13.4
```

OCaml rejects this:

```
Error: This expression has type float but an expression was expected
       of type int
```

- Then-branch `int`, else-branch `float`.
- Compiler can't assign a **single type** to the whole expression.
- If accepted, the type would depend on which branch ran: dynamic, not static.
- OCaml's rule: to mix, **decide up front and convert one side**.

:::

:::slide

## Fix: convert one side

```ocaml
let _ = if true then 13.0 else 13.4
```

- Result `float = 13.0`. Both branches now `float`.

Or:

```ocaml
let _ = if true then 13 else int_of_float 13.4
```

- Result `int = 13`. Both branches now `int`.
- The choice depends on the answer you want; the **compiler won't pick** for you.

:::

This rule (both branches must have the same type) is the
"static-not-dynamic" part of `if`/`then`/`else`. The compiler is not
allowed to wait until runtime to find out which branch fires; it
must give the whole expression a type *before* running it. That
forces the two branches to agree.

:::slide

## Inference rule, written out

The **typing rule** for `if`:

```
  E1 : bool      E2 : T      E3 : T
  ---------------------------------
        if E1 then E2 else E3 : T
```

- Read the bar as "if the things above hold, then the thing below holds".
- **Premises** (above): `E1 : bool`, `E2 : T`, `E3 : T`.
- **Conclusion** (below): whole expression has type `T`.
- Inference rules recur throughout this course.
- Precise way to write what we've been saying in English.

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

- Result: `string = "B"`.
- Chain of `if`/`then`/`else` is **one big expression** of type `string`.
- The shape for "compute X based on input Y".
- Replaces `switch` / nested `if`/`else` in an imperative language.

:::

:::slide

## `if` without `else`

- You can write `if cond then expr` with no `else`.
- The omitted `else` is treated as `else ()` (unit value).
- So `expr` must have type `unit`.

```ocaml
let warn_if_negative x =
  if x < 0 then print_endline "warning: negative"
```

- `val warn_if_negative : int -> unit`.
- Body has type `unit`: then-side prints, else-side is implicit `()`.
- For positive `x`, nothing is printed; function returns `()`.

- Use one-armed `if` only for **side effects** (printing, mutating).
- For computing a value, always need both branches.

:::

:::slide

## Branches can themselves be `if`s

```ocaml
let sign x =
  if x > 0 then 1
  else if x < 0 then -1
  else 0
```

- `"else if"` is just `else (if ... then ... else ...)`.
- Same expression, with parens made explicit:

```ocaml
let sign x =
  if x > 0 then 1
  else (if x < 0 then -1 else 0)
```

- Idiomatic OCaml leaves parens off.
- Reads top-to-bottom: `if`, `else if`, `else if`, `else`.

:::

:::slide

## Branches can return functions, or lists, or anything

- `if` is an expression: its value can be **anything** of the agreed type.

```ocaml
let pick mode =
  if mode = "double" then (fun x -> x * 2)
  else (fun x -> x + 1)

let f = pick "double"
let _ = f 7
```

- Result: `int = 14`.
- Both branches are functions; whole `if` returns a function.
- `pick : string -> int -> int`.
- "Pick which function to apply" pattern is verbose in C / Java.
  - Needs interfaces, function pointers, or a switch.
- In OCaml it's just a value: `if`-expression of two functions, picked at runtime.

:::

:::slide

## Activity

Why does OCaml reject the following? Be precise about which rule is
violated.

```ocaml skip
let label x =
  if x > 0 then "positive"
  else 0
```

:::

:::slide

## Activity discussion

Branches don't share a type:

- Then: `"positive"` is `string`.
- Else: `0` is `int`.

- Typing rule for `if`: both branches share a type `T`.
- No `T` is both `string` and `int`. Compiler reports:

```
Error: This expression has type int but an expression was expected
       of type string
```

- To fix: decide whether `label` returns `string` (else `"non-positive"`) or `int`.

:::

:::slide

## What's next

- Lecture 6: **tutorial** for Module 2.
- Work through several small programs end to end.
- Uses everything from this module: literals, `let`, types, operators, `if`.
- Meet a few of the type errors that show up in practice.

:::

## Reading

- **Cornell CS3110**, *Conditional expressions*:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
