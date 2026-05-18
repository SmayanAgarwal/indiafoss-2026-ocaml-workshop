---
title: "Tutorial: walking an arithmetic expression AST"
lecture_no: 6
week: 5
duration_target_min: 28
concepts: [worked AST walk, structural recursion, multi-purpose pattern matching]
keywords: [OCaml, AST, expression, evaluator, pretty printer, pattern matching tutorial]
activity_question: "Extend the [expr] type with a [Var of string] constructor and a unary [Neg of expr]. Update [eval] (Var requires an environment) and [pretty]. Where does the compiler help?"
think_about_this: "An AST walker pattern-matches on every constructor every time. What is the cost of that, and what is the cost of the alternative?"
reading:
  - title: "Cornell CS3110, Walking an AST"
    url: https://cs3110.github.io/textbook/chapters/data/pattern_matching.html
---

# Tutorial for Module 5

We build a tiny arithmetic expression language and implement four
functions over it: evaluator, pretty printer, depth, and constant
folder. Each one is a pattern match on the same algebraic data
type. By the end you will have seen the workhorse pattern of
Module 5.

:::slide

## The type

```ocaml
type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let example =
  Mul (Add (Num 1.0, Num 2.0),
       Sub (Num 4.0, Num 0.5))
```

`(1 + 2) * (4 - 0.5) = 3 * 3.5 = 10.5`, by hand.

:::

:::slide

## Function 1: eval

```ocaml
type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec eval = function
  | Num n -> n
  | Add (a, b) -> eval a +. eval b
  | Sub (a, b) -> eval a -. eval b
  | Mul (a, b) -> eval a *. eval b
  | Div (a, b) -> eval a /. eval b

let example =
  Mul (Add (Num 1.0, Num 2.0),
       Sub (Num 4.0, Num 0.5))

let _ = eval example
```

`float = 10.5`. One clause per constructor. The recursive cases
delegate to `eval` on their sub-expressions and combine with the
arithmetic operator.

:::

:::slide

## Function 2: pretty printer

```ocaml
type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec pretty = function
  | Num n -> string_of_float n
  | Add (a, b) -> "(" ^ pretty a ^ " + " ^ pretty b ^ ")"
  | Sub (a, b) -> "(" ^ pretty a ^ " - " ^ pretty b ^ ")"
  | Mul (a, b) -> "(" ^ pretty a ^ " * " ^ pretty b ^ ")"
  | Div (a, b) -> "(" ^ pretty a ^ " / " ^ pretty b ^ ")"

let example =
  Mul (Add (Num 1.0, Num 2.0),
       Sub (Num 4.0, Num 0.5))

let _ = pretty example
```

A string like `"((1. + 2.) * (4. - 0.5))"`. Same shape as `eval`:
one clause per constructor; recursive cases call `pretty` on
sub-expressions.

A real pretty printer would suppress unnecessary parens based on
precedence; we keep them all for simplicity.

:::

:::slide

## Function 3: depth

The maximum nesting depth of the expression.

```ocaml
type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec depth = function
  | Num _ -> 0
  | Add (a, b) | Sub (a, b) | Mul (a, b) | Div (a, b) ->
      1 + max (depth a) (depth b)

let example =
  Mul (Add (Num 1.0, Num 2.0),
       Sub (Num 4.0, Num 0.5))

let _ = depth example
```

`int = 2`. The four binary operators all do the same thing
(recursively look at both sides), so we use an **or-pattern** to
share their clause. Same right-hand side, four constructors.

:::

The or-pattern here is doing real work: it lets us avoid four
near-identical clauses. The compiler is fine with this: it knows
that whichever constructor matched, both `a` and `b` are `expr`,
so the right-hand side type-checks.

:::slide

## Function 4: constant folding

Simplify expressions where both operands are known numbers.

```ocaml
type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec fold = function
  | Num n -> Num n
  | Add (a, b) ->
      (match fold a, fold b with
       | Num x, Num y -> Num (x +. y)
       | a', b' -> Add (a', b'))
  | Sub (a, b) ->
      (match fold a, fold b with
       | Num x, Num y -> Num (x -. y)
       | a', b' -> Sub (a', b'))
  | Mul (a, b) ->
      (match fold a, fold b with
       | Num x, Num y -> Num (x *. y)
       | a', b' -> Mul (a', b'))
  | Div (a, b) ->
      (match fold a, fold b with
       | Num x, Num y -> Num (x /. y)
       | a', b' -> Div (a', b'))

let example =
  Mul (Add (Num 1.0, Num 2.0),
       Sub (Num 4.0, Num 0.5))

let _ = fold example
```

`expr = Num 10.5`. The whole expression was constant, so folding
reduces it to a single `Num`. For an expression with variables (we
don't have those yet), it would partially fold what it could and
leave the rest as a tree.

:::

The inner `match fold a, fold b with` is a *nested pattern match*
on the tuple of two recursively folded values. If both reduced to
`Num`, combine; otherwise rebuild the original constructor with the
folded subtrees. This is the everyday shape of compiler-style
passes.

:::slide

## Notice the pattern (the meta-pattern)

Every function on `expr` has the same skeleton:

```
let rec f = function
  | Num n -> <answer for a leaf>
  | Add (a, b) -> <combine f a and f b>
  | Sub (a, b) -> <combine f a and f b>
  | Mul (a, b) -> <combine f a and f b>
  | Div (a, b) -> <combine f a and f b>
```

This is **structural recursion** on the type. Once you have it,
every walk over `expr` follows the same template. The differences
are in the right-hand sides.

In Module 6 we'll see **folds**, which extract this template into
a generic function: "walk an expr, given a leaf-handler and a
binary-op-handler". You'll write one fold for `expr` and use it for
`eval`, `pretty`, `depth`, `fold`, and anything else you want over
`expr`.

:::

:::slide

## Activity

Extend `expr` with:

- `Var of string` (variables, like `"x"`, `"y"`).
- `Neg of expr` (unary minus).

Update `pretty` to print these (variables as their name, `Neg e`
as `"-" ^ pretty e`). What does the compiler tell you about
`eval`, `depth`, and `fold`?

:::

:::slide

## Activity discussion

After adding the constructors:

```ocaml skip
type expr =
  | Num of float
  | Var of string
  | Neg of expr
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
```

The compiler warns *every match on `expr`*: `eval`, `pretty`,
`depth`, `fold`. Each one needs new clauses for `Var` and `Neg`.

- `pretty` is straightforward: stringify the variable name; prefix
  the result of recursing on `e` with `-`.
- `depth` is easy: `Var _ -> 0`, `Neg e -> 1 + depth e`.
- `fold` is straightforward for `Neg`: if the inside is `Num x`,
  return `Num (-. x)`; else keep as `Neg`.
- `eval` is suddenly **a different shape**: with variables, `eval`
  needs an environment (a mapping from name to value) to look up
  the value of `Var "x"`. The signature changes from `expr -> float`
  to `(string -> float) -> expr -> float` (or
  `(string * float) list -> expr -> float`).

This is the compiler doing the work *for you*: it pointed at every
place that needs attention, and even surfaced a deeper change
(eval's signature must grow). You only need to make the design
calls; the punch list comes from the compiler.

:::

:::slide

## What you should be able to do now

After Module 5 you can:

- Use literal, variable, wildcard, nested, and or-patterns.
- Match on records (with `_` for ignored fields), variants, and
  combinations.
- Use `when`-guards for arithmetic predicates on bound names.
- Read the compiler's exhaustiveness warnings and fix the missing
  cases.
- Walk recursive ADTs by pattern matching on the constructors.

Module 6 picks up the meta-pattern of the recursive-walk and
generalises it: **higher-order functions** (`map`, `filter`,
`fold`) that capture *the walk*, leaving you to specify only the
per-element work.

:::

## Reading

- **Cornell CS3110**, *Walking an AST*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
