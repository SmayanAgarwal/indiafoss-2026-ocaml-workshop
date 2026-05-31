---
title: "Monad laws, the list monad, and the result monad"
lecture_no: 2
week: 8
duration_target_min: 26
concepts: [monad laws, list monad, non-determinism, result monad, Result.bind, error propagation]
keywords: [OCaml, monad laws, list monad, concat_map, result, Result.bind, let*]
activity_question: "Define a [parse_pair_r : string -> ((int * int), string) result] that returns informative error messages. Use [let*] to chain the parses."
think_about_this: "The option, list, and result monads share one [let*]. What is different about what [let*] *means* in each?"
reading:
  - title: "Cornell CS3110, Monads"
    url: https://cs3110.github.io/textbook/chapters/ds/monads.html
---

# Monad laws, the list monad, and the result monad


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Monad laws, the list monad, and the result monad</h2>
<p class="title-slide-label">Module 8 &middot; Lecture 2</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

[Lecture 1](M08-L01-option-monad.html) built the option monad and
the `let*` notation. We said a monad is "a type plus `return` and
`bind`". That is not quite the whole story: a *lawful* monad's
`return` and `bind` also satisfy three equations, the *monad laws*.
This lecture states them quickly, then spends its time where the
payoff is: showing the same `let*` driving two very different
shapes. The *list monad* (`'a list`) models many values at once;
the *result monad* (`('a, 'e) result`) is option with an
informative failure.

## The monad laws

The three laws are the "good behaviour" contract that lets you
trust and refactor monadic code without reasoning about each `let*`
from scratch:

:::slide

## The three laws

```text
left identity   bind (return x) f  ===  f x
right identity  bind m return      ===  m
associativity   bind (bind m f) g  ===  bind m (fun x -> bind (f x) g)
```

- Left and right identity fence `return` in: it can only wrap, do
  nothing else.
- Associativity says nested `bind`s regroup freely, so a `let*`
  chain reads as a flat sequence and you can refactor a sub-chain
  into a helper without changing the result.
- They hold for every monad in this course (option, list, result,
  state). You check them on paper, once, per monad; OCaml's type
  system cannot enforce equalities.

:::

We will not enforce or test the laws. They are worth recognising
(they are why category theorists like monads), but day-to-day OCaml
rarely turns on them. The one to remember is associativity: it is
why `let* a in let* b in let* c in ...` is unambiguous and why
carving a sub-chain into a helper is always safe.

## A different shape: the list monad

So far our monads have been about one value or none. The list monad
is about *many* values. `'a list` has the right shape: `return x`
is `[x]`, and `bind` runs the continuation on *every* element and
flattens the results:

:::slide

## The list monad: definition

```ocaml
let return x = [x]
let bind xs f = List.concat_map f xs
let ( let* ) = bind

let _ = bind [1; 2; 3] (fun x -> [x; x * 10])  (* = [1; 10; 2; 20; 3; 30] *)
let _ = return 7                                (* = [7] *)
```

- `bind xs f` maps `f` across `xs` and concatenates: that is
  exactly `List.concat_map` (`flat_map` in other languages).
- `return x = [x]`: one value, lifted to a one-element list.

:::

The list monad models *non-determinism*: a computation that may
produce several values, with the next step running on each one.
`let*` becomes "for every value in the previous step's output, do
the next step":

:::slide

## Non-determinism: a Cartesian product

```ocaml
let ( let* ) xs f = List.concat_map f xs

let pairs =
  let* x = [1; 2; 3] in
  let* y = ["a"; "b"] in
  [(x, y)]

let _ = pairs
(* = [(1, "a"); (1, "b"); (2, "a"); (2, "b"); (3, "a"); (3, "b")] *)
```

- Six pairs: every `x` paired with every `y`.
- Each `let*` adds one dimension to the search.

:::

The striking thing: the same `let*` that meant "short-circuit on
failure" for `option` now means "consider every combination" for
lists. The notation did not change; the monad did. Search problems
fall out of this directly, using the empty list as a filter:

:::slide

## Filtering with the empty list

```ocaml
let ( let* ) xs f = List.concat_map f xs

let ordered_pairs =
  let* x = [1; 2; 3] in
  let* y = [1; 2; 3; 4] in
  if x < y then [(x, y)] else []

let _ = ordered_pairs
(* = [(1, 2); (1, 3); (1, 4); (2, 3); (2, 4); (3, 4)] *)
```

- `[]` at a step drops that branch (`concat_map` of `[]` adds
  nothing); a singleton keeps it.
- "Filter via empty list" is how you write guards in the list
  monad.

:::

## The result monad: failure with information

[`option`](M04-L04-recursive-types.html#the-option-type) says
"maybe a value". [`result`](M04-L04-recursive-types.html#the-result-type)
says "either a value, or an error with a payload". Both carry a
value on success; only `result` carries information on failure. The
plumbing is identical to the option monad; only the failure type
changes.

:::slide

## `Result.bind` and `let*`

```ocaml
let ( let* ) = Result.bind

let parse_int_msg s =
  match int_of_string_opt s with
  | Some n -> Ok n
  | None -> Error ("not an int: " ^ s)

let double_r x = Ok (x * 2)
let small_r x = if x < 100 then Ok x else Error "too big"

let demo s =
  let* x = parse_int_msg s in
  let* y = double_r x in
  small_r y

let _ = demo "5"      (* = Ok 10 *)
let _ = demo "frog"   (* = Error "not an int: frog" *)
let _ = demo "200"    (* = Error "too big" *)
```

- `type ('a, 'e) result = Ok of 'a | Error of 'e`; the error type
  `'e` is yours to choose.
- Same shape as the option monad; failure now names *why*.

:::

The structure is identical to the option-monad demo from lecture 1.
`let*` still means "unwrap the success, or short-circuit"; the only
visible change is that the failure case has a payload. When several
distinct things can go wrong, a [variant](M04-L03-variants.html) in
the error slot beats a `string`, because callers can
[pattern-match](M05-L01-basic-patterns.html) on it:

:::slide

## A typed-error variant

```ocaml
type parse_error =
  | Not_an_int of string
  | Empty_input
  | Too_large of int

let parse_int_v s =
  if s = "" then Error Empty_input
  else
    match int_of_string_opt s with
    | None -> Error (Not_an_int s)
    | Some n when n > 1000 -> Error (Too_large n)
    | Some n -> Ok n

let _ = parse_int_v "42"     (* = Ok 42 *)
let _ = parse_int_v "frog"   (* = Error (Not_an_int "frog") *)
let _ = parse_int_v ""       (* = Error Empty_input *)
let _ = parse_int_v "9999"   (* = Error (Too_large 9999) *)
```

- The type lists every failure mode; callers match and respond.

:::

Like the option monad, `result` short-circuits on the *first*
`Error`: subsequent steps do not run, and the origin of failure is
what you get back. That is usually what you want from sequential
code. (If instead you want to collect *all* errors, as when
validating a form, that is the *applicative* or *validation*
pattern, a sibling shape we do not pursue here.) The rule of thumb:
use `option` when "no value" is the whole story, and `result` when
the failure deserves a reason, typically at module boundaries and
user-facing APIs.

## A quick check

:::quiz mcq id=M08-L02-q2
Given `let pipeline () = let* _ = (Error "first") in let* _ =
(Error "second") in Ok 42` (with `let*` bound to `Result.bind`),
what does `pipeline ()` evaluate to?

- [ ] `Ok 42`.
- [x] `Error "first"`.
- [ ] `Error "second"`.
- [ ] `Error "first; second"`.

**Why:** `Result.bind` short-circuits on the first `Error`. The
second and third lines never run; the `Error "first"` is returned
unchanged. Collecting all errors requires the validation pattern,
not the monad.
:::

:::quiz mcq id=M08-L02-q3
Which law guarantees that you can refactor part of a `let*` chain
into a helper function without changing the result?

- [ ] Left identity.
- [ ] Right identity.
- [x] Associativity.
- [ ] None of them; refactoring monadic code is risky.

**Why:** associativity says nested `bind`s can be reassociated.
Extracting a sub-chain into a helper is exactly reassociating those
`bind`s. Left and right identity govern `return`, not the shape of
long chains.
:::

:::slide

## Activity

Define `parse_pair_r : string -> ((int * int), string) result` that
reads `"(3, 4)"` into the pair `(3, 4)` and returns informative
error messages otherwise. Use `let*` to chain the two integer
parses.

:::

:::solution

:::slide

## Activity solution

```ocaml
let ( let* ) = Result.bind

let int_or_err prefix s =
  match int_of_string_opt s with
  | Some n -> Ok n
  | None -> Error (prefix ^ ": not an int: " ^ s)

let parse_pair_r s =
  let s = String.trim s in
  let n = String.length s in
  if n < 5 || s.[0] <> '(' || s.[n-1] <> ')' then
    Error "expected '(... , ...)'"
  else
    let inner = String.sub s 1 (n-2) in
    match String.split_on_char ',' inner with
    | [a; b] ->
        let* x = int_or_err "first" (String.trim a) in
        let* y = int_or_err "second" (String.trim b) in
        Ok (x, y)
    | _ -> Error "expected exactly one comma"

let _ = parse_pair_r "(3, 4)"      (* = Ok (3, 4) *)
let _ = parse_pair_r "(3, frog)"   (* = Error "second: not an int: frog" *)
let _ = parse_pair_r "frog"        (* = Error "expected '(... , ...)'" *)
```

- The outer `if`/`match` handles shape errors with ordinary control
  flow; the two `let*`s short-circuit on the first bad integer.

:::

:::

A code quiz on the list monad:

:::quiz code id=M08-L02-q1
Use the list monad to write `divisors_of_each : int list -> int
list` that returns every pair of integers whose product is in the
input list, reported as `a * b` to confirm. (For input `[6]`, valid
pairs include `(1, 6)`, `(2, 3)`, `(3, 2)`, `(6, 1)`.)

```ocaml
let ( let* ) xs f = List.concat_map f xs

let divisors_of_each xs =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  let r = divisors_of_each [6] in
  check (List.length r >= 4) "at least four factor pairs of 6";
  check (List.for_all (fun n -> n = 6) r) "every entry should equal 6";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let ( let* ) xs f = List.concat_map f xs

let divisors_of_each xs =
  let* n = xs in
  let* a = List.init n (fun i -> i + 1) in
  let* b = List.init n (fun i -> i + 1) in
  if a * b = n then [a * b] else []
```

Three `let*`s, one per dimension of the search: pick an `n` from
the input, pick `a` and `b` from `1..n`, keep only the pairs whose
product equals `n`. The list monad makes the nested search read
like ordinary sequential code.

:::

## What is next

:::slide

## What is next

Lecture 3: the **state monad** and parameterised state.

- Thread hidden state through a chain *without* mutation.
- A third monad shape, the same `let*` notation.
- Parameterised state: when the state's *type* changes per step.

:::

We have now seen three monads with one notation: `option` and
`result` for failure, `list` for non-determinism. The
[next lecture](M08-L03-state-monad.html) adds a fourth flavour, the
state monad, which threads ambient state through a chain of pure
computations, and then lets the state's type itself change from
step to step, a first bridge toward GADTs.

## Reading

- **Cornell CS3110**, *Monads*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>

## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. The list-monad framing and the monad-laws layout draw
on the CS3100 monads notebook
(`_references/cs3100_m20/lectures/lec15_monads/`), used here as a
private structural reference; the surface code, comments, and
explanations are written from scratch. Cornell CS3110 and Real
World OCaml are CC BY-NC-ND-licensed and have not been derivatively
reused. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
