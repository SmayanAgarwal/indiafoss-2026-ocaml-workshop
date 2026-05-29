---
title: "Practice: mutability, modules, and streams"
lecture_no: 10
week: 7
duration_target_min: 0
concepts: [practice problems, references, mutable records, arrays, modules, functors, streams]
keywords: [OCaml, practice, assignment, ref, mutable, array, module, functor, stream]
think_about_this: "These problems mix the three threads of Module 7: in-place mutation, packaging code behind signatures and functors, and infinite data built lazily. The module/functor problems are the hard ones; budget most of your time there."
reading:
  - title: "OCaml manual, The module system"
    url: https://v2.ocaml.org/manual/moduleexamples.html
---

# Practice: mutability, modules, and streams

This is a *Practice* chapter, not a Tutorial. There are no slides
and there is no video; it is a worksheet. The Tutorial
([M07-L09](M07-L09-tutorial.html)) walked through a queue functor
on screen. Here you solve the problems yourself, directly in the
browser. Each problem has an editable cell seeded with
`failwith "not implemented"` (or a stub module) and a test cell
that prints `all tests passed` when your solution is correct. A
reference solution sits below each problem behind a collapsed
*Reference solution* panel: try the problem first, then reveal the
solution to compare.

The worksheet has three parts, one per thread of the module:

- **Part 1: mutability** (Problems 1 to 3). References, mutable
  record fields, and in-place array update, from
  [M07-L01](M07-L01-references.html) and
  [M07-L02](M07-L02-arrays-and-mutation.html).
- **Part 2: modules and functors** (Problems 4 to 6). Packaging
  code behind a [signature](M07-L07-signatures.html), and writing
  [functors](M07-L08-functors.html) that build modules from
  modules. Problem 5 ties Parts 1 and 2 together: a functor that
  produces a *mutable* node type.
- **Part 3: streams** (Problems 7 to 8). Infinite data built from
  thunks, from [M07-L04](M07-L04-streams-and-laziness.html).

Difficulty rises roughly as you go. The functor problems in Part 2
are the meatiest; if you get stuck, skip ahead to the streams and
come back.

## Part 1: mutability

## Problem 1: `sum_ref`

Write a function

```text
sum_ref : int list -> int
```

that sums a list using a single mutable accumulator and
[`List.iter`](https://v2.ocaml.org/api/List.html#VALiter), *not*
recursion and *not* `List.fold_left`. The point is to practise the
ref idiom: allocate a cell, mutate it in a loop, read it out at the
end.

:::quiz code id=M07-L10-q1
Implement `sum_ref` with a `ref` and `List.iter`.

```ocaml
let sum_ref xs =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (sum_ref [1; 2; 3; 4] = 10) "small";
  check (sum_ref [] = 0) "empty";
  check (sum_ref [5] = 5) "singleton";
  check (sum_ref [-1; 1; -1; 1] = 0) "cancels";
  check (sum_ref (List.init 100 (fun i -> i + 1)) = 5050) "1..100";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let sum_ref xs =
  let acc = ref 0 in
  List.iter (fun x -> acc := !acc + x) xs;
  !acc
```

Allocate `acc` once, mutate it with `:=` for each element, and
dereference with `!` at the end. This is the imperative shape of a
fold: the accumulator lives in a cell rather than being threaded
through recursive calls.

:::

## Problem 2: `rotate_left`

Write a function

```text
rotate_left : 'a array -> unit
```

that rotates an array one position to the left, *in place*: the
element at index 0 moves to the end, everything else shifts down
one. For example, `[|1; 2; 3; 4|]` becomes `[|2; 3; 4; 1|]`. Arrays
of length 0 or 1 are unchanged. The function returns `unit`; its
effect is the mutation.

:::quiz code id=M07-L10-q2
Implement `rotate_left`.

```ocaml
let rotate_left a =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  let a = [|1; 2; 3; 4|] in
  rotate_left a;
  check (a = [|2; 3; 4; 1|]) "four elements";
  let b = [|7|] in
  rotate_left b;
  check (b = [|7|]) "singleton unchanged";
  let c = [||] in
  rotate_left c;
  check (c = [||]) "empty unchanged";
  let d = [|1; 2|] in
  rotate_left d;
  check (d = [|2; 1|]) "pair";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rotate_left a =
  let n = Array.length a in
  if n > 1 then begin
    let first = a.(0) in
    for i = 0 to n - 2 do
      a.(i) <- a.(i + 1)
    done;
    a.(n - 1) <- first
  end
```

Save the first element, shift every later element down one with a
`for` loop and `a.(i) <- ...`, then drop the saved element into the
last slot. The `n > 1` guard skips the work for empty and
singleton arrays (where rotation is a no-op). This is the kind of
index-juggling in-place mutation that arrays are *for*.

:::

## Problem 3: a mutable bank account

Using the record type

```text
type account = { mutable balance : int }
```

write two functions:

```text
deposit  : account -> int -> unit
withdraw : account -> int -> bool
```

`deposit acc n` adds `n` to the balance. `withdraw acc n` subtracts
`n` *only if* the account has at least `n`; it returns `true` if the
withdrawal happened and `false` (leaving the balance untouched) if
there were insufficient funds.

:::quiz code id=M07-L10-q3
Implement `deposit` and `withdraw`.

```ocaml
type account = { mutable balance : int }

let deposit acc n =
  failwith "not implemented"

let withdraw acc n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  let a = { balance = 0 } in
  deposit a 100;
  check (a.balance = 100) "deposit";
  check (withdraw a 30 = true) "withdraw ok returns true";
  check (a.balance = 70) "balance after withdraw";
  check (withdraw a 1000 = false) "overdraw returns false";
  check (a.balance = 70) "balance unchanged on overdraw";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let deposit acc n = acc.balance <- acc.balance + n

let withdraw acc n =
  if n <= acc.balance then begin
    acc.balance <- acc.balance - n;
    true
  end else
    false
```

`deposit` is a one-line field update with `<-`. `withdraw` guards
the update on sufficient funds: when the guard holds it mutates and
returns `true`; otherwise it leaves the field alone and returns
`false`. Returning a `bool` lets the caller tell whether the
withdrawal succeeded, which a `unit`-returning version could not.

:::

## Part 2: modules and functors

These three problems are the heart of the worksheet. They are drawn
from the *CS3100* mutability-and-modules assignment: a `Showable`
signature, a functor that builds a mutable doubly-linked-list node
from any `Showable`, and a purely functional heap behind a
signature.

## Problem 4: `Showable` modules

Given the signature

```text
module type Showable = sig
  type t
  val string_of_t : t -> string
end
```

implement two modules, `IntShowable` and `FloatShowable`, that
satisfy it. Use the standard library's `string_of_int` and
`string_of_float` for the `string_of_t` functions.

:::quiz code id=M07-L10-q4
Implement `IntShowable` and `FloatShowable`.

```ocaml
module type Showable = sig
  type t
  val string_of_t : t -> string
end

(* Implement IntShowable and FloatShowable below. *)
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (IntShowable.string_of_t 10 = "10") "int 10";
  check (IntShowable.string_of_t (-3) = "-3") "int -3";
  check (FloatShowable.string_of_t 0.0 = "0.") "float 0.0";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
module IntShowable : Showable with type t = int = struct
  type t = int
  let string_of_t = string_of_int
end

module FloatShowable : Showable with type t = float = struct
  type t = float
  let string_of_t = string_of_float
end
```

Each module fixes `t` to a concrete type and supplies the printer.
The `with type t = int` in the ascription is the key detail: a bare
`: Showable` would make `t` *abstract*, so the test
`IntShowable.string_of_t 10` would not type-check (10 is an `int`,
not the opaque `IntShowable.t`). The `with type` constraint exposes
the equation `t = int` to the outside while still checking the
module against the signature.

:::

## Problem 5: a doubly-linked-list node functor

This problem combines Part 1 (mutable fields) with Part 2 (functors).
A doubly-linked-list *node* holds a value and mutable links to its
neighbours. Implement the functor

```text
module MakeNode : functor (C : Showable) -> NODE with type content = C.t
```

for the signature

```text
module type NODE = sig
  type t
  type content
  val create        : content -> t
  val get_content   : t -> content
  val get_next      : t -> t option
  val get_prev      : t -> t option
  val set_next      : t -> t option -> unit
  val set_prev      : t -> t option -> unit
end
```

`create c` makes a fresh node holding `c` with no neighbours. The
`get_*` accessors read the fields; the `set_*` operations mutate the
`next` / `prev` links in place. The neighbours are `t option` so a
node at either end can record "no neighbour."

:::quiz code id=M07-L10-q5
Implement the functor `MakeNode`.

```ocaml
module type Showable = sig
  type t
  val string_of_t : t -> string
end

module IntShowable : Showable with type t = int = struct
  type t = int
  let string_of_t = string_of_int
end

module type NODE = sig
  type t
  type content
  val create      : content -> t
  val get_content : t -> content
  val get_next    : t -> t option
  val get_prev    : t -> t option
  val set_next    : t -> t option -> unit
  val set_prev    : t -> t option -> unit
end

module MakeNode (C : Showable) : NODE with type content = C.t = struct
  (* Implement the node here. *)
  type content = C.t
  type t = unit  (* replace this *)
  let create _ = failwith "not implemented"
  let get_content _ = failwith "not implemented"
  let get_next _ = failwith "not implemented"
  let get_prev _ = failwith "not implemented"
  let set_next _ _ = failwith "not implemented"
  let set_prev _ _ = failwith "not implemented"
end
```

```ocaml skip
let check b m = if not b then failwith m
module IntNode = MakeNode (IntShowable)
let () =
  let open IntNode in
  let a = create 1 and b = create 2 and c = create 3 in
  check (get_content a = 1) "content";
  check (get_next a = None) "fresh node has no next";
  set_next a (Some b); set_prev b (Some a);
  set_next b (Some c); set_prev c (Some b);
  check (match get_next a with Some n -> get_content n = 2 | None -> false)
        "a -> b";
  check (match get_prev c with Some n -> get_content n = 2 | None -> false)
        "c <- b";
  set_next a (Some c);
  check (match get_next a with Some n -> get_content n = 3 | None -> false)
        "relink a -> c";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
module MakeNode (C : Showable) : NODE with type content = C.t = struct
  type content = C.t
  type t = {
    value : content;
    mutable next : t option;
    mutable prev : t option;
  }
  let create v = { value = v; next = None; prev = None }
  let get_content n = n.value
  let get_next n = n.next
  let get_prev n = n.prev
  let set_next n m = n.next <- m
  let set_prev n m = n.prev <- m
end
```

The node is a record with one immutable field (`value`) and two
`mutable` fields (`next`, `prev`), exactly the doubly-linked-list
node from [M07-L02](M07-L02-arrays-and-mutation.html), now packaged
inside a functor. The functor is parameterised by `C : Showable`,
so `content` is `C.t`; the `with type content = C.t` ascription
exposes that equation so the test can call `create 1` with a plain
`int`. The `set_*` operations are field assignments (`<-`) returning
`unit`. Note the type `t` is recursive: a node's neighbours are
themselves nodes.

:::

## Problem 6: a functional heap

Not every "store" needs mutation. A *functional heap* is an
immutable key-value map that returns a *new* map on every update,
representing the store as a plain value. Implement the module
`FHeap` satisfying

```text
module type FHEAP = sig
  type ('k, 'v) t
  val empty : ('k, 'v) t
  val set   : ('k, 'v) t -> 'k -> 'v -> ('k, 'v) t
  val get   : ('k, 'v) t -> 'k -> 'v option
end
```

`empty` is the heap with no bindings. `set h k v` returns a heap
that maps `k` to `v` and agrees with `h` everywhere else. `get h k`
returns `Some v` if `k` is bound, `None` otherwise. A later `set`
on a key shadows an earlier one.

:::quiz code id=M07-L10-q6
Implement `FHeap`. (An association list is the simplest backing
store; you may use `List.assoc_opt`.)

```ocaml
module type FHEAP = sig
  type ('k, 'v) t
  val empty : ('k, 'v) t
  val set   : ('k, 'v) t -> 'k -> 'v -> ('k, 'v) t
  val get   : ('k, 'v) t -> 'k -> 'v option
end

module FHeap : FHEAP = struct
  (* Replace these stub bodies with a real implementation. *)
  type ('k, 'v) t = ('k * 'v) list
  let empty = []
  let set _h _k _v = []
  let get _h _k = None
end
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  let open FHeap in
  check (get empty 0 = None) "empty has nothing";
  let h = set (set empty 0 "a") 1 "b" in
  check (get h 0 = Some "a") "key 0";
  check (get h 1 = Some "b") "key 1";
  check (get h 9 = None) "missing key";
  let h2 = set h 1 "c" in
  check (get h2 1 = Some "c") "shadowed key";
  check (get h 1 = Some "b") "original heap unchanged";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
module FHeap : FHEAP = struct
  type ('k, 'v) t = ('k * 'v) list
  let empty = []
  let set h k v = (k, v) :: h
  let get h k = List.assoc_opt k h
end
```

The heap is an association list. `set` conses a new pair onto the
front (it does *not* remove the old binding); `get` uses
`List.assoc_opt`, which returns the *first* match, so the most
recent `set` wins. Because `set` builds a new list and never
mutates, the old heap keeps its bindings: the test's
"original heap unchanged" check passes. The representation type
`('k, 'v) t` is abstract behind the signature, so callers cannot
depend on it being a list. (CS3100's version uses a function
`'k -> 'v option` as the store instead; either works.)

:::

## Part 3: streams

These problems use the thunk-based stream type from
[M07-L04](M07-L04-streams-and-laziness.html). Each problem's cell
seeds the type and the `hd` / `tl` / `take` / `from` helpers; you
write the new function.

## Problem 7: `interleave`

Write a function

```text
interleave : 'a stream -> 'a stream -> 'a stream
```

that alternates between two streams: the first element of `s1`,
then the first of `s2`, then the second of `s1`, and so on. For
example, interleaving `0, 1, 2, ...` with `100, 101, 102, ...`
gives `0, 100, 1, 101, 2, 102, ...`.

:::quiz code id=M07-L10-q7
Implement `interleave`.

```ocaml
type 'a stream = Cons of 'a * (unit -> 'a stream)
let hd (Cons (x, _)) = x
let tl (Cons (_, t)) = t ()
let rec take n s = if n = 0 then [] else hd s :: take (n - 1) (tl s)
let rec from n = Cons (n, fun () -> from (n + 1))

let rec interleave s1 s2 =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (take 6 (interleave (from 0) (from 100))
         = [0; 100; 1; 101; 2; 102]) "two counters";
  check (take 4 (interleave (from 0) (from 0)) = [0; 0; 1; 1])
        "same stream twice";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rec interleave s1 s2 =
  Cons (hd s1, fun () -> interleave s2 (tl s1))
```

Emit the head of `s1` now, and defer the rest: the tail thunk
interleaves `s2` with the *tail* of `s1`, with the two streams
*swapped*. Swapping the arguments on each step is what makes the
output alternate. Because the tail is a thunk, only as much of each
stream as `take` demands is ever forced.

:::

## Problem 8: `cycle`

Write a function

```text
cycle : 'a list -> 'a stream
```

that turns a non-empty list into the infinite stream that repeats
it forever. For example, `cycle [1; 2; 3]` is the stream
`1, 2, 3, 1, 2, 3, 1, ...`. On the empty list, raise
`Invalid_argument` (there is nothing to cycle).

:::quiz code id=M07-L10-q8
Implement `cycle`.

```ocaml
type 'a stream = Cons of 'a * (unit -> 'a stream)
let hd (Cons (x, _)) = x
let tl (Cons (_, t)) = t ()
let rec take n s = if n = 0 then [] else hd s :: take (n - 1) (tl s)

let cycle lst =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (take 7 (cycle [1; 2; 3]) = [1; 2; 3; 1; 2; 3; 1])
        "three-cycle";
  check (take 4 (cycle [9]) = [9; 9; 9; 9]) "singleton cycle";
  check ((try let _ = cycle [] in false with Invalid_argument _ -> true))
        "empty raises";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let cycle lst =
  if lst = [] then invalid_arg "cycle: empty list";
  let rec go = function
    | [] -> go lst
    | x :: xs -> Cons (x, fun () -> go xs)
  in
  go lst
```

The inner `go` walks the list, emitting one element per stream
node; when it runs off the end (`[]`) it starts over from the
original `lst`. The restart sits inside the tail thunk, so the
stream is genuinely infinite but uses finite memory: there is one
`go lst` closure, re-entered each time round. The empty-list guard
runs *before* building any stream, so `cycle []` fails immediately
rather than diverging.

:::

## What you should be able to do now

By the end of these eight problems you should be comfortable with:

- The reference idiom: allocate a cell, mutate it in a loop, read
  it out (`sum_ref`), and in-place array update with a `for` loop
  (`rotate_left`).
- Mutable record fields and the `<-` assignment operator, including
  returning a `bool` to report whether a guarded mutation happened
  (the bank account).
- Writing a module to satisfy a signature, and why `with type t =
  ...` matters when a caller needs the concrete type (`Showable`).
- Writing a *functor* that builds a module from a module, including
  one whose result type is a *mutable* record (`MakeNode`): the
  point where this module's two big themes, mutation and modules,
  meet.
- Hiding a representation behind an abstract type in a signature,
  and the difference between a functional store that returns new
  values (`FHeap`) and a mutable one that updates in place.
- Building infinite streams from thunks and consuming a finite
  prefix with `take` (`interleave`, `cycle`).

[Module 8](M08-L01-sequencing.html) goes further with two more
advanced ideas: *monads* (a uniform way to sequence computations
that carry context, including the kind of functional-heap state you
built in Problem 6) and *generalised algebraic data types* (GADTs).

## Sources

Part 2 (Problems 4 to 6) is drawn from the mutability-and-modules
and monads assignments of the instructor's *CS3100: Paradigms of
Programming* course at IIT Madras, with prose, signatures, test
harnesses, and reference solutions rewritten for this NPTEL course.
Part 1 (Problems 1 to 3) and Part 3 (Problems 7 to 8) are new here,
exercising the references, arrays, and streams from the Module 7
lectures.
