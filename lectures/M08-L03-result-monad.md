---
title: "The result monad: errors with information"
lecture_no: 3
week: 8
duration_target_min: 22
concepts: [result type, Result.bind, error propagation, let* for results]
keywords: [OCaml, result, Result.bind, error monad, let*, error handling]
activity_question: "Define a [parse_pair_r : string -> ((int * int), string) result] that returns informative error messages. Use [let*] to chain the parses."
think_about_this: "The [result] monad propagates the *first* error. Sometimes you want to collect *all* errors. What changes about the design of [bind] if you wanted that?"
reading:
  - title: "Cornell CS3110, Result monad"
    url: https://cs3110.github.io/textbook/chapters/ds/monads.html
---

# The result monad

`option` says "maybe a value, maybe not". **`result`** says "either
a value, or an error". The shape is the same; the failure case
carries information. Same monad pattern; richer payload.

:::slide

## Definition

The standard library defines:

```ocaml skip
type ('a, 'e) result =
  | Ok of 'a
  | Error of 'e
```

`Ok x` is success; `Error e` is failure with payload `e`. The
payload type is a *parameter*: you choose what to carry on
failure. Common choices: a `string` message, an error code variant,
a record.

We saw this type back in Module 4. Now we use it as a monad.

:::

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

let _ = demo "5"
let _ = demo "frog"
let _ = demo "200"
```

`Ok 10`, `Error "not an int: frog"`, `Error "too big"`.

Same shape as the option monad. The difference: when something
goes wrong, we get an *informative* `Error` payload rather than
just `None`.

:::

:::slide

## Why pick `result` over `option`?

- **Errors with reasons**. A parser, a validator, a network
  client: callers need to know *why* it failed. `result` carries
  that.
- **Multiple failure modes**. With a variant payload, you can
  distinguish "not an int" from "out of range" from "wrong format".

When the only thing that can go wrong is "no value here", `option`
is enough. When there's diagnostic info worth surfacing, `result`
is the better fit.

:::

:::slide

## Mixing `option` and `result`

It's common to have an `option` and want to lift to a `result`
with a default error:

```ocaml
let to_result err = function
  | Some x -> Ok x
  | None -> Error err

let _ = to_result "missing" (Some 42)
let _ = to_result "missing" None
```

`Ok 42`, `Error "missing"`.

This pattern is so common it's sometimes called `Option.to_result`
or `Result.of_option`. The standard library has
`Option.to_result ~none:err opt` (with labelled argument).

:::

:::slide

## A typed-error variant

For richer information, the error can be a variant:

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

let _ = parse_int_v "42"
let _ = parse_int_v "frog"
let _ = parse_int_v ""
let _ = parse_int_v "9999"
```

`Ok 42`, `Error (Not_an_int "frog")`, `Error Empty_input`,
`Error (Too_large 9999)`.

The variant tells callers exactly which error case fired. They can
pattern-match on it and decide what to do.

:::

:::slide

## Chaining: errors propagate first-wins

The result monad propagates the *first* `Error` it encounters.
Subsequent steps don't run.

```ocaml
let ( let* ) = Result.bind

let step1 () = Error "first"
let step2 () = Error "second"
let step3 () = Ok 42

let pipeline () =
  let* _ = step1 () in
  let* _ = step2 () in
  step3 ()

let _ = pipeline ()
```

`Error "first"`. Once `step1` errored, the pipeline is dead; we
never see "second" or 42.

This is what you usually want: the *origin* of the failure is the
useful information, not how it cascaded.

:::

:::slide

## When you want to collect all errors

Sometimes you want every error, not just the first:

```ocaml
let validate_int s =
  match int_of_string_opt s with
  | Some n -> Ok n
  | None -> Error [s ^ " is not an int"]

let combine a b =
  match a, b with
  | Ok x, Ok y -> Ok (x, y)
  | Error e1, Error e2 -> Error (e1 @ e2)
  | Error e, Ok _ | Ok _, Error e -> Error e

let _ = combine (validate_int "1") (validate_int "2")
let _ = combine (validate_int "frog") (validate_int "2")
let _ = combine (validate_int "frog") (validate_int "bar")
```

`Ok (1, 2)`, `Error ["frog is not an int"]`,
`Error ["frog is not an int"; "bar is not an int"]`.

The error type is a *list* of messages; `combine` accumulates.
This is sometimes called the *Applicative* or *Validation* shape:
it runs both arms regardless and aggregates failures. Not a strict
monad (the second step doesn't depend on the first's result), but
the same flavour of "what to do on failure" abstraction.

:::

:::slide

## When `result` becomes heavy

A function chain six `let*`s long is fine. A whole codebase where
every function returns `('a, my_error_type) result` is a lot to
carry.

Real OCaml code often:

- Uses `result` at module boundaries (the public APIs).
- Uses exceptions or `option` *inside* a module where the failure
  mode is more local.
- Layers a result monad only at the levels where errors are
  user-visible.

The choice isn't "always use result"; it's "use result where
informative errors are worth their weight".

:::

:::slide

## Activity

Define `parse_pair_r : string -> ((int * int), string) result`
that returns informative errors. Use `let*`.

:::

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

let _ = parse_pair_r "(3, 4)"
let _ = parse_pair_r "(3, frog)"
let _ = parse_pair_r "frog"
```

`Ok (3, 4)`, `Error "second: not an int: frog"`,
`Error "expected '(... , ...)'"`.

The two `let*`s short-circuit on the first parse failure with a
specific message.

:::

:::slide

## What's next

Lecture 4: **the state monad**. Thread a hidden mutable-ish state
through a chain of computations *without* mutation. The third
monad shape; the same `let*` notation.

:::

## Reading

- **Cornell CS3110**, *Result monad*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>
