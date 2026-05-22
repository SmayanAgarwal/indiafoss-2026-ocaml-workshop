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


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">The result monad: errors with information</h2>
<p class="title-slide-label">Module 8 &middot; Lecture 3</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

[`option`](M04-L05-option-and-aliases.html#the-option-type) says
"maybe a value, maybe not".
[`result`](M04-L05-option-and-aliases.html#the-result-type) says
"either a value, or an error". Both shapes carry a value on success;
only `result` carries information on failure. The monadic plumbing
is identical: same [`bind`](M08-L02-option-monad.html#definition),
same [`let*`](M08-L02-option-monad.html#using-let), same intuition.
What changes is the type of failure.

This lecture defines `result`, shows the standard library's
`Result.bind`, walks through a parser that returns informative
error messages, and discusses the design trade-offs of using
`result` at scale.

## The type

OCaml's standard library defines:

:::slide

## Definition

The standard library defines:

```ocaml skip
type ('a, 'e) result =
  | Ok of 'a
  | Error of 'e
```

- `Ok x` is success; `Error e` is failure with payload `e`.
- The payload type `'e` is a *parameter*: you choose what to carry on failure.
- Common choices: a `string` message, an error-code variant, a record.
- We saw the type in Module 4. Now we use it as a monad.

:::

The two type parameters give you flexibility: `'a` is the success
type, `'e` is the error type. A function returning `(int, string)
result` either gives you an `int` or a `string` error message.
A function returning `(int, my_error) result` either gives you an
`int` or a value of your custom variant type.

This is more flexible than `option`, where the failure case is
just "nothing". The cost: every signature now carries two type
parameters, and you have to think about what kind of error to
report. The benefit: when something fails, the caller learns
*why*, which is essential for parsers, validators, network clients,
and anything user-facing.

## `Result.bind` and `let*`

The standard library provides `Result.bind`. We define `let*` as
its alias and use it the same way as for `option`:

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
```

Same shape as the option monad; failure now carries an informative
message instead of just `None`.

:::

:::slide

## Trying the result-monad demo

```ocaml
let _ = demo "5"
let _ = demo "frog"
let _ = demo "200"
```

`Ok 10`, `Error "not an int: frog"`, `Error "too big"`. The first
failure to fire is the one returned; later steps don't run.

:::

The structure of the code is identical to the
[option-monad version in the previous lecture](M08-L02-option-monad.html#using-let).
The `let*` operator means the same thing: "unwrap the success, or
short-circuit with the failure." The only visible change is that
the failure case has a name and a payload.

If you read the three result lines: `demo "5"` parses, doubles,
checks under 100, returns `Ok 10`. `demo "frog"` fails at the
parse, returns the error message naming the offending input.
`demo "200"` parses to 200, doubles to 400, fails the "too big"
check.

This is what "errors with information" looks like in code. The
caller can pattern-match on the result, distinguishing success from
each kind of failure, and present a useful message to its caller
in turn.

## Why pick `result` over `option`?

:::slide

## Why pick `result` over `option`?

- **Errors with reasons.** Parsers, validators, network clients:
  callers need to know *why* failure happened.
- **Multiple failure modes.** Distinguish "not an int" from "out of
  range" from "wrong format" by encoding them in the error type.
- **Better diagnostics.** Stack-shaped error traces; user-readable
  messages.

- If the only failure case is "no value here": `option` is enough.
- If the failure type would carry diagnostic information worth
  surfacing: `result` is the right choice.

:::

The choice is not absolute. Within a single function, `option` may
be perfect for "this index was out of range, return nothing"
internal logic; `result` may make sense at the function's
boundary for "we could not parse, here is what went wrong" for
callers. Different layers, different choices.

A useful conversion between them, both ways:

:::slide

## Mixing `option` and `result`

It is common to have an `option` and want to lift it to a `result`
with a default error:

```ocaml
let to_result err = function
  | Some x -> Ok x
  | None -> Error err

let _ = to_result "missing" (Some 42)
let _ = to_result "missing" None
```

`Ok 42`, `Error "missing"`.

- The standard library has `Option.to_result ~none:err opt`.
- Going the other way: `Result.to_option`, which discards error info.

:::

`Option.to_result` and `Result.to_option` are the two adapter
functions in the stdlib. The first lifts an `option` to a `result`
by supplying a default error for the `None` case. The second drops
a `result` back to an `option`, throwing the error payload away.
They let you mix the two monads at a boundary.

## A typed error type

When several distinct things can go wrong, a `string` message
loses information. Encoding the failure as a
[variant](M04-L03-variants.html) gives callers something to
[pattern-match](M05-L01-basic-patterns.html) on:

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

let _ = parse_int_v "42"
let _ = parse_int_v "frog"
let _ = parse_int_v ""
let _ = parse_int_v "9999"
```

`Ok 42`, `Error (Not_an_int "frog")`, `Error Empty_input`,
`Error (Too_large 9999)`.

- The variant tells callers exactly which error fired.
- Callers can match on it and respond accordingly.

:::

A typed-error variant has a self-documenting quality: when you
read the type, you see every failure mode the function can raise.
This is a recurring strength of OCaml: you can encode "what can
go wrong" in the type system rather than in prose.

The trade-off is the same one we keep meeting: more types, less
ambiguity, slightly more code. For a one-off parser, a `string`
message is fine. For a function used in many places, a typed
variant is usually worth the investment.

## Errors propagate first-wins

The result monad short-circuits on the first `Error`. Subsequent
steps do not run:

:::slide

## Chaining: errors propagate first-wins

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

`Error "first"`.

- Once `step1` errored, the chain is dead.
- We never see `"second"` or `42`.
- This is usually the right behaviour: the *origin* of failure is
  the useful information.

:::

The behaviour matches the
[option monad's short-circuit-on-`None`](M08-L02-option-monad.html#using-let):
the first failure to fire is the one returned, and downstream
steps are skipped. This is what you usually want from sequential
code. Parsing step 2 only makes sense if step 1 succeeded; running
step 3 only makes sense if step 2 succeeded.

There is an alternative pattern, sometimes called *validation* or
*applicative*, where you want every error rather than just the
first. Suppose you are validating a form with multiple fields; if
the user fills two of them wrong, you want to tell them about
both, not just the first.

:::slide

## When you want to collect all errors

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

let _ = combine (validate_int "frog") (validate_int "bar")
```

`Error ["frog is not an int"; "bar is not an int"]`.

- Error type is `string list`; `combine` accumulates.
- The *applicative* (validation) shape: runs both arms regardless
  and aggregates failures. Not a strict monad.

:::

The validation pattern uses an *accumulating* error type (a list,
or any monoid). The combiner runs both sides, then unions their
errors. It is not a monad in the strict sense, because monad
`bind` lets the second step depend on the first's value, which
the validation pattern cannot do (it has no value when the first
errored). It is a closely related shape, and the difference matters
in production code where you want comprehensive feedback.

OCaml does not have built-in syntax sugar for the validation
pattern, but writing your own combinators (often called `and+` or
`and*`) is straightforward. We will not pursue it further in this
course.

## When `result` becomes heavy

A function chain six `let*`s long with `result` is fine and idiomatic.
A whole codebase where every function returns `('a, my_error) result`
is a lot of types to carry around:

:::slide

## When `result` becomes heavy

- A six-step `let*` chain is fine.
- A whole codebase of `result`-returning functions is a tax.

Real OCaml code often:

- Uses `result` at *module boundaries* (the public APIs).
- Uses exceptions or `option` inside a module where the failure
  mode is local.
- Layers a result monad only where errors are user-visible.

The choice is not "always use result"; it is "use result where
informative errors are worth their weight".

:::

The argument for using `result` everywhere is uniformity: every
function has the same shape, every caller knows what to do. The
argument against is that the boilerplate piles up, especially at
boundaries where you have to map between different error types
(your [module's](M07-L04-module-basics.html) errors versus the
library's errors). Most real codebases compromise: `result` at the
API boundary, simpler mechanisms internally.

A second tactic, used in larger codebases: define a single
top-level error type for the whole project, with one constructor
per error category, and have all the result-typed functions use
that type. This unifies the result types at the cost of one
central place that knows about every kind of failure. Some
projects find this elegant; others find it bureaucratic. There is
no universal right answer.

## A quick check

:::quiz mcq id=M08-L03-q3
Given `let pipeline () = let* _ = (Error "first") in let* _ =
(Error "second") in Ok 42` (with `let*` bound to `Result.bind`),
what does `pipeline ()` evaluate to?

- [ ] `Ok 42`.
- [x] `Error "first"`.
- [ ] `Error "second"`.
- [ ] `Error "first; second"`.

**Why:** `Result.bind` short-circuits on the first `Error`. The
second and third lines never run; the `Error "first"` from the
first line is returned unchanged. "Collect all errors" requires
the validation pattern, not the monad pattern.
:::

:::quiz mcq id=M08-L03-q2
Which is the right tool for "this function might return one of
five distinct kinds of error and callers should be able to react
differently to each"?

- [ ] `'a option`.
- [ ] `('a, string) result`.
- [x] `('a, my_error) result` where `my_error` is a five-case variant.
- [ ] Raise five different exceptions.

**Why:** `option` has no room for error information. A `string`
result loses the structure: callers would have to parse the
message to decide what to do. A typed variant in the error slot
makes the five cases first-class and pattern-matchable. (The
exception version works but loses static checking; the compiler
will not tell you if you forgot to handle one case.)
:::

:::slide

## Activity

Define `parse_pair_r : string -> ((int * int), string) result` that
returns informative error messages. Use `let*`.

:::

:::slide

## Activity solution: the helpers

```ocaml
let ( let* ) = Result.bind

let int_or_err prefix s =
  match int_of_string_opt s with
  | Some n -> Ok n
  | None -> Error (prefix ^ ": not an int: " ^ s)
```

`int_or_err` produces a labelled `Error` if parsing fails.

:::

:::slide

## Activity solution: `parse_pair_r`

```ocaml
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
```

Two `let*`s short-circuit on first parse failure.

:::

:::slide

## The activity solution in action

```ocaml
let _ = parse_pair_r "(3, 4)"
let _ = parse_pair_r "(3, frog)"
let _ = parse_pair_r "frog"
```

`Ok (3, 4)`, `Error "second: not an int: frog"`,
`Error "expected '(... , ...)'"`.

:::

A small code quiz to put it together:

:::quiz code id=M08-L03-q1
Write `safe_div_chain : int -> int -> int -> (int, string) result`
that computes `((a / b) / c)` using `Result.bind`, returning
`Error "div by zero"` if either division would fail.

```ocaml
let safe_div_chain a b c =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (safe_div_chain 100 5 2 = Ok 10) "ok";
  check (safe_div_chain 100 0 2 = Error "div by zero") "first zero";
  check (safe_div_chain 100 5 0 = Error "div by zero") "second zero";
  check (safe_div_chain 100 5 4 = Ok 5) "ok (truncation)";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let ( let* ) = Result.bind
let safe_div a b =
  if b = 0 then Error "div by zero" else Ok (a / b)
let safe_div_chain a b c =
  let* ab = safe_div a b in
  safe_div ab c
```

Two divisions, two `let*`s (well, one `let*` and a tail call), a
single failure type. The chain short-circuits on the first
divide-by-zero, which is exactly what we want.

:::

## What is next

:::slide

## What is next

Lecture 4: the **state monad**.

- Thread a hidden state through a chain of computations *without*
  mutation.
- The third monad shape; the same `let*` notation.

:::

We have seen two monads with the same shape: `option` and
`result`, both about possible failure. The
[next lecture](M08-L04-state-monad.html) moves to a different
flavour entirely: the state monad, which threads a piece of
"ambient" state through a chain of pure computations. Same `let*`
syntax, very different intuition.

## Reading

- **Cornell CS3110**, *Result monad*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
