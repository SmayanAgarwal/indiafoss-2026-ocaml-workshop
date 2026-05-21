---
title: "Operators, precedence, and common pitfalls"
lecture_no: 4
week: 2
duration_target_min: 22
concepts: [operator precedence, arithmetic operators, comparison, logical operators, common type errors]
keywords: [OCaml, operators, precedence, comparison, equality, logical operators]
activity_question: "Without parentheses, how does OCaml parse [1 + 2 * 3 = 7 && true]? What does it evaluate to?"
think_about_this: "Why does OCaml have [&&] short-circuit but not, say, a special short-circuiting form of [+]? What property of [&&] makes short-circuiting safe?"
reading:
  - title: "OCaml manual, Operators section"
    url: https://v2.ocaml.org/manual/expr.html
---

# Operators, precedence, and common pitfalls

You already know most of OCaml's operators from school arithmetic
and from previous lectures (the
[tour](M01-L03-ocaml-tour.html#integers) introduced `+`, `*`, `/`,
`mod`; the [literals lecture](M02-L01-literals.html#float-arithmetic-uses-different-operators)
contrasted `+` and `+.`). This lecture is the comprehensive
reference. It lays out the full set, says which bind tighter than
which, and walks through the small set of mistakes that beginners
reliably make in their first week. There is nothing deep here, but
a lot of it is sharp-edged: every one of the pitfalls in the second
half of the lecture has caught me out at some point.

The reason to have a dedicated lecture on operators is that OCaml
makes some unusual choices: separate arithmetic operators for `int`
and `float`, structural-not-physical equality as the default, and a
restricted notion of polymorphic comparison. These choices have good
reasons (we have argued for them throughout Module 1 and the first
half of Module 2), but they generate a predictable set of beginner
type errors. Pre-reading those errors here will save you debugging
time later.

## Arithmetic, by type

OCaml has separate arithmetic operators for `int` and `float`. The
float versions all carry a trailing dot. You have seen this before;
the full table is worth having in one place.

:::slide

## Arithmetic, by type

| Operation | `int` | `float` |
| --- | --- | --- |
| Add | `a + b` | `a +. b` |
| Subtract | `a - b` | `a -. b` |
| Multiply | `a * b` | `a *. b` |
| Divide | `a / b` (truncating) | `a /. b` |
| Remainder | `a mod b` | (`Float.rem a b`) |
| Power | (`Int.pow a b`, OCaml 5.x) | `a ** b` |
| Negate | `-a` | `-. a` |
| Absolute | `abs a` | `Float.abs a` |

- Float operators all end in `.`.
- Mixing `int` and `float`: **type error**.
- Convert with `float_of_int` or `int_of_float`.

:::

A few details worth flagging:

**Division.** `a / b` on `int` is *truncating*: it throws away the
fractional part. So `7 / 2 = 3`, not `3.5`. The companion is `a
mod b`, the integer remainder. For floats, `a /. b` is the ordinary
mathematical division, returning `float`.

**Power.** OCaml's `**` operator is float exponentiation:
`2.0 ** 10.0 = 1024.0`. There is no built-in integer power
operator in older OCaml; in OCaml 5.x there is `Int.pow`. For most
small powers, just spell out the multiplication: `let cube x = x *
x * x`.

**Negation.** Unary negation on `int` uses the same `-` symbol as
subtraction, but it sits in front of a single argument: `let x =
-5`. For floats, the unary negation is `-.` (with a trailing dot):
`let y = -. 3.14`. This is the only case where you write `-.` as a
*prefix* operator instead of an infix one.

**Absolute value.** `abs` for `int`, `Float.abs` for `float`. The
stdlib used to have `abs_float`; that name is deprecated in
favour of `Float.abs`. Either works in current OCaml.

The two-operators-per-arithmetic rule is the most distinctive
thing about OCaml arithmetic and the source of most beginner type
errors. Internalise: `+` for ints, `+.` for floats; `*` for ints,
`*.` for floats; etc. Module 2 will burn this into your fingers.

`mod` is the integer remainder. There is no `mod.` operator for
floats; if you need float remainder, use `Float.rem a b` from the
standard library.

## Comparison and equality

The six comparison operators all return `bool`.

```ocaml
let _ = 1 < 2
let _ = "apple" = "apple"
let _ = 3 <> 4
let _ = 1.5 >= 1.5
```

:::slide

## Comparison and equality

```ocaml
let _ = 1 < 2
let _ = "apple" = "apple"
let _ = 3 <> 4
let _ = 1.5 >= 1.5
```

- Orderings: `<`, `<=`, `>`, `>=`.
- `=` is **structural** equality; `<>` structural inequality.
- All five are **polymorphic**: numbers, strings, tuples, lists,
  variants, records.
- `==` and `!=` are **physical** identity. Almost never what you want.
- **Use `=` and `<>`.**

:::

The four ordering operators (`<`, `<=`, `>`, `>=`) work on
anything orderable in the usual way. Two equality operators worth
distinguishing precisely:

- `=` is *structural* equality. It compares values by their content,
  recursively. `"apple" = "apple"` is `true` if the two strings
  contain the same bytes. `[1;2;3] = [1;2;3]` is `true` if both
  lists have the same elements in the same order. Records: same
  fields, same values. This is the operator you want 99% of the
  time.
- `==` is *physical* equality. It checks whether two values refer
  to the same memory allocation. For immutable data, this is almost
  never the question you want. Two strings with the same content
  might or might not be the *same allocation* depending on details
  of how they were constructed. Stick with `=`.

The companion inequalities: `<>` is the structural inequality
(opposite of `=`); `!=` is the physical inequality (opposite of
`==`). Same advice: use `<>`, not `!=`.

A historical note. Many languages took the unfortunate path of
using `==` as everyday equality and `=` as assignment (C inherited
this from B; Java, JavaScript, Python all followed). OCaml goes
the other way: `=` is equality, and assignment uses `<-` (for
[mutable fields](M07-L02-arrays-and-mutation.html#mutable-record-fields),
which we will see in Module 7). The OCaml choice matches
mathematical notation, but takes adjusting to if you came from a
C-family language.

All five comparison operators (`<`, `<=`, `>`, `>=`, `=`) are
*polymorphic*: they have type `'a -> 'a -> bool`, where `'a` can
be any type that has a sensible structural comparison. This works
for numbers, strings, tuples, lists, records, and most variants.
What it does not work cleanly on is functions (you cannot
sensibly compare functions for equality) and infinite or cyclic
data structures (these can hang the comparison). For ordinary
data, polymorphic comparison "just works."

## Logical operators

```ocaml
let _ = true && false
let _ = true || false
let _ = not true
```

`&&`, `||`, and `not` are familiar. The two binary ones short-circuit:

```ocaml
let _ = false && (1 / 0 = 0)
```

:::slide

## Logical operators

```ocaml
let _ = true && false
let _ = true || false
let _ = not true
```

`&&` and `||` short-circuit:

```ocaml
let _ = false && (1 / 0 = 0)
```

- Result: `false`. RHS never evaluated, so no divide-by-zero.
- Same for `true || ...`.
- Identical to C / Java / JavaScript / Python.
- Quirk: keyword `not` instead of `!`.

:::

`false && X` returns `false` without evaluating `X`. `true || X`
returns `true` without evaluating `X`. These short-circuit semantics
are identical to C, Java, JavaScript, Python. The only OCaml-specific
quirk is that *negation* uses the keyword `not`, not the symbol `!`.

Why does short-circuit matter? Because the right-hand side might
crash, raise an exception, or simply take a long time, and the
left-hand side may have decided we do not need the right-hand side.
Common idiom: guarding against an invalid case before using a
value:

```ocaml
let safe_div a b = b <> 0 && a / b > 1
```

If `b = 0`, the second clause is never evaluated, so we never
divide by zero. If `&&` were strict (evaluated both sides
unconditionally), this idiom would crash on `b = 0`. The
short-circuit semantics is what makes the idiom safe.

A subtle why-question worth thinking about: why does OCaml provide
short-circuit forms of `&&` and `||` but not of, say, `+`? Two
reasons:

1. `&&` and `||` have a useful "decided early" semantics: knowing
   the value of the left operand sometimes uniquely determines the
   value of the whole expression. `false && X` is always `false`,
   so we don't need `X`. There is no analogous shortcut for `+`:
   knowing one operand doesn't determine the sum.
2. *Boolean values themselves* carry the short-circuit decision:
   `false` means "stop"; `true` means "continue." There is no analogous
   stop-decision for arithmetic.

## String concatenation

Strings concatenate with `^`, not `+`:

```ocaml
let _ = "first" ^ " " ^ "second"
```

:::slide

## String concatenation

```ocaml
let _ = "first" ^ " " ^ "second"
```

- `^` is **right-associative**.
- Fine for a few; for many, use `String.concat`:

```ocaml
let _ = String.concat ", " ["apple"; "banana"; "cherry"]
```

- `String.concat sep xs`: joins `xs` with `sep` between.
- Faster than chained `^`.

:::

`^` is right-associative: `"a" ^ "b" ^ "c"` parses as `"a" ^ ("b"
^ "c")`. This is mostly invisible (the result is the same either
way), but it matters for performance on long chains: right
association means the leftmost strings are concatenated last, so
each intermediate result keeps growing. For a few strings, fine.
For many, use `String.concat`:

```ocaml
let _ = String.concat ", " ["apple"; "banana"; "cherry"]
```

`String.concat sep xs` joins the elements of `xs` with `sep`
between them. It allocates the result string once, of exactly the
right size; it is dramatically faster than `^`-chaining when you
have dozens or hundreds of pieces.

For formatted output, `Printf.sprintf` is the standard tool:

```ocaml
let _ = Printf.sprintf "value: %d" 5
```

The format string `"%d"` is the C-style integer specifier. We
will see Printf in more depth later.

## Function application is its own "operator"

Function application in OCaml is *juxtaposition*: just write the
function next to its arguments, separated by spaces. No parentheses
or commas.

```ocaml
let _ = succ 5
let _ = max 3 7
let _ = String.length "hello"
```

:::slide

## Function application is its own "operator"

- **Function application is juxtaposition.** No parens.

```ocaml
let _ = succ 5
let _ = max 3 7
let _ = String.length "hello"
```

- Parens only for **grouping**:

```ocaml
let _ = succ (max 3 7)
```

- Without parens: parses as `(succ max) 3 7`. Wrong.

:::

Function application binds *tighter than any infix operator*, so
`succ 5 + 3` parses as `(succ 5) + 3 = 9`, not `succ (5 + 3) = 9`.
(They give the same answer here by coincidence; in general the
two parses would differ.)

When you nest calls, you need parentheses to group:

```ocaml
let _ = succ (max 3 7)
```

Without the parentheses, OCaml would parse this as
`(succ max) 3 7`: try to apply `succ` to `max` (a function), then
apply the result to `3`, then to `7`. That makes no sense (you
can't apply `succ` to a function), and the compiler complains.

The "no parentheses on function call" rule takes adjusting to if
you came from C-family languages. The reason OCaml does this is
that it makes *partial application* (supplying some but not all
arguments and getting back a function) a natural reading. We will
see [partial application](M03-L03-currying.html#partial-application-the-payoff)
in Module 3.

## Operator precedence

Here is OCaml's operator precedence, tightest at the top, loosest at
the bottom. Levels separated by horizontal lines bind tighter than
levels below.

:::slide

## Operator precedence

From **tightest** to **loosest**:

```
.       (record / module access)
function application
* / mod (and *., /.)
+ - (and +., -.)
^ @  (concat operators)
< = > <= >= <> (comparisons)
&&
||
,       (tuple)
;       (sequence)
```

- When in doubt, **parenthesize**.

:::

A few observations:

- *Function application* is one of the tightest forms. Tighter than
  any infix operator. This is unusual; in many languages, function
  call has the same precedence as parenthesisation.
- *Arithmetic* follows the school order: `*`, `/`, `mod` tighter
  than `+`, `-`. Same as everywhere.
- *Comparisons* sit below arithmetic, so `1 + 2 < 5` parses as
  `(1 + 2) < 5`, as expected.
- `&&` binds tighter than `||`, same as everywhere.
- The tuple constructor `,` binds *very* loosely, so `1, 2 + 3` is
  `(1, 5)`, not `(1, 2) + 3`.

When in doubt, just parenthesise. Explicit parentheses cost
nothing at runtime and make the parse intent crystal clear to the
reader. Code is read far more often than it is written; spend the
ten extra keystrokes.

`mod` is at the same precedence level as `*` and `/` (and is
left-associative). So `10 mod 3 * 2` is `(10 mod 3) * 2 = 2`, not
`10 mod (3 * 2)`.

## Pitfall 1: `+` instead of `+.`

By far the most common type error in your first week:

```ocaml skip
let area r = 3.14159 * r * r
```

The compiler refuses with:

```
Error: This expression has type float but an expression was expected
       of type int
```

:::slide

## Pitfall 1: `+` instead of `+.`

```ocaml skip
let area r = 3.14159 * r * r
```

OCaml refuses:

```
Error: This expression has type float but an expression was expected
       of type int
```

Fix: `3.14159 *. r *. r`. The operator drives the type.

:::

The fix is `3.14159 *. r *. r` (note the three dots). The error
message is helpful once you can read it: it says "expected `int`"
because `*` is the integer-multiplication operator; it says
"found `float`" because `3.14159` is a float literal. The
mismatch tells you which operator is wrong.

## Pitfall 2: implicit conversion that isn't there

In Python and JavaScript, you can write `"value: " + 5` and the
language coerces the `int` to a string. OCaml does not:

```ocaml skip
let _ = "value: " ^ 5
```

:::slide

## Pitfall 2: implicit conversion that isn't there

```ocaml skip
let _ = "value: " ^ 5
```

```
Error: This expression has type int but an expression was expected
       of type string
```

- Python / JavaScript coerce silently. OCaml does not.

```ocaml
let _ = "value: " ^ string_of_int 5
```

Or `Printf.sprintf` for richer formatting:

```ocaml
let _ = Printf.sprintf "value: %d" 5
```

:::

`^` is string concatenation; both operands must be `string`. To
mix an `int` in, convert explicitly with `string_of_int`. For
richer formatting (decimal precision, padding, hex, scientific
notation), `Printf.sprintf` is the go-to.

The lack of implicit conversion is a feature, not a bug. Languages
that *do* coerce automatically have famously confusing edge cases
(JavaScript's `1 + "1" == "11"` but `1 - "1" == 0`; Python's
"strict but with surprises"). OCaml's "always be explicit" rule
means you read code and know exactly what conversion is happening.

## Pitfall 3: subtraction looks like unary minus

```ocaml skip
let _ = abs -5
```

Looks like "absolute value of negative 5." Actually parses as "abs
minus 5":

:::slide

## Pitfall 3: subtraction syntax

```ocaml skip
let _ = abs -5
```

- Looks like "absolute value of negative 5".
- **Parses as** `abs - 5`: type error.
- Fix: parenthesize the negative.

```ocaml
let _ = abs (-5)
```

- Same trap with `-.` for floats.

:::

`abs -5` is parsed as `abs - 5`: take the function `abs`, subtract
`5` from it. That doesn't type-check (you cannot subtract from a
function), so you get an error. The fix is to parenthesise the
negative literal: `abs (-5)`. Same with floats: `Float.abs (-. 3.14)`.

This catches everyone at least once. When you have a unary minus
in argument position, parenthesise it.

## Pitfall 4: comparison chains are not a thing

In Python, `0 < x < 10` reads as you'd hope: "x is between 0 and
10." Python is unusual in supporting this; OCaml (like most
languages) does not:

```ocaml skip
let _ = 0 < x < 10
```

:::slide

## Pitfall 4: comparison chains aren't a thing

```ocaml skip
let _ = 0 < x < 10
```

- Parses as `(0 < x) < 10`: `bool` vs `int`. Type error.
- Spell it out with `&&`:

```ocaml skip
let _ = 0 < x && x < 10
```

- Python supports chains; OCaml (like most languages) does not.

:::

OCaml parses this as `(0 < x) < 10`: first compare `0 < x` (which
gives `bool`), then compare that `bool` to `10`. Comparing a `bool`
to an `int` is a type error. The fix is to write the bounded check
with `&&`:

```ocaml skip
let x = 5 in 0 < x && x < 10
```

This idiom (`a < x && x < b`) is so common that you internalise it
quickly.

## A quick check

:::quiz mcq id=M02-L04-q2
What is the value of this OCaml expression?

```ocaml
let _ = 1 + 2 * 3 = 7 && true
```

- [ ] `false`
- [x] `true`
- [ ] A type error: `int` compared to `bool`.
- [ ] `7`

**Why:** apply precedence. `*` binds tighter than `+`, so `2 * 3 =
6`. Then `+`: `1 + 6 = 7`. Then `=`: `7 = 7` is `true`. Then `&&`:
`true && true` is `true`. Reading the implicit parentheses: `(((1
+ (2 * 3)) = 7) && true)`. The expression has type `bool` and
value `true`.
:::

:::slide

## Activity

How does OCaml parse:

```ocaml
let _ = 1 + 2 * 3 = 7 && true
```

What does it evaluate to? Trace through.

:::

:::slide

## Activity discussion

Parse with precedence:

- `*` tighter than `+`: do `2 * 3` first.
- Then `+`: `1 + 6 = 7`.
- Then `=`: `7 = 7` is `true`.
- Then `&&`: `true && true` is `true`.

Answer: `true`. Implicit: `((1 + (2 * 3)) = 7) && true`.

Any grouping that surprises you: candidate for **explicit parens**.

:::

A code challenge to close out:

:::quiz code id=M02-L04-q1
Write `clamp : int -> int -> int -> int` that takes a value and a
range `[lo, hi]` and clamps the value to the range: if `x` is
below `lo`, return `lo`; if above `hi`, return `hi`; otherwise
return `x`. Argument order: `clamp lo hi x`.

```ocaml
let clamp lo hi x =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (clamp 0 10 5    = 5)  "in range";
  check (clamp 0 10 (-3) = 0)  "below range";
  check (clamp 0 10 20   = 10) "above range";
  check (clamp 0 10 0    = 0)  "at lower bound";
  check (clamp 0 10 10   = 10) "at upper bound";
  print_endline "all tests passed"
```
:::

One sample solution: `if x < lo then lo else if x > hi then hi
else x`. We will see `if`-expressions in detail in the
[next lecture](M02-L05-if-expressions.html).

## What's next

[Next lecture](M02-L05-if-expressions.html): `if`/`then`/`else` as
an expression. The big conceptual shift is that `if` returns a
value in OCaml: it is not a statement that controls execution
flow, but an expression that evaluates to one of two values. The
downstream consequence is that you can use `if` anywhere an
expression can go: as a function argument, as the right-hand side
of a `let`, inside another `if`.

:::slide

## What's next

- Lecture 5: `if`/`then`/`else` as an **expression**.
- Turns straight-line code into branching code.
- Worked example of OCaml's expression-oriented design.

:::

## Reading

- **OCaml manual**, *Expressions* (operator section): the
  authoritative precedence table:
  <https://v2.ocaml.org/manual/expr.html>
- **Cornell CS3110**, *Operators*: a friendlier walk-through:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
