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

- *Everything.*
- Three `subleq` instructions implement addition.
- A few more: copy, move, conditional, multiply.
- `subleq` is **Turing complete** — same power as any other language.

So why not write everything in `subleq`?

:::

:::slide

## Because language is about more than what you *can* compute

- A Facebook clone in `subleq`: theoretically possible, practically catastrophic.
- Languages exist to let you **say what you mean.**
- A programming language is for **thinking**, not just running.
- Richer abstractions $\Rightarrow$ thinking closer to the running code.

:::

:::slide

## The functional thesis

Two load-bearing abstractions:

1. **Functions as values.** Pass them around, return them, store them. First-class.
2. **Immutability.** Data is constructed, not mutated. New states $=$ new values.

Together: programs as **compositions of values**, not **sequences of state changes**.

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

- Pure functions $\Rightarrow$ reason about code like algebra.
- `double 21` is *equal to* `42`.
- Replace one with the other, anywhere — meaning unchanged.

```ocaml
let total = double 21 + double 21
(* same as *)  let total = 42 + 42
(* same as *)  let total = 84
```

Sounds modest. Powerful tool for **refactoring, testing, proving**.

:::

:::slide

## Imperative code resists this

```c
int counter = 0;
int next() {
  return ++counter;
}
```

- `next()` is **not** `next()`.
- Reordering two calls: breaks meaning.
- Caching the result: breaks meaning.
- Reading imperative code = reconstructing implicit state.

:::

:::slide

## Immutability in practice

```ocaml
let xs = [1; 2; 3]
let ys = 0 :: xs
let _ = xs
```

- `ys` is `[0; 1; 2; 3]`. `xs` is **unchanged.**
- Both live at once. No "newer" version of `xs`.
- No copy cost: runtime shares the tail.

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

- **Hardware-level performance.** Cache-aware algorithms want mutation.
- **Imperative APIs.** Database, file system, network — effects exist.
- **Idiom carry-over.** Your first programs will fight your intuition. Normal.

OCaml is **functional-first**: disciplined escape hatches, used only when they help.

:::

:::slide

## Why OCaml specifically

Three things that don't often appear together:

- A serious **type system** — compile-time errors, not runtime.
- **Native-code performance** close to C.
- **Pragmatic effects** — state, exceptions, I/O when you need them; types make the boundary explicit.

That combination is what lets the second half of the course tackle **secure systems software**.

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

Only **(a)** is referentially transparent.

```ocaml
(* (a) is pure: f 5 is always 6 *)
let f x = x + 1
```

- **(b)** is random.
- **(c)** reads and writes hidden state.
- **(d)** prints — an observable effect.

Replace any of these with a previous result: program behaviour changes.

:::

## Reading

- **Cornell CS3110, Chapter 1** -- free online textbook, very
  accessible:
  <https://cs3110.github.io/textbook/chapters/intro/intro.html>
- **John Hughes, *Why Functional Programming Matters* (1990)** -- one
  of the foundational papers in the area, still readable:
  <https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf>
