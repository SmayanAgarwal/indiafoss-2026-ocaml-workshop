---
title: "Tutorial: a tiny well-typed evaluator"
lecture_no: 7
week: 8
duration_target_min: 28
concepts: [GADT-driven AST, type-safe evaluator, optional + result monad in evaluation]
keywords: [OCaml, GADT, evaluator, AST, tutorial, capstone]
activity_question: "Add a [Less : int expr * int expr -> bool expr] constructor. Update [eval]. What does the type system require, and what would change if the new constructor were [Less : 'a expr * 'a expr -> bool expr] (using parametric 'a)?"
think_about_this: "The evaluator we build cannot construct an ill-typed program. The cost: more setup. The benefit: the runtime *cannot* fail with a type error. Is that the right trade for a calculator? For a real compiler? For your own domain code?"
reading:
  - title: "Real World OCaml, Building a typed AST"
    url: https://dev.realworldocaml.org/gadts.html
---

# Tutorial for Module 8

The capstone for the OCaml half of the course. We build a tiny
expression language using a GADT, write its evaluator, and show
that ill-typed programs can't even be constructed.

:::slide

## The typed AST

```ocaml
type _ expr =
  | Int_lit  : int -> int expr
  | Bool_lit : bool -> bool expr
  | Add      : int expr * int expr -> int expr
  | Mul      : int expr * int expr -> int expr
  | If       : bool expr * 'a expr * 'a expr -> 'a expr
  | Eq_int   : int expr * int expr -> bool expr
```

Six constructors. Notice:

- `Int_lit` produces `int expr`; `Bool_lit` produces `bool expr`.
- `Add`, `Mul`, `Eq_int` operate on `int expr`s only; their
  result types differ (`int expr` for arithmetic, `bool expr` for
  comparison).
- `If` is polymorphic in its return type but requires the
  condition to be `bool expr` and the branches to have the same
  `'a expr`.

The compiler can already enforce a lot about what you build with
this.

:::

:::slide

## The evaluator

```ocaml
type _ expr =
  | Int_lit  : int -> int expr
  | Bool_lit : bool -> bool expr
  | Add      : int expr * int expr -> int expr
  | Mul      : int expr * int expr -> int expr
  | If       : bool expr * 'a expr * 'a expr -> 'a expr
  | Eq_int   : int expr * int expr -> bool expr

let rec eval : type a. a expr -> a = function
  | Int_lit  n  -> n
  | Bool_lit b  -> b
  | Add (a, b)  -> eval a + eval b
  | Mul (a, b)  -> eval a * eval b
  | Eq_int (a, b) -> eval a = eval b
  | If (c, t, e) -> if eval c then eval t else eval e
```

The `type a. a expr -> a` says: "for any `a`, an `a expr`
evaluates to an `a`". Each pattern refines `a`: `Int_lit n -> n`
returns an `int`, `Bool_lit b -> b` returns a `bool`, and so on.

The compiler accepts this because each clause's right-hand side
matches the constructor's index.

:::

:::slide

## Building expressions

```ocaml
type _ expr =
  | Int_lit  : int -> int expr
  | Bool_lit : bool -> bool expr
  | Add      : int expr * int expr -> int expr
  | Mul      : int expr * int expr -> int expr
  | If       : bool expr * 'a expr * 'a expr -> 'a expr
  | Eq_int   : int expr * int expr -> bool expr

let rec eval : type a. a expr -> a = function
  | Int_lit  n  -> n
  | Bool_lit b  -> b
  | Add (a, b)  -> eval a + eval b
  | Mul (a, b)  -> eval a * eval b
  | Eq_int (a, b) -> eval a = eval b
  | If (c, t, e) -> if eval c then eval t else eval e

(* (1 + 2) * 3 = 9 *)
let e1 = Mul (Add (Int_lit 1, Int_lit 2), Int_lit 3)

(* if 1 + 2 = 3 then 100 else 200 *)
let e2 =
  If (Eq_int (Add (Int_lit 1, Int_lit 2), Int_lit 3),
      Int_lit 100,
      Int_lit 200)

let _ = eval e1
let _ = eval e2
```

`9` and `100`. The evaluator returns the expected types because
the expressions are well-typed at the OCaml level.

:::

:::slide

## What can't be built

```ocaml skip
(* error: Add wants int expr, not bool expr *)
let bad = Add (Bool_lit true, Int_lit 1)

(* error: If wants bool expr condition *)
let bad = If (Int_lit 5, Int_lit 1, Int_lit 2)

(* error: If branches must have same type *)
let bad = If (Bool_lit true, Int_lit 1, Bool_lit false)
```

All three are *compile* errors. We don't need the evaluator to
catch them; the AST itself doesn't admit them.

This is the rebuilt promise of GADTs: failure modes that would
normally be evaluator bugs (or runtime checks) become type errors.

:::

:::slide

## Adding a comparison: `<`

```ocaml skip
| Less : int expr * int expr -> bool expr
```

Inputs are `int expr`, output is `bool expr`. Adding this to the
type and the evaluator:

```ocaml
type _ expr =
  | Int_lit  : int -> int expr
  | Bool_lit : bool -> bool expr
  | Add      : int expr * int expr -> int expr
  | Mul      : int expr * int expr -> int expr
  | If       : bool expr * 'a expr * 'a expr -> 'a expr
  | Eq_int   : int expr * int expr -> bool expr
  | Less     : int expr * int expr -> bool expr

let rec eval : type a. a expr -> a = function
  | Int_lit  n  -> n
  | Bool_lit b  -> b
  | Add (a, b)  -> eval a + eval b
  | Mul (a, b)  -> eval a * eval b
  | Eq_int (a, b) -> eval a = eval b
  | Less (a, b)   -> eval a < eval b
  | If (c, t, e) -> if eval c then eval t else eval e

let _ = eval (If (Less (Int_lit 3, Int_lit 5), Int_lit 1, Int_lit 0))
```

`1` (3 < 5 is true).

The compiler made us add the new case in `eval`; the exhaustiveness
warning we relied on in Module 5 still works for GADTs.

:::

:::slide

## Adding a pretty printer

```ocaml
type _ expr =
  | Int_lit  : int -> int expr
  | Bool_lit : bool -> bool expr
  | Add      : int expr * int expr -> int expr
  | Mul      : int expr * int expr -> int expr
  | If       : bool expr * 'a expr * 'a expr -> 'a expr
  | Eq_int   : int expr * int expr -> bool expr
  | Less     : int expr * int expr -> bool expr

let rec pretty : type a. a expr -> string = function
  | Int_lit n -> string_of_int n
  | Bool_lit b -> string_of_bool b
  | Add (a, b) -> "(" ^ pretty a ^ " + " ^ pretty b ^ ")"
  | Mul (a, b) -> "(" ^ pretty a ^ " * " ^ pretty b ^ ")"
  | Eq_int (a, b) -> "(" ^ pretty a ^ " = " ^ pretty b ^ ")"
  | Less (a, b)   -> "(" ^ pretty a ^ " < " ^ pretty b ^ ")"
  | If (c, t, e) ->
      "(if " ^ pretty c ^ " then " ^ pretty t ^ " else " ^ pretty e ^ ")"

let _ = pretty
  (If (Less (Int_lit 3, Int_lit 5),
       Add (Int_lit 1, Int_lit 2),
       Mul (Int_lit 4, Int_lit 5)))
```

A string like `"(if (3 < 5) then (1 + 2) else (4 * 5))"`. Note
`pretty`'s signature: `'a expr -> string`. The return is always
`string`, regardless of the expression's type index. That's a
valid signature: the result type doesn't have to depend on `a`.

:::

:::slide

## Bringing in option / result

Suppose evaluation can fail (division by zero):

```ocaml
type _ expr =
  | Int_lit : int -> int expr
  | Div     : int expr * int expr -> int expr

let ( let* ) = Option.bind

let rec eval_safe : type a. a expr -> a option = function
  | Int_lit n -> Some n
  | Div (a, b) ->
      let* x = eval_safe a in
      let* y = eval_safe b in
      if y = 0 then None
      else Some (x / y)

let _ = eval_safe (Div (Int_lit 10, Int_lit 2))
let _ = eval_safe (Div (Int_lit 10, Int_lit 0))
```

`Some 5`, `None`. We combine GADT-based AST with option-monad
sequencing. The evaluator returns `'a option`; the option monad
short-circuits on division by zero.

This is the design pattern for any non-trivial typed interpreter:
GADTs for type safety, an error monad for runtime failure.

:::

:::slide

## Activity

Add a `Less : int expr * int expr -> bool expr` constructor (we
just did it above). Then think about: what if we made it
polymorphic, `Less : 'a expr * 'a expr -> bool expr`? Why doesn't
that work for arbitrary `'a`?

:::

:::slide

## Activity discussion

A `Less : 'a expr * 'a expr -> bool expr` would type-check for
constructing values, but the evaluator would fail. In the case
`Less (a, b) -> eval a < eval b`, OCaml's `<` works for any
*concrete* type via polymorphic compare, but here `a` and `b` have
*abstract* type `'a` inside the GADT case. We don't know enough
about `'a` to compare values of that type.

There are two fixes:

- **Constraint via witness**: pass a comparator alongside, like a
  GADT for ordered types.
- **Specialize**: keep `Less : int expr * int expr -> bool expr`
  and define `Less_float` etc. for other numeric types.

The first is more elegant; the second is what we already have. The
takeaway: a GADT lets you encode constraints precisely, but you
have to encode all the constraints you'll actually need.

:::

:::slide

## You finished Module 8

After Module 8 you can:

- Recognise the "monad" shape: `return` + `bind` for sequencing
  computations of a common kind.
- Use the option and result monads with `let*` sugar.
- Use the state monad for threaded computations without mutation.
- Define and use simple GADTs to encode type-level information.
- Combine GADTs with monads in a small typed interpreter.

You've finished the **functional programming** half of the course
(Modules 1-8). The second half (Modules 9-12) turns to **secure
systems software**: runtime / GC, memory safety, unikernels,
concurrency. The toolkit you've built will be the foundation for
everything that comes.

:::

## Reading

- **Real World OCaml**, *Building a typed AST*:
  <https://dev.realworldocaml.org/gadts.html>
