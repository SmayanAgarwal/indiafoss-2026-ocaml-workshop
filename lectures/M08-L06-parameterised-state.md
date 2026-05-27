---
title: "Parameterised state and a typed stack machine"
lecture_no: 6
week: 8
duration_target_min: 21
concepts: [parameterised monad, state type changes, typed stack machine, type-encoded preconditions]
keywords: [OCaml, parameterised monad, indexed monad, stack machine, WebAssembly]
activity_question: "Extend the typed stack machine with a [mul] operation that multiplies the top two ints on the stack. Show a program that pushes two ints, multiplies, then pushes a third and adds."
think_about_this: "The state-monad type was [state -> state * 'a], one state type throughout. The parameterised version is [pre -> post * 'a]. What kinds of programs become well-typed under the second that the first could not even express?"
reading:
  - title: "Cornell CS3110, Monads"
    url: https://cs3110.github.io/textbook/chapters/ds/monads.html
---

# Parameterised state and a typed stack machine


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Parameterised state and a typed stack machine</h2>
<p class="title-slide-label">Module 8 &middot; Lecture 6</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The state monad in [Lecture 5](M08-L05-state-monad.html) threads a
*single, typed* mutable cell through a chain of computations.
That works as long as the state's *type* does not change between
steps. But what if it should? Imagine a small stack machine where
each operation transforms the stack: `push 5` changes a stack of
shape `'s` to a stack of shape `int * 's`; `add` takes a stack of
shape `int * (int * 's)` and returns `int * 's`. The state's type
*itself* is the running shape of the stack.

This lecture introduces the *parameterised state monad*, where the
input and output state types are two separate type parameters. We
build it from the state monad of the previous lecture, then use it
to construct a tiny stack machine whose ill-typed programs (push a
bool then add two ints) are rejected at compile time. This is also
the bridge from monads to GADTs: the type-refinement pattern we
will formalise in [Lecture 7](M08-L07-gadts-basics.html) shows up
here in slightly less rigorous form.

:::slide

## This lecture

- State monad threaded a single state type through every step.
- Parameterised state lets the state's *type* change between steps.
- The signature: `('pre, 'post, 'a) t`.
  - `'pre`: input state type.
  - `'post`: output state type.
  - `'a`: value produced.
- Worked example: typed stack machine.
- Compile-error demo: ill-typed programs rejected.
- Bridge from monads (this lecture) to GADTs
  ([Lecture 7](M08-L07-gadts-basics.html)).

:::

## From state to parameterised state

Recall the ordinary state monad:

:::slide

## Ordinary state monad: one state type

```ocaml
type ('s, 'a) state = 's -> 's * 'a

let return x : ('s, 'a) state = fun s -> (s, x)

let bind (m : ('s, 'a) state) (f : 'a -> ('s, 'b) state)
  : ('s, 'b) state =
  fun s ->
    let (s', a) = m s in
    (f a) s'
```

- The state type `'s` is *fixed* throughout the chain.
- Every step takes an `'s` and returns an `'s`.
- This is fine for counters, gensyms, parser positions.
- It does not encode "this step grows the state by one int".

:::

The function `m : ('s, 'a) state` says "given an input state of
type `'s`, return a (new state of type `'s`, value of type `'a`)".
The input and output state types are the same `'s`. There is no
room to track "this step expects a stack with at least one int on
top" because that would be a different state type from "this step
expects an empty stack".

## The parameterised version

The fix is to give the state two type parameters instead of one:
`'pre` for the input and `'post` for the output.

:::slide

## Parameterised state: two state types

```ocaml
type ('pre, 'post, 'a) pstate = 'pre -> 'post * 'a

let preturn x : ('s, 's, 'a) pstate = fun s -> (s, x)

let pbind (m : ('p, 'q, 'a) pstate) (f : 'a -> ('q, 'r, 'b) pstate)
  : ('p, 'r, 'b) pstate =
  fun s ->
    let (s', a) = m s in
    (f a) s'
```

- Three type parameters now: pre-state, post-state, value.
- `preturn`: state type unchanged (`'s` in and out).
- `pbind`: the *post-state* of the first step is the *pre-state*
  of the second. Types thread through the chain.

:::

Read `pbind`'s type carefully. The first computation goes from
`'p` to `'q`. The continuation takes a value and goes from `'q` to
`'r`. The combined computation goes from `'p` to `'r`, skipping
the intermediate `'q`. The compiler tracks this chain at every
step.

This is the same machinery as the state monad's `bind`, just with
three type variables where there was one. The runtime behaviour is
identical; the types are richer.

## A typed stack machine

Now the fun part. We model a stack as a *nested pair*, with `unit`
at the bottom:

:::slide

## Stack as a nested pair

- Empty stack: `()` of type `unit`.
- One int on top: `(5, ())` of type `int * unit`.
- Stack `[1; 2; 3]`: `(1, (2, (3, ())))` of type
  `int * (int * (int * unit))`.
- Mixed stack `[1; true; 3]`: `(1, (true, (3, ())))` of type
  `int * (bool * (int * unit))`.

The *type* records every element's shape from top to bottom.

:::

This is the same encoding we will see again in
[L09](M08-L09-hlists-witnesses.html) for hlists. The type is a
right-nested tuple; the deeper you go, the further down the stack.

The stack operations now have *informative* types:

:::slide

## Stack operations with informative types

```ocaml
type ('pre, 'post, 'a) pstate = 'pre -> 'post * 'a
let preturn x : ('s, 's, 'a) pstate = fun s -> (s, x)
let pbind (m : ('p, 'q, 'a) pstate) (f : 'a -> ('q, 'r, 'b) pstate)
  : ('p, 'r, 'b) pstate =
  fun s ->
    let (s', a) = m s in
    (f a) s'
let ( let* ) = pbind

let push (x : 'a) : ('s, 'a * 's, unit) pstate =
  fun s -> ((x, s), ())

let add : (int * (int * 's), int * 's, unit) pstate =
  fun (x, (y, s)) -> ((x + y, s), ())

let run (m : ('pre, 'post, 'a) pstate) (s : 'pre) : 'post * 'a = m s
```

- `push x`: input stack `'s`, output stack `'a * 's`. Adds one.
- `add`: input must be `int * (int * 's)`, output is `int * 's`.
  Consumes two ints, produces one.
- The compiler reads these signatures and enforces them.

:::

`push x` always succeeds: any stack `'s` accepts a value `x` on
top, producing `'a * 's`. The output stack's type names the value
pushed.

`add` is fussier: it *requires* the input stack to have at least
two `int`s on top. The type `int * (int * 's)` says: "first int,
then int, then anything else". If you try to run `add` on a stack
whose top is a `bool`, the type system rejects it.

## A well-typed program

A program that pushes two ints and adds them:

:::slide

## A well-typed program

```ocaml
let prog =
  let* () = push 4 in
  let* () = push 5 in
  add

let _ = run prog ()
```

`((9, ()), ())`. Read the run result:

- Final stack: `(9, ())` (one int, `9`, on top of empty).
- Value: `()` (the `add` operation returns nothing useful).

Step by step:

- Start: stack `()`, type `unit`.
- `push 4`: stack `(4, ())`, type `int * unit`.
- `push 5`: stack `(5, (4, ()))`, type `int * (int * unit)`.
- `add`: stack `(9, ())`, type `int * unit`.

:::

Notice: this *type-checks* because the chain of types lines up.
After `push 5`, the stack has type `int * (int * unit)`, which is
exactly what `add` wants. After `add`, the stack has type `int *
unit`, which is the final state.

The compiler is verifying not just that the code runs but that
the *shape* of the stack at every point is what the next operation
needs.

## An ill-typed program: rejected at compile time

Try to add when the top of the stack is a bool:

:::slide

## What if we push a bool and then add?

```ocaml skip
let bad_prog =
  let* () = push 4 in
  let* () = push true in  (* stack: bool * (int * unit) *)
  add                     (* add wants int * (int * 's) *)

let _ = run bad_prog ()
```

```text
Error: This expression has type
         (bool * (int * unit), 'a, 'b) pstate
       but an expression was expected of type
         (int * (int * 'c), 'd, 'e) pstate
       Type bool is not compatible with type int
```

- `add` wants two ints on top.
- After `push 4; push true`, the top is `bool`, not `int`.
- Compile-time error: the program will not even build.

:::

This is the parameterised-state-monad payoff. A "stack machine
that wants two ints on top to add" is a constraint that lives in
the *type* of the operation. The compiler enforces it before any
code runs, by matching the types in the pre-state and post-state
positions.

Compare this with the ordinary state monad in
[Lecture 5](M08-L05-state-monad.html): there, the state type was a
single `'s`, and any "this operation needs a specific stack shape"
constraint would have been a runtime check (or impossible to
express). Parameterised state moves the check to the type level.

## Where this idea shows up

The parameterised-state monad is what underlies several real
systems where "the next step depends on the current shape":

:::slide

## Where parameterised state matters

- **WebAssembly**: operational semantics defines well-typedness
  via per-instruction pre- and post-stack types. Same idea, with
  a formal type system.
- **Session types**: tracking protocol state at compile time. A
  TCP-like client cannot `send` before `connect`.
- **Typed builders**: a query builder where the type tracks "we
  have specified WHERE but not ORDER BY", and the next operation
  is constrained accordingly.
- **Typestate** in some languages (Rust, Pony): exactly this
  pattern, named differently.

:::

In each of these the parameterised-monad shape is "this operation
takes a value in some state and returns a value in a (possibly
different) state". The state lives in the types; the compiler
enforces the protocol.

## Bridge: this is what GADTs formalise

There is a clear parallel between what we just did and what GADTs
(next lecture) will let us do more cleanly.

:::slide

## Bridge to GADTs

- Parameterised state encodes preconditions in *type parameters*
  of a function type.
- GADTs encode preconditions in *type parameters of a
  constructor*.
- Both say: "the type witnesses what state we are in."
- GADTs are the proper machinery for this pattern.
- We informally previewed GADT-style refinement here; we make it
  rigorous in [L07](M08-L07-gadts-basics.html).

:::

The stack machine above is one step short of being a GADT. The
state type *is* a witness for the shape of the stack at this point
in the chain. In [L07](M08-L07-gadts-basics.html) we will see
constructors that carry similar witnesses inline, and pattern
matching that refines them. The next two lectures formalise what
we just did informally.

## A quick check

:::quiz mcq id=M08-L06-q3
What is the type of `push 5 : ('s, 'post, unit) pstate`? What is
`'post`?

- [ ] `'post = 's`.
- [x] `'post = int * 's`.
- [ ] `'post = unit`.
- [ ] `'post = 'a * 's` for any `'a`.

**Why:** `push x` takes a value `x` and produces a stack with `x`
on top. The post-state type adds an `int` (specifically) to the
front of the input state. Because we pushed `5 : int`, the new
state is `int * 's`. If we had pushed `true : bool`, it would be
`bool * 's`.
:::

:::quiz mcq id=M08-L06-q2
Why does the ill-typed `let* () = push true in add` fail at
compile time rather than runtime?

- [ ] OCaml runs the type checker at runtime for safety.
- [x] The type of `add` says the input state must be `int * (int *
  's)`. After `push true`, the input state is `bool * 's`. The
  compiler refuses to match `bool` against `int`.
- [ ] The bool is allocated dynamically.
- [ ] `add` raises an exception immediately.

**Why:** the parameterised-state monad encodes the precondition of
each operation in its type signature. `add`'s signature says "I
take a state shaped like `int * (int * 's)`". The compiler reads
that and rejects any preceding chain that does not produce such a
state. There is no runtime check; the error is caught at compile
time.
:::

## Activity

:::slide

## Activity

Extend the stack machine with a `mul` operation that multiplies
the top two `int`s on the stack and pushes the product. Show a
program that pushes 2, then 3, multiplies (top is now 6), then
pushes 10 and adds (top is now 16).

:::

:::solution

:::slide

## Activity solution: setup and mul

```ocaml
type ('pre, 'post, 'a) pstate = 'pre -> 'post * 'a
let preturn x : ('s, 's, 'a) pstate = fun s -> (s, x)
let pbind (m : ('p, 'q, 'a) pstate) (f : 'a -> ('q, 'r, 'b) pstate)
  : ('p, 'r, 'b) pstate =
  fun s ->
    let (s', a) = m s in
    (f a) s'
let ( let* ) = pbind
let push (x : 'a) : ('s, 'a * 's, unit) pstate =
  fun s -> ((x, s), ())
let add : (int * (int * 's), int * 's, unit) pstate =
  fun (x, (y, s)) -> ((x + y, s), ())
let run (m : ('pre, 'post, 'a) pstate) (s : 'pre) : 'post * 'a = m s

let mul : (int * (int * 's), int * 's, unit) pstate =
  fun (x, (y, s)) -> ((x * y, s), ())
```

- `mul` has the same shape as `add`: takes `int * (int * 's)`,
  returns `int * 's`, value `unit`.
- The constraint "top two are ints" is in the type.

:::

:::

:::solution

:::slide

## Activity solution: a longer program

```ocaml
let prog =
  let* () = push 2 in
  let* () = push 3 in
  let* () = mul in
  let* () = push 10 in
  add

let _ = run prog ()
```

`((16, ()), ())`.

- After `push 2`: stack `(2, ())`.
- After `push 3`: stack `(3, (2, ()))`.
- After `mul`: stack `(6, ())`.
- After `push 10`: stack `(10, (6, ()))`.
- After `add`: stack `(16, ())`.

The chain of state types lines up every step.

:::

:::

A code quiz:

:::quiz code id=M08-L06-q1
Add a `dup` operation that duplicates the top of the stack. It
should take an `'a * 's` state and produce an `'a * ('a * 's)`
state. Then write a program that pushes 7, duplicates it, and
adds.

```ocaml
type ('pre, 'post, 'a) pstate = 'pre -> 'post * 'a
let preturn x : ('s, 's, 'a) pstate = fun s -> (s, x)
let pbind (m : ('p, 'q, 'a) pstate) (f : 'a -> ('q, 'r, 'b) pstate)
  : ('p, 'r, 'b) pstate =
  fun s ->
    let (s', a) = m s in
    (f a) s'
let ( let* ) = pbind
let push (x : 'a) : ('s, 'a * 's, unit) pstate =
  fun s -> ((x, s), ())
let add : (int * (int * 's), int * 's, unit) pstate =
  fun (x, (y, s)) -> ((x + y, s), ())
let run (m : ('pre, 'post, 'a) pstate) (s : 'pre) : 'post * 'a = m s

let dup : ('a * 's, 'a * ('a * 's), unit) pstate =
  fun _ -> failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  let prog =
    let* () = push 7 in
    let* () = dup in
    add
  in
  let (final_stack, ()) = run prog () in
  let (top, ()) = final_stack in
  check (top = 14) "7 + 7 = 14";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let dup : ('a * 's, 'a * ('a * 's), unit) pstate =
  fun (x, s) -> ((x, (x, s)), ())
```

Take the input stack `(x, s)`, return the new stack `(x, (x, s))`
with `x` duplicated on top. The type signature says "input has
top `'a`; output has two `'a`s on top". `add` then works because
the duplicated `7`s have type `int`, matching what `add` expects.

:::

## What is next

:::slide

## What is next

Lecture 7: **GADTs**, formalising the type-refinement pattern.

- Variants whose constructors carry their own type indices.
- Pattern matching that refines the index per branch.
- Same idea as the stack-machine state types, made first-class.

:::

The [next lecture](M08-L07-gadts-basics.html) starts the GADT
half of the module. The parameterised-state-monad pattern we just
saw will reappear there in a more rigorous form: GADT constructors
carry type witnesses, pattern matching refines those witnesses,
and the compiler tracks state-like information through expressions
naturally.

## Reading

- **Cornell CS3110**, *Monads*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>

## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. The parameterised-state-monad framing and the
stack-machine encoding draw on the CS3100 monads notebook
(`_references/cs3100_m20/lectures/lec15_monads/`), used here as a
private structural reference; the surface code, comments, and
explanations are written from scratch. Cornell CS3110 and Real
World OCaml are CC BY-NC-ND-licensed and have not been
derivatively reused. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
