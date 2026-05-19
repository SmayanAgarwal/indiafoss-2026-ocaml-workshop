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

You already know most of the operators in OCaml from school
arithmetic. This lecture lays out the full set, says which bind
tighter than which, and walks through the small set of mistakes
beginners reliably make.

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

The two-operators-per-arithmetic-operation rule is the most
distinctive thing about OCaml arithmetic, and the source of the
most beginner type errors. Get it into your fingers: `+` for ints,
`+.` for floats. The same applies to the other three.

The `mod` operator is the integer remainder. For floats there is no
`mod.` operator; you reach for the `Float.rem` function.

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
- All five are **polymorphic**: work on any type with a sensible structural compare.
  - Numbers, strings, tuples, lists, variants, records.

- `==` and `!=` are **physical** identity ("same allocation in memory").
- Almost never what you want. **Use `=` and `<>`.**

:::

The structural-vs-physical distinction matters in practice when you
have two strings or two lists that look the same. `s1 = s2` will be
`true` if they contain the same bytes, even if they live in
different memory. `s1 == s2` will be `true` only if `s1` and `s2`
are literally the same allocation, which depends on how the program
constructed them. Avoid `==`.

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

- Result: `false`.
- RHS never evaluated: no division by zero.
- Same for `true || ...`.
- Identical to C, Java, JavaScript, Python.
- Only difference: keyword `not` instead of `!`.

:::

Short-circuit evaluation matters because the right-hand side can
contain expressions that would crash, raise, or take a long time. You
rely on this pattern when guarding access:

```ocaml skip
let _ = n <> 0 && (1.0 /. float_of_int n) > 0.0
```

If `n = 0`, the second clause is never evaluated, so we never divide
by zero. If `&&` evaluated both sides unconditionally, this pattern
wouldn't work.

:::slide

## String concatenation

```ocaml
let _ = "first" ^ " " ^ "second"
```

- `^` is **right-associative**.
- `"a" ^ "b" ^ "c"` parses as `"a" ^ ("b" ^ "c")`.
- Fine for a few strings; for many, use `String.concat`:

```ocaml
let _ = String.concat ", " ["apple"; "banana"; "cherry"]
```

- `String.concat sep xs`: joins elements of `xs` with `sep` between.
- More efficient than chained `^`.

:::

:::slide

## Function application is its own "operator"

- In OCaml, **function application is just juxtaposition**. No parens.

```ocaml
let _ = succ 5
let _ = max 3 7
let _ = String.length "hello"
```

- `succ 5`: function `succ` applied to `5`.
- Parens used only when **grouping** with another operator:

```ocaml
let _ = succ (max 3 7)
```

- Without parens: parses as `(succ max) 3 7`, not what you want.

:::

The "no parentheses on function call" rule is one of the
more surprising-at-first features of OCaml. In C, Java, Python,
JavaScript, every call needs `f(x, y)`. In OCaml, `f x y` is the
syntax. The reason is that this notation makes *partial application*
(supplying some but not all arguments and getting back a function) a
natural reading; we'll see this in Module 3.

:::slide

## Operator precedence

- Standard math conventions, with additions.
- From **tightest** binding to **loosest**:

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
- Code is read more than written; explicit parens cost nothing.

:::

Notice that function application binds tighter than any infix
operator. So `succ 5 + 3` is `(succ 5) + 3 = 9`, not
`succ (5 + 3) = 9`. Both happen to give 9 in this example, but in
general the parser is treating `succ 5` as a unit first, then
applying `+`.

`mod` and `*` are at the same precedence level (and left-associative,
like `*`). So `10 mod 3 * 2` is `(10 mod 3) * 2 = 2`, not `10 mod (3 * 2)`.

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

:::slide

## Pitfall 2: implicit conversion that isn't there

```ocaml skip
let _ = "value: " ^ 5
```

```
Error: This expression has type int but an expression was expected
       of type string
```

- Python / JavaScript: `"value: " + 5` works or silently coerces.
- OCaml: convert **explicitly**.

```ocaml
let _ = "value: " ^ string_of_int 5
```

For richer formatting, use `Printf.sprintf`:

```ocaml
let _ = Printf.sprintf "value: %d" 5
```

:::

:::slide

## Pitfall 3: subtraction syntax

```ocaml skip
let _ = abs -5
```

- Looks like "absolute value of negative 5".
- **Parses as** "`abs` minus `5`": type error (`abs` is a function).
- Fix: use parens around the negative literal.

```ocaml
let _ = abs (-5)
```

- Same problem with `-.` for floats.
- When in doubt, **parenthesize**.

:::

:::slide

## Pitfall 4: comparison chains aren't a thing

```ocaml skip
let _ = 0 < x < 10
```

- Parses as `(0 < x) < 10`: compares a `bool` to an `int`. Type error.
- Spell it out with `&&`:

```ocaml skip
let _ = 0 < x && x < 10
```

- Python is a rare language where `a < b < c` does the math thing.
- OCaml (like most languages) makes you write `&&`.

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

- Answer: `true`.
- Implicit groupings: `((1 + (2 * 3)) = 7) && true`.
- Any grouping that surprises you: a candidate for **explicit parens**.

:::

:::slide

## What's next

- Lecture 5: `if`/`then`/`else` as an **expression**.
- Turns straight-line code into branching code.
- Worked example of OCaml's expression-oriented design.

:::

## Reading

- **OCaml manual**, *Expressions* (operator section):
  <https://v2.ocaml.org/manual/expr.html>
