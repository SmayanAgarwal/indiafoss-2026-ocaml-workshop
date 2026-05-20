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

This is the tutorial video for Module 2. We will work through five
small programs that exercise everything in the module:
[literals](M02-L01-literals.html), [`let` bindings](M02-L02-let-bindings.html),
[type inference](M02-L03-types-and-inference.html),
[operators](M02-L04-operators.html), and
[`if`-expressions](M02-L05-if-expressions.html). After the worked
problems, we will dwell on the three type errors you will see most
often in your first programs, and close with an activity for you
to try.

The point of the tutorial is to *type code* and meet the type
errors when they show up. Every cell is editable. Make
deliberate mistakes; see what the compiler says; fix them. The
five-minute frustration of "why won't this compile" is the
fastest path to fluency.

## Problem 1: classify a temperature

A function that returns a label for a Celsius temperature. The
classification: below 0 is "freezing", up to 15 is "cold", up to
26 is "comfortable", anything else is "hot".

```ocaml
let temperature_label c =
  if c < 0.0 then "freezing"
  else if c < 15.0 then "cold"
  else if c < 26.0 then "comfortable"
  else "hot"

let _ = temperature_label 22.5
```

:::slide

## Problem 1: the classic temperature classifier

- Return a label for a Celsius temperature.
- Labels: "freezing", "cold", "comfortable", "hot".

```ocaml
let temperature_label c =
  if c < 0.0 then "freezing"
  else if c < 15.0 then "cold"
  else if c < 26.0 then "comfortable"
  else "hot"

let _ = temperature_label 22.5
```

- Result: `string = "comfortable"`.
- Try `30.0`, `-2.0`, `10.0`.
- Boundary: `15.0` is classified "comfortable" because `<` is **strict**.

:::

Result for `22.5`: `string = "comfortable"`. Try the boundaries:
`temperature_label 15.0` returns `"comfortable"` (because `<` is
strict; 15 is not less than 15); `temperature_label 26.0` returns
`"hot"`. The choice of `<` vs `<=` at thresholds is a judgement
call. Both are right; this version treats 15 as "comfortable" and
26 as "hot". If you would rather it be the other way (treat 15 as
"cold"), swap `<` for `<=`. The point is to be deliberate.

This is also a good example of a function that has type `float
-> string`: the operator drives inference. The comparisons are
against `float` literals (`0.0`, `15.0`, etc.), so `c` is `float`;
the branches return string literals, so the body has type
`string`; the function is `float -> string`.

## Problem 2: leap year

A year is a leap year if it is divisible by 4, *unless* divisible
by 100, *unless again* divisible by 400. So 2000 is a leap year
(divisible by 400), 1900 is not (divisible by 100 but not by 400),
2024 is (divisible by 4, not by 100), 2025 is not (not divisible
by 4).

```ocaml
let is_leap y =
  (y mod 4 = 0 && y mod 100 <> 0) || y mod 400 = 0

let _ = is_leap 2024
let _ = is_leap 2025
let _ = is_leap 1900
let _ = is_leap 2000
```

:::slide

## Problem 2: a leap year predicate

- Leap year: divisible by 4, *unless* by 100, *unless again* by 400.

```ocaml
let is_leap y =
  (y mod 4 = 0 && y mod 100 <> 0) || y mod 400 = 0

let _ = is_leap 2024
let _ = is_leap 2025
let _ = is_leap 1900
let _ = is_leap 2000
```

- Expected: `true, false, false, true`.
- Parens around the first `&&` not strictly needed (`&&` binds tighter than `||`).
- They make the rule **readable**: explicit parens beat clever precedence.

:::

Expected: `true, false, false, true`. The parentheses around the
first `&&` are not strictly needed (`&&` binds tighter than `||`,
so the parse is the same either way), but they make the rule
readable. The expression "either (divisible by 4 and not by 100)
or (divisible by 400)" reads off the code with the parens; without
them you have to mentally insert them. Explicit parens cost
nothing at runtime; spend them.

This is a useful place to notice that `mod` produces an `int`,
which we then compare with `=`. The comparisons are all
`int = int`, so they all type-check; the `&&` and `||` glue them
into one `bool`-typed expression.

## Problem 3: BMI category

BMI = mass / height². The standard categories: under 18.5 is
"underweight", 18.5 to 25 is "normal", 25 to 30 is "overweight",
30 and above is "obese". Here is a two-function solution:

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

:::slide

## Problem 3: BMI category

- BMI = `mass / height²`.
- Standard categories:
  - under 18.5: underweight
  - 18.5 to 25: normal
  - 25 to 30: overweight
  - 30 and above: obese

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

- Result: `string = "normal"`.
- `let b = bmi mass height in`: compute BMI **once**, name it, then branch.

:::

Result for `70.0 1.75`: `string = "normal"`. The pattern `let b =
bmi mass height in if b < ... else ...` is idiomatic: when you
need to inspect the same value at several thresholds, name it
once and compare repeatedly. Without the `let`, you would compute
`bmi mass height` four times in the if-chain (once for each
threshold), which is wasteful and clutters the code.

The function `bmi_category` is built by composing two smaller
functions, `bmi` and an if-chain. This is the rhythm of
functional programming: small, focused functions, combined into
larger behaviours. [Module 6](M06-L05-pipelines.html#function-composition)
will give us tools to make this composition explicit; here it is
just `let` + function call.

## Problem 4: clamp

Constrain a value to a given range. If the value is below the
lower bound, return the lower bound; if above the upper bound,
return the upper bound; otherwise return the value as-is.

```ocaml
let clamp lo hi x =
  if x < lo then lo
  else if x > hi then hi
  else x

let _ = clamp 0 10 7
let _ = clamp 0 10 (-3)
let _ = clamp 0 10 25
```

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

- Results: `7, 0, 10`.
- Type: `int -> int -> int -> int`.
- Parameter order: `lo`, `hi`, `x`.
- Result: the clamped value.

:::

Results: `7`, `0`, `10`. The function's type is `int -> int -> int
-> int`. Note the argument order: `lo`, `hi`, `x`. There is no one
right argument order; this one mirrors the conceptual reading
("clamp into the range lo..hi, the value x"). Another defensible
order is `x lo hi`; both are fine, just be consistent.

The parenthesisation `(-3)` is the unary-minus pitfall from
[M02-L04](M02-L04-operators.html#pitfall-3-subtraction-looks-like-unary-minus)
(without parens it would parse as subtraction). Worth remembering.

## Problem 5: tying it together

A small utility function for "divide safely":

```ocaml
let safe_divide a b =
  if b = 0.0 then 0.0
  else a /. b

let scaled value scale offset =
  safe_divide (value +. offset) scale

let _ = scaled 100.0 4.0 5.0
let _ = scaled 100.0 0.0 5.0
```

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

- Results: `26.25` and `0.0`.
- Second call avoids divide-by-zero via `b = 0.0` check in `safe_divide`.
- `safe_divide` **replaces** the bad case with a sentinel (`0.0`).
- A design decision, not always right.
- Sometimes you want the error visible: exception or `result` type.
- We'll come back to this in Module 4.

:::

Results: `26.25` (which is `(100 + 5) / 4`) and `0.0`. The second
call would have been a divide-by-zero in `a /. b`, but `safe_divide`
intercepts it and returns `0.0` instead.

A short aside: replacing a bad case with a "sentinel" value
(returning `0.0` for divide-by-zero) is a *design decision*, and
not always the right one. The sentinel can hide real bugs: if your
caller didn't notice that you returned `0.0`, they might
incorporate it into a subsequent computation and silently produce
nonsense. The alternatives are:

- **[Raise an exception](M07-L03-exceptions.html)** (we cover
  exceptions in Module 7) so the caller has to handle the case
  explicitly.
- **Return an [`option`](M04-L05-option-and-aliases.html#the-option-type)
  or [`result`](M04-L05-option-and-aliases.html#the-result-type)
  type** (Module 4) that encodes "this might be a valid number, or
  it might be 'no answer'". Forces the caller to check.

For a tutorial example, the sentinel is fine. In production code,
either of the two alternatives is usually better. Mention this
to set up Modules 4 and 7.

## Reading type errors

Type errors are noisy at first. The cure is *repetition*: write
some code, read the message, fix, repeat. Three errors you will
meet a lot deserve their own slides.

:::slide

## Type error 1: int / float confusion

```ocaml skip
let bad r = 3.14 * r * r
```

```
Error: This expression has type float but an expression was expected
       of type int
```

- Compiler reports on `3.14`: its type (`float`) doesn't match expected (`int`).
- "Expected" is **driven by the operator**: `*` is integer mul.
- Fix: switch to `*.`.

:::

**Type error 1**: the int/float operator mix-up. You wrote `*`
when you meant `*.`. The compiler points at the `float` literal as
the offender, says it expected an `int` (because `*` is integer
multiplication), and tells you the actual type is `float`. The
fix: change the operator to `*.`.

The trick to reading the error: *the operator drives the expected
type*. If you see "expected int", look for an `int` operator
nearby; that's where the constraint came from.

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

- `bad` was inferred as `string -> string` (because of `^`).
- Passing an `int` is rejected.
- Convert with `string_of_int`:

```ocaml skip
let _ = bad (string_of_int 5)
```

:::

**Type error 2**: missing conversion. Python and JavaScript would
silently coerce an `int` to a `string` when you `+`-concatenate
them; OCaml does not. The fix: convert explicitly with
`string_of_int`, or use `Printf.sprintf` for richer formatting.

This error often shows up not at the `^` line but at the *call
site* of a function you wrote. Inference fixed the function's
parameter to `string` (because of the `^`), so passing an `int`
fails at the caller. Read the error in context: it might be your
function that's wrong, or it might be the caller passing the
wrong thing.

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

- Both `if` branches must have the **same type**.
- Decide: `string` (rewrite else) or `int` (rewrite then).
- Either is fine; pick one.

:::

**Type error 3**: mismatched `if` branches. Then-branch is
`"positive"` (type `string`); else-branch is `0` (type `int`); the
compiler cannot give the whole expression a single type, so it
rejects it. Decide which type you want and fix the other branch.

These three errors account for most type errors in your first
week. After your tenth `+`-versus-`+.` slip, you'll start to type
the right operator without thinking; the others fall into the same
muscle-memory pattern.

## Activity

:::slide

## Activity

Write two functions:

- `signum : int -> int` returning `-1`, `0`, `1`.
- `signum_f : float -> float` returning `-1.0`, `0.0`, `1.0`.

Compare what changed between the two.

:::

Try this one yourself before reading on.

:::quiz code id=M02-L06-q2
Write `signum : int -> int` that returns `-1` for negative inputs,
`0` for zero, and `1` for positive inputs.

```ocaml
let signum x =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (signum 5    =  1) "signum 5";
  check (signum (-3) = -1) "signum -3";
  check (signum 0    =  0) "signum 0";
  check (signum 100  =  1) "signum 100";
  print_endline "all tests passed"
```
:::

:::quiz code id=M02-L06-q1
Now write the float version: `signum_f : float -> float`
returning `-1.0`, `0.0`, `1.0`.

```ocaml
let signum_f x =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (signum_f 5.0    =  1.0) "signum_f 5.0";
  check (signum_f (-3.7) = -1.0) "signum_f -3.7";
  check (signum_f 0.0    =  0.0) "signum_f 0.0";
  print_endline "all tests passed"
```
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

- Comparison literals: `0` to `0.0`.
- Returned literals: `-1, 0, 1` to `-1.0, 0.0, 1.0`.
- Type signature: `int -> int` to `float -> float`.

- **Structure is identical.**
- OCaml made you spell out the type choice; the logic is the same.

:::

Compare the two versions. The *logic* (negative? zero? positive?)
is identical. What changed is the *literals*: `0` becomes `0.0`,
`-1` becomes `-1.0`, etc. OCaml made you write out the type choice;
the algorithm itself didn't change. This is the cost of the no-implicit-conversion
rule. The benefit is that anyone reading either function knows
unambiguously what types are involved.

A small philosophical aside, since the *think about this* prompt
invites it. Could you write `signum` using arithmetic alone, no
`if`? Sure:

```ocaml
let signum_arith x =
  if x = 0 then 0 else x / abs x

let _ = signum_arith 5
let _ = signum_arith (-3)
let _ = signum_arith 0
```

This works: `x / abs x` is `1` for positive and `-1` for negative,
and we handle the `0` case separately to avoid division by zero.
It is a more compact than the three-branch `if`, but arguably
less clear: a reader has to think to convince themselves that
the formula gives the right answer. The three-branch version
*reads* like the specification.

This is a general theme: *cleverness* and *clarity* are different
virtues, and clarity usually wins. We will see this again with
recursion versus [higher-order functions](M06-L01-functions-revisited.html)
(Module 6).

## What you should be able to do now

By the end of Module 2 you should be comfortable doing the
following without checking references:

:::slide

## What you should be able to do now

After Module 2 you can:

- Write `int`, `float`, `bool`, `string` literals.
- Use `let` and `let ... in` to name values.
- Read the type the toplevel reports for any expression.
- Recognise the three common type errors and fix them.
- Write multi-branch `if`/`else if`/`else` expressions.
- Compose small functions like `bmi`, `clamp`, `signum`.

- **Next, Module 3**: functions as values.
- Currying, partial application, recursion, tail recursion.
- Once functions are first-class, real programs take shape.

:::

If any of these still feel shaky, the right move is to go back to
the relevant lecture and re-attempt the quizzes.
[Module 3](M03-L01-functions-as-values.html) will assume Module 2
is solid: we will start treating functions as values you can pass
around, store, and return from other functions. That's where OCaml
starts to feel like a genuinely different language from C or
Python, and you'll want the expression-level mechanics from Module
2 to be automatic.

## Reading

- **Cornell CS3110**, *Basics chapter*: a denser version of the
  same material if anything felt thin:
  <https://cs3110.github.io/textbook/chapters/basics/index.html>
- **Real World OCaml**, *A Guided Tour*: another angle:
  <https://dev.realworldocaml.org/guided-tour.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
