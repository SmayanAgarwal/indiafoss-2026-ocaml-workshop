---
title: "Static vs dynamic semantics, and type inference"
lecture_no: 3
week: 2
duration_target_min: 26
concepts: [static typing, dynamic typing, type errors, type inference, type signatures]
keywords: [OCaml, static typing, dynamic typing, type inference, Hindley-Milner, type errors]
activity_question: "Without running it, what type does OCaml infer for [let f x y = x +. y *. 2.0]? Why?"
think_about_this: "If OCaml can figure out the types itself, why would you ever write a type annotation? Where are annotations actually useful?"
reading:
  - title: "Cornell CS3110, Type checking"
    url: https://cs3110.github.io/textbook/chapters/basics/expressions.html
  - title: "Real World OCaml, Type inference"
    url: https://dev.realworldocaml.org/guided-tour.html
---

# Static vs dynamic semantics, and type inference

Programming languages catch errors at different times. Some catch
them while you're compiling. Some catch them while you're running.
Some never catch them. Where a language draws this line shapes how
you write code in it.

OCaml lands on the *more static* end of this spectrum: many of the
errors a Python or JavaScript program would discover at runtime, an
OCaml program rejects at compile time. The mechanism that makes this
work is **type inference**, which gives you the safety of types
without forcing you to write them down.

:::slide

## Two kinds of semantics

Every expression has both:

- **Static semantics**: meaning *before* you run.
  - Main piece: **what type the expression has**.
- **Dynamic semantics**: what happens when you *run* it.
  - Result: a **value**.

```ocaml
let _ = 23 + 45
```

- Static: `int + int`, so the expression has type `int`.
- Dynamic: evaluates to `68`.

- Both matter; static catches whole classes of bug before you press Run.

:::

The static-vs-dynamic distinction is the lens through which much of
this course is taught. Whenever we introduce a new construct, we
will ask: what type does this expression have (static), and what
happens when you run it (dynamic). The two are independent.

A type error is a **violation of static semantics** discovered by
the compiler. A runtime exception is a **violation of dynamic
semantics** discovered while the program is executing.

:::slide

## A spectrum of languages

Think of a spectrum, not a binary:

- **Mostly dynamic** (JavaScript, Python):
  - Almost everything checked at runtime.
  - Bugs surface only when their code path runs.
- **Some static, mostly dynamic** (C):
  - Types declared, but weak system: casts / `void*` sidestep it.
  - Memory errors are runtime, often silent.
- **More static** (Java, Scala, Rust, Kotlin, Swift):
  - Strong type systems; most type errors compile-time.
  - Null refs and downcast failures still surface at runtime.
- **Mostly static** (OCaml, Haskell):
  - Almost no runtime type errors in well-typed code.
  - Compiler catches a large fraction of bugs pre-run.

- OCaml sits near the **"mostly static"** end: a deliberate choice.

:::

:::slide

## A static error

```ocaml skip
let _ = 23 = 45.0
```

- Rejected: left is `int`, right is `float`.
- `=` requires both sides to have the **same type**.

```
Error: This expression has type float but an expression was expected
       of type int because it is in the right operand of equality.
```

- The program does not run.
- Static check fails first: never reaches "what does the comparison return".

:::

:::slide

## A dynamic check (not an error)

```ocaml
let _ = 23 = 45
```

- Both sides `int`: static check passes, expression type is `bool`.
- At runtime, the comparison evaluates to `false`.
- Dynamic semantics produced a **value** (`false`).
- Evaluating to `false` is **not an error**; it's what the comparison means.

:::

:::slide

## Why catch errors statically?

- **Earlier is cheaper.** A bug caught at compile time can't ship.
- **Better localization.** Compiler points at file and line.
  - A runtime null-pointer three calls deep is harder to trace.
- **Fearless refactoring.** Rename a field; compiler lists every call site.
  - In a dynamic language you find them by running the code.
- **Documentation.** Types annotate the API, mechanically checked.

- **Cost**: upfront friction; must be well-typed before running.
- People from dynamic languages sometimes find this annoying.
- Trade: fewer bugs at later, more expensive stages.

:::

## Type inference

Here is the trick that makes a strongly typed language usable for
real work: you don't have to write the types down. The compiler
figures them out.

OCaml uses an algorithm in the **Hindley-Milner** family. The
intuition: every expression has a type, every variable's type is
constrained by the operators and functions it touches, and the
compiler solves these constraints to find a single consistent
typing of the whole program.

You'll never need to implement this algorithm by hand. You only need
to read its output: when you write a function and the toplevel
reports a type, that's inference at work.

:::slide

## Inference for a simple function

```ocaml
let add x y = x + y
```

Toplevel reports: `val add : int -> int -> int = <fun>`.

- `x + y` uses `(+) : int -> int -> int`.
- So `x : int`, `y : int`, result `int`.
- Therefore `add : int -> int -> int`.
- **Zero annotations written.** Compiler did the work.

:::

:::slide

## A different operator changes everything

```ocaml
let add_f x y = x +. y
```

`val add_f : float -> float -> float = <fun>`.

- Same shape; `+.` instead of `+`.
- Float operator forces both args to `float`.
- So `add_f : float -> float -> float`.
- **Secret**: operators carry type information.
- Inference propagates it through the rest of the function.

:::

:::slide

## A trickier example

```ocaml
let mag x y = sqrt (x *. x +. y *. y)
```

`val mag : float -> float -> float = <fun>`.

- `sqrt : float -> float`, argument must be `float`.
- So `x *. x +. y *. y` must be `float`.
- `*.` and `+.` force operands to `float`.
- Hence `x : float`, `y : float`, result `float`.
- Many languages need this spelled out as annotations; OCaml infers it.

:::

:::slide

## Polymorphism for free

```ocaml
let identity x = x
```

`val identity : 'a -> 'a = <fun>`.

- Read `'a` as "some type, to be filled in by the caller".
- OCaml has **parametric polymorphism** (like Java generics / C++ templates, more pleasant).
- Functions that don't constrain their arg type stay polymorphic.

```ocaml
let _ = identity 5
let _ = identity "hello"
let _ = identity true
```

- Each call instantiates `'a` differently. **No casting.**

:::

The `'a` notation is read as "alpha", a placeholder for an unknown
type that the caller decides. You'll meet `'a`, `'b`, `'c`, ... when
inference can't determine a concrete type because the function genuinely
works at *any* type. Polymorphism gives you a single function that works
on many types, with the compiler still tracking what each call really
uses.

:::slide

## Annotations: when and why

- Annotations are optional; must **agree** with what inference would produce.

```ocaml
let triple (x : int) : int = x + x + x
```

- Inference would have given `int -> int` anyway.
- Annotation uses:
  - **Documents intent** in public APIs.
  - **Pins down ambiguity** (rare, with records and modules).
  - **Locates type errors**: an annotated function fails at *its* line.

- For everyday code, leave annotations off.
- For module signatures (`.mli`, Module 7), annotations **are the API**.

:::

:::slide

## When inference reports a surprising type

Sometimes the inferred type is more general than you expected:

```ocaml
let first (x, _) = x
```

`val first : 'a * 'b -> 'a = <fun>`.

- Works on any pair.
- First element any type `'a`, second any (possibly different) `'b`, result `'a`.
- We didn't ask for genericity; inference gave it.

To **constrain**, annotate:

```ocaml
let first_int (x, _ : int * int) = x
```

- `val first_int : int * int -> int = <fun>`.
- Now only works on pairs of `int`. Less general, sometimes what you want.

:::

:::slide

## Activity

What type does OCaml infer for:

```ocaml
let f x y = x +. y *. 2.0
```

Predict, then run.

:::

:::slide

## Activity discussion

`val f : float -> float -> float = <fun>`.

- `2.0` is `float`.
- `y *. 2.0` forces `y : float`; result `float`.
- `x +. (...)` forces `x : float`; result `float`.
- So `f : float -> float -> float`.

- Had you written `x + y *. 2.0`: type error.
- `+` wants `int`, `*.` wants `float`.
- Inference reports an inconsistency and points at the offender.

:::

:::slide

## What's next

- Next: **operators and pitfalls**.
- Precedence, daily operators, and beginner mistakes.

:::

## Reading

- **Cornell CS3110**, *Type checking*:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
- **Real World OCaml**, *A Guided Tour* (type inference section):
  <https://dev.realworldocaml.org/guided-tour.html>
