---
title: "GADTs: variants with type-level information"
lecture_no: 5
week: 8
duration_target_min: 24
concepts: [GADT, generalized algebraic data types, type-level information, pattern matching on GADTs]
keywords: [OCaml, GADT, type refinement, type-safe AST]
activity_question: "Write a GADT [type _ expr] with [Int_lit : int -> int expr], [Bool_lit : bool -> bool expr], [If : bool expr * 'a expr * 'a expr -> 'a expr]. Write an evaluator [eval : 'a expr -> 'a]. Why is [If (Int_lit 5, ..., ...)] a *type* error?"
think_about_this: "An ordinary variant says: 'each constructor produces a value of the type'. A GADT says: 'each constructor produces a value of a *specific* type that may differ from the others'. What is the cost of this extra precision?"
reading:
  - title: "Real World OCaml, GADTs"
    url: https://dev.realworldocaml.org/gadts.html
---

# GADTs: variants with type-level information

A **GADT** (generalized algebraic data type) is a variant where
each constructor's *type parameters* can differ. Where an ordinary
variant says "every `t` is one of these constructors", a GADT
says "different constructors have different type indices, and the
compiler can use that".

The result: you can write a type that lets the compiler *prove*
something about each value at compile time. Wrong combinations
become type errors, not runtime errors.

:::slide

## Ordinary variant: same parameter for all constructors

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
```

Here `'a` is the same throughout. Every constructor of `'a tree`
produces a value of type `'a tree`. The compiler doesn't
distinguish "tree of int" from "tree of string" except by the `'a`.

:::

:::slide

## GADT: constructors with specific indices

```ocaml
type _ expr =
  | Int_lit  : int  -> int expr
  | Bool_lit : bool -> bool expr
  | Add      : int expr * int expr -> int expr
  | If       : bool expr * 'a expr * 'a expr -> 'a expr
```

Reading the constructors:

- `Int_lit : int -> int expr`: takes an `int`, produces an `int
  expr`.
- `Bool_lit : bool -> bool expr`: takes a `bool`, produces a `bool
  expr`.
- `Add : int expr * int expr -> int expr`: takes two `int expr`s,
  produces an `int expr`. Can't add `bool expr`s.
- `If : bool expr * 'a expr * 'a expr -> 'a expr`: condition must
  be `bool expr`; the two branches must have the *same* `'a`.

The `_` in `type _ expr` is a placeholder for the type index. Each
constructor decides what fills it in.

:::

:::slide

## What we get: type-safe construction

```ocaml
type _ expr =
  | Int_lit  : int  -> int expr
  | Bool_lit : bool -> bool expr
  | Add      : int expr * int expr -> int expr
  | If       : bool expr * 'a expr * 'a expr -> 'a expr

let e1 : int expr = Add (Int_lit 1, Int_lit 2)
let e2 : int expr = If (Bool_lit true, Int_lit 5, Int_lit 10)
```

Both compile. `Add` expects `int expr`s; we give it `Int_lit`
constructors which are `int expr`. `If` expects matching branches;
both `Int_lit 5` and `Int_lit 10` are `int expr`.

Now try:

```
let bad = Add (Int_lit 1, Bool_lit true)  (* type error *)
let bad = If (Int_lit 5, Int_lit 1, Int_lit 2)  (* type error *)
```

OCaml refuses to compile these. `Add` requires both arguments to
be `int expr`; `Bool_lit true` is `bool expr`. `If` requires its
condition to be `bool expr`; `Int_lit 5` is `int expr`.

What would be a runtime "type error: expected boolean" in a
dynamically-typed AST becomes a *compile-time* error here.

:::

:::slide

## Pattern matching: type refinement

```ocaml
type _ expr =
  | Int_lit  : int  -> int expr
  | Bool_lit : bool -> bool expr
  | Add      : int expr * int expr -> int expr
  | If       : bool expr * 'a expr * 'a expr -> 'a expr

let rec eval : type a. a expr -> a = function
  | Int_lit  n -> n
  | Bool_lit b -> b
  | Add (a, b) -> eval a + eval b
  | If (c, t, e) -> if eval c then eval t else eval e

let _ = eval (Add (Int_lit 3, Int_lit 4))
let _ = eval (If (Bool_lit true, Int_lit 5, Int_lit 10))
```

`7`, `5`.

Two new things:

- `let rec eval : type a. a expr -> a = ...` is OCaml's "locally
  abstract type" annotation. We promise the compiler "this works
  for *any* `a`, and the function's return type is exactly `a`".
- Inside each case, the type `a` is *refined* based on which
  constructor matched. `Int_lit n -> n` returns `n : int`; the
  type rule of `Int_lit` says the result type is `int expr`, so
  `a = int` in this case, and `n : int` is consistent.

The compiler is doing real type-level work here. Each case's
right-hand side is checked under the type-refinement implied by
the constructor that matched.

:::

:::slide

## Why is this useful?

Three reasons:

- **Make illegal states unrepresentable.** You can't construct an
  AST that would crash an interpreter (`Add` of a string, `If` on
  an int). The type system rejects it.
- **Compose typed DSLs.** A small embedded language gets its
  type-checking for free from the host's type checker.
- **Carry compile-time metadata.** Phantom types can encode
  "list known non-empty" or "string known to be valid UTF-8" or
  "value known to be positive".

The cost: the type-level reasoning is more involved. Some patterns
that "obviously" work need help (the `type a. ...` annotation, or
explicit constraints).

:::

:::slide

## A simpler use: phantom types

You don't always need a fancy GADT. Sometimes just a *phantom*
type parameter is enough:

```ocaml
type 'a id = string
let new_user_id (s : string) : [`User] id = s
let new_order_id (s : string) : [`Order] id = s

let greet (u : [`User] id) = "hello, " ^ u
```

The `'a` in `'a id` doesn't appear in the implementation (it's
secretly always a string). But the compiler uses it to keep
`[`User] id` and `[`Order] id` distinct. Trying to greet an
order id would be a type error.

```ocaml skip
let order = new_order_id "ord-42"
let _ = greet order  (* error: [`Order] id is not [`User] id *)
```

This is a *poor person's* GADT: similar safety, simpler machinery.

:::

:::slide

## When to reach for GADTs

Use a GADT when:

- You're building an embedded language with multiple value types.
- You want some construction to be a compile-time error rather
  than a runtime one.
- You need polymorphic recursion that ordinary variants can't
  express.

Avoid them when:

- A regular variant + `option`/`result` is enough.
- The complexity exceeds the safety gain (real engineering trade).

GADTs are powerful but they're a more advanced tool. Most real
OCaml code does not use them; the code that does (interpreters,
some library cores) uses them heavily.

:::

:::slide

## Activity

Define a GADT `_ expr` with `Int_lit`, `Bool_lit`, and `If`. Write
`eval : 'a expr -> 'a`. Try to construct
`If (Int_lit 5, Int_lit 1, Int_lit 2)`. Note the compile error.

:::

:::slide

## Activity solution

```ocaml
type _ expr =
  | Int_lit  : int  -> int expr
  | Bool_lit : bool -> bool expr
  | If       : bool expr * 'a expr * 'a expr -> 'a expr

let rec eval : type a. a expr -> a = function
  | Int_lit  n -> n
  | Bool_lit b -> b
  | If (c, t, e) -> if eval c then eval t else eval e

let _ = eval (If (Bool_lit true, Int_lit 5, Int_lit 10))
let _ = eval (If (Bool_lit false, Bool_lit true, Bool_lit false))
```

`5`, `false`. Try

```ocaml skip
let bad = If (Int_lit 5, Int_lit 1, Int_lit 2)
```

OCaml refuses:

```
Error: This expression has type int expr but an expression was
       expected of type bool expr
```

The compiler enforces that the `If`'s condition is `bool expr`. An
`Int_lit` constructor doesn't fit.

:::

:::slide

## What's next

Lecture 6: **GADT use cases**. Less-trivial examples: heterogeneous
lists, type witnesses (`Type.Equal`), printf-style format types.
Then Lecture 7, the Module 8 tutorial.

:::

## Reading

- **Real World OCaml**, *GADTs*:
  <https://dev.realworldocaml.org/gadts.html>
