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

# Tutorial for Module 8: a tiny well-typed evaluator


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Tutorial: a tiny well-typed evaluator</h2>
<p class="title-slide-label">Module 8 &middot; Lecture 7</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

This is the capstone for the OCaml half of the course. We are
going to build a small expression language that combines almost
everything we have seen in Module 8:

- A [GADT](M08-L05-gadts-basics.html) for the abstract syntax tree,
  so that ill-typed programs cannot be constructed.
- A [pattern-matching](M05-L01-basic-patterns.html) evaluator that
  uses [GADT type refinement](M08-L05-gadts-basics.html#pattern-matching-with-type-refinement)
  to return the right type for each constructor.
- An optional-failure layer, in the
  [option-monad style](M08-L02-option-monad.html), that
  short-circuits when evaluation has a runtime problem (such as
  division by zero).
- Two pretty-printers and an extension exercise (adding `<`).

The exercise serves two purposes. First, it is a useful piece of
code on its own: a typed mini-interpreter is the foundation of
many production OCaml tools (configuration languages, query
builders, embedded scripting). Second, it is a working example
that ties together [monads](M08-L01-sequencing.html),
[GADTs](M08-L05-gadts-basics.html), and
[pattern matching](M05-L01-basic-patterns.html), the three big
OCaml ideas from the back half of the functional-programming half
of the course.

By the end of this lecture you should be able to read GADT-typed
ASTs comfortably, write evaluators over them, and extend the
language with new constructors without confusion.

## The typed AST

The first design decision is the AST shape. We want six
constructors:

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
- `Add`, `Mul`, `Eq_int` consume `int expr`s only.
- `Eq_int` returns `bool expr`; `Add` and `Mul` return `int expr`.
- `If` is polymorphic in the return; branches must agree.

The compiler enforces a lot of the language semantics already.

:::

Read the type definition slowly. Each constructor has its own
signature with an explicit result type. `Int_lit : int -> int
expr` means "given an OCaml `int`, build an expression of type
`int expr`". The literal `5` becomes `Int_lit 5 : int expr` and
not `Int_lit 5 : 'a expr` for some unknown `'a`. Each constructor
pins its index.

`Add` and `Mul` require both their sub-expressions to have type
`int expr`. You cannot construct `Add (Bool_lit true, Int_lit 5)`:
the first argument's type does not match what `Add` expects. The
arithmetic operations also produce `int expr`, because the result
of adding two integers is an integer.

`Eq_int` is interesting: it takes two `int expr`s but produces a
`bool expr`. This is the constructor that changes type indices.
You compare two integers; the result is a boolean. The type
system tracks the change.

`If` is the most subtle. Its condition is `bool expr` (since you
need a boolean to branch on), and the two branches share a
parameter `'a`: whatever type the "then" branch has, the "else"
branch must have the same. The result is `'a expr` for that
shared type. So `If` between two `int expr`s produces an `int
expr`; `If` between two `bool expr`s produces a `bool expr`; `If`
between an `int expr` and a `bool expr` is a type error.

This is the design pattern for typed embedded languages: the
compiler turns the OCaml type system into a type checker for the
embedded language. We get the embedded language's type safety for
free, with the host language's machinery.

## The evaluator

Now to evaluate. The evaluator takes an `'a expr` and returns
an `'a`:

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

`type a. a expr -> a`: for any `a`, an `a expr` evaluates to `a`.

:::

:::slide

## What each branch refines

- `Int_lit n -> n`: `a = int`; return type is `int`.
- `Bool_lit b -> b`: `a = bool`; return type is `bool`.
- `Add` and `Mul`: `a = int`, returning the int result.
- `Eq_int`: `a = bool`, returning the comparison result.
- `If`: `a` unchanged; both branches evaluate to `a`.

:::

The function reads naturally for a language interpreter, but
notice the depth of compiler-tracked typing. The single function
`eval` has a type that says "I return whatever type the input
expression is indexed by", and OCaml verifies that every branch
returns the right thing.

For `Eq_int (a, b) -> eval a = eval b`: the GADT constructor's
signature is `int expr * int expr -> bool expr`. In this branch,
`a` (the locally abstract type parameter) is refined to `bool`.
The recursive calls `eval a` and `eval b` both return `int`s (the
sub-expressions have type `int expr`, so they evaluate to `int`).
The `=` between two `int`s is a `bool`. Returning that `bool`
matches the refined `a = bool`. Type-checks.

This is real type-system work. Without GADTs you cannot write
this evaluator: an ordinary variant cannot encode that `Eq_int`
returns `bool` while `Add` returns `int`. With GADTs the encoding
falls out.

## Building expressions

Let us try the evaluator on a couple of expressions:

:::slide

## Building expressions

```ocaml
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

`9` and `100`. `e1` is `(1 + 2) * 3` (int expr). `e2` is
`if 1 + 2 = 3 then 100 else 200` (int expr, equality holds).

:::

Notice how the construction reads. `Mul (Add (Int_lit 1, Int_lit
2), Int_lit 3)`: an `Add` between two int literals, then a `Mul`
between that sum and another int literal. Each piece's type is
fixed by its constructor. The compiler verifies the whole tree at
build time.

The second example uses `If` and `Eq_int`. `Eq_int (..., ...)`
produces a `bool expr`, which is what `If` needs as its first
argument. The two `Int_lit` branches make the `If` result an `int
expr`. The whole thing has type `int expr` and evaluates to `100`.

## What cannot be built

Here is where GADTs pay off. Try the obvious mistakes:

:::slide

## What cannot be built

```ocaml skip
(* error: Add wants int expr, not bool expr *)
let bad = Add (Bool_lit true, Int_lit 1)

(* error: If wants bool expr condition *)
let bad = If (Int_lit 5, Int_lit 1, Int_lit 2)

(* error: If branches must have same type *)
let bad = If (Bool_lit true, Int_lit 1, Bool_lit false)
```

- All three are *compile-time* errors.
- The evaluator does not need to catch them; the AST does not
  admit them.
- A dynamically-typed interpreter would crash on these inputs;
  here, you cannot even build the input.

:::

In an interpreter without typed ASTs, you would write the
expression, run the interpreter, and get a runtime error: "tried
to add a bool to an int, panic." In a GADT-typed interpreter, the
compiler refuses to compile the expression in the first place.
The class of bug is gone.

For a calculator that may not seem like a big deal. For a serious
embedded language with hundreds of expression nodes and many
language features, the difference is large: you can refactor the
language and trust the type checker to find every place that needs
updating, rather than relying on tests to exercise every branch
of the interpreter.

## Adding a `<` comparison

Let us extend the language with a less-than operator. The new
constructor has the same shape as `Eq_int`: it takes two `int
expr`s and produces a `bool expr`:

:::slide

## Adding a comparison: `<`

Add one constructor to `expr` and one case to `eval`:

```ocaml skip
  | Less : int expr * int expr -> bool expr
```

```ocaml skip
  | Less (a, b) -> eval a < eval b
```

```ocaml skip
let _ = eval (If (Less (Int_lit 3, Int_lit 5), Int_lit 1, Int_lit 0))
```

`1` (3 < 5 is true). Compiler forces us to add the `eval` case
via exhaustiveness; type refinement gives us `a = bool` inside
the `Less` branch.

:::

A useful detail: the
[exhaustiveness checker from Module 5](M05-L04-exhaustiveness.html)
still works for GADTs. When you add `Less` to the type and forget
to add it to `eval`, the compiler warns about a non-exhaustive
match. This is one of the things you would lose if you encoded the
AST as a polymorphic-variant-tagged dictionary (or similar dynamic
approach): the exhaustiveness check would not apply.

## Adding a pretty printer

The reverse direction: turn an expression back into a string. The
return type is always `string`, regardless of the expression's
type index:

:::slide

## Adding a pretty printer

```ocaml skip
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

`"(if (3 < 5) then (1 + 2) else (4 * 5))"`. Return type is always
`string`, regardless of `a`; consume-a-GADT/produce-a-fixed-type
is a common pattern (hashers, size estimators, printers).

:::

The signature `type a. a expr -> string` is the right one here.
The function is polymorphic in the input (any expression, of any
type), but the output is always a `string`. The `type a. ...`
annotation is needed because we are still pattern-matching on a
GADT; OCaml needs permission to refine `a` per branch. The right-
hand side of each branch happens not to use `a`, which is fine,
the output type is `string` regardless.

This is the pattern for any "consume a GADT, produce a fixed
type" function: pretty-printers, hashers, size computations,
size estimations. The GADT lets you handle every constructor with
the right local types; the result type is whatever fits your
purpose.

## Combining GADTs with the option monad

So far our `eval` cannot fail: every constructor evaluates
cleanly. Real interpreters have runtime failures (division by
zero, missing variable, stack overflow). The
[option monad (Lecture 2)](M08-L02-option-monad.html) is the
natural way to add a layer of fallibility:

:::slide

## Bringing in option / result

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

`Some 5`, `None`. GADT rules out type errors at compile time;
option monad handles the runtime "divide by zero" case.

:::

The two failure-handling mechanisms address different problems.
The GADT guarantees that you do not mix booleans and integers at
the type level: that bug class cannot exist at runtime, because
it cannot exist at compile time. The option monad handles the
genuine runtime failures: you do not know whether the divisor is
zero until you evaluate it, so you handle that case with `None`
short-circuit semantics.

For a real interpreter you would pick
[`result`](M08-L03-result-monad.html) over `option` so that the
error case carries a useful message ("divide by zero at expression
4711"). The shape of the code is identical: `let*` chains, GADT
pattern matching with `type a. ...`, runtime checks in the
constructor cases that can fail.

This is the design pattern for a serious typed interpreter:
GADTs at the type level to rule out type errors, monads at the
value level to handle runtime errors cleanly. Both pay their own
way; together they cover the full spectrum.

## The "polymorphic less-than" question

The activity for this lecture is an extension: add a `Less`
constructor and consider what would change if it were polymorphic
in its argument types rather than fixed to `int expr * int expr`.

:::slide

## Activity

Add a `Less : int expr * int expr -> bool expr` constructor (we
did this above). Then think about: what if we made it polymorphic,
`Less : 'a expr * 'a expr -> bool expr`? Why does that not work
for arbitrary `'a`?

:::

:::slide

## Activity discussion

- Polymorphic `Less : 'a expr * 'a expr -> bool expr` builds fine.
- The evaluator fails: `<` needs a concrete type.
- Inside the GADT branch, `a` and `b` have abstract type `'a`.
- The compiler cannot compile the comparison.

Two fixes:

- **Witness:** pass a comparator alongside (GADT for ordered
  types).
- **Specialise:** one constructor per numeric type (`Less`,
  `Less_float`).

A GADT encodes the constraints you actually need. Pick precisely.

:::

The deeper lesson: GADT type indices are about *what the compiler
knows*. If you parameterise too loosely (`'a expr` everywhere),
you lose the ability to write functions that need a specific type
(like `<`, which needs to know it has two integers). If you
parameterise too tightly (one constructor per OCaml type), you
have more code to write. The right balance is application-specific.
For a calculator, "tight" is fine. For a richer language, you may
need ordering witnesses or other extensions.

A code quiz to put it together:

:::quiz code id=M08-L07-q3
Add a `Neg : int expr * int expr -> int expr` constructor that
represents subtraction (despite its name; let us call it `Sub`).
Write the evaluator that handles `Int_lit`, `Add`, and `Sub`.

```ocaml
type _ expr =
  | Int_lit : int -> int expr
  | Add     : int expr * int expr -> int expr
  | Sub     : int expr * int expr -> int expr

let rec eval_arith : type a. a expr -> a = function
  | Int_lit _ -> failwith "not implemented"
  | Add _ -> failwith "not implemented"
  | Sub _ -> failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (eval_arith (Add (Int_lit 1, Int_lit 2)) = 3) "1 + 2";
  check (eval_arith (Sub (Int_lit 10, Int_lit 4)) = 6) "10 - 4";
  check (eval_arith (Sub (Add (Int_lit 1, Int_lit 2), Int_lit 1)) = 2) "1+2-1";
  check (eval_arith (Sub (Int_lit 0, Int_lit 5)) = -5) "0 - 5";
  print_endline "all tests passed"
```
:::

Reference solution:

```
let rec eval_arith : type a. a expr -> a = function
  | Int_lit n -> n
  | Add (a, b) -> eval_arith a + eval_arith b
  | Sub (a, b) -> eval_arith a - eval_arith b
```

Same pattern as the main evaluator: each case refines `a` based
on the constructor (always `a = int` here, since all three
constructors return `int expr`), and the right-hand side does the
arithmetic.

## A check

:::quiz mcq id=M08-L07-q2
We pattern-match on a GADT inside `eval`. Why is the `type a.
...` annotation usually needed?

- [ ] It is required syntax for any function in OCaml.
- [x] It tells the compiler to treat `a` as locally abstract so
  that each branch can refine it differently.
- [ ] It improves performance.
- [ ] It is only needed when the function is recursive.

**Why:** without the annotation, OCaml tries to find a single
concrete type for `a` and fails because different branches refine
`a` to different concrete types (int, bool, etc.). The `type a.
...` annotation gives the compiler permission to treat each
branch's `a` independently. This is the standard idiom for
writing functions on GADTs.
:::

:::quiz mcq id=M08-L07-q1
Why does combining GADTs with the option monad in `eval_safe`
make sense?

- [ ] The option monad replaces GADTs.
- [x] GADTs rule out compile-time type errors; the option monad
  handles genuine runtime failures (like division by zero) that
  the type system cannot prevent.
- [ ] Option is required for any GADT function.
- [ ] The two are interchangeable.

**Why:** the two address different problems. The GADT type system
prevents bugs of the form "trying to add a bool to an int" by
making them un-constructable. The option monad handles failures
that depend on runtime values (zero divisor, missing key) and
that no static type can detect. They are complementary, not
redundant.
:::

## You finished Module 8

:::slide

## You finished Module 8

After Module 8 you can:

- Recognise the "monad" shape: `return` + `bind` for sequencing.
- Use the option and result monads with `let*` sugar.
- Use the state monad for threaded computations without mutation.
- Define and use simple GADTs to encode type-level information.
- Combine GADTs with monads in a small typed interpreter.

End of the **functional programming** half (Modules 1-8); the
secure-systems half builds on this foundation.

:::

Module 8 is the most "advanced OCaml" part of the course so far.
Monads and GADTs are not in everyday OCaml code; they are in the
core of libraries, in interpreters, in serious type-safe APIs. You
do not need to use them daily, but you need to recognise them
when reading other people's code, and you need to be able to reach
for them when the problem calls for them.

The functional-programming half of the course
(Modules [1](M01-L01-course-intro.html)-8) is now complete. We
started from [primitive literals](M02-L01-literals.html) and built
up through [`let` bindings](M02-L02-let-bindings.html),
[functions](M03-L01-functions-as-values.html),
[recursion](M03-L02-recursion.html),
[pattern matching](M05-L01-basic-patterns.html),
[algebraic data types](M04-L03-variants.html),
[higher-order functions](M06-L01-functions-revisited.html),
[modules](M07-L04-module-basics.html),
[monads](M08-L01-sequencing.html), and
[GADTs](M08-L05-gadts-basics.html). Each module fed the next: refs
in M07 gave the imperative ground for the state monad in M08;
variants in M04 set up GADTs in M08; modules in M07 are the
packaging you reach for whenever you grow a real codebase.

<!-- TODO: the secure-systems half (runtime/GC, memory safety,
     unikernels with Mirage, concurrency with Eio) is planned but
     not yet authored; this paragraph will link forward once those
     modules exist. -->

What you carry forward from here is not the specific syntax of
`let*` or the exact shape of a GADT constructor, but a *taste* for
typed-first thinking: pick the data shape, then write functions on
it; lean on the compiler to find your missing cases; keep mutation
in a small corner and prefer values everywhere else. Those habits
travel: to systems code, to web back-ends, to whatever you build
next.

## Reading

- **Real World OCaml**, *Building a typed AST*:
  <https://dev.realworldocaml.org/gadts.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
