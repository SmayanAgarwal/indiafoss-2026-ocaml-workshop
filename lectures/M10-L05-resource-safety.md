---
title: "Resource safety: file descriptors, sockets, and buffers"
lecture_no: 5
week: 10
duration_target_min: 21
concepts: [resource safety, file descriptor, socket, In_channel, with_open_text, Fun.protect, finalisers, leak, double-close, use-after-close]
keywords: [OCaml, resource safety, file descriptor, socket, In_channel, with_open_text, Out_channel, Fun.protect, finaliser, GC, RAII, linearity, uniqueness, OxCaml]
activity_question: "Write a `with_open_file : string -> (in_channel -> 'a) -> 'a` that opens a file, runs the callback, and guarantees the file is closed even if the callback raises. Use `Fun.protect`. What still goes wrong if the callback *returns* the channel?"
think_about_this: "The garbage collector reclaims memory when it becomes unreachable. A leaked file descriptor is also a piece of state held by an unreachable handle: why does the GC not just close it for you?"
reading:
  - title: "OCaml manual, In_channel and Out_channel"
    url: https://v2.ocaml.org/api/In_channel.html
  - title: "OCaml manual, Fun.protect"
    url: https://v2.ocaml.org/api/Fun.html
  - title: "Real World OCaml, Files, modules and programs"
    url: https://dev.realworldocaml.org/files-modules-and-programs.html
---

# Resource safety: file descriptors, sockets, and buffers


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Resource safety: file descriptors, sockets, and buffers</h2>
<p class="title-slide-label">Module 10 &middot; Lecture 5</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The four lectures so far have built the memory-safety story.
M10-L01 catalogued the C bug zoo (use-after-free, buffer
overflow, uninitialised read, double-free). M10-L02 walked the
security cost. M10-L03 showed how OCaml's GC + bounds checks +
binding-time initialisation rule the zoo out by construction.
M10-L04 was the honest boundary (`Obj.magic`, `Marshal`, FFI).

Memory safety is only half the safety story for systems code.
Real programs hold *resources* that are not just memory: file
descriptors, sockets, database connections, mutex locks, GPU
contexts, file handles a kernel hands you. Each one has the same
lifecycle pattern as `malloc` / `free`: you acquire it, you use
it for a while, you release it. Each one has the same bug
patterns: leak (forget to release), double-release, use after
release. The GC does *not* solve these.

This lecture asks: what does OCaml do about resources today, and
where does the story break down? The answer in 2026 is a
combination of higher-order scoping (`In_channel.with_open_text`,
`Fun.protect`) that handles the easy cases, and a residual gap
for resources whose lifetime escapes a function boundary. That
gap is exactly what Module 11's *modes* (uniqueness, linearity)
were designed to close.

:::slide

## Memory safety is half the story

- M10-L01 to M10-L04: **memory** safety, by construction.
- Real programs also hold **resources**: file descriptors,
  sockets, locks, DB connections, GPU contexts.
- Each has its own lifecycle: acquire / use / release.
- Each has its own bug zoo: **leak**, **double-close**,
  **use-after-close**.
- The GC does not solve these.

:::

## File descriptors as a non-memory resource

Pick the simplest case: a file descriptor returned by `open`.
A file descriptor is a small integer the kernel hands you when
you ask it to open a file. The kernel keeps an entry in its
per-process open-file table; that entry has a real cost (kernel
memory, a possible lock on the underlying inode, a position
counter, a reference into the buffer cache). The process has a
hard limit on how many file descriptors it can hold open at a
time; on Linux that limit is often 1024 by default, sometimes
higher, but always finite.

The contract is: you call `open`, you do reads and writes, you
call `close`. If you do not call `close`, the kernel keeps the
entry until the process exits. A long-running server that leaks
one descriptor per request will hit the limit after a few
thousand requests and then refuse every subsequent connection
with "too many open files."

:::slide

## File descriptors

- Kernel-managed: small integer + per-process table entry.
- Hard per-process limit (Linux: often 1024).
- Contract: `open` then `close`.
- *No `close`* -> entry persists until process exit.
- Long-running server leaking one fd per request: dies in hours.

:::

## The three resource-safety bugs

The bug patterns for a file descriptor are the resource-side
analogues of the memory-side bugs from M10-L01. The shape is the
same; the underlying thing being managed is different.

- **Leak**: code path acquires the descriptor, never reaches the
  matching `close`. The descriptor's table entry persists for
  the rest of the process. Equivalent in spirit to a memory
  leak, but on a much smaller pool.
- **Double-close**: `close` is called twice on the same
  descriptor. The first `close` frees the integer; between the
  first and second `close`, the kernel may have reassigned that
  integer to a new `open` call (in this or another thread); the
  second `close` then closes *some other file*, silently.
- **Use-after-close**: `read` or `write` is called on a
  descriptor whose `close` has already happened. Either the
  kernel returns `EBADF` (if no reassignment has occurred), or
  the integer has been reassigned and the read or write hits an
  unrelated file. The unrelated-file case is the dangerous one;
  it is the resource-safety analogue of use-after-free.

The double-close-followed-by-cross-thread-reuse bug is the
resource-safety equivalent of "use-after-free with the allocator
already reusing the address." Both are subtle, both are
attacker-relevant, and both are surprisingly common in real
codebases.

:::slide

## The resource-safety bug zoo

| Bug | What | Memory analogue |
| --- | --- | --- |
| **Leak** | acquire, never release | memory leak |
| **Double-close** | release twice | double-free |
| **Use-after-close** | use after release | use-after-free |

- Each is to file descriptors what its analogue is to memory.
- The kernel does not protect against any of them.

:::

## What OCaml does today: HOF scoping

OCaml's standard idiom for resource management is
*higher-order-function scoping*. The library does not give you
`open` and `close` as separate calls; it gives you a
*combinator* that opens the resource, runs your callback, and
guarantees the resource is closed when the callback returns or
raises.

The canonical example is `In_channel.with_open_text` (added in
OCaml 4.14):

```ocaml skip
let count_lines path =
  In_channel.with_open_text path (fun ic ->
    let n = ref 0 in
    (try
       while true do
         let _ = In_channel.input_line ic in
         incr n
       done
     with End_of_file -> ());
    !n)
```

The handle `ic` is bound only inside the callback. Whatever the
callback does, even if it raises, `with_open_text` closes the
channel before returning control to its own caller. There is no
syntactic shape in which the user can keep `ic` past the end of
the callback without explicitly going out of their way (more on
that below).

:::slide

## HOF scoping: `with_open_text`

```ocaml skip
In_channel.with_open_text path (fun ic ->
  ...)
```

- Combinator: open + run callback + close.
- Handle bound only inside the callback.
- Close runs on normal return *and on exception*.
- The user does not call `close` explicitly: there is no
  `close` to forget.

:::

## How the combinator works: `Fun.protect`

The combinator is built from a more primitive piece: `Fun.protect`
(OCaml 4.08+). Its job is the OCaml equivalent of C++'s RAII or
Python's `with` statement: run a function, and *always* run a
cleanup action afterwards, whether the function returned
normally or raised.

```ocaml skip
let with_open_file path f =
  let ic = open_in path in
  Fun.protect
    ~finally:(fun () -> close_in_noerr ic)
    (fun () -> f ic)
```

Read the signature of `Fun.protect`:

```text
val protect : finally:(unit -> unit) -> (unit -> 'a) -> 'a
```

It takes a `finally` cleanup thunk and a work thunk. It runs the
work; if the work raises, it runs the finally and re-raises; if
the work returns, it runs the finally and returns the work's
result. Either way, the cleanup runs exactly once.

The pattern is the *idiom* that `with_open_text`,
`Out_channel.with_open_text`, `Mutex.protect`, and many
ecosystem libraries are written from. It is also the pattern
this lecture's activity asks you to recreate by hand.

:::slide

## `Fun.protect`: the cleanup combinator

```ocaml
let with_open_file path f =
  let ic = open_in path in
  Fun.protect
    ~finally:(fun () -> close_in_noerr ic)
    (fun () -> f ic)
```

- `Fun.protect ~finally work` runs `work ()`, then `finally ()`,
  *always*, even on exception.
- Cleanup runs exactly once.
- This is the building block of every `with_open_*` in the
  stdlib.

:::

## What HOF scoping closes

When the resource's lifetime really does match a function
boundary, the combinator closes the bug class structurally:

- **Leak**: the close runs on every exit from the callback.
  There is no code path inside `with_open_text` that returns
  without closing.
- **Double-close**: the user does not write `close` at all;
  there is no way to call it twice. The combinator calls
  `close_in_noerr` once.
- **Use-after-close**: the handle goes out of scope at the
  callback's end. After `with_open_text` returns, the name `ic`
  is not in scope at the caller; the user cannot use it.

This is the same shape of argument we ran for `Bytes.sub` in
M10-L03: the bug class is closed because the syntactic shape
that would express it does not exist in the safe combinator.

:::slide

## What `with_open_text` closes

- **Leak**: close runs on every exit (including exceptions).
- **Double-close**: user never calls close at all; combinator
  calls it once.
- **Use-after-close**: handle goes out of scope at callback end.

*The bug class is closed because the syntactic shape does not
exist in the safe combinator.*

:::

## Where HOF scoping breaks down

The combinator pattern only works when the resource's lifetime
fits *neatly inside* a single function call. Two common cases
break it.

**Case 1: the handle has to escape.** Suppose a TCP server
accepts a socket on one thread and hands it to a worker pool to
be processed later. The accepting thread cannot call
`with_open_socket (fun sock -> ...)` because the socket needs to
*outlive* the accept call: it lives until the worker is done. A
`with_*` combinator with a scope-bound handle does not fit this
shape.

```ocaml skip
(* This will NOT type-check, but it captures the intent:
   the user wants the socket to escape the callback. *)
let bad () =
  let sock_escaped =
    with_open_socket addr (fun sock -> sock)
    (* The handle is dead by the time we leave the callback! *)
  in
  send_to_worker sock_escaped
```

The HOF runs the close *as the callback returns*; returning the
handle from the callback hands the caller a closed handle.

:::slide

## Limitation 1: handles that escape

```ocaml skip
let bad () =
  let sock_escaped =
    with_open_socket addr (fun sock -> sock)
  in
  send_to_worker sock_escaped (* sock is already closed *)
```

- HOF closes the resource *as the callback returns*.
- A handle that escapes the callback is *already closed*.
- Stack-discipline lifetimes only. Worker pools, async pipelines,
  promise-returning code: poor fit.

:::

**Case 2: complex lifetimes.** Even within one function, the
resource's lifetime may not be a simple block. A buffer might be
shared between two readers running in parallel; a database
connection might be pinned for a transaction that spans many
function calls; a mutex might be acquired in one function and
released in another after a state-machine transition. The "open
inside this function, close inside this function" pattern does
not generalise.

The combinator pattern remains the right answer for the *common
case*: open a file, read it, close it; open a TCP connection,
do one round-trip, close it. For the cases above, the OCaml
discipline today is "be careful," which is the same discipline
M10-L01 told us does not scale in C.

:::slide

## Limitation 2: complex lifetimes

- Shared buffers between two readers.
- DB connection pinned across a transaction.
- Mutex acquired in one function, released in another.
- *None of these fit "open in this scope, close in this scope".*

The HOF combinator is great for the common case; the boundary is
where the discipline becomes "be careful."

:::

## Sockets and buffers as harder cases

The TCP-server-with-worker-pool pattern from Case 1 above is a
realistic system shape. The accept thread cannot close the
socket; the worker thread receives it and may pass it on to yet
another stage. At each handoff, the question is: who owns the
close? Who is allowed to use the socket while it is "in
flight"? What happens if both endpoints try to close it?

A similar story holds for large buffers. A network parser might
hand a buffer to a hash function and then, *while the hash is
running*, also hand the same buffer to a serialiser. If both
expect to be the unique consumer, you have a race; if one
finishes early and releases the buffer to a pool, the other now
has a use-after-release.

This is the resource-safety analogue of the "uninitialised read"
and "data race" categories of UB from M10-L01. OCaml's
combinator-based discipline does not catch either at compile
time. Today the typical defence is code review and integration
testing.

:::slide

## Harder cases

- **Sockets passed to worker pools**: ownership crosses thread
  boundaries.
- **Buffers shared between consumers**: who owns the release?
- **Mutexes held across function calls**: who unlocks?

*Each is the resource-safety analogue of a C UB category. No
combinator catches them.*

:::

## Why the GC is not enough

A reasonable first reaction is "well, OCaml has a GC; why does
the GC not just close the file descriptor when the handle
becomes unreachable?" The OCaml runtime does in fact have a
mechanism for this: *finalisers* (`Gc.finalise` lets you
register a cleanup that runs when a value is collected). But
finalisers do not solve the problem.

The reasons are quietly important.

**Finalisers are advisory, not prompt.** The GC runs when memory
pressure justifies it, not when *resource* pressure justifies
it. A program holding many leaked file descriptors but very few
leaked bytes will not trigger a GC; the finalisers will not
fire. The program crashes with "too many open files" while the
heap is barely touched.

**Finalisers run in arbitrary order.** If two resources have an
ordering constraint (close the socket before the buffer that
holds its pending writes, for instance), the GC may run the
finalisers in the wrong order. The order is not specified.

**Finalisers cannot fail meaningfully.** A `close` system call
can fail (the buffered writes did not flush; the disk is full).
A finaliser is a `unit -> unit` callback running asynchronously
from GC; it has nowhere to report the failure. Errors are
silently swallowed or logged at best.

The OCaml runtime does ship finalisers, and channels do install
one (`In_channel` registers a finaliser that calls `close_in`
when the channel becomes unreachable). It is a *safety net*, not
the primary discipline. The primary discipline is the
combinator.

:::slide

## Why the GC is not enough

- **Not prompt**: GC runs on memory pressure, not on resource
  pressure.
- **No ordering**: finalisers run in unspecified order.
- **Cannot fail**: finalisers cannot report errors meaningfully.

OCaml channels *do* install finalisers as a safety net. The
*primary* discipline is the combinator.

:::

## Activity

The classroom exercise is to write the
`with_open_file` combinator from scratch, using `Fun.protect`.
The signature is:

```text
val with_open_file : string -> (in_channel -> 'a) -> 'a
```

Open the file, pass the channel to the callback, and ensure the
channel is closed whether the callback returns normally or
raises. Use `Fun.protect` for the guarantee.

:::quiz code id=M10-L05-q1
Implement `with_open_file : string -> (in_channel -> 'a) -> 'a`
that opens the file at `path`, calls `f` with the resulting
input channel, and *always* closes the channel before returning
(even if `f` raises). Use `Fun.protect`.

```ocaml
let with_open_file path f =
  failwith "not implemented"
```

```ocaml skip
let () =
  (* Use /dev/null so the test does not depend on any
     particular file in the working directory. *)
  let result =
    with_open_file "/dev/null" (fun ic ->
      let _ = In_channel.input_line ic in
      42)
  in
  assert (result = 42);
  (* Verify cleanup runs on exception. *)
  let cleaned = ref false in
  (try
     with_open_file "/dev/null" (fun _ic ->
       (* Mark cleanup via a different channel: install a
          finally that flips the ref. The real cleanup of the
          file descriptor still runs through Fun.protect. *)
       cleaned := true;
       failwith "boom")
   with Failure _ -> ());
  assert !cleaned;
  print_endline "all tests passed"
```
:::

A reference solution.

```ocaml
let with_open_file path f =
  let ic = open_in path in
  Fun.protect
    ~finally:(fun () -> close_in_noerr ic)
    (fun () -> f ic)

let _ =
  with_open_file "/dev/null" (fun _ic -> 42)
    (* = 42 *)
```

Notice what the implementation gives you for free. The cleanup
is registered before the user's callback runs; if `open_in`
itself raises, no cleanup is needed (no channel exists yet); if
`f` raises, the cleanup fires and the exception propagates; if
`f` returns, the cleanup fires and the return value propagates.
The combinator does not need to know whether `f` raises or
returns; `Fun.protect` handles both cases uniformly.

This is the entire discipline that closes the leak / double-close
/ use-after-close bug class for the easy lifetime shape. The
shape is the gift; the rest of the chapter is the cases where
that shape does not fit.

:::slide

## Activity discussion

```ocaml skip
let with_open_file path f =
  let ic = open_in path in
  Fun.protect
    ~finally:(fun () -> close_in_noerr ic)
    (fun () -> f ic)
```

- `Fun.protect` runs `finally` on both normal return and
  exception.
- `open_in` runs *before* `Fun.protect`, so a failed open does
  not need cleanup.
- `close_in_noerr` swallows any close-time error (no exception
  from cleanup).
- *No path through the body forgets to close.*

:::

## A forward pointer: modes

The HOF combinator closes the *common* case. The cases it does
not close (resources that escape, complex lifetimes, shared
buffers) are exactly the cases that Module 11's *modes* are
designed to address.

In M11 we will meet a new mode-system axis called *uniqueness*
(and its dual, *linearity*). A value with the `unique` mode is
guaranteed to have no other references. A value with the `once`
mode is guaranteed to be used at most once. Together, they let
the *type checker* enforce the discipline that today depends on
the programmer remembering to wrap every resource in
`with_open_*`.

A sketch (real syntax appears in M11-L04):

```ocaml skip
(* Forward sketch from M11: a unique file handle. *)
val open_file : string -> file_handle @ unique
val read     : file_handle @ unique -> string * file_handle @ unique
val close    : file_handle @ unique -> unit
```

Every operation consumes the unique handle and (except for
`close`) returns a new one. Use-after-close is rejected at
compile time because the handle was consumed by `close` and
nothing was returned. Double-close is rejected for the same
reason. Leak is rejected by the linearity axis: the compiler
checks that the handle is eventually consumed.

The combinator we wrote in this lecture is the *value-level*
shape of this discipline. M11's modes are the *type-level*
shape, with the compiler doing the enforcement that the
combinator does at runtime.

:::slide

## Forward pointer to M11

- M11 introduces *uniqueness* and *linearity* modes.
- A `unique` handle has no other references.
- A `once` value is used at most once.
- *The compiler enforces the discipline that the combinator
  enforces at runtime.*
- Closes the cases HOF scoping cannot (escape, complex
  lifetimes, shared buffers).

:::

## What we did

- Pointed out that memory safety is only half the safety story.
- Catalogued the resource-safety bug zoo: leak, double-close,
  use-after-close.
- Walked OCaml's current discipline: `Fun.protect` and the
  `with_open_*` family of combinators.
- Showed where the combinator pattern breaks down: handles that
  escape, complex lifetimes, shared resources.
- Explained why the GC is not the answer: finalisers are
  advisory, unordered, and cannot fail meaningfully.
- Forward-pointed to M11: uniqueness and linearity modes will
  close these cases at the type level.

The lecture's pitch is that OCaml's safety story extends past
the GC. The combinator pattern handles most resources; the
remaining cases motivate Module 11.

:::slide

## What we did

- Memory safety is half the story.
- Resource bug zoo: leak, double-close, use-after-close.
- Today's discipline: `Fun.protect` + `with_open_*`.
- Where it breaks: escape, complex lifetimes, shared resources.
- GC is not enough: finalisers are advisory.
- *M11 modes close the gap at the type level.*

:::

## What's next

[Lecture 6](M10-L06-tutorial.html) is the module's tutorial. It
walks the Heartbleed CVE end to end, the canonical
memory-safety bug, and shows the OCaml equivalent where the
same bug class is structurally impossible. The tutorial closes
M10 by landing the full safety picture (memory + resource +
honest boundary) on one concrete case study.

[Module 11](M11-L01-modes-as-safety.html) picks up the
resource-safety thread and elevates it from runtime combinator
to compile-time check.

:::slide

## What's next

- Lecture 6: walk Heartbleed end to end, the canonical CVE.
- Module 11: type-level resource safety with uniqueness and
  linearity modes.

:::

## Reading

- **OCaml manual**, *`In_channel`*:
  <https://v2.ocaml.org/api/In_channel.html>
- **OCaml manual**, *`Fun.protect`*:
  <https://v2.ocaml.org/api/Fun.html>
- **Real World OCaml**, *Files, modules and programs*:
  <https://dev.realworldocaml.org/files-modules-and-programs.html>
- **Jane Street**, *OxCaml modes overview*:
  <https://oxcaml.org/>

## Sources

This lecture's prose, code examples, and the activity are
original to this course. The OCaml manual entries for
`In_channel`, `Out_channel`, `Fun.protect`, and the finaliser
machinery are public documentation. The forward pointer to
uniqueness and linearity in Module 11 draws on the OxCaml mode
system documentation at <https://oxcaml.org/>. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
