---
title: "Locality: safe stack allocation"
lecture_no: 1
week: 11
duration_target_min: 25
concepts: [OxCaml, modes, locality, local mode, stack allocation, exclave, mode crossing, regions]
keywords: [OCaml, OxCaml, modes, locality, local, stack_, exclave_, regions, mode crossing]
activity_question: "Does a function returning a freshly-built [point] from a [@ local] parameter compile, and is its result local or global? And why does storing a [@ local] value into a top-level [ref] fail to compile?"
think_about_this: "OCaml programmers spend a surprising fraction of their time fretting about GC pressure in hot loops. If the compiler could prove a value never escapes its scope, that value could live on the stack and the GC would never see it. What information does the compiler need to make that proof?"
reading:
  - title: "Oxidizing OCaml: locality (Jane Street blog)"
    url: https://blog.janestreet.com/oxidizing-ocaml-locality/
  - title: "Stack allocation, OxCaml documentation"
    url: https://oxcaml.org/documentation/stack-allocation/
---

# Locality: safe stack allocation


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Locality: safe stack allocation</h2>
<p class="title-slide-label">Module 11 &middot; Lecture 1</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

This module is about **OxCaml**, an actively-developed, open-source
fork of the OCaml compiler (built at Jane Street, available on
GitHub). It is a strict superset: every OCaml program is already a
valid OxCaml program. What it adds falls in two camps. One is
**control** over performance: where a value is allocated, how it is
laid out in memory. The other is **safety**: ruling out data races
and tightening memory safety. Both are delivered by a single new
ingredient, **modes**.

A **mode** tracks not *what* a value is but *how* it may be used:
whether it may escape a scope, whether it has been aliased, whether
it may cross a domain boundary. Types and modes are complementary.
Where OCaml's types reject `"x" + 1`, OxCaml's modes reject, for
example, a plain `ref` being read and written by two domains at
once. A mode is *orthogonal to the type*: it is not part of the type
definition, so the same type can appear at different modes in
different places (a `t` and a `t @ local` are one type at two
modes), and the compiler checks different rules.

Module 10 showed that OCaml's garbage collector and type system rule
out a zoo of memory bugs by construction, and where that safety
stops: stack-pointer escape, use-after-free of manually managed
resources, and data races across domains. OxCaml's modes pick the
argument back up at exactly those boundaries, at zero runtime cost.
Each lecture in this module takes one mode and the bug class it
rules out. We begin with **locality**, which makes stack allocation
safe.

:::slide

## OxCaml: control and safety

- **OxCaml**: a performance-oriented superset of OCaml.
  - open source on GitHub; used in production at Jane Street.
  - every OCaml program is already a valid OxCaml program.
- Two kinds of extension:
  - **Control**: allocations and memory layout (performance).
  - **Safe**: data-race freedom and memory safety.

:::

:::slide

## Modes: how, not what

- New ingredient: **modes**.
  - types are *what* a value is; modes are *how* it may be used.
- Types reject `"x" + 1`; modes reject a plain `ref` shared by two
  domains.
- A mode is *orthogonal to the type*: `t` and `t @ local` are one
  type, two modes.
- M10 closed memory bugs; modes close stack escape, unsafe `free`,
  cross-domain races.

:::

:::slide

## Why put it in the type system

- **Zero runtime cost**: no flag, no branch, no allocation.
- **Caught at compile time**, not on the bad input in production.
- **Modular**: the signature is the contract.
- One mode per lecture; first up: **locality**.

:::

## Following up on Module 10: the handle that escaped

Module 10 closed its lecture on the edges of the safe fragment with
a resource-safety bug it could not fix. Recall the file-descriptor
stand-in: a `handle` that must be closed exactly once, with `open`,
`use`, and `close` operations that print each step and raise on
misuse.

```ocaml
type handle = { mutable closed : bool }

let my_open () = print_endline "open"; { closed = false }

let use h =
  if h.closed then failwith "use after close" else print_endline "use"

let my_close h =
  if h.closed then failwith "double close"
  else (print_endline "close"; h.closed <- true)
```

The Module 10 fix was a `with_handle` combinator, built from the
`fun_protect` cleanup combinator: it opens a handle, runs your
code, and closes on the way out, on both the normal and the
exceptional path, so leak, double-close, and use-after-close are
discharged by construction:

```ocaml
let fun_protect finally work =
  match work () with
  | x -> finally (); x
  | exception e -> finally (); raise e

let with_handle f =
  let h = my_open () in
  fun_protect (fun () -> my_close h) (fun () -> f h)

let () = with_handle (fun h -> use h)   (* prints: open, use, close *)
```

That guarantee held *as long as the handle stayed inside the
callback*. Nothing stopped a callback from stashing it in a
longer-lived place, a global `ref`, say. Then the handle *escapes*
its scope; `with_handle` still closes it on the way out, and a
later `use` reads a closed handle. Press Run and watch it raise:

```ocaml
let escaped = ref None
let () = with_handle (fun h -> escaped := Some h)   (* open, close *)
let () =
  match !escaped with
  | Some h -> use h     (* raises: Failure "use after close" *)
  | None -> ()
```

That is a *runtime* failure, on this particular run. Module 10 said
so in as many words: "Runtime scoping cannot prevent this. A
stronger type system, one that tracks whether a value is allowed
to escape, can reject `escaped := Some h` at compile time. That is
the kind of guarantee a later module builds toward." This is that
module, and **locality** is that guarantee.

The fix is one annotation: hand the callback the handle at mode
`local`. A `local` value can be used freely *within* the callback,
but the compiler forbids it from escaping. The combinator's body is
unchanged; `use` and `my_close` simply accept the handle `@ local`:

```ocaml
let my_close (h @ local) =
  if h.closed then failwith "double close"
  else (print_endline "close"; h.closed <- true)

let use (h @ local) =
  if h.closed then failwith "use after close" else print_endline "use"

let with_handle (f : handle @ local -> 'a) : 'a =
  let h = my_open () in
  fun_protect (fun () -> my_close h) (fun () -> f h)
```

The honest, in-scope client still type-checks and runs:

```ocaml
let () = with_handle (fun h -> use h)   (* prints: open, use, close *)
```

The escaping client no longer compiles. Press Run:

```ocaml
(* The handle cannot escape its scope: a compile-time error. *)
let escaped : handle option ref = ref None
let () = with_handle (fun h -> escaped := Some h)
```

> Error: This value is "local" to the parent region but is expected
> to be "global" because it is contained (via constructor "Some") in
> the value ... which is expected to be "global".

The bug Module 10 could only catch at runtime, on the unlucky run,
OxCaml catches at compile time, on the program.

:::slide

## The handle that escaped (Module 10)

```ocaml
let with_handle (f : handle @ local -> 'a) : 'a =
  let h = my_open () in
  fun_protect (fun () -> my_close h) (fun () -> f h)

let escaped : handle option ref = ref None
let () = with_handle (fun h -> escaped := Some h)
```

- Without `@ local`: the escape compiles and raises `use after
  close` at runtime (M10).
- With `handle @ local`: `escaped := Some h` is a *compile-time*
  error.
- > Error: This value is "local" ... expected to be "global"
  > because it is contained (via constructor "Some") ...

:::

## The same escape, in C

The escaping handle is one instance of a general hazard: a value
outliving the scope that owns it. C has the same bug in its
sharpest form, and its type system says nothing. A function returns
a pointer to one of its own stack locals:

```text
char *greeting(void) {
  char buf[16];
  strcpy(buf, "hello");
  return buf;            /* &buf into greeting's frame */
}

void clobber(void) {     /* reuses the just-freed stack space */
  char junk[16];
  strcpy(junk, "###############");
}

int main(void) {
  char *p = greeting();  /* p points into a frame that is now gone */
  clobber();             /* overwrites those bytes */
  printf("%s\n", p);     /* no longer "hello" */
}
```

Read the trap carefully. Right after `greeting` returns, `printf`
might still print `hello`: nothing has overwritten the frame yet,
so the old bytes linger. The program *looks* fine, which is exactly
what makes the bug dangerous. It is a bug regardless: `p` references
memory whose owning scope has ended. Force the issue with
`clobber`, which reuses the same stack space; now `p`'s bytes are
gone, and the `printf` prints garbage or segfaults. This is the
`return &x` use-after-stack bug, the stack-frame cousin of the
use-after-free Module 10 worked through on the heap. C compiles all
of it without complaint.

:::slide

## The same escape, in C

```text
char *greeting(void) {
  char buf[16]; strcpy(buf, "hello");
  return buf;            /* &buf into a frame about to be popped */
}
char *p = greeting();    /* p references a frame that is now gone */
clobber();               /* reuses that stack space */
printf("%s\n", p);       /* "hello", or garbage, or a crash */
```

- A value (`buf`) escaping the scope that owns it.
- It may *look* fine until something overwrites the frame.
- C's type system does not catch it; locality makes it
  unrepresentable.

:::

## What locality mode captures

A value at mode **`local`** is *scoped*: the compiler guarantees it
cannot escape the region it was created in. It cannot be returned,
stored in a longer-lived cell, or captured by a closure that
outlives the scope. Everything else (the default) is **`global`**
and may escape freely. Escape is a *type error*, so both the
escaping handle and C's `return &x` become unrepresentable.

That same "cannot escape" guarantee has a second, performance
payoff. If the compiler knows a value never escapes its scope, the
value is safe to put on the **stack**: when the frame is popped, no
live reference to it can survive. So locality is also the key that
unlocks safe stack allocation, which is where we turn next.

:::slide

## What locality mode captures

- A `local` value is *scoped*: it cannot escape its region.
  - not returned, not stored in a long-lived cell, not captured
    to outlive the scope.
- `global` (the default) may escape freely.
- Escape is a *type error*: the escaping handle, C's `return &x`.
- Bonus: a value that cannot escape is safe to **stack**-allocate.

:::

## Locality also buys performance: stack allocation

OCaml allocates almost everything on the heap. Tuples, records,
closures, boxed floats, list cons cells: each is a fresh
allocation, a minor-heap pointer bump the garbage collector later
reclaims. For most code this is fine. In hot loops it bites: a
renderer that produces millions of intermediate 2-D points per
frame pays GC pressure for values that live a few nanoseconds and
should sit on the stack. Vanilla OCaml cannot oblige, because it
does not know whether a given `point` escapes. Locality supplies
exactly that knowledge: a `local` point provably does not escape,
so the compiler can put it on the stack. The rest of the lecture
uses 2-D points to make this concrete.

## How locality works, mechanically

We have the intuition: `local` is scoped and stack-safe, `global`
(the default) may escape. The one rule left to state is how the two
modes relate.

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

You can hand this function an ordinary heap-allocated ref. Will it
compile?

```ocaml
let test_use_locally () =
  let r = ref 41 in
  use_locally r
```

Yes. The annotation is the function's contract, not a request to
the caller: every `global` value satisfies a `@ local` parameter,
because a `global` value can always be used in a context that
merely promises not to let it escape. The reverse fails: a `local`
value cannot be passed where `global` is required.

:::slide

## `global` satisfies `@ local`

```ocaml
let use_locally (r @ local) = !r + 1

let test_use_locally () =
  let r = ref 41 in    (* an ordinary global ref *)
  use_locally r        (* global value used at @ local: fine *)
```

- `@ local` is the *function's* promise: it will not let `r` escape.
- Any `global` value satisfies it (`global ⊑ local`).
- The reverse is rejected: a `local` value cannot be passed where
  `global` is required.

:::

:::slide

## The locality axis

| Mode | Meaning | May escape? |
|---|---|---|
| **`global`** (default) | Lives on the heap | Yes |
| **`local`** | Confined to its region | No |

Submoding: `global ⊑ local`. A `global` value can flow into a
`@ local` slot. The reverse is rejected.

```ocaml
type point = { x : float; y : float }
```

- Running example for this lecture: 2-D points.

:::

## Putting `stack_` to work

The `stack_` keyword forces an allocation onto the **stack**
instead of the heap, at mode `local`; the compiler convinces itself
the value does not escape, or refuses to compile.

The running example for the rest of this lecture: computing the
length of a 2-D polyline, built from the `point` type. First a
basic distance function:

```ocaml
let distance (a @ local) (b @ local) =
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
  let d = distance a b in
  d

let _ = test_distance ()  (* = 5. *)
```

We bind `distance a b` to `d` and return `d`, rather than returning
the call result directly. The locality checker
refuses a tail-position call whose arguments are stack-allocated in
the current region, because tail-call optimisation would otherwise
let the callee outlive the arguments. Binding to a local `d` first
puts the call out of tail position; the stack frame (holding `a`
and `b`) survives until the call completes.

Both `point` records live on `test_distance`'s stack frame. The
`stack_` keyword forces the record to be allocated there. When
`test_distance` returns, both points evaporate with the frame, no
GC involved. The `float` answer escapes back to the caller because
floats are computed fresh and `distance`'s return is not locally
constrained. (Run the cell: the toplevel echoes `- : float = 5.`.)

:::slide

## `stack_`: a point on the stack

```ocaml
type point = { x : float; y : float }

let distance (a @ local) (b @ local) =
  let dx = a.x -. b.x in
  let dy = a.y -. b.y in
  Float.sqrt (dx *. dx +. dy *. dy)

let test_distance () =
  let a = stack_ { x = 0.0; y = 0.0 } in
  let b = stack_ { x = 3.0; y = 4.0 } in
  let d = distance a b in
  d                          (* = 5. *)
```

- `stack_` allocates each record on the current frame, at mode
  `local`.
- Bind the call to `d` (out of tail position) so the frame outlives
  it.
- The `float` result escapes; the points evaporate with the frame.

:::

## A second escape route: storing into a global cell

Returning a stack value is one way to make it escape; storing it
into a longer-lived cell is another, and the compiler catches it
the same way. First an ordinary global `ref`:

```ocaml
let storage : point ref = ref { x = 0.0; y = 0.0 }
```

Then the mistake:

```ocaml
(* Press Run; the locality checker rejects storing a local value
   into a long-lived global cell. *)
let store_local () =
  let p = stack_ { x = 1.0; y = 2.0 } in
  storage := p
```

> Error: This value is "local" because it is "stack_"-allocated.
> However, the highlighted expression is expected to be "global".

`storage` is a global mutable cell. Anything assigned into it must
also be global, because the cell will outlive whatever scope
performed the assignment. Our `p` is not global. Type error.

The mental model is: every `stack_` allocation lives in a
**region**, and the function's region disappears when the function
returns. A reference to memory in that region would become a
dangling pointer; the compiler refuses to let one escape, whether
the escape is by return (as we saw) or by store.

:::slide

## A second escape route: a global cell

```ocaml
let storage : point ref = ref { x = 0.0; y = 0.0 }

let store_local () =
  let p = stack_ { x = 1.0; y = 2.0 } in
  storage := p   (* type error: storage holds global, p is local *)
```

- Return *and* store are both escapes; both are type errors.
- A long-lived cell must hold a `global`; a `local` cannot land
  there.

:::

## Returning a local value: `exclave_`

Sometimes you *do* want a helper function whose job is to build a
fresh local value for the caller. The standard example: a
function `midpoint a b` that allocates a fresh point between two
input points and returns it. Where should the fresh point live?

Not on `midpoint`'s own stack frame: that frame is about to
disappear when `midpoint` returns. The right place is the
**caller's** region: the caller is the one whose lifetime the new
point will share.

The `exclave_` keyword expresses exactly that. (The name comes
from the geographic sense of "exclave": a piece of one country's
territory that sits inside another's. An `exclave_` allocation
sits in the *caller's* region while syntactically appearing in
*this* function's body.) Consider a `midpoint` helper that builds
a fresh point between two inputs; `exclave_` says "allocate this
in the caller's region, not mine":

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
number). Write `stack_ (midpoint a b)` and the compiler answers
"This expression is not an allocation site": `midpoint a b` is a
function call, not an allocation. The function's job, if it wants
to return something stack-friendly, is to use `exclave_`.

:::slide

## `exclave_`: allocate in the caller's region

```ocaml
let midpoint (a @ local) (b @ local) : point @ local =
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
OxCaml code uses `float#` for inner loops. We will meet `float#`
again at the end of this lecture, where it removes the last heap
allocation from the polyline; its full story is the OxCaml
documentation's *unboxed types*.

You might expect that annotating `distance`'s return as
`float @ local` (or wrapping `Float.sqrt ...` in `exclave_`) would
force the issue, or be rejected. Neither: both *compile* and change
nothing, because a `global` float coerces down to `local` for free
(`global ⊑ local`), so the annotation is satisfied trivially. The
float's real cost is not escape at all; it is that a boxed `float`
is a heap *allocation*. That is a separate axis from locality, and
the zero-allocation section at the end of the lecture is where it
gets addressed, with `float#`.

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

One example threads through this whole lecture: a polyline of 2-D
points, where every intermediate allocation is on the stack and
the compiler verifies it.

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
  let p = triangle_perimeter a b c in  (* out of tail position *)
  p
(* test_perimeter ();; - : float = 12.0 *)
```

Three stack-allocated points, three calls to `distance`, no heap
allocation for the points or the perimeter computation. The
`float` answer escapes globally because it is a fresh allocation
from the `+.` operations. Note the same binding dance as
`test_distance`: the call is bound to `p` first, putting it out
of tail position so the stack frame holding `a`, `b`, `c`
survives the call.

:::slide

## A triangle perimeter, on the stack

```ocaml
let triangle_perimeter (a @ local) (b @ local) (c @ local) : float =
  distance a b +. distance b c +. distance c a

let test_perimeter () =
  let a = stack_ { x = 0.0; y = 0.0 } in
  let b = stack_ { x = 3.0; y = 0.0 } in
  let c = stack_ { x = 3.0; y = 4.0 } in
  let p = triangle_perimeter a b c in
  p                          (* = 12. *)
```

- Three stack points, three `distance` calls, no heap traffic.
- The perimeter is a `float`: a fresh *global* scalar that escapes.
- To return a *local* value (a fresh point or list) you need
  `exclave_`, which the next slide uses.

:::

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
let[@zero_alloc] [@inline never] rec translate_polyline
    (poly : point list @ local) dx dy : point list @ local =
  match poly with
  | [] -> exclave_ []
  | p :: rest ->
      exclave_ (translate p dx dy :: translate_polyline rest dx dy)
```

The `[@zero_alloc]` annotation asks the compiler to *prove*, at
`-O3`, that the function allocates nothing on the heap;
`translate_polyline` passes, because every cons cell and every
translated point lives in the caller's region. (The check runs in
the native compiler, not the in-browser toplevel, which accepts the
annotation without verifying it.)

This is the most striking example of the lecture. In vanilla
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

## Building a local list with `exclave_`

```ocaml
let translate (p @ local) (dx : float) (dy : float) : point @ local =
  exclave_ { x = p.x +. dx; y = p.y +. dy }

let[@zero_alloc] [@inline never] rec translate_polyline
    (poly : point list @ local) dx dy : point list @ local =
  match poly with
  | [] -> exclave_ []
  | p :: rest ->
      exclave_ (translate p dx dy :: translate_polyline rest dx dy)
```

- A `point list @ local`: cons cells *and* points all in the region.
- Each `exclave_` builds into the *caller's* region, so the whole
  new list lives there: no heap traffic, end to end.
- `[@zero_alloc]` makes the compiler prove it (at `-O3`).

:::

## Zero allocation, and where it stops

`translate_polyline` passed `[@zero_alloc]`. `path_length` is the
cautionary contrast. It looks just as local, but tag it
`[@zero_alloc]` and the compiler refuses:

```text
let[@zero_alloc] [@inline never] rec path_length
    (poly : point list @ local) : float =
  match poly with
  | a :: (b :: _ as rest) -> distance a b +. path_length rest
  | _ -> 0.0
```

```text
Error: Annotation check for zero_alloc failed on function path_length.
Error: allocation of 16 bytes for float
```

The leak is not in the locality story. `distance a b` returns a
*boxed* `float`, a 16-byte heap block, and `+.` allocates another
for the running sum. Locality kept the *points* off the heap; the
*floats* were global all along (recall boxed `float` does not
mode-cross locality). This `-O3` check runs in the native compiler,
not the in-browser toplevel, so the blocks above are shown rather
than run.

:::slide

## Zero-alloc stops at boxed floats

```text
let[@zero_alloc] [@inline never] rec path_length
    (poly : point list @ local) : float = ...

Error: Annotation check for zero_alloc failed ...
Error: allocation of 16 bytes for float
```

- `translate_polyline` passes `[@zero_alloc]`: all in the region.
- `path_length` fails: `distance` returns a *boxed* float.
- Locality kept the points local; the floats were global all along.

:::

## Unboxed floats remove the last allocation

The fix is **unboxed floats**, `float#`: a float that lives in a
register instead of a heap block (it mode-crosses locality for the
same reason `int` does). Rewriting `distance` and `path_length`
over `float#` makes the whole traversal allocate nothing, and the
`[@zero_alloc]` check passes:

```text
let[@zero_alloc] [@inline never] distance_u
    (a @ local) (b @ local) : float# =
  let open Float_u in
  let dx = of_float a.x - of_float b.x in
  let dy = of_float a.y - of_float b.y in
  sqrt (dx * dx + dy * dy)

let[@zero_alloc] [@inline never] rec path_length_u
    (poly : point list @ local) (acc : float#) : float# =
  let open Float_u in
  match poly with
  | a :: (b :: _ as rest) -> path_length_u rest (acc + distance_u a b)
  | _ -> acc
```

Unboxed numbers are their own topic (the OxCaml documentation's
*unboxed types*); the point here is that locality is one
zero-allocation tool among several, and boxed-versus-unboxed is a
*separate* axis from where a value lives. These cells use `float#`
and `Float_u`, which the in-browser toplevel does not carry, so
they are shown rather than run.

:::slide

## Unboxed floats: `float#`

```text
let[@zero_alloc] [@inline never] distance_u
    (a @ local) (b @ local) : float# = ...

let[@zero_alloc] [@inline never] rec path_length_u
    (poly : point list @ local) (acc : float#) : float# = ...
```

- `float#` lives in a register; it mode-crosses locality like `int`.
- The polyline traversal now allocates nothing; `[@zero_alloc]` passes.
- Boxing is a *separate* axis from locality.

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

## Locality versus the C bug, recapped

We opened with Module 10's escaping handle, and its C cousin
`return &x`: both compile, and break at runtime on whatever input
trips the escaped reference. OxCaml's `local` mode turns that into
a compile-time error on the *program*, at zero runtime cost, and
`exclave_` is the explicit opt-in for the rare case where you
really do want to hand a fresh local value back to the caller. C
would need stack canaries or a sanitiser to catch the same bug
dynamically, and only on the inputs that trigger it.

:::slide

## C vs OxCaml on stack escape

| C | OxCaml |
|---|---|
| `return &local` compiles | `return stack_-allocated` rejected |
| Bug fires at runtime, on the bad input | Bug is caught at compile time |
| Fix: never write the pattern (good luck) | Fix: use `exclave_` if you really want this |

Locality is the type-level continuation of the safety story.

:::

:::slide

## Summary: locality mode

- Allocation on the **stack**, not just the heap.
- Two modes: `global` (default) and `local`.
  - `global` may be treated as `local`; the reverse is rejected.
  - `local` values may be stack-allocated and must not escape.
- `stack_` allocates here; `exclave_` returns into the caller's region.
- A boxed `float` is a heap value: it does not mode-cross locality.
- `[@zero_alloc]` verifies a function allocates nothing on the heap.

:::

## Activity

:::quiz mcq id=M11-L01-q1
Consider (press Run to check your reading):

```ocaml
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

:::quiz mcq id=M11-L01-q2
Why does this fail to compile? (Press Run to see the error.)

```ocaml
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

Q1 (compiles; run it):
```ocaml
let combine (p @ local) : point =
  { x = p.x *. 2.0; y = p.y *. 2.0 }
```
Q2 (rejected; run it):
```ocaml
let cache : point ref = ref { x = 0.0; y = 0.0 }
let save (p @ local) : unit = cache := p
```

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
expressions, boxed-number literals. `stack_ (midpoint a b)` is
rejected with "This expression is not an allocation site", because
a function call is not an allocation the caller can see. If you
want a function to return a stack-friendly value, the function
itself must use `exclave_`.

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

The next lecture (M11-L02) moves to the **uniqueness** axis,
which tracks whether a value has been aliased. Locality protected
values that must not outlive a scope; uniqueness protects
resources that must be released exactly once by whoever holds the
only reference. Then M11-L03 covers **linearity**, M11-L04 covers
**portability**, M11-L05 covers **contention**, and M11-L06 is
the tutorial that combines everything.

:::slide

## What's next

- Lecture 2: **uniqueness**. Past-aliasing tracking. Safe `free`.
- Lecture 3: **linearity**. Future-use tracking. Safe `close`.
- Lecture 4: **portability**. Cross-domain crossing.
- Lecture 5: **contention**. Cross-domain access.
- Lecture 6: tutorial. A resource-management API combining the axes.

:::

## Reading

- **Jane Street blog**, *Oxidizing OCaml: locality*. The canonical
  presentation, with motivation:
  <https://blog.janestreet.com/oxidizing-ocaml-locality/>
- **OxCaml documentation**, stack allocation:
  <https://oxcaml.org/documentation/stack-allocation/>
- **Lorenzen, White, Dolan, Eisenberg, Lindley**, *Oxidizing OCaml
  with Modal Memory Management* (ICFP 2024). The paper behind
  OxCaml's locality and uniqueness design:
  <https://dl.acm.org/doi/10.1145/3674642>

## Sources

The polyline running example, the worked compiler-error blocks,
and the structure of this lecture are adapted from the CS6868
OxCaml handout (the instructor's own teaching material, freely
reusable). The C versus OxCaml framing on `return &x` and the
safety narrative are original to this course. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
