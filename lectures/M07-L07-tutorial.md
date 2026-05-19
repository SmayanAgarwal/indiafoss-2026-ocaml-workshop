---
title: "Tutorial: a queue functor"
lecture_no: 7
week: 7
duration_target_min: 28
concepts: [worked module, abstract type, functor, two-stack queue]
keywords: [OCaml, queue, two-stack, functor, tutorial, module]
activity_question: "Add an [is_empty : 'a t -> bool] function to the queue. Update the signature. What does the compiler require?"
think_about_this: "We built a queue using two stacks (lists). [enqueue] is O(1), [dequeue] is amortized O(1). Why does the two-list trick give amortized O(1) rather than worst-case O(1)?"
reading:
  - title: "Cornell CS3110, A functional queue"
    url: https://cs3110.github.io/textbook/chapters/modules/functors.html
---

# Tutorial for Module 7

We build a small functional queue using the two-stack trick: keep
two lists, one for the front (in normal order) and one for the
back (in reverse). `enqueue` pushes onto the back; `dequeue` peels
off the front, refilling the front from the (reversed) back when
the front runs out.

We package it as a module with a signature that hides the
implementation, then turn it into a functor parameterized by the
element type.

:::slide

## The implementation

```ocaml
type 'a queue = { front : 'a list; back : 'a list }

let empty = { front = []; back = [] }

let is_empty q = q.front = [] && q.back = []

let enqueue x q = { q with back = x :: q.back }

let rec dequeue q =
  match q.front, q.back with
  | [], [] -> None
  | x :: rest, _ -> Some (x, { q with front = rest })
  | [], back -> dequeue { front = List.rev back; back = [] }

let q = enqueue 3 (enqueue 2 (enqueue 1 empty))
let _ = dequeue q
```

`Some (1, ...)`.

- The first call to `dequeue` triggers the recursive case (front
  is empty).
- Reverses `back` into `front`, and recurses.
- The next dequeue is O(1).

:::

:::slide

## The signature

- Callers should see only `'a t`, `empty`, `enqueue`, `dequeue`,
  `is_empty`.
- The representation should be **hidden**:

```ocaml
module type QUEUE = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val enqueue : 'a -> 'a t -> 'a t
  val dequeue : 'a t -> ('a * 'a t) option
end

module Queue : QUEUE = struct
  type 'a t = { front : 'a list; back : 'a list }

  let empty = { front = []; back = [] }

  let is_empty q = q.front = [] && q.back = []

  let enqueue x q = { q with back = x :: q.back }

  let rec dequeue q =
    match q.front, q.back with
    | [], [] -> None
    | x :: rest, _ -> Some (x, { q with front = rest })
    | [], back -> dequeue { front = List.rev back; back = [] }
end

let q = Queue.enqueue 3 (Queue.enqueue 2 (Queue.enqueue 1 Queue.empty))
let _ = Queue.dequeue q
let _ = Queue.is_empty Queue.empty
```

`Some (1, ...)`, `true`.

- From outside, `Queue.t` is **abstract**.
- We can construct, enqueue, dequeue, check empty: that's it.
- The two-list representation is **hidden**.

:::

:::slide

## Why hide the representation?

Two reasons we've seen before:

- **Invariants.** Our queue assumes `front` is the "front in
  normal order". If callers could touch the record directly, they
  could violate that. Hiding the representation enforces it.
- **Change.** If we later switch to a different implementation (a
  Dynarray, a linked structure), no caller breaks.

:::

:::slide

## Turning it into a functor

- Suppose we want a queue parameterized by element type, with a
  typed-printer for elements.
- The element type isn't free anymore.
- We need a `pp` function on it.

```ocaml
module type ELT = sig
  type t
  val to_string : t -> string
end

module Make (E : ELT) = struct
  type elt = E.t
  type t = { front : elt list; back : elt list }

  let empty = { front = []; back = [] }
  let is_empty q = q.front = [] && q.back = []
  let enqueue x q = { q with back = x :: q.back }
  let rec dequeue q =
    match q.front, q.back with
    | [], [] -> None
    | x :: rest, _ -> Some (x, { q with front = rest })
    | [], back -> dequeue { front = List.rev back; back = [] }

  let print q =
    let f = String.concat ", " (List.map E.to_string q.front) in
    let b = String.concat ", " (List.map E.to_string (List.rev q.back)) in
    print_endline ("[" ^ f ^ " | " ^ b ^ "]")
end

module IQ = Make (struct type t = int let to_string = string_of_int end)

let q = IQ.enqueue 3 (IQ.enqueue 2 (IQ.enqueue 1 IQ.empty))
let () = IQ.print q
```

Prints `[ | 3, 2, 1]` (front is empty; back is `[3; 2; 1]`,
reversed for display gives `1, 2, 3`).

- The functor expects an element type with a `to_string`.
- We pass an inline module providing `int` and `string_of_int`.
- We get out a fully working int-queue with print capability.

:::

:::slide

## What's notable about the functor

- **Specialised**: `IQ.elt` is `int`, period. Trying to enqueue a
  `string` is a type error.
- **Generic**: the *queue logic* is the same regardless of element
  type. We wrote it once.
- **Composable**: a `String_queue` is one line:

```ocaml
module Q = struct end  (* dummy *)
```

(actually `module String_queue = Make(struct type t = string let to_string s = s end)`)

- This is how `Map.Make`, `Set.Make`, `Hashtbl.Make` work in the
  standard library.
- **One implementation, many specialisations.**

:::

:::slide

## Activity

Add `length : 'a t -> int` to the queue. Update the signature.
What does the compiler require?

:::

:::slide

## Activity solution

```ocaml
module type QUEUE = sig
  type 'a t
  val empty : 'a t
  val is_empty : 'a t -> bool
  val length : 'a t -> int
  val enqueue : 'a -> 'a t -> 'a t
  val dequeue : 'a t -> ('a * 'a t) option
end

module Queue : QUEUE = struct
  type 'a t = { front : 'a list; back : 'a list }
  let empty = { front = []; back = [] }
  let is_empty q = q.front = [] && q.back = []
  let length q = List.length q.front + List.length q.back
  let enqueue x q = { q with back = x :: q.back }
  let rec dequeue q =
    match q.front, q.back with
    | [], [] -> None
    | x :: rest, _ -> Some (x, { q with front = rest })
    | [], back -> dequeue { front = List.rev back; back = [] }
end

let q = Queue.enqueue 3 (Queue.enqueue 2 (Queue.enqueue 1 Queue.empty))
let _ = Queue.length q
```

`int = 3`.

- The signature now lists `length`; the implementation provides
  it.
- **Forget to add `length` to the module** and OCaml errors:
  `Signature mismatch: missing value 'length'`.
- **Add `length` to the signature without implementing it** and
  you get the same error.
- The compiler enforces both sides.

:::

:::slide

## What you should be able to do now

After Module 7 you can:

- Use `ref`s and mutable record fields when imperative state is
  the right tool.
- Use arrays for O(1) indexed access.
- Raise and catch exceptions; choose between exceptions and
  `option`/`result`.
- Group definitions into modules; access them via `Module.value`.
- Constrain a module by a signature to hide internals.
- Use functors from the standard library (`Map.Make`, `Set.Make`).
- Write your own simple functor.

Module 8 covers **monads and GADTs**:

- Two abstractions for sequencing computations cleanly.
- And for encoding richer type-level information.

:::

## Reading

- **Cornell CS3110**, *A functional queue*:
  <https://cs3110.github.io/textbook/chapters/modules/functors.html>
