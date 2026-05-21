---
title: "Linearity — use exactly once"
lecture_no: 4
week: 11
duration_target_min: 25
concepts: [linearity, once, many, linear types, file handle, resource discipline, linear logic]
keywords: [OCaml, OxCaml, linearity, once, many, linear types, file handle, Linear Logic, Girard]
activity_question: "Write a function-call sequence that opens a file, reads from it twice, then closes it. Now imagine that the type system *required* the handle to be used exactly once, with no aliasing in the future. How would you have to thread the handle through the calls?"
think_about_this: "Rust's ownership system enforces 'this value will be used at most once' through move semantics. OxCaml's linearity is a similar idea, but the value is not the package: the *mode* is. What does it buy you to separate the value from the mode?"
reading:
  - title: "KC Sivaramakrishnan, Linearity and uniqueness (2025-06-04)"
    url: https://kcsrk.info/ocaml/modes/oxcaml/2025/06/04/linearity_and_uniqueness/
  - title: "Oxidizing OCaml: ownership (Jane Street blog)"
    url: https://blog.janestreet.com/oxidizing-ocaml-ownership/
  - title: "Jean-Yves Girard, Linear logic (1987)"
    url: https://www.sciencedirect.com/science/article/pii/0304397587900454
---

# Linearity: use exactly once

The previous lecture's uniqueness axis tracked something about a
value's **past**: has it been aliased? This lecture's linearity
axis tracks something about a value's **future**: how many more
times will it be used?

These sound similar but are genuinely different. A value can have
no aliases right now (unique) and still be used many times in the
future. A value can be used only once in the future (linear) even
if it has been aliased in the past. The two axes are independent;
they cooperate, but they are not redundant.

For a *resource* like a file handle, linearity is often the
natural axis. The protocol for a file is:

1. Open the file. Get a handle.
2. Read from the handle some number of times.
3. Close the handle.
4. Do not use the handle again.

What the language needs to enforce is step 4 (use no further), not
"the handle has no other references" (which it may, depending on
the program). Linearity is the axis that says "after this use,
there are no more." That is exactly the file-handle discipline.

This lecture introduces the linearity axis, walks through a
file-handle module that uses it, contrasts it briefly with Rust's
ownership, and traces the idea back to Girard's Linear Logic.

:::slide

## Where we are

- M11-L02: locality. Tracks scope.
- M11-L03: uniqueness. Tracks past aliasing.
- M11-L04 (this lecture): **linearity**. Tracks future use.

Three independent axes. M11-L05 puts them together.

:::

## The linearity axis, mechanically

Two modes:

- **`many`** (the default): the value may be used any number of
  times in the future. This is the normal world: a string, an
  integer, a list, a function value can be referenced many times.
- **`once`**: the value will be used at most once. After that use,
  the binding is consumed; the compiler refuses any further
  reference to it.

The submoding is `many ⊑ once`. A `many` value can be used
anywhere a `once` value is expected. The intuition: "use many
times" is a *stronger* promise than "use at most once." If you can
use it many times, you can use it once and then stop. The reverse
is rejected: a `once` value cannot satisfy a context that may use
the value many times.

The annotation goes after `@`, like the other axes. For example,
`val close : t @ once -> unit` says that `close` takes a `t` at
mode `once`. Calling `close` consumes that single use. After the
call, the binding is gone; the compiler refuses any further
reference. We will see the full signature in context in a moment.

:::slide

## The linearity axis

| Mode | Meaning | Future uses |
|---|---|---|
| **`many`** (default) | Use any number of times | Unbounded |
| **`once`** | Use at most once | One |

Submoding: `many ⊑ once`. A many-value can flow into a once-slot.
The reverse is rejected.

:::

## A file-handle module

Here is the running example for this lecture. A small module that
manages file handles, with the type system enforcing the
"open-read*-close" protocol. We will define the module type, the
implementation, and three deliberately buggy clients in turn; the
implementation has to exist first so that the bug demos have an
`open_`, `read`, and `close` to call.

A note on the implementation: this lecture uses an **in-memory
mock** as the backing of `Handle`. The body of `open_` allocates
a small record with an empty buffer; `read` slices substrings;
`close` does nothing. In production you would back the same
signature with `Unix.openfile` / `Unix.read` / `Unix.close`, and
the I/O code would do the real work. The point of the lecture is
not the I/O; it is that the linearity guarantees are entirely
independent of the backing. With a real file descriptor inside,
the type system's "used at most once" contract is exactly the
contract you want on an OS file descriptor. The mock keeps the
runtime trivial so we can focus on the compiler's behaviour.

```ocaml
module type Handle = sig
  type t

  val open_ : string -> t @ once
  (** [open_ filename] opens a file and returns a once-usable
      handle. *)

  val read : t @ once -> int -> string * t @ once
  (** [read t n] reads [n] bytes from [t] and returns the data
      and a fresh once-usable handle. *)

  val close : t @ once -> unit
  (** [close t] closes [t]. The handle is consumed. *)
end

module Handle : Handle = struct
  type t = { mutable buf : string; mutable pos : int }

  let open_ _path =
    (* In production: Unix.openfile path [...] mode and store the
       fd. Here: an empty in-memory buffer. *)
    { buf = ""; pos = 0 }

  let read t n =
    (* In production: Unix.read t.fd buf 0 n and copy. Here:
       safely substring whatever the buffer holds. *)
    let avail = String.length t.buf - t.pos in
    let take = if n < avail then n else avail in
    let s = if take <= 0 then "" else String.sub t.buf t.pos take in
    t.pos <- t.pos + take;
    s, t

  let close _t =
    (* In production: Unix.close t.fd. Here: nothing to release. *)
    ()
end
```

Read each line of the signature:

- `open_` produces a `once` handle. The caller will use it at
  most once, then.
- `read` consumes a `once` handle and returns a *fresh* `once`
  handle. This is the ownership-chain shape from M11-L03:
  threading the handle through each operation lets us call `read`
  many times in sequence, each call consuming its handle and
  producing the next.
- `close` consumes the `once` handle without returning a new one.
  After `close`, there is no live handle to the file.

The implementation itself looks ordinary. OxCaml's mode checking
is structural, not type-level: the compiler reads the
implementation in light of the declared signature and verifies
that each function respects linearity. The mode bookkeeping is in
the *checker*, not in the runtime.

A correct client looks like this:

```ocaml
let read_two () =
  let t = Handle.open_ "data.txt" in
  let s1, t = Handle.read t 100 in
  let s2, t = Handle.read t 100 in
  Handle.close t;
  s1, s2
```

The handle threads through each call. Each line consumes the
current `t` and rebinds a fresh `t` (or, for `close`, consumes and
returns nothing). At the end of the function, `t` no longer
exists; the file is closed; the strings escape to the caller.

This is *exactly* the same shape as the `Unique_ref` example in
the previous lecture. The shape is generic: any linear/unique
resource API ends up looking like an ownership chain. The
*meaning* differs (linearity tracks future use, uniqueness tracks
past aliasing), but the *programming model* is the same.

:::slide

## File-handle protocol as a type

```ocaml
module type Handle_recap = sig
  type t
  val open_ : string -> t @ once
  val read  : t @ once -> int -> string * t @ once
  val close : t @ once -> unit
end
```

- `open_` produces a fresh once-usable handle.
- `read` consumes and re-produces a once-usable handle.
- `close` consumes without re-producing.

Client uses the **ownership-chain** shape: shadow `t` through
each operation.

:::

## Three bugs, three type errors

The whole point of the API is that you cannot misuse it. Let us
walk through three deliberate bugs and see what the compiler says.
Each cell below is *meant* to fail to compile; press Run on each
to see the OxCaml compiler's refusal inline.

### Bug 1: double-close

```ocaml
(* Press Run; the compiler refuses on linearity grounds. *)
let double_close () =
  let t = Handle.open_ "data.txt" in
  Handle.close t;
  Handle.close t
```

The first `Handle.close t` consumed the handle. The second
`Handle.close t` is attempting to reference a binding that no
longer holds a live once-value. The compiler refuses, with a
message of the form "This value is used here, but it is defined
as once and has already been used", pointing at the offending use
and the prior one.

The corresponding C bug is the canonical double-close: calling
`fclose` twice, or `unix_close` twice, on the same file
descriptor. On Linux, the second call may close some *other*
descriptor (because the kernel has reassigned the integer); on
Windows, behaviour varies. None of this can happen here: the
program does not compile.

### Bug 2: use-after-close

```ocaml
(* Press Run; same shape as bug 1, different surface form. *)
let read_after_close () =
  let t = Handle.open_ "data.txt" in
  Handle.close t;
  let _s, _t' = Handle.read t 10 in
  ()
```

Same shape. The `close t` consumed the handle; `read t` then
tries to use it again. The compiler tracks the single allowable
use and rejects the second one with the same "already been used as
once" error.

### Bug 3: forgetting to close

```ocaml
(* Press Run; discarding a once-value is also a violation. *)
let leak () =
  let t = Handle.open_ "data.txt" in
  let _s, _t = Handle.read t 10 in
  ()
```

This one is subtler. The handle is consumed by `read`, and the
fresh handle returned by `read` is bound to `_t`. The underscore
tells the compiler we are intentionally discarding the value.
Discarding a `once` value is a *violation*: the protocol said this
value must be used (exactly) once, and we never used it.

Different OxCaml configurations handle this differently: strict
configurations treat the leak as an error, the default emits a
warning of the form "this expression has type `t @ once` and is
not used." Either way, the leak is visible to the type system,
unlike in vanilla OCaml where a forgotten close is a silent
file-descriptor leak.

:::slide

## Three bugs, all caught

| Bug | What | Compiler says |
|---|---|---|
| Double-close | `close t; close t` | "used as once, already used" |
| Use-after-close | `close t; read t ...` | same |
| Forgot to close | discard the final handle | "expression of type once is not used" |

The C versions of these bugs ship to production. The OxCaml
versions do not compile.

:::

## Linearity vs uniqueness: why both?

The 2025-06-04 blog post devotes a section to this question. The
short answer: each axis captures something the other does not.

**Uniqueness gives modular reasoning.** From
`val free : 'a t @ unique -> unit` alone, you know `free` cannot
create a dangling alias: the input had no aliases to begin with.
You do not need to inspect the rest of the library.

**Linearity gives use-once guarantees that survive aliasing.** A
`@ once` handle may have aliases (someone earlier in the program
might have copied it), but the *binding the compiler is tracking*
will be used at most once. The downstream uses go through that
binding; the type system bookkeeps the count.

For some APIs, uniqueness is the right tool: anything resembling
`free`, `destroy`, `drop` where the *resource* is what is being
finalised. For others, linearity is the right tool: anything
resembling a *protocol* with a final step, like `close` on a
handle, `commit` on a transaction, `consume` on a generator.

And for some APIs, you want both. The file-handle module above is
actually a candidate for *both* uniqueness and linearity: the
handle should have no aliases (uniqueness) *and* be used at most
once on each thread of execution (linearity). The minimal version
in this lecture is the linearity-only one; M11-L05's tutorial
combines them.

:::slide

## Uniqueness vs linearity: when to reach for each

| Axis | Tracks | Best for |
|---|---|---|
| **Uniqueness** | Past aliasing | `free`-style APIs; modular reasoning |
| **Linearity** | Future uses | `close`-style protocols; sequence-of-ops |

Often combined. The next lecture builds an API that uses both.

:::

## The closure-capture rule revisited

In M11-L03 we saw that a closure capturing a unique value becomes
`once`. That rule sits squarely on the linearity axis. Here is the
phenomenon stated in linearity terms.

A closure that captures a once-value (or a unique value, which is
related) has the future use of that value built into it. Each call
to the closure uses the captured value once. If the captured value
is at mode `once`, the closure must be at mode `once`, because
calling it twice would use the captured value twice.

This is automatic: you do not annotate the closure as `once`; the
compiler infers it from the captures.

```ocaml
(* Press Run; the closure captures a once-handle and is itself
   forced to mode once, so a second call fails to type-check. *)
let use_it () =
  let t = Handle.open_ "data.txt" in
  let f = fun () -> Handle.close t in
  f ();
  f ()                  (* type error: f is once, already used *)
```

The function `f` has been given mode `once` because it captures a
`once` handle. The second call is rejected. This is the same shape
as the `wat` example from M11-L03, but stated on the linearity
axis instead of the uniqueness axis.

:::slide

## Closure capture forces `once`

A closure that captures a `once` value has mode `once`.
A closure that captures a `unique` value has mode `once`.

```ocaml
(* Same shape as the use_it example above; press Run to see the
   second call rejected. *)
let demo_capture () =
  let t = Handle.open_ "data.txt" in
  let f = fun () -> Handle.close t in
  f ();
  f ()           (* type error: f used twice *)
```

The rule keeps you from sneaking a once-resource through a normal
function value.

:::

## A brief comparison to Rust's ownership

If you have written any Rust, the linearity story will feel
familiar. Rust's ownership model is, in a precise sense, a linear
type system in disguise. When a Rust function takes ownership of
a value (`fn f(x: T)`), the value is "moved" into the function;
the caller cannot use the original binding afterward. Rust's
compiler tracks this just like OxCaml's compiler tracks `once`.

The differences are mostly cosmetic. Rust packages ownership into
the type itself: a `Box<T>` and a `&T` are different types. OxCaml
factors ownership out into a separate *mode*: a `t` and a
`t @ once` are the *same type* used at different modes. The
factoring matters for backward compatibility (an OxCaml program
can use a value at `many` or `once` depending on context, without
changing the type) and for expressing more flexible policies.

The other difference: Rust has *exactly one* axis (ownership +
borrowing). OxCaml has five, of which we are covering three.
Rust's single axis is opinionated and well-integrated; OxCaml's
factoring gives more design freedom, at the cost of more axes to
remember.

For the purposes of this course, the *intuition* you build for
linearity here transfers to Rust if you ever read Rust code. The
"this value moves; you can't use it twice" mental model is the
same.

:::slide

## Linearity ≈ Rust's move semantics

| Rust | OxCaml |
|---|---|
| `fn f(x: T)` moves `x` | `f : t @ once -> ...` consumes `t` |
| `x` cannot be used after the move | binding cannot be referenced after consumption |
| One axis (ownership + borrowing) | Five axes; linearity is one of them |

Same underlying idea: track which uses are still live.

:::

## A footnote: where linearity comes from

Linear logic was introduced by Jean-Yves Girard in 1987 (the paper
is in the reading list). The original motivation was philosophical
and logical: classical logic has the *contraction* rule, which
says that if you can prove a proposition once, you can use the
proof any number of times. Girard noticed that *removing*
contraction leads to a logic where every proposition is *used
exactly once*. He called this *linear logic*, and it turned out to
have deep computational content: a linear proof can be read as a
program that uses its resources exactly once, with no duplication
and no discarding.

Linear logic powered a wave of research into linear type systems
in the 1990s, including the famous *Linear LISP* and Wadler's
*Linear Types Can Change the World*. The practical adoption was
slow: linear types are useful for resource management, but they
make ordinary programming awkward (you cannot freely copy a value,
which is the dominant thing programmers do). The breakthrough was
realising that you can have *both* worlds in one language: most
values at the default `many` mode, a small minority at `once`,
with cheap coercion `many ⊑ once` and rules for promoting one to
the other when needed.

OxCaml's linearity is this practical packaging of the 1987 idea.
The 2022 ESOP paper *Linearity and Uniqueness: An Entente
Cordiale* by Marshall, Vollmer, and Orchard, which we cited in
M11-L03, brings the linearity and uniqueness threads together in
one formal system: that paper is the academic mirror of what
OxCaml ships.

:::slide

## Where linearity comes from

- **Girard, 1987**: linear logic. Drop contraction; every
  proposition used once.
- **Wadler, 1990s**: linear types in programming.
- **OxCaml, 2024+**: linearity as one of five mode axes,
  cooperating with the rest.

The intuition has been around for thirty-five years. The
production deployment is recent.

:::

## Activity

:::quiz mcq id=M11-L04-q1
Given the `Handle` signature in this lecture, which client
compiles?

```ocaml skip
(* A *)
let a () =
  let t = open_ "f" in
  let _, t = read t 10 in
  let _, _ = read t 10 in
  ()

(* B *)
let b () =
  let t = open_ "f" in
  let _, t = read t 10 in
  close t

(* C *)
let c () =
  let t = open_ "f" in
  let s1, _ = read t 10 in
  let s2, _ = read t 10 in
  s1, s2
```

- [ ] A only.
- [x] B only.
- [ ] C only.
- [ ] All three.

**Why:** A has a problem at the end: the second `read t 10` binds
the fresh handle to `_`, discarding it. That is the leak case: a
`once` value is discarded without being consumed. The compiler
warns (or errors). C is worse: the first `read t 10` already
consumes `t`, then C tries to call `read t 10` again on the
original `t`. That is a use-after-consume. B is correct: `read`
threads the fresh handle into the shadowed `t`, then `close`
consumes it.
:::

:::quiz mcq id=M11-L04-q2
Inside a function `f`, the type checker reports that `f` itself
has mode `once`, even though you did not annotate it. Which of
these is the most likely cause?

- [ ] `f` is defined at top level.
- [ ] `f`'s body contains a side effect.
- [x] `f` captures a `once`-mode value from its enclosing scope.
- [ ] `f` returns a value of type `unit`.

**Why:** The rule is: a closure's mode on the linearity axis is at
least as restrictive as the modes of the values it captures. If
the closure captures a `once` value (typically by referencing a
resource defined in the enclosing scope), the closure becomes
`once`. The other options are unrelated to linearity. Top-level
position, side effects, and return types do not by themselves
force `once`.
:::

:::slide

## Activity discussion

- Threading the handle correctly through `read` is the same shape
  as the `Unique_ref` ownership chain.
- A closure capturing a `once` value becomes `once`. This is the
  rule that bridges into the closure-capture pitfall from M11-L03.

:::

## Common pitfalls

**Pitfall 1: "Once and unique are the same."** They are not. Once
is about *future use*; unique is about *past aliasing*. A value
can be aliased in the past and `once` in the future. A value can
be unique and used many times. The two axes are independent.

**Pitfall 2: "I can store a `once` value in a record."** You can,
but the record then becomes `once`. Linearity propagates into
containers, so a record carrying a `once` field is itself `once`.
This often surprises programmers used to vanilla OCaml's
permissive treatment of records.

**Pitfall 3: "Returning a `once` value is fine."** It can be, but
only if the *caller* threads it onwards. A function whose return
type is `t @ once` produces a once-handle for the caller to
consume; the caller must respect the discipline or the program
fails to type-check.

**Pitfall 4: "Linearity prevents efficient mutation."** Quite the
opposite: a `once`-mode binding can be safely destructively
updated in place, because the compiler has guaranteed there is no
later use. Linearity *enables* in-place updates that would
otherwise be unsafe.

## What's next

The final lecture of M11 (M11-L05) is the tutorial. We will build
a complete file-handle module using both linearity *and* locality:
the handle is `once` (cannot be used twice) *and* `local` (cannot
escape the scope it was opened in). We will walk through three
attempts to misuse the API and see the compiler reject each.

Then we will turn to a `malloc`-style buffer API and ask you to
design one for yourselves, with the type system rejecting
double-free, use-after-free, and escape.

:::slide

## What's next

- Lecture 5: tutorial. A file-handle API combining linearity and
  locality, plus a buffer-API design exercise.

:::

## Reading

- **KC Sivaramakrishnan**, *Linearity and uniqueness* (2025-06-04),
  the *A linear ref* and *Why both linearity and uniqueness?*
  sections in particular:
  <https://kcsrk.info/ocaml/modes/oxcaml/2025/06/04/linearity_and_uniqueness/>
- **Jane Street blog**, *Oxidizing OCaml: ownership*:
  <https://blog.janestreet.com/oxidizing-ocaml-ownership/>
- **Jean-Yves Girard**, *Linear logic* (1987), the foundational
  paper:
  <https://www.sciencedirect.com/science/article/pii/0304397587900454>
- **Wadler**, *Linear Types Can Change the World* (1990), a
  classic early treatment of linear types in programming:
  <https://homepages.inf.ed.ac.uk/wadler/papers/linear/linear.ps>

## Sources

The `Handle` module shape and the three-bug walkthrough are
adapted from the CS6868 OxCaml handout (the instructor's own
teaching material). The linearity-vs-uniqueness contrast and the
past-vs-future framing are paraphrased from the instructor's
2025-06-04 blog post. The historical footnote on Girard, Wadler,
and the long arc of linear types is original to this course but
relies on standard public-domain history. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
