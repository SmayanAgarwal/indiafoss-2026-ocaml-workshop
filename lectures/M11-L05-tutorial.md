---
title: "Tutorial: a resource-management API"
lecture_no: 5
week: 11
duration_target_min: 25
concepts: [tutorial, file handle, linearity, locality, manual resource management, API design]
keywords: [OCaml, OxCaml, tutorial, file handle, malloc, buffer, once, local, exclave_]
activity_question: "Design a buffer API where `alloc` produces a heap buffer, `read` and `write` take the buffer, and `free` releases it. Which OxCaml mode(s) would prevent a use-after-free of the buffer?"
think_about_this: "You are writing a library with a C-style `malloc`/`free` interface, but in OxCaml. Sketch the signatures of `malloc`, `read`, `write`, `free` so that the compiler statically refuses double-free, use-after-free, and escape of the buffer beyond its allocation scope."
reading:
  - title: "OxCaml documentation, modes overview"
    url: https://oxcaml.org/documentation/modes/
  - title: "CS6868 OxCaml handout (KC Sivaramakrishnan)"
    url: https://github.com/kayceesrk/cs6868_s26
---

# Tutorial: a resource-management API


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Tutorial: a resource-management API</h2>
<p class="title-slide-label">Module 11 &middot; Lecture 5</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The previous four lectures introduced three mode axes and worked
small examples for each. This tutorial brings them together in a
single API: a file-handle module that uses **linearity** to enforce
"open once, close once" and **locality** to keep the handle from
escaping its scope. We will design the signature, sketch the
implementation, and then try to break the API in three different
ways. Each attempt is a type error.

The lecture closes with a design exercise: a `malloc`-style buffer
API, with the same shape, that you design and the type system
checks.

:::slide

## Today's plan

1. Design a `Handle` module: linearity + locality.
2. Sketch the implementation.
3. Break the API three ways; watch the compiler reject each.
4. Compare to the C version.
5. Design exercise: a `malloc`-style buffer API.

:::

## The design problem

We want a file-handle module that delivers four guarantees:

1. **Open exactly once.** Every successful `open` produces a fresh
   handle.
2. **Close exactly once.** Every handle must be closed; closing
   twice is an error.
3. **No use after close.** Reading or writing after close is an
   error.
4. **No handle escape.** The handle cannot leak out of the scope
   where the file was opened. It cannot be stored in a global
   `ref`, captured in a closure that outlives the scope, or
   returned by enclosing functions.

Guarantees (2) and (3) are *linearity*. Guarantees (4) is
*locality*. (1) falls out automatically: each successful call to
`open_` constructs a brand-new handle, so the "exactly once" is
the constructor itself, not something the type system has to
enforce after the fact.

The two axes compose. A `t @ once @ local` is the combination: at
most one further use *and* may not escape the current scope.

:::slide

## The four guarantees

| Guarantee | Axis |
|---|---|
| Open exactly once | (automatic) |
| Close exactly once | linearity |
| No use after close | linearity |
| No handle escape | locality |

Combined annotation: `t @ once @ local`.

:::

## The signature

Here is the module type, in the OxCaml dialect we have been using:

```ocaml
module type Handle = sig
  type t

  val open_ : string -> t @ once @ local
  (** [open_ path] opens a file at [path] and returns a
      once-usable, local handle. *)

  val read : t @ once @ local -> int -> string * t @ once @ local
  (** [read t n] consumes the handle, reads [n] bytes, returns
      the bytes and a fresh handle. *)

  val write : t @ once @ local -> string -> t @ once @ local
  (** [write t s] consumes the handle, writes [s], returns a
      fresh handle. *)

  val close : t @ once @ local -> unit
  (** [close t] consumes the handle and closes the file. *)
end
```

Read each line carefully; this is the centrepiece of the tutorial.

- `open_` returns a *fresh* `t @ once @ local`. The handle is
  once-usable (linearity guarantee) and local (cannot escape the
  scope of the caller of `open_`).
- `read` *consumes* the handle (takes it at mode `once`) and
  returns a string plus a *fresh* handle for chaining further
  operations. The returned handle is again `once @ local`.
- `write` is parallel to `read`: consume, return a fresh handle.
- `close` consumes the handle and returns `unit`. No fresh handle.
  After `close`, no handle exists.

The combined `once @ local` means: each operation takes a handle
that is in this scope and has at most one more use; each
non-close operation returns a fresh one for the next step; `close`
ends the chain.

:::slide

## The signature

```ocaml skip
val open_ : string -> t @ once @ local
val read  : t @ once @ local -> int -> string * t @ once @ local
val write : t @ once @ local -> string -> t @ once @ local
val close : t @ once @ local -> unit
```

- `@ once`: at most one further use.
- `@ local`: cannot escape the caller's scope.
- Composed: at most one use, in this scope.

The ownership chain threads the handle through each call.

:::

## The implementation

The implementation is mostly mechanical. We need a representation
type for the handle and four operations.

A note on the body. In a production setting you would wrap a
`Unix.file_descr`: `open_` would call `Unix.openfile`, `read`
would call `Unix.read`, `write` would call `Unix.write_substring`,
and `close` would call `Unix.close`. The browser toplevel we are
using does not ship a real `Unix` module, so the cell below uses
an **in-memory mock**: the handle carries a mutable `Bytes`
buffer plus a position cursor; `read` slices bytes out, `write`
appends, `close` is a no-op. The mode discipline we are studying
is entirely independent of the backing: swapping the body for
real I/O would not change a single mode annotation. The compiler
checks the signature; the runtime can be trivial.

```ocaml
module Handle : Handle = struct
  type t = {
    mutable buf : Bytes.t;
    mutable pos : int;
  }

  let open_ _path =
    (* In production: Unix.openfile path [Unix.O_RDWR] 0o600 and
       store the fd. Here: a fresh, empty Bytes buffer.
       exclave_ places the record in the caller's region. *)
    exclave_ { buf = Bytes.create 0; pos = 0 }

  let read t n =
    (* In production: Unix.read t.fd buf 0 n. Here: slice from
       the in-memory buffer. *)
    let avail = Bytes.length t.buf - t.pos in
    let take = if n < avail then n else avail in
    let s =
      if take <= 0 then ""
      else Bytes.sub_string t.buf t.pos take
    in
    t.pos <- t.pos + take;
    exclave_ (s, t)

  let write t s =
    (* In production: Unix.write_substring t.fd s 0 (length s).
       Here: append to the in-memory buffer. *)
    let extra = Bytes.of_string s in
    t.buf <- Bytes.cat t.buf extra;
    t.pos <- t.pos + String.length s;
    exclave_ t

  let close _t =
    (* In production: Unix.close t.fd. Here: nothing to release. *)
    ()
end
```

A few points to note.

First, `open_` *allocates* a fresh record using `exclave_`. The
`exclave_` keyword places the record in the *caller's* region, not
in `open_`'s own region. The caller's region is the scope where
the handle is to be used; the handle therefore lives long enough.

Second, `read` returns a pair `(string, t)`. By the locality
rules, this pair, the string, and the `t` should all be in the
caller's region. The `exclave_` on the return takes care of it.

Third, `close` does not return a fresh handle, and does not need
`exclave_`. The handle is consumed; nothing flows back.

Fourth, mutation of `t.pos` is fine because `t` is `once` at the
function boundary: the compiler knows there is no parallel reader
or writer.

The implementation type-checks against the signature. The compiler
verifies that each function respects the mode annotations:
specifically, that the handle threads through correctly, that
nothing escapes its scope, and that the locality story holds for
returned values.

:::slide

## The implementation (sketch)

```ocaml skip
let open_ _path =
  exclave_ { buf = Bytes.create 0; pos = 0 }

let read t n =
  let s = Bytes.sub_string t.buf t.pos n in
  t.pos <- t.pos + n;
  exclave_ (s, t)

let close _t = ()
```

`exclave_` lets each operation return a value in the caller's
region. The compiler checks the mode discipline against the
signature.

:::

## Correct usage

Here is a client that opens a file, writes some bytes, reads them
back, and closes:

```ocaml
let example () =
  let t = Handle.open_ "scratch.txt" in
  let t = Handle.write t "hello" in
  let s, t = Handle.read t 5 in
  Handle.close t;
  s
```

Each line threads the handle through. The handle never leaves
`example`'s scope (locality is satisfied). The handle is used
exactly once at each step, and is finally consumed by `close`
(linearity is satisfied). The string `s` does not carry any
locality constraint (strings are heap-allocated values that escape
freely; the freshly-allocated buffer in `read`'s implementation is
returned via `exclave_`, but a string is a value type that can be
freely globalised), so it returns to the caller of `example`
cleanly.

:::slide

## Correct usage

```ocaml
let example () =
  let t = Handle.open_ "scratch.txt" in
  let t = Handle.write t "hello" in
  let s, t = Handle.read t 5 in
  Handle.close t;
  s
```

- Handle never escapes `example`.
- Each step consumes and rebinds the handle.
- `close` ends the chain.

:::

## Three bugs, three type errors

Now the misuse cases. Each is a real bug pattern in C, with a real
CVE per category somewhere in the wild. Each is a type error in
OxCaml.

### Bug 1: double-close

```ocaml
(* Press Run; linearity rejects the second close. *)
let double () =
  let t = Handle.open_ "scratch.txt" in
  Handle.close t;
  Handle.close t
```

The compiler responds with a message of the form

> Error: This value is used here, but it is defined as once and
> has already been used.

The first `close t` consumed the handle. The second `close t` is
attempting to use it again. Linearity rejects it.

The C version of this bug is the standard `fclose` / `fclose`
pattern. On Linux, the second close may close some *other* file
descriptor that the kernel has reassigned to the same integer.
This has produced a class of CVEs around file-handle confusion
attacks. One representative example is
[CVE-2020-1472 ("Zerologon")](https://nvd.nist.gov/vuln/detail/CVE-2020-1472),
a Netlogon cryptographic-authentication bypass in Windows
domain controllers where a flawed handle-management path was
part of the exploit chain. The OCaml signature above forbids
the double-close at compile time.

### Bug 2: escape attempt

```ocaml
(* Press Run; locality refuses to let a local handle land in a
   long-lived global cell. *)
let bad_storage : Handle.t ref = ref (Handle.open_ "init.txt")

let escape () =
  let t = Handle.open_ "scratch.txt" in
  bad_storage := t
```

Two things go wrong here. First, the top-level `bad_storage`
declaration itself fails: `Handle.open_` returns a `t @ local`,
which cannot land in a top-level mutable cell (top-level cells are
global). Second, even if we tried inside `escape`, the assignment
fails, with a message of the form

> Error: This value is local because it is the result of
> Handle.open_.
> However, the highlighted expression is expected to be global
> because it is being stored in a long-lived mutable cell.

The C version of this is "save the `FILE *` in a global so we can
close it later." It works in C: file descriptors persist across
function boundaries. The OxCaml locality story disallows it,
because the locality contract on the handle says the handle's
scope is the opening function. If you want a longer-lived handle,
you would need a different API: one that returns the handle at
mode `global`, accepting that it may now be aliased and escape.
The point of the `local` annotation is that the *protocol* of
this particular API is "open and close in one scope."

### Bug 3: use-after-close

```ocaml
(* Press Run; same shape as bug 1, different surface form. *)
let uaf () =
  let t = Handle.open_ "scratch.txt" in
  Handle.close t;
  let _, _t = Handle.read t 10 in
  ()
```

The compiler responds with the same "used as once, already used"
shape of error. `close` consumed the handle, and `read t` is
trying to use it. Linearity rejects.

The C version of use-after-close is one of the most common
practical bugs: a logging library closes its file descriptor on
shutdown, but another thread is still trying to write logs. The
behaviour is unpredictable: bytes go to /dev/null, or to a *different*
file the kernel has reassigned to the same number, or the program
SIGSEGVs. With OxCaml, the bug does not compile.

:::slide

## Three bugs, three type errors

| Bug | C version | OxCaml verdict |
|---|---|---|
| Double-close | `fclose(f); fclose(f)` | Linearity error |
| Escape | save `FILE *` in a global | Locality error |
| Use-after-close | `fclose(f); fread(...,f)` | Linearity error |

The C versions ship to production. The OxCaml versions fail at
compile time.

:::

## Comparison to C's `FILE *`

A direct comparison may help cement the lesson. Here is the
file-handle protocol in C:

```c
FILE *fopen(const char *path, const char *mode);
size_t fread(void *ptr, size_t size, size_t count, FILE *stream);
size_t fwrite(const void *ptr, size_t size, size_t count, FILE *stream);
int fclose(FILE *stream);
```

What does C's type system tell you about these functions? Each
takes a `FILE *`. Each returns something. Nothing in the type says
"this pointer must be closed once," "this pointer must not be used
after close," "this pointer must not escape any particular scope."
The protocol is a programmer convention, enforced by code review
and runtime checking (or, far more often, by the bug reports that
arrive after deployment).

The C standard library does provide *some* runtime checks. `fclose`
sets `errno` and returns `EOF` if you close a handle that was
already closed. Some libc implementations harden against double-
free of `FILE` structs. But all of this is opt-in: a program that
ignores the return value of `fclose` (most programs do) gets no
benefit. And none of it catches the use-after-close pattern, which
is the most dangerous of the three.

Compare with the OxCaml signature (this is the same `Handle`
module type we wrote above; rebinding it under a fresh name lets
us put the signature side by side with the C prototypes):

```ocaml
module type Handle_recap = sig
  type t
  val open_ : string -> t @ once @ local
  val read  : t @ once @ local -> int -> string * t @ once @ local
  val close : t @ once @ local -> unit
end
```

The signature *is* the protocol. Reading the signature is reading
the rules. Violating the rules fails to compile. There is no
"hope the programmer reads the docs"; the type checker is the doc
reader.

:::slide

## C vs OxCaml: the type-system delta

| Property | C `FILE *` | OxCaml `Handle.t` |
|---|---|---|
| "Close exactly once" | docs + hope | linearity |
| "No use after close" | runtime check (sometimes) | linearity |
| "Local to scope" | not expressible | locality |
| Bugs found at | runtime, in production | compile time |

The protocol of use is now part of the type signature.

:::

## What this style buys you in practice

A short list of where this kind of API discipline pays off.

**Database connections.** A pooled connection has the same
protocol as a file handle: borrow from pool, use, return. A
`Pool.conn @ once @ local` enforces the protocol at the type
level. Forgetting to return a connection or returning it twice is
a type error.

**Cryptographic keys.** A key material handle should not be
captured in a long-lived closure (locality), should be destroyed
in a known scope (linearity), should not be duplicated (a
combination of uniqueness and linearity, depending on the
threat model).

**Mapped memory.** A `mmap`'d region must be `munmap`'d exactly
once. Sound familiar? Same protocol; same `once @ local`
signature.

**Iterators over external state.** A cursor into an external
database, an iterator over a file's directory entries, a handle
to a network stream that produces messages: each is a candidate
for the linearity/locality treatment.

The pattern recurs because the underlying *protocol* recurs.
OxCaml's mode system lets you express the protocol in the type.
Once you have the type, the compiler enforces it.

:::slide

## Where this pattern recurs

- Database connection pools
- Cryptographic key material
- `mmap`'d memory regions
- External-state iterators
- TLS / TCP sockets
- DMA buffers from device drivers
- Lock handles in capsule-based concurrency

Same protocol; same `once @ local` signature.

:::

## Design exercise: a `malloc`-style buffer

Now your turn. Design the OxCaml signature for a buffer API with
this informal description:

- `Buffer.alloc n` allocates an `n`-byte buffer.
- `Buffer.read b i` reads byte at index `i`.
- `Buffer.write b i x` writes byte `x` at index `i`.
- `Buffer.free b` frees the buffer.

The type system should statically prevent:

1. Double-free.
2. Use-after-free.
3. The buffer escaping the scope it was allocated in.

A skeleton signature is provided below. Fill in the modes.

:::slide

## Design exercise

Design `Buffer` with:

```ocaml skip
val alloc : int -> ???
val read  : ??? -> int -> char * ???
val write : ??? -> int -> char -> ???
val free  : ??? -> unit
```

The compiler should reject:
- double-free
- use-after-free
- escape from the allocation scope

What mode annotations do you put where?

:::

:::quiz code id=M11-L05-q1
Fill in the `Buffer` signature with the right OxCaml mode
annotations so that the API enforces "no double-free, no
use-after-free, no escape." The signature shape (one operation per
line) is provided; only the annotations need to change. Replace
each `failwith "..."` with the correct line.

```ocaml
(* For grading, return a list of strings representing the lines
   of the module signature, in order. Each string is one line
   of the signature, with the right mode annotations. *)
let buffer_signature : string list =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m

let () =
  let lines = buffer_signature in
  check (List.length lines = 4)
    "expected four signature lines";
  let l1 = List.nth lines 0 in
  let l2 = List.nth lines 1 in
  let l3 = List.nth lines 2 in
  let l4 = List.nth lines 3 in
  let has substring s =
    let lsub = String.length substring in
    let ls = String.length s in
    let rec scan i =
      if i + lsub > ls then false
      else if String.sub s i lsub = substring then true
      else scan (i + 1)
    in scan 0
  in
  check (has "alloc" l1 && has "@ once" l1 && has "@ local" l1)
    "line 1 must declare alloc returning a once+local buffer";
  check (has "read" l2 && has "@ once" l2 && has "@ local" l2)
    "line 2 must declare read consuming and returning once+local";
  check (has "write" l3 && has "@ once" l3 && has "@ local" l3)
    "line 3 must declare write consuming and returning once+local";
  check (has "free" l4 && has "@ once" l4 && has "@ local" l4)
    "line 4 must declare free consuming a once+local buffer";
  print_endline "all tests passed"
```
:::

The intended answer looks roughly like this (the test cell only
checks that the right modes appear on each line; you can phrase the
types however you like, but each operation should accept a buffer
at `@ once @ local`, and the non-`free` operations should return a
fresh `@ once @ local` buffer):

```ocaml
module type Buffer = sig
  type t
  val alloc : int -> t @ once @ local
  val read  : t @ once @ local -> int -> char * t @ once @ local
  val write : t @ once @ local -> int -> char -> t @ once @ local
  val free  : t @ once @ local -> unit
end
```

Read off what each annotation buys:

- `alloc` returns a fresh `t @ once @ local`. The buffer cannot
  escape the calling scope (locality); it has at most one further
  use (linearity).
- `read` consumes the buffer and hands back a fresh `once @ local`
  one, plus the value at the index. The ownership chain threads
  through.
- `write` is parallel to `read`.
- `free` consumes the buffer, returns `unit`. No fresh buffer.
  After `free`, no `once @ local` binding exists.

Double-free: linearity error (same as double-close in the
file-handle example). Use-after-free: linearity error. Escape:
locality error.

:::slide

## The intended buffer signature

```ocaml skip
val alloc : int -> t @ once @ local
val read  : t @ once @ local -> int -> char * t @ once @ local
val write : t @ once @ local -> int -> char -> t @ once @ local
val free  : t @ once @ local -> unit
```

Same shape as `Handle`. The compiler rejects every bug class we
listed.

:::

## Module summary

We have spent the module on three OxCaml mode axes:

- **Locality** (M11-L02): tracks whether a value escapes its
  scope. Replaces the C `return &x` bug. Lets you stack-allocate
  short-lived values safely.
- **Uniqueness** (M11-L03): tracks whether a value has been
  aliased in the past. Replaces use-after-free and double-free for
  manually managed resources. Gives modular reasoning from
  signatures alone.
- **Linearity** (M11-L04): tracks whether a value will be used
  again in the future. Replaces use-after-close, double-close,
  and forgotten-close. Provides the protocol vocabulary for
  resource APIs.

Three axes, five modes total (`global` / `local`,
`aliased` / `unique`, `many` / `once`), each independent. The
compiler checks all of them simultaneously. The cost is zero at
runtime; the benefit is whole categories of bugs becoming
impossible.

There are two more axes we did not cover in this course:
**contention** and **portability**, which deliver compile-time
data-race freedom. The same shape of argument applies: a runtime
discipline (locking) becomes a compile-time invariant. If you
want to follow up, the CS6868 OxCaml handout linked at the top of
this lecture is the most comprehensive treatment.

:::slide

## Module 11 summary

| Axis | Default | Strict | Tracks | Replaces C bug |
|---|---|---|---|---|
| Locality | `global` | `local` | Escape | `return &x` |
| Uniqueness | `aliased` | `unique` | Past aliasing | use-after-free, double-free |
| Linearity | `many` | `once` | Future use | use-after-close, double-close |

Three axes, zero runtime cost, whole categories of bugs become
type errors.

:::

## What's next

Module 11 closes the "type-level safety" half of the course. The
next module (M12) zooms out: if OCaml plus OxCaml is this safe,
what falls out if you write the *operating system* itself in
OCaml? The answer is **unikernels**, and that is where we go next.

:::slide

## What's next

- Module 12: **Unikernels (MirageOS)**. What an OS looks like
  when the whole stack is written in safe OCaml.

:::

## Reading

- **OxCaml documentation**, the modes overview:
  <https://oxcaml.org/documentation/modes/>
- **CS6868 OxCaml handout** (KC Sivaramakrishnan), the
  comprehensive treatment including contention, portability,
  capsules, and fork-join parallelism:
  <https://github.com/kayceesrk/cs6868_s26>
- **OxCaml ICFP 2025 tutorial**, the hands-on exercises:
  <https://github.com/oxcaml/tutorial-icfp25>
- The two blog posts that anchored M11-L01 and M11-L03 / L04
  (linked in those lectures).

## Sources

The `Handle` API shape, the three-bug walkthrough, and the
`Buffer` design exercise are original to this course, structured
to combine the locality material from CS6868 Part 1 and the
linearity / uniqueness material from CS6868 Part 3 (the
instructor's own teaching material, freely reusable). The C-versus-
OxCaml comparison and the module-summary recap are original. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
