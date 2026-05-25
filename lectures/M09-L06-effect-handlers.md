---
title: "Effect handlers for concurrency"
lecture_no: 6
week: 9
duration_target_min: 22
concepts: [effect handlers, user-defined effects, delimited continuations, perform, continue, deep handlers, control inversion, generators, exceptions as effects]
keywords: [OCaml, effect handlers, Effect.t, perform, continue, Effect.Deep, Effect.Shallow, delimited continuation, generator, scheduler, concurrency primitives, OCaml 5]
activity_question: "Take an effect [E : int Effect.t]. Inside a handler, after [continue k 7], the handler clause's body runs to completion and then... where does control go? What is the return type of [continue k v]?"
think_about_this: "Exceptions and effect handlers look syntactically similar (try ... with). What does perform/continue let you do that raise/catch does not?"
reading:
  - title: "OCaml manual, Effect handlers"
    url: https://v2.ocaml.org/manual/effects.html
  - title: "Sivaramakrishnan et al., Retrofitting Effect Handlers onto OCaml (PLDI 2021)"
    url: https://dl.acm.org/doi/10.1145/3453483.3454039
  - title: "Stephen Dolan, OCaml effect-handlers tutorial"
    url: https://github.com/ocaml-multicore/ocaml-effects-tutorial
---

# Effect handlers for concurrency


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Effect handlers for concurrency</h2>
<p class="title-slide-label">Module 9 &middot; Lecture 6</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The first half of this module was about *testing*. Now the
module turns toward *concurrency*: how to write OCaml programs
whose tasks interleave in time, and how to make those programs
testable. We need one new language feature to do that cleanly:
*effect handlers*, OCaml 5's mechanism for user-defined,
non-local control flow.

Effect handlers look superficially like exceptions: there is a
`try ... with` syntax, an effect is declared like an exception
constructor, and code "raises" the effect by calling `perform`.
The crucial difference is that an effect's handler can
*resume* the computation that performed it, optionally with a
return value. That single ability turns effects into a
general-purpose vocabulary for non-local control flow: they
subsume exceptions, generators, coroutines, async/await,
lightweight threads, and (the goal of this lecture and the
next) cooperative concurrency.

:::slide

## What this lecture covers

- The shape of OCaml 5 effect handlers: declaration,
  `perform`, the handler clause, `continue`.
- A worked example: exceptions, refactored to use effects, with
  one extra power.
- **State as effects**: `Get` and `Set` handled by a single
  scoped handler.
- **Generators by control inversion**: convert a push-based
  iterator into a pull-based generator.
- Why this matters for *testing concurrent code*: a handler is
  a scheduler we can pin down.

:::

## A motivating problem: failure recovery

Here is a small program in plain (M07-style) OCaml.

```ocaml skip
let rec sum_up acc =
  let l = input_line stdin in
  acc := !acc + int_of_string l;
  sum_up acc

let _ =
  let r = ref 0 in
  try sum_up r with
  | End_of_file -> Printf.printf "Sum is %d\n" !r
```

Read lines from `stdin`, parse each as an integer, accumulate
the sum, print on EOF. Simple. But what if a line is *not* a
valid integer? `int_of_string` raises `Failure`, and the program
crashes mid-stream, throwing away all the good lines that came
before.

:::slide

## A motivating problem

```ocaml skip
let rec sum_up acc =
  let l = input_line stdin in
  acc := !acc + int_of_string l;
  sum_up acc

let _ =
  let r = ref 0 in
  try sum_up r with
  | End_of_file -> Printf.printf "Sum is %d\n" !r
```

- Sum integers from stdin until EOF.
- One bad line: `int_of_string` raises, the loop is gone.
- Exceptions can *report* the error; they cannot *recover and
  continue*.

:::

The exception fix is familiar: wrap `int_of_string` in a
`try`/`with`, raise a custom exception on failure, catch that
exception at the top level and print a diagnostic. Once an
exception is caught, control returns *to the catch site*; we
cannot return *to the throw site* and continue the loop with a
recovered value. Recovery means restarting the loop from
scratch, or giving up.

```ocaml skip
exception Conversion_failure of string

let int_of_string l =
  try int_of_string l with
  | Failure _ -> raise (Conversion_failure l)

let _ =
  let r = ref 0 in
  try sum_up r with
  | End_of_file -> Printf.printf "Sum is %d\n" !r
  | Conversion_failure s ->
    Printf.fprintf stderr "Bad input: %s\n" s
    (* sum_up aborted; we lose the rest of the stream *)
```

We *want* to skip the bad line and keep going. Exceptions do not
let us do that, because `raise` discards the stack frame between
the throw and the catch. To skip and continue, we need to
*resume* the computation that raised, after the handler decides
how to recover.

That is precisely what effect handlers do.

:::slide

## What exceptions cannot do

- Read lines, sum the integers, recover from a non-integer.
- Exceptions: catch at the top, but the loop is gone (stack
  unwound).
- We want: handle the bad line, then *continue from where we
  were*, with a substitute value.
- Effects give us the missing power: the handler holds a
  *continuation* it can resume.

:::

## Effect-handler syntax in OCaml 5

Three pieces of new syntax.

**Declaration.** An effect is added to the extensible
`Effect.t` type, with the value it carries and the type it
returns:

```ocaml skip
open Effect
open Effect.Deep

type _ Effect.t += Conversion_failure : string -> int Effect.t
```

`Conversion_failure` carries a `string` (the bad input) and,
when performed, *returns an `int`* (the substitute value the
handler will supply). Compare with the analogous exception:
`exception Conversion_failure of string` carries the same
string but returns nothing, because exceptions do not resume.

**Performing.** Inside a computation:

```ocaml skip
let int_of_string l =
  try int_of_string l with
  | Failure _ -> perform (Conversion_failure l)
```

`perform e` suspends the current computation and transfers
control to the nearest enclosing handler for `e`. The result of
`perform` (which has the type the effect declares, here `int`)
is whatever the handler supplies via `continue`.

**Handling.** A handler clause is added to a `try ... with`:

```ocaml skip
let _ =
  let r = ref 0 in
  try sum_up r with
  | End_of_file -> Printf.printf "Sum is %d\n" !r
  | effect Conversion_failure s, k ->
    Printf.fprintf stderr "Bad input: %s\n" s;
    continue k 0
```

`effect Conversion_failure s, k` binds two things: `s` is the
payload (the bad input), and `k` is the *delimited continuation*
of the computation that performed. `continue k 0` resumes that
continuation with `0` as the substituted return value of
`perform`. The loop picks up where it left off, with the bad
line replaced by zero, and the sum keeps growing.

:::slide

## Effect syntax: three pieces

```ocaml skip
type _ Effect.t += Conversion_failure : string -> int Effect.t

let int_of_string l =
  try int_of_string l with
  | Failure _ -> perform (Conversion_failure l)

let _ =
  try sum_up r with
  | End_of_file -> Printf.printf "Sum is %d\n" !r
  | effect Conversion_failure s, k ->
    Printf.fprintf stderr "Bad input: %s\n" s;
    continue k 0
```

- **Declaration**: extend `Effect.t` with payload + return type.
- **`perform`**: suspend, transfer to handler.
- **`effect ..., k -> continue k v`**: resume the computation
  with `v` as the substitute return value of `perform`.

:::

The pivotal observation: this exact program is the exception
version *plus the line* `continue k 0`. The handler now decides
not "abort the stream and report" but "skip this line and keep
summing." That power is what `try`/`with` always lacked.

:::slide

## The recovery, with effect handlers

```ocaml skip
type _ Effect.t += Conversion_failure : string -> int Effect.t

let int_of_string l =
  try int_of_string l with
  | Failure _ -> perform (Conversion_failure l)

let _ =
  try sum_up r with
  | End_of_file -> Printf.printf "Sum is %d\n" !r
  | effect Conversion_failure s, k ->
    Printf.fprintf stderr "Bad input: %s\n" s;
    continue k 0
```

- Same structure as the exception version.
- The single new line is `continue k 0`.
- That line is what makes recovery + continuation possible.

:::

## Tracing the control flow

Walk through what happens, line by line, on a small trace.
Suppose stdin is `"1"`, `"oops"`, `"3"`, EOF.

1. The outer handler is installed. `sum_up r` starts.
2. Line `"1"`: `int_of_string` succeeds. Sum becomes `1`.
   Recurse.
3. Line `"oops"`: `int_of_string` raises `Failure`, the inner
   `try` performs `Conversion_failure "oops"`.
4. The runtime walks up the stack to the nearest handler for
   `Conversion_failure`. It packages the part of the stack
   between the `perform` and the handler as a *delimited
   continuation* `k`.
5. The handler clause runs. It prints the diagnostic, then
   `continue k 0`.
6. `continue k 0` reinstates the stack frames in `k`, with `0`
   as the result of the `perform`. Execution proceeds from
   inside `int_of_string`: it returns `0`. The body of `sum_up`
   adds `0` to the sum, recurses.
7. Line `"3"`: succeeds. Sum becomes `4`.
8. EOF: `input_line` raises `End_of_file`. That is an
   *exception*, not an effect; it propagates up to the
   `End_of_file ->` clause of the same `try`. Print "Sum is
   4".

The handler clause is just a *match case*. The new vocabulary
is `effect ..., k` and `continue k v`. Everything else is
ordinary OCaml.

:::slide

## Tracing the control flow

Input: `"1"`, `"oops"`, `"3"`, EOF.

- "1" -> sum = 1.
- "oops" -> `perform (Conversion_failure "oops")`. Handler
  prints diagnostic, `continue k 0`.
- Computation resumes inside `int_of_string`; returns 0.
- "3" -> sum = 4.
- EOF -> the `End_of_file` exception clause prints "Sum is 4".

The handler held a *continuation* `k` and resumed it. That is
all the new vocabulary buys; it is enough to subsume coroutines,
generators, async/await, and schedulers.

:::

## State as effects

A more structural example. We model mutable state by declaring
*two* effects, `Get` and `Set`, and handling both with a single
local handler that holds the actual reference.

```ocaml skip
open Effect
open Effect.Deep

module State (T : sig type t end) : sig
  val get : unit -> T.t
  val set : T.t -> unit
  val run : T.t -> (unit -> 'a) -> T.t * 'a
end = struct
  type _ Effect.t += Get : T.t Effect.t
  type _ Effect.t += Set : T.t -> unit Effect.t
  let get () = perform Get
  let set v = perform (Set v)
  let run (init : T.t) f =
    let state = ref init in
    let res =
      try f () with
      | effect Get,     k -> continue k !state
      | effect (Set v), k -> state := v; continue k ()
    in
    (!state, res)
end
```

Read it. `State` is parameterised over the state type `T.t`.
Inside the functor, the two effects are declared (carrying
nothing for `Get`, a value for `Set`; the return types are
`T.t` and `unit`). `get ()` and `set v` are one-liners over
`perform`. `run init f` installs a handler around the
computation `f`, holding a local `state` reference. Each
`perform Get` is resumed with the current value; each `perform
(Set v)` updates the reference and resumes with `()`.

```ocaml skip
module IS = State (struct type t = int end)

let comp () =
  Printf.printf "initial: %d\n" (IS.get ());
  IS.set 42;
  Printf.printf "after set: %d\n" (IS.get ())

let () =
  let final, () = IS.run 0 comp in
  Printf.printf "final: %d\n" final
```

Output:

```ocaml skip
initial: 0
after set: 42
final: 42
```

`comp` reads like ordinary mutable code: `get`, `set`, `get`.
But there is no global state, no module-level `ref`, no
side-effecting primitive other than the user-defined effects.
The handler is the *only* place state lives, and the scope of
the state is exactly `IS.run`. Two calls to `IS.run` give two
independent state cells.

:::slide

## State as effects

```ocaml skip
module State (T : sig type t end) = struct
  type _ Effect.t += Get : T.t Effect.t
  type _ Effect.t += Set : T.t -> unit Effect.t
  let get () = perform Get
  let set v = perform (Set v)
  let run init f =
    let state = ref init in
    let res =
      try f () with
      | effect Get,     k -> continue k !state
      | effect (Set v), k -> state := v; continue k ()
    in
    (!state, res)
end
```

- Two effects: `Get` and `Set`.
- One handler holds the actual `ref`.
- The scope of the state is exactly `run`.

:::

This is a real example of *what effect handlers buy you over
plain `ref`s*: the state is *scoped*, not global; the handler is
the only place it can be mutated; testing the inner function in
isolation is a matter of supplying a different handler that
records, logs, or substitutes the values.

## Control inversion: from iterator to generator

The third worked example, and the one that points directly at
concurrency. An *internal iterator* (push-based) traverses a
tree and calls a callback for each element; the producer is in
control. A *generator* (pull-based) lets the consumer ask for
the next element on demand; the consumer is in control. They
encode the same data flow with opposite control flow.

Effect handlers convert one to the other mechanically.

```ocaml skip
open Effect
open Effect.Deep

type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let rec iter t f = match t with
  | Leaf -> ()
  | Node (l, x, r) -> iter l f; f x; iter r f

let to_gen (type a) (iter : (a -> unit) -> unit) =
  let module M = struct
    type _ Effect.t += Next : a -> unit Effect.t
  end in
  let open M in
  let rec step = ref (fun () ->
    try
      iter (fun x -> perform (Next x));
      None
    with effect (Next v), k ->
      step := (fun () -> continue k ());
      Some v)
  in
  fun () -> !step ()
```

Read carefully. `to_gen` takes an internal iterator (a function
that walks the structure and calls a callback for each element)
and returns a generator (a function of type `unit -> a option`
that returns `Some v` for each element in turn, then `None`).

The trick: inside the handler, when `iter` calls the callback
with element `x`, the callback performs `Next x`. The handler
captures the continuation `k` (which is "the rest of the
traversal"), stashes a thunk `fun () -> continue k ()` in
`step`, and returns `Some v`. On the next call to the
generator, the thunk runs, resuming the suspended traversal
until the next `perform (Next ...)`, which captures another
continuation, and so on. When the traversal finishes, the
inner `iter` returns `()`, the `match` clause for the value
returns `None`, and the generator is done.

```ocaml skip
let next = to_gen (iter example_tree) in
let rec go () =
  match next () with
  | None -> ()
  | Some v -> Printf.printf "  got %d\n" v; go ()
in
go ()
```

Each call to `next ()` pulls one element. The traversal suspends
between calls, and resumes when the consumer asks for the next.
This is exactly Python's generators / JavaScript's iterators,
implemented in OCaml in 15 lines, without any language-level
generator support. Effect handlers reduced the entire feature
to "perform an effect and let the handler stash a continuation."

:::slide

## Control inversion: iter -> generator

```ocaml skip
let to_gen (type a) (iter : (a -> unit) -> unit) =
  let module M = struct
    type _ Effect.t += Next : a -> unit Effect.t
  end in
  let step = ref (fun () ->
    try iter (fun x -> perform M.Next x); None
    with effect M.Next v, k ->
      step := (fun () -> continue k ());
      Some v)
  in fun () -> !step ()
```

- Internal iterator: producer-driven.
- Generator: consumer-driven.
- The handler stashes the continuation between calls.
- Same data, opposite control flow.

:::

The same trick generalises to async/await (the handler returns
a promise instead of `Some v`), to coroutines (the handler
schedules a different fiber instead of returning), and to
cooperative multitasking. We see the cooperative-multitasking
case explicitly in [Lecture 7](M09-L07-fibers-concurrency.html).

## Effects vs exceptions, side by side

A compact comparison.

| | `exception E` | `type _ Effect.t += E` |
|---|---|---|
| Carry a payload | yes | yes |
| Catch site | `try ... with E s -> ...` | `try ... with effect E s, k -> ...` |
| Can unwind the stack | yes | yes (don't call `continue`) |
| Can *resume* the perform site | **no** | **yes** (`continue k v`) |
| Can supply a return value to the raise | n/a | yes |
| Handler clause runs to completion | yes | yes (continue is a function call, not a return) |

The middle two rows are the heart of it. Exceptions can do
recovery as a *terminal* action; effects can do recovery as a
*continuation-passing* action.

:::slide

## Effects vs exceptions

| | exception | effect |
|---|---|---|
| Catch site | `with E s -> ...` | `with effect E s, k -> ...` |
| Unwind stack | yes | optional (don't `continue`) |
| **Resume the raise site** | no | **yes** (`continue k v`) |
| Supply a return value | n/a | yes |

- Effects are exceptions + the power to resume.
- Everything else (generators, async/await, schedulers) is
  built from that.

:::

## Deep vs shallow

`Effect.Deep` is the standard handler form: when you `continue
k`, the resumed computation runs under the *same* handler.
`Effect.Shallow` is the alternative: the resumed computation
is *outside* the handler, and any further effects must be
caught by a fresh handler.

For 95% of code (including this lecture and the next) `Deep`
is the right choice and the `effect ..., k` syntax above is
its sugar. `Shallow` is occasionally useful (one-shot
continuations, transformers), and it lives in `Effect.Shallow`
with similar shape. Stephen Dolan's tutorial in the Reading
goes into the comparison.

:::slide

## Deep vs shallow handlers

- **Deep** (`Effect.Deep`): after `continue`, code runs under
  the *same* handler. The `effect ..., k` syntax sugar.
- **Shallow** (`Effect.Shallow`): after `continue`, code runs
  *outside* the handler. A fresh handler must be installed for
  the next effect.
- 95% of effect-handler code uses `Deep`. We do not need
  `Shallow` in M09.

:::

:::slide

## Three handler-shaped patterns

| Pattern | Effects | Handler stores |
|---|---|---|
| Failure recovery | `Conversion_failure` | nothing |
| State | `Get`, `Set` | a `ref` |
| Generator | `Next x` | the suspended continuation |
| (Next: scheduler) | `Fork`, `Yield` | a queue of continuations |

Same vocabulary in each case: declare the effect, perform from
the computation, hold the continuation in the handler. The
*payload of the handler* (what it stores between effects)
changes; the syntax does not.

:::

## Why this matters for testing concurrent code

The pitch for this entire pair of lectures: effect handlers
make concurrency *testable*.

Two consequences.

**The scheduler is just a handler.** In [Lecture 7](M09-L07-fibers-concurrency.html)
we will declare two effects, `Fork` and `Yield`, and write a
handler that maintains a queue of suspended continuations.
`perform Yield` cooperatively gives up control to the next
fiber. `perform (Fork f)` enqueues a new fiber. The whole
scheduler is ~10 lines of OCaml. Different schedulers
(round-robin, priority-based, deterministic-for-test) all share
the same `Fork`/`Yield` interface; the implementation lives
entirely in the handler.

**Side effects are interceptable.** A function that wants to
print can `perform Print` instead of calling `print_endline`
directly. Under the production handler, `Print` calls
`print_endline`. Under the test handler, `Print` appends to a
list, and the test inspects the list. The function's source
does not change between production and test. This pattern is
the topic of the tutorial in [L08](M09-L08-tutorial.html),
where we stub the print effect for the M05-L06 evaluator so
that we can unit-test trace output.

:::slide

## Why effect handlers make concurrency testable

- The **scheduler is a handler.** Different schedulers (real,
  deterministic, replay) plug into the same `Fork`/`Yield`
  interface.
- **Side effects are interceptable.** A `Print` effect can
  call `print_endline` in production and append to a buffer
  in tests, without changing the source code.
- L07: a real scheduler using these ideas.
- L08: side-effect stubbing for testable interpreters.

:::

## Activity

:::quiz mcq id=M09-L06-q1
Consider the OCaml 5 fragment:

```ocaml skip
type _ Effect.t += E : string -> int Effect.t

let () =
  try
    let n = perform (E "hi") in
    Printf.printf "n = %d\n" n
  with
  | effect E s, k ->
    Printf.printf "got %s\n" s;
    continue k 42;
    Printf.printf "handler done\n"
```

What does the program print?

- [ ] `n = 42` only.
- [ ] `got hi` and `handler done` only.
- [ ] `got hi`, then `handler done`, then `n = 42`.
- [x] `got hi`, then `n = 42`, then `handler done`.

**Why:** `perform (E "hi")` suspends the computation that was
about to bind `n`. The handler clause prints `got hi`, then
`continue k 42`: the suspended computation resumes with `42` as
the value of `perform`, prints `n = 42`, and returns. Control
returns to the handler clause *after* `continue`, which then
prints `handler done`. The key insight: `continue k 42` is *not*
a tail call; the handler clause keeps running after the
continuation returns. This is the structural difference between
effects and exceptions.
:::

:::quiz mcq id=M09-L06-q2
Which of the following is *uniquely* enabled by effect handlers
and *cannot* be done with exceptions alone?

- [ ] Recovering from a runtime error and printing a diagnostic.
- [ ] Aborting a long computation early.
- [x] Resuming the computation that raised, after the handler
  has decided how to recover, with a substitute return value.
- [ ] Carrying a string payload from the raise site to the
  catch site.

**Why:** exceptions can carry payloads, can be caught at any
level of the stack, and can be used for early abort. What they
cannot do is *resume* the computation that raised, because
`raise` unwinds the stack. Effect handlers hold a delimited
continuation `k` and can `continue k v`, returning control to
the perform site with `v` as the substituted result. That is
the structural extension.
:::

:::quiz code id=M09-L06-q3
Declare an effect `Ask` that takes nothing and returns an
`int`. Inside a function `f : unit -> int`, perform `Ask` to
read a value, double it, and return the result. Then handle
`Ask` so that it always supplies `21`, and call `f`.

```ocaml skip
type _ Effect.t += (* TODO *)

let f () : int = (* TODO *)

let () =
  let open Effect in
  let open Effect.Deep in
  let n =
    try f ()
    with effect (* TODO *), k -> continue k 21
  in
  Printf.printf "n = %d\n" n  (* Expected: n = 42 *)
```
:::

:::solution

Reference solution:

```ocaml skip
open Effect
open Effect.Deep

type _ Effect.t += Ask : int Effect.t

let f () =
  let x = perform Ask in
  2 * x

let () =
  let n =
    try f ()
    with effect Ask, k -> continue k 21
  in
  Printf.printf "n = %d\n" n
```

Three lines of effect-relevant code: the declaration, the
`perform`, the handler clause. The function `f` reads as
ordinary OCaml; the handler decides what `Ask` answers.

:::

## Common pitfalls

**Pitfall 1: forgetting to open `Effect.Deep`.** Without it,
the `effect` keyword in match clauses is not in scope and the
program fails to parse.

**Pitfall 2: forgetting to `continue`.** A handler clause that
*does not* call `continue` aborts the computation that
performed (like an exception catch). Sometimes you want that
(it is the right behaviour for failure recovery in a top-level
handler), but if you intended to resume and forgot, the code
silently returns from the handler without running the rest.

**Pitfall 3: continuing twice.** OCaml 5's default
continuations are *one-shot*: calling `continue k v` a second
time raises `Continuation_already_resumed`. This is a runtime
error, not a type error.

**Pitfall 4: the handler clause runs *after* `continue`.**
Code after `continue k v` in the handler body runs once the
resumed computation returns. New programmers often write
`continue k 42` as if it were a tail-call return. It is not;
it is a function call.

**Pitfall 5: confusing effects with exceptions.** Effects use
`Effect.t`, not `exn`. Use `perform` to invoke an effect, not
`raise`. The OCaml manual treats them as distinct constructs.

:::slide

## Common pitfalls

1. Forgetting `open Effect.Deep`: `effect` clause does not
   parse.
2. Forgetting to `continue`: handler aborts the computation
   silently.
3. Continuing twice: runtime error
   `Continuation_already_resumed`.
4. `continue k v` is *not* a tail return: code after it runs
   once the resumed computation returns.
5. Effects use `Effect.t`, not `exn`.

:::

## What's next

[Lecture 7](M09-L07-fibers-concurrency.html) puts effect
handlers to use building a real concurrency library: fibers
(lightweight threads), channels (typed message passing), and a
scheduler. The whole library is ~50 lines, all built from the
`Fork`/`Yield`/`Await` effects we sketched above. The library
is testable in the sense that its schedule is *deterministic*:
the same fiber sequence with the same scheduler always produces
the same outcome.

[Lecture 8](M09-L08-tutorial.html) returns to the testing
theme and uses effect handlers to *stub* side effects in the
M05-L06 evaluator, making the interpreter unit-testable in
isolation.

:::slide

## What's next

- L7: **fibers and lightweight concurrency.** A small Go-style
  library: fork + yield + channels, scheduler in 10-50 lines.
- L8: **testing-with-handlers.** Stubbing print + input
  effects in the M05-L06 evaluator.

:::

## Reading

- **OCaml manual**, *Effect handlers*. The authoritative
  reference for the syntax and semantics:
  <https://v2.ocaml.org/manual/effects.html>
- **Sivaramakrishnan, Dolan, White, et al.**, *Retrofitting
  Effect Handlers onto OCaml*, PLDI 2021. The paper that
  introduced effect handlers into mainstream OCaml:
  <https://dl.acm.org/doi/10.1145/3453483.3454039>
- **Stephen Dolan**, *OCaml effect-handlers tutorial*. A
  hands-on walkthrough with progressively richer examples:
  <https://github.com/ocaml-multicore/ocaml-effects-tutorial>

## Sources

This lecture's prose, worked examples, and quizzes are original
to this course. The `sum_up` recovery example, the State-as-effect
module, and the iterator-to-generator inversion are from the
CS6868 *Concurrent Programming* course at IIT Madras (lecture
09, KC Sivaramakrishnan, Spring 2026); they are folkloric
patterns in the effect-handlers community, presented here in
slightly compressed form. The OCaml manual's effect-handler
chapter, and the public ocaml-effects-tutorial repository, are
linked above for further reading; no prose has been
derivatively reused. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
