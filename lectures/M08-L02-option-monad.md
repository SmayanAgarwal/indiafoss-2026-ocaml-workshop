---
title: "The option monad and `let*` sugar"
lecture_no: 2
week: 8
duration_target_min: 24
concepts: [option monad, return, bind, let-operators, Option.bind, Option.map]
keywords: [OCaml, option monad, let*, bind, return, Option.bind]
activity_question: "Rewrite this with [let*]:\n\n[match parse_int s with None -> None | Some x -> match double x with None -> None | Some y -> small y]"
think_about_this: "The [let*] operator is just a regular OCaml let-operator binding. You can define it for any monad. What rules does the definition have to satisfy to be a 'lawful' monad?"
reading:
  - title: "Cornell CS3110, Option monad"
    url: https://cs3110.github.io/textbook/chapters/ds/monads.html
---

# The option monad

The option monad is the workhorse for "this may fail without a
specific reason". This lecture defines it, shows the `let*` sugar
that makes it pleasant to use, and walks through a real example.

:::slide

## Definition

```ocaml
module Opt = struct
  let return x = Some x
  let bind opt f =
    match opt with
    | None -> None
    | Some x -> f x
  let ( let* ) = bind
end
```

Two functions:

- `return : 'a -> 'a option` (sometimes called `pure`). Lift a
  value into the option world.
- `bind : 'a option -> ('a -> 'b option) -> 'b option`. Pass an
  option-shaped value through a function that returns another
  option-shaped value.

And one operator alias:

- `let*` is just `bind`.
- The OCaml syntax sugar `let* x = e in rest` desugars to `( let* ) e (fun x -> rest)`.
- Which is `bind e (fun x -> rest)`.

:::

:::slide

## Using `let*`

```ocaml
let ( let* ) opt f =
  match opt with
  | None -> None
  | Some x -> f x

let parse_int s = int_of_string_opt s
let double x = Some (x * 2)
let small x = if x < 100 then Some x else None

let demo s =
  let* x = parse_int s in
  let* y = double x in
  small y

let _ = demo "5"
let _ = demo "frog"
let _ = demo "200"
```

`Some 10`, `None`, `None`.

- Read it top to bottom.
- Each `let* y = expr in` says: compute `expr`; if `None`, the whole thing is `None`.
- Otherwise, bind `y` to the unwrapped value and continue.
- Looks like ordinary `let ... in ...` sequencing.
- The monad operator hides the failure-propagation plumbing.

:::

:::slide

## `Option.bind` and `Option.map`

The standard library ships these:

```ocaml
let _ = Option.bind (Some 5) (fun x -> if x > 0 then Some (x * 2) else None)
let _ = Option.bind None (fun x -> Some (x + 1))
let _ = Option.map (fun x -> x * 2) (Some 5)
```

`Some 10`, `None`, `Some 10`.

- `Option.bind` is exactly the `bind` we defined.
- `Option.map` is weaker: applies a *pure* function inside the option, without giving it the chance to fail.
- Next step might fail (returns option): use `bind`.
- Next step always produces a plain value: use `map`.

:::

:::slide

## A real example: parsing

```ocaml
let ( let* ) = Option.bind

(* parse "(x, y)" into a pair of ints; None if malformed *)
let parse_pair s =
  let s = String.trim s in
  let n = String.length s in
  if n < 5 || s.[0] <> '(' || s.[n - 1] <> ')' then None
  else
    let inner = String.sub s 1 (n - 2) in
    match String.split_on_char ',' inner with
    | [a; b] ->
        let* x = int_of_string_opt (String.trim a) in
        let* y = int_of_string_opt (String.trim b) in
        Some (x, y)
    | _ -> None

let _ = parse_pair "(3, 4)"
let _ = parse_pair "(3, x)"
let _ = parse_pair "frog"
```

`Some (3, 4)`, `None`, `None`.

- The two `int_of_string_opt` calls can each fail.
- We use `let*` to unwrap each one or short-circuit.
- After both succeed, we package into `Some (x, y)`.
- Without `let*`, this would be two nested `match` statements with `None` arms.

:::

:::slide

## Combining `map` and `bind`

```ocaml
let ( let* ) = Option.bind
let ( let+ ) x f = Option.map f x  (* arg order flipped from Option.map *)

let demo s =
  let* x = int_of_string_opt s in
  let+ y = if x > 0 then Some (x * 2) else None in
  y + 1

let _ = demo "5"
```

`Some 11`.

- `let* x = parse_int s in` unwraps `x` from the parse.
- `let+ y = ... in y + 1` does both an unwrap and the final transformation.
- The final `+ 1` doesn't fail; `let+` is for that.
- `let+` is a useful complement to `let*` when the last step is a pure transformation.
- Not in `Option` by default; you alias it where you want it.

:::

:::slide

## When *not* to use a monad

If your function does *one* optional thing and returns immediately,
`match` is fine:

```ocaml
let _ =
  match int_of_string_opt "frog" with
  | Some n -> n * 2
  | None -> 0
```

`int = 0`. Two cases, one `match`, three lines. No monad needed.

- Reach for `let*` when you have **three or more** sequential optional steps.
- Where the failure handling is "give up, return `None`".
- Before three, the `match` is shorter and equally clear.

:::

:::slide

## A note on `let*` per-monad

- `let*` is *not* a fixed operator: it's a regular binding you define.
- Each monad has its own `let*`.
- `let open Opt in` makes `let*` option-flavoured; switching to result, you redefine `let*` for that.
- The compiler doesn't know which monad you're in; you choose by `open`-ing the right module or aliasing.
- Languages with built-in `do`-notation (Haskell) avoid this per-monad redefinition.
- OCaml's mechanism is more explicit: trades elegance for clarity.

:::

:::slide

## Activity

Rewrite this using `let*`:

```ocaml skip
match parse_int s with
| None -> None
| Some x ->
    match double x with
    | None -> None
    | Some y -> small y
```

:::

:::slide

## Activity solution

```ocaml
let ( let* ) = Option.bind

let parse_int s = int_of_string_opt s
let double x = Some (x * 2)
let small x = if x < 100 then Some x else None

let pipeline s =
  let* x = parse_int s in
  let* y = double x in
  small y

let _ = pipeline "5"
let _ = pipeline "frog"
let _ = pipeline "200"
```

`Some 10`, `None`, `None`.

- Three steps, three `let*`s.
- The same logic as the nested `match` version, but flat.

:::

:::slide

## What's next

Lecture 3: **the result monad**.

- Like option, but the failure case carries information (error message, error code).
- Same `let*` pattern; richer information.

:::

## Reading

- **Cornell CS3110**, *Option monad*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>
