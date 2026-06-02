---
title: "Practice: monads and GADTs"
lecture_no: 8
week: 8
duration_target_min: 0
concepts: [practice problems, state monad, functional references, universal types, length-indexed lists, type-level arithmetic]
keywords: [OCaml, practice, assignment, monad, state, ref, GADT, length-indexed, plus, mult, min]
think_about_this: "These are the stretch end of Module 8: a state monad that simulates mutable references, and length-indexed lists whose operations carry type-level proofs. Everything is pure; the types do the bookkeeping."
reading:
  - title: "Real World OCaml, GADTs"
    url: https://dev.realworldocaml.org/gadts.html
---

# Practice for Module 8: monads and GADTs

These are stretch problems, harder than the lectures and book-only
(there are no slides). Part 1 uses the
[state monad](M08-L03-state-monad.html) to *simulate mutable
references* without any real mutation; Part 2 pushes
[length-indexed lists](M08-L05-gadts-use-cases.html) to operations
that carry the [type-level proofs](M08-L05-gadts-use-cases.html#aside-type-level-arithmetic)
from the L05 aside. Attempt them once Lectures 1 to 7 are
comfortable.

Each problem is a fill-in-the-blank cell with a `Check` button; the
reference solution sits in a collapsed block below it. The problems
share a few definitions, gathered in the *Background* section, so
run the page top to bottom (or use `Run all`) before checking a
problem.

## Background

### A functional heap

A *functional heap* is an immutable key-value store: every update
returns a new heap. You built one in the
[Module 7 practice](M07-L10-practice.html); here it is again, with
the store as a function `'k -> 'v option`.

```ocaml
module type FHEAP = sig
  type ('k, 'v) t
  val empty_heap : ('k, 'v) t
  val set : ('k, 'v) t -> 'k -> 'v -> ('k, 'v) t
  val get : ('k, 'v) t -> 'k -> 'v option
end

module FHeap : FHEAP = struct
  type ('k, 'v) t = 'k -> 'v option
  let empty_heap = fun _ -> None
  let set h k v = fun k' -> if k' = k then Some v else h k'
  let get h k = h k
end
```

### The monad interface

The same `MONAD` shape as the lectures, with `let*` as a member so
that opening a monad module brings the syntax into scope.

```ocaml
module type MONAD = sig
  type 'a t
  val return : 'a -> 'a t
  val ( let* ) : 'a t -> ('a -> 'b t) -> 'b t
end
```

### A universal type

To store values of *different* types in one heap, we need a single
type they can all be packed into. A *universal type* provides a
`pack`/`unpack` pair per use site: `pack` injects a value, `unpack`
recovers it (returning `None` if the universal value was packed by a
*different* packer). The implementation below is given; its details
do not matter, only its interface.

```ocaml
module Univ : sig
  type t
  type 'a packer = { pack : 'a -> t; unpack : t -> 'a option }
  val mk : unit -> 'a packer
end = struct
  type t = exn
  type 'a packer = { pack : 'a -> t; unpack : t -> 'a option }
  let mk : type a. unit -> a packer = fun () ->
    let module M = struct exception E of a end in
    { pack = (fun x -> M.E x);
      unpack = (function M.E x -> Some x | _ -> None) }
end
```

Each call to `Univ.mk ()` returns a fresh packer; a value packed by
one packer unpacks to `None` through any other.

### Type-level numbers and proofs

Part 2 reuses the church numerals, length-indexed vector, and the
`plus` / `mult` / `min` proof types from the
[L05 aside](M08-L05-gadts-use-cases.html#aside-type-level-arithmetic).
They are repeated here so the cells compile.

```ocaml
type z = Z
type 'n s = S of 'n

type ('a, _) vec =
  | Nil  : ('a, z) vec
  | Cons : 'a * ('a, 'n) vec -> ('a, 'n s) vec

type (_, _, _) plus =
  | PlusZero : (z, 'n, 'n) plus
  | PlusSucc : ('m, 'n, 'o) plus -> ('m s, 'n, 'o s) plus

type (_, _, _) mult =
  | MultZero : (z, 'n, z) mult
  | MultSucc : ('n, 'p, 'o) plus * ('m, 'n, 'p) mult -> ('m s, 'n, 'o) mult

type (_, _, _) min =
  | MinZero1 : (z, 'n, z) min
  | MinZero2 : ('m, z, z) min
  | MinSucc  : ('m, 'n, 'o) min -> ('m s, 'n s, 'o s) min
```

## Part 1: monads

### Problem 1: `Ref_monad`

Implement a monad that simulates OCaml-style references holding one
fixed value type. The state threaded by the monad is a *counter*
(for handing out fresh reference cells) paired with a functional
heap. A `ref` is just the integer index of its cell.

:::quiz code id=M08-L08-q1
Fill in the six members so the tests pass. `mk_ref` allocates a
fresh cell (bump the counter); `!` reads; `:=` writes; `run_state`
runs a computation from an empty heap and a zero counter.

```ocaml
module type REF_MONAD = sig
  type value
  type ref
  include MONAD
  val mk_ref : value -> ref t
  val ( ! ) : ref -> value t
  val ( := ) : ref -> value -> unit t
  val run_state : 'a t -> 'a
end

module Ref_monad (V : sig type t end) : REF_MONAD with type value = V.t =
struct
  type value = V.t
  type ref = int
  type 'a t = int * (int, value) FHeap.t -> int * (int, value) FHeap.t * 'a
  let return _ = failwith "not implemented"
  let ( let* ) _ _ = failwith "not implemented"
  let mk_ref _ = failwith "not implemented"
  let ( ! ) _ = failwith "not implemented"
  let ( := ) _ _ = failwith "not implemented"
  let run_state _ = failwith "not implemented"
end
```

```ocaml skip
let () =
  let module R = Ref_monad (struct type t = int end) in
  let open R in
  let prog =
    let* i = mk_ref 10 in
    let* iv = !i in
    let* () = i := iv + 1 in
    let* j = mk_ref 100 in
    let* jv = !j in
    return (iv, jv, ())
  in
  let (a, b, _) = run_state prog in
  if a <> 10 || b <> 100 then failwith "wrong";
  let prog2 = let* i = mk_ref 10 in let* () = i := 42 in !i in
  if run_state prog2 <> 42 then failwith "update";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
module Ref_monad (V : sig type t end) : REF_MONAD with type value = V.t =
struct
  type value = V.t
  type ref = int
  type 'a t = int * (int, value) FHeap.t -> int * (int, value) FHeap.t * 'a
  let return x = fun (c, h) -> (c, h, x)
  let ( let* ) m f = fun s -> let (c, h, a) = m s in (f a) (c, h)
  let mk_ref v = fun (c, h) -> (c + 1, FHeap.set h c v, c)
  let ( ! ) r = fun (c, h) -> (c, h, Option.get (FHeap.get h r))
  let ( := ) r v = fun (c, h) -> (c, FHeap.set h r v, ())
  let run_state m = let (_, _, a) = m (0, FHeap.empty_heap) in a
end
```

`'a t` is a state-transforming function over `(counter, heap)`,
exactly the [state monad](M08-L03-state-monad.html) with a richer
state. `return` leaves the state alone. `let*` threads the state
from one step into the next. `mk_ref` allocates at the current
counter and bumps it (the `gensym` idea, giving *generative*
references). `!` and `:=` read and write the heap at a cell's index.

:::

### Problem 2: `Poly_ref_monad`

Now lift the restriction that all cells hold the same type. The heap
stores `Univ.t`, and each reference carries its own packer, so a
cell of any type can be packed in and unpacked out.

:::quiz code id=M08-L08-q2
Fill in the members. `mk_ref` makes a fresh packer (`Univ.mk ()`),
packs the value, and stores it; `!` unpacks; `:=` repacks.

```ocaml
module type POLY_REF_MONAD = sig
  type 'a ref
  include MONAD
  val mk_ref : 'a -> 'a ref t
  val ( ! ) : 'a ref -> 'a t
  val ( := ) : 'a ref -> 'a -> unit t
  val run_state : 'a t -> 'a
end

module Poly_ref_monad : POLY_REF_MONAD = struct
  type 'a ref = int * 'a Univ.packer
  type 'a t = int * (int, Univ.t) FHeap.t -> int * (int, Univ.t) FHeap.t * 'a
  let return _ = failwith "not implemented"
  let ( let* ) _ _ = failwith "not implemented"
  let mk_ref _ = failwith "not implemented"
  let ( ! ) _ = failwith "not implemented"
  let ( := ) _ _ = failwith "not implemented"
  let run_state _ = failwith "not implemented"
end
```

```ocaml skip
let () =
  let open Poly_ref_monad in
  let prog =
    let* i = mk_ref 10 in
    let* s = mk_ref "x" in
    let* iv = !i in
    let* () = i := iv + 1 in
    let* sv = !s in
    let* iv2 = !i in
    return (sv, iv2)
  in
  if run_state prog <> ("x", 11) then failwith "wrong";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
module Poly_ref_monad : POLY_REF_MONAD = struct
  type 'a ref = int * 'a Univ.packer
  type 'a t = int * (int, Univ.t) FHeap.t -> int * (int, Univ.t) FHeap.t * 'a
  let return x = fun (c, h) -> (c, h, x)
  let ( let* ) m f = fun s -> let (c, h, a) = m s in (f a) (c, h)
  let mk_ref v = fun (c, h) ->
    let p = Univ.mk () in (c + 1, FHeap.set h c (p.Univ.pack v), (c, p))
  let ( ! ) (i, p) = fun (c, h) ->
    (c, h, Option.get (p.Univ.unpack (Option.get (FHeap.get h i))))
  let ( := ) (i, p) v = fun (c, h) -> (c, FHeap.set h i (p.Univ.pack v), ())
  let run_state m = let (_, _, a) = m (0, FHeap.empty_heap) in a
end
```

The only change from `Ref_monad` is that the reference carries a
packer alongside its index, and the heap stores `Univ.t`. `mk_ref`
mints a fresh packer; `!` and `:=` use it to move the value in and
out of the universal type. Because each cell's packer is its own,
the `unpack` always matches the `pack` that stored the value.

:::

## Part 2: GADTs

These problems extend the length-indexed `vec`. Recall that
`('a, 'n) vec` is a list of `'a`s whose length `'n` is a church
numeral, and that `plus` / `mult` / `min` are proofs about those
numerals.

### Problem 3: `cross_v_l`

Pairing a single value with every element of a vector does not
change its length.

:::quiz code id=M08-L08-q3
Implement `cross_v_l : 'a -> ('b, n) vec -> ('a * 'b, n) vec`, which
pairs `v` with each element.

```ocaml
let cross_v_l : type n. 'a -> ('b, n) vec -> ('a * 'b, n) vec =
  fun _ _ -> failwith "not implemented"
```

```ocaml skip
let () =
  let r = cross_v_l 1 (Cons ("a", Cons ("b", Nil))) in
  if r <> Cons ((1, "a"), Cons ((1, "b"), Nil)) then failwith "wrong";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rec cross_v_l : type n. 'a -> ('b, n) vec -> ('a * 'b, n) vec =
  fun v l -> match l with
  | Nil -> Nil
  | Cons (x, xs) -> Cons ((v, x), cross_v_l v xs)
```

Each `Cons` becomes a `Cons`, so the length index `n` is preserved.

:::

### Problem 4: `append`

Appending two vectors gives one whose length is the *sum*. Since
OCaml's types cannot add, `append` takes a `plus` proof that
`m + n = o` and returns an `('a, o) vec`.

:::quiz code id=M08-L08-q4
Implement `append`. The proof and the first vector shrink in
lock-step.

```ocaml
let append : type m n o.
  (m, n, o) plus -> ('a, m) vec -> ('a, n) vec -> ('a, o) vec =
  fun _ _ _ -> failwith "not implemented"
```

```ocaml skip
let () =
  let p : (z s s, z s s s, z s s s s s) plus = PlusSucc (PlusSucc PlusZero) in
  let r = append p (Cons (1, Cons (2, Nil)))
                   (Cons (3, Cons (4, Cons (5, Nil)))) in
  if r <> Cons (1, Cons (2, Cons (3, Cons (4, Cons (5, Nil))))) then
    failwith "wrong";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rec append : type m n o.
  (m, n, o) plus -> ('a, m) vec -> ('a, n) vec -> ('a, o) vec =
  fun p l1 l2 -> match p, l1 with
  | PlusZero, Nil             -> l2
  | PlusSucc p', Cons (x, xs) -> Cons (x, append p' xs l2)
```

`PlusZero` says `l1` is empty, so the answer is `l2`. `PlusSucc p'`
strips one `Cons` from `l1` and one `PlusSucc` from the proof,
keeping the length arithmetic aligned. The `(PlusZero, Cons ...)`
and `(PlusSucc _, Nil)` cases are impossible and the compiler knows
it, so two cases are exhaustive.

:::

### Problem 5: `cross`

The cross product of a length-`m` vector with a length-`n` vector
has length `m * n`. It uses `cross_v_l` and `append`, and takes a
`mult` proof.

:::quiz code id=M08-L08-q5
Implement `cross`. (Hint: for `Cons (x, xs)`, pair `x` with all of
`l2` via `cross_v_l`, then `append` that to the recursive
`cross`. The `mult` proof carries a `plus` proof for that append.)

```ocaml
let cross : type m n o.
  (m, n, o) mult -> ('a, m) vec -> ('b, n) vec -> ('a * 'b, o) vec =
  fun _ _ _ -> failwith "not implemented"
```

```ocaml skip
let () =
  let p : (z s, z s s, z s s) mult = MultSucc (PlusSucc (PlusSucc PlusZero), MultZero) in
  let r = cross p (Cons ("a", Nil)) (Cons (1, Cons (2, Nil))) in
  if r <> Cons (("a", 1), Cons (("a", 2), Nil)) then failwith "wrong";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rec cross : type m n o.
  (m, n, o) mult -> ('a, m) vec -> ('b, n) vec -> ('a * 'b, o) vec =
  fun p l1 l2 -> match p, l1 with
  | MultZero, Nil -> Nil
  | MultSucc (pl, pm), Cons (x, xs) ->
      append pl (cross_v_l x l2) (cross pm xs l2)
```

`MultZero` (`0 * n = 0`) gives the empty result. `MultSucc (pl, pm)`
unpacks the proof that `(m+1) * n = o` into `pm : m * n = p` and
`pl : n + p = o`; the body builds `cross_v_l x l2` (length `n`) and
`cross pm xs l2` (length `p`), then `append pl` joins them into a
vector of length `o`.

:::

### Problem 6: `zip`

`zip` pairs two vectors element by element. Sharing one length index
`n` makes zipping vectors of *different* lengths a compile error, no
runtime `Invalid_argument`.

:::quiz code id=M08-L08-q6
Implement `zip : ('a, n) vec -> ('b, n) vec -> ('a * 'b, n) vec`.

```ocaml
let zip : type n. ('a, n) vec -> ('b, n) vec -> ('a * 'b, n) vec =
  fun _ _ -> failwith "not implemented"
```

```ocaml skip
let () =
  let r = zip (Cons (1, Cons (2, Nil))) (Cons ("a", Cons ("b", Nil))) in
  if r <> Cons ((1, "a"), Cons ((2, "b"), Nil)) then failwith "wrong";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rec zip : type n. ('a, n) vec -> ('b, n) vec -> ('a * 'b, n) vec =
  fun a b -> match a, b with
  | Nil, Nil -> Nil
  | Cons (x, xs), Cons (y, ys) -> Cons ((x, y), zip xs ys)
```

The shared `n` forces both vectors to the same length, so a `Nil`
paired with a `Cons` cannot occur; the two cases are exhaustive.

:::

### Problem 7: `zip_matching`

To zip vectors of *unequal* length, stopping at the shorter one, the
result length is `min m n`. `zip_matching` takes a `min` proof.

:::quiz code id=M08-L08-q7
Implement `zip_matching`, matching the three cases of the `min`
proof.

```ocaml
let zip_matching : type m n o.
  (m, n, o) min -> ('a, m) vec -> ('b, n) vec -> ('a * 'b, o) vec =
  fun _ _ _ -> failwith "not implemented"
```

```ocaml skip
let () =
  let p : (z s s s, z s s s s s, z s s s) min =
    MinSucc (MinSucc (MinSucc MinZero1)) in
  let r = zip_matching p
            (Cons (1, Cons (2, Cons (3, Nil))))
            (Cons (10, Cons (20, Cons (30, Cons (40, Cons (50, Nil)))))) in
  if r <> Cons ((1, 10), Cons ((2, 20), Cons ((3, 30), Nil))) then
    failwith "wrong";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rec zip_matching : type m n o.
  (m, n, o) min -> ('a, m) vec -> ('b, n) vec -> ('a * 'b, o) vec =
  fun p l1 l2 -> match p, l1, l2 with
  | MinZero1, Nil, _ -> Nil
  | MinZero2, _, Nil -> Nil
  | MinSucc p', Cons (x, xs), Cons (y, ys) ->
      Cons ((x, y), zip_matching p' xs ys)
```

`MinZero1` (`min 0 n = 0`) and `MinZero2` (`min m 0 = 0`) stop at an
empty vector; `MinSucc` consumes one element from each and recurses.
The proof picks exactly the case that the two vectors' shapes allow,
so the match is exhaustive.

:::

## Where this sits

Problems 1 and 2 are the [CS3100](https://kcsrk.info/cs3100_m21/)
monad assignment: a state monad rich enough to *be* a reference
implementation, first monomorphic, then polymorphic via a universal
type. Problems 3 to 7 are the GADT assignment: every length-changing
operation carries a type-level proof, so the compiler checks the
shapes that ordinary lists check (if at all) only at runtime. This
is the far end of what we do with types in this course; if you
enjoyed it, the dependently typed languages (Agda, Idris, F\*) make
this style the default.

## Reading

- **Real World OCaml**, *GADTs*:
  <https://dev.realworldocaml.org/gadts.html>

## Sources

This lecture's problems adapt the monad and GADT programming
assignments from the author's CS3100 course, used here as a private
structural reference; the surface code, prompts, and explanations
are written for this course. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
