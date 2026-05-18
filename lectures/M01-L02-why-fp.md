---
title: "Why functional programming?"
lecture_no: 2
week: 1
duration_target_min: 25
concepts: [paradigms, pure functions, immutability, referential transparency, equational reasoning]
keywords: [functional programming, OCaml, pure functions, immutability, referential transparency, side effects, equational reasoning]
activity_question: "Which of the following functions is referentially transparent? (a) [let f x = x + 1]; (b) [let f x = Random.int x]; (c) [let counter = ref 0 in let f () = incr counter; !counter]; (d) [let f x = print_endline (string_of_int x); x]."
think_about_this: "If a function is pure, can you replace any call to it by its result without changing the meaning of the surrounding program? If a function is impure, can you still do the same?"
reading:
  - title: "Cornell CS3110, Chapter 1: Introduction"
    url: https://cs3110.github.io/textbook/chapters/intro/intro.html
  - title: "Why Functional Programming Matters (John Hughes, 1990)"
    url: https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf
---

# Why functional programming?

You can write any program in any Turing-complete language, so why is it
worth learning a new one? This video makes the case for the functional
style: what pure functions, immutability, and equational reasoning buy
you, and where they don't.

:::slide

## A one-instruction language

Consider a language with exactly one instruction:

```
subleq A, B, C
```

Read it as: store at `B` the difference of the values at `B` and `A`,
and if the result is `<= 0`, jump to `C`.

That's the whole language.

:::

:::slide

## What can it compute?

Surprisingly, *everything*. Three `subleq` instructions can implement
addition. A few more, and you have copy, move, conditional, multiply.
With enough patience, `subleq` is **Turing complete**: it expresses
every program any other language expresses.

So if `subleq` can compute everything, why not just write everything
in `subleq`?

:::

:::slide

## Because language is about more than what you *can* compute

Writing a Facebook clone in `subleq` is theoretically possible and
practically catastrophic. Languages exist to let you **say what you
mean**.

The slogan, then: a programming language is for thinking, not just for
running. The richer the abstractions, the closer the thinking aligns
with the running.

:::

:::slide

## The functional thesis

Functional programming chooses two abstractions as load-bearing:

1. **Functions as values.** You can pass functions around, return them,
   store them. Functions are first-class.
2. **Immutability.** Data is constructed, not mutated. New states are
   new values; old states stay valid.

These two together give you a way of thinking about programs as
*compositions of values*, instead of *sequences of state changes*.

:::

:::slide

## Pure functions

A function is **pure** when:

- Its output depends only on its arguments.
- It produces no observable side effects: no I/O, no mutation, no
  exception, no hidden state read or written.

```ocaml
let double x = x + x
```

`double 21` is `42`. Always. Anywhere. Whether you call it once,
twice, or never.

:::

:::slide

## Equational reasoning

Pure functions let you reason about your code the way you reason about
algebra. The expression `double 21` is *equal to* `42`. You can replace
it by `42` anywhere and the meaning of your program is unchanged.

```ocaml
let total = double 21 + double 21
(* same as *)
let total = 42 + 42
(* same as *)
let total = 84
```

This sounds modest. It is in fact a powerful tool for refactoring,
testing, and proving.

:::

:::slide

## Imperative code resists this

```c
int counter = 0;
int next() {
  return ++counter;
}
```

`next()` is not `next()`. The first call returns `1`, the second
returns `2`. Replacing one call by the next breaks meaning. Reordering
two calls breaks meaning. Caching the result breaks meaning.

Most of the work you do reading imperative code is reconstructing
the implicit state. Pure code lets you stop doing that.

:::

:::slide

## Immutability in practice

```ocaml
let xs = [1; 2; 3]
let ys = 0 :: xs
let _ = xs
```

`ys` is a new list, `[0; 1; 2; 3]`. `xs` is **unchanged**. You can hold
both at once. There is no version of the program where `xs` is in some
"newer" state.

The cost you might expect (copying the list) is not paid here; OCaml's
runtime shares structure between `xs` and `ys`.

:::

:::slide

## When functional shines

- **Parallelism without locks.** No mutable state means no races.
- **Refactoring.** Equational reasoning is a license to move code
  around with confidence.
- **Testing.** Pure functions are deterministic; tests are stable.
- **Domain modelling.** Algebraic data types make illegal states
  unrepresentable.

:::

:::slide

## When functional doesn't (be honest)

- **Hardware-level performance work.** Cache-aware algorithms sometimes
  want mutation.
- **Imperative APIs.** Anything talking to a database, a file system,
  the network: side effects exist and you must engage with them.
- **Idiom carry-over.** First few programs you write will fight your
  intuition. That's normal.

OCaml is a *functional-first* language with disciplined escape hatches
for state and effects. We will use those escape hatches when they
help, and only then.

:::

:::slide

## Why OCaml specifically

OCaml combines three things that don't often appear together:

- A serious type system that catches many errors at compile time.
- Native-code performance close to C.
- Pragmatic support for state, exceptions, and I/O when you actually
  need them, with the type system making the boundary explicit.

That combination is what lets us, in the second half of this course,
tackle **secure systems software**: runtime, memory safety, unikernels,
concurrency. Most languages aren't a credible vehicle for that. OCaml
is.

:::

:::slide

## Activity

Which of these is referentially transparent (the call can be replaced
by the result without changing program meaning)?

- (a) `let f x = x + 1`
- (b) `let f x = Random.int x`
- (c) `let counter = ref 0 in let f () = incr counter; !counter`
- (d) `let f x = print_endline (string_of_int x); x`

Think before peeking at the next slide.

:::

:::slide

## Activity discussion

Only (a) is referentially transparent.

```ocaml
(* (a) is pure: f 5 is always 6 *)
let f x = x + 1
```

(b) is random; (c) reads and writes hidden state; (d) prints, which
is an observable effect. Replacing any of those with their last
result changes program behaviour.

:::

## Reading

- **Cornell CS3110, Chapter 1** -- free online textbook, very
  accessible:
  <https://cs3110.github.io/textbook/chapters/intro/intro.html>
- **John Hughes, *Why Functional Programming Matters* (1990)** -- one
  of the foundational papers in the area, still readable:
  <https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf>
