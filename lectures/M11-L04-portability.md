---
title: "Portability: data-race freedom across domains"
lecture_no: 4
week: 11
duration_target_min: 22
concepts: [portability, portable, nonportable, Domain.Safe.spawn, data race, capture, Atomic, gensym]
keywords: [OCaml, OxCaml, portability, portable, nonportable, Domain, Atomic, data race]
activity_question: "A closure captures a [Buffer.t] and appends to it; why does annotating it [@ portable] get it rejected? And why does swapping a [ref] counter for a stdlib [Atomic.t] still not make the closure portable?"
think_about_this: "OCaml today lets you build a closure that captures a mutable [ref] and hand it to [Domain.spawn]. The compiler is happy; the race happens at runtime, on the bad input. What information would the compiler need to refuse that spawn?"
reading:
  - title: "OxCaml documentation, modes"
    url: https://oxcaml.org/documentation/modes/
  - title: "CS6868 OxCaml handout, Part 2 (KC Sivaramakrishnan)"
    url: https://github.com/kayceesrk/cs6868_s26
---

# Portability: data-race freedom across domains


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Portability: data-race freedom across domains</h2>
<p class="title-slide-label">Module 11 &middot; Lecture 4</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The first half of this module built the resource story: locality
(stack allocation without escape), uniqueness (safe `free`), and
linearity (no double-`close`). Each axis let the compiler refuse
a program that mishandles a value's lifetime.

This lecture and the next one move to the other half of OxCaml's
safety story: making *concurrency* data-race-free at the type
level.
Vanilla OCaml 5 gives you domains (real OS-thread parallelism) but
no compile-time help with the races those domains can create. The
runtime conventions are familiar from any other parallel language:
do not share a `ref` across domains; if you must share, wrap it in
an `Atomic.t`; remember to lock; remember to unlock on the error
path. Forget any one of these and you have a race that may only
fire under load in production.

OxCaml's mode system makes the type checker the enforcer. Two new
axes do the work: **portability** (this lecture) and **contention**
(the next one). The portability axis asks "can this value safely
cross a domain boundary?" If a closure would let two domains race
on captured mutable state, the answer is no, and the type checker
rejects any attempt to send it to another domain. The race never
reaches runtime, because the program never compiles.

:::slide

## A new bug class: cross-domain races

- Memory bugs: M10 closed by GC + types.
- Stack escape, unsafe `free`, double `close`: closed by
  locality, uniqueness, linearity.
- Still open: **data races** across domains.
- Vanilla OCaml 5 ships domains but no compile-time race check.
- This lecture: how OxCaml fixes that, at the type level.

:::

:::slide

## Where we are

- M11-L01 to L03: the resource axes. Locality, uniqueness,
  linearity.
- This lecture (M11-L04): **portability**. Which values may
  cross a domain boundary.
- Next lecture (M11-L05): **contention**. How a shared value may
  be touched.

:::

## The motivating example: a parallel gensym race

The cleanest motivation is a small systems chore: generating
unique symbols. A sequential `gensym` is a one-liner: hold a
counter in a `ref`, increment on every call, format the result.

```ocaml
let gensym =
  let count = ref 0 in
  fun prefix ->
    count := !count + 1;
    prefix ^ "_" ^ string_of_int !count

let _ = gensym "x" (* = "x_1" *)
let _ = gensym "y" (* = "y_2" *)
```

Sequential, this is fine. The counter is incremented on every
call; the calls cannot overlap; every result is unique.

Now move to two domains. Each domain calls `gensym` concurrently
in a hot loop. The four ingredients of a data race, which we
first met when Module 10 discussed OCaml's memory model, are all
present:

1. two domains running in parallel,
2. a shared memory location: the `count` ref,
3. both domains write: each call does `count := !count + 1`,
4. the location is *not* atomic: it is a plain `ref`.

The runtime behaviour: lost updates, duplicate symbols, occasional
crashes if the runtime is unlucky. Standard OCaml will compile the
program and let you find out the hard way.

```ocaml
(* In OCaml 5 today, this compiles, and on a multicore machine it
   races at runtime. (This browser toplevel is single-domain, so
   the interleaving cannot manifest here; the point is that the
   vanilla API accepts the program.) *)
[@@@alert "-do_not_spawn_domains"]
[@@@alert "-unsafe_multidomain"]
let d1 = Domain.spawn (fun () -> for _ = 1 to 1_000 do ignore (gensym "x") done)
let d2 = Domain.spawn (fun () -> for _ = 1 to 1_000 do ignore (gensym "y") done)
let () = Domain.join d1; Domain.join d2
```

:::slide

## The gensym race

```ocaml
let gensym =
  let count = ref 0 in
  fun prefix ->
    count := !count + 1;
    prefix ^ "_" ^ string_of_int !count
```

- Sequential: fine.
- Two domains calling `gensym` in parallel: classic data race
  on `count`.
- All four race ingredients present: two domains, shared `ref`,
  two writers, non-atomic.
- Vanilla OCaml compiles it. The race fires at runtime.

:::

:::slide

## Four ingredients of a data race

1. **Two domains** executing code in parallel.
2. **A shared memory location** accessible by both.
3. **At least one write** (read-read is fine).
4. **The location is not atomic** (atomics have special
   semantics).

Remove any one ingredient and the race disappears. OxCaml's plan:
attack ingredient 2 with **portability** (this lecture), ingredient
3 with **contention** (next lecture), and ingredient 4 with mode
crossing on atomics (also next lecture).

:::

## The portability axis

OxCaml introduces a **portability** axis with two modes:

- **`nonportable`** (the default): the value is not safe to send
  to another domain. The most common reason: it captures
  thread-local mutable state, or it is a function value that
  captures such state.
- **`portable`**: the value is safe to send to another domain.
  Pure functions are portable. Functions that capture only
  immutable data are portable. Functions that capture mutable
  state are not.

The submoding is `portable ⊑ nonportable`. A `portable` value can
be used anywhere a `nonportable` value is expected ("safe to ship"
is a stronger promise than "not safe to ship"). The reverse is
rejected.

As with locality, the mode is a property of the use, not a brand
on the value: the compiler tracks it at every use site. `gensym`
is `nonportable` (because it captures `count`); a fresh closure
that does not capture any mutable state is `portable` from the
start.

:::slide

## The portability axis

| Mode | Meaning | Safe to ship to another domain? |
|---|---|---|
| **`nonportable`** (default) | Captures thread-local mutable state | No |
| **`portable`** | Pure or captures only immutable data | Yes |

Submoding: `portable ⊑ nonportable`. A `portable` value can flow
into a `@ nonportable` slot. The reverse is rejected.

:::

## `Domain.Safe.spawn` requires `portable`

OxCaml's parallel primitives bake the portability discipline into
their signatures. The relevant entry point is `Domain.Safe.spawn`.
Rather than quoting the documentation, ask the toplevel itself;
press Run:

```ocaml
let spawn = Domain.Safe.spawn
(* val spawn : (unit -> 'a) @ once portable -> 'a Domain.t *)
```

Read the reported signature carefully. The argument is a thunk
`unit -> 'a`, with *two* mode annotations. `portable` is this
lecture's subject: the thunk must be safe to hand to another
domain. And `once` is an old friend from the linearity lecture:
the spawned thunk will be run at most one time, so the API
demands no more than that. Two axes, one signature, each doing
its own job.

Vanilla OCaml has `Domain.spawn` without this annotation, which is
why the gensym race can compile today. OxCaml's `Domain.Safe.spawn`
adds the portability constraint, and the type checker enforces it.

Try to spawn the racy gensym, and the compiler stops you:

```ocaml
(* OxCaml refuses this at compile time; press Run. *)
let _ = Domain.Safe.spawn (fun () -> gensym "x")
(* Error: The value "gensym" is "nonportable" but is expected to
   be "portable" because it is used inside the function ... which
   is expected to be "portable". *)
```

The error is precise: `gensym` is nonportable, because it captures
a `ref`; the closure handed to `Domain.Safe.spawn` is expected to
be portable; the constraint cannot be satisfied. No race fires
because the program does not compile.

:::slide

## `Domain.Safe.spawn`'s signature

```ocaml
let spawn = Domain.Safe.spawn
(* val spawn : (unit -> 'a) @ once portable -> 'a Domain.t *)
```

```ocaml
(* Press Run; OxCaml refuses the racy spawn. *)
let _ = Domain.Safe.spawn (fun () -> gensym "x")
(* Error: The value "gensym" is "nonportable" but is
   expected to be "portable" ... *)
```

- The thunk must be `portable` (and `once`: run at most one time).
- The vanilla `Domain.spawn` lacks the annotations.
  - that is why the race compiles today.

:::

## Why is `gensym` nonportable?

The mechanics of the rule are worth understanding, and the rule
is sharper than "no mutable captures." A `@ portable` closure is
checked under two obligations about what it captures from its
enclosing scope:

1. every captured value must itself be portable, and
2. every captured value is treated as if another domain might be
   touching it right now, so its mutable parts are off-limits
   inside the body. (The next lecture gives this status its
   proper name: *contended*.)

A pure function captures nothing the rules can object to. Press
Run:

```ocaml
let test_portable () =
  let (f @ portable) = fun x y -> x + y in
  f 1 2

let () = Printf.printf "test_portable () = %d\n" (test_portable ())
```

Capturing a `ref` and *mutating* it is what falls afoul. Press
Run and read the error carefully; it points at the captured `r`
inside the portable closure:

```ocaml
(* Press Run; the mutation of the captured ref is rejected. *)
let test_nonportable () =
  let r = ref 0 in
  let (counter @ portable) () = incr r; !r in
  counter ()
```

The error says the captured `r` is treated as shared with other
domains ("contended"), but `incr` needs it exclusive
("uncontended"). The two requirements collide, so the closure
cannot be portable.

And now the `gensym` rejection makes sense: its closure captures
`count : int ref` and mutates it on every call. If the closure
ran on another domain, the original domain might still call
`gensym` directly. Both domains would write to `count`.
Ingredient 3 of a data race (two writers) is exactly what the
compiler is refusing to permit.

:::slide

## Why `gensym` is nonportable

- A closure's portability comes from what it **captures**.
- Captures must be portable values, and are treated as shared
  with other domains inside the body.
- Capture an immutable value: fine (nothing mutable to race on).
- Capture a `ref` and **mutate it**: rejected.
  - the compiler points at the offending capture.

`gensym` captures and mutates `count : int ref`. Therefore
nonportable. Therefore cannot be spawned.

:::

:::slide

## A pure closure is portable

```ocaml
let test_portable () =
  let (f @ portable) = fun x y -> x + y in
  f 1 2

let () = Printf.printf "test_portable () = %d\n" (test_portable ())
```

- Captures nothing mutable: nothing to race on.
- The `@ portable` annotation is checked, and passes.

:::

:::slide

## Capturing a mutable `ref`: rejected

```ocaml
(* Press Run; the mutation of the captured ref is rejected. *)
let test_nonportable () =
  let r = ref 0 in
  let (counter @ portable) () = incr r; !r in
  counter ()
```

- Captured `r` is treated as shared with other domains.
  - `incr` needs it exclusive.
  - the two requirements collide.

:::

## A non-fix: `Atomic.fetch_and_add`

The standard concurrency fix for a shared counter is an atomic:
replace the `ref` with an `Atomic.t` and the read-modify-write
becomes a single uninterruptible step. Vanilla OCaml lets you do
this:

```ocaml
let gensym_atomic =
  let count = Atomic.make 0 in
  fun prefix ->
    let n = Atomic.fetch_and_add count 1 in
    prefix ^ "_" ^ string_of_int n
```

The runtime race is gone: atomic increments serialise correctly.
But OxCaml's compiler is not satisfied yet; press Run:

```ocaml
(* Still rejected by OxCaml. *)
let _ = Domain.Safe.spawn (fun () -> gensym_atomic "x")
(* Error: The value "gensym_atomic" is "nonportable" ... *)
```

Same error shape as before. Why?

The reason is that `Atomic.t` from the standard library
mode-crosses the **contention** axis (the topic of the next
lecture): it is
safe to access concurrently from many domains without locking.
But it does *not* mode-cross the **portability** axis. A closure
capturing a top-level `Atomic.t` is still capturing thread-local
mutable state from the perspective of the closure mode rule, and
the closure is therefore still nonportable.

Atomics close the runtime race. They do not, on their own, make
the *function* portable. That is a separate question, answered by
a separate axis.

:::slide

## Atomics alone are not enough

```ocaml
let gensym_atomic =
  let count = Atomic.make 0 in
  fun prefix ->
    let n = Atomic.fetch_and_add count 1 in
    prefix ^ "_" ^ string_of_int n
```

- Runtime race: gone. Atomic increments serialise.
- Compile-time portability: still rejected.
- `Atomic.t` mode-crosses *contention* (next lecture).
- It does *not* mode-cross *portability*.

The closure still captures a top-level mutable cell, so the
closure is still nonportable.

:::

## The fix: `Portable.Atomic.t`

OxCaml ships a dedicated `Portable.Atomic` (from the `portable`
library) whose `t` mode-crosses *both* contention and
portability. A closure that captures a `Portable.Atomic.t`
instead of a stdlib `Atomic.t` is portable; it can be handed to
`Domain.Safe.spawn` without complaint.

One packaging detail before the cell. We wrap the counter and
`gensym` in a small module:

```ocaml
[@@@alert "-do_not_spawn_domains"]

module Gen = struct
  open Portable
  let count = Atomic.make 0
  let gensym prefix =
    let n = Atomic.fetch_and_add count 1 in
    prefix ^ "_" ^ string_of_int n
end

let d  = Domain.Safe.spawn (fun () -> Gen.gensym "y")
let s1 = Gen.gensym "x"
let s2 = Domain.join d
let () = Printf.printf "%s %s\n" s1 s2
(* x_1 y_0 here: the spawned thunk ran first and drew 0
   (fetch_and_add returns the pre-increment value). The x/y
   split varies with timing, but no number ever repeats. *)
```

Two domains, a shared atomic counter, no race; the compiler
verified all of that before anything ran. The toplevel reports
`module Gen : sig ... end @@ portable`: mode inference noticed
that every value inside is portable and marked the whole module
portable, so `Gen.gensym` can be read out of it at portable mode
by the spawned closure.

Why the module wrap, instead of `let (gensym @ portable) = ...`
at the top level? A quirk of the toplevel: a bare `let` lands in
the implicit toplevel module, which itself sits at the default
`nonportable` mode. When `Domain.Safe.spawn` later reads `gensym`
back out of that module, it sees a nonportable binding and
refuses, even though the closure was verified portable at its
binding site. Wrapping in `module Gen` gives the closure a
portable home. In a real `.ml` file the whole compilation unit is
a module that mode inference can mark portable wholesale, so this
dance is not necessary.

:::slide

## The fix: `Portable.Atomic` in a module

```ocaml
module Gen = struct
  open Portable
  let count = Atomic.make 0
  let gensym prefix =
    let n = Atomic.fetch_and_add count 1 in
    prefix ^ "_" ^ string_of_int n
end
```

- `Portable.Atomic` mode-crosses portability and contention.
- Wrap in a module: inference marks it `@@ portable`.
  - a bare toplevel `let` would read back as nonportable.
- `Domain.Safe.spawn` now accepts the closure.

:::

## What does and does not mode-cross portability

Mode crossing on portability tells you which *types* can sit
inside a portable closure without making it nonportable. The list
is small and worth remembering.

- **Mode-cross portability**: immutable types
  (`int`, `float`, `string`, `bool`, immutable records,
  `Iarray.t`, `Portable.Atomic.t`, pure functions).
- **Do not mode-cross portability**: anything mutable defined
  outside the closure (`ref`, mutable record, `Hashtbl.t`,
  stdlib `Atomic.t`, channels, file descriptors).

The rule of thumb: if the value carries thread-local mutable
state from the point of view of the enclosing scope, it does not
mode-cross. Atomics are the special case, and even there only
`Portable.Atomic.t` (not stdlib `Atomic.t`) crosses.

:::slide

## Mode crossing on the portability axis

| Type | Mode-crosses portability? |
|---|---|
| `int`, `float`, `string`, `bool` | Yes |
| Immutable records, `Iarray.t` | Yes |
| Pure functions | Yes |
| `Portable.Atomic.t` | Yes |
| `ref`, mutable record, `Hashtbl.t` | No |
| Stdlib `Atomic.t` | No (only contention) |

A portable closure can capture only types that mode-cross
portability.

:::

## Captures vs parameters

A subtle but important point. Portability constrains *what a
closure captures from its enclosing scope*. It does **not** force
*parameters* into any particular mode.

A `portable` function can still take a `ref` (or any other
mutable value) as a parameter and mutate it inside the body,
because parameters are supplied fresh at each call. The function
itself does not capture them; the caller hands them in. This
split matters because parallel APIs hand callbacks an explicit
token (a scheduler handle, a slice, a parallel-context tag), and
that token can carry whatever mode the API specifies even though
the callback is portable.

A small example, with the loop split out of the enclosing scope:

```ocaml
let factorial_portable n =
  let a = ref 1 in
  let rec (loop @ portable) a i =
    if i > 0 then begin
      a := !a * i;
      loop a (i - 1)
    end
  in
  loop a n;
  !a
```

Here `loop` is portable: it captures nothing from outside. It
accepts `a` as an ordinary parameter and mutates it freely; a
parameter arrives with whatever access rights the caller has, and
the caller (the outer function) holds `a` with full rights and
passes it in. (The next lecture gives this access status its
proper name.) This split is the way to write portable callbacks
that still need to read or write to a mutable accumulator.

:::slide

## Captures vs parameters

- Portability constrains **captures**, not **parameters**.
- A portable closure cannot capture mutable state from its
  enclosing scope.
- It *can* take mutable state as a parameter and mutate it.
- This is how parallel APIs hand tokens (schedulers, slices)
  into a portable callback.

:::

## Activity

:::quiz mcq id=M11-L04-q1
We try to annotate a logging function as portable. (Predict the
verdict, then press Run.)

```ocaml
let (f @ portable) =
  let log = Buffer.create 16 in
  fun x ->
    Buffer.add_string log (string_of_int x ^ "; ");
    x + 1
```

Why does the compiler refuse?

- [ ] It returns an `int`, which is not a portable type.
- [x] It captures `log : Buffer.t` and writes to it; captures of
      a portable closure are treated as shared with other
      domains, so the write is rejected.
- [ ] It uses `string_of_int`, which is not a portable function.
- [ ] Functions defined at the top level are always nonportable.

**Why:** Portability is determined by what a closure *captures*
from its enclosing scope. `f` captures `log`, a mutable buffer,
and `Buffer.add_string` writes through it. Inside a portable
closure the captured `log` is treated as if another domain might
be touching it (the error calls it "contended"), and a write
needs exclusive access. The return type, the helper calls, and
the top-level position are not the issue. The compiler points at
`log` in its diagnostic.
:::

:::quiz mcq id=M11-L04-q2
A team replaces a top-level `ref` counter with a stdlib `Atomic.t`
counter to fix a data race. After the fix, the closure that uses
the counter is still rejected by `Domain.Safe.spawn`. Why?

- [ ] Stdlib `Atomic.t` is broken.
- [ ] `Domain.Safe.spawn` does not exist; they meant
      `Domain.spawn`.
- [x] Stdlib `Atomic.t` mode-crosses contention but not
      portability, so the closure that captures it is still
      `nonportable`.
- [ ] `Atomic.fetch_and_add` runs on the GC thread.

**Why:** Atomics serialise reads and writes; they fix the runtime
race. But portability and contention are *separate* axes.
Stdlib `Atomic.t` is `mode-crossing` on the contention axis (it
can be hammered on by many domains without locking) but is *not*
mode-crossing on portability (it is still thread-local mutable
state from the closure's point of view). The fix is
`Portable.Atomic`, which mode-crosses both axes.
:::

:::solution

Q1 is rejected: the closure captures a mutable `Buffer.t` and writes
to it inside the body, so it cannot be `@ portable` (its mutable
capture is off-limits across domains).

```ocaml
(* Q1: rejected. Run it. *)
let (f @ portable) =
  let log = Buffer.create 16 in
  fun x ->
    Buffer.add_string log (string_of_int x ^ "; ");
    x + 1
```

Q2: swapping the `ref` for a stdlib `Atomic.t` fixes the runtime race
but not portability: stdlib `Atomic.t` mode-crosses contention, not
portability, so the closure is still nonportable. `Portable.Atomic`
mode-crosses both. The two axes are independent: fixing the race is
not the same as making the closure portable.

:::

## Common pitfalls

**Pitfall 1: "Atomics make my closure portable."** They make the
*data* safe to share concurrently. The *closure capturing* the
atomic is a separate question. Stdlib `Atomic.t` does not
mode-cross portability; use `Portable.Atomic` if you need a
portable closure.

**Pitfall 2: "Portability bans captures."** It does not ban
them; it disciplines them. A portable closure's captures must be
portable values, and they are treated as shared with other
domains inside the body, so any use that needs exclusive access
(a write, a read of a mutable field, a call that demands an
uncontended argument) is rejected. Immutable captures sail
through, because there is nothing mutable to race on.

**Pitfall 3: "Portability and contention are the same axis."**
They are not. Portability tracks crossing domain boundaries (the
closure goes to another domain). Contention tracks how a value
is accessed (one domain or many). The next lecture develops the
contention axis on its own terms.

**Pitfall 4: "I can mutate a parameter inside a portable
closure."** Yes; portability constrains captures, not parameters.
A `@ portable` function can take a mutable value as a parameter
and mutate it freely: the parameter arrives with the caller's
access rights.

:::slide

## What portability buys you

- Race ingredient 2 (shared mutable location) becomes a
  compile-time check.
- `Domain.Safe.spawn` refuses closures that capture
  thread-local mutable state.
- No TSan, no test sweep, no production firefight.
- Cost: zero. The runtime is exactly what you would write
  by hand.

The next axis (contention, next lecture) attacks race
ingredient 3.

:::

## What's next

The next lecture is **contention**, the other half of
the data-race-freedom story: portability decided whether a value
may reach another domain; contention decides what any domain may
do with a value once it is shared. The module then closes with
the tutorial
that combines the resource axes (locality, uniqueness, linearity)
with portability and contention in a single API.

:::slide

## What's next

- Lecture 5: **contention**. Cross-domain access. Atomic mode
  crossing.
- Lecture 6: tutorial. A resource-management API that ships
  safely across domains.

:::

## Reading

- **OxCaml documentation**, the modes overview:
  <https://oxcaml.org/documentation/modes/>
- **CS6868 OxCaml handout** (KC Sivaramakrishnan), Part 2
  (Modes and Data-Race Freedom):
  <https://github.com/kayceesrk/cs6868_s26>
- **OxCaml ICFP 2025 tutorial**, the hands-on activities
  (act01..act03 trace the gensym race exactly):
  <https://github.com/oxcaml/tutorial-icfp25>

## Sources

The gensym example, the four-ingredient race analysis, the
stdlib-vs-`Portable.Atomic` story, and the
captures-versus-parameters explanation are adapted from the
CS6868 OxCaml handout, Part 2 (the instructor's own teaching
material, freely reusable). The framing as a sequel to
the locality lecture is original to this course. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
