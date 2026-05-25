---
title: "Where OCaml itself has UB"
lecture_no: 4
week: 10
duration_target_min: 25
concepts: [Obj.magic, Marshal, FFI, data races, unsafe fragment, escape hatch, runtime invariants]
keywords: [OCaml, Obj.magic, Marshal, FFI, external, Ctypes, data race, ref, memory model, undefined behaviour, unsafe]
activity_question: "Every memory-safe language has at least one escape hatch: Rust has `unsafe`, Java has `sun.misc.Unsafe`, C# has `unsafe`, Haskell has `unsafePerformIO`. What is OCaml's, and how small can the auditable unsafe core actually be?"
think_about_this: "If the safe fragment of OCaml rules out the four canonical memory bugs, why does the language ship `Obj.magic` at all? What is it for, who uses it, and what would have to change for it to be removable?"
reading:
  - title: "OCaml manual, Module Obj"
    url: https://v2.ocaml.org/api/Obj.html
  - title: "OCaml manual, Module Marshal"
    url: https://v2.ocaml.org/api/Marshal.html
  - title: "Real World OCaml, Foreign Function Interface"
    url: https://dev.realworldocaml.org/foreign-function-interface.html
  - title: "OCaml manual, The memory model for the multicore runtime"
    url: https://v2.ocaml.org/manual/memorymodel.html
---

# Where OCaml itself has UB


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Where OCaml itself has UB</h2>
<p class="title-slide-label">Module 10 &middot; Lecture 4</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The last lecture made the safety story precise: in the *safe
fragment* of OCaml, the four canonical memory bugs are ruled out
by construction. This lecture is the honest boundary. Every
memory-safe language has at least one escape hatch from its own
safety guarantees, and OCaml is no exception. The hatches exist
for good reasons; they are also where, if you push hard enough,
you can crash the runtime, corrupt invariants, and reproduce the
class of bug the rest of the language excludes.

This is not a betrayal of the safety story. It is the consequence
of being a *practical* language: real programs need to talk to C,
serialise values across processes, and occasionally do something
the type system was not designed to express. The design question
is not "should the unsafe operations exist?" but "how small can the
unsafe surface be, and how syntactically obvious can each unsafe
operation be, so that a code reviewer can spot it instantly?"

This lecture walks the four places OCaml itself admits undefined
behaviour: `Obj.magic`, races on shared mutable state across
domains, `Marshal`, and the FFI. For each one, what it does, why
the language ships it, what goes wrong if you misuse it, and how
to keep the unsafe core small in production code.

:::slide

## Where we are

- M10-L03: the safe fragment is safe by construction.
- M10-L04: the *unsafe fragment* exists, and is explicit.
- Four places to look:
  - `Obj.magic` (arbitrary type casts)
  - Races on `ref` across domains
  - `Marshal` with the wrong type
  - FFI (`external`, Ctypes)
- Principle: keep the unsafe core small and well-audited.

:::

## The principle of the small escape hatch

Before we look at any specific feature, the design principle.

Every memory-safe language ships with an explicit escape from its
own safety guarantees. Rust has the `unsafe` keyword. Java has
`sun.misc.Unsafe`. C# has the `unsafe` block. Haskell has
`unsafePerformIO` and `unsafeCoerce`. Go has the `unsafe` package.
The escape exists because some operations (interfacing with C,
implementing collection primitives, mapping memory) genuinely
require it, and a language that refused to ship them would simply
be ignored by anyone who needs those operations.

The design goal is to make the escape *small*, *syntactically
loud*, and *auditable*. Small, so most programs do not touch it.
Loud, so a code reviewer sees it on the page. Auditable, so a
security review can grep for the unsafe operations and inspect
them.

OCaml's unsafe operations are each named to be obvious. The module
is called `Obj`, with one function literally called `magic`. The
serialisation module is called `Marshal`. The C-binding keyword is
called `external`. None of these names hide what they do; they
exist so the careful reader notices them.

:::slide

## The small-escape-hatch principle

| Language | Escape hatch |
| --- | --- |
| Rust | `unsafe { ... }` |
| Java | `sun.misc.Unsafe` |
| C# | `unsafe` block |
| Haskell | `unsafePerformIO`, `unsafeCoerce` |
| Go | `unsafe` package |
| **OCaml** | `Obj.magic`, `Marshal`, `external` |

- Each is syntactically loud.
- Each is rare in code review.
- *Grep-ability is the audit story.*

:::

## `Obj.magic`: arbitrary type casts

The `Obj` module exposes the runtime's view of values. It treats
every OCaml value as a generic `Obj.t` and lets you inspect tags,
field counts, and field contents directly. The one function in
this module that matters for our discussion is:

```ocaml
val Obj.magic : 'a -> 'b
```

The type signature is the whole story. It takes any value of any
type `'a` and returns it, claiming the result has any type `'b`.
The runtime does nothing: the bytes of the input value are
returned unchanged, with the type system fooled into believing
they have the new type. If the runtime representation of `'a` and
`'b` happens to coincide, the cast is "safe" in the sense that the
result behaves as a valid value of the new type. If they do not
coincide, the result is a value of type `'b` whose underlying
bytes do not correspond to any valid `'b`. Operations on it can
read out-of-bounds, follow garbage pointers, and crash the
runtime.

### A worked example

Let us see what goes wrong. Take an integer and cast it to a list.

```ocaml
let x : int = 42
let l : int list = Obj.magic x
```

In the runtime, `42` is the immediate value `0x55` (the `42`
shifted left and tagged with the low bit set). The type system now
believes `l` is an `int list`. When we ask for its head, the
runtime dereferences the value as if it were a pointer to a cons
cell. It is not; it is the immediate `0x55`. The dereference reads
whatever memory happens to live at address `0x55`, which on a
typical system is unmapped, and the program segfaults.

```ocaml
let _ = List.hd l   (* segfault, garbage read, or random data *)
```

The exact outcome depends on the operating system, the address
space layout, and how recently you ran the program. The point is
that the *runtime invariant* the GC relies on (every pointer
points at a valid heap block with a valid header) has been broken,
silently, by one line of OCaml.

:::slide

## `Obj.magic`, the all-purpose footgun

```ocaml
val Obj.magic : 'a -> 'b
```

- Takes any value, returns the same bytes claiming any type.
- The runtime is unchanged: just lies to the type system.
- A wrong cast violates the runtime's invariants.
- Effect: segfault, garbage read, or arbitrary memory access.

:::

The reason this is so dangerous is that the type system,
elsewhere, *guarantees* that values of a given type have a
specific runtime representation. The pattern-matching compiler
emits code that assumes the value's tag is one of the expected
constructors. The GC assumes pointers point at valid blocks.
Field access assumes the block has the expected layout.
`Obj.magic` undoes all of these assumptions at once, with no
indication to the compiler that an assumption has been violated.

### Why does this exist?

Two historical reasons.

**Low-level FFI helpers.** Before the FFI grew its current type-
safe surface, some interfaces with C needed to manipulate values
at the byte level: extract a field from a boxed record, read the
header tag of a polymorphic variant, write into a string's raw
bytes. These operations are now mostly subsumed by safer
alternatives (`Bytes`, the FFI's `Custom_block` mechanism, the
`Marshal` module), but the `Obj` module remains as the lower
layer they were built on.

**GADT emulation before GADTs landed.** OCaml gained Generalised
Algebraic Data Types in version 4.00 (2012). Before that, some
libraries needed to express "this list contains heterogeneous
elements with a tag describing each one", which the type system
could not express directly. The trick was to box each element with
its tag, type-erase to a uniform representation (often via
`Obj.magic`), and recover the precise type by inspecting the tag
at the use site. The implementation was tedious and error-prone,
but it worked. Modern OCaml uses GADTs for the same pattern with
no `Obj.magic` required.

A small number of legitimate uses remain: some high-performance
library code, certain interactions with the Marshal module, and a
narrow class of FFI helpers. The general advice for application
code is *never use `Obj.magic`*. If you find yourself reaching for
it, the type-system problem you are trying to solve almost
certainly has a GADT or first-class module solution that is safer
and clearer.

:::slide

## Why `Obj.magic` exists at all

- **Pre-GADT type-system gaps**: heterogeneous collections.
- **Low-level FFI helpers**: field extraction, tag inspection.
- **Runtime library plumbing**: parts of the stdlib itself.
- *Modern application code should never need it.*
- *If you are reaching for it: try a GADT or first-class module.*

:::

## Races on shared mutable state

OCaml 5 introduced parallel execution via *domains*. A domain is a
unit of parallelism that gets its own OS thread; multiple domains
execute OCaml code in parallel on multiple cores. With parallelism
comes the possibility of *data races*: two domains accessing the
same memory location without synchronisation, with at least one of
the accesses being a write.

Concurrency is out of this course's scope, so we will not go deep
on the OCaml memory model. The honest acknowledgement, for the
purposes of this lecture, is that two domains writing to the same
`int ref` *is* a data race under the OCaml memory model, and the
read results are not what a sequential intuition would expect.

```ocaml
let r = ref 0
(* domain A: r := 1 *)
(* domain B: r := 2 *)
(* domain C: print_int !r *)
```

Sequential intuition says domain C reads either `0`, `1`, or `2`.
The OCaml memory model agrees in this specific case because of how
OCaml represents integers. But for *boxed* values (records, tuples,
arrays), unsynchronised reads can in principle observe partially
initialised values, in which case the program may crash. The
manual chapter on the memory model is the precise reference.

The OCaml 5 memory model is *DRF-SC*: programs that are
data-race-free behave sequentially-consistently. Programs with
races have weakly-defined behaviour. The model is much stronger
than C++'s "any race is UB" rule: OCaml's racy programs are still
memory-safe (they will not segfault or read uninitialised bytes
from the OS), but the values returned by reads may be unexpected.

The practical advice is the same as in every other parallel
language: introduce synchronisation between the writer and the
reader. The OCaml standard library provides `Atomic` for atomic
references, `Mutex` and `Condition` from the `Stdlib` for locking,
and `Domain` for spawning. The point is not to fear `ref`; it is
to understand that a `ref` shared across domains is *shared
mutable state*, and shared mutable state needs synchronisation
just as it does in any other language.

:::slide

## Races on `ref` (brief)

```ocaml
let r = ref 0
(* domain A:  r := 1     *)
(* domain B:  r := 2     *)
(* domain C:  let v = !r *)
```

- Two writers + one reader, no sync = data race.
- OCaml's model (DRF-SC): racy programs have weakly-defined
  behaviour, but stay **memory-safe**.
- *Mitigation*: `Atomic`, `Mutex`, message passing.
- *Concurrency is out of this course's scope; the OCaml manual's
  memory-model chapter is the reference.*

:::

The reason this lives in the "UB" lecture even though it is not C-
style UB is that, in the multicore era, sloppy sharing is the
most common way a working OCaml program produces surprising
results. The TL;DR: if you spawn domains and let them touch the
same data, learn the memory model first.

## `Marshal`: serialisation without type checks

The `Marshal` module serialises any OCaml value to a string of
bytes, and deserialises bytes back to a value. The encoding is
the runtime's internal block representation, with pointers
relativised and headers preserved. It is fast, deterministic, and
universal: any OCaml value can be marshalled.

```ocaml
val Marshal.to_string   : 'a -> Marshal.extern_flags list -> string
val Marshal.from_string : string -> int -> 'a
```

Read those signatures carefully. `to_string` is polymorphic and
takes a value of any type; that is fine. `from_string` is also
polymorphic in its result type. It takes a string and an offset
and returns a value of type `'a`, where `'a` is whatever the
caller writes down. The runtime *does not check* that the
serialised bytes actually represent a value of the expected
type. It hands the bytes back, with the type system fooled into
believing they have the requested type.

This is structurally the same as `Obj.magic`. Whatever the bytes
encode, `from_string` returns it as if it had the type you asked
for. If the bytes were serialised from an `int list`, and you
deserialise as a `string * float`, the runtime hands you a value
that the type system believes is a `string * float` and that the
runtime believes is an `int list`. Operations on it produce
garbage at best and segfault at worst.

```ocaml
let bytes = Marshal.to_string [1; 2; 3] []
let s : string = Marshal.from_string bytes 0
(* s has the runtime representation of [1; 2; 3]
   but the type system thinks it is a string.
   Any string operation will misbehave. *)
```

:::slide

## `Marshal.from_string` is unchecked

```ocaml
let bytes = Marshal.to_string [1; 2; 3] []
let s : string = Marshal.from_string bytes 0
(* s : string, but the bytes encode [1; 2; 3] *)
```

- The runtime returns the bytes; the type annotation is a lie.
- Wrong type at deserialise = same bug class as `Obj.magic`.
- *The serialised format carries no type tag the reader checks
  against.*

:::

### Version skew is the practical hazard

The clean failure mode (deserialising bytes from `int list` as
`string`) is easy to avoid: do not mix types between the marshal
and unmarshal sites. The hazard that gets people in production is
*version skew*.

Suppose a producer and a consumer of marshalled values are
deployed separately. The producer is upgraded; its definition of
the marshalled type now adds a field, or reorders fields, or
changes a variant constructor. The consumer is still running the
old code with the old type definition. The producer marshals a
value with the new layout; the consumer reads it as if it had the
old layout. The bytes are interpreted at the wrong offsets. The
result is a value that looks like the consumer's type but is, in
fact, garbage; operations on it crash the runtime.

This is not a theoretical concern. It is one of the standard
reasons projects move off `Marshal` to a tagged serialisation
format. The tagged formats (JSON, MsgPack, Protobuf, Cap'n Proto)
all carry enough metadata in the byte stream for the reader to
detect a mismatch and report an error instead of silently
producing garbage.

:::slide

## Version skew: the practical hazard

- Producer and consumer of marshalled bytes deployed separately.
- Producer's type definition evolves; consumer's does not.
- Bytes read at wrong offsets; runtime crashes.
- *This is why production OCaml at boundaries uses tagged
  formats.*

:::

### Practical advice

`Marshal` is fine for *local* use: caching a computed value on
disk between runs of the same binary; sending values between two
processes built from the same source tree; round-tripping a value
through bytes inside one program. In each of those cases the
producer and consumer agree on the type by construction.

`Marshal` is the wrong tool for *boundary* use: storing values in
a database that outlives the program; sending values over the
network between programs with separate release cycles; persisting
values across program upgrades. At boundaries, the recommended
tools in 2026 are:

- **`yojson`** for JSON encoding with hand-written
  encoders/decoders.
- **`jsont`** for typed JSON codecs with one declaration per type.
- **`ppx_deriving`** for auto-derived encoders/decoders.
- Hand-written binary formats with explicit version tags for
  performance-critical paths.

Each of these makes the type contract explicit in the byte stream;
a version mismatch produces a parsing error, not a runtime crash.

:::slide

## When to use, when not

| Use case | `Marshal`? | Alternative |
| --- | --- | --- |
| Cache within one run of one binary | Yes | (nothing simpler) |
| IPC between processes from same build | Yes | (with care) |
| Database, persisted across upgrades | **No** | `yojson`, `jsont` |
| Network protocol between independent programs | **No** | JSON, Protobuf, MsgPack |
| Long-term storage | **No** | Tagged format with version field |

:::

## FFI: calling into C

OCaml's foreign function interface lets you call C from OCaml.
The mechanism is the `external` keyword: a declaration that says
"this OCaml function name corresponds to this C symbol, with this
type."

```ocaml
external my_c_function : int -> int -> int = "caml_my_c_function"
```

The OCaml compiler emits a call to the C symbol; the C side is
expected to follow the OCaml runtime's calling convention (root
registration, GC handshaking, value-representation rules). The
compiler does not, and cannot, check that the C code on the other
side actually obeys these rules.

This is the single largest unsafe surface in real OCaml programs.
Every external library binding (database clients, OpenGL, image
codecs, cryptographic primitives) is FFI. The OCaml side is type-
safe; the C side is C, which means it can do anything that C can
do, which we have spent four lectures cataloguing.

:::slide

## FFI in one declaration

```ocaml
external my_c_function : int -> int -> int = "caml_my_c_function"
```

- `external` keyword: this name is a C symbol.
- Compiler emits a call; trusts the C stub.
- *The C side is C. All C-style UB is in play on that side.*
- Largest unsafe surface in real OCaml programs.

:::

The conceptual model is that OCaml *trusts your stubs*. If the C
function reads off the end of a buffer, OCaml will not catch it.
If the C function holds a pointer to an OCaml value across an
allocation point (where the GC may move the value), OCaml will
not catch it. If the C function double-frees something it
allocated itself, OCaml will not catch it. The safety boundary
moves to the C side of the FFI, and the C side is responsible for
preserving the OCaml invariants.

### Keeping the unsafe core small

Production OCaml mitigates this by structuring code so that the
FFI surface is small and concentrated. The recommended pattern:

1. **Thin C stubs.** Each `external` declaration corresponds to a
   small C function that does the minimum needed: convert OCaml
   values to C values, call the underlying C library, convert
   results back. The stub itself contains as little logic as
   possible.
2. **OCaml wrappers.** Above the stubs, write an OCaml module
   that exposes a *safe* interface. The module's signature does
   not expose raw pointers, raw memory, or any operation whose
   safety depends on C-side discipline.
3. **Type-safe FFI libraries.** Where possible, use a library
   like `ctypes`, which generates the C-side glue from an OCaml
   description of the C ABI. `ctypes` does not eliminate the
   underlying unsafety (the C library can still misbehave), but
   it eliminates a whole class of stub-writing bugs.

A well-organised OCaml application with extensive C bindings has,
in total, a few hundred to a few thousand lines of C stubs. That
is small enough to audit thoroughly and to monitor for changes.

:::slide

## Keeping the FFI core small

- **Thin C stubs**: minimum logic on the C side.
- **OCaml safe wrappers**: hide raw pointers from the rest of the
  program.
- **`ctypes`** when possible: generated stubs from an OCaml ABI
  description.
- **Auditable**: aim for hundreds, not tens of thousands, of lines
  of C in your FFI.

:::

### The handshake with the GC

One specific FFI hazard deserves a sentence: the GC may move OCaml
values during collection. A pointer to an OCaml value, held in a C
local variable across an allocation point, will be left dangling
when the GC moves the value. The convention is to *register* such
pointers with the runtime using the `CAMLparam` and `CAMLlocal`
macros from `<caml/memory.h>`, so the GC knows to update them when
it moves things. Get the registration wrong and you have a UAF
that no amount of OCaml-side discipline can prevent.

This is the deepest reason production OCaml prefers to keep the C
side small: every line of stub code is a place to forget a
`CAMLparam`, and every forgotten `CAMLparam` is a potential
memory-safety bug.

Real World OCaml's chapter on the
[Foreign Function Interface](https://dev.realworldocaml.org/foreign-function-interface.html)
is the standard reference; the OCaml manual's chapter on
*Interfacing C with OCaml* covers the same ground with more
detail.

## The full picture

We can now name OCaml's unsafe surface in one slide.

:::slide

## OCaml's unsafe surface

| Feature | What it lets you do | Audit story |
| --- | --- | --- |
| `Obj.magic` | Arbitrary type cast | Grep for `Obj.magic`; should be empty in app code |
| Races on shared `ref` | Weakly-defined reads across domains | Grep for cross-domain `ref`; require sync |
| `Marshal.from_string` | Read bytes as any type | Grep for `Marshal.from_string`; ban at boundaries |
| `external` (FFI) | Call C | Concentrate in small stubs; audit each |

Everything else in the language is safe by construction
(M10-L03).

:::

The point of laying out the unsafe surface like this is that, in
the language as a whole, it is *small*. Four constructs. A code
reviewer can grep for each of them and find every occurrence in
the entire codebase. There is no fifth hidden hatch; no
`__attribute__((unsafe_but_no_one_will_notice))` like in some
languages. The unsafe operations are named, explicit, and
auditable.

This is the contrast with C, where *every* pointer arithmetic
operation, *every* memcpy, *every* uninitialised local variable
is a potential bug. C has no safe fragment to retreat to. OCaml's
unsafe fragment is a small, well-defined, syntactically loud
subset; the rest of the language is safe.

:::slide

## Compare

- **C**: every pointer operation is potentially unsafe.
- **OCaml**: four specific constructs are potentially unsafe.
  Everything else is safe by construction.
- *That is the engineering value of "memory-safe by default."*

:::

## Activity

:::quiz mcq id=M10-L04-q1
A teammate is reviewing OCaml code and sees this line:

```ocaml
let parsed : Config.t = Marshal.from_string raw_bytes 0
```

`raw_bytes` is a `string` read from a configuration file on disk.
What is the most accurate critique?

- [ ] The type annotation `Config.t` is unnecessary; it should
  be inferred.
- [x] If the on-disk format ever diverges from the current
  `Config.t` definition (across software versions), the read
  will succeed but the resulting value may crash the program
  on any access. Use a tagged format like JSON instead.
- [ ] `Marshal.from_string` is slow; prefer `Marshal.from_bytes`.
- [ ] The offset `0` is wrong; it should be the length of the
  marshal header.

**Why:** the critical issue is version skew. `Marshal.from_string`
returns whatever bytes are in the input, claiming they have the
type the caller writes down. If the producer's `Config.t` and the
consumer's `Config.t` differ (because the config file was written
by a different version of the program, or by hand, or by a
migration script), the bytes are read at the wrong offsets and the
resulting value will crash the runtime on access. Configuration
on disk crosses a version boundary, which is exactly the case
`Marshal` is the wrong tool for. The other options are minor or
incorrect (`Marshal.from_string` works fine, offset `0` is
correct for a value at the start of the string, and the
annotation is required for the polymorphic return).
:::

:::quiz mcq id=M10-L04-q2
Which of the following is *not* part of OCaml's safe fragment?

- [ ] `Array.get`, which raises `Invalid_argument` on out-of-bounds
  access.
- [ ] `ref` cells used by a single domain at a time.
- [x] `Obj.magic`, which lets the programmer assert any type for
  any value.
- [ ] `List.map`, which traverses a list and produces a new one.

**Why:** `Obj.magic` is the canonical escape hatch from OCaml's
type system. It performs no runtime check; it simply lies to the
type system about a value's type, with the bytes returned
unchanged. Using it incorrectly violates runtime invariants and
can crash the program. The other three are squarely in the safe
fragment: bounds-checked array access (M10-L03), single-domain
`ref` (no race possible), and pure list traversal. The split
between "safe fragment" and "escape hatches" is small and
well-defined; `Obj.magic` is on the unsafe side, the others on the
safe side.
:::

:::slide

## Activity discussion

Q1: `let parsed : Config.t = Marshal.from_string raw_bytes 0`
where `raw_bytes` came from disk.
Q2: which of `Array.get`, single-domain `ref`, `Obj.magic`, or
`List.map` is *not* in OCaml's safe fragment.

- `Marshal` at a *version boundary* (disk, network, IPC across
  releases) is structurally the wrong tool. Tagged formats catch
  the mismatch.
- `Obj.magic` is the canonical OCaml escape hatch. Grep-able,
  rare, and a red flag in code review.

:::

## Common pitfalls

A short list of misunderstandings about OCaml's unsafe fragment
that come up in early discussions.

**Pitfall 1: "Safe OCaml means no crashes."** No. Safe OCaml means
no memory-safety bugs (UAF, overflow, uninit, double-free). It can
still raise exceptions (`Invalid_argument`, `Failure`, `Not_found`),
loop forever, or compute the wrong answer. Memory safety is about
the *category* of bug being excluded, not about absolute absence
of failure.

**Pitfall 2: "If a library uses FFI, the whole program is
unsafe."** The unsafety is local to the FFI surface. A library
that wraps a C dependency in a safe OCaml signature exposes a
safe interface; the C side is auditable as a separate, small
concern. The principle is *contained* unsafety, not *contagious*
unsafety.

**Pitfall 3: "`Obj.magic` is for clever tricks."** It used to be,
in the pre-GADT era. In 2026, almost every legitimate use of
`Obj.magic` in application code has a GADT-based alternative
that is safer and clearer. If you find an `Obj.magic` in a
modern codebase, treat it as a red flag and look for the
intended replacement.

**Pitfall 4: "Marshal is fine for caches."** Within one binary,
yes. Across versions, no. Even the cache use case sometimes
crosses a version boundary in practice (rebuild the binary, old
cache file on disk, segfault on next start). Cache files should
either be tagged with the binary version and discarded on
mismatch, or use a format that detects the mismatch.

## What's next

[Lecture 5](M10-L05-resource-safety.html) extends the safety
story past memory: file descriptors, sockets, and other resources
that the GC alone cannot manage, and the higher-order patterns
OCaml uses to scope them today.

[Lecture 6](M10-L06-tutorial.html) is the tutorial. We have built
the safety picture (M10-L01 to M10-L03), the honest boundary
(this lecture), and the resource-safety gap (M10-L05). The
tutorial walks one famous CVE, **Heartbleed**, end to end: the
bug in OpenSSL, the exploit, the fix, and the OCaml equivalent
where the same bug class is structurally impossible. It is the
lecture where the abstract argument lands on a concrete,
well-documented case study.

:::slide

## What's next

- Lecture 5: **resource safety** beyond memory: file
  descriptors, sockets, buffers. Higher-order scoping with
  `with_open_text` / `Fun.protect`. Where HOF scoping breaks
  down. Forward pointer to M11 modes.
- Lecture 6: walk **Heartbleed** end to end. The OpenSSL bug,
  the exploit, the fix. The OCaml equivalent: same shape,
  structurally impossible bug.

:::

## Reading

- **OCaml manual**, *Module `Obj`* (the unsafe runtime primitives):
  <https://v2.ocaml.org/api/Obj.html>
- **OCaml manual**, *Module `Marshal`*:
  <https://v2.ocaml.org/api/Marshal.html>
- **OCaml manual**, *The memory model for the multicore runtime*:
  <https://v2.ocaml.org/manual/memorymodel.html>
- **Real World OCaml**, *Foreign Function Interface*:
  <https://dev.realworldocaml.org/foreign-function-interface.html>
- **OCaml manual**, *Interfacing C with OCaml*:
  <https://v2.ocaml.org/manual/intfc.html>

## Sources

This lecture's prose, worked examples, and quizzes are original
to this course. The descriptions of `Obj.magic`, `Marshal`, and
the FFI follow the relevant chapters of the OCaml manual and Real
World OCaml; we summarise the safety-relevant subset rather than
reproducing those longer treatments. The DRF-SC memory model
summary is the consensus reading of the OCaml manual's memory-
model chapter. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
