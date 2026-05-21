---
title: "Modes as the type-level continuation of safety"
lecture_no: 1
week: 11
duration_target_min: 25
concepts: [modes, behavioural types, locality, uniqueness, linearity, OxCaml]
keywords: [OCaml, OxCaml, modes, behavioural types, type system, safety]
activity_question: "Module 10 said OCaml's GC plus types rule out four classic memory bugs by construction. Name one C bug class that survives even with a GC, and sketch why a *type-level* fix is the natural next step."
think_about_this: "A type usually answers the question *what is this value?* What if it also answered *how is it allowed to be used?* What sorts of bugs could a compiler then reject that it cannot today?"
reading:
  - title: "KC Sivaramakrishnan, Uniqueness for behavioural types (2025-05-29)"
    url: https://kcsrk.info/ocaml/modes/oxcaml/2025/05/29/uniqueness_and_behavioural_types/
  - title: "KC Sivaramakrishnan, Linearity and uniqueness (2025-06-04)"
    url: https://kcsrk.info/ocaml/modes/oxcaml/2025/06/04/linearity_and_uniqueness/
  - title: "OxCaml documentation"
    url: https://oxcaml.org/
---

# Modes as the type-level continuation of safety

Module 10 made a careful argument. The garbage collector plus the
type system rule out a small zoo of memory bugs by construction:
use-after-free, buffer overflow, uninitialised read, double-free.
We saw the C versions of each, surveyed how they become CVEs, and
then walked through which feature of OCaml eliminates each. The
honest closing note was that this safety story has boundaries:
`Obj.magic`, races on `ref`, the `Marshal` flows, the FFI. Inside
the safe fragment, though, the language genuinely does what it
claims.

Module 11 picks the argument back up at a different boundary. There
are two C bug classes that the OCaml story so far does *not*
address, and they are not curiosities. They are bugs that real
systems programmers hit every week.

The first is **stack-pointer escape**. In C you can write
`return &x` where `x` is a function-local variable. The compiler
will not stop you. When the caller dereferences the pointer, the
stack frame is gone, the bytes have been overwritten by some later
call, and the program reads whatever happens to be there now. OCaml
cannot have this bug, because OCaml does not let you take pointers
to local variables; everything that escapes is on the GC heap. But
that is a strong promise that comes with a price: every value that
might escape lives on the heap, even when it does not need to. A
graphics renderer building millions of intermediate points pays GC
pressure for values that exist for nanoseconds. The cheap-stack
escape valve does not exist in vanilla OCaml.

The second is **use-after-free of manually managed resources**. The
GC handles memory: by the time it frees a block, no part of your
program holds a reference. But "resource" is a wider category than
"memory." A file descriptor must be closed exactly once. A database
connection must be returned to the pool exactly once. A unique
buffer you obtained from `malloc` via the FFI must be `free`d
exactly once. The GC does not know about any of these. If your code
calls `close` twice on the same descriptor, or forgets to close it,
or closes it and then keeps using it, the type system has nothing
to say.

OxCaml's mode system fixes both. The fix is type-level, which means
no extra runtime, no extra branches, no extra allocation. The
compiler reads the program more carefully, and rejects more bad
programs.

:::slide

## Where M10 left us

- GC + types rule out memory bugs **inside safe OCaml**, by construction.
- But two C bug classes survive even with a GC:
  - **stack-pointer escape** (`return &x`),
  - **use-after-free of manually managed resources** (close twice).
- The fix is to extend the *type* system. That is the OxCaml story.

:::

## What the words mean

Three terms keep coming back in this module. Let us put them on a
slide before we use them.

A **mode** is a type-level annotation that tracks not just what a
value is, but *how* it can be used. The same `int ref` can appear
at two different modes in two different places in your program;
the compiler treats it as the same type but checks different rules.
The mode is on the *use site*, not on the type definition. This is
unlike, say, Rust, where ownership is woven into the type itself.

An **axis** is one independent dimension of mode. OxCaml has five
axes. We will look at three in this module:

- **Locality**: can this value escape the scope it was created in?
- **Uniqueness**: has this value been aliased in the past?
- **Linearity**: how many times can this value still be used?

The other two are **contention** and **portability**, which together
form OxCaml's story for compile-time data-race freedom. They matter
to the same people who care about Module 11, but the course does
not include a concurrency module, so we will mention them in
passing and then move on.

A **behavioural type** is a type that tracks *use patterns*, not
just shape. The classical example: a file-handle type that knows it
must be closed before the program ends. Modes give us behavioural
types built into the compiler.

:::slide

## Three definitions

- **Mode**: type-level annotation describing *how* a value can be
  used, not what it is.
- **Axis**: one independent dimension of mode.
- **Behavioural type**: a type that tracks the protocol of use,
  not just the shape of values.

OxCaml has five axes. M11 covers **locality**, **uniqueness**,
**linearity**.

:::

## The behavioural-types framing

Before OxCaml existed, OCaml programmers who wanted to enforce
"this resource must be closed exactly once" reached for runtime
tricks. The standard one: a mutable `bool` inside the resource,
flipped to `false` on first use, checked on every subsequent
operation, with an exception raised if it was already `false`. The
2016 blog post *Behavioural types in OCaml*, by your instructor,
worked through this pattern in detail using polymorphic variants to
encode the protocol of allowed operations. The polymorphic-variant
types were already behavioural: they expressed sequences of
operations. But the implementation needed a runtime flag because
OCaml had no way to *statically* prove the type-state machine was
respected.

The 2025-05-29 follow-up post (linked at the top of this lecture)
asks the question we are about to spend the next four lectures on:
what if the compiler could enforce that the resource is never
aliased? Then the runtime flag becomes redundant. The behavioural
type stops needing a dynamic check. The protocol is a *type*, and
the type-checker enforces it.

That is the line OxCaml's mode system delivers. Locality,
uniqueness, and linearity together let you write types that
describe use patterns: this value lives on the stack and cannot
escape; this reference is the only one and may safely be freed;
this handle must be used exactly once. The implementation needs no
runtime checks. The compiler does the work, statically, and rejects
programs that violate the protocol.

:::slide

## Behavioural types, before and after

| Before modes | With modes |
|---|---|
| Protocol encoded in polymorphic variants | Same |
| Linearity enforced by a `mutable bool` flag | Linearity enforced by the type checker |
| `raise LinearityViolation` at runtime | Type error at compile time |
| Cost: branch + memory cell per ref | Cost: zero |

The 2016 post needed dynamic checks because OCaml could not
statically prove no aliasing. With OxCaml's uniqueness, the
dynamic check is gone.

:::

## A tour of the axes

The next three lectures (M11-L02 through M11-L04) each take one
axis, give a working example, and walk through what the compiler
says when you try to break the rule. This section is the road map.

### Locality: scope-tracking

OxCaml introduces a **locality** axis with two modes,
`global` (the default, may live anywhere) and `local` (must not
escape the current scope). Mark a function parameter `@ local` and
the type checker enforces that you do not capture it in a closure,
return it from the function, or store it in a long-lived cell. In
exchange, the compiler can allocate that value on the **stack**.
You can mix and match: `local` inputs feeding `global` outputs is
fine, as long as the local value itself does not escape.

A small taste of what the annotations look like (we will read this
carefully in M11-L02):

```ocaml
type point = { x : float; y : float }

let distance (a @ local) (b @ local) : float =
  let dx = a.x -. b.x in
  let dy = a.y -. b.y in
  Float.sqrt (dx *. dx +. dy *. dy)
```

`distance` takes two points at mode `local`. It promises not to
capture either of them. It returns a `float`, which is not marked
local, so the answer is global and can flow back to the caller
freely. The two arguments may now live on the stack.

The escape-attempt version, the one that would be `return &x` in C,
does not compile:

```ocaml skip
(* Compile-time error demo: kept as `skip` because the lecture
   text says "the compiler refuses this". The error message below
   is the expected diagnostic. *)
let escape () =
  let p = stack_ { x = 1.0; y = 2.0 } in
  p
(* Error: This value is local because it is stack_-allocated.
         However, the highlighted expression is expected to be
         local to the parent region or global because it is a
         function return value. *)
```

The C version compiles and silently breaks. The OxCaml version
fails at the type level. The information you would need to write
the rule for yourself (does this pointer outlive its frame?) is in
the type.

:::slide

## Locality, in one slide

- Two modes: `global` (default) and `local`.
- `@ local` parameter: caller hands you a value you promise not to
  let escape.
- `stack_ {...}`: allocate on the stack instead of the heap.
- Escape attempts (return, capture, long-lived store) become **type
  errors**.

Replaces the C bug: `return &x`.

:::

### Uniqueness: tracking past aliasing

OxCaml introduces a **uniqueness** axis with two modes,
`aliased` (the default) and `unique`. A `unique` value is one the
compiler has proven has no other live references. With that proof
in hand, you can do things that would be unsafe on aliased values:
free the underlying memory, destructively update it in place, hand
it to a low-level resource manager.

The signature of a uniqueness-checked reference looks like this:

```ocaml
module type Unique_ref = sig
  type 'a t
  val alloc : 'a -> 'a t @ unique
  val free  : 'a t @ unique -> unit
  val get   : 'a t @ unique -> 'a * 'a t @ unique
  val set   : 'a t @ unique -> 'a -> 'a t @ unique
end
```

`free` consumes the unique reference. After it returns, there is
no live `unique` handle to that resource: the compiler tracked
where it went. A second `free` cannot find anything to free
because the original handle was consumed. Double-free becomes a
type error, not a runtime crash.

Uniqueness gives the compiler the proof it needs to call `free`
safely. The bug class it eliminates: use-after-free of any
manually managed resource, not just memory.

:::slide

## Uniqueness, in one slide

- Two modes: `aliased` (default) and `unique`.
- `@ unique`: compiler has proven this value has no other live
  references.
- Operations like `free` consume the unique handle: a second use
  is a type error.

Replaces the C bugs: use-after-free, double-free.

:::

### Linearity: tracking future use

OxCaml introduces a **linearity** axis with two modes,
`many` (the default) and `once`. A `once` value is one the compiler
has proven will be used *at most once* going forward. A linear
file-handle type, for example, can require that `close` takes a
`once` handle: any code that calls `close` twice fails to type
check, because the handle is consumed on first use.

```ocaml
module type Handle = sig
  type t
  val open_  : string -> t @ once
  val read   : t @ once -> string -> t @ once
  val close  : t @ once -> unit
end
```

The signature reads like a protocol. `open_` produces a once-usable
handle. `read` consumes the once-usable handle and gives you back a
fresh one (so you can call `read` many times in sequence, each call
consuming and returning the handle). `close` consumes the handle
without returning one. After `close`, there is no handle left, so
double-close is impossible. Forgetting to close is also caught: a
`once` value that is never consumed at the end of its scope is a
warning, or in some configurations a hard error.

Linearity is the mirror of uniqueness. Uniqueness asks *has this
been aliased in the past?* Linearity asks *will this be used again
in the future?* They cooperate in subtle ways, especially around
closures, which we will see in M11-L03 and M11-L04.

:::slide

## Linearity, in one slide

- Two modes: `many` (default) and `once`.
- `@ once`: compiler has proven this value will be used at most
  once.
- Operations like `close` consume the once-usable handle.

Replaces the C bugs: double-close, missing close, use-after-close.
Captures the *future*; uniqueness captures the *past*.

:::

### Contention and portability, briefly

The last two axes are **contention**
(`uncontended` / `shared` / `contended`) and **portability**
(`portable` / `nonportable`). Together they let the OxCaml compiler
reject data races at compile time. A closure that captures a
mutable `ref` is `nonportable`; the spawn primitives require
`portable` closures; the type checker glues those rules together to
make racy programs untypable.

This course does not include a concurrency module, so we are not
covering contention and portability in any depth. The point of
mentioning them now: the mode-system framing scales. The same shape
of argument we will use for locality, uniqueness, and linearity is
the shape Jane Street uses to deliver compile-time race freedom.
The CS6868 handout in your reading list covers contention and
portability if you want to follow up.

:::slide

## Mode axes, full table

| Axis | Modes (looser ⇐ ⇒ stricter) | Default | Tracks |
|---|---|---|---|
| **Locality** | `global` ⇐ `local` | `global` | Can it escape its scope? |
| **Uniqueness** | `aliased` ⇐ `unique` | `aliased` | Has it been aliased? |
| **Linearity** | `many` ⇐ `once` | `many` | Will it be used again? |
| Contention | `uncontended` ⇐ `shared` ⇐ `contended` | uncontended | Cross-domain access? |
| Portability | `nonportable` ⇐ `portable` | nonportable | Cross-domain crossing? |

The first three are M11's subject.

:::

## Why this is *type-level* and what that buys you

It would be tempting to dismiss the whole mode system as syntax
sugar. There are after all simpler ways to enforce "close a file
once": a runtime flag, a `Hashtbl` of open handles, even a finaliser
that closes on GC. Why a whole compiler-level axis?

Three reasons.

**No runtime cost.** A runtime flag is one extra byte, one extra
branch on every operation, one extra mistake to forget. Across a
million operations per second in a hot loop, that adds up. A
compile-time check costs nothing at runtime.

**Detectable before deployment.** A runtime check fires on the bad
input that triggers it. A compile-time check fires on the bad
*program*, before it has been deployed. The difference is between
"this program crashed in production at 03:14 last Tuesday" and
"this program failed to compile and the developer fixed it."

**Modular reasoning.** When the signature of `free` is
`'a t @ unique -> unit`, you know, just from reading the
signature, that calling `free` on an aliased reference is
impossible. You do not have to read the implementation, check the
caller, audit the entire codebase. The type makes the promise. The
2025-06-04 post (the second one in your reading list) makes this
point precisely: with `@ unique`, modular reasoning works; with
linearity alone, you have to inspect the whole API to be sure the
ref does not get aliased somewhere you missed.

:::slide

## What type-level safety buys you

1. **Zero runtime cost** vs. runtime flags or GC finalisers.
2. **Detected at compile time**, before deployment, not on the bad
   input that triggers the bug.
3. **Modular reasoning**: the signature alone tells you what is
   safe.

This is the same shape of argument we made for OCaml's type system
in M01. Modes extend the argument to the protocol of use.

:::

## What this module covers

The remaining four lectures of M11 take each axis in turn and walk
it carefully. The plan:

- **M11-L02** introduces locality. Polyline running example.
  `stack_` blocks. `exclave_` for returning local values. Mode
  crossing for primitive types. The compiler-error walk-through
  when an escape is attempted.
- **M11-L03** introduces uniqueness. The `Unique_ref` API from the
  2025-05-29 post. The subtle pitfall around closure capture and
  why uniqueness alone is insufficient. (Spoiler: it leads
  naturally to linearity.)
- **M11-L04** introduces linearity. The `once` mode. A file-handle
  module where the compiler rejects double-close, missing close,
  and use-after-close. Past-versus-future framing from the second
  blog post.
- **M11-L05** is the tutorial. We design a small resource-management
  API end to end, combining locality and linearity, watch the
  compiler reject three different ways to misuse the API, and
  compare to the C equivalent.

The OxCaml compiler is still a moving target; the locality and
uniqueness syntax in particular has shifted across releases. We
have pinned to a stable snapshot for this course (see the OxCaml
documentation link at the top of this lecture for the version
matrix). Where this matters, we will call it out.

All OxCaml code in this module runs in an in-browser bundle of the
OxCaml compiler, the same way vanilla cells have worked in earlier
modules. The bundle is heavier than the vanilla one (the OxCaml
type checker is a substantial extension), so cells in M11 take a
few seconds longer to load. If your reading environment is offline,
the OxCaml cells will gracefully degrade: you will see the source
code with syntax highlighting but no Run button.

## Activity

:::quiz mcq id=M11-L01-q1
Which of the following bug classes is *not* ruled out by OCaml's
type system plus its garbage collector, but *is* ruled out by
OxCaml's mode system?

- [ ] Buffer overflow when indexing into a `string`.
- [ ] Forgetting to handle the empty-list case in a function.
- [x] A `close` function called twice on the same file handle.
- [ ] An integer overflow.

**Why:** Of these four, only the double-close is a behavioural-type
bug: the value (the file handle) is fine, but the *protocol* of how
it should be used (close at most once) is what is being violated.
OCaml's type system tracks the *shape* of values; OxCaml's mode
system extends that to track *use*. The first option is wrong
because `string` indexing in OCaml already raises
`Invalid_argument`; the second is a programmer logic error; the
fourth is a separate axis (integer overflow is not a memory-safety
issue and is not what modes address).
:::

:::quiz mcq id=M11-L01-q2
Read the type signature carefully:

```ocaml skip
val free : 'a t @ unique -> unit
```

Which statement is the strongest correct claim you can make about
this function, just from the signature?

- [ ] `free` runs in constant time.
- [ ] `free` may release memory.
- [x] After calling `free t`, the compiler ensures `t` cannot be
      used again in any well-typed continuation.
- [ ] `free` is safe to call from any number of threads in
      parallel.

**Why:** The `@ unique` annotation says the input has no other live
references. The type-system bookkeeping then ensures that after the
call, the original binding is consumed: the compiler will reject
any attempt to use it. That is modular reasoning straight from the
signature, with no implementation inspection needed. The other
options are about behaviour or thread-safety, which the uniqueness
mode by itself does not tell you (thread-safety is on the
contention axis, which is a *different* axis).
:::

:::slide

## Activity discussion

- Modes catch **behavioural** bugs, not just *value-shape* bugs.
  The double-close example is the prototypical case.
- Reading a signature like `free : 'a t @ unique -> unit` tells
  you, modularly, that the compiler will not let you use the
  reference after `free`. The signature is the contract.

:::

## Reading

- **KC Sivaramakrishnan**, *Uniqueness for behavioural types*
  (2025-05-29). The bridge from the 2016 polymorphic-variant
  approach to modes:
  <https://kcsrk.info/ocaml/modes/oxcaml/2025/05/29/uniqueness_and_behavioural_types/>
- **KC Sivaramakrishnan**, *Linearity and uniqueness* (2025-06-04).
  Why both axes are needed; the closure-capture pitfall:
  <https://kcsrk.info/ocaml/modes/oxcaml/2025/06/04/linearity_and_uniqueness/>
- **OxCaml documentation**, the canonical reference for the
  language extensions: <https://oxcaml.org/>
- **Marshall, Vollmer and Orchard**, *Linearity and Uniqueness: An
  Entente Cordiale* (ESOP 2022). The paper that establishes the
  formal relationship between linearity and uniqueness in one type
  system: <https://granule-project.github.io/papers/esop22-paper.pdf>

## Sources

This lecture's framing of modes as the type-level continuation of
M10's safety story is original to this course. The behavioural-
types narrative draws on the instructor's own 2025-05-29 and
2025-06-04 blog posts, freely reusable. The tour-of-the-axes
material adapts the introduction of the CS6868 OxCaml handout
(`/Users/kc/teaching/cs6868/cs6868_s26/lectures/11_oxcaml/handout.md`,
the instructor's own teaching material). See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
