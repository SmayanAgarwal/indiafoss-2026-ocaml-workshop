---
title: "Mutable references"
lecture_no: 1
week: 7
duration_target_min: 22
concepts: [mutation, ref, !, :=, side effects, when to use mutation]
keywords: [OCaml, ref, mutation, side effects, !, :=]
activity_question: "Write a function [make_counter : unit -> (unit -> int)] that returns a closure giving the next integer each time it's called: [1; 2; 3; ...]."
think_about_this: "OCaml is functional-first but supports mutation via [ref]. When you reach for mutation, what property are you giving up? When does the trade pay off?"
reading:
  - title: "Cornell CS3110, References"
    url: https://cs3110.github.io/textbook/chapters/mut/refs.html
---

# Mutable references


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Mutable references</h2>
<p class="title-slide-label">Module 7 &middot; Lecture 1</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

For six modules we have written OCaml without using mutation. Every
value has been immutable; whenever we needed a new state, we made a
new value, with [`let` shadowing](M02-L02-let-bindings.html) the
old name or building a fresh list, record, or tuple. This is the
*functional* style and it has real benefits: any expression `f x`
produces the same answer regardless of when in the program you run
it, so reasoning about code reduces to
[substituting values for names](M01-L02-why-fp.html#equational-reasoning),
and the compiler can inline and reorder freely.

But mutation is, sometimes, the right tool. A statistics routine
walks a stream of numbers and updates a running sum. A web server
counts how many requests it has handled. A memoization table caches
results across calls. None of these are *impossible* to express
without mutation, but threading the state through every call by
hand makes the code longer and noisier than it needs to be. OCaml,
unlike a purely-functional language such as [Haskell](https://www.haskell.org/),
takes the position that mutation should be available when you want
it but should not be the default. The simplest mechanism the
language offers for opting in is the *mutable reference cell*, or
`ref` for short. This module is about `ref` and the other
mutable building blocks (mutable record fields, arrays), and about
when reaching for them is worth what you give up.

## A ref is a mutable box

```ocaml
let counter = ref 0

let () = counter := 1
let () = counter := 2
let _ = !counter
```

Three operators, three roles. `ref x` *creates* a fresh mutable
cell holding the value `x`; the expression evaluates to a reference
to that cell, of type `int ref`. The operator `:=` *writes* a new
value into the cell. The operator `!` *reads* the current value
out. The toplevel reports `int = 2`, the contents after the last
write.

:::slide

## A `ref` is a mutable box

```ocaml
let counter = ref 0

let () = counter := 1
let () = counter := 2
let _ = !counter
```

`int = 2`.

- `ref x` creates a mutable cell holding `x`.
- `!cell` reads the current value (dereferencing).
- `cell := y` writes a new value into the cell.
- The cell itself has type `int ref`.
- The contents (`!counter`) have type `int`.

:::

The unusual thing for a programmer arriving from C or Python is
that *creation*, *read*, and *write* each get their own syntax.
In C you write `int counter = 0` to create and `counter = 1` to
update; in Python `counter = 0` does both, with the second `=`
deciding from context that it is an update. OCaml separates the
three because, under the hood, they really are three different
operations: `ref` allocates a cell on the heap, `:=` mutates a cell
that already exists, and `!` reads from a cell. C makes the same
distinction implicitly with pointers (`malloc` allocates, `*p = 1`
writes, `*p` reads), and OCaml's `ref` is essentially a
heap-allocated single-cell pointer with named operations.

:::slide

## Why three operators?

In C and Python, you'd write `counter = 1` for both creation and
update. OCaml separates them:

- **Creation**: `let counter = ref 0` binds a *name* to a *fresh
  cell* containing 0.
- **Read**: `!counter` reads from the cell.
- **Write**: `counter := 1` writes to the cell.
- C makes this same distinction implicitly with pointers: `malloc`
  creates, `*p = 1` writes, `*p` reads.
- OCaml just makes it explicit at the syntax level.

:::

One small note about syntax: the `!` in `!counter` is the
dereference operator, *not* boolean negation. Boolean negation is
the function `not`, not a symbol. This is the same `!`/`not` split
that ML-family languages have shared since [Standard ML](https://smlfamily.github.io/),
and the choice is deliberate: the dereference is the more common
operation by far on a ref, so it gets the short symbol.

## The cost of mutation: equational reasoning

Here is the price you pay when you reach for a `ref`.

```ocaml
let counter = ref 0
let get_next () = counter := !counter + 1; !counter

let _ = get_next ()
let _ = get_next ()
let _ = get_next ()
```

The toplevel reports `1`, then `2`, then `3`. The same expression
`get_next ()` produces three different answers in succession. There
is no way to predict the answer of a call to `get_next ()` without
knowing how many times it has been called before.

:::slide

## Mutation breaks equational reasoning

```ocaml
let counter = ref 0
let get_next () = counter := !counter + 1; !counter

let _ = get_next ()
let _ = get_next ()
let _ = get_next ()
```

`1`, `2`, `3`.

- `get_next ()` is *not* equal to `get_next ()`.
- First call returns 1, second returns 2.
- You can't replace a call by its result without changing behaviour.
- **The cost of mutation**: the equational reasoning we had with
  pure functions (Module 2) is gone for code that touches a `ref`.

:::

Contrast with a pure function. If `let f x = x + 1`, then `f 3` is
always `4`. You can replace any occurrence of `f 3` in the program
with `4` and nothing changes: the behaviour is the same, the
performance is the same. This
[*equational* property](M01-L02-why-fp.html#equational-reasoning)
is what makes pure code easy to reason about. You think of a function
call as naming a value, the way `pi` names `3.14159`, and you can
substitute freely.

Mutation gives that up. `get_next ()` is not the name of a value;
it is the name of an *action*. The action consults a shared mutable
state, modifies it, and returns the new state. Two textually
identical calls can produce different results. You can no longer
inline a call to `get_next ()` without thinking about whether the
inlining changes how many times the function is called.

This is why OCaml is *functional-first*. The default discipline is
to write pure code, where equational reasoning holds, and to
isolate mutation behind a small surface area when it is needed. We
will come back to "what surface area" at the end of the lecture.

## When ref is the right tool

A non-exhaustive list of cases where reaching for a `ref` is
defensible.

:::slide

## When `ref` is the right tool

- **Imperative-flavoured loops:** counters, accumulators.
- **Caches:** memoization tables across calls.
- **Recursive references:** rare but possible.
- **Mutation interop:** callbacks, GUI state.
- Most everyday OCaml uses no `ref`s; reach only when the
  alternative is awkward.

:::

**Counters and accumulators.** When you are stepping through a
sequence and the natural shape of the algorithm is "for each
element, update this variable," a `ref` is fine. We will see in
the next lecture that `for` loops in OCaml usually go hand in hand
with refs and arrays: this is the imperative corner of the
language, and you use it where the algorithm wants it.

**Caches.** A memoization table that maps inputs to previously
computed outputs grows across calls. A [`Hashtbl.t`](https://v2.ocaml.org/api/Hashtbl.html)
is itself mutable; you reach for it directly without wrapping in a
`ref`. A small inline cache, on the other hand, is often a `ref` of
an [option](M04-L05-option-and-aliases.html#the-option-type) or a list.

**Recursive references.** Building a cyclic structure (a graph
with cycles, a doubly-linked list, a function that needs to refer
to a not-yet-defined function) often uses a `ref` as the
backpatch point. The technique is sometimes called *tying the
knot*: create a placeholder ref, build the structure that uses
the ref, then update the ref to point at the real value. We will
not need this in the course, but it is part of what `ref` makes
possible.

**Interop.** Code that talks to GUI toolkits, network callbacks,
or any C library expects to push state into the world rather than
return it from a function. A `ref` (or a mutable record field, or
a hash table) is how OCaml participates in that world.

For most everyday OCaml code, *none* of these apply, and the
function you are writing has no `ref`s at all. Reach for `ref`
when the alternative is awkward, not as a default.

## A small example: a one-shot

Here is a pattern where mutation is genuinely the cleanest
expression: a closure that does something the first time it is
called and nothing thereafter.

```ocaml
let make_once () =
  let used = ref false in
  fun () ->
    if !used then None
    else begin
      used := true;
      Some "first call"
    end

let f = make_once ()
let _ = f ()
let _ = f ()
let _ = f ()
```

The first call returns `Some "first call"`. Subsequent calls all
return `None`. The mutable state `used` is hidden inside the
closure: there is no way to reach it from the outside. Each call
to `make_once` produces a fresh, independent one-shot.

:::slide

## A small example: a one-shot

```ocaml
let make_once () =
  let used = ref false in
  fun () ->
    if !used then None
    else begin
      used := true;
      Some "first call"
    end

let f = make_once ()
let _ = f ()
let _ = f ()
let _ = f ()
```

`Some "first call"`, `None`, `None`.

- The closure captures `used`; first call sets it, later calls see it.
- **Private mutable state inside a function**: a clean use of `ref`.

:::

The pattern is *private mutable state inside a closure*. The state
is invisible to callers; they can only observe its effects through
the function's behaviour. From the outside, `f ()` looks like a
function that happens to return `None` on the second and later
calls. The fact that it does so via a mutable flag is an
implementation detail.

This same pattern, scaled up, is how many imperative languages
build *objects*: an object is essentially a record of closures
that share some private mutable state. Smalltalk and JavaScript
make the connection explicit; in OCaml, the building blocks are
exposed and you put them together as needed.

## A ref is a record with one mutable field

Once you see what a `ref` does, the implementation is not
mysterious. The standard library defines `'a ref` as:

```ocaml skip
type 'a ref = { mutable contents : 'a }
```

It is a one-field record with that field marked `mutable`. The
operators `!` and `:=` are just shorthand for accessing and
updating that field:

- `!r` is `r.contents`.
- `r := x` is `r.contents <- x`.

The `<-` operator is the assignment operator for mutable record
fields. We will see it again in
[the next lecture](M07-L02-arrays-and-mutation.html#mutable-record-fields)
when we look at mutable records in their own right.

:::slide

## A `ref` is just a record with one mutable field

The type `'a ref` is literally:

```ocaml skip
type 'a ref = { mutable contents : 'a }
```

The operators `!` and `:=` are just shorthand:

- `!r` is `r.contents`.
- `r := x` is `r.contents <- x`.
- `ref` is **not a magic builtin**: a record with one mutable field.

:::

:::slide

## Use a `mutable` field directly when it reads better

```ocaml
type counter = { mutable n : int }

let c = { n = 0 }
let () = c.n <- c.n + 1
let () = c.n <- c.n + 1
let _ = c.n
```

`int = 2`. The `<-` is the assignment operator for mutable record
fields.

:::

For named mutable state, the record form is often more readable:
`c.n <- c.n + 1` reads like an imperative assignment. The `ref`
form, with `!` and `:=`, is more concise when you have a single
cell. Both compile to the same thing.

## Sequencing side effects with semicolon

Several side-effecting actions in a row are sequenced with `;`,
the *statement* semicolon (which is a different token from `;;`,
the toplevel terminator that you only need in `utop` and `ocaml`
sessions).

```ocaml
let r = ref 0

let () =
  r := 1;
  r := 2;
  r := 3
```

The expression `e1 ; e2` evaluates `e1`, throws its result away,
then evaluates `e2` and returns *its* result. There is no syntactic
limit on the chain: `e1 ; e2 ; e3 ; e4` evaluates each in order and
returns the last.

:::slide

## Sequencing side effects

Several side-effecting actions in a row are sequenced with `;`
(the *statement* semicolon, distinct from `;;`):

```ocaml
let r = ref 0

let () =
  r := 1;
  r := 2;
  r := 3
```

- Each `;` says "do this, then that".
- The left-hand side of each `;` must have type `unit` (the value
  `()`).
- A non-unit expression in sequence (`r := 1; 5; r := 2`) triggers
  a warning: the value `5` is being thrown away.
- Wrap it in `let _ = 5` or `ignore 5` to silence.

:::

For this to be useful, every expression in the chain except the
last must produce `unit`. If you put something like `5` in the
middle of a sequence, the compiler warns that the value is being
discarded; the program runs, but the warning is right that you
probably meant something else. To silence the warning when the
discard is intentional, wrap the expression in `ignore`:
`ignore 5` evaluates to `()` and explicitly throws away whatever
`5` was.

The `begin ... end` and `(...)` brackets group a sequence into
one expression, which we sometimes need when a sequence appears
in the branch of an `if`. We saw this in
[M03-L02](M03-L02-recursion.html) when writing `count_down`.

## incr and decr

A ref of `int` is so common that the standard library gives you two
shortcuts:

```ocaml
let n = ref 0

let () = incr n
let () = incr n
let () = incr n
let _ = !n
let () = decr n
let _ = !n
```

`incr r` is shorthand for `r := !r + 1`; `decr r` is shorthand for
`r := !r - 1`. They are mildly more readable in counter-style code.
Otherwise the difference is cosmetic.

## A quick check

:::quiz mcq id=M07-L01-q3
What is the type of `ref "hello"`?

- [ ] `string`
- [x] `string ref`
- [ ] `string * int`
- [ ] `'a ref`

**Why:** `ref` is a function (well, a constructor) of type `'a ->
'a ref`. Applied to a `string`, it returns a `string ref`. The
contents are `"hello"`; the reference is a fresh cell holding that
string.
:::

:::quiz mcq id=M07-L01-q2
What does this print?

```ocaml
let r = ref 0
let () = r := 5
let () = r := !r + 1
let _ = !r
```

- [ ] `0`
- [ ] `5`
- [x] `6`
- [ ] error

**Why:** create cell holding `0`. Write `5`; cell now holds `5`.
Compute `!r + 1`, which reads `5` and adds `1` to get `6`. Write
`6` back into the cell. Final read returns `6`.
:::

## Aliasing: two names for one cell

Because a `ref` is a heap-allocated cell, you can have two names
that refer to *the same* cell. Mutating through one name mutates
what the other name sees.

```ocaml
let x = ref 42
let y = x
let () = x := 99
let _ = !x
let _ = !y
```

Both `!x` and `!y` return `99`. The `let y = x` did not copy the
cell; it bound a new name to the same cell. Both names refer to
the same place in memory.

If you actually want two independent cells with the same initial
value, you have to create two cells:

```ocaml
let x = ref 42
let y = ref 42
let () = x := 99
let _ = !x
let _ = !y
```

Now `!x` is `99` and `!y` is `42`. Each `ref 42` evaluation is a
fresh allocation.

This *aliasing* is the source of much of the difficulty of
imperative programming. Anywhere a `ref` (or any mutable value)
escapes a function, there is now a question of "who else has a
handle on this cell, and what might they do to it?" In a pure
functional setting, the question does not arise because there is
nothing to share. With mutation, every API has to decide what its
caller is allowed to do with the values it returns.

## Where you put `let ref` matters

A small bug whose shape recurs constantly in larger code.

Suppose we want a ticket dispenser: a zero-argument function whose
first call returns `1`, second returns `2`, and so on. A first
attempt:

```ocaml
let dispense_broken () =
  let n = ref 0 in
  incr n;
  !n

let _ = dispense_broken ()
let _ = dispense_broken ()
let _ = dispense_broken ()
```

Expected: `1`, `2`, `3`. Actual: `1` every time.

Trace through one call. The body runs as a fresh evaluation: `let
n = ref 0` allocates a new `ref` cell with value `0`; `incr n`
bumps that cell to `1`; `!n` reads `1` back. The cell was *local*
to this call, so it has nothing to do with any cell from a previous
call. Each call starts over from zero.

The fix is to hoist the `let n = ref 0` *out* of the function so
that the cell is allocated once, when the function is defined, and
the function value closes over it:

```ocaml
let dispense =
  let n = ref 0 in
  fun () ->
    incr n;
    !n

let _ = dispense ()
let _ = dispense ()
let _ = dispense ()
```

Now there is one cell, allocated at definition time, captured by
the closure. Successive calls hit the same cell. The toplevel
reports `1`, `2`, `3`.

The lesson generalises: a `let` *inside* a function body runs on
every call; a `let` outside, captured by closure, runs once. With
immutable bindings the distinction rarely matters; with `ref` it
decides whether your state survives between calls.

## Activity

:::slide

## Activity

Write `make_counter : unit -> (unit -> int)` that returns a closure
yielding the next integer on each call: first call returns `1`,
second `2`, third `3`, and so on.

:::

:::quiz code id=M07-L01-q1
Write `make_counter : unit -> (unit -> int)` that returns a closure
yielding the next integer on each call.

```ocaml
let make_counter () =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  let next = make_counter () in
  check (next () = 1) "first call";
  check (next () = 2) "second call";
  check (next () = 3) "third call";
  let other = make_counter () in
  check (other () = 1) "fresh counter starts at 1";
  check (next () = 4) "original counter independent";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```ocaml
let make_counter () =
  let n = ref 0 in
  fun () -> incr n; !n
```

:::

:::slide

## Activity solution

```ocaml
let make_counter () =
  let n = ref 0 in
  fun () -> incr n; !n

let next = make_counter ()
let _ = next ()
let _ = next ()
let _ = next ()
```

`1`, `2`, `3`.

- The closure captures `n`; each call increments and reads.
- `incr n` is shorthand for `n := !n + 1`; `decr` is the other direction.

:::

:::slide

## Two counters have independent state

```ocaml
let make_counter () =
  let n = ref 0 in
  fun () -> incr n; !n

let a = make_counter ()
let b = make_counter ()
let _ = a (), a (), a (), b (), b ()
```

`(1, 2, 3, 1, 2)`. Each call to `make_counter ()` allocates a fresh
`n` captured by a fresh closure; `a` and `b` don't share state.

:::

Each call to `make_counter ()` is a fresh allocation of `n`,
captured by a fresh closure. The two counters `a` and `b` are
*independent*: `a`'s `n` and `b`'s `n` are different cells. This
is the same [closure machinery from Module 3](M03-L01-functions-as-values.html),
with the captured value happening to be a mutable cell rather than
an integer.

## What's next

The [next lecture](M07-L02-arrays-and-mutation.html) extends the
mutation toolkit: mutable record fields (briefly) and *arrays*,
the fixed-size random-access mutable sequence.
[Lecture 3](M07-L03-exceptions.html) covers exceptions, the other
major form of "side effect" in OCaml. Together these three (refs,
arrays, exceptions) give you the imperative subset of the
language. Lectures [4](M07-L04-module-basics.html) through
[6](M07-L06-functors.html) turn to *modules*, the unit of
program structure: how OCaml organizes code at scale, hides
representation, and writes generic data structures via functors.
[Lecture 7](M07-L07-tutorial.html) is the tutorial.

:::slide

## What's next

Lecture 2: **mutable records and arrays**.

- Beyond the one-cell `ref`, OCaml has mutable fields on records
  (as we've seen).
- It also has fixed-size mutable arrays.
- Both are for code that genuinely needs in-place updates.

:::

## Reading

- **Cornell CS3110**, *References*:
  <https://cs3110.github.io/textbook/chapters/mut/refs.html>
- **Real World OCaml**, *Imperative Programming*:
  <https://dev.realworldocaml.org/imperative-programming.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
