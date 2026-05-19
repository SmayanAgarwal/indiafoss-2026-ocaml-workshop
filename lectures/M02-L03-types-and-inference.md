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
them while you are compiling; some catch them while you are running;
some never catch them. Where a language draws this line shapes how
you write code in it. The earlier a bug is caught, the cheaper it is
to fix: a bug a compiler reports in milliseconds is cheaper than a
bug a test discovers in minutes, which is cheaper than a bug a user
discovers in production.

OCaml lands on the *more static* end of this spectrum: many of the
errors a Python or JavaScript program would discover at runtime, an
OCaml program rejects at compile time. The mechanism that makes this
work without forcing you to write types everywhere is *type
inference*, which gives you the safety of a strong type system
without the syntactic burden of annotations. This lecture covers
both: the static-vs-dynamic distinction first, then inference in
detail.

By the end you should be able to look at any OCaml function you have
written and predict, without running it, what type the compiler will
infer. That skill is the difference between fighting OCaml's type
errors and reading them.

## Static versus dynamic: two kinds of meaning

Every expression in any programming language has two kinds of
meaning. The *static* meaning is what you can determine without
running the code: in OCaml, the most important static fact is the
expression's *type*. The *dynamic* meaning is what happens when you
execute the code: the *value* it produces (and any side effects on
the way).

```ocaml
let _ = 23 + 45
```

- Static semantics: this expression is the application of `(+)`
  (with type `int -> int -> int`) to two `int` literals. The
  expression has type `int`.
- Dynamic semantics: when evaluated, it produces the value `68`.

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

The two kinds of meaning are independent: knowing the type of an
expression does not, in general, tell you its value (it tells you
which *kind* of values are possible). Knowing the value does not
formally tell you the type, though usually it constrains it.

A *type error* is a violation of static semantics: the compiler
notices a mismatch and refuses to produce a runnable program. A
*runtime exception* (like division by zero, or out-of-bounds array
access) is a violation of dynamic semantics: the program runs and
encounters an unexpected situation at execution time.

The static-vs-dynamic lens is one we will return to throughout the
course. Each time we introduce a new construct (functions, records,
variants, modules), we will ask: what type does this expression
have, and what happens at runtime? They are two questions, both
worth answering.

## A spectrum of languages

It is helpful to think of programming languages as falling along a
spectrum, not into a binary "static" versus "dynamic" box. Different
languages catch different fractions of errors statically.

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

**Mostly dynamic** (JavaScript, Python, Ruby). Almost everything is
checked at runtime. You can write `x + "1"` in Python and find out
*at execution time* whether it makes sense (it does not, in
Python 3). Programs work in test until an untested code path runs;
a typo in a method name is a runtime error, not a compile error.

**Some static, mostly dynamic** (C). Types are declared, but the
type system is weak: casts and `void*` give you escape hatches that
the compiler does not police. Pointer arithmetic can manufacture
nonsense without complaint. Memory errors (use-after-free,
buffer overflow) are detected (if at all) at runtime, often
silently corrupting data before crashing somewhere else.

**More static** (Java, Scala, Rust, Kotlin, Swift, C#). Stronger
type systems; many errors that would be runtime in dynamic
languages are compile-time here. But there are still escape
hatches: null references are usually nullable by default in Java
(NullPointerException at runtime), downcasts can fail at runtime,
generics have erasure issues. Rust is closer to fully static.

**Mostly static** (OCaml, Haskell, Idris). Almost no runtime type
errors in well-typed code. There is no `null` by default (you opt
in via `Option`, which the type system tracks). Casts that the
type checker can't verify are explicit and rare. Most of the
errors you would discover at runtime in Python or Java, you
discover at compile time in OCaml.

The trade-off is real: more static checking means more upfront
work to get the types right, in exchange for fewer runtime
surprises. OCaml's bet is that the upfront cost is small (because
of inference, see below) and the runtime payoff is large. The same
bet underlies Rust and Haskell.

## A static error

Here is a small program that does not even compile, because of a
static-semantics violation.

```ocaml skip
let _ = 23 = 45.0
```

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

The left operand of `=` is an `int`, the right is a `float`. The
equality operator `(=)` has type `'a -> 'a -> bool`: both operands
must be the *same* type (any type, but the same). `int` and
`float` are different types; the constraint cannot be satisfied;
the compiler rejects the program.

This is helpful behaviour, not annoying. The program author
probably intended to compare two numbers of the same type;
mixing `int` with `float` here is almost certainly a typo (was
the literal supposed to be `45`? Or was the variable supposed to
be `23.0`?). Either way, the compiler asks before the program
runs.

## A dynamic check (not an error)

Compare with this:

```ocaml
let _ = 23 = 45
```

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

Both sides are `int`; the types match; static check passes. The
expression has type `bool`. At runtime, it evaluates to `false`
(because 23 ≠ 45). This is *not* an error; it is what equality
means. The static check was about whether the comparison was
well-formed; the dynamic answer is about whether it happens to
hold for these particular values.

This is the distinction worth internalising: type errors and
"wrong answers" are different categories of failure. The first is
a question about the *shape* of your program; the second is about
its *behaviour*. Static checking aims at the first.

## Why catch errors statically?

Why bother with this whole static apparatus, when dynamic languages
let you write code faster? Four reasons that compound:

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

**Earlier is cheaper.** Bugs found by the compiler never ship; they
get fixed before the code is even committed. Bugs found in tests
get fixed before the code is deployed. Bugs found in production are
the most expensive to fix, because users were affected and you
need a hot-fix release. The earlier in this chain the compiler
catches an error, the cheaper it is.

**Better localization.** When the compiler reports a type error, it
points at the file, line, and (usually) the offending sub-expression,
plus what was expected versus what was found. Compare this to a
runtime null-pointer exception that surfaces three calls deep into a
library you did not write, where the error message is the *symptom*
(`undefined is not a function`) rather than the *cause* (a typo in
a field name).

**Fearless refactoring.** This is the one that makes the largest
practical difference. If you rename a field of a record in OCaml,
the compiler immediately tells you every call site that needs to be
updated, by reporting type errors. You fix them; the program
compiles; it works (or at least, has not regressed). In a dynamic
language, the equivalent rename means hunting through string
matches in the codebase and hoping you have tests for every code
path. Refactoring in OCaml is fast and confident; in Python or
JavaScript it is slow and nervous. This is why large codebases in
typed languages stay maintainable over years.

**Documentation that cannot lie.** A function's type signature is
documentation: a one-line description of what it expects and what
it returns, that the compiler keeps honest. If the documentation
were a doc comment ("this function takes an int and returns a
string"), it could drift out of sync with the code; the type
signature can't. We will exploit this heavily in Module 7 when we
get to module signatures.

The cost: you have to think about types upfront. Programs that
would run-but-silently-misbehave in Python are rejected by OCaml
until they are well-typed. To people used to typing fast and
testing fast, this can feel like friction. The trade is that you
catch problems early; the question is whether the friction is
worth the savings. For programs intended to last more than a week
(which is most real software), the savings dwarf the friction.

## Type inference

The reason the static type system is bearable in OCaml is *type
inference*: the compiler works out what types your expressions have
without you having to write them down. OCaml's inference is based
on the [Hindley-Milner algorithm](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system)
(developed by Roger Hindley in combinatory logic and rediscovered
by Robin Milner for ML in the 1970s). The intuition is straightforward, even if the algorithm
itself has some clever parts:

1. Every expression has some type. Initially the compiler treats
   each unknown type as a fresh type variable (`'a`, `'b`, ...).
2. Operators and literal forms generate *constraints*: `+` says its
   two operands must be `int` and its result is `int`. The literal
   `3.14` says it is `float`. A function call says the argument's
   type must match the function's parameter type.
3. The compiler collects all these constraints and *solves* them: it
   finds a consistent assignment of types to every expression in
   the program. If no consistent assignment exists, you get a type
   error.
4. The final inferred type of each binding is reported.

You will never implement this algorithm yourself in this course;
you only need to read its output. When the toplevel reports a type
for a function you wrote, it ran inference.

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

Walk through:

- `+` has type `int -> int -> int` (the integer addition operator).
- In `x + y`, both operands of `+` must be `int`. So `x : int` and
  `y : int`.
- The result of `+` is `int`. So `x + y` has type `int`.
- The function body is `x + y`, so the body has type `int`.
- The function takes `x` (an `int`) and `y` (an `int`) and returns
  an `int`. So `add : int -> int -> int`.

Every step is a constraint generated from an operator or function;
the inference algorithm runs through them all and reports the type.
We wrote no annotations.

```ocaml
let add_f x y = x +. y
```

Same shape, different operator. `+.` has type `float -> float ->
float`. So `x` and `y` are forced to be `float`, the result is
`float`, and the function has type `float -> float -> float`.

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

**The operator drives the inference.** This is the punchline I want
you to internalise from this lecture. When you read OCaml code and
want to predict the type, look at the operators and function calls;
each one imposes constraints; the constraints propagate; the type
falls out.

## A trickier example

Here is a function whose type may surprise you the first time:

```ocaml
let mag x y = sqrt (x *. x +. y *. y)
```

What is the type?

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

Trace:

- `sqrt` has type `float -> float`. So its argument must be `float`.
- The argument is `x *. x +. y *. y`. The result of `+.` is `float`.
- The operands of `+.` (which are `x *. x` and `y *. y`) must each
  be `float`. The result of `*.` is `float`.
- The operands of `*.` (which are `x` and `x`, and `y` and `y`)
  must each be `float`. So `x : float` and `y : float`.
- The result of the whole function body, `sqrt (...)`, is `float`.
- Therefore `mag : float -> float -> float`.

Inference chained four operator constraints to determine both
parameters and the return type. In a language without inference
(Java, C, C++), you would have written `float mag(float x, float y)`
with all three types explicit. In OCaml the compiler does the work.

## Polymorphism for free

Some functions cannot be pinned to a single concrete type, because
they work *at any type*. Here is the simplest example:

```ocaml
let identity x = x
```

What is the type of `identity`?

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

The toplevel reports `val identity : 'a -> 'a = <fun>`. The `'a`
(read "alpha") is a *type variable*: a placeholder for "some type,
chosen by the caller." The same `'a` appears in the argument and
return positions, meaning "whatever type the caller passes in is
also the return type."

This is *parametric polymorphism*. Other languages call this
"generics" (Java, C#, Swift), "templates" (C++), or "type
parameters" (Rust, Haskell). The OCaml version is particularly
pleasant: there is no syntax to opt in. You just write a function;
if it does not constrain its argument's type, inference assigns it
a polymorphic type automatically.

Each call instantiates the type variable to the concrete type of
the argument. `identity 5` instantiates `'a` to `int`; `identity
"hello"` instantiates it to `string`; `identity true` to `bool`.
No casting, no boxing, no special syntax. The function works.

When you see `'a`, `'b`, `'c` in inferred types, those are type
variables; the function is polymorphic in them. The names start at
`'a` and go alphabetically.

:::quiz mcq
What type does OCaml infer for this function?

```ocaml
let swap (a, b) = (b, a)
```

- [ ] `int * int -> int * int`
- [ ] `'a * 'a -> 'a * 'a`
- [x] `'a * 'b -> 'b * 'a`
- [ ] `'a -> 'a`

**Why:** `swap` takes a pair (note the *single* parenthesised
argument, which is destructured into `a` and `b`) and returns the
elements in reversed order. Nothing constrains `a` and `b` to be
the same type, so they get distinct type variables `'a` and `'b`.
The return is the pair with positions swapped: first element is
`b` (type `'b`), second is `a` (type `'a`). Total: `'a * 'b -> 'b
* 'a`. The function is polymorphic in *two* type variables.
:::

## Annotations: when and why

Annotations are optional and must agree with what inference would
have produced anyway. So why ever write them?

```ocaml
let triple (x : int) : int = x + x + x
```

The `(x : int)` says the parameter is `int`; the `: int` after the
parameter list says the return type is `int`. Inference would have
inferred these from `+`; the annotations are redundant. They
compile fine because they agree with what inference would have
produced. If you wrote `(x : float) : int` instead, the compiler
would reject it (`float` does not match the `int` constraint from
`+`).

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

Use annotations when:

- **The function is part of a public API.** Then the annotation is
  documentation: it tells a reader what the function expects without
  forcing them to read the body.
- **You want to constrain inference.** Occasionally inference would
  produce a more general type than you want (we will see an example
  next). Annotating constrains it.
- **You are debugging a confusing type error.** Adding annotations
  to suspect functions narrows where the error gets reported. The
  compiler now blames *that* function instead of some caller.

Module signatures (`.mli` files, Module 7) are entirely
annotations: they list the types of a module's exports, and the
compiler enforces them against the module's implementation. We
will see this in detail later.

For ordinary local helpers, leave annotations off. They clutter.

## When inference is more general than you wanted

Sometimes inference gives you a more polymorphic type than you
intended. Here is the canonical example:

```ocaml
let first (x, _) = x
```

What is the inferred type?

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

`first : 'a * 'b -> 'a`. The function takes a pair (any types,
possibly different) and returns the first element. We did not ask
for genericity; we just did not do anything that would constrain
the types. Inference gave us the most general type that fits.

This is usually what you want. Sometimes it is not: if you
specifically wanted `first` to work only on `int * int` (to catch
accidental misuse), you would annotate:

```ocaml
let first_int (x, _ : int * int) = x
```

Now the function is `int * int -> int`, less general but more
constrained. Whether to constrain is a judgement call; in
practice, leaving things polymorphic is usually fine and sometimes
useful (you can pass any pair).

## Activity

:::slide

## Activity

What type does OCaml infer for:

```ocaml
let f x y = x +. y *. 2.0
```

Predict, then run.

:::

:::quiz mcq
What type does OCaml infer for `let f x y = x +. y *. 2.0`?

- [ ] `int -> int -> int`
- [ ] `'a -> 'a -> 'a`
- [x] `float -> float -> float`
- [ ] `float -> int -> float`

**Why:** the literal `2.0` is `float`. The operator `*.` forces `y`
to be `float` and the product `y *. 2.0` to be `float`. The
operator `+.` forces `x` and the product to be `float`; the result
of `+.` is `float`. So both arguments are `float` and the result
is `float`. If you had written `+` instead of `+.`, the compiler
would have rejected the function because the operator `+` expects
two `int` arguments but the inner expression `y *. 2.0` is
`float`.
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

## What's next

We have now seen enough OCaml that the rhythm of writing functions
and reading inferred types should feel manageable. The next lecture
(M02-L04) goes through the operators in detail: precedence, the
ones that catch beginners out, and the small set of operators you
will use 95% of the time. After that, M02-L05 covers
`if`/`then`/`else` as an expression (a small but real shift from
imperative languages), and M02-L06 is the tutorial.

:::slide

## What's next

- Next: **operators and pitfalls**.
- Precedence, daily operators, and beginner mistakes.

:::

## Reading

- **Cornell CS3110**, *Type checking*: the textbook chapter on
  the same material with formal typing rules:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
- **Real World OCaml**, *A Guided Tour* (type inference section):
  <https://dev.realworldocaml.org/guided-tour.html>
