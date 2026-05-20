---
title: "How OCaml rules them out by construction"
lecture_no: 3
week: 10
duration_target_min: 25
concepts: [garbage collection, bounds checking, initialisation, tagged pointers, block headers, runtime representation]
keywords: [OCaml, GC, garbage collection, bounds checking, Invalid_argument, tagged pointers, block header, runtime, memory safety]
activity_question: "If OCaml's GC reclaims memory only when nothing reachable refers to it, why is it impossible to read from freed memory in safe OCaml? Trace the chain of reasoning."
think_about_this: "Bounds checks on every array access are not free. They cost a comparison and a branch on every read. Yet OCaml programs are routinely within a small constant factor of C. Why does the cost not dominate, and where do compilers reclaim it?"
reading:
  - title: "Cornell CS3110, Memory representation"
    url: https://cs3110.github.io/textbook/chapters/data/memory.html
  - title: "Real World OCaml, Memory representation of values"
    url: https://dev.realworldocaml.org/runtime-memory-layout.html
---

# How OCaml rules them out by construction

We have, by now, a precise catalogue of memory-safety bugs (M10-L01)
and a precise account of why they matter in production (M10-L02).
This lecture makes the OCaml side precise. For each of the four
canonical bugs, we identify *which* language feature rules it
out, *where* in the runtime the rule is enforced, and *what* the
cost is. Then we sketch the runtime infrastructure that makes
these rules implementable: tagged pointers, block headers, what
the garbage collector actually does.

The point of this lecture is not "OCaml is safe, trust us." The
point is "OCaml is safe, and here is the mechanism, and the
mechanism is small enough to fit in one lecture, and we can
demonstrate it running in your browser."

We will close with the *honest boundary*: this story holds for
the safe fragment. Outside that fragment (`Obj.magic`, FFI,
`Marshal` with the wrong type, races on `ref`), the guarantees
weaken. [Lecture 4](M10-L04-where-ocaml-has-ub.html) walks that
boundary in detail.

:::slide

## Roadmap

- One section per bug from M10-L01.
- For each: which feature rules it out, and how.
- A brief runtime sketch: tagged pointers, block headers, the GC.
- The honest boundary: safe-fragment only.

:::

## Use-after-free: ruled out by the GC

The C use-after-free pattern was: a program calls `free` on a
block, then later reads or writes through a pointer that still
holds the address of that block. The bug is *temporal*: the
address is "valid" in the sense that it is a real address; it
just no longer belongs to the program.

In OCaml the bug class is impossible because the bug *cannot be
written down*. Two things rule it out, working together.

**No `free` primitive.** OCaml's surface language has no
`free`, no `delete`, no `dispose`. The programmer never tells
the runtime "this block is now garbage." This is the same design
choice as Java, C#, Python, Go, Haskell, and every other
GC'd language; in OCaml's case it has been the design since the
language's first release in 1996.

**Garbage collection.** Memory is reclaimed automatically by the
garbage collector, but only after every reference to the block
has gone out of scope. The GC walks the *roots* (the stack, the
registers, global variables) and follows every pointer; any
block that remains unreachable after that walk is dead and can
be reclaimed. By the time the GC reclaims a block, no part of
the program is holding a pointer to it.

These two together close the bug class structurally. If you
cannot free explicitly, you cannot free early. If the GC only
frees blocks nothing references, "after free" has no observable
moment in the program: there is no time at which a live pointer
refers to freed memory.

:::slide

## Use-after-free: closed

```ocaml
let buf = Bytes.create 64 in
Bytes.set buf 0 'h';
(* there is no free(buf) you can write *)
print_char (Bytes.get buf 0)
```

- No `free` primitive in the language.
- GC reclaims memory only when nothing reachable refers to it.
- "Live pointer to freed memory" is unreachable as a program
  state.

**Closes Chromium's largest single bug category (36 percent).**

:::

There is a subtlety worth naming, because it comes up in
discussions with C programmers. The GC reclaims based on
*reachability*, not based on liveness. A pointer can remain
reachable long after the program will never use it again; the
GC will not collect the block until the pointer itself becomes
unreachable. This is called a *memory leak*, and OCaml programs
can have them. A memory leak is a reliability and resource bug,
not a memory-safety bug. It cannot become an arbitrary-code-
execution exploit because the language still cannot read freed
memory; it can only retain too much un-freed memory.

The distinction is important. "OCaml has no use-after-free"
does not mean "OCaml has perfect memory hygiene." It means the
specific UB pattern of UAF, and the security consequences that
follow from it, are eliminated. Other resource-management bugs
(leaks, accidental retention, large unintended caches) remain
possible.

## Buffer overflow: ruled out by bounds checking

The C buffer-overflow pattern was: a program writes or reads
beyond the end of an allocated buffer. The write may corrupt
adjacent memory; the read may leak adjacent memory (the
Heartbleed case). The bug is *spatial*: the address is wrong by
some number of bytes.

OCaml rules this class out by making every access to an
indexed structure go through a bounds check. The standard
library functions `Array.get`, `Array.set`, `String.get`,
`Bytes.get`, `Bytes.set` all take an index, compare it against
the structure's length, and raise the exception
`Invalid_argument` if the index is out of range. There is no
unchecked alternative in the safe fragment.

The indexing-operator syntax `a.(i)`, `s.[i]`, and `b.{i}` for
bigarrays all desugar to these checked accessors. Even the
low-level `bytes` type, which is the closest thing OCaml has to
a C-style mutable buffer, is bounds-checked on every access.

Let us see the check fire. Pick any `int list`, index it at a
position past its end, and watch the runtime refuse:

```ocaml
let xs = [1; 2; 3]
let bad = List.nth xs 99
```

The runtime raises `Failure "nth"` (for `List.nth`) or the more
generic `Invalid_argument "index out of bounds"` (for
`Array.get`, `String.get`, `Bytes.get`). The exception is
unrecoverable in the sense that the offending access never
returns; control transfers immediately to the nearest enclosing
handler, or to the top-level if there is none. The out-of-bounds
*memory* is never touched. There is no Heartbleed-shaped leak
because there is no point in time at which the runtime is
willing to read bytes outside the allocated region.

:::slide

## Buffer overflow: closed

```ocaml
let xs = [1; 2; 3]
let bad = List.nth xs 99
```

- Every `Array.get`, `String.get`, `Bytes.get`, `List.nth`
  bounds-checks at runtime.
- `Invalid_argument` raised at the *offending access*; the
  bytes are never read.
- No unchecked accessor in the safe fragment.
- *No Heartbleed: the read never crosses the boundary.*

:::

The bounds-checking cost is a comparison and a branch on each
access. The expectation might be that this dominates, but in
practice it does not. Two reasons. First, modern CPUs predict
in-bounds branches with near-perfect accuracy: the branch is
almost always taken or almost never taken, depending on the
access pattern, and the predictor learns it on the second
iteration. The cost is around half a cycle in steady state.
Second, the OCaml compiler can sometimes eliminate the check
entirely when it can prove the index is in range (loop-invariant
range checks, statically known indices). The flint compiler and
the native compiler both do some of this; ongoing work in the
compiler community continues to push it further.

The remaining cost (small percentage in most workloads) is the
price of the safety guarantee. It is paid every cycle the
program runs. It is also exactly what the M10-L02 exploit
walk-through was prevented from happening: the bounds check is
the moment Heartbleed would have died.

## Bounds-checking demo

We can demonstrate the bounds check live in this lecture. The
`x-ocaml` cell below has a list and an index. Try changing the
index to 99 or to -1 and re-running:

```ocaml
let xs = [|10; 20; 30|]
let _  = xs.(1)
```

In the above, `xs.(1)` is `20`. If you change `1` to `99` or
`-1` and re-run, you will see the runtime raise
`Invalid_argument`. The cell's output panel reports the
exception with a stack trace. The bytes beyond the array are
never read.

:::slide

## Bounds check, live

```ocaml
let xs = [|10; 20; 30|]
let _  = xs.(1)
```

- Change `1` to `99` or `-1`.
- The runtime raises `Invalid_argument "index out of bounds"`.
- The out-of-bounds bytes are never accessed.

:::

## Uninitialised read: ruled out by binding-time initialisation

The C uninitialised-read pattern was: a program declares a
variable, reads it before assigning to it, and gets whatever
bytes happened to be left over from the previous use of that
memory. In the kernel cases from M10-L01, the leftover bytes
were sometimes sensitive (cryptographic keys, addresses
defeating ASLR), and the bug became a security incident.

OCaml rules this class out by *requiring an initial value at
binding time*. There is no equivalent of `int x;` in OCaml.
Every `let x = ...` requires the right-hand side to evaluate
to a value of the appropriate type. There is no syntactic shape
that introduces a name without giving it a value.

```ocaml
let x = 42
(* there is no "let x : int" without a value *)
```

For mutable storage, the same rule applies. A `ref` cell
requires an initial contents:

```ocaml
let r = ref 0
```

There is no `ref : 'a -> 'a ref` that takes nothing and returns
a ref with no contents. The closest thing in the standard
library is `ref None`, which is a `ref` holding the value
`None : 'a option`. The cell *does* have a value, namely
`None`; reading it returns `None`, which is well-typed and
forces the programmer to handle the absent case explicitly via
pattern matching. There is no path from `ref None` to leaking a
secret cryptographic key.

The Array equivalent is `Array.make n x`, which requires the
fill value `x`. There is no `Array.uninitialised n` in the
safe library.

:::slide

## Uninitialised read: closed

- Every `let x = ...` requires a value.
- Every `ref ...` requires initial contents.
- `Array.make n x` requires the fill value `x`.
- *No syntactic shape introduces a name without giving it a value.*

The closest analogue is `ref None`, but `None` is itself a
well-typed value; the type system forces the reader to handle
the `None` case explicitly.

:::

A few internal performance-oriented APIs (notably
`Array.make_float` for float arrays in some compiler versions)
historically left content uninitialised in unchecked layouts;
these have been progressively tightened. The safe surface of
the language requires initialisation; if you find an exception,
you have found a corner where the runtime is exposing a
performance shortcut and you should be reading carefully.

## Double-free: ruled out trivially

This one is the easiest. C's double-free requires the program to
call `free` twice on the same block. OCaml has no `free`. There
is no `free` to call once, let alone twice. The bug class is
closed because the operation does not exist.

The same observation makes the entire family of
manual-memory-management hazards (use-after-free, double-free,
forgotten-free, freeing a pointer that was never allocated)
disappear. The GC owns deallocation. The programmer cannot
participate in it.

:::slide

## Double-free: closed

- No `free` in the surface language.
- *The operation does not exist.*
- All manual-memory hazards (UAF, double-free, forgotten-free,
  free-non-allocated) close together.

:::

## Sketch of the runtime

The four "by-construction" arguments above rely on the runtime
to do real work. Let us spend two or three minutes on what is
actually happening, because the M02-L01 promise about the
missing 63rd bit pays off here.

### Tagged pointers

The OCaml runtime represents every value uniformly as a single
machine word. Some words are *immediate* values (small integers,
booleans, `()`); others are *pointers* to heap-allocated blocks
(tuples, records, variants, closures, strings, arrays). The
runtime needs to tell these apart at every step (the GC has to
know which words to follow as pointers; the runtime has to know
how to interpret each operand of a primitive operation).

The trick is to use the low bit of every word as a *tag*:
immediates have the low bit set to `1`; pointers have the low
bit set to `0` (heap blocks are always allocated at even
addresses, so this is enforceable). At any point in execution,
one bit test distinguishes an immediate from a pointer.

This is the choice that cost us the 63rd bit of integer range,
as we observed in [M02-L01](M02-L01-literals.html). The cost is
one bit of integer range; the benefit is a uniform value
representation, a simple GC, and the categorical absence of the
"is this word a pointer?" ambiguity that makes C-level memory
analysis so painful.

:::slide

## Tagged values

| Tag bit | Meaning | Example |
| --- | --- | --- |
| `1` | Immediate value | `int`, `bool`, `()`, constant constructors |
| `0` | Pointer to heap block | tuples, records, variants, closures, arrays, strings |

- One bit-test distinguishes a pointer from an immediate.
- Cost: 63-bit `int` instead of 64-bit.
- Benefit: simple GC, uniform representation, no "is this a
  pointer?" guessing.

(Callback to M02-L01: the missing 63rd bit pays off here.)

:::

### Block headers

Every heap-allocated block has a small *header* word in front of
it. The header encodes:

- The size of the block (how many words follow).
- The block's *tag*, which classifies the block's content kind:
  tuple-like (fields are values), string-like (bytes), closure,
  forward, etc.
- The GC colour (white / grey / black), used to track which
  blocks the GC has visited during a sweep.

The header is invisible to the surface programmer. It is what
the runtime consults when it needs to know how to interpret a
block: how many bytes does this string have? How many fields
does this tuple have? Is this block a function? The header tells
it.

This is also the answer to "how does `Array.length` know the
length without a separate length field?" The answer is: the
length is in the header. Every block header carries its size,
so every operation on every block has length information
available without an extra word per array.

:::slide

## Block headers

- Every heap block is preceded by a one-word header.
- Header carries: size, tag (kind), GC colour.
- Surface programmer never sees the header.
- *This is why `Array.length` and bounds checks are O(1) with
  no extra storage per array.*

:::

### What the GC does

The GC's job is to find and reclaim memory the program will not
use again. OCaml's GC is a *generational two-space minor heap +
mark-sweep-compact major heap* design. The detail is more than
this lecture needs; the conceptual model is:

1. The program allocates a new block. The minor heap is fast:
   bump a pointer, write the header, return the address.
2. The minor heap fills up. The GC walks roots (stack, globals,
   registers), follows pointers, and copies anything still
   reachable into the major heap. The unreachable minor-heap
   space is then trivially reclaimable: it is the entire minor
   heap.
3. The major heap accumulates. Periodically, the GC sweeps it:
   walks roots, marks every reachable major-heap block,
   reclaims the unmarked ones. Compaction may run to
   defragment.

Reachability is the central concept. A block is reachable if
some root holds a pointer to it, or if some reachable block
holds a pointer to it. The GC computes the reachable set; the
complement is garbage; the complement is reclaimed.

Critically, the GC reclaims *only* unreachable blocks. By
definition, no reachable block has a pointer to an unreachable
block. So at the moment the GC reclaims a block, no part of the
program has a pointer to it. The use-after-free pattern from
C has no representation in this model.

:::slide

## The GC, in one paragraph

- Minor heap: fast bump-pointer allocation.
- Major heap: mark-sweep-compact.
- GC walks **roots** (stack, registers, globals).
- Anything reachable from roots is live; the rest is garbage.
- *Garbage is reclaimed only when unreachable, so no live pointer
  ever refers to freed memory.*

:::

### What the runtime costs

A few rough numbers. The minor-heap allocation is a few
nanoseconds per block. The minor-heap collection (the more
frequent event) takes microseconds to a millisecond. The major
collection runs less often and is the larger pause; on a modern
workload it is tens to hundreds of milliseconds, paid in chunks
rather than all at once (the major GC is incremental). The total
runtime overhead of the GC is typically a few percent of total
CPU time in long-running OCaml workloads. The bounds-check
overhead is smaller and depends on access pattern. Together,
the safety overhead is a small fraction of the program's
runtime; in exchange, the four memory-safety bug classes are
eliminated.

## A small exercise

:::quiz code id=M10-L03-q1
Write a function `safe_nth : 'a list -> int -> 'a option` that
returns `Some x` if the list has at least `n + 1` elements (so
position `n` is in range), and `None` otherwise. The function
should never raise an exception, even on negative indices or
indices past the end of the list. Hint: walk the list,
decrementing the index; return `None` if the list runs out or
the index is negative.

```ocaml
let safe_nth xs n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (safe_nth [1; 2; 3] 0 = Some 1) "head";
  check (safe_nth [1; 2; 3] 2 = Some 3) "last";
  check (safe_nth [1; 2; 3] 3 = None)   "past end";
  check (safe_nth [1; 2; 3] 99 = None)  "way past";
  check (safe_nth [1; 2; 3] (-1) = None) "negative";
  check (safe_nth ([] : int list) 0 = None) "empty";
  print_endline "all tests passed"
```
:::

A reference solution: walk the list, decrement the index; return
`None` on empty list or negative index.

```ocaml
let rec safe_nth xs n =
  if n < 0 then None
  else match xs with
    | [] -> None
    | x :: rest -> if n = 0 then Some x else safe_nth rest (n - 1)
```

This is the OCaml-flavoured version of bounds-checked indexing.
The runtime's `List.nth` raises `Failure` on out-of-bounds; if
you want a non-raising version, you write one. Either way, the
out-of-bounds bytes are never read; the only question is whether
the boundary is reported as an exception or as a `None`.

:::quiz mcq id=M10-L03-q2
A C program calls `free(p)`, and then a few microseconds later
another part of the program reads `*p`. What does the OCaml
analogue look like?

- [ ] The OCaml program also reads stale bytes, but the GC
  catches it later.
- [x] The bug pattern cannot be written in safe OCaml. There is
  no `free`, and the GC will not reclaim a block while any
  reachable reference to it exists.
- [ ] The OCaml program raises a runtime exception "use after
  free".
- [ ] The OCaml program's behaviour is implementation-defined
  (depends on the GC's mood).

**Why:** OCaml has no explicit `free`. The GC reclaims a block
only after the block has become unreachable, that is, no live
reference to it exists anywhere in the program. The "free, then
later access the freed pointer" pattern requires that a live
reference exist *after* the free, which is contradictory to the
GC's reclamation rule. The pattern is not implementable in safe
OCaml. There is no "use after free" exception because there is
no point in time at which a live OCaml reference points at a
freed block.
:::

:::quiz mcq id=M10-L03-q3
Why does the OCaml runtime use the low bit of every value as a
tag, even though it costs one bit of integer range?

- [ ] To accelerate integer arithmetic on x86.
- [ ] To distinguish signed from unsigned integers at runtime.
- [x] So that the GC and other primitives can tell, in one
  bit-test, whether a word is a pointer or an immediate.
- [ ] Backwards compatibility with 32-bit machines.

**Why:** OCaml represents every value uniformly as a single
word. The GC must walk every reachable word and decide whether
to follow it as a pointer; the runtime must decide, on every
primitive operation, whether an operand is a heap address or a
boxed value. The low-bit tag (`1` for immediates, `0` for
pointers, with heap allocations always even-aligned) means one
bit test suffices. The cost is a 63-bit `int` (which we paid in
M02-L01) and the benefit is a uniform, simple GC and a
predictable runtime.
:::

:::slide

## Activity discussion

- The "no free" half closes UAF and double-free together: no
  operation exists for the bug.
- The bounds-checked indexing closes buffer overflow at the
  access; no out-of-bounds byte is ever read or written.
- Binding-time initialisation closes uninit read: there is no
  syntactic shape that introduces a name without a value.
- The runtime's tagged-pointer + block-header design is the
  machinery that makes the GC fast and uniform.

:::

## The honest boundary

The four "by construction" arguments hold for the *safe fragment*
of OCaml: the surface language and its standard library,
excluding `Obj`, `Marshal` with the wrong type, and FFI
(`external` declarations, Ctypes). Step outside the safe
fragment and the guarantees weaken.

[Lecture 4](M10-L04-where-ocaml-has-ub.html) walks the boundary
in detail. The short summary is that the unsafe operations are
deliberately named: `Obj.magic` literally contains the word
"magic" in the function name; `Marshal.from_string` takes a type
annotation that the runtime does not check; FFI requires the
keyword `external`. The unsafe operations exist, but they are
syntactically loud, and a sensible code review can ban them
outside specifically-audited modules.

In particular, the GC's "no live pointer to a freed block"
property holds *only for pointers the GC knows about*. If C
code, called via FFI, retains a pointer to an OCaml block and
the OCaml side becomes unreachable, the GC may reclaim the
block while the C pointer dangles. This is why FFI requires
careful handshaking with the runtime (the `caml_register_global_root`
machinery): the C side must tell the GC "I am holding a
reference, do not reclaim this." Get the handshake wrong and
the safety guarantee evaporates locally.

:::slide

## Honest boundary

- The four guarantees hold for the **safe fragment**:
  surface language + safe stdlib.
- Outside it (`Obj.magic`, `Marshal`, FFI), guarantees weaken.
- The unsafe operations are syntactically named (`Obj`, `Marshal`,
  `external`) so they are reviewable.
- Lecture 4: the boundary in detail.

:::

## What's next

[Lecture 4](M10-L04-where-ocaml-has-ub.html) makes the unsafe
side honest: what `Obj.magic` lets you do, why `Marshal` is
dangerous when the type annotation is wrong, what FFI signs you
up for, and one short note on data races on `ref` (concurrency
proper is out of this course's scope; this is the brief
acknowledgement that the race exists). The principle that
emerges: keep the unsafe core small and well-audited; trust the
safe fragment for everything else.

[Lecture 5](M10-L05-tutorial.html) walks a real CVE end to end,
showing how the same bug pattern is *structurally impossible* in
the OCaml equivalent. We have built the conceptual picture; the
tutorial is where it lands on a concrete case.

:::slide

## What's next

- Lecture 4: where OCaml itself has UB. `Obj.magic`, `Marshal`,
  FFI, races on `ref`.
- Lecture 5: walk a real CVE, then show its OCaml equivalent
  cannot have the same bug.

:::

## Reading

- **Cornell CS3110**, *Memory representation*:
  <https://cs3110.github.io/textbook/chapters/data/memory.html>
- **Real World OCaml**, *Memory representation of values*:
  <https://dev.realworldocaml.org/runtime-memory-layout.html>
- **OCaml manual**, *The garbage collector*:
  <https://v2.ocaml.org/manual/intfc.html>

## Sources

This lecture's prose, worked examples, and quizzes are original
to this course. The runtime sketch (tagged pointers, block
headers, GC) is the standard exposition that appears in the
OCaml manual, Cornell CS3110, and Real World OCaml; we present
the conceptual minimum the rest of the module relies on rather
than reproducing those longer treatments. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
