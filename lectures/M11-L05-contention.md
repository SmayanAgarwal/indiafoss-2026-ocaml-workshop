---
title: "Contention: synchronisation at compile time"
lecture_no: 5
week: 11
duration_target_min: 25
concepts: [contention, uncontended, contended, shared, Atomic, mode crossing, capsule, parallel counter]
keywords: [OCaml, OxCaml, contention, uncontended, contended, Atomic, mode crossing, parallel counter, capsule]
activity_question: "A record has one immutable and one mutable field and is shared between two domains: which accesses does OxCaml reject, and why does even a *read* of the mutable field get refused on a contended value?"
think_about_this: "Portability said you could *send* a value to another domain. Contention says how you can *access* it once it gets there. What kind of value is safe to read from two domains without locking?"
reading:
  - title: "OxCaml documentation, modes"
    url: https://oxcaml.org/documentation/modes/
  - title: "CS6868 OxCaml handout, Part 2 (KC Sivaramakrishnan)"
    url: https://github.com/kayceesrk/cs6868_s26
---

# Contention: synchronisation at compile time


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Contention: synchronisation at compile time</h2>
<p class="title-slide-label">Module 11 &middot; Lecture 5</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

In the previous lecture we met **portability**: the axis that
decides whether a value can cross a domain boundary at all. The
rule there was clear. A closure that mutates a captured `ref`
cannot be spawned, because the closure is `nonportable`;
replacing the `ref` with a `Portable.Atomic.t` makes the closure
portable, and the spawn goes through.

But portability alone does not finish the data-race story. It
controls whether a value can *reach* another domain. It does not
control how the domains may *access* the value once it is there.
If two domains share a record with a mutable field, both can
write the field at the same time even though the closure was
portable. That is the other half of a race: ingredient 3 from the
four-ingredient analysis, "at least one write."

The **contention** axis closes that half. It tracks whether a
value is being accessed by multiple domains, and rules out
write-write and write-read combinations on mutable fields of
shared values. The axis is independent of portability; you can
think of portability as "is this value on the right domain?" and
contention as "is it safe to read or write this field?" The two
together deliver compile-time data-race freedom.

:::slide

## A new question: how do shared values get accessed?

- M11-L04's portability: can the value *cross* a domain
  boundary?
- This lecture's contention: how can the value *be accessed*
  once it has been shared?
- Both axes are needed: portability is ingredient 2 of a race,
  contention is ingredient 3.
- A value can be on the right domain (portable) and still be
  racy (uncontended writes).

:::

:::slide

## Where we are

- M11-L01: locality. Scope escape.
- M11-L02: uniqueness. Past aliasing.
- M11-L03: linearity. Future use.
- M11-L04: portability. Cross-domain crossing.
- This lecture (M11-L05): **contention**. Cross-domain access.

:::

:::slide

## Portability vs contention, in one slide

- **Portability** (M11-L04): can this value *get to* another
  domain at all?
- **Contention** (M11-L05): once it gets there, how can it be
  *accessed*?
- Portability is about closures crossing boundaries.
- Contention is about reads and writes of mutable fields.
- Both axes are independent. A race needs both to be wrong;
  closing either axis closes the race.

:::

## The four ingredients of a race, again

A quick recap, because this lecture is about which ingredient
each axis attacks.

A data race needs all four of these at once:

1. Two domains executing code in parallel.
2. A shared memory location accessible by both.
3. At least one write (read-read is fine).
4. The location is not atomic.

Remove any one and the race disappears. Vanilla OCaml gives you
no compile-time help on ingredients 2 to 4: you rely on the
discipline "do not forget the lock," and you find out at runtime
when you forget.

OxCaml's mode system attacks ingredients 2 and 3 directly:

- **Portability** (M11-L04) attacks ingredient 2: by rejecting
  the spawn, the shared location never becomes shared in the
  first place, or it becomes shared only through types
  (`Portable.Atomic.t`) that mode-cross both axes.
- **Contention** (this lecture) attacks ingredient 3: by
  rejecting writes (and even reads) of mutable fields of
  shared values, the compiler refuses programs where two
  domains can write the same field.

:::slide

## What each axis attacks

| Ingredient | What it is | Which axis catches it |
|---|---|---|
| 1 | Two domains | (You wrote the spawn) |
| 2 | Shared location | **Portability** (M11-L04) |
| 3 | At least one write | **Contention** (this lecture) |
| 4 | Not atomic | Mode crossing (`Atomic.t`) |

Together: every data race needs all four; OxCaml's mode system
catches 2, 3, and 4.

:::

## The contention axis

OxCaml introduces a **contention** axis with three modes (one
more than locality or portability):

- **`uncontended`** (the default): the value is exclusively
  yours. No other domain has access. You may read and write
  mutable fields freely.
- **`shared`**: the value is shared with other domains, but only
  for read access. You may read but not write any mutable
  field.
- **`contended`**: the value is shared with other domains for
  both read and write. You may not read or write mutable
  fields at all.

The submoding is `uncontended ⊑ shared ⊑ contended`. A value at
the stronger end can be used at any of the weaker positions.
"Uncontended" is the strongest promise (exclusive access);
"contended" is the weakest (anyone may write at any time).

The interesting rule is the one for reading from a contended
value: the compiler refuses even *reads* of mutable fields. This
sounds harsh, but it follows from ingredient 3 of a race. The
compiler cannot tell at the read site whether some other domain
is mid-write; the conservative answer is to refuse both.

:::slide

## The contention axis

| Mode | Meaning | Read mutable field? | Write? |
|---|---|---|---|
| **`uncontended`** | Exclusive access | Yes | Yes |
| **`shared`** | Shared, read-only | Yes | No |
| **`contended`** | Shared, read-write | **No** | No |

Submoding: `uncontended ⊑ shared ⊑ contended`.

The "no read on contended" rule is the surprising one. The
compiler cannot tell at the read site whether another domain is
mid-write; it refuses both.

:::

## Mutable fields of contended values are off-limits

Let us see the rule in action. Suppose we have a record with one
immutable and one mutable field:

```ocaml
type mood = Happy | Neutral | Sad
type thing = { price : float; mutable mood : mood }
```

Reading the immutable `price` field from a contended `thing` is
fine: nobody can be racing the read, because the field is not
mutable.

```ocaml
let price_contended (t @ contended) = t.price
(* val price_contended : thing @ contended -> float = <fun> *)
```

Writing the mutable `mood` field, however, is rejected:

```ocaml
(* Press Run; the write is rejected. *)
let cheer_up_contended (t @ contended) = t.mood <- Happy
(* Error: This value is "contended" but is expected to be
   "uncontended" because its mutable field "mood" is being
   written. *)
```

And, the surprising one, *reading* the mutable field is also
rejected:

```ocaml
(* Press Run; even the read is rejected. *)
let read_mood_contended (t @ contended) = t.mood
(* Error: This value is "contended" but is expected to be "shared"
   or "uncontended" because its mutable field "mood" is being
   read. *)
```

The error is the type system encoding ingredient 3 of a race.
The read of a mutable field on a contended value is exactly
where the racy read goes; the compiler refuses to let it
through.

If you remove the `@ contended` annotation, the value defaults to
`uncontended` and everything compiles as in regular OCaml.

:::slide

## The middle mode: `shared`

- `shared` is the read-only-share mode.
- Mutable field on `shared`: read **yes**, write **no**.
- The use case: many domains need to read the same mutable
  field; only one (or none) is writing.
- Without `shared`, you would have to choose between
  `uncontended` (only one domain) and `contended` (no reads).

A practical example: a thread-local snapshot of a config record
that one domain updates periodically and many domains read.

:::

:::slide

## Reads and writes on a contended record

```ocaml
type thing = { price : float; mutable mood : mood }
```

- `price` is immutable. Read it from `contended`: fine.
- `mood` is mutable.
- Write `t.mood` on `contended`: rejected.
- *Read* `t.mood` on `contended`: also rejected.

The read rejection is the surprising bit. It encodes ingredient
3 of a race: the compiler cannot know if another domain is
writing, so it refuses both.

:::

## Mode crossing on the contention axis

The contention axis is the place where mode crossing really
earns its keep.

- **Immutable types** mode-cross contention. An `int`, a
  `string`, an immutable record, an `Iarray.t`: every domain
  can read them simultaneously, because there is no write
  anywhere. The compiler waves them through at every contention
  mode.
- **`Atomic.t`** mode-crosses contention. The whole point of an
  atomic is to be hammered on by many domains; the runtime
  guarantees serialise the operations. The compiler trusts the
  atomic.
- **Mutable records, `ref`, `Hashtbl.t`**: do *not* mode-cross
  contention. Sharing them means accepting the contention
  discipline (reads and writes through atomics, or capsules
  with locks).

This is why the standard fix for a parallel counter is
`Atomic.t`: the atomic mode-crosses contention, so the closure
that captures it can read and write the counter from any domain
without the compiler raising an objection. The mode-crossing rule
expresses, at the type level, exactly the discipline you would
use at runtime: "use atomics to share state safely."

:::slide

## `Atomic.t`: a typed mode-crossing pattern

- `Atomic.t` is the standard library's race-free shared cell.
- Its operations (`Atomic.get`, `Atomic.incr`,
  `Atomic.fetch_and_add`) are uninterruptible at the runtime
  level.
- At the type level, `Atomic.t` *mode-crosses contention*: the
  compiler accepts read and write at any contention mode.
- So a closure can hold an `Atomic.t` and have any domain
  hammer on it, all from the type checker's blessing.

This is one of the cleanest examples of a runtime pattern being
lifted into a typed pattern.

:::

:::slide

## Mode crossing on contention

| Type | Mode-crosses contention? |
|---|---|
| `int`, `string`, immutable records | Yes |
| `Iarray.t` (immutable arrays) | Yes |
| `Atomic.t` | Yes |
| `ref`, mutable record, `Hashtbl.t` | No |

`Atomic.t` is the typed pattern for safely shared mutable state:
it is always safe to access, regardless of contention mode.

:::

:::slide

## Immutable data: free to share

- An immutable type mode-crosses contention.
- Many domains can read an `int`, a `string`, an immutable
  record, an `Iarray.t` simultaneously: there is no write,
  so there is no race.
- This is why parallel APIs reach for `Iarray.t` for shared
  input data: it slots into any domain without contention
  worry.

If you can make your data immutable, the contention axis
disappears for free.

:::

## A parallel-counter program

Time to make it concrete. Here is a parallel counter program
that vanilla OCaml accepts (and races), and that OxCaml rejects
until rewritten.

The racing version:

```ocaml
(* Compiles in OCaml 5 today; races at runtime on a multicore
   machine. (This browser toplevel is single-domain, so the loss
   will not show here; the point is that the program compiles.) *)
[@@@alert "-do_not_spawn_domains"]
[@@@alert "-unsafe_multidomain"]
let count = ref 0
let d1 = Domain.spawn (fun () ->
  for _ = 1 to 1_000_000 do count := !count + 1 done)
let d2 = Domain.spawn (fun () ->
  for _ = 1 to 1_000_000 do count := !count + 1 done)
let () = Domain.join d1; Domain.join d2
let () = Printf.printf "count = %d\n" !count
(* On a parallel build: expected 2_000_000, actually below it. *)
```

The runtime behaviour: lost updates, a wrong final count, no
warning. The standard OCaml compiler accepts the program because
its type system has nothing to say about how `count` is shared.

OxCaml's `Domain.Safe.spawn` rejects the closure on portability
grounds first (the closure captures a `ref`). Even if you tried
to wrap the program in a portable closure, the access to a
shared mutable `int ref` would hit the contention rule the
moment the body tried to read or write `count` from a contended
context.

The fix is `Portable.Atomic.t`, which mode-crosses contention
(and portability, so the closure can be spawned). As in the
previous lecture, the counter lives in a module so the spawned
closure can read it back at portable mode:

```ocaml
module Counter = struct
  open Portable
  let count = Atomic.make 0
  let bump_loop n =
    for _ = 1 to n do Atomic.incr count done
  let value () = Atomic.get count
end

let () =
  let d1 = Domain.Safe.spawn (fun () -> Counter.bump_loop 1_000_000) in
  let d2 = Domain.Safe.spawn (fun () -> Counter.bump_loop 1_000_000) in
  Domain.join d1;
  Domain.join d2;
  Printf.printf "count = %d\n" (Counter.value ())
(* count = 2000000 *)
```

The compiler verified the program is race-free before anything
ran; given that, atomic increments cannot lose updates, and the
final count is exactly 2,000,000 on any machine, parallel or
not.

:::slide

## Parallel counter: before and after

| Version | OCaml today | OxCaml |
|---|---|---|
| `int ref`, `count := !count + 1` | Compiles, races | Rejected (portability + contention) |
| `Atomic.t`, `Atomic.incr count` | Compiles, runs correctly | Compiles, runs correctly |

`Portable.Atomic.t` is the typed pattern that ships across
domains *and* is safe to access in parallel. The mode system
expresses, at the type level, the discipline you already
followed at runtime.

:::

## No compile-time safety in vanilla OCaml

Atomics handle a counter or a flag. For richer shared state, a
hash table, a buffer, a connection pool, the runtime answer is a
mutex, and the discipline is "lock before you touch it." Vanilla
OCaml does not check that discipline:

```ocaml
let mutex = Mutex.create ()
let shared_table : (string, int) Hashtbl.t = Hashtbl.create 16

let safe_insert k v =
  Mutex.lock mutex;
  Hashtbl.add shared_table k v;
  Mutex.unlock mutex

(* Nothing stops you from forgetting the lock: *)
let unsafe_insert k v =
  Hashtbl.add shared_table k v   (* DATA RACE, and it compiles fine *)
```

Both functions compile. `unsafe_insert` races if two domains call
it, and the compiler said nothing: correctness rests on a
convention the type system cannot see. (Run the cell; both
definitions load without complaint.)

:::slide

## No compile-time safety in vanilla OCaml

```ocaml
let safe_insert k v =
  Mutex.lock mutex; Hashtbl.add shared_table k v; Mutex.unlock mutex

let unsafe_insert k v =
  Hashtbl.add shared_table k v   (* DATA RACE; compiles fine *)
```

- Atomics cover counters/flags; richer state needs a mutex.
- "Lock before you touch it" is a *convention*.
- Vanilla OCaml accepts `unsafe_insert`. The compiler cannot see
  the missing lock.

:::

## Capsules: compile-time lock discipline

OxCaml's **capsule** library makes the lock discipline structural.
A capsule is a *branded* container for mutable state:

- the **brand** is an (implicit) type parameter that ties the data
  to one specific lock;
- you **cannot read the data without proving, at the type level,
  that you hold that lock**.

Three pieces work together:

- `Capsule.Mutex.t`: a mutex carrying a brand;
- `Capsule.Data.t`: the encapsulated data, sharing the same brand;
- an `access` token: proof that you hold the lock, required to
  unwrap the data, and handed to you only inside `with_lock`.

Here is the lecture's counter, upgraded from "an atomic int" to
"arbitrary state behind a lock." Press Run:

```ocaml
open Await

let gensym =
  let (P mutex) = Await_capsule.Mutex.create () in
  let counter = Capsule.Data.create (fun () -> ref 0) in
  let fetch_and_incr (w : Await.t) =
    Await_capsule.Mutex.with_lock w mutex
      ~f:(fun access ->
        let c = Capsule.Data.unwrap ~access counter in
        incr c;
        !c)
  in
  fun w prefix -> prefix ^ "_" ^ Int.to_string (fetch_and_incr w)

let w = Await_blocking.await Terminator.never
let s1 = gensym w "x"
let s2 = gensym w "y"
let () = Printf.printf "%s %s\n" s1 s2   (* x_1 y_2 *)
```

Read the shape, not every name. `let (P mutex) = ... create ()`
introduces a *fresh brand* tied to this mutex. The counter `ref`
is created *inside* `Capsule.Data.create`, so it has no name in
the outer scope; the only handle to it is `counter`, branded to
the mutex. `Capsule.Data.unwrap ~access counter` demands an
`access` token of the matching brand, and the only way to obtain
one is `with_lock` on that very mutex. `w : Await.t` is the
awaiter: acquiring the lock may suspend the fiber, and `w` is the
capability to wait.

The payoff: there is no way to write "forget the lock." The bare
`ref` cannot be reached outside `with_lock`, because no `access`
token of the right brand exists anywhere else. The convention that
vanilla OCaml could not enforce is now a type-level fact.

:::slide

## Capsules: forgetting the lock won't compile

```ocaml
let gensym =
  let (P mutex) = Await_capsule.Mutex.create () in
  let counter = Capsule.Data.create (fun () -> ref 0) in
  let fetch_and_incr (w : Await.t) =
    Await_capsule.Mutex.with_lock w mutex
      ~f:(fun access ->
        let c = Capsule.Data.unwrap ~access counter in
        incr c; !c)
  in
  fun w prefix -> prefix ^ "_" ^ Int.to_string (fetch_and_incr w)
```

- `Capsule.Mutex.t` (brand) + `Capsule.Data.t` (same brand) +
  `access` token.
- The `ref` lives *inside* the capsule; unreachable without a
  matching `access`.
- `access` is granted only inside `with_lock`. Forgetting the
  lock is unwritable.

:::

## Activity

:::quiz mcq id=M11-L05-q1
A record `state = { mutable counter : int; size : int }` is
shared between two domains. Both domains read `state.size`; one
domain also writes `state.counter` while the other reads it.
Which is rejected by OxCaml?

- [ ] Reading `state.size` from a contended `state`.
- [ ] Writing `state.counter` from an uncontended `state`.
- [x] Reading `state.counter` from a contended `state`.
- [ ] Constructing the `state` record.

**Why:** Reading `state.size` is fine even on a contended value
because `size` is immutable; nobody can be racing the read.
Writing `state.counter` is fine from an uncontended value (the
domain has exclusive access). The rejected access is *reading*
`state.counter` from a contended value: `counter` is mutable, and
another domain might be writing to it at the same time. The
contention axis refuses both writes *and* reads of mutable
fields on contended values, which is the surprising rule from
this lecture.
:::

:::quiz mcq id=M11-L05-q2
A team replaces a `int ref` accumulator with an `Atomic.t`
counter and the parallel program now compiles. They claim "the
mode system is satisfied because atomics mode-cross *all* the
axes." Which statement is more accurate?

- [ ] Their claim is correct; `Atomic.t` mode-crosses every axis.
- [x] Stdlib `Atomic.t` mode-crosses **contention** but not
      portability; the closure capturing it may still be
      `nonportable` unless they use `Portable.Atomic`.
- [ ] `Atomic.t` only mode-crosses portability, not contention.
- [ ] Mode crossing applies to closures, not types.

**Why:** Mode crossing is per-axis. Stdlib `Atomic.t`
mode-crosses contention (its whole point) but not portability
(the closure capturing it is still capturing thread-local
mutable state). For a closure that needs to be `portable` *and*
read the counter from multiple domains, the right type is
`Portable.Atomic.t`, which mode-crosses both axes. This is the
same point made in M11-L02 from the portability side.
:::

:::slide

## Activity discussion

Q1: a record with one mutable and one immutable field, accessed
under different contention modes. Q2: stdlib `Atomic.t` vs
`Portable.Atomic.t`.

- Reads of *immutable* fields on contended values: fine.
- Reads or writes of *mutable* fields on contended values:
  rejected.
- Mode crossing is per-axis. Stdlib `Atomic.t` crosses
  contention; `Portable.Atomic.t` crosses both.

:::

## Common pitfalls

**Pitfall 1: "Contended just means shared."** It means shared
*for read and write*. The middle mode `shared` is the read-only
share. A value at mode `shared` lets all domains read its
mutable fields but not write them; a value at `contended` lets
nobody touch its mutable fields.

**Pitfall 2: "Atomics make my closure safe to share."** They make
the *value* safe to share concurrently. The closure capturing it
is a separate question (portability, from the previous lecture).
For both guarantees together, the type is `Portable.Atomic.t`.

**Pitfall 3: "Reading a mutable field is always safe."** Not on
a contended value. Even reads can race a concurrent write. The
compiler refuses, conservatively, both. If you need read-only
access from multiple domains, mark the value `shared` (or make
the field immutable, which is often the cleaner fix).

**Pitfall 4: "Contention and portability are redundant."** They
catch different ingredients of a race. Portability stops the
value from crossing; contention stops the racy access once it
*has* crossed. A real-world program needs both axes to be
race-free.

:::slide

## What contention buys you

- Race ingredient 3 (mutable read or write) becomes a
  compile-time check.
- `Atomic.t` is the typed shorthand for "safe to share without
  the mutex."
- **Capsules** make the mutex discipline structural: the data is
  unreachable without an `access` token, granted only inside
  `with_lock`.
- Together with portability (M11-L04), all four race
  ingredients are addressed by the type system.

The cost is zero at runtime. The benefit is "the program does
not compile" instead of "the program races under load."

:::

## What's next

The next (and final) lecture of M11 is the tutorial (M11-L06).
It puts the resource axes (locality, uniqueness, linearity)
together with the concurrency axes (portability, contention) in
a single API: a resource-management module that is safe to use
within a scope, safe to share across domains, and safe to close
at most once. After M11 comes M12, which carries the safety
story down one more level, into the operating system itself.

:::slide

## What's next

- Lecture 6: tutorial. A resource-management API that combines
  the resource axes (locality, uniqueness, linearity) with the
  concurrency axes (portability, contention).
- Module 12: the safety story, carried into the operating
  system itself.

:::

## Reading

- **OxCaml documentation**, the modes overview:
  <https://oxcaml.org/documentation/modes/>
- **CS6868 OxCaml handout** (KC Sivaramakrishnan), Part 2
  (Modes and Data-Race Freedom):
  <https://github.com/kayceesrk/cs6868_s26>
- **OxCaml ICFP 2025 tutorial**, hands-on activities including
  `act04_quicksort` for parallel arrays:
  <https://github.com/oxcaml/tutorial-icfp25>

## Sources

The contention-axis table, the contended-record example, the
vanilla-mutex `unsafe_insert` motivation, the capsule-backed
`gensym`, and the `Atomic.t`-versus-`Portable.Atomic.t` story are
adapted from the CS6868 OxCaml handout, Part 2 and Part 5 (the
instructor's own teaching material, freely reusable). The framing
of contention as the "second half" of OxCaml's race-freedom story,
and the ingredient-by-ingredient table in this lecture, are
original to this course. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
