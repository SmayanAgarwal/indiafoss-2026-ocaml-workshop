---
title: "Fibers and lightweight concurrency"
lecture_no: 7
week: 9
duration_target_min: 20
concepts: [fibers, lightweight threads, cooperative concurrency, scheduler, channels, trigger, ivar, structured concurrency, deterministic scheduling]
keywords: [OCaml, effect handlers, fibers, scheduler, Fork, Yield, channels, trigger, ivar, async, await, promise, lightweight threads, goroutines, multicore]
activity_question: "Two fibers, A and B, each print three characters with a yield between them. With a FIFO scheduler that starts A first, what is the exact output? Why is that output the same on every run?"
think_about_this: "OCaml 5 has true parallelism through Domains. Why is a *uniprocessor* fiber scheduler still a useful first step, especially for testing? What would we lose by jumping straight to a multicore scheduler?"
reading:
  - title: "OCaml manual, Effect handlers"
    url: https://v2.ocaml.org/manual/effects.html
  - title: "Eio: effect-handler-based direct-style concurrency"
    url: https://github.com/ocaml-multicore/eio
  - title: "Stephen Dolan, OCaml effect-handlers tutorial: scheduler"
    url: https://github.com/ocaml-multicore/ocaml-effects-tutorial
---

# Fibers and lightweight concurrency


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Fibers and lightweight concurrency</h2>
<p class="title-slide-label">Module 9 &middot; Lecture 7</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

[Lecture 6](M09-L06-effect-handlers.html) gave us the new
control-flow vocabulary: declare an effect, perform from a
computation, suspend the computation in a handler that holds
its continuation, and `continue` later to resume. We saw that
vocabulary express failure recovery, state, and generators. The
last of those was already most of the way to concurrency: a
generator is a coroutine that yields between two parties.

This lecture takes the final step. We build a small Go-style
concurrency library: lightweight threads called *fibers*,
typed inter-fiber communication called *channels*, a *trigger*
primitive for one-shot wakeups, and an *IVar* for write-once
read-many synchronisation. Each piece is a handful of lines on
top of the effect-handler vocabulary. The whole library is
~80 lines of OCaml.

We deliberately stay on a *single core*: one OS thread, fibers
interleaved by the scheduler we own. This makes the schedule
*deterministic*: same program, same input, same output, every
run. That property is what makes the library testable.
Multicore parallelism (real Domain-level threads, lock-free
data structures) follows in a future course.

:::slide

## What this lecture covers

- **Fibers**: lightweight threads on a single OS thread.
- **The scheduler**: a handler for `Fork`, `Yield`, and
  `Trigger.Await`.
- **Channels**: typed FIFO message passing between fibers.
- **IVar + Trigger**: write-once read-many, with blocking on
  read.
- **Async/await** built on top.
- **Deterministic schedules** as the basis for testable
  concurrent code.

:::

## A motivating example: cooperative interleaving

Suppose we want two computations to take turns. The first
prints `"A "` three times; the second prints `"B "` three
times; we want the output `"A B A B A B"` rather than `"A A A
B B B"`. With OS threads we would need synchronisation
primitives; the schedule would still be non-deterministic.

With fibers, we declare `Fork` and `Yield` effects, write
each computation to yield between print operations, and let
a scheduler interleave them. The same scheduler always picks
the same fiber next, so the output is the same every run.

```ocaml skip
Sched.run (fun () ->
  Sched.fork (fun () ->
    Printf.printf "A "; Sched.yield ();
    Printf.printf "A "; Sched.yield ();
    Printf.printf "A ");
  Sched.fork (fun () ->
    Printf.printf "B "; Sched.yield ();
    Printf.printf "B "; Sched.yield ();
    Printf.printf "B "))
```

Output: `A B A B A B`. Same output every run, because the
scheduler is deterministic.

:::slide

## Cooperative interleaving

```ocaml skip
Sched.run (fun () ->
  Sched.fork (fun () ->
    print_string "A "; Sched.yield ();
    print_string "A "; Sched.yield ();
    print_string "A ");
  Sched.fork (fun () ->
    print_string "B "; Sched.yield ();
    print_string "B "; Sched.yield ();
    print_string "B "))
```

- Two fibers, each yields between prints.
- Output: `A B A B A B`, every run.
- No OS threads. No synchronisation. Determinism is automatic.

:::

## The fiber scheduler in 25 lines

Here is the whole `Sched` module:

```ocaml skip
open Effect
open Effect.Deep

type _ Effect.t += Fork  : (unit -> unit) -> unit Effect.t
type _ Effect.t += Yield : unit Effect.t

let fork f  = perform (Fork f)
let yield () = perform Yield

let run main =
  let run_q = Queue.create () in
  let enqueue k = Queue.push k run_q in
  let dequeue () =
    if Queue.is_empty run_q then ()
    else continue (Queue.pop run_q) ()
  in
  let rec spawn f =
    match f () with
    | () -> dequeue ()
    | exception e ->
        Printf.eprintf "Uncaught: %s\n" (Printexc.to_string e);
        dequeue ()
    | effect Yield, k ->
        enqueue k;
        dequeue ()
    | effect (Fork f), k ->
        enqueue k;
        spawn f
  in
  spawn main
```

Read it. Two effects (`Fork` and `Yield`), three helper
functions (`fork`, `yield`, `dequeue`), and the recursive
`spawn`. The handler clauses are the heart:

- **`effect Yield, k`**: enqueue the current continuation and
  run the next fiber from the queue.
- **`effect (Fork f), k`**: enqueue the current continuation
  (so the parent fiber will resume after the new one starts)
  and spawn the new fiber `f`.
- **Normal return**: the current fiber finished; run the next
  one from the queue. When the queue is empty, `run` returns.

There is no OS-level thread, no `pthread_create`, no
synchronisation primitive. Each fiber is a suspended OCaml
function with a captured continuation; the scheduler decides
when to resume it. The whole thing is single-threaded and
deterministic.

:::slide

## The fiber scheduler

```ocaml skip
type _ Effect.t += Fork  : (unit -> unit) -> unit Effect.t
type _ Effect.t += Yield : unit Effect.t

let run main =
  let run_q = Queue.create () in
  let dequeue () =
    if Queue.is_empty run_q then ()
    else continue (Queue.pop run_q) ()
  in
  let rec spawn f =
    match f () with
    | ()                    -> dequeue ()
    | effect Yield, k       -> Queue.push k run_q; dequeue ()
    | effect (Fork f), k    -> Queue.push k run_q; spawn f
  in
  spawn main
```

- Queue of suspended continuations.
- `Yield`: enqueue self, run the next.
- `Fork`: enqueue self, spawn the new fiber.
- ~25 lines, deterministic FIFO schedule.

:::

## Trigger: a one-shot wakeup

A bare fiber library has no way for one fiber to *wait* for
another to finish, or for a fiber to *block* on a condition.
We need a synchronisation primitive. The smallest useful one
is a *trigger*: a one-shot, one-direction wakeup with an
optional callback. State machine:

- `Initial`: nothing is waiting yet, no signal has fired.
- `Waiting (cb)`: a fiber is blocked, with callback `cb` to
  run on signal.
- `Signaled`: the signal has fired; further signals are
  no-ops.

Two operations:

- `signal t`: transition `Initial`/`Waiting` to `Signaled`; if
  waiting, run the callback.
- `on_signal t cb`: transition `Initial` to `Waiting cb`,
  returning `true` to mean "you should now block." Returns
  `false` if already signaled (no need to block).

And one effect:

- `Await : t -> unit Effect.t` (performed by a fiber to ask
  the scheduler to suspend it).

```ocaml skip
type state =
  | Initial
  | Waiting of (unit -> unit)
  | Signaled

type t = { mutable state : state }

type _ Effect.t += Await : t -> unit Effect.t

let create () = { state = Initial }

let signal t =
  match t.state with
  | Initial -> t.state <- Signaled; true
  | Waiting cb -> t.state <- Signaled; cb (); true
  | Signaled -> false

let on_signal t cb =
  match t.state with
  | Initial -> t.state <- Waiting cb; true
  | Signaled -> false
  | Waiting _ -> failwith "Trigger.on_signal: already waiting"

let await t = Effect.perform (Await t)
```

The handler for `Await` lives in the scheduler. When a fiber
performs `Await trigger`, the handler calls
`Trigger.on_signal trigger (fun () -> enqueue k)`. If the
trigger is already signalled (`on_signal` returns `false`),
the handler immediately re-enqueues `k`. Otherwise the fiber
sleeps until something calls `Trigger.signal trigger`, at which
point the callback fires and re-enqueues `k` into the run
queue.

The extended scheduler clause:

```ocaml skip
| effect (Trigger.Await trigger), k ->
    if Trigger.on_signal trigger (fun () -> enqueue k) then
      dequeue ()                  (* genuinely waiting *)
    else
      continue k ()               (* already signalled; resume *)
```

Three lines added to `Sched`. A fiber that performs
`Trigger.await t` is suspended; some other fiber later calls
`Trigger.signal t` and the suspended fiber wakes.

:::slide

## Trigger: one-shot wakeup

```ocaml skip
type state = Initial | Waiting of (unit -> unit) | Signaled
type t = { mutable state : state }
type _ Effect.t += Await : t -> unit Effect.t
```

- Three states: `Initial`, `Waiting cb`, `Signaled`.
- One effect: `Await`.
- Scheduler handler: install callback that re-enqueues the
  fiber on signal.
- Foundation for every other sync primitive (IVar, channel,
  mutex, semaphore, ...).

:::

## IVar: write-once, read-many

An IVar (named after Id and write-once vars from Haskell and
Concurrent ML) is a value cell that starts empty, can be
filled exactly once, and can be read any number of times.
Reads on an empty IVar *block* until it is filled.

```ocaml skip
type 'a state =
  | Empty of Trigger.t list
  | Filled of 'a

type 'a t = { mutable state : 'a state }

let create () = { state = Empty [] }

let fill ivar v =
  match ivar.state with
  | Filled _ -> failwith "IVar.fill: already filled"
  | Empty triggers ->
      ivar.state <- Filled v;
      List.iter (fun t -> ignore (Trigger.signal t : bool)) triggers

let read ivar =
  match ivar.state with
  | Filled v -> v
  | Empty triggers ->
      let t = Trigger.create () in
      ivar.state <- Empty (t :: triggers);
      Trigger.await t;
      match ivar.state with
      | Filled v -> v
      | Empty _ -> assert false  (* fill always precedes signal *)
```

Read it. `read` on a filled IVar returns the value
immediately. `read` on an empty IVar creates a trigger,
attaches it to the IVar's wait list, performs
`Trigger.await`, and (on wakeup) reads the now-filled value.
`fill` writes the value and signals every waiting trigger,
which the scheduler turns into re-enqueues.

The picture: an IVar is a write-once latch. A scheduler is a
queue of fibers. A trigger is the bridge that lets the IVar
wake fibers without knowing what a fiber is. Each layer has
*one job*; the layers compose.

:::slide

## IVar: write-once, read-many

```ocaml skip
type 'a state = Empty of Trigger.t list | Filled of 'a
type 'a t = { mutable state : 'a state }

let fill iv v = (* set Filled, signal all triggers *)
let read iv = match iv.state with
  | Filled v -> v
  | Empty ts -> let t = Trigger.create () in
                iv.state <- Empty (t :: ts);
                Trigger.await t;
                (* wake -> filled by invariant *)
```

- Empty: list of waiting triggers.
- Filled: the value.
- `read` blocks via `Trigger.await`; `fill` wakes all readers.

:::

## Async/await on top

With IVar + fiber, async/await is six lines:

```ocaml skip
type 'a t = 'a Ivar.t

let async f =
  let p = Ivar.create () in
  Sched.fork (fun () -> Ivar.fill p (f ()));
  p

let await p = Ivar.read p
```

`async f` creates an IVar, forks a fiber that runs `f` and
fills the IVar with the result, returns the IVar (the
"promise"). `await p` reads the IVar, blocking if it is not
yet filled. Classic async/await semantics, built from
primitives we already have.

The fibonacci example:

```ocaml skip
Sched.run (fun () ->
  let rec fib n =
    if n <= 1 then n
    else
      let a = Promise.async (fun () -> fib (n - 1)) in
      let b = fib (n - 2) in
      Promise.await a + b
  in
  for i = 0 to 10 do
    Printf.printf "  fib(%d) = %d\n" i (fib i)
  done)
```

No speedup here (we are on one core, and the parallelism
overhead dominates the cost of one addition). But the
*structure* of an asynchronous program is in place, and a
multicore version of `Sched` would parallelise it.

:::slide

## Async/await built on IVar + fork

```ocaml skip
type 'a t = 'a Ivar.t

let async f =
  let p = Ivar.create () in
  Sched.fork (fun () -> Ivar.fill p (f ()));
  p

let await p = Ivar.read p
```

- Six lines.
- `async f`: fork a fiber, return a promise.
- `await p`: block on the promise.
- Standard async/await semantics from primitives we already
  have.

:::

## Channels: typed FIFO message passing

The last library piece. A channel is a FIFO queue with two
operations:

- `send c v`: enqueue `v`. Blocks if the channel is *full*
  (for bounded channels).
- `recv c`: dequeue. Blocks if the channel is *empty*.

Sketched implementation (bounded channel; unbounded is
simpler):

```ocaml skip
type 'a t = {
  buf : 'a Queue.t;
  capacity : int;
  mutable senders : (Trigger.t * 'a) list;
  mutable receivers : (Trigger.t * 'a ref) list;
}

let send c v =
  if Queue.length c.buf < c.capacity then begin
    Queue.push v c.buf;
    (* wake a receiver if any *)
    ...
  end else begin
    let t = Trigger.create () in
    c.senders <- (t, v) :: c.senders;
    Trigger.await t
  end

let recv c =
  if not (Queue.is_empty c.buf) then begin
    let v = Queue.pop c.buf in
    (* wake a sender if any *)
    ...; v
  end else begin
    let slot = ref (Obj.magic 0) in (* filled before wakeup *)
    let t = Trigger.create () in
    c.receivers <- (t, slot) :: c.receivers;
    Trigger.await t;
    !slot
  end
```

The shape is the same as IVar: blocking operations create a
trigger and `await` it; the unblocking operation (`send` for a
waiting `recv`, `recv` for a waiting `send`) signals the
trigger.

The point is that the same `Trigger.Await` effect serves
every blocking primitive in the library. The scheduler only
needs to know about that one effect; everything else (IVar,
channel, mutex, semaphore) is layered on top.

:::slide

## Channels and the Trigger.Await pattern

| Primitive | Blocks on | Wakes up when |
|---|---|---|
| `IVar.read` (empty) | `Trigger.Await` | `IVar.fill` signals |
| `Channel.send` (full) | `Trigger.Await` | a `recv` signals |
| `Channel.recv` (empty) | `Trigger.Await` | a `send` signals |
| Mutex (locked) | `Trigger.Await` | unlock signals |
| Semaphore (no permits) | `Trigger.Await` | release signals |

One handler clause (`Trigger.Await`) services every blocking
primitive. Synchronisation structures are *agnostic* to the
scheduler.

:::

## Separation of concerns

The architecture is worth pausing on. Three layers, each
small, each independent.

1. **The scheduler** knows about fibers, the run queue, and
   one synchronisation effect (`Trigger.Await`). Nothing else.
2. **Triggers** know about callbacks and signalling. They do
   not know what a fiber is.
3. **IVar, channels, mutexes** are built from triggers. They
   do not know what a fiber is, and they do not know what
   scheduler is running.

Different schedulers can plug in to the same library: a FIFO
one for tests, a priority-based one for production, a
work-stealing one for multicore. The synchronisation
structures stay the same. The fibers stay the same. The
client code (the `Sched.fork (fun () -> ...)` calls) stays
the same.

:::slide

## Separation of concerns

| Layer | Knows about |
|---|---|
| Scheduler | fibers, run queue, `Trigger.Await` |
| Trigger | callbacks, signal |
| Synchronisation (IVar, channel, ...) | triggers |
| Client code | fork, yield, sync structures |

Each layer is small and replaceable.

- Swap the scheduler: deterministic for tests, FIFO for prod,
  work-stealing for multicore.
- Same library code; same fibers; new schedule.

:::

## Why this is testable

Three properties of the library above make it testable in
ways an OS-thread library is not.

**Determinism by construction.** A single OS thread, a FIFO
queue, no real-time interleaving. Same program, same input,
same output. Every run.

**Schedule is a parameter.** The scheduler is a value in your
code (the `Sched` module). For a test, swap in an exhaustive
scheduler that explores *every* interleaving up to a depth,
or a randomised one that samples interleavings with a fixed
seed.

**Effects are introspectable.** A test handler can log every
`Fork`, `Yield`, `Await`, `Signal` and assert on the trace.
Production code does not need to know it is being tested.

We do not build the test schedulers in this course; that is
material for a *concurrent programming* course like CS6868.
What you should take away is the *architecture*: concurrency
expressed as effects + handlers is a target rich with hooks
for testing, in a way that pthreads are not.

:::slide

## Why this is testable

- **Deterministic schedule.** Same input -> same output.
- **Schedule is a parameter.** Swap in deterministic, random
  with fixed seed, or exhaustive schedulers.
- **Effects are introspectable.** A test handler can log
  every `Fork`, `Yield`, `Await`, `Signal`.

The architecture costs nothing once you have effect handlers;
it makes concurrent code unit-testable in ways pthreads cannot
match.

:::

## What we deliberately skipped

A bullet list of things this lecture *did not* cover, with
pointers to where they would go.

- **Multicore.** Real parallelism uses OCaml 5 Domains. The
  scheduler grows a lock-protected queue and worker domains.
  Trigger needs to be lock-free or lock-protected. The
  user-facing API (`Sched.fork`, `Sched.yield`, `IVar.fill`,
  `Promise.async`) is unchanged. (Course: CS6868.)
- **Structured concurrency** (cancellation, nurseries, fibre
  hierarchies). Eio adds these on top of effect handlers;
  Forester's `Switch` value is the canonical example.
- **The `select`-style multi-way wait.** Pick the first of
  several events to fire (a `recv` on one channel, a
  `recv` on another, a timeout, ...). Builds on a more
  elaborate trigger.
- **Type-level safety.** OCaml 5 effects do not carry their
  effect type in the value's type; OxCaml (Module 11) and the
  ongoing effects-in-types work do, with implications for
  data-race-freedom and modal types.

:::slide

## What we skipped (pointers, not gaps)

- Multicore: lock-free scheduler, Domains.
- Structured concurrency: Eio's `Switch`, nurseries,
  cancellation.
- Multi-way `select` over many channels.
- Effect-types and modal-types safety (Module 11).

:::

## Activity

:::quiz mcq id=M09-L07-q1
A fiber scheduler uses a FIFO run queue. Two fibers, A and B,
are spawned in that order. Each prints a character, yields,
prints another character, then exits. With initial run queue
`[main]` and FIFO discipline, what does the program print?

```ocaml skip
Sched.run (fun () ->
  Sched.fork (fun () -> print_string "A1 "; Sched.yield (); print_string "A2 ");
  Sched.fork (fun () -> print_string "B1 "; Sched.yield (); print_string "B2 "))
```

- [ ] `A1 A2 B1 B2`.
- [ ] `B1 B2 A1 A2`.
- [x] `A1 B1 A2 B2`.
- [ ] The output is non-deterministic.

**Why:** the main fiber forks A (which goes to the back of the
queue) and forks B (also enqueued). When the main fiber
finishes, the scheduler dequeues A. A prints `A1 `, yields
(re-enqueues itself), and the scheduler dequeues B. B prints
`B1 `, yields (re-enqueues itself). Scheduler dequeues A, which
prints `A2 ` and exits. Scheduler dequeues B, which prints
`B2 ` and exits. Output: `A1 B1 A2 B2`. The schedule is fixed
by the FIFO discipline; the output is the same on every run.
:::

:::quiz mcq id=M09-L07-q2
A worked-out advantage of using effect handlers for
concurrency, rather than OS threads, is that the *scheduler is
a value*. What does that buy specifically for *testing*
concurrent code?

- [ ] Concurrent code becomes faster.
- [ ] The OCaml type checker can prove the code is data-race
  free.
- [x] A test can install a deterministic scheduler that
  reproduces the same interleaving every run, so a failing
  test reproduces reliably and the bug becomes debuggable.
- [ ] OS threads cannot be tested at all.

**Why:** the testing problem with OS threads is *flakiness*:
the same code passes today, fails tomorrow on a different
interleaving the OS happened to choose. By making the
scheduler a value, an effect-handler library lets a test pin
the schedule. A failing test reproduces every time, so it can
be debugged. OS threads can be tested, but only with
non-determinism-suppression tooling (rr, ThreadSanitizer)
that effect-handler libraries get for free at the language
level.
:::

:::quiz code id=M09-L07-q3
Using the `Sched` module above (with `Sched.fork`,
`Sched.yield`, `Sched.run`), write a function `interleave`
that takes two thunks `f` and `g` and runs them as two
fibers, each yielding once after printing its name.

```ocaml skip
let interleave (f : unit -> unit) (g : unit -> unit) : unit =
  (* TODO: fork two fibers, each calls f or g then yields then
     prints "done"; wrap in Sched.run. *)
  ()
```
:::

:::solution

Reference solution:

```ocaml skip
let interleave f g =
  Sched.run (fun () ->
    Sched.fork (fun () -> f (); Sched.yield (); print_endline "f done");
    Sched.fork (fun () -> g (); Sched.yield (); print_endline "g done"))
```

Three lines plus the `Sched.run` wrapper. `interleave (fun ()
-> print_string "A ") (fun () -> print_string "B ")` prints
`A B f done g done`, in that exact order, every run.

:::

## Common pitfalls

**Pitfall 1: forgetting to yield.** A long-running fiber
that never yields starves every other fiber. There is no
preemption in a cooperative scheduler.

**Pitfall 2: deadlock via cycle.** Fiber A waits on IVar
filled by fiber B; fiber B waits on IVar filled by fiber A.
The scheduler runs out of work; `run` returns; the IVars
remain empty. A debug scheduler would warn; the simple
scheduler above just returns silently.

**Pitfall 3: assuming determinism is "the right schedule".**
The schedule is deterministic *for this particular scheduler*
and *this particular set of inputs*. A real-world program with
real I/O has scheduler-external sources of non-determinism;
treat the deterministic scheduler as a *test fixture*, not a
production guarantee.

**Pitfall 4: confusing fibers with Domains.** Fibers are
cooperative tasks on one OS thread. Domains are real parallel
threads on multiple cores. The same effect-handler vocabulary
works for both, but they have very different performance and
correctness characteristics. The lecture is about fibers.

:::slide

## Common pitfalls

1. **Never yielding.** No preemption: a tight loop starves
   everyone.
2. **Deadlock by mutual wait.** No automatic detection in the
   simple scheduler.
3. **"Deterministic" is per-scheduler.** Use it as a test
   fixture, not a guarantee.
4. **Fibers vs Domains.** One OS thread vs many cores; same
   effect-handler vocabulary, different semantics.

:::

## What's next

[Lecture 8](M09-L08-tutorial.html) closes the module. It uses
effect handlers as a *testing* tool: stub the print effect
inside the M05-L06 interpreter so that we can assert on what
it would have printed, without actually touching stdout. The
same idea (handler-as-stub) lets you test code that depends
on external services without mocking them in the
sophisticated frameworks Python and Java codebases need.

After M09 the course shifts to *Memory safety and security*
(M10), then to OxCaml's type-level safety extensions
(M11, with modal types that go beyond what we have seen here
and which can in principle make some of this concurrency code
data-race-free at the type level), and to MirageOS (M12).

:::slide

## What's next

- L8: **wrap-up tutorial.** OUnit2 + QCheck on the M05-L06
  evaluator, plus an effect-handler stub for the print
  effect.
- M10: memory safety and security.
- M11: OxCaml; modal types that can make some of this
  concurrency data-race-free at the type level.

:::

## Reading

- **OCaml manual**, *Effect handlers*. Authoritative syntax
  and semantics:
  <https://v2.ocaml.org/manual/effects.html>
- **Eio**, the effect-handler-based concurrency library for
  OCaml 5. A production-quality version of the architecture
  in this lecture, with structured concurrency, multicore
  support, and a `Switch` mechanism:
  <https://github.com/ocaml-multicore/eio>
- **Stephen Dolan**, *OCaml effect-handlers tutorial*. The
  "scheduler" chapter walks the same code path with more
  examples:
  <https://github.com/ocaml-multicore/ocaml-effects-tutorial>

## Sources

This lecture's prose, worked examples, and quizzes are original
to this course. The fiber scheduler, trigger, IVar, and
async/await architecture is from the CS6868 *Concurrent
Programming* course at IIT Madras (lecture 10, KC
Sivaramakrishnan, Spring 2026), specifically the
`golike_unicore/` sample. The architecture itself is
folkloric in the effect-handler community: Eio
(Anil Madhavapeddy, Thomas Leonard, and contributors) uses
the same layering at production scale. No prose has been
derivatively reused; the diagrams and tables are original.
See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
