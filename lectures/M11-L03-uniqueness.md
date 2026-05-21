---
title: "Uniqueness — use-after-free at the type level"
lecture_no: 3
week: 11
duration_target_min: 25
concepts: [uniqueness, unique, aliased, manual resource management, use-after-free, double-free, closure capture]
keywords: [OCaml, OxCaml, uniqueness, unique mode, aliased, free, Unique_ref, closure capture]
activity_question: "OCaml's garbage collector takes the use-after-free problem off the table for memory. Why is that not the end of the story? What resources, in a real OCaml program, still need explicit release, and which OCaml language feature traditionally enforces correct release?"
think_about_this: "Your reference is unique; you call `free` on it; the compiler is happy. Now you put a closure around the `free` call: `let f () = free r`. The closure has captured a unique reference. How many times is it safe to call `f`?"
reading:
  - title: "KC Sivaramakrishnan, Uniqueness for behavioural types (2025-05-29)"
    url: https://kcsrk.info/ocaml/modes/oxcaml/2025/05/29/uniqueness_and_behavioural_types/
  - title: "KC Sivaramakrishnan, Linearity and uniqueness (2025-06-04)"
    url: https://kcsrk.info/ocaml/modes/oxcaml/2025/06/04/linearity_and_uniqueness/
  - title: "Oxidizing OCaml: ownership (Jane Street blog)"
    url: https://blog.janestreet.com/oxidizing-ocaml-ownership/
---

# Uniqueness: use-after-free at the type level

In M10 we made the case that OCaml's garbage collector takes the
use-after-free problem off the table for *memory*. The argument
was straightforward: the collector frees a block only when no
live reference to it remains. A program that holds a reference
to a block is, by definition, *not* in the situation where the
collector would free it. So "use after free" for GC-managed memory
is impossible.

That argument is correct and useful, but its premise is narrow:
*GC-managed memory*. The world of manually managed resources is
wider. Some examples your OCaml programs encounter every day:

- A file descriptor obtained from `Unix.openfile`. The OS counts
  it. You must `Unix.close` it exactly once.
- A database connection from a connection pool. The pool counts
  it. You must return it exactly once.
- A buffer obtained from `Bigarray.Array1.create`. The kernel
  may have mapped it for DMA; closing twice corrupts the kernel's
  bookkeeping.
- A file allocated through C's `fopen` via the FFI. The C runtime
  counts it. You must `fclose` it exactly once.

For all of these, the garbage collector is not the manager. The
*you-and-your-types* combination is. And until OxCaml, the
"your-types" half of that combination was effectively absent: the
types could express that the value was a `Unix.file_descr`, but
not that it should be closed exactly once.

The traditional OCaml mitigation is exception-safe wrappers like
`Fun.protect ~finally:close (fun () -> ...)`. This works for the
common case where the resource has a single owner. It does not
work when the resource is passed around the program, or stored in
a record, or captured in a closure: now the "exactly once close"
discipline becomes a property of the whole call graph, and there
is no language-level help to enforce it.

OxCaml's **uniqueness** axis is the type-level fix. The compiler
tracks which references have no aliases; you can then attach a
"consumes the reference" semantics to operations like `free`, and
the type system prevents both use-after-free and double-free.

:::slide

## Where we are

- M10: GC eliminates use-after-free for **memory**.
- But "resource" is wider than "memory": file descriptors, DB
  connections, FFI-allocated buffers, mapped pages.
- The OCaml type system traditionally had nothing to say about
  these.
- This lecture: **uniqueness**. Compile-time use-after-free
  prevention for any manually managed resource.

:::

## The uniqueness axis, mechanically

OxCaml introduces an axis with two modes:

- **`aliased`** (the default): the value may have any number of
  other live references. Anything we do to it must respect that.
- **`unique`**: the value has no other live references. The
  compiler has *proven* this; we can do things that would be
  unsafe in the presence of aliasing.

The submoding is `unique ⊑ aliased`. A unique value can be used
anywhere an aliased value is expected, because "no aliases" is a
stronger guarantee than "may have aliases." The reverse coercion
is rejected: you cannot promote an `aliased` value to `unique`, no
matter what; the compiler has no evidence that other references do
not exist.

You write the mode after `@`, just like locality. A representative
signature, wrapped in a tiny module type so the toplevel can check
it directly:

```ocaml
module type Free_sig = sig
  type 'a t
  val free : 'a t @ unique -> unit
end
```

This signature says: `free` takes a `'a t` value at mode `unique`,
and returns `unit`. The reading is operational: hand `free` a
reference that is the only one to its target, and `free` will
deallocate the target. After the call, the reference is
*consumed*: the compiler bookkeeps that the caller's binding no
longer exists, and rejects any further use.

Uniqueness extends transitively. If a record is `unique`, the
parts you reach by `r.field` are also expected to be unique (with
one escape hatch we will see). This means uniqueness is *deep*:
you cannot hide an alias in a sub-component.

:::slide

## The uniqueness axis

| Mode | Meaning | Aliases? |
|---|---|---|
| **`aliased`** (default) | Other references may exist | Yes |
| **`unique`** | Compiler has proven no other references | No |

Submoding: `unique ⊑ aliased`. A unique reference can be passed
where aliased is expected. The reverse is rejected.

Uniqueness is *deep*: a unique record has unique parts (with one
escape hatch, `Modes.Aliased.t`).

:::

## A safe memory-managed reference

The motivating example from the 2025-05-29 blog post is a
"manually managed" reference: a cell whose memory is *not* under
the GC's control, with explicit `alloc` and `free` operations. The
unsafe version of the interface looks innocent:

```ocaml
module type Unsafe_ref = sig
  type 'a t
  val alloc : 'a -> 'a t
  val free  : 'a t -> unit       (* nothing stops use-after-free *)
  val get   : 'a t -> 'a
  val set   : 'a t -> 'a -> unit
end
```

This is essentially the C-pointer API: explicit allocation,
explicit free. Nothing in the type stops you from calling `free`
twice, or calling `get` after `free`. The interface admits the
exact bugs M10 spent a lecture cataloguing.

Uniqueness lets us tighten the signatures:

```ocaml
module type Unique_ref = sig
  type 'a t
  val alloc : 'a -> 'a t @ unique
  val free  : 'a t @ unique -> unit
  val get   : 'a t @ unique -> 'a Modes.Aliased.t * 'a t @ unique
  val set   : 'a t @ unique -> 'a -> 'a t @ unique
end
```

Read each line carefully; it is the whole story.

- `alloc : 'a -> 'a t @ unique` mints a fresh reference and
  *guarantees* it is unique: no other references to it exist (it
  was just created).
- `free : 'a t @ unique -> unit` takes a unique reference and
  consumes it. After the call, the caller's binding cannot be
  used again.
- `get : 'a t @ unique -> 'a Modes.Aliased.t * 'a t @ unique` is
  the interesting one. To read the value, we *consume* the unique
  reference and hand the caller back two things: the contents
  wrapped in `Modes.Aliased.t` (so the reader can alias it freely),
  and a *fresh* unique reference to the same cell. The caller's
  original binding is gone; the new binding lives on. The
  `Modes.Aliased` wrap on the value is necessary because OxCaml's
  deep-uniqueness rule otherwise insists every component of a
  unique pair is itself unique, which would prevent the caller from
  copying the read-out value.
- `set : 'a t @ unique -> 'a -> 'a t @ unique` same shape: consume,
  install, return a fresh unique handle.

The pattern across all of these is: every operation takes the
unique reference, the original binding is consumed, and (except
for `free`) a fresh unique reference is returned to chain through.

:::slide

## The `Unique_ref` signature

```ocaml
module type Unique_ref_recap = sig
  type 'a t
  val alloc : 'a -> 'a t @ unique
  val free  : 'a t @ unique -> unit
  val get   : 'a t @ unique -> 'a Modes.Aliased.t * 'a t @ unique
  val set   : 'a t @ unique -> 'a -> 'a t @ unique
end
```

Every operation:
- consumes the unique reference,
- (except `free`) returns a fresh one,
- forming a **linear chain of ownership** through the program.

:::

## The implementation, and what the compiler quietly checks

A perfectly innocent-looking implementation satisfies the
signature:

```ocaml
module M : Unique_ref = struct
  type 'a t = { mutable value : 'a }
  let alloc x = { value = x }
  let free _t = ()                       (* deallocation elided *)
  let get t =
    let a = Modes.Aliased.{ aliased = t.value } in
    a, t
  let set t x = t.value <- x; t
end
```

For a course of this size we are not chasing the actual `free`-the-
memory step; the OxCaml documentation has examples that wire into
real allocators. What matters for now is the *type discipline*: the
compiler verifies that the implementation respects uniqueness.

The `Modes.Aliased.{ aliased = t.value }` wrapper on the value
returned by `get` is the production-shaped escape hatch: it tells
the compiler "this field is aliased, even inside an otherwise
unique container." Without it the deep-uniqueness rule would
demand the value itself be unique, which is rarely what the caller
wants when reading.

A subtle test: change `set` to use `Fun.id` on the result. Same
behaviour, but `Fun.id` is a normal-mode function the compiler
cannot prove preserves uniqueness. Wrapping the variant in a
module ascription against the same signature makes the failure
concrete:

```ocaml
(* Press Run; the ascription fails because the rewritten set does
   not satisfy 'a t @ unique -> 'a -> 'a t @ unique. *)
module M_bad : Unique_ref = struct
  type 'a t = { mutable value : 'a }
  let alloc x = { value = x }
  let free _t = ()
  let get t =
    let a = Modes.Aliased.{ aliased = t.value } in
    a, t
  let set t x =
    t.value <- x;
    let t' = Fun.id t in    (* compiler cannot prove unique *)
    t'
end
```

The compiler rejects this with a message that the function does
not satisfy the signature: `'a t -> 'a -> 'a t` is not compatible
with `'a t @ unique -> 'a -> 'a t @ unique`. The lesson: the
compiler reads the implementation as carefully as it reads the
client.

:::slide

## What the compiler checks

The implementation is straightforward; the compiler does the
work behind the scenes:

- Tracks each unique binding through assignments, pattern matches,
  function applications.
- Rejects any operation that would alias a unique value (except
  via `Modes.Aliased.t` or a coercion to `aliased`).
- Verifies the implementation matches the signature mode-by-mode.

:::

## Correct usage: the ownership chain

A well-typed client looks like this:

```ocaml
open M

let okay (r : int t @ unique) =
  let _v, r = get r in   (* old r consumed, new r bound *)
  let r = set r 20 in    (* old r consumed, new r bound *)
  free r                 (* old r consumed, nothing returned *)
```

Each line consumes the previous `r` and (except the last) binds a
fresh `r`. Pattern matching the pair from `get` is the standard
shadowing dance. By the end, `r` has been consumed by `free`; the
function has no live reference to the resource; no use-after-free
is possible because there is nothing left to use.

:::slide

## Correct usage shadows through

```ocaml
let okay_slide (r : int t @ unique) =
  let _v, r = get r in
  let r = set r 20 in
  free r
```

Each operation:
- takes the current `r`,
- (except `free`) hands back a fresh one to shadow into the same name.

The shape is the *linear ownership chain*. After `free`, no `r`
exists.

:::

## Use-after-free: a compile error

Now the bad cases.

```ocaml
(* Press Run to see the use-after-free rejected at compile time. *)
let use_after_free (r : int t @ unique) =
  free r;
  get r
```

The compiler's response:

> Error: This value is used here, but it has already been used as
> unique:
> Line 2, characters 7-8.

Crisp. The first `free r` consumed the unique binding. By the time
we reach the second use (in `get r`), the original `r` is no
longer a live unique reference. The compiler refuses.

Double-free, the same way:

```ocaml
(* Press Run to see double-free rejected at compile time. *)
let double_free (r : int t @ unique) =
  free r;
  free r
```

> Error: This value is used here, but it has already been used as
> unique:
> Line 2, characters 7-8.

These errors are *static*. There is no runtime check, no flag, no
extra branch. The compiler's bookkeeping eliminated a whole class
of memory-safety bugs.

:::slide

## Use-after-free and double-free: type errors

```ocaml
let oops_uaf (r : int t @ unique) =
  free r;
  get r           (* type error *)
```

```ocaml
let oops_double (r : int t @ unique) =
  free r;
  free r          (* type error *)
```

Both rejected by the uniqueness bookkeeping, with the same shape
of error: "This value is used here, but it has already been used
as unique."

:::

## How the compiler tracks "already used"

A useful intuition. Each `unique` value has a single live
*owner* at any time. The owner is the binding that the compiler
believes has the unique reference. Operations like
`free`, `get`, `set` *transfer* ownership: they consume the input
owner and (in `get`'s and `set`'s case) introduce a new owner via
the returned value.

In the `okay` example, watch the ownership pass through:

```ocaml
let okay_renamed (r0 : int t @ unique) =
  let _v, r1 = get r0 in   (* ownership passed from r0 to r1 *)
  let r2 = set r1 20 in    (* passed from r1 to r2 *)
  free r2                  (* r2 consumed, no new owner *)
```

The shadowing names hide this, but the compiler is bookkeeping
exactly that chain. After the final `free`, there is no live
owner: the resource is gone, and any subsequent use of `r0`, `r1`,
or `r2` is a type error.

The same bookkeeping handles pattern destructuring, function calls
(which consume their unique arguments), record construction
(which consumes the fields), and so on. The 2025-05-29 blog post
has the full set of cases.

:::slide

## Ownership chains, conceptually

```text
alloc        →  r0
get r0       →  r1 (and a value)
set r1 v     →  r2
free r2      →  (nothing)
```

Each step *transfers* ownership of the unique handle. At the end
of `free`, no live handle exists.

:::

## A subtle problem: capturing a unique value in a closure

Here is where the story gets interesting. The 2025-06-04 blog post
opens with exactly this scenario; it is worth working through
carefully, because it motivates the next lecture's introduction of
linearity.

Suppose we have a unique reference and write a closure that frees
it:

```ocaml
(* Press Run; the closure captures a unique value, becomes `once`,
   and the second call is rejected on linearity grounds. *)
let wat () =
  let t = alloc 42 in       (* t : int t @ unique *)
  let f () = free t in      (* closure captures t *)
  f ();                     (* OK: free t *)
  f ()                      (* uh oh: double-free? *)
```

Read this carefully. The closure `f` captures `t`. Calling `f`
runs `free t`. Calling `f` *twice* would run `free t` twice. That
is a double-free. The compiler must reject it.

But on what grounds? The unique value `t` is consumed *inside*
`f`'s body, not at the outer level. From the outer level's point
of view, `t` is referenced by `f`. The unique binding is *captured*,
not consumed.

The compiler's answer: a closure that captures a unique value is
itself given the mode **`once`** (which is on the *linearity* axis,
the topic of M11-L04). Once-mode means "use at most once." The
second call to `f` is then rejected, not because `t` was already
freed (the linearity check fires before any value-level reasoning
about `t`), but because `f` itself has already been used.

The error:

> Error: This value is used here, but it is defined as once and
> has already been used:
> Line 4, characters 2-3.

This is the punchline of the 2025-06-04 post: uniqueness alone is
not enough. You also need linearity to handle the closure-capture
case. The two axes cooperate: capturing a unique value automatically
downgrades the closure's linearity to `once`.

:::slide

## The closure-capture pitfall

```ocaml
let wat_recap () =
  let t = alloc 42 in
  let f () = free t in
  f ();
  f ()       (* type error *)
```

- `f` captures the unique `t`.
- Capture *itself* does not consume `t`.
- But calling `f` twice would free `t` twice.
- Resolution: capturing a `unique` value gives the closure mode
  `once`. The second call to `f` is rejected on **linearity**
  grounds.

This is why we need *both* uniqueness and linearity.

:::

## The other side of the same coin: aliasing a unique reference

You can also see the asymmetry in the submoding rule. Take a
unique reference and pass it through a function that aliases it:

```ocaml
let dup r = (r, r)

let oops () =
  let r = alloc 42 in
  let a, b = dup r in
  (a, b)
```

The type of `oops` is `unit -> int t * int t`. The two components
of the pair are at mode `aliased` (the default for the pair type
returned by `dup`). The compiler accepts the call to `dup`,
because `dup` requires its argument at mode `aliased`, and the
unique `r` can be coerced down (`unique ⊑ aliased`).

But now `a` and `b` are aliased. They can no longer be passed to
`free`, `get`, or `set`:

```ocaml
(* Press Run; once you alias a unique reference via `dup`, you
   cannot pass it to `free` any more. *)
let oops () =
  let r = alloc 42 in
  let a, _b = dup r in
  free a
```

Once you coerce a unique reference to aliased, you cannot get
uniqueness back. The library has lost the ability to safely free
the reference.

This is the *price* of allowing the submoding. Calling `dup` is
fine; you just lose the privileges of uniqueness afterwards. It is
on the programmer to keep the reference unique throughout its
useful life.

:::slide

## Aliasing destroys the uniqueness privilege

```ocaml
let dup_recap r = (r, r)

let oops_alias () =
  let r = alloc 42 in      (* r : int t @ unique *)
  let a, _b = dup_recap r in (* coerced to aliased *)
  free a                   (* error: aliased, expected unique *)
```

`unique ⊑ aliased` is a one-way street. You can lose uniqueness;
you cannot regain it.

:::

## Why uniqueness gives you *modular* safety

A theme worth pulling out. The 2025-06-04 post emphasises this
explicitly.

When you read the signature of `free`:

```ocaml
module type Free_unique = sig
  type 'a t
  val free : 'a t @ unique -> unit
end
```

you can conclude, just from the signature, that calling `free` on
a `unique` reference is safe. The argument:

1. The reference is unique. (That is what the type says.)
2. Therefore there are no other live references to the underlying
   resource.
3. Therefore freeing it cannot create a dangling reference: there
   is nothing to dangle.

This argument is **modular**. You do not need to look at `free`'s
implementation. You do not need to audit the rest of the library.
You do not need to read every call site. The signature is the
contract.

Contrast with a hypothetical linear-only version of the same API:

```ocaml
module type Free_once = sig
  type 'a t
  val free : 'a t @ once -> unit
end
```

This says "use the reference at most once, then call `free`." From
the signature alone, you cannot conclude that no aliases exist.
The `once` constraint is about *this binding's future use*, not
about *aliasing*. To prove the API is safe, you would have to
inspect every operation that produces a `'a t`, every operation
that consumes one, and the whole control flow of every client.
That is *whole-API reasoning*.

Both versions can deliver the right runtime behaviour. But the
unique version's *signature alone* is convincing; the linear
version requires more work. For an API where modular reasoning
matters (and it always matters), uniqueness is the more
appropriate axis.

:::slide

## Uniqueness vs linearity, modularly

```ocaml
module type Free_unique_slide = sig
  type 'a t
  val free : 'a t @ unique -> unit
end
```
→ Safe from the signature alone. Modular reasoning.

```ocaml
module type Free_once_slide = sig
  type 'a t
  val free : 'a t @ once -> unit
end
```
→ Safe only if you audit the whole API. Whole-API reasoning.

For `free`-like APIs, **uniqueness is more appropriate**.

:::

## Past, future, and which axis you reach for

The 2025-06-04 post puts the difference in one sentence:

- **Uniqueness** talks about the **past**: has this value been
  aliased *before now*?
- **Linearity** talks about the **future**: will this value be
  used *after now*?

A unique value may *become* aliased in the future (you can pass it
to `dup`, as above; you can coerce it explicitly). A linear value
may have been aliased in the *past*. These are different
properties.

For most resource-management APIs, you want both. M11-L04 is the
linearity lecture; M11-L05 is the tutorial that puts the two
together.

:::slide

## Past vs future

- **Uniqueness**: was this value aliased in the *past*?
- **Linearity**: will this value be used in the *future*?

Different axes; different rules; both useful.

:::

## Activity

:::quiz mcq id=M11-L03-q1
Given the `Unique_ref` signature from this lecture, which of these
clients fails to type-check?

```ocaml skip
(* A *)
let a r =
  let _v, r = get r in
  let _v, _r = get r in
  ()

(* B *)
let b r =
  let r = set r 100 in
  free r

(* C *)
let c r =
  let _v, _r = get r in
  free r
```

- [ ] Only A.
- [ ] Only B.
- [x] Only C.
- [ ] All three fail.

**Why:** A and B both follow the ownership chain: each operation
consumes the current `r` and binds a fresh one (or `free` consumes
without rebinding). C is the broken one. After
`let _v, _r = get r`, the *original* `r` has been consumed; the
new unique handle is `_r`, but the underscore tells the binding to
be discarded. The subsequent `free r` is the **original** `r`,
which has already been used as unique. The compiler rejects it.
:::

:::quiz mcq id=M11-L03-q2
Suppose we wrote a closure that *aliases* (not consumes) a unique
reference:

```ocaml skip
let read_outside (r : int t @ unique) =
  let f () = get r in
  let _v, _r' = f () in
  let _v, _r' = f () in   (* called twice *)
  ()
```

What happens?

- [x] The second call to `f` is rejected because `f` is implicitly
      `once`: it captured a unique value.
- [ ] Both calls succeed; the implementation is wrong.
- [ ] The compiler accepts both calls; `get` produces a fresh
      unique handle each time.
- [ ] The compiler accepts both calls; only `free` is restricted,
      not `get`.

**Why:** The capture of a unique value (`r`) into a closure
forces the closure's linearity mode to `once`. The first call to
`f` is fine; it consumes the captured `r` and produces a new
binding *inside `f`'s body*, which is then discarded by the
caller's pattern. The second call is rejected because `f` is
`once`, regardless of what `f` does internally. Capture is not
consumption, but it is enough to downgrade the closure.
:::

:::slide

## Activity discussion

- Each unique operation must thread the binding correctly. An
  underscored shadow drops the new handle and leaves the original
  consumed.
- Capture of a unique value into a closure forces the closure to
  be `once`. That is the bridge into the next lecture.

:::

## Common pitfalls

**Pitfall 1: "If I never alias a value, it must be unique."** No.
"Unique" is what the *compiler* has proven. If you write a
function whose signature does not say `@ unique`, the value will
not be unique inside the function, even if the caller's
implementation never aliases it. The signature is the contract.

**Pitfall 2: "Uniqueness handles all my closure problems."** No.
Closures over unique values become `once` automatically, but
*calling* the closure twice is the linearity rule, not the
uniqueness rule. Pay attention to the closure's *mode*, not just
its captured values.

**Pitfall 3: "`Modes.Aliased.t` defeats uniqueness."** Not really.
It is an escape hatch for *parts* of a unique value: the
container stays unique, but a designated field is allowed to be
aliased. This is the right tool for `get : 'a t @ unique -> 'a
Modes.Aliased.t * 'a t @ unique`, where the contents may need to
be shared with other code while the reference itself stays unique.

**Pitfall 4: "Uniqueness costs runtime."** It does not. The
checking is all at compile time. The compiled code is the same as
the unsafe version; the type checker has just proven it safe.

## What's next

The next lecture (M11-L04) is **linearity**. We will treat it on
its own terms: a separate axis that tracks *future* use rather
than past aliasing, a separate set of modes (`many` and `once`),
a separate set of compile errors. We will see why some APIs are
more naturally written with linearity than uniqueness (the
"linear handle" example), and we will look at the file-handle
shape that puts the two together.

Then M11-L05 is the tutorial, where we design a file-handle module
end to end, combining locality and linearity, and walk through
three attempts to misuse the API. Each attempt is a type error.

:::slide

## What's next

- Lecture 4: **linearity**. Future-use tracking, `once` and `many`.
- Lecture 5: tutorial. A file-handle API combining locality and
  linearity.

:::

## Reading

- **KC Sivaramakrishnan**, *Uniqueness for behavioural types*
  (2025-05-29):
  <https://kcsrk.info/ocaml/modes/oxcaml/2025/05/29/uniqueness_and_behavioural_types/>
- **KC Sivaramakrishnan**, *Linearity and uniqueness* (2025-06-04),
  the *Capturing unique values* section in particular:
  <https://kcsrk.info/ocaml/modes/oxcaml/2025/06/04/linearity_and_uniqueness/>
- **Jane Street blog**, *Oxidizing OCaml: ownership*:
  <https://blog.janestreet.com/oxidizing-ocaml-ownership/>
- **Marshall, Vollmer, Orchard**, *Linearity and Uniqueness: An
  Entente Cordiale* (ESOP 2022):
  <https://granule-project.github.io/papers/esop22-paper.pdf>

## Sources

The `Unique_ref` API, the worked client examples, and the
compiler-error blocks are adapted from the instructor's 2025-05-29
blog post and the CS6868 OxCaml handout (the instructor's own
teaching material, freely reusable). The closure-capture pitfall
narrative draws on the 2025-06-04 post's *Capturing unique values*
section. The modular-reasoning argument is paraphrased from the
same post's *Uniqueness is more appropriate for safe refs*
section. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
