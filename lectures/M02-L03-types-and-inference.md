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

- **Static semantics**: rules that say what the expression *means*
  before you run it. The main piece of static semantics is **what
  type the expression has**.
- **Dynamic semantics**: rules that say what happens when you *run*
  the expression. The result of running is a **value**.

```ocaml
let _ = 23 + 45
```

- Static: this is `int + int`, so the expression has type `int`.
- Dynamic: it evaluates to `68`.

Both kinds of meaning matter. Static catches whole classes of bug
before you ever press Run.

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

You cannot put a language cleanly into a single "static" or
"dynamic" box. It is more useful to think of a spectrum:

- **Mostly dynamic** (JavaScript, Python). Almost everything is
  checked at runtime. Programs run with very little upfront
  ceremony; bugs surface when the code path that contains them is
  exercised.
- **Some static, mostly dynamic** (C). Types are declared and the
  compiler checks them, but the type system is weak: a cast or a
  void* lets you sidestep it. Memory errors are runtime, and often
  silent.
- **More static** (Java, Scala, Rust, Kotlin, Swift). Strong type
  systems; most type errors are compile-time. Some things (null
  references, downcast failures) still surface at runtime.
- **Mostly static** (OCaml, Haskell). Almost no runtime type errors
  in well-typed code. The compiler catches a large fraction of bugs
  before the program runs.

OCaml sits near the "mostly static" end. That's a deliberate design
choice.

:::

:::slide

## A static error

```ocaml
let _ = 23 = 45.0
```

OCaml rejects this: the left side is `int`, the right side is
`float`, and `=` requires both sides to have the same type.

```
Error: This expression has type float but an expression was expected
       of type int because it is in the right operand of equality.
```

The program does not run. You haven't even gotten to "well, what
does the comparison return"; the static check failed first.

:::

:::slide

## A dynamic check (not an error)

```ocaml
let _ = 23 = 45
```

Both sides are `int`. The static check is happy: the expression has
type `bool`. At runtime, the comparison evaluates: `false`.

The dynamic semantics produced a value. That value is `false`. It is
not an error to have an expression evaluate to `false`; it is what
the comparison means.

:::

:::slide

## Why catch errors statically?

- **Earlier is cheaper.** A bug caught at compile time can't ship.
- **Better localization.** The compiler points at the file and line.
  A runtime null-pointer exception three function calls deep is
  harder to trace.
- **Fearless refactoring.** Rename a field, change a type; the
  compiler tells you every call site that needs updating. In a
  dynamic language you find them by running the code.
- **Documentation.** Types annotate the program with what each
  function expects and returns, mechanically checked.

The cost is some upfront friction: you have to make the code well
typed before you can run any of it. People used to dynamic languages
sometimes find this annoying. The trade is fewer bugs at later,
more expensive stages.

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

How did inference arrive at this?

- `x + y` uses `(+)`, which has type `int -> int -> int`.
- So `x` must be `int`, `y` must be `int`, and the result of `x + y`
  is `int`.
- The function `add x y` therefore has type `int -> int -> int`.

You wrote zero type annotations. The compiler did the work.

:::

:::slide

## A different operator changes everything

```ocaml
let add_f x y = x +. y
```

`val add_f : float -> float -> float = <fun>`.

Same shape; just `+.` instead of `+`. The float operator forces both
arguments to be `float`, so the function is `float -> float -> float`.

This is the whole secret: the operators carry type information.
Inference propagates it through the rest of the function.

:::

:::slide

## A trickier example

```ocaml
let mag x y = sqrt (x *. x +. y *. y)
```

`val mag : float -> float -> float = <fun>`.

Walk it:

- `sqrt` has type `float -> float`. Its argument must be `float`.
- `x *. x +. y *. y` must therefore be `float`.
- `*.` and `+.` force both their operands to `float`.
- So `x` is `float` and `y` is `float`.
- Result is `float`.

You'd have to write all this out as annotations in many other
languages. OCaml does it for you and reports the final type.

:::

:::slide

## Polymorphism for free

```ocaml
let identity x = x
```

`val identity : 'a -> 'a = <fun>`.

Read `'a` as "some type, to be filled in by the caller". OCaml has
*parametric polymorphism* (the same idea as Java generics or C++
templates, just more pleasant): functions that don't constrain their
argument's type stay polymorphic.

```ocaml
let _ = identity 5
let _ = identity "hello"
let _ = identity true
```

Each call instantiates `'a` differently. No casting.

:::

The `'a` notation is read as "alpha", a placeholder for an unknown
type that the caller decides. You'll meet `'a`, `'b`, `'c`, ... when
inference can't determine a concrete type because the function genuinely
works at *any* type. Polymorphism gives you a single function that works
on many types, with the compiler still tracking what each call really
uses.

:::slide

## Annotations: when and why

You can write types explicitly. They must *agree* with what inference
would have produced:

```ocaml
let triple (x : int) : int = x + x + x
```

Inference would have given `int -> int` anyway. The annotation:

- documents intent in public APIs,
- pins down ambiguity (rare, but happens with records and modules),
- helps you locate the source of a type error: an annotated function
  fails at *its* line rather than propagating the error elsewhere.

For everyday code, leave annotations off. For module signatures
(the `.mli` files we'll see in Module 7), the annotations are the API.

:::

:::slide

## When inference reports a surprising type

Sometimes you write a function and the inferred type is more general
than you expected:

```ocaml
let first (x, _) = x
```

`val first : 'a * 'b -> 'a = <fun>`.

`first` works on any pair. The first element can be any type `'a`,
the second any (possibly different) type `'b`, and the result is
`'a`. We didn't ask for genericity; inference gave it to us.

If you want to *constrain* it, annotate:

```ocaml
let first_int (x, _ : int * int) = x
```

`val first_int : int * int -> int = <fun>`. Now it only works on
pairs of ints. Less general, but sometimes that's what you want.

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
- `y *. 2.0` requires `y` to be `float`; result is `float`.
- `x +. (...)` requires `x` to be `float`; result is `float`.
- So `f` is `float -> float -> float`.

If you had written `x + y *. 2.0` you'd have gotten an error: `+`
wants `int`, `*.` wants `float`. Inference reports an inconsistency
and points at the offender.

:::

:::slide

## What's next

In Lecture 4 we cover **operators and pitfalls**: precedence, the
list of operators you'll use daily, and the small set of mistakes that
catch beginners.

:::

## Reading

- **Cornell CS3110**, *Type checking*:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
- **Real World OCaml**, *A Guided Tour* (type inference section):
  <https://dev.realworldocaml.org/guided-tour.html>
