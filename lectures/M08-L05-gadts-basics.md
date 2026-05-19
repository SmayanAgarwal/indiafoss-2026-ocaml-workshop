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

This lecture switches gears entirely from the monad story. So far
in Module 8 we have been about *sequencing* computations; now we
turn to a more advanced type-system feature called *generalized
algebraic data types*, almost always abbreviated *GADTs*. They are
the second half of the OCaml toolkit needed for typed embedded
languages, and they show up in serious OCaml code whenever you
want the compiler to do more work for you.

Ordinary variants say "this value is one of a finite set of cases".
GADTs add: "and each case can have a *different* type index". The
practical consequence is that the compiler can prove things at
compile time that an ordinary variant would have to check at
runtime. Wrong combinations become type errors, not crashes.

The idea is in some ways simple. The notation is unusual. The
type theory is involved. We will keep the type theory light, focus
on a few worked examples, and revisit them in the next lecture
with more substantial use cases.

## Ordinary variant: same parameter for all constructors

To set the contrast, an ordinary parameterised variant:

:::slide

## Ordinary variant: same parameter for all constructors

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
```

- `'a` is the same for every constructor.
- Every value of `'a tree` has the same `'a`.
- The compiler does not distinguish "tree of int" from "tree of
  string" except by tracking `'a`.

:::

Here `'a tree` is uniformly indexed: every `Leaf` and every `Node`
inside an `'a tree` value uses the same `'a`. If `'a = int`, then
the `Node` values carry `int`s; if `'a = string`, they carry
strings. The constructors do not choose their own type index; they
share whatever the surrounding type says.

That is fine for most data structures. A list of `int`s, a tree
of `string`s, a record of options: in all these the parameter is
fixed by the outside. But sometimes the constructors need to
choose their own indices independently. That is the case GADTs
handle.

## The GADT form

Look at this expression-AST type:

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

- `Int_lit : int -> int expr`: takes an `int`, produces an `int expr`.
- `Bool_lit : bool -> bool expr`: takes a `bool`, produces a `bool expr`.
- `Add : int expr * int expr -> int expr`: requires two `int expr`s.
- `If : bool expr * 'a expr * 'a expr -> 'a expr`: condition is
  `bool expr`; the two branches share an `'a`.

The `_` in `type _ expr` is a placeholder; each constructor decides
what fills it in.

:::

The syntax `Constructor : args -> result_type` is unusual. Read it
as an explicit type signature for the constructor: like a function
signature, but for a data constructor. Ordinary variant constructors
implicitly have a result type of "the type being defined, with the
same parameters as the type header". GADT constructors say so
explicitly, which lets them choose *different* result types.

Concretely:

- `Int_lit n` is a value of type `int expr`. So `Int_lit 3 : int expr`.
- `Bool_lit b` is a value of type `bool expr`. So `Bool_lit true : bool expr`.
- `Add (a, b)` is a value of type `int expr`, *and* it can only be
  built if both `a` and `b` already have type `int expr`. You
  cannot pass an `int expr` and a `bool expr` to `Add`.
- `If (c, t, e)` is a value of type `'a expr` for some `'a`, with
  the constraint that the condition is `bool expr` and the two
  branches share the same `'a`. So an `If` returning `int expr`
  must have two `int expr` branches; an `If` returning `bool expr`
  must have two `bool expr` branches.

This is what we mean by "type-level information". The constructor
not only tags the data; it pins down the *type* of the value, and
the compiler uses that information at compile time.

## What we get: type-safe construction

Compare what the compiler accepts and rejects:

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

- Both compile.
- `Add` is given two `int expr`s.
- `If` has a `bool expr` condition and two `int expr` branches.

Try the broken versions:

```
let bad = Add (Int_lit 1, Bool_lit true)
let bad = If (Int_lit 5, Int_lit 1, Int_lit 2)
```

- Type errors.
- `Add` rejects `Bool_lit true`: it wants `int expr`.
- `If` rejects `Int_lit 5` as a condition: it wants `bool expr`.
- A dynamically-typed AST would raise a runtime error here.
- A GADT-typed AST raises a *compile* error.

:::

This is the slogan of GADTs: "make illegal states unrepresentable
at the type level". With ordinary variants you would have to
write an interpreter, walk the AST, and check at every node that
the children have compatible types. With a GADT, the compiler
refuses to even build a tree with incompatible children. The
runtime check vanishes.

The cost is on the construction side: every constructor application
has to be at the right index. The compiler is unforgiving about
this. If you want to write a program that builds an `int expr`,
every step of the construction has to commit to int-typed values.
You cannot have a runtime-dispatched "I will figure out later
what type this is" because the compiler wants to know now.

## Pattern matching with type refinement

The compiler's bookkeeping continues into pattern matching. When
you `match` on a GADT value, each case knows which constructor
fired, and OCaml *refines* the type index based on which one it
was.

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

`7`, `5`. Two new things:

- `let rec eval : type a. a expr -> a = ...`: a *locally abstract
  type* annotation. "For any `a`, this function takes an `a expr`
  and returns an `a`."
- Each case refines `a`: in `Int_lit n -> n`, the constructor type
  forces `a = int`, so `n : int` matches the return type.

:::

The `type a. ...` syntax is OCaml's way of saying "this function
is polymorphic in `a`, and inside the body, `a` is treated as an
abstract type". It is sometimes called a *locally abstract type*
or a *polymorphic recursion annotation*. For GADT pattern matching
to work, you almost always need it. The reason is technical: OCaml
needs to type-check each branch in a way that knows `a` might be
refined to a different concrete type per branch, and the `type a.
...` annotation gives the compiler permission to do that
refinement.

Reading the cases:

- `Int_lit n -> n`. The constructor `Int_lit : int -> int expr`
  fires. The compiler refines: in this branch, `a = int`. The
  variable `n : int`. The return type is `a`, which is now `int`.
  The expression `n` is an `int`. Type-checks.
- `Bool_lit b -> b`. Similarly, `a = bool` in this branch.
  `b : bool`. Returning `b` has type `bool`, which is `a` here.
  Type-checks.
- `Add (a, b) -> eval a + eval b`. The constructor's result is
  `int expr`, so this branch refines `a = int`. The two
  recursive calls `eval a` and `eval b` (where `a` and `b` are
  the GADT's sub-expressions) produce `int`s. Adding them gives
  an `int`, which matches the refined `a = int`. Type-checks.
- `If (c, t, e)`. The constructor preserves `'a`, so no refinement
  happens here; `a` stays whatever it was. The condition `c :
  bool expr`, so `eval c : bool`. The branches `t, e : a expr`,
  so `eval t : a` and `eval e : a`. The `if` returns an `a`.
  Type-checks.

The compiler is doing real work in every case: tracking which
constructor matched, refining the abstract type accordingly, and
type-checking the right-hand side under the refinement. This is
the central feature that distinguishes GADTs from ordinary
variants. With ordinary variants the index is fixed across
branches; with GADTs it can change.

## Why is this useful?

:::slide

## Why is this useful?

Three reasons:

- **Make illegal states unrepresentable.** Programs that would
  crash an interpreter become type errors.
- **Compose typed DSLs.** A small embedded language gets its
  type-checking for free from the host.
- **Carry compile-time metadata.** Phantom types encode "list
  known non-empty" or "value known positive".

Cost: the type-level reasoning is more involved; some patterns
need help (locally abstract types, explicit constraints).

:::

A more concrete way to think about the first benefit: when you
build a program with `Add (Bool_lit true, Int_lit 5)`, an
ordinary AST would represent the program just fine, and the
*interpreter* would eventually try to add a boolean to an integer
and raise a runtime "type error". The compiler had no way to
notice the mistake when you wrote the source. With a GADT, the
compiler refuses to compile the source: the construction itself
is ill-typed, before any evaluation runs.

For a toy interpreter that is a parlour trick. For a real
language (a [SQL query
builder](https://hackage.haskell.org/package/beam), a financial
calculation engine, an embedded scripting language), it is a
massive win: bugs that would otherwise hide in branches your tests
never exercise become impossible to write.

The cost is real too. GADTs require more annotations, more
locally-abstract-type declarations, and more thought. Pattern
matching can occasionally need explicit type assertions to help
the compiler refine correctly. The error messages, when GADT
inference fails, are harder to read than ordinary type errors.
Most OCaml code does not need GADTs and is better off without
them; the code that *does* need them needs them in a serious way.

## A simpler use: phantom types

You do not always need a fancy GADT. Sometimes a *phantom* type
parameter is enough:

:::slide

## A simpler use: phantom types

```ocaml
type 'a id = string
let new_user_id (s : string) : [`User] id = s
let new_order_id (s : string) : [`Order] id = s

let greet (u : [`User] id) = "hello, " ^ u
```

- The `'a` in `'a id` is *phantom*: it never appears in the
  implementation (always a `string` underneath).
- The compiler keeps `` [`User] id `` and `` [`Order] id `` distinct.

```ocaml skip
let order = new_order_id "ord-42"
let _ = greet order  (* error: [`Order] id is not [`User] id *)
```

A "poor person's GADT": similar safety, simpler machinery.

:::

The trick is that `'a id` is a *type alias* for `string`, but the
`'a` parameter is part of the type even though no value of type
`'a` is actually stored. The compiler tracks `'a` purely for
identity. Two strings tagged with `[`User]` and `[`Order]` are
*different types*, even though they have identical runtime
representations. The user cannot mix them up without an explicit
cast.

This trick has a name (*phantom types*) and a long history. It
predates GADTs and is far less heavy machinery; many of the same
safety wins are available with just a `type 'a t = string` plus
careful API design. Real codebases use phantom types where they
suffice and reach for GADTs only when phantom types cannot express
the relationship they want.

The polymorphic variants `` [`User] `` and `` [`Order] `` are a
related OCaml feature (Module 5 covered ordinary variants; we will
not dive into polymorphic variants in this course). The key thing
for now: they are tags that the type system tracks distinctly.

## When to reach for GADTs

:::slide

## When to reach for GADTs

Use a GADT when:

- You are building an embedded language with multiple value types.
- You want some construction to be a compile-time error.
- You need polymorphic recursion that ordinary variants cannot
  express.

Avoid them when:

- A regular variant plus `option`/`result` is enough.
- The complexity exceeds the safety gain.

GADTs are powerful but advanced. Most OCaml code does not use them;
the code that does (interpreters, query builders, library cores)
uses them heavily.

:::

A useful question to ask before reaching for a GADT: "what
specifically would go wrong if I used an ordinary variant and
runtime checks?" If the answer is "I would crash with a
type-mismatch error after running for hours", GADTs are worth it.
If the answer is "I would have to add an `option` return type
and pattern-match in two places", they are probably not.

The next lecture shows three or four real use cases that pull this
into focus: typed pretty-printers, heterogeneous lists, type-safe
builders, and the GADT machinery behind `Printf`.

## A quick check

:::quiz mcq
What is the type of `Add (Int_lit 1, Int_lit 2)`?

- [x] `int expr`
- [ ] `bool expr`
- [ ] `(int * int) expr`
- [ ] `int expr * int expr`

**Why:** the constructor's signature is `Add : int expr * int expr
-> int expr`. Given two `int expr` arguments, the result type is
`int expr`. The compiler refuses to apply `Add` to anything else.
:::

:::quiz mcq
Why does the `eval` function need the annotation `type a. a expr
-> a`?

- [ ] OCaml requires every function to be annotated.
- [x] The function is polymorphic and each branch refines `a` to a
  different concrete type; the annotation tells the compiler to
  treat `a` as abstract and allow per-branch refinement.
- [ ] It is purely cosmetic; the compiler infers it anyway.
- [ ] It optimises the compiled code.

**Why:** without the locally-abstract-type annotation, the
compiler tries to infer a single concrete type for `a` and fails
because different branches refine it differently. The `type a. ...`
annotation says "treat `a` as fresh and abstract", which is what
GADT pattern matching needs. This is a recurring quirk: GADT
functions often need this annotation explicitly.
:::

:::slide

## Activity

Define a GADT `type _ expr` with `Int_lit`, `Bool_lit`, and `If`.
Write `eval : 'a expr -> 'a`. Try to construct `If (Int_lit 5,
Int_lit 1, Int_lit 2)`. Note the compile error.

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

`5`, `false`.

Try:

```ocaml skip
let bad = If (Int_lit 5, Int_lit 1, Int_lit 2)
```

OCaml refuses:

```
Error: This expression has type int expr but an expression was
       expected of type bool expr
```

- The compiler enforces that `If`'s condition is `bool expr`.
- `Int_lit 5 : int expr` does not fit.

:::

A code quiz:

:::quiz code
Define a GADT `type _ value` with two constructors `VInt : int ->
int value` and `VBool : bool -> bool value`. Write `unwrap : type
a. a value -> a` that returns the underlying value.

```ocaml
type _ value =
  | VInt  : int -> int value
  | VBool : bool -> bool value

let unwrap : type a. a value -> a = fun _ -> failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (unwrap (VInt 42) = 42) "VInt";
  check (unwrap (VBool true) = true) "VBool true";
  check (unwrap (VBool false) = false) "VBool false";
  print_endline "all tests passed"
```
:::

Reference solution:

```
let unwrap : type a. a value -> a = function
  | VInt n -> n
  | VBool b -> b
```

The `type a. ...` annotation makes `a` locally abstract so that
each branch can refine it (`a = int` for `VInt`, `a = bool` for
`VBool`). Without the annotation, the compiler cannot find a
single concrete `a` to satisfy both branches.

## What is next

:::slide

## What is next

Lecture 6: **GADT use cases**.

- Heterogeneous lists and type witnesses.
- The format-string trick behind `Printf`.
- Less-trivial examples.

Then Lecture 7, the Module 8 tutorial: combining GADTs with the
monad pattern in a small typed evaluator.

:::

The next lecture takes the basic machinery here and shows three or
four real applications. The lecture after that is the tutorial:
combining a GADT-based typed AST with an option-monad evaluator
that can fail at runtime (division by zero, say) while still
guaranteeing type safety on the success path. That is the
capstone for the OCaml half of the course.

## Reading

- **Real World OCaml**, *GADTs*:
  <https://dev.realworldocaml.org/gadts.html>
