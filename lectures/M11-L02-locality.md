---
title: "Locality — safe stack allocation"
lecture_no: 2
week: 11
duration_target_min: 25
concepts: [locality, local mode, stack allocation, exclave, mode crossing, regions]
keywords: [OCaml, OxCaml, locality, local, stack_, exclave_, regions, mode crossing]
activity_question: "A C function returns the address of one of its local variables. What goes wrong, and at what point during the program's execution does the bug show up? Now: what would it take for the *type checker* to refuse the program?"
think_about_this: "OCaml programmers spend a surprising fraction of their time fretting about GC pressure in hot loops. If the compiler could prove a value never escapes its scope, that value could live on the stack and the GC would never see it. What information does the compiler need to make that proof?"
reading:
  - title: "Oxidizing OCaml: locality (Jane Street blog)"
    url: https://blog.janestreet.com/oxidizing-ocaml-locality/
  - title: "Stack allocation, OxCaml documentation"
    url: https://oxcaml.org/documentation/stack-allocation/
---

# Locality: safe stack allocation

OCaml allocates almost everything on the heap. Tuples, records,
closures, boxed floats, list cons cells: each one is a fresh
allocation, each one trips a minor-heap pointer bump, each one
gets eventually reclaimed by the garbage collector. For most
programs this is fine; the minor heap is fast, the GC is well
tuned, and the convenience of "every value is potentially
long-lived" is the source of OCaml's clean semantics.

In hot loops, though, this all-heap model bites. Consider a
graphics renderer that produces millions of intermediate 2-D
points per frame, only to throw them away nanoseconds later.
Every one of those points is a 24-byte block on the minor heap,
contributing to GC pressure that the program does not benefit
from. The points exist for a few nanoseconds; conceptually they
should live in a register, or on the stack, or wherever cheap
short-lived data lives. The OCaml compiler does not have the
information to make that decision: a `point` might escape, the
compiler does not know.

The C world solves this with stack allocation. `Point p = ...;`
puts `p` on the stack. When the function returns, `p` is gone.
This is free, fast, and dangerous. Free because no allocator runs.
Fast because the stack pointer just moves up and down. Dangerous
because, if you return a pointer to `p`, the caller has a pointer
into a stack frame that no longer exists, and you have a
use-after-stack-frame-end bug. C's type system does nothing to
prevent this.

OxCaml's **locality** axis is the type-level fix. The compiler
tracks which values must not escape their region; programmers can
allocate those values on the stack; escape attempts become type
errors. You get C's performance without C's foot-gun.

:::slide

## Where we are

- M10: types + GC catch use-after-free, double-free, overflow,
  uninit.
- M11: the *type system* extends to catch more.
- This lecture: **locality**. Stack allocation with no
  pointer-escape risk.

:::

## What locality is, mechanically

OxCaml introduces a new axis with two modes:

- **`global`** (default): the value may escape its scope. It can
  be captured in a closure, returned from a function, stored in a
  long-lived data structure. It lives on the heap, where it can
  outlive the function that created it.
- **`local`**: the value must not escape its scope. It cannot be
  captured in a closure that outlives the scope, cannot be returned
  (without special syntax we will see in a moment), cannot be
  stored in a global cell.

The submoding relation is `global ⊑ local`. Read that as: a
`global` value can be used anywhere a `local` value is expected.
The reverse is not true; passing a `local` value where `global` is
required is a type error. The intuition: `global` is the stronger
promise. A function that takes a `local` parameter only promises
to use the value within its scope; you can always hand it a
`global` value too.

Concretely, you write the mode after an `@` symbol:

```ocaml
let use_locally (r @ local) = !r + 1
(* val use_locally : int ref @ local -> int = <fun> *)
```

The function takes an `int ref @ local`. It promises not to let
the ref escape. The body just dereferences and returns an `int`,
which the caller gets back at the default `global` mode (`int`
mode-crosses the locality axis, which we will explain shortly).

You can hand this function a heap-allocated ref, no problem:

```ocaml
let test () =
  let r = ref 41 in
  use_locally r
```

The annotation is the function's contract, not a request to the
caller. Every `global` value satisfies a `@ local` parameter,
because every `global` value can be used in a context that promises
not to let it escape.

:::slide

## The locality axis

| Mode | Meaning | May escape? |
|---|---|---|
| **`global`** (default) | Lives on the heap | Yes |
| **`local`** | Confined to its region | No |

Submoding: `global ⊑ local`. A `global` value can flow into a
`@ local` slot. The reverse is rejected.

:::

## Allocating on the stack: `stack_`

The `stack_` keyword forces an allocation onto the **stack**
instead of the heap. The allocation is at mode `local`; the
compiler must convince itself the value does not escape, or refuse
to compile.

The running example for the rest of this lecture is from the
CS6868 OxCaml handout: computing the length of a 2-D polyline.
First the types and a basic distance function:

```ocaml
type point = { x : float; y : float }

let distance (a @ local) (b @ local) : float =
  let dx = a.x -. b.x in
  let dy = a.y -. b.y in
  Float.sqrt (dx *. dx +. dy *. dy)
(* val distance : point @ local -> point @ local -> float = <fun> *)
```

Both arguments are at mode `local`: `distance` promises to consume
them within its body, never capturing or returning them. The body
reads two field values, does arithmetic, calls `Float.sqrt`. The
returned `float` is not marked local (we will see why in a moment),
so the answer escapes to the caller cleanly.

Now use it:

```ocaml
let test_distance () =
  let a = stack_ { x = 0.0; y = 0.0 } in
  let b = stack_ { x = 3.0; y = 4.0 } in
  distance a b
(* val test_distance : unit -> float = <fun>
   test_distance ();; - : float = 5.0 *)
```

Both `point` records live on `test_distance`'s stack frame. The
`stack_` keyword forces the record to be allocated there. When
`test_distance` returns, both points evaporate with the frame, no
GC involved. The `float` answer escapes back to the caller because
floats are computed fresh and `distance`'s return is not locally
constrained.

:::slide

## `stack_`: allocate on the current stack frame

```ocaml
let stack_demo () =
  let a = stack_ { x = 0.0; y = 0.0 } in
  a.x +. a.y
```

- Allocates the record on **the stack**, in the current function's
  *region*.
- The resulting value is at mode `local`. It cannot escape the
  region.
- Free: no allocator runs.
- Fast: stack pointer up, stack pointer down.

:::

## What escape *means* and what the compiler says

Suppose we make a mistake and try to return a `stack_`-allocated
point:

```ocaml
(* Press Run to see the compiler's refusal inline. *)
let escape_demo () =
  let p = stack_ { x = 1.0; y = 2.0 } in
  p
```

The compiler refuses. Here is what it says, verbatim from the
OxCaml compiler on this snippet:

> Error: This value is local because it is stack_-allocated.
> However, the highlighted expression is expected to be local to
> the parent region or global because it is a function return
> value.
> Hint: Use exclave_ to return a local value.

The error spells out the situation: `p` is local because we put
it on the stack; but a function return value must be at least
local-in-the-parent-region (the caller's region, since this
function's region is about to disappear), or fully global. Our `p`
is local-in-*our*-region, which is the wrong region.

The same diagnosis fires if we try to stash a local value in a
long-lived global cell:

```ocaml
(* Press Run; the locality checker rejects storing a local value
   into a long-lived global cell. *)
let storage : point ref = ref { x = 0.0; y = 0.0 }

let store_local () =
  let p = stack_ { x = 1.0; y = 2.0 } in
  storage := p
```

The compiler's response:

> Error: This value is local because it is stack_-allocated.
> However, the highlighted expression is expected to be global.

`storage` is a global mutable cell. Anything assigned into it must
also be global, because the cell will outlive whatever scope
performed the assignment. Our `p` is not global. Type error.

The mental model is: every `stack_` allocation lives in a
**region**, and the function's region disappears when the function
returns. A reference to memory in that region would become a
dangling pointer; the compiler refuses to let one escape. This is
exactly the C `return &x` bug, type-checked into nonexistence.

:::slide

## Escape attempts are type errors

```ocaml
(* Press Run; the compiler refuses on locality grounds. *)
let escape_slide () =
  let p = stack_ { x = 1.0; y = 2.0 } in
  p   (* type error: p is local, return must not be *)
```

```ocaml
(* Press Run; same axis, different escape route. *)
let stash_slide () =
  let p = stack_ { x = 1.0; y = 2.0 } in
  storage := p   (* type error: storage holds global, p is local *)
```

The C bug `return &x` becomes a compile-time refusal.

:::

## Returning a local value: `exclave_`

Sometimes you *do* want a helper function whose job is to build a
fresh local value for the caller. The CS6868 handout's example: a
function `midpoint a b` that allocates a fresh point between two
input points and returns it. Where should the fresh point live?

Not on `midpoint`'s own stack frame: that frame is about to
disappear when `midpoint` returns. The right place is the
**caller's** region: the caller is the one whose lifetime the new
point will share.

The `exclave_` keyword expresses exactly that. It says "allocate
this in the caller's region, not mine":

```ocaml
let midpoint (a @ local) (b @ local) : point @ local =
  exclave_ { x = (a.x +. b.x) /. 2.0;
             y = (a.y +. b.y) /. 2.0 }
(* val midpoint : point @ local -> point @ local -> point @ local *)
```

The return type is `point @ local`: the caller gets a local value.
The body uses `exclave_` to allocate the record in the caller's
region rather than the helper's region. So the new point is local
from the caller's point of view, lives as long as the caller's
region, and disappears when the caller's frame goes.

Composition works:

```ocaml
let translate (p @ local) (dx : float) (dy : float)
    : point @ local =
  exclave_ { x = p.x +. dx; y = p.y +. dy }
```

A chain of `exclave_`-using helpers passes the buck up: each
helper allocates in its caller's region. The chain bottoms out at
the original non-exclave-using caller, whose region is where every
intermediate value ends up.

A subtle restriction: `stack_` only works on a *syntactic*
allocation site (a record literal, a tuple, a closure, a boxed
number). You cannot write `stack_ (midpoint a b)`, because
`midpoint a b` is a function call, not an allocation. The
function's job, if it wants to return something stack-friendly,
is to use `exclave_`.

:::slide

## `exclave_`: allocate in the caller's region

```ocaml
let midpoint_recap (a @ local) (b @ local) : point @ local =
  exclave_ { x = (a.x +. b.x) /. 2.0;
             y = (a.y +. b.y) /. 2.0 }
```

- `exclave_` returns a local value, allocated in the *caller's*
  region.
- Helpers chain: every link in the chain `exclave_`s into its
  parent.

`stack_` is for syntactic allocations; `exclave_` is for returning
locals.

:::

## Mode crossing for primitive types

Look back at `distance`. It takes two `local` points and returns a
`float`. No `exclave_`. No `@ local` on the return type. How does
the `float` get out?

The answer is **mode crossing**. Some types carry no evidence for
a particular mode axis: there is no aliasing risk, no escape risk,
nothing the mode is tracking. For such types, the compiler lets a
value silently change mode along that axis. The classical examples
on the locality axis:

- `int`: lives in a register, no heap baggage. A `local` int can
  always be used where `global` is expected. `int` *mode-crosses*
  locality.
- `bool`: same story.
- `float` (the *boxed* default): *does not* mode-cross locality
  in vanilla OxCaml, because a boxed `float` is a heap-allocated
  block.

Wait. If boxed `float` does not mode-cross, how does `distance`
return a `float`? Look closely: `distance` does not return a
*local* float. It returns a fresh float, computed by `Float.sqrt`,
which allocates a fresh boxed float on the heap. So the value
flowing out is global from the start, not a local that got
mode-crossed away.

For `int`-style primitives, the cross is silent:

```ocaml
let bump (x @ local) : int = x + 1
(* val bump : int @ local -> int = <fun> *)
```

Read the signature: `int @ local -> int`. Local input, global
output. The compiler accepts the coercion because `int` is its
own evidence: it lives in a register, it cannot dangle.

OxCaml's unboxed `float#` also mode-crosses locality: it lives in
a register, like `int`. This is one of the reasons high-performance
OxCaml code uses `float#` for inner loops. The full unboxed-number
story is its own topic (see the CS6868 handout Part 6 for the
treatment); we will not pursue it further in this course.

:::slide

## Mode crossing: free coercion for register-sized types

| Type | Mode-crosses locality? |
|---|---|
| `int`, `bool`, `char` | Yes (one register) |
| `float#` (unboxed) | Yes |
| `float` (boxed default) | No |
| Records, tuples, lists | No |

A `local int` can be silently used where `global int` is expected.
A `local point` cannot.

:::

## Putting it together: the polyline

The original CS6868 handout threads one example through the whole
Part 1: a polyline of 2-D points, where every intermediate
allocation is on the stack and the compiler verifies it.

Computing the perimeter of a triangle, with three stack-allocated
points and no heap traffic:

```ocaml
let triangle_perimeter (a @ local) (b @ local) (c @ local)
    : float =
  distance a b +. distance b c +. distance c a

let test_perimeter () =
  let a = stack_ { x = 0.0; y = 0.0 } in
  let b = stack_ { x = 3.0; y = 0.0 } in
  let c = stack_ { x = 3.0; y = 4.0 } in
  triangle_perimeter a b c
(* test_perimeter ();; - : float = 12.0 *)
```

Three stack-allocated points, three calls to `distance`, no heap
allocation for the points or the perimeter computation. The
`float` answer escapes globally because it is a fresh allocation
from the `+.` operations.

The locality axis extends through data structures. A
`point list @ local` is a list whose cons cells *and* whose points
are all in the current region. You can iterate over such a list
without escape:

```ocaml
let rec sum_xs (lst : point list @ local) : float =
  match lst with
  | [] -> 0.0
  | p :: rest -> p.x +. sum_xs rest
```

And you can *build* a new local list, with `exclave_` placing the
new cons cells in the caller's region:

```ocaml
let rec translate_polyline
    (poly : point list @ local) (dx : float) (dy : float)
    : point list @ local =
  match poly with
  | [] -> exclave_ []
  | p :: rest ->
      exclave_ (translate p dx dy
                :: translate_polyline rest dx dy)
```

This is the CS6868 handout's most striking example. In vanilla
OCaml, mapping `translate` across an `n`-point list allocates `n`
new cons cells and `n` new points on the heap, for `2n`
allocations total. With OxCaml's local lists and `exclave_`, the
*same shape* of code allocates everything in the **caller's**
region. The new list lives there, the new points live there, no
GC traffic.

The recursive structure is important: each `exclave_` ends *this*
frame's region and runs the body in the parent's region; the
recursive call to `translate_polyline rest` then ends its own
frame's region and lands in *its* parent's region, which is the
same as ours. The whole spine of the list collapses into one
outermost region: the caller of the top-level `translate_polyline`.

:::slide

## The polyline example, end to end

- `distance`, `midpoint`, `translate` all take `@ local` points
  and return `float` or `point @ local`.
- A `point list @ local` is a fully-local linked list.
- `translate_polyline` builds an *entirely new* list in the
  caller's region: no heap allocation, end to end.
- Verified with `[@zero_alloc]` if you want the compiler to prove
  it.

:::

## Where locality cannot reach (yet)

Locality has a limitation that surfaces in this same example.
Consider `path_length`, which sums distances along a polyline:

```ocaml
let rec path_length (poly : point list @ local) : float =
  match poly with
  | a :: (b :: _ as rest) ->
      distance a b +. path_length rest
  | _ -> 0.0
```

This compiles. But if you tag it `[@zero_alloc]` and ask the
compiler to verify "no heap allocation," it fails:

> Error: Annotation check for zero_alloc failed on path_length.
> Error: allocation of 16 bytes for float

The bug is not in our locality story. It is that `distance a b`
returns a *boxed* `float`, a 16-byte heap block, and `+.` allocates
another for the running sum. Locality has not helped because the
escaping values were always global floats, not local points.

The fix is *unboxed* numbers: the same algorithm with `float#`
passes the `[@zero_alloc]` check at `-O3`. We will not pursue
unboxed numbers in this course (they have their own learning
curve); the point for now is that locality is one of *several*
zero-allocation tools, and you sometimes need others.

:::slide

## What locality does *not* cover

```ocaml
let rec path_length_recap (poly : point list @ local) : float =
  match poly with
  | a :: (b :: _ as rest) ->
      distance a b +. path_length_recap rest
  | _ -> 0.0
```

This compiles, but **allocates** boxed floats. Locality is for
*lifetime escape*; boxing is a *separate* axis. Fix: unboxed
`float#`, covered in OxCaml docs Part 6.

:::

## The other rule of `exclave_`

A subtle constraint, included so you do not trip on it. `exclave_`
must sit in *tail position* of the current region, and you can
write it at most once per region. If you stack `exclave_
(exclave_ e)`, the compiler responds:

> Error: Exclave expression should only be in tail position of
> the current region.

A function has exactly one region. `exclave_` ends it and runs the
body in the parent's region; after that, there is no longer a
region of *yours* to end. Reaching a grandparent's region requires
*your* caller to itself be an exclave-frame, so the chain composes
through real function boundaries, not nested keywords.

:::slide

## `exclave_` constraints

- One per region.
- Must sit in *tail position*.
- To reach a grandparent's region, the parent function must itself
  exclave.

:::

## Why this is a *type-level* fix for the C bug

The C bug:

```c
char *bad(void) {
  char buf[16];
  return buf;     /* &buf is a stack pointer; bad() returns it */
}
```

This compiles in C. Many compilers warn, but the standard does not
require an error. The program runs; at the call site, the caller
gets a pointer into a stack frame that has been popped. Reads
return whatever bytes happen to be there now; writes corrupt
whatever data the next stack frame has placed there. This is the
canonical use-after-stack-end bug, and it has produced its share
of CVEs.

The OxCaml equivalent:

```ocaml
(* The OxCaml mirror of C's `return &x`; press Run to see the
   compile-time refusal. *)
let bad () =
  let buf = stack_ (Bytes.create 16) in
  buf
```

This **does not** compile. The compiler has all the information it
needs to reject the program: `stack_` puts `buf` in `bad`'s
region; `bad` is trying to return `buf`, which escapes; locality
says no.

The fix to make it work is to use `exclave_`, which would
*explicitly* mark the allocation as going into the caller's region,
so that the lifetime story is correct. The point is: the fix is
right there in the type system, the bug is impossible without
opting in to the fix, and there is zero runtime cost. The C
version would need stack-canaries or sanitisers to catch the bug
*at runtime*, and only on the bad inputs that trigger it.

:::slide

## C vs OxCaml on stack escape

| C | OxCaml |
|---|---|
| `return &local` compiles | `return stack_-allocated` rejected |
| Bug fires at runtime, on the bad input | Bug is caught at compile time |
| Fix: never write the pattern (good luck) | Fix: use `exclave_` if you really want this |

Locality is the type-level continuation of the safety story.

:::

## Activity

:::quiz mcq id=M11-L02-q1
Consider:

```ocaml skip
let combine (p @ local) : point =
  { x = p.x *. 2.0; y = p.y *. 2.0 }
```

What does the compiler say about this function?

- [ ] It compiles; the result mode-crosses locality, so the
      caller gets a global `point`.
- [ ] It compiles; the result is local, despite the absence of
      `@ local`.
- [x] It compiles; the record literal allocates a fresh `point`
      on the heap, so the result is global, and `p` is consumed
      within the function.
- [ ] It fails: the result is local but the return type does not
      say so.

**Why:** `p` is a `local` parameter; we read its fields, fine. The
record literal `{ x = ...; y = ... }` is a *fresh* allocation, and
since it is not `stack_`-prefixed, it allocates on the heap, at
mode `global`. So the function's return type `point` (no `@ local`)
is correct: a freshly allocated heap `point` escapes to the caller
normally. Records do not mode-cross locality, so option 1 is
wrong; the result is global by *allocation*, not by mode-crossing.
The locality system here is doing exactly what it should: tracking
that we did not leak `p` itself.
:::

:::quiz mcq id=M11-L02-q2
Why does this fail to compile?

```ocaml skip
let cache : point ref = ref { x = 0.0; y = 0.0 }

let save (p @ local) : unit =
  cache := p
```

- [ ] `cache` has the wrong type.
- [ ] `save` should be declared `let save : point @ local -> unit`.
- [x] `cache` is a long-lived global cell; storing a local value
      in it would let the local value outlive its region. The
      compiler refuses the assignment.
- [ ] `p` is immutable, so it cannot be stored.

**Why:** Locality's whole job is to refuse this. `cache` lives at
top level, so it must hold a `global` `point`. `p` is `local`, by
the parameter annotation. The assignment would force a local value
into a global slot: the cell would outlive the region, the
contents would become a dangling reference. The compiler rejects
the assignment with a "this value is local, expected global"
error. Option 2 is unrelated (changing the function signature does
not change `cache`'s requirement); option 4 confuses immutability
with locality.
:::

:::slide

## Activity discussion

- `local` parameters do not poison the function's outputs: fresh
  allocations escape normally.
- Long-lived cells (global refs, top-level structures) demand
  `global` contents. Local values cannot land there.

:::

## Common pitfalls

A short list, in the spirit of the earlier modules.

**Pitfall 1: "`@ local` on a parameter restricts the *caller*."**
It restricts the *function*, not the caller. The function promises
not to capture or return the value. The caller can hand in a
`global` or a `local` value freely.

**Pitfall 2: "`stack_` works on any expression."** It only works on
syntactic allocation sites: record literals, tuples, closure
expressions, boxed-number literals. `stack_ (f x)` is a syntax
error, because `f x` is not an allocation. If you want a function
to return a stack-friendly value, the function itself must use
`exclave_`.

**Pitfall 3: "If my function compiles with `[@zero_alloc]`, then
all my hot loops are zero-allocation."** `[@zero_alloc]` is a
function-level annotation. A whole call chain can be zero-alloc
only if every link in the chain is. Spot-check the leaves: a
boxed-float computation deep in the call graph will still allocate.

**Pitfall 4: "Locality and reference-counting / linear types are
the same thing."** They are not. Locality is about *scope*: where
does this value live? Linearity (M11-L04) is about *number of
uses*: how many times can this be invoked? Some C++ / Rust idioms
blur the two; OxCaml keeps them separate, on separate axes.

## What's next

The next lecture (M11-L03) moves to the **uniqueness** axis, which
tracks whether a value has been aliased in the past. With
uniqueness in hand, we can give a *safe* type to a `free` function
for a manually managed resource: `'a t @ unique -> unit`. We will
see the compiler reject use-after-free and double-free for free.

Uniqueness alone has a subtle problem when unique values get
captured in closures; that problem motivates the linearity axis,
which is M11-L04. Then M11-L05 is the tutorial, where we build a
file-handle module that puts locality and linearity together.

:::slide

## What's next

- Lecture 3: **uniqueness**. Past-aliasing tracking. Safe `free`.
- Lecture 4: **linearity**. Future-use tracking. Safe `close`.
- Lecture 5: tutorial. A resource-management API combining both.

:::

## Reading

- **Jane Street blog**, *Oxidizing OCaml: locality*. The canonical
  presentation, with motivation:
  <https://blog.janestreet.com/oxidizing-ocaml-locality/>
- **OxCaml documentation**, stack allocation:
  <https://oxcaml.org/documentation/stack-allocation/>
- **Lorenzen, Leijen, Swamy**, *Reference Counting with Frame
  Limited Reuse* (ICFP 2024). The academic underpinning of OxCaml's
  region-based locality system:
  <https://dl.acm.org/doi/10.1145/3674642>

## Sources

The polyline running example, the worked compiler-error blocks,
and the structure of this lecture are adapted from the CS6868
OxCaml handout
(`/Users/kc/teaching/cs6868/cs6868_s26/lectures/11_oxcaml/handout.md`,
the instructor's own teaching material, freely reusable). The C
versus OxCaml framing on `return &x` and the safety narrative are
original to this course. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
