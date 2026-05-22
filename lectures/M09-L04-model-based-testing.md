---
title: "Model-based testing of stateful data structures"
lecture_no: 4
week: 9
duration_target_min: 25
concepts: [model-based testing, stateful testing, reference implementation, command sequences, observable equivalence, hash table, PBT for state]
keywords: [OCaml, QCheck, model-based testing, reference implementation, command, stateful, hash table, queue, association list, observable equivalence]
activity_question: "Suppose you have implemented a queue with O(1) amortised enqueue/dequeue (two stacks, the Banker's queue trick). What is the simplest reference implementation you could test it against? Why is a `list` a better reference than another queue implementation?"
think_about_this: "If your reference implementation is the *spec* (because it is so simple it is obviously correct), what kind of property are you actually checking? Is model-based testing a form of refinement checking? What is the relationship to formal specifications?"
reading:
  - title: "QCheck-STM: stateful model-based testing"
    url: https://github.com/ocaml-multicore/multicoretests
  - title: "Cornell CS3110, Randomized testing with QCheck"
    url: https://cs3110.github.io/textbook/chapters/correctness/randomized.html
  - title: "John Hughes, Experiences with QuickCheck (2016)"
    url: https://publications.lib.chalmers.se/records/fulltext/232550/local_232550.pdf
---

# Model-based testing of stateful data structures


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Model-based testing of stateful data structures</h2>
<p class="title-slide-label">Module 9 &middot; Lecture 4</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

[Lecture 3](M09-L03-property-based-testing.html) developed
property-based testing on *pure* functions: a list reversal, a
sort, an expression evaluator. The properties were statements
about a single function call: "for every input `xs`, `rev (rev
xs) = xs`." No state. No mutation. No sequence of calls. Just
input goes in, output comes out, property holds.

Most of real software is not like that. A hash table is
*stateful*: you `add` to it, you `find` in it, you `remove`
from it, and the result of `find` depends on every previous
`add` and `remove`. A queue is stateful: dequeue order depends
on enqueue order. A file handle is stateful. A database is
stateful. The entire OS is stateful. And the property "for
every input, the output is correct" no longer obviously
applies, because there is no single input; there is a *history*.

This lecture shows how to extend PBT to stateful code. The
technique is *model-based testing*: write a simple, obviously-
correct reference implementation (often a list or a sorted
list); generate random sequences of operations; run each
sequence against both your sophisticated implementation and the
reference; assert observable equivalence at every step.

If your real implementation is correct, the test passes for any
operation sequence. If it has a bug, some sequence triggers a
divergence between the two implementations, and QCheck shrinks
that sequence to the smallest one that still diverges. The
result is a tiny reproducer for a stateful bug, which is what
you need to debug it.

:::slide

## What this lecture covers

- **The state problem**: PBT for stateful code is harder than
  PBT for pure code.
- **Model-based testing**: test a sophisticated impl against a
  simple reference, on random sequences of operations.
- A worked example: a custom hash table tested against a list-
  based reference.
- The shrinker: how QCheck minimises *operation sequences*, not
  just data.
- When this scales: stateful libraries, parallel algorithms,
  protocol implementations.

:::

## The state problem

We have a function. We want to test it. The PBT recipe from L3
says: generate a random input, run the function, check a
property of the output. For `sort`, that is

```ocaml
QCheck.Test.make QCheck.(list int)
  (fun xs ->
     let ys = sort xs in
     is_sorted ys && same_multiset xs ys)
```

One generated input, one call, one property. Done.

Now we have a hash table:

```ocaml
module type HASHTABLE = sig
  type ('k, 'v) t
  val create : unit -> ('k, 'v) t
  val add : ('k, 'v) t -> 'k -> 'v -> unit
  val find : ('k, 'v) t -> 'k -> 'v option
  val remove : ('k, 'v) t -> 'k -> unit
  val size : ('k, 'v) t -> int
end
```

What is the *input* we generate? A single call to `add` does
not test much; the interesting behaviour is in the *interaction*
between `add`, `find`, and `remove` over a sequence of calls.

What is the *property*? "The hash table is correct" is not a
property; it is a paragraph. We need something concrete. And
the natural concrete thing is: *the hash table behaves the same
as a much simpler, obviously-correct implementation of the same
interface*.

The PBT shape stays the same: generate a random "input" (now a
*sequence of operations*), run the function (now a *function
sequence*), check a property (now *observable equivalence* with
the reference at each step). It is the same idea applied at a
higher level.

:::slide

## The state problem

A pure function:
```
input -> output -> check property
```

A stateful API:
```
sequence of operations -> sequence of outputs
                      -> check equivalence with reference
                         at each step
```

Same PBT shape, lifted to sequences and references.

:::

## The recipe in five steps

Model-based testing has a fixed structure. The five pieces:

1. **A representation of operations as data.** Define a
   variant type `command` whose constructors mirror the
   public API of the data structure under test. `Add of int
   * string`, `Remove of int`, `Find of int`, `Size`.

2. **A generator for `command list`.** Use QCheck combinators
   to produce random sequences of commands. Bias toward
   sequences that are likely to be interesting (e.g. occasional
   `Add` of a key we have already added, so `Add`-collisions
   get exercised).

3. **Two interpreters.** A function `run_real : t -> command ->
   observation` and `run_ref : t_ref -> command -> observation`.
   Each takes the (possibly mutable) state, applies the
   command, and returns whatever the operation observably
   produced (the result of `find`, the new size, ...).

4. **A property.** Given a `command list`, run it through both
   interpreters in lockstep; check that at every step, both
   produce the same observation. If any step diverges, the
   property fails and that sequence is the bug.

5. **A shrinker.** Use QCheck's default list shrinker on the
   command list. When a failing sequence is found, the
   shrinker tries to delete commands, simplify their arguments,
   and find the *smallest* sequence that still diverges.

The five pieces are all the model-based testing you need. Once
you have them, the test is one line.

:::slide

## The recipe

1. Define `command` as a variant.
2. Write a generator for `command list`.
3. Write two interpreters: `run_real` and `run_ref`.
4. Property: equivalent at every step.
5. Let QCheck shrink the failing sequence.

:::

## A worked example: int -> string hash table

Concretely: we test a custom hash table for `int -> string`
mappings against a reference implementation built from an
association list `(int * string) list`. The reference is *obvious*
to anyone reading it (an association list is the simplest
finite-map data structure); the custom hash table is more
sophisticated and could plausibly have a bug.

### Under test: the custom hash table

We write a small open-addressing hash table. The
implementation is not the point of this lecture, but here it
is for concreteness:

```ocaml
module Ht : sig
  type t
  val create : unit -> t
  val add : t -> int -> string -> unit
  val find : t -> int -> string option
  val remove : t -> int -> unit
  val size : t -> int
end = struct
  type entry = Empty | Tombstone | Live of int * string
  type t = {
    mutable buckets : entry array;
    mutable count : int;
  }

  let create () = { buckets = Array.make 8 Empty; count = 0 }

  let hash k cap = (k mod cap + cap) mod cap

  let resize t =
    let old = t.buckets in
    let new_cap = Array.length old * 2 in
    t.buckets <- Array.make new_cap Empty;
    t.count <- 0;
    Array.iter (function
      | Live (k, v) -> add_inner t k v
      | _ -> ()) old

  and add_inner t k v =
    let cap = Array.length t.buckets in
    let rec scan i =
      match t.buckets.(i) with
      | Empty | Tombstone ->
        t.buckets.(i) <- Live (k, v); t.count <- t.count + 1
      | Live (k', _) when k' = k ->
        t.buckets.(i) <- Live (k, v)
      | Live _ ->
        scan ((i + 1) mod cap)
    in
    scan (hash k cap)

  let add t k v =
    if t.count * 2 >= Array.length t.buckets then resize t;
    add_inner t k v

  let find t k =
    let cap = Array.length t.buckets in
    let rec scan i =
      match t.buckets.(i) with
      | Empty -> None
      | Tombstone -> scan ((i + 1) mod cap)
      | Live (k', v) when k' = k -> Some v
      | Live _ -> scan ((i + 1) mod cap)
    in
    scan (hash k cap)

  let remove t k =
    let cap = Array.length t.buckets in
    let rec scan i =
      match t.buckets.(i) with
      | Empty -> ()
      | Tombstone -> scan ((i + 1) mod cap)
      | Live (k', _) when k' = k ->
        t.buckets.(i) <- Tombstone; t.count <- t.count - 1
      | Live _ -> scan ((i + 1) mod cap)
    in
    scan (hash k cap)

  let size t = t.count
end
```

Eighty lines of mutable state, array indexing, linear probing,
tombstones, and resize. Many places a bug could live. The
*reference* implementation looks like this:

```ocaml
module Ref : sig
  type t
  val create : unit -> t
  val add : t -> int -> string -> unit
  val find : t -> int -> string option
  val remove : t -> int -> unit
  val size : t -> int
end = struct
  type t = (int * string) list ref

  let create () = ref []

  let add t k v =
    t := (k, v) :: List.filter (fun (k', _) -> k' <> k) !t

  let find t k = List.assoc_opt k !t

  let remove t k =
    t := List.filter (fun (k', _) -> k' <> k) !t

  let size t = List.length !t
end
```

Fifteen lines. Each operation is one line of code. *Obviously*
correct (modulo type-checks and the `assoc_opt` semantics
matching what we want). The reference does not need to be fast,
it does not need to scale, it only needs to be unambiguously
correct.

This is the heart of model-based testing: the reference is the
spec, written in code. Anything more complex than the reference
is something to test *against* the reference.

:::slide

## Two implementations of the same interface

```ocaml
(* sophisticated, fast, possibly buggy *)
module Ht : HASHTABLE = struct
  (* open addressing, linear probing, tombstones,
     resize on load factor *)
  ...
end

(* simple, slow, obviously correct *)
module Ref : HASHTABLE = struct
  type t = (int * string) list ref
  let add t k v = t := (k, v) :: List.filter ((<>) k % fst) !t
  let find t k = List.assoc_opt k !t
  ...
end
```

- The reference is the spec.
- The complex impl is what we want to ship.
- Bug => divergence under some operation sequence.

:::

### Step 1: commands as data

```ocaml
type command =
  | Add of int * string
  | Find of int
  | Remove of int
  | Size

let command_to_string = function
  | Add (k, v) -> Printf.sprintf "Add (%d, %S)" k v
  | Find k -> Printf.sprintf "Find %d" k
  | Remove k -> Printf.sprintf "Remove %d" k
  | Size -> "Size"
```

Each constructor mirrors one method of `HASHTABLE`. We carry
the arguments inside the constructor. The `command_to_string`
function pretty-prints commands for failure messages; this
matters because QCheck's failure messages will show command
sequences, and `<opaque>` is not helpful.

We deliberately do *not* model `create` as a command; that is
the initial state. Each test starts with a freshly created
table and applies a sequence of `command`s to it.

### Step 2: a generator for `command list`

```ocaml
let key_gen = QCheck.Gen.int_range 0 20
(* Small key space => collisions, lookups of present keys *)

let value_gen = QCheck.Gen.string_size (QCheck.Gen.int_range 0 5)

let command_gen : command QCheck.Gen.t =
  let open QCheck.Gen in
  oneof [
    (let* k = key_gen in
     let* v = value_gen in
     return (Add (k, v)));
    (let* k = key_gen in return (Find k));
    (let* k = key_gen in return (Remove k));
    return Size;
  ]

let command_list_gen : command list QCheck.arbitrary =
  QCheck.make
    ~print:(fun cs ->
      "[" ^ String.concat "; " (List.map command_to_string cs) ^ "]")
    (QCheck.Gen.list_size (QCheck.Gen.int_range 0 50) command_gen)
```

The `let*` is QCheck's monadic let-binding for `Gen.t`: it draws
one random value from a generator and binds it to a name (same
shape as the monadic `let*` from
[M08-L02](M08-L02-option-monad.html)).

Three observations on the generator:

**The key space is small (0 to 20).** This is the most
important design choice. A random `int` covers ~10^19 distinct
values, so two `Add`s would almost never hit the same key, and
no `Find` would ever locate anything we added. By restricting
keys to 0-20, we get frequent collisions, frequent `Find`-hits,
frequent `Remove`-of-present-key. The interesting behaviours
(collision resolution, removal, tombstone handling) are
exercised by every test.

**The command distribution is roughly uniform.** We use
`oneof` to pick among the four constructors with equal
probability. In practice you might want `Add` to fire more
often than `Size` (each `Add` is more informative than each
`Size`), but uniform is a fine default.

**The list length is bounded.** `list_size (int_range 0 50)`
caps sequences at 50 commands. Long enough to fill the table
and trigger resizes; short enough that each test is fast and
the shrinker has manageable work.

:::slide

## Generator design choices

```ocaml
let key_gen = QCheck.Gen.int_range 0 20  (* tiny key space! *)
```

- **Small key space**: forces collisions, makes Find/Remove hit
  existing keys.
- **Uniform command distribution**: simple; tune by need.
- **Bounded sequence length**: long enough to trigger resizes,
  short enough to keep tests fast.

The default `QCheck.int` keys would give zero collisions in
practice. Test the *behaviour* you care about; control the
distribution.

:::

### Step 3: two interpreters

The interpreters apply a single command to a piece of state and
return an `observation`, which captures whatever the operation
makes visible.

```ocaml
type observation =
  | OUnit
  | OInt of int
  | OFound of string option

let run_real (t : Ht.t) (c : command) : observation =
  match c with
  | Add (k, v) -> Ht.add t k v; OUnit
  | Find k -> OFound (Ht.find t k)
  | Remove k -> Ht.remove t k; OUnit
  | Size -> OInt (Ht.size t)

let run_ref (t : Ref.t) (c : command) : observation =
  match c with
  | Add (k, v) -> Ref.add t k v; OUnit
  | Find k -> OFound (Ref.find t k)
  | Remove k -> Ref.remove t k; OUnit
  | Size -> OInt (Ref.size t)
```

The observations are exactly the parts of each call's result
that are publicly visible. `Add` and `Remove` return `unit`, so
their observation is `OUnit` (they pass trivially); `Find`
returns a `string option`, observed as `OFound`; `Size` returns
an `int`, observed as `OInt`.

Why an `observation` type at all? Because the property has to
compare the *observable* output of each call. A test that just
checked "no exception was raised" would miss bugs that silently
return wrong values from `Find`. By making every visible result
an `observation`, we explicitly compare the parts of behaviour
the user can see.

:::slide

## Interpreters return observations

```ocaml
type observation =
  | OUnit
  | OInt of int
  | OFound of string option

let run_real t = function
  | Add (k, v) -> Ht.add t k v; OUnit
  | Find k -> OFound (Ht.find t k)
  | Remove k -> Ht.remove t k; OUnit
  | Size -> OInt (Ht.size t)
```

- One observation per command.
- Captures every publicly visible bit of behaviour.
- `Add`/`Remove` -> `OUnit` (only visible later via Find/Size).
- The property compares observations step by step.

:::

### Step 4: the property

```ocaml
let test_ht_matches_ref =
  QCheck.Test.make
    ~name:"hash table matches reference"
    ~count:1000
    command_list_gen
    (fun cs ->
       let real = Ht.create () in
       let ref_t = Ref.create () in
       List.for_all
         (fun c ->
            let or_ = run_real real c in
            let oref = run_ref ref_t c in
            or_ = oref)
         cs)
```

Five lines of property. Read them carefully because they encode
the entire model-based-testing idea:

- Create both a real table and a reference table, fresh.
- Walk the command list. At each step, apply the same command
  to both. Compute their observations.
- The step *passes* if the observations are equal. The step
  *fails* if they differ.
- The property is `true` iff *every* step passes.

If the hash table is correct, both implementations produce the
same observation for every command, the equality holds for
every step, and the test passes. If the hash table has a bug,
some operation eventually produces a different observation
than the reference, the equality fails, the step returns
`false`, and `List.for_all` short-circuits to `false`. The
property fails and QCheck reports the operation sequence as a
counterexample.

:::slide

## The property

```ocaml
let test_ht_matches_ref =
  QCheck.Test.make
    ~name:"hash table matches reference"
    command_list_gen
    (fun cs ->
       let real = Ht.create () in
       let ref_t = Ref.create () in
       List.for_all
         (fun c -> run_real real c = run_ref ref_t c)
         cs)
```

- Both impls start fresh.
- Apply each command to both.
- Observations must agree at *every* step.
- Disagreement => bug; QCheck shrinks the sequence.

:::

### Step 5: what shrinking does to operation sequences

The default `list` shrinker is exactly what we want. When the
property fails on, say, a 23-command sequence, the shrinker:

1. Tries dropping a single command. Re-runs both interpreters
   on the shorter sequence. Does the divergence still happen?
   If yes, the smaller sequence is the new witness; recurse.
2. If dropping any single command makes the divergence go
   away, the shrinker tries dropping pairs, then halves.
3. Eventually the shrinker arrives at a minimum-length
   sequence that still triggers the bug. For most hash-table
   bugs, this is 2-4 commands.
4. Once the length is minimal, the shrinker tries to simplify
   the arguments inside each command (smaller integers, shorter
   strings). The key in `Add (17, "asdf")` shrinks to `Add (0,
   "")` if the smaller version still triggers the bug.

The shrunk sequence is *the bug report*. For a typical hash
table off-by-one, the shrinker might end up reporting:

```
Test failed on input:
  [Add (0, ""); Remove 0; Add (0, "a"); Find 0]
Expected: OFound (Some "a"); got: OFound None
```

Four commands, three of which are needed to exercise the
"remove-then-add at the same key" pattern that triggers the
bug. A 23-command sequence with random distractors would be
unreadable. The four-command shrunk witness reads itself: "add
key 0, remove it, add it again with a new value, look it up.
Expected the new value; got nothing." Now you know exactly where
to look in your `Ht.remove` / `Ht.add` interaction.

:::slide

## Shrinking an operation sequence

A 23-command failing sequence shrinks to:

```
[Add (0, ""); Remove 0; Add (0, "a"); Find 0]
```

- Drop commands one by one.
- Then simplify arguments (integers toward 0, strings to "").
- The default list shrinker (from L3) does all this.
- Four commands = a readable bug report.

:::

## The full test, end to end

Putting the pieces together (this is the complete file you
would put in `test/test_ht.ml`):

```text
type command =
  | Add of int * string
  | Find of int
  | Remove of int
  | Size

let command_to_string = function
  | Add (k, v) -> Printf.sprintf "Add (%d, %S)" k v
  | Find k -> Printf.sprintf "Find %d" k
  | Remove k -> Printf.sprintf "Remove %d" k
  | Size -> "Size"

type observation =
  | OUnit
  | OInt of int
  | OFound of string option

let run_real (t : Ht.t) = function
  | Add (k, v) -> Ht.add t k v; OUnit
  | Find k -> OFound (Ht.find t k)
  | Remove k -> Ht.remove t k; OUnit
  | Size -> OInt (Ht.size t)

let run_ref (t : Ref.t) = function
  | Add (k, v) -> Ref.add t k v; OUnit
  | Find k -> OFound (Ref.find t k)
  | Remove k -> Ref.remove t k; OUnit
  | Size -> OInt (Ref.size t)

let key_gen = QCheck.Gen.int_range 0 20
let value_gen = QCheck.Gen.string_size (QCheck.Gen.int_range 0 5)

let command_gen : command QCheck.Gen.t =
  let open QCheck.Gen in
  oneof [
    (let* k = key_gen in
     let* v = value_gen in
     return (Add (k, v)));
    (let* k = key_gen in return (Find k));
    (let* k = key_gen in return (Remove k));
    return Size;
  ]

let command_list_gen : command list QCheck.arbitrary =
  QCheck.make
    ~print:(fun cs ->
      "[" ^ String.concat "; " (List.map command_to_string cs) ^ "]")
    (QCheck.Gen.list_size (QCheck.Gen.int_range 0 50) command_gen)

let test_ht_matches_ref =
  QCheck.Test.make
    ~name:"hash table matches reference on all command sequences"
    ~count:1000
    command_list_gen
    (fun cs ->
       let real = Ht.create () in
       let ref_t = Ref.create () in
       List.for_all
         (fun c -> run_real real c = run_ref ref_t c)
         cs)

let () = QCheck_runner.run_tests_main [test_ht_matches_ref]
```

Sixty lines for a complete stateful test. The `dune`:

```dune
(test
 (name test_ht)
 (libraries qcheck))
```

One test executable, one `dune runtest`, 1000 random operation
sequences per run, automatic shrinking on failure.

:::slide

## The complete file

```dune
(test
 (name test_ht)
 (libraries qcheck))
```

- 60 lines of OCaml.
- 1000 sequences per `dune runtest`.
- Automatic shrinking on failure.
- Catches off-by-one in Remove, tombstone bugs, resize bugs,
  hash-collision bugs, ...

The hash-table-vs-list-reference pattern is the canonical
worked example for model-based PBT.

:::

## Watching it catch a real bug

To make this concrete: suppose someone "optimises" `Ht.remove`
and gets the tombstone logic slightly wrong. They write:

```text
let remove t k =
  let cap = Array.length t.buckets in
  let rec scan i =
    match t.buckets.(i) with
    | Empty -> ()
    | Tombstone -> scan ((i + 1) mod cap)
    | Live (k', _) when k' = k ->
      (* BUG: set to Empty instead of Tombstone *)
      t.buckets.(i) <- Empty;
      t.count <- t.count - 1
    | Live _ -> scan ((i + 1) mod cap)
  in
  scan (hash k cap)
```

The subtle bug: `Empty` instead of `Tombstone`. This breaks the
"a `Find` that walks past the removed entry can still find
subsequent entries that collided with it" invariant of open
addressing. Concretely, if keys `7` and `15` both hash to the
same bucket and end up at consecutive positions (linear
probing), removing `7` and then looking up `15` will fail:
the `find` scan hits `Empty` at the first position and
returns `None`, missing `15`.

QCheck finds this. The random generator produces, eventually, a
sequence that triggers the failure. The shrinker minimises. The
output is something like:

```
random seed: 42
Test failed on input:
  [Add (0, ""); Add (8, ""); Remove 0; Find 8]
Expected: OFound (Some ""); got: OFound None
```

(The `0` and `8` are the smallest pair of integers in our `0..20`
key range that hash to the same bucket modulo 8, the initial
capacity.) Four commands, immediately legible. A unit-test
suite would need to *think* of this scenario; the model-based
test *generates* it.

This is the value proposition: writing the reference plus the
five-step harness costs maybe an hour. The harness then catches
every off-by-one, every tombstone bug, every resize bug, every
hash-collision bug, every thing the random sequence happens to
trip over. The cost is bounded; the coverage is unbounded.

:::slide

## A bug found

A buggy `Remove` clears the bucket to `Empty` instead of
`Tombstone`. Open-addressing relies on tombstones to keep
collision chains intact.

```
Test failed on input:
  [Add (0, ""); Add (8, ""); Remove 0; Find 8]
Expected: OFound (Some ""); got: OFound None
```

- `0` and `8` collide modulo the initial capacity.
- Tombstone bug breaks the lookup of `8` after `0` is removed.
- The shrunk sequence makes the bug immediate.

:::

## When does this scale?

Model-based testing scales beautifully to any data structure
with a clean interface. Some examples:

**Queues.** Reference: a `list`. Test: an `O(1)` queue
(banker's queue, batched queue, real-time queue).

**Stacks.** Reference: a `list` (head = top). Test: any stack
implementation (array-backed, linked, persistent).

**Priority queues.** Reference: a sorted list. Test: heap,
pairing heap, leftist heap.

**Maps and sets.** Reference: an association list or a sorted
list. Test: AVL tree, red-black tree, hash table, B-tree.

**LRU caches.** Reference: a list plus a counter for recency.
Test: a doubly-linked-list + hash table implementation.

**Persistent data structures.** Reference: a list of all
versions. Test: a persistent vector, finger tree, zipper.

In every case the pattern is the same: the reference is the
simplest possible thing that satisfies the interface, the
implementation under test is the optimised version, and the
property checks that they agree on every sequence of
operations.

### Limits and extensions

**Limit 1: non-determinism.** If the implementation is
non-deterministic (e.g. concurrent code, hash-table iteration
order), the simple equality check `or_ = oref` fails because
the observations *legitimately* differ. The fix is to compare
*equivalence classes*: maps as their multi-sorted contents,
iteration as the sorted result of `to_list`. The shape of the
property gets richer, but the framework still applies.

**Limit 2: concurrent code.** For multi-threaded data
structures, you want to test linearisability: the parallel
history is *equivalent to some sequential interleaving*. This
is what the [`multicoretests`
library](https://github.com/ocaml-multicore/multicoretests)
does for OCaml 5's parallel runtime, with `qcheck-stm`
(stateful model) and `qcheck-lin` (linearisability). The
underlying technique is the same as this lecture: define
commands, run on a model, check equivalence.

**Limit 3: external state.** If the data structure interacts
with the filesystem, network, or database, the reference can
sometimes be an in-memory mock. When the external state itself
is the spec, model-based testing degrades to integration
testing. The boundary is fuzzy and worth thinking about.

**Extension: state-aware command generation.** A more advanced
technique is to make the *generator itself* aware of state. For
example, after an `Add 5`, the generator should be biased to
generate `Find 5` or `Remove 5` (to exercise interesting
follow-ups), not just uniform random keys. Libraries like
`qcheck-stm` support this via a "command precondition"
mechanism: each command can be conditioned on the current
model state. Beyond the scope of this introductory lecture but
worth knowing exists.

:::slide

## When this scales

| Structure | Reference |
| --- | --- |
| Queue, stack | `list` |
| Priority queue | sorted `list` |
| Map, set | association list |
| LRU cache | list + recency counter |
| Persistent vector | list of versions |
| Concurrent data structure | linearised sequential history |

Same five-step recipe. Different reference.

:::

## The relationship to formal specifications

A philosophical aside. When you write the reference implementation,
you are writing *a specification in code*. It is executable, it
is type-checked, it is testable, and it is human-readable. It
is not a formal proof of correctness for the optimised version,
but it is a *very strong* specification: any difference between
the two on any operation sequence is, by definition, a bug in
the optimised version.

This puts model-based testing into a productive middle ground.
On one side, formal verification (Coq, Lean) gives mathematical
certainty but costs months of effort per data structure. On the
other side, unit testing gives the cases you thought of. Model-
based PBT gives you, for one hour of harness writing,
exhaustive sampling of operation sequences against a hand-
written spec. It catches almost all the bugs that unit testing
misses, almost free of cost. It is the highest-leverage testing
technique we will cover.

Some industrial cases worth knowing:

- John Hughes's group at Quviq applied this technique to
  industrial codebases at AUTOSAR, Volvo Cars, and Ericsson;
  see the *Experiences with QuickCheck* paper in the Reading.
- Jane Street uses property tests with derived generators
  (`ppx_quickcheck`) for many of their financial data
  structures; the RWO Testing chapter has a few examples.
- The OCaml 5 runtime's lock-free data structures are tested
  with `multicoretests` against a linearisability model.

:::slide

## The bigger picture

Model-based testing is the *executable spec* version of formal
verification.

- **Formal proof (Coq, Lean)**: mathematical certainty, months
  of effort.
- **Unit testing**: the cases you thought of.
- **Model-based PBT**: a sampled refinement check against a
  reference, hours of effort.

Industrial cases: Quviq + Volvo + Ericsson (Hughes); Jane
Street (ppx_quickcheck); OCaml 5's multicoretests.

:::

## A subtler example: testing a queue

To make the technique stick, let us walk through one more
example with less code. A *two-stack queue* (Banker's queue
without the lazy evaluation) is a classic data structure: it
supports `enqueue` and `dequeue` in amortised O(1) by
maintaining two stacks, `front` and `back`. Enqueue pushes onto
`back`; dequeue pops from `front`, refilling `front` by
reversing `back` when `front` is empty.

```ocaml
module Queue2 : sig
  type 'a t
  val empty : 'a t
  val enqueue : 'a -> 'a t -> 'a t
  val dequeue : 'a t -> ('a * 'a t) option
  val to_list : 'a t -> 'a list
end = struct
  type 'a t = { front : 'a list; back : 'a list }
  let empty = { front = []; back = [] }
  let enqueue x q = { q with back = x :: q.back }
  let rec dequeue = function
    | { front = []; back = [] } -> None
    | { front = []; back } ->
      dequeue { front = List.rev back; back = [] }
    | { front = x :: xs; back } -> Some (x, { front = xs; back })
  let to_list q = q.front @ List.rev q.back
end
```

Reference: just a `list`. Enqueue is `xs @ [x]` (or `x ::` from
the back); dequeue is "head and tail". Twelve lines vs. our
two-stack twelve lines, but the reference is dead obvious.

```ocaml
module Qref : sig
  type 'a t
  val empty : 'a t
  val enqueue : 'a -> 'a t -> 'a t
  val dequeue : 'a t -> ('a * 'a t) option
  val to_list : 'a t -> 'a list
end = struct
  type 'a t = 'a list
  let empty = []
  let enqueue x q = q @ [x]
  let dequeue = function [] -> None | x :: xs -> Some (x, xs)
  let to_list q = q
end
```

Now the model-based test, in compressed form:

```ocaml
type qcommand =
  | Enq of int
  | Deq
  | ToList

let qcmd_gen : qcommand QCheck.Gen.t =
  QCheck.Gen.(oneof [
    map (fun x -> Enq x) small_int;
    return Deq;
    return ToList;
  ])

let qcmd_list_gen =
  QCheck.make
    (QCheck.Gen.list_size (QCheck.Gen.int_range 0 30) qcmd_gen)

type qobs =
  | OQUnit of int list      (* the queue as a list, for observation *)
  | OQDeq of int option

let run_real_q (q : int Queue2.t ref) c =
  match c with
  | Enq x -> q := Queue2.enqueue x !q; OQUnit (Queue2.to_list !q)
  | Deq ->
    (match Queue2.dequeue !q with
     | None -> OQDeq None
     | Some (x, q') -> q := q'; OQDeq (Some x))
  | ToList -> OQUnit (Queue2.to_list !q)

let run_ref_q (q : int Qref.t ref) c =
  match c with
  | Enq x -> q := Qref.enqueue x !q; OQUnit (Qref.to_list !q)
  | Deq ->
    (match Qref.dequeue !q with
     | None -> OQDeq None
     | Some (x, q') -> q := q'; OQDeq (Some x))
  | ToList -> OQUnit (Qref.to_list !q)

let test_q =
  QCheck.Test.make
    ~name:"queue matches list reference"
    qcmd_list_gen
    (fun cs ->
       let qr = ref Queue2.empty in
       let qf = ref Qref.empty in
       List.for_all
         (fun c -> run_real_q qr c = run_ref_q qf c)
         cs)
```

Note the design choice: we wrap the persistent `Queue2` in a
`ref` to give it a stateful API matching the hash table's. This
is mostly a notational convenience for keeping the interpreters
uniform; you could equally well thread the queue value through
explicitly.

The `OQUnit (Queue2.to_list !q)` observation is the trick that
makes the queue test more thorough than just "dequeue results
agree." By including the *list representation* of the queue in
the observation after each `enqueue`, we catch bugs where the
queue's internal structure has gone wrong but the dequeue
result happens to be right anyway. If the front and back
stacks ever get out of sync in `Queue2`, `to_list` will return
the wrong list, the observation will diverge, and the test
will fail. Without observing the full queue state, those bugs
would go undetected until they later manifested in a `dequeue`.

This is a craft skill of model-based testing: *what should the
observation include?* The minimum is the literal return value of
each operation. The maximum is the entire visible state (here,
`to_list`). The maximum catches more bugs but at the cost of
more work; the minimum is cheap but lets some bugs hide. A
reasonable default is "return value plus any cheap observation
of the state after the call."

:::slide

## Queue test: include observations of state

```ocaml
let run_real_q q c =
  match c with
  | Enq x -> q := enqueue x !q; OQUnit (to_list !q)
  | Deq -> (match dequeue !q with ...)
  | ToList -> OQUnit (to_list !q)
```

- Observe the *whole queue* after each enqueue, not just the
  dequeue result.
- Catches "front/back out of sync" bugs that dequeue alone
  would miss.
- The richer the observation, the more bugs the property
  catches.

:::

## Activity

:::quiz mcq id=M09-L04-q1
You are testing a custom red-black tree implementation using
model-based PBT against an association-list reference. The
default `command_gen` produces `Add k v`, `Remove k`, and
`Find k` with equal probability and `k` chosen uniformly from
`int_range 0 1_000_000`.

After running 1000 random sequences, the test passes. A user
later reports a bug: `Remove` on a key already in the tree
sometimes leaves the tree unbalanced. Why did the test not
catch this?

- [ ] Property-based testing cannot find bugs in tree
  algorithms.
- [x] With a key space of one million and short command
  sequences, `Remove k` almost never targets a key that is
  actually in the tree, so the rebalancing branch is rarely
  exercised. Restrict the key space to e.g. `int_range 0 20`,
  or generate `Remove` keys from the set of currently-added
  keys.
- [ ] The reference implementation must also be a red-black
  tree, otherwise the comparison is meaningless.
- [ ] `Remove` cannot be tested by model-based PBT; it requires
  a dedicated invariant checker.

**Why:** the issue is *distribution*. A million-element key
space means random commands almost never collide. `Remove k`
on a key not in the tree is a no-op for both implementations,
so observations agree trivially. The interesting case (remove
a present key) almost never happens. The fix is the same fix
as the hash-table example in the lecture: use a small key
space so that random commands frequently target existing keys
and exercise the algorithm's interesting branches.
:::

:::quiz mcq id=M09-L04-q2
In the hash-table example, the property compares observations
step-by-step:

```text
List.for_all (fun c -> run_real real c = run_ref ref_t c) cs
```

Why is step-by-step equivalence important? Why not just compare
the *final* state of the two tables after running all commands?

- [ ] OCaml's `=` does not work on mutable state.
- [ ] Step-by-step is faster.
- [x] A divergence might happen in the middle of the sequence
  but be "fixed up" by a later command (e.g. a `Remove` that
  brings the two impls back into agreement by coincidence).
  Step-by-step equivalence catches the bug at the exact step
  where it occurred and gives a smaller, more readable
  counterexample after shrinking.
- [ ] Final-state comparison is impossible because the table is
  mutable.

**Why:** if two impls diverge at step 7 and then reconverge at
step 12, a final-state comparison passes; the bug is hidden. By
asserting equivalence at every step, the test fires at the
*earliest* step where the divergence occurs. Combined with
shrinking, this gives you the smallest possible bug reproducer:
"the first time these two implementations disagree is on a
4-command sequence ending in this `Find`."
:::

:::quiz code id=M09-L04-q3
Write a `command` variant type for a *stack* with three
operations: `push : int -> unit`, `pop : unit -> int option`,
and `top : unit -> int option`. (Each operation takes only the
stack itself as state; `push` also takes an `int`.) Then write
a `command_to_string` function that pretty-prints each command
for failure messages.

```ocaml
type command =
  | (* TODO: fill in *)

let command_to_string = function
  | _ -> failwith "not implemented"
```

```ocaml skip
let () =
  let s = command_to_string (Push 3) in
  assert (s = "Push 3");
  let s = command_to_string Pop in
  assert (s = "Pop");
  let s = command_to_string Top in
  assert (s = "Top");
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```ocaml
type command =
  | Push of int
  | Pop
  | Top

let command_to_string = function
  | Push x -> Printf.sprintf "Push %d" x
  | Pop -> "Pop"
  | Top -> "Top"
```

Three constructors mirroring the three stack operations, plus a
printer that uses `Printf.sprintf` for the parameterised case.
The same shape generalises to any stateful API.

:::

## Common pitfalls

**Pitfall 1: the reference has a bug too.** If the reference
implementation contains the same bug as the system under test,
the test passes despite both being wrong. *Keep the reference
trivial*. The whole point is that it is so simple that any
reader can convince themselves it is right. If the reference
is more complex than 30-50 lines, you have lost the property.

**Pitfall 2: incomplete observations.** Comparing only `Find`
results misses bugs where the internal state has gone wrong but
the next `Find` happens to be on a key not affected. Include
enough observations to make any state divergence visible: at
minimum, compare the size after every operation; ideally,
compare the full visible state.

**Pitfall 3: distribution that misses interesting cases.** The
canonical mistake: use the default `QCheck.int` for keys. The
test passes vacuously because no two random commands ever
operate on the same key. Force collisions with a small key
range.

**Pitfall 4: not enough commands.** A bug that only fires after
several resizes needs sequences long enough to trigger them. If
your tests are too short, you miss bugs that emerge from
interactions between many operations. Bound sequences at 30-50
commands by default; experiment with longer for data structures
that grow.

**Pitfall 5: assuming determinism.** If your data structure has
any randomised behaviour (e.g. a hash with `Random.int` salt,
or any concurrency), the equality check breaks. Either seed the
randomness explicitly so the test is reproducible, or compare
equivalence classes rather than raw observations.

**Pitfall 6: the reference is not the spec.** Sometimes you
inherit a "reference" implementation that itself has subtle bugs
or different semantics. Check the reference against the *actual
specification* once, by hand or by unit tests, before using it
as the oracle. Garbage in, garbage out.

:::slide

## Common pitfalls

1. **The reference itself has a bug.** Keep it under 50 lines.
2. **Observations too narrow.** Compare more than just return
   values; include cheap state observations.
3. **Distribution misses collisions.** Small key space.
4. **Sequences too short.** 30-50 commands per test.
5. **Non-determinism.** Seed it or compare equivalence classes.
6. **The reference is not the spec.** Sanity-check it by hand.

:::

## What's next

[Lecture 5](M09-L05-tutorial.html) is the module's wrap-up
tutorial: putting OUnit2 and QCheck side by side on a single
worked example (the `expr` evaluator from M05-L06), watching
QCheck catch a deliberately introduced bug. The model-based
technique from this lecture is implicit in any nontrivial
testing of stateful code; the tutorial focuses on the pure-
function case to keep the example self-contained.

:::slide

## What's next

- L5: tutorial wrap-up. OUnit2 + QCheck on the `expr`
  evaluator. A deliberately buggy implementation. A complete
  `dune` test file.

:::

## Reading

- **QCheck-STM**, a QCheck extension specifically for
  model-based testing of stateful code. Used in the OCaml 5
  multicore runtime for testing lock-free data structures:
  <https://github.com/ocaml-multicore/multicoretests>
- **Cornell CS3110**, *Randomized testing with QCheck*. The
  abstraction layering used in this lecture matches CS3110's:
  <https://cs3110.github.io/textbook/chapters/correctness/randomized.html>
- **John Hughes**, *Experiences with QuickCheck: Testing the
  Hard Stuff and Staying Sane* (2016). Industrial-scale
  applications of QuickCheck, including model-based testing of
  AUTOSAR drivers:
  <https://publications.lib.chalmers.se/records/fulltext/232550/local_232550.pdf>
- **Claessen and Hughes**, *QuickCheck: A Lightweight Tool for
  Random Testing of Haskell Programs* (2000). The original
  paper introducing PBT, and the "test against a model"
  example with finite maps:
  <https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/quick.pdf>
- **Real World OCaml**, *Testing*. The Quickcheck section
  covers manual generators for compound types, with
  `ppx_quickcheck` for boilerplate reduction:
  <https://dev.realworldocaml.org/testing.html>

## Sources

This lecture's prose, worked examples, and quizzes are original
to this course. The "test stateful impl against a simple
reference using random operation sequences" pattern is the
canonical model-based testing technique, originally articulated
in Claessen and Hughes 2000 and elaborated in Hughes 2016
(both cited in the Reading); the OCaml-specific phrasing and
the hash-table / queue worked examples are our own. The
two-stack queue (Banker's queue without lazy thunks) is a
classic data structure originally due to Burton; our
presentation is the textbook one. The QCheck library
(Simon Cruanes and contributors) is BSD-2-Clause licensed and
linked through its public API. Cornell CS3110's testing
chapters are CC BY-NC-ND licensed and have not been
derivatively reused. Real World OCaml's testing chapter is
linked for further reading; its Quickcheck and `ppx_quickcheck`
discussion is independent of ours.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
