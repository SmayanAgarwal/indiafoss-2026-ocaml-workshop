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

This lecture introduces conditionals. The construct is familiar from
every language you have written before: a way to choose between two
courses of action depending on a boolean. The OCaml version of
`if`/`then`/`else` looks similar at first, but it has a property
that changes how you write code: in OCaml, `if`/`then`/`else` is an
*expression* that has a value, not a *statement* that just runs
something. This is a small syntactic difference with a big
consequence for how programs are structured.

If you arrived from C, Java, or Python, you have written code like
"declare a variable; do an `if`; assign the variable in each
branch." OCaml lets you collapse that pattern: bind the variable
directly to the result of the `if`. The line shrinks, the
intermediate state disappears, the program becomes easier to read.
The cost is a single rule: both branches must produce values of the
same type. We will see why this rule is necessary and how to live
within it.

## In C, `if` is a statement

In C and Java, conditionals do not have values. They are
*statements*: blocks of code that get executed for their effects.
Here is the canonical use:

```c
int abs_val;
if (x < 0) abs_val = -x; else abs_val = x;
```

:::slide

## In C, `if` is a statement

```c
int abs_val;
if (x < 0) abs_val = -x; else abs_val = x;
```

- `if`/`else` **does something** but has **no value**.
- Can't write `int abs_val = if (x < 0) -x else x;` in C.
- Forces separate declaration plus separate statement.

:::

We declare `abs_val` first, then the `if` assigns to it. The
declaration and the assignment have to be separate, because `if`
is a statement: it does not produce a value you can use in the
declaration. The C compiler is also slightly nervous about this
pattern: `abs_val` is uninitialised at declaration, and if the
`if` somehow took neither branch (impossible here, but in general
it can happen), the variable would stay uninitialised. C tries to
catch this with control-flow analysis; the workaround is usually
to give the variable a sentinel default.

Some C-family languages have a *ternary* operator `cond ? a : b`
that *is* an expression, returning either `a` or `b`. So you can
write `int abs_val = (x < 0) ? -x : x` in C, Java, JavaScript. The
ternary is OCaml's `if`-as-expression in disguise. But the ternary
is awkward to nest, and most C programmers write the statement
form for anything beyond simple cases.

## In OCaml, `if` is an expression

OCaml has no separate ternary operator. Instead, the ordinary
`if`/`then`/`else` is itself an expression with a value:

```ocaml
let abs_val x = if x < 0 then -x else x
```

:::slide

## In OCaml, `if` is an expression

```ocaml skip
let abs_val = if x < 0 then -x else x
```

- `if x < 0 then -x else x` is an **expression** with a value.
- Bind it, return it, pass it as an argument.
- No "first declare, then fill in"; the expression **is** the value.

:::

`if x < 0 then -x else x` is the entire body of the function. It
is an expression of type `int`, equal to `-x` when `x < 0` and to
`x` otherwise. The function `abs_val` simply *is* that expression,
parameterised by `x`.

This is more than a cosmetic change. Anywhere an expression can
go, an `if` can go: as a function argument, as the right-hand side
of a `let`, inside another expression. You will use this
constantly. Examples:

```ocaml
let _ = print_endline (if true then "yes" else "no")
```

```ocaml
let nat = let n = 7 in if n >= 0 then n else 0
```

The first prints "yes". The second binds `nat` to 7 (the
non-negative number from `n`). The `if`-expression inside the
`let` is fine; we did not need a separate declaration.

## The shape and type rule

The general form is `if E1 then E2 else E3`, where:

- `E1` is the **condition**: it must have type `bool`.
- `E2` is the **then-branch**: it has some type `T`.
- `E3` is the **else-branch**: it must have the *same* type `T`.
- The whole expression has type `T`.

```ocaml
let _ = if true then 13 else 14
```

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

Result: `int = 13`. The condition `true` evaluates to `true`
(itself), the then-branch fires, the value is `13`.

The "both branches must have the same type" rule is the part that
catches new OCaml programmers, and it is worth understanding why
the rule has to be this way.

## Why the branches must agree

```ocaml skip
let _ = if true then 13 else 13.4
```

OCaml rejects this with:

```
Error: This expression has type float but an expression was expected
       of type int
```

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
- Rule: to mix, **decide up front and convert one side**.

:::

The branches return different types: `int` in one case, `float` in
the other. The compiler cannot assign a *single* type to the whole
`if`-expression. If it accepted the program, the type would depend
on which branch ran at runtime: dynamic, not static. This goes
against the entire point of static typing (a program's types are
known before it runs).

The fix is to bring both branches to the same type. Either both
floats:

```ocaml
let _ = if true then 13.0 else 13.4
```

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
- The **compiler won't pick** for you.

:::

Or both ints:

```ocaml
let _ = if true then 13 else int_of_float 13.4
```

The compiler will not pick for you. You decide which type you want
and convert the other branch to match.

The rule generalises to anything, not just numbers. If the branches
return a `string` and an `int`, you get a type error. If they
return a list of `int` and a list of `string`, same thing. The
rule is "both branches the same type", full stop.

## The typing rule, written out

Programming-languages people write rules like this with horizontal
bars, where the lines above the bar are *premises* and the line
below is the *conclusion*:

```
  E1 : bool      E2 : T      E3 : T
  ---------------------------------
        if E1 then E2 else E3 : T
```

:::slide

## Inference rule, written out

The **typing rule** for `if`:

```
  E1 : bool      E2 : T      E3 : T
  ---------------------------------
        if E1 then E2 else E3 : T
```

- Bar reads as "if the things above hold, then the thing below holds".
- **Premises** above; **conclusion** below.
- Same `T` in both branches.

:::

Read as: "if `E1` has type `bool`, and `E2` has type `T`, and `E3`
has type `T` (the same `T`), then the whole expression `if E1 then
E2 else E3` has type `T`." This is one of the standard rules of
the OCaml type system, and we will see more such rules as we
introduce more constructs. They are the precise statement of what
the compiler is checking.

You do not have to read these rules to use OCaml. They are useful
notation when we need to be precise about *exactly* what the type
checker does. [Module 4](M04-L01-tuples.html) (data types) and
[Module 5](M05-L01-basic-patterns.html) (pattern matching)
introduce more constructs with their own rules.

## A typical use: multi-way branching

A chain of `if`/`else if`/`else if`/`else` lets you do multi-way
branching cleanly:

```ocaml
let grade_letter score =
  if score >= 90 then "A"
  else if score >= 80 then "B"
  else if score >= 70 then "C"
  else if score >= 60 then "D"
  else "F"

let _ = grade_letter 87
```

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
- Chain of `if`/`then`/`else` is **one expression** of type `string`.
- Shape for "compute X based on input Y".

:::

Result: `string = "B"`. The chain is, formally, a deeply nested
single `if`-expression: `if E1 then "A" else (if E2 then "B" else
(if E3 then "C" else (if E4 then "D" else "F")))`. OCaml allows
you to write `else if` to make the chain readable; semantically,
each `else if` is just the `if`-expression that the previous
`else` returns.

For multi-way branching on a *value's structure* (rather than on
threshold comparisons), the better tool is
[*pattern matching*](M05-L01-basic-patterns.html) (Module 5). Use
`if` chains when you have threshold comparisons or boolean
predicates; use `match` when you are unpacking a value.

## `if` without `else`

You can write `if cond then expr` with no `else`. The omitted
`else` is treated as `else ()`, the unit value.

```ocaml
let warn_if_negative x =
  if x < 0 then print_endline "warning: negative"
```

:::slide

## `if` without `else`

- `if cond then expr` with no `else`: implicit `else ()`.
- So `expr` must have type `unit`.

```ocaml
let warn_if_negative x =
  if x < 0 then print_endline "warning: negative"
```

- `val warn_if_negative : int -> unit`.
- For positive `x`, function returns `()` and prints nothing.
- Use one-armed `if` only for **side effects**.
- For computing a value, you need both branches.

:::

The function `warn_if_negative : int -> unit` has type `unit` (no
useful value, like C's `void`). The branches must both be `unit`:
the then-branch prints (returns `()`), and the implicit else is
`()`. For non-negative inputs, nothing is printed; the function
just returns `()`.

Use one-armed `if` only for side effects (printing, mutating). For
computing a *value*, you need both branches: the else has to
return something of the appropriate type, and there is no sensible
default for arbitrary types.

## Nested `if`s

Branches can themselves be `if`-expressions, naturally:

```ocaml
let sign x =
  if x > 0 then 1
  else if x < 0 then -1
  else 0
```

:::slide

## Branches can themselves be `if`s

```ocaml
let sign x =
  if x > 0 then 1
  else if x < 0 then -1
  else 0
```

- `else if` is just `else (if ... then ... else ...)`.
- Same expression, parens explicit:

```ocaml
let sign x =
  if x > 0 then 1
  else (if x < 0 then -1 else 0)
```

- Idiomatic OCaml leaves the parens off.

:::

As we said: `else if` is sugar for `else (if ... then ... else
...)`. Either form is fine; the unparenthesised form reads more
naturally for a chain.

## Branches can be anything

`if` returns a value of *any* type, as long as both branches agree.
The value can be a function, a list, a record, a tuple, anything.

```ocaml
let pick mode =
  if mode = "double" then (fun x -> x * 2)
  else (fun x -> x + 1)

let f = pick "double"
let _ = f 7
```

:::slide

## Branches can return functions, or lists, or anything

- `if` is an expression: value can be **anything** of the agreed type.

```ocaml
let pick mode =
  if mode = "double" then (fun x -> x * 2)
  else (fun x -> x + 1)

let f = pick "double"
let _ = f 7
```

- Result: `int = 14`. Both branches are functions.
- `pick : string -> int -> int`.
- Pattern "pick a function" is verbose in C / Java; in OCaml it's
  just an `if` of two functions.

:::

Result: `int = 14`. The `if`-expression picks one of two
functions based on `mode`, and we then apply the picked function
to `7`. The whole pattern is *one expression* in OCaml. Doing
this in Java would require a `switch` on `mode`, or an interface
with two implementations, or function-pointer bookkeeping. In
OCaml, "pick a function based on a condition" is just an `if` of
two functions.

This kind of compactness pays dividends through the rest of the
course. Once you internalise that `if` returns *anything*, you
start writing programs that pick out values, functions, even
modules conditionally.

## A quick check

:::quiz mcq id=M02-L05-q3
Which of the following OCaml expressions has type `string`?

- [x] `if x > 0 then "positive" else "non-positive"`
- [ ] `if x > 0 then "positive" else 0`
- [ ] `if x > 0 then "positive"`
- [ ] `if "x" > 0 then "yes" else "no"`

**Why:** the first has both branches returning `string` (the
correct shape). The second mixes `string` and `int` branches:
type error. The third has no else, which OCaml treats as
`else ()`; the then-branch would have to be `unit`, but it's
`string`: type error. The fourth has the condition `"x" > 0`,
which compares `string` to `int`: type error.
:::

A code challenge:

:::quiz code id=M02-L05-q2
Define `sign : int -> int` that returns 1 for positive inputs, -1
for negative inputs, and 0 for zero.

```ocaml
let sign x =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (sign 5    =  1) "sign 5";
  check (sign (-3) = -1) "sign -3";
  check (sign 0    =  0) "sign 0";
  check (sign 100  =  1) "sign 100";
  print_endline "all tests passed"
```
:::

The reference implementation is `if x > 0 then 1 else if x < 0
then -1 else 0`. Three branches, two thresholds.

## Activity

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

:::quiz mcq id=M02-L05-q1
Why does OCaml reject this?

```ocaml skip
let label x =
  if x > 0 then "positive"
  else 0
```

- [ ] `if` cannot be used as the body of a function.
- [ ] `"positive"` is not a valid OCaml string literal.
- [x] The two branches have different types (`string` and `int`).
- [ ] `x > 0` is not a valid boolean expression.

**Why:** OCaml's `if`-expression requires both branches to have
the same type. Here the then-branch returns `"positive"` (a
`string`) and the else-branch returns `0` (an `int`). There is no
single type the whole expression could have, so the compiler
rejects it. To fix: decide whether `label` should return `string`
(replace `0` with `"non-positive"`) or `int` (replace `"positive"`
with `1`).
:::

:::slide

## Activity discussion

Branches don't share a type:

- Then: `"positive"` is `string`.
- Else: `0` is `int`.

Rule: both branches need a single type `T`. Compiler reports:

```
Error: This expression has type int but an expression was expected
       of type string
```

To fix: decide on `string` or `int`.

:::

## What's next

Module 2 ends with the [tutorial](M02-L06-tutorial.html) (M02-L06),
where we work through several small problems end to end, combining
literals, `let`, types, operators, and `if`. After that,
[Module 3](M03-L01-functions-as-values.html) starts on functions in
depth: [anonymous functions](M03-L01-functions-as-values.html#anonymous-functions-in-expressions),
[recursion](M03-L02-recursion.html),
[currying](M03-L03-currying.html),
[partial application](M03-L03-currying.html#partial-application-the-payoff),
[tail recursion](M03-L04-tail-recursion.html). The constructs
introduced in Module 3 are the workhorses of every OCaml program
you will write.

:::slide

## What's next

- Lecture 6: **tutorial** for Module 2.
- Work through small programs end to end.
- Uses everything: literals, `let`, types, operators, `if`.

:::

## Reading

- **Cornell CS3110**, *Conditional expressions*:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
- **Real World OCaml**, *A Guided Tour* (if-expressions section):
  <https://dev.realworldocaml.org/guided-tour.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
