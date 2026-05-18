---
title: "Tutorial: small expressions, end to end"
lecture_no: 6
week: 2
duration_target_min: 28
concepts: [expression composition, reading type errors, writing small programs]
keywords: [OCaml, tutorial, expressions, type errors, beginner exercises]
activity_question: "Write [signum : int -> int] returning -1, 0, or 1 for negative, zero, positive inputs. Then write [signum_f : float -> float] doing the same for floats. What changes between the two?"
think_about_this: "If you wrote [signum] without using [if], could you do it with arithmetic alone? What would that program look like, and is it clearer?"
reading:
  - title: "Cornell CS3110, Basics chapter (revisit anything that felt thin)"
    url: https://cs3110.github.io/textbook/chapters/basics/index.html
---

# Tutorial for Module 2

This is the tutorial video. We work through five small programs that
exercise everything in Module 2. The point is to *type code* with
these tools and meet the type errors when they show up.

:::slide

## Problem 1: the classic temperature classifier

Write a function that returns a label for a Celsius temperature:
"freezing", "cold", "comfortable", or "hot".

```ocaml
let temperature_label c =
  if c < 0.0 then "freezing"
  else if c < 15.0 then "cold"
  else if c < 26.0 then "comfortable"
  else "hot"

let _ = temperature_label 22.5
```

`string = "comfortable"`.

Try `30.0`, `-2.0`, `10.0`. Notice the threshold at the boundary:
`15.0` itself is classified as "comfortable" because the `<` is
strict.

:::

The choice of `<` vs `<=` at thresholds is a judgement call. Both
are right. The function above treats 15 as "comfortable"; if you'd
rather it be "cold", swap the operator.

:::slide

## Problem 2: a leap year predicate

A year is a leap year if it is divisible by 4, *unless* it is
divisible by 100, *unless again* it is divisible by 400.

```ocaml
let is_leap y =
  (y mod 4 = 0 && y mod 100 <> 0) || y mod 400 = 0

let _ = is_leap 2024
let _ = is_leap 2025
let _ = is_leap 1900
let _ = is_leap 2000
```

Expected: `true, false, false, true`.

The parens around the first conjunction are not strictly needed
(`&&` binds tighter than `||`) but they make the rule readable.
This is a place where explicit parens beat clever precedence.

:::

:::slide

## Problem 3: BMI category

Body Mass Index is `mass / height²`. The standard categories:

- under 18.5 → underweight
- 18.5 to 25 → normal
- 25 to 30 → overweight
- 30 and above → obese

```ocaml
let bmi mass height = mass /. (height *. height)

let bmi_category mass height =
  let b = bmi mass height in
  if b < 18.5 then "underweight"
  else if b < 25.0 then "normal"
  else if b < 30.0 then "overweight"
  else "obese"

let _ = bmi_category 70.0 1.75
```

`string = "normal"`. Use `let b = bmi mass height in` to compute the
BMI once and name it `b`, then branch.

:::

The pattern `let b = ... in if b < ...` is idiomatic when you need to
inspect the same value several times. Without the `let`, you'd end up
computing `bmi mass height` four times in the if-chain. With it, once.

:::slide

## Problem 4: clamp

Constrain a number to a range:

```ocaml
let clamp lo hi x =
  if x < lo then lo
  else if x > hi then hi
  else x

let _ = clamp 0 10 7
let _ = clamp 0 10 (-3)
let _ = clamp 0 10 25
```

`7, 0, 10`. The function is `int -> int -> int -> int`. The three
parameters come in the order `lo`, `hi`, `x`; the result is the
clamped value.

:::

:::slide

## Problem 5: tying it together

```ocaml
let safe_divide a b =
  if b = 0.0 then 0.0
  else a /. b

let scaled value scale offset =
  safe_divide (value +. offset) scale

let _ = scaled 100.0 4.0 5.0
let _ = scaled 100.0 0.0 5.0
```

`26.25` and `0.0`. The second call avoids a divide-by-zero by
checking `b = 0.0` in `safe_divide`.

Notice that `safe_divide` *replaces* the bad case with a sentinel
value (`0.0`). That is a design decision, and not always the right
one; sometimes you want the error to be visible (a runtime exception
or a `result` type). We'll come back to this in Module 4.

:::

## Reading type errors

Type errors are noisy at first. The cure is repetition: write code,
read the message, fix, repeat. Three errors you'll meet a lot:

:::slide

## Type error 1: int / float confusion

```ocaml skip
let bad r = 3.14 * r * r
```

```
Error: This expression has type float but an expression was expected
       of type int
```

Read it: the compiler is reporting on `3.14`, saying its type
(`float`) doesn't match the expected type (`int`). The "expected" is
driven by the *operator*: `*` is integer multiplication, so it
expected an `int`. Fix: switch to `*.`.

:::

:::slide

## Type error 2: missing conversion

```ocaml skip
let bad x = "value: " ^ x
let _ = bad 5
```

```
Error: This expression has type int but an expression was expected
       of type string
```

The function `bad` was inferred as `string -> string` (because of
`^`), so passing an `int` is rejected. Convert with `string_of_int`:

```ocaml skip
let _ = bad (string_of_int 5)
```

:::

:::slide

## Type error 3: mismatched if branches

```ocaml skip
let bad x =
  if x > 0 then "positive"
  else 0
```

```
Error: This expression has type int but an expression was expected
       of type string
```

The two branches of an `if` must have the same type. Decide whether
you want a `string` (rewrite the else) or an `int` (rewrite the
then). Both are fine; pick one.

:::

:::slide

## Activity

Write two functions:

- `signum : int -> int` returning `-1`, `0`, `1`.
- `signum_f : float -> float` returning `-1.0`, `0.0`, `1.0`.

Compare what changed between the two.

:::

:::slide

## Activity solution

```ocaml
let signum x =
  if x < 0 then -1
  else if x > 0 then 1
  else 0
```

```ocaml
let signum_f x =
  if x < 0.0 then -1.0
  else if x > 0.0 then 1.0
  else 0.0
```

What changed:

- Comparison literals: `0` became `0.0`.
- Returned literals: `-1, 0, 1` became `-1.0, 0.0, 1.0`.
- Type signature: `int -> int` became `float -> float`.

The *structure* of the function is identical. OCaml made you spell
out the type choice, but the logic is the same.

:::

:::slide

## What you should be able to do now

After Module 2 you can:

- Write integer, float, boolean, and string literals.
- Use `let` and `let ... in` to name values.
- Read the type the toplevel reports for any expression.
- Recognise the three common type errors and know how to fix them.
- Write multi-branch `if`/`else if`/`else` expressions.
- Compose small functions like `bmi`, `clamp`, `signum`.

Module 3 turns to **functions** as values in their own right:
currying, partial application, recursion, tail recursion. Once we
have functions as first-class values, real programs start to take
shape.

:::

## Reading

- **Cornell CS3110**, *Basics chapter*:
  <https://cs3110.github.io/textbook/chapters/basics/index.html>
