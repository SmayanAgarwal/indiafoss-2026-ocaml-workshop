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

# Tutorial: walking an arithmetic expression AST


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Tutorial: walking an arithmetic expression AST</h2>
<p class="title-slide-label">Module 5 &middot; Lecture 6</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

In this tutorial we build a tiny expression language and four
functions over it: an evaluator, a pretty printer, a depth
calculator, and a constant folder. Each function is a pattern
match on the same [algebraic data type](M04-L04-recursive-types.html#modelling-arithmetic-expressions),
and each illustrates a different facet of the patterns we have
learned over the module. By the end, you will have seen the
workhorse shape of pattern matching on [recursive data](M04-L04-recursive-types.html),
the shape you will reach for every time you build a parser, a
transformer, an interpreter, a query compiler, or any other code
that walks a tree.

The choice of "arithmetic expressions" is not arbitrary. It is
the simplest interesting *algebraic data type*: leaves are
numbers, internal nodes are operators with sub-expressions.
Compilers, calculators, spreadsheet engines, query planners,
typecheckers, all generalise this same shape. Once you can
walk one tree comfortably, you can walk any of them.

We will build everything from scratch, so by the end of this
lecture you should have a small working library you could copy
into a project and extend.

:::slide

## This tutorial: a tiny expression language

- Build an algebraic data type for arithmetic expressions.
- Four functions, each a pattern match on the same type:
  - *Evaluator*: produce a number.
  - *Pretty printer*: produce a string.
  - *Depth*: how tall is the tree.
  - *Constant folder*: simplify by collapsing constants.
- This is the workhorse shape: parsers, interpreters, query
  compilers, transformers all walk trees this way.
- From scratch; by the end, a small library you could extend.

:::

## The type

```ocaml
type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
```

:::slide

## The type

```ocaml
type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
```

- Five constructors.
- `Num` carries a numeric leaf.
- The four binary operators carry two sub-expressions each.
- *Recursive*: `expr` appears in its own definition.

:::

Five constructors. `Num` is the *leaf*: a literal number. The
other four are *internal nodes*: each carries two sub-expressions
as its payload. The type is recursive: an `expr` can contain
other `expr`s. This is the definition that makes the type a
*tree*.

To exercise the type, here is a small expression that computes
`(1 + 2) * (4 - 0.5)`:

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

By hand: `(1 + 2) = 3`; `(4 - 0.5) = 3.5`; `3 * 3.5 = 10.5`. We
will use this as the running test value through the lecture.

Notice the parenthesisation. `Mul` takes a tuple of two
sub-expressions. The first is `Add (Num 1.0, Num 2.0)`; the
second is `Sub (Num 4.0, Num 0.5)`. We could break it into
multiple `let` bindings, but a single nested expression is
fine for a small example.

## Function 1: eval

The first function is an *evaluator*: given an `expr`, return
the `float` value it computes to.

```ocaml
type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec eval = function
  | Num n      -> n
  | Add (a, b) -> eval a +. eval b
  | Sub (a, b) -> eval a -. eval b
  | Mul (a, b) -> eval a *. eval b
  | Div (a, b) -> eval a /. eval b

let example =
  Mul (Add (Num 1.0, Num 2.0),
       Sub (Num 4.0, Num 0.5))

let _ = eval example
```

:::slide

## Function 1: `eval`

```ocaml
let rec eval = function
  | Num n      -> n
  | Add (a, b) -> eval a +. eval b
  | Sub (a, b) -> eval a -. eval b
  | Mul (a, b) -> eval a *. eval b
  | Div (a, b) -> eval a /. eval b
```

`float = 10.5` on the example.

- One clause per constructor.
- Leaf case: return the literal.
- Recursive case: evaluate sub-expressions and combine with the operator.

:::

The function is recursive (`let rec`) because the type is
recursive: to evaluate an `Add`, we need to evaluate its sub-
expressions, which are themselves `expr`s.

Five clauses, one per constructor. The shape is:

- **Leaf case** (`Num n`): return the carried number.
- **Recursive cases** (`Add`, `Sub`, `Mul`, `Div`): recursively
  evaluate the two sub-expressions, then combine them with the
  appropriate operator.

Crucially, OCaml's [exhaustiveness check](M05-L04-exhaustiveness.html)
guarantees we handled every constructor: the match has no warning.
If we had forgotten `Div`, the compiler would warn ("not exhaustive;
here is an example that is not matched: `Div (...)`"). The check is
doing real work even in a tutorial.

This is [*structural recursion*](M04-L04-recursive-types.html#structural-induction):
each recursive call is on a *strictly smaller* sub-expression, so
the function is guaranteed to terminate. The base case (`Num n`)
does not recurse. Every other case recurses on a sub-expression,
which has one fewer constructor than the parent.

`eval example` returns `10.5`, matching our hand calculation.

## Function 2: pretty printer

The pretty printer turns an `expr` back into a string that
represents it. We will not be clever about parentheses; we
will simply parenthesise every binary application:

```ocaml
type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec pretty = function
  | Num n      -> string_of_float n
  | Add (a, b) -> "(" ^ pretty a ^ " + " ^ pretty b ^ ")"
  | Sub (a, b) -> "(" ^ pretty a ^ " - " ^ pretty b ^ ")"
  | Mul (a, b) -> "(" ^ pretty a ^ " * " ^ pretty b ^ ")"
  | Div (a, b) -> "(" ^ pretty a ^ " / " ^ pretty b ^ ")"

let example =
  Mul (Add (Num 1.0, Num 2.0),
       Sub (Num 4.0, Num 0.5))

let _ = pretty example
```

:::slide

## Function 2: `pretty`

```ocaml
let rec pretty = function
  | Num n      -> string_of_float n
  | Add (a, b) -> "(" ^ pretty a ^ " + " ^ pretty b ^ ")"
  | Sub (a, b) -> "(" ^ pretty a ^ " - " ^ pretty b ^ ")"
  | Mul (a, b) -> "(" ^ pretty a ^ " * " ^ pretty b ^ ")"
  | Div (a, b) -> "(" ^ pretty a ^ " / " ^ pretty b ^ ")"
```

On the example: `"((1. + 2.) * (4. - 0.5))"`.

- Same shape as `eval`: one clause per constructor.
- Recursive calls on sub-expressions; combine with operator string.
- Real pretty-printer would suppress unnecessary parens by tracking precedence; we keep them for simplicity.

:::

The shape of `pretty` is *exactly* the same as the shape of
`eval`. One clause per constructor. Leaf returns a string. Each
recursive case recurses on the sub-expressions and combines the
results. The only thing that changes is the *combination
operator*: `+.`/`-.`/`*.`/`/.` in `eval`, string concatenation
with a printed symbol in `pretty`.

This already starts to look like a *template*: walk the
expression, do something at the leaf, combine recursive results
at each node. [Module 6](M06-L01-functions-revisited.html) will
give us the tool ([`fold`](M06-L04-fold.html#beyond-lists-fold-any-structure))
for capturing this template generically, so we can write just the
"do something" parts and let the walker be supplied. For now we
write out the template by hand each time.

A real pretty printer would track operator precedence and
suppress unnecessary parens: `1 + 2 + 3` instead of `(1 + (2 +
3))`. That is an exercise in conditional parenthesisation that
does not add anything to our understanding of pattern matching,
so we skip it.

## Function 3: depth, with an or-pattern

The depth of an expression is the maximum nesting level. A leaf
has depth 0; an internal node has depth one plus the maximum
depth of its sub-expressions.

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

:::slide

## Function 3: `depth` (with an or-pattern)

```ocaml
let rec depth = function
  | Num _ -> 0
  | Add (a, b) | Sub (a, b) | Mul (a, b) | Div (a, b) ->
      1 + max (depth a) (depth b)
```

`int = 2` on the example.

- Leaf: depth 0; payload is discarded with `_`.
- Four binary operators do the **same** computation.
- Or-pattern groups them; same right-hand side.
- The names `a` and `b` are bound in **every** alternative.

:::

`depth` introduces an or-pattern. The four binary-operator
clauses all compute the same thing: `1 + max (depth a) (depth
b)`. Instead of writing four near-identical clauses, we combine
them into one with `|`:

```text
| Add (a, b) | Sub (a, b) | Mul (a, b) | Div (a, b) ->
    1 + max (depth a) (depth b)
```

Recall from [Lecture 2](M05-L02-nested-and-or-patterns.html#the-binding-constraint-on-or-patterns):
every alternative of an or-pattern must bind the same variables at
the same types. Here, each alternative binds `a : expr` and `b :
expr`. The compiler is happy: regardless of which constructor
matched, the right-hand side has both `a` and `b` in scope as
`expr`.

The leaf case `Num _` uses a wildcard because we do not care
what number a leaf carries: every leaf has depth `0` regardless.

On the example expression, depth is 2: the outer `Mul` is depth
1 above its sub-expressions, and each sub-expression is itself
an internal node of depth 1.

## Function 4: constant folding

Constant folding is a small compiler optimisation: if both sides
of an operator reduce to numeric literals, evaluate them at
compile time and replace the whole sub-expression with the
result.

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
       | a', b'       -> Add (a', b'))
  | Sub (a, b) ->
      (match fold a, fold b with
       | Num x, Num y -> Num (x -. y)
       | a', b'       -> Sub (a', b'))
  | Mul (a, b) ->
      (match fold a, fold b with
       | Num x, Num y -> Num (x *. y)
       | a', b'       -> Mul (a', b'))
  | Div (a, b) ->
      (match fold a, fold b with
       | Num x, Num y -> Num (x /. y)
       | a', b'       -> Div (a', b'))

let example =
  Mul (Add (Num 1.0, Num 2.0),
       Sub (Num 4.0, Num 0.5))

let _ = fold example
```

:::slide

## Function 4: `fold` (constant folding)

```text
let rec fold = function
  | Num n -> Num n
  | Add (a, b) ->
      (match fold a, fold b with
       | Num x, Num y -> Num (x +. y)
       | a', b'       -> Add (a', b'))
  (* similar for Sub, Mul, Div *)
```

`expr = Num 10.5` on the example (the whole expression was constant).

- Outer match: on the original `expr`.
- Inner match: on the **pair** of folded sub-expressions.
- If both are `Num`: combine into a single `Num`.
- Otherwise: rebuild with the folded subtrees.

:::

This is the most interesting of the four functions. The shape
is:

1. Match on the original constructor.
2. For each binary operator, recursively fold the two
   sub-expressions.
3. Pattern match the *pair* of folded results: if both are
   `Num`, combine into a single `Num`; otherwise rebuild the
   original constructor with the folded subtrees.

The inner `match ... with` uses the tuple-form pattern from
[Lecture 5](M05-L05-records-variants.html#matching-a-tuple-of-values-the-diagonal-idiom):
`match fold a, fold b with | Num x, Num y -> ... | a', b' -> ...`.
This is the cleanest way to dispatch on the combination of two
values.

On our example, *every* sub-expression is constant, so the whole
thing folds to a single `Num 10.5`. On an expression that
contained variables (which we have not added yet), folding would
leave a tree with constants pre-computed and variables
preserved. This is what real compilers do for arithmetic
expressions in source code.

The structure is repetitive: four cases that differ only in the
operator. [Module 6's `fold`](M06-L04-fold.html) will let us
collapse this repetition; for now, four near-identical cases is the
price of the explicit walk.

## The meta-pattern

Take a step back. Each of the four functions has the same
skeleton:

:::slide

## The meta-pattern

Every function on `expr` has the same skeleton:

```
let rec f = function
  | Num n -> <answer for a leaf>
  | Add (a, b) -> <combine f a and f b>
  | Sub (a, b) -> <combine f a and f b>
  | Mul (a, b) -> <combine f a and f b>
  | Div (a, b) -> <combine f a and f b>
```

- This is **structural recursion** on the type.
- Every walk over `expr` follows this template.
- Differences live in the right-hand sides.
- Module 6 will extract this template into a generic **fold**.
- One generic walker; reuse for `eval`, `pretty`, `depth`, `fold`, etc.

:::

The skeleton is fixed by the *type definition*: one clause per
constructor, the base case for the leaf, recursive cases for the
internal nodes. The only thing that varies between `eval`,
`pretty`, `depth`, and `fold` is what each clause *does*.

This is the central insight: a type definition gives you a
*template* for walking values of that type. The compiler can
even check that you have filled the template completely
(exhaustiveness). And once you notice the template, you can
abstract it: write the template once, parameterise on the
per-constructor actions, and use the result a hundred times.
That is what `fold` does in Module 6.

For now, internalise the shape. When you see a recursive ADT,
your first reflex should be: one clause per constructor, base
case for the leaf, recursive cases for the rest. After Module 5,
this should be muscle memory.

## A small quiz

:::quiz mcq id=M05-L06-q3
Suppose we extend the `expr` type with a new constructor `Neg of
expr` (unary minus). What does the compiler do to `eval`,
`pretty`, `depth`, and `fold` as written above?

- [ ] Adds `Neg` automatically based on context.
- [ ] Refuses to compile any of them.
- [x] Warns each one with warning 8, showing `Neg _` as the missing case.
- [ ] Silently dispatches `Neg` to the `Num` branch.

**Why:** the four functions are exhaustive *as written*, but
adding a constructor breaks that. The compiler issues warning 8
for each match site, naming `Neg _` as the missing case. This is
exactly the refactoring-with-the-compiler pattern from
[Lecture 4](M05-L04-exhaustiveness.html#the-big-payoff-refactoring-with-the-compiler).
:::

:::quiz mcq id=M05-L06-q2
Why is the `depth` function above written with an or-pattern
across `Add`, `Sub`, `Mul`, `Div`?

- [ ] To save space.
- [x] Because all four constructors contribute the same depth (1) and the same recursion on `a` and `b`; the or-pattern shares the right-hand side.
- [ ] To force the compiler to emit a warning.
- [ ] To prevent the depth from being too large.

**Why:** the four binary operators all compute depth the same
way: one level for the node itself, plus the max of the children's
depths. The or-pattern groups them and shares the right-hand side.
Each alternative binds the same names (`a` and `b`) at the same
types, which is what the or-pattern constraint requires.
:::

A code task. Extend the type with a constant negate, and write
the new clause for `pretty`:

:::quiz code id=M05-L06-q1
Given:

```ocaml
type expr =
  | Num of float
  | Neg of expr
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
```

Write `pretty : expr -> string` that handles `Neg e` by
producing `"-(" ^ pretty e ^ ")"`. The other cases:

- `Num n` -> `string_of_float n`,
- `Add (a, b)` -> `"(" ^ pretty a ^ " + " ^ pretty b ^ ")"`,
- analogous for `Sub`, `Mul`, `Div`.

```ocaml
let rec pretty e =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (pretty (Num 3.0) = "3.") "num";
  check (pretty (Neg (Num 3.0)) = "-(3.)") "neg of num";
  check (pretty (Add (Num 1.0, Num 2.0)) = "(1. + 2.)") "add";
  check (pretty (Neg (Add (Num 1.0, Num 2.0))) = "-((1. + 2.))") "neg of add";
  print_endline "all tests passed"
```
:::

:::solution

The shape: six clauses, one per constructor, matching the
skeleton from earlier.

:::

## Activity: extend the type

:::slide

## Activity

Extend `expr` with:

- `Var of string` (variables, like `"x"`).
- `Neg of expr` (unary minus).

Update `pretty` to print these (variables as their name, `Neg e`
as `"-(" ^ pretty e ^ ")"`). What does the compiler tell you
about `eval`, `depth`, and `fold`?

:::

Try the extension before reading on. Run the build; collect the
warnings; fix each one.

:::slide

## Activity discussion: the extended type

Adding `Var of string` (variables) and `Neg of expr` (unary minus):

```text
type expr =
  | Num of float
  | Var of string
  | Neg of expr
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
```

- Compiler warns *every match on `expr`*: `eval`, `pretty`,
  `depth`, `fold`.
- Each needs new clauses for `Var` and `Neg`.

:::

:::slide

## Activity discussion: the easy three

- `pretty`: stringify the variable name; prefix `Neg`'s recursive
  result.
- `depth`: `Var _ -> 0`, `Neg e -> 1 + depth e`.
- `fold`: for `Neg`, if inside is `Num x` return `Num (-. x)`;
  else keep as `Neg (fold e)`. For `Var`, no folding (it stays).

Each clause is short; the compiler tells you which match needs
updating.

:::

:::slide

## Activity discussion: `eval` changes shape

- `eval` needs an environment to look up variables.
- Signature grows from `expr -> float` to
  `(string -> float) -> expr -> float`.
- Or `(string * float) list -> expr -> float`.

Takeaway:

- Compiler points at every place needing attention.
- It surfaces *deeper* changes (`eval`'s signature must grow).
- You make design calls; the punch list comes from the compiler.

:::

Three observations from the activity, in increasing depth:

**The compiler does the bookkeeping.** Add two constructors, the
compiler tells you exactly where each of the four functions is
incomplete. You do not grep, you do not hope; you read the
warnings and fix each one.

**Some clauses are obvious.** For `depth`, a variable has depth
`0`, a `Neg` has depth one above its child. For `pretty`, a
variable prints as its name, a `Neg` prefixes the recursive
result with `"-"`.

**Some clauses surface deeper design questions.** `eval` is
suddenly *insufficient* with its current signature. To evaluate
a `Var`, you need a value for the variable; that means `eval`
needs to take an *environment* mapping variable names to
numbers. The signature becomes `(string -> float) -> expr ->
float`, or `(string * float) list -> expr -> float`, depending
on your choice. The compiler does not tell you which to pick;
that is a design decision. But it *does* tell you to start
asking the question.

This is exactly what we mean by "refactoring with the compiler":
the mechanical work is automatic, the design work is yours, and
the compiler ensures you do not skip a site.

## What you should be able to do now

:::slide

## What you should know after Module 5

After Module 5 you can:

- Use literal, variable, wildcard, nested, and or-patterns.
- Match on records (with `_` for ignored fields), variants, and combinations.
- Use `when`-guards for predicates the pattern language cannot express.
- Read the compiler's exhaustiveness warnings and act on them.
- Walk recursive ADTs by pattern matching on the constructors.

- Module 6 picks up the recursive-walk meta-pattern and generalises it.
- **Higher-order functions** (`map`, `filter`, `fold`) capture *the walk*.
- You specify only the per-element work; the walker is reused.

:::

After Module 5, you should be able to:

- Use literal, variable, wildcard, nested, and or-patterns
  fluently.
- Match on records (with `_` for ignored fields), variants, and
  combinations.
- Add `when`-guards for predicates the pattern language cannot
  express, while keeping the match exhaustive.
- Read the compiler's exhaustiveness warnings, fix the missing
  cases, and use the warning as a refactoring aid.
- Walk recursive ADTs by pattern matching on the constructors,
  with structural recursion as the default shape.

[Module 6](M06-L01-functions-revisited.html) picks up where this
lecture leaves off. The "meta-pattern" of structural recursion on an
ADT is so common that the standard library provides higher-order
functions ([`map`](M06-L02-map.html), [`filter`](M06-L03-filter.html),
[`fold`](M06-L04-fold.html)) that capture the walker for you. You
write only the per-element work; the walker is reused. We will
spend Module 6 making this idea precise.

## Common pitfalls

**Pitfall 1: nested matches without parentheses.** When the
right-hand side of a clause is itself a `match`, parenthesise
the inner match (or use `begin...end`). Otherwise the inner
`|` clauses get parsed as part of the outer match. We saw this
in the body of `fold`.

**Pitfall 2: forgetting to recurse.** Easy to write `Add (a, b)
-> a +. b` instead of `Add (a, b) -> eval a +. eval b`. The
compiler will complain (`a` is `expr`, not `float`), but read
the error: you forgot the recursive call.

**Pitfall 3: making the match non-exhaustive by accident.** Add
`Neg` to the type, forget to update `eval`, and you may not
notice until runtime: `Match_failure`. The compiler warning is
your defence. Read it. Promote it to an error if possible.

**Pitfall 4: writing too clever a pretty printer.** Operator
precedence and associativity make a "minimal-parens" pretty
printer tricky. Start with the parenthesise-everything version;
add precedence only if you actually need it.

## Reading

- **Cornell CS3110**, *Walking an AST*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
- **Real World OCaml**, *Lists and patterns* (the trees and
  walkers section):
  <https://dev.realworldocaml.org/lists-and-patterns.html>
- John Whitington, *OCaml from the Very Beginning*, Chapter 8
  (data types and pattern matching).
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
