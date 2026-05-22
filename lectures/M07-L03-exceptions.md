---
title: "Exceptions"
lecture_no: 3
week: 7
duration_target_min: 22
concepts: [raise, try-with, exception declarations, when to throw vs return option]
keywords: [OCaml, exception, raise, try, with, Failure, Not_found]
activity_question: "Write [find_first : ('a -> bool) -> 'a list -> 'a] that returns the first element matching the predicate, raising [Not_found] if none does. Then write a wrapper [find_first_opt] returning [None] instead."
think_about_this: "Exceptions are not tracked in OCaml's type system. A function with type [int -> int] might raise anyway. What does this cost the reader? When is [result] / [option] a better fit?"
reading:
  - title: "Cornell CS3110, Exceptions"
    url: https://cs3110.github.io/textbook/chapters/data/exceptions.html
---

# Exceptions


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Exceptions</h2>
<p class="title-slide-label">Module 7 &middot; Lecture 3</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

A function's type tells you the shape of its output: `int -> int`
returns an `int`, `'a list -> int` returns the length of a list,
and so on. But what if the function is asked to compute something
that has no answer? `List.hd []` cannot return an `int`: the empty
list has no head. `1 / 0` cannot return an `int`: integer division
by zero is undefined. `int_of_string "hello"` cannot return an
`int`: the string is not a number.

We have already seen one way to express this: the
[`option` type](M04-L04-recursive-types.html#the-option-type)
(`None` when there is no answer, `Some x` when there is) and the
[`result` type](M04-L04-recursive-types.html#the-result-type)
(`Error e` instead of just `None`, so the failure can carry a
reason). Those were the subjects of
[Module 4](M04-L04-recursive-types.html). They are the *typed*
approach to partial functions: the possibility of failure is right
there in the return type, and the compiler will not let you forget
to handle it.

This lecture covers the other approach: *exceptions*. An exception
is a kind of value that, when *raised*, interrupts the normal flow
of evaluation and propagates up the call stack until something
catches it. Exceptions are how OCaml expresses "something went
wrong in a way the caller probably is not going to handle here,
but somebody up the call stack might want to." They are cheap at
the call site (no wrapping in `Some`, no unwrapping with `match`)
but they hide the possibility of failure from the type. We will
spend the lecture on what exceptions are, how to raise and catch
them, and the practical question of when an exception is the
right shape and when an `option` or `result` is.

## Built-in exceptions

OCaml's standard library predefines a handful of common
exceptions. Here is a tour, with examples of where each one comes
up.

```ocaml
let _ = try List.hd [] with Failure _ -> 0
```

The toplevel reports `int = 0`. `List.hd` (head of a list) raises
the exception `Failure "hd"` when called on an empty list; the
`try ... with` form catches that exception and substitutes `0` as
the result.

Some standard exceptions you will meet:

- `Failure of string` is raised by `failwith "..."`. It signals
  "the function was called in a way the documentation forbids."
- `Invalid_argument of string` is raised by `invalid_arg "..."`.
  Used for outright invalid inputs: `String.get s i` with `i` out
  of range, for instance.
- `Not_found` is raised by lookup functions when the key is
  absent. `List.assoc`, `Hashtbl.find`, and many others raise it.
- `Division_by_zero` is raised by `/` and `mod` on integer zero.
- `End_of_file` is raised by reading-from-channel functions when
  they hit the end of input.

There are a handful more; the [OCaml stdlib documentation](https://v2.ocaml.org/api/Stdlib.html)
lists them under "Predefined exceptions."

:::slide

## Built-in exceptions

```ocaml
let _ = try List.hd [] with Failure _ -> 0
```

`int = 0`. `List.hd` raises `Failure "hd"`; `try ... with` catches.

Common standard-library exceptions:

- `Failure of string`: from `failwith "..."`.
- `Invalid_argument of string`: from `invalid_arg "..."`.
- `Not_found`: lookups when the key is absent.
- `Division_by_zero`: `/` and `mod` on `0`.
- `End_of_file`: reading past the end.

:::

## Raising exceptions

To raise an exception, use the `raise` function. Two convenience
wrappers `failwith` and `invalid_arg` are common enough to know
by name.

```ocaml
let head = function
  | [] -> failwith "head of empty list"
  | x :: _ -> x

let _ = head [1; 2; 3]
```

`int = 1`. `failwith s` is shorthand for `raise (Failure s)`;
`invalid_arg s` is shorthand for `raise (Invalid_argument s)`. The
expanded forms make the construction explicit: an exception value
is a constructor applied to its payload, the same way `Some 3` is
a `Some` constructor applied to a `3`. The only thing that
distinguishes an exception value from any other value is what you
*do* with it: you `raise` it.

:::slide

## Raising

```ocaml
let head = function
  | [] -> failwith "head of empty list"
  | x :: _ -> x

let _ = head [1; 2; 3]
```

`int = 1`.

- `failwith s` is short for `raise (Failure s)`.
- `invalid_arg s` is `raise (Invalid_argument s)`.
- These are **convenience wrappers**.
- You can also `raise some_exception` directly.

:::

A subtle but important fact about the type of `raise`. The function
has type `exn -> 'a`. The result type is *polymorphic*: a `raise`
expression can stand in for any type the surrounding context wants.
This is consistent: a raise does not return a value, so there is no
constraint on what type it would have produced. The `match` branch
`| [] -> failwith "..."` lives next to `| x :: _ -> x`, which has
type `'a` (the element type). The `failwith` side must have the
same type as the other branch, which is `'a`. Because `raise` is
polymorphic, the types match without any coercion.

## Catching exceptions: try and with

A `try ... with` expression looks like a
[`match`](M05-L01-basic-patterns.html), except it matches on the
*exception* a body raises rather than on a value the body produces.

```ocaml
let safe_head xs =
  try Some (List.hd xs)
  with Failure _ -> None

let _ = safe_head [1; 2; 3]
let _ = safe_head []
```

`Some 1` for the non-empty list, `None` for the empty list. The
shape:

- The expression after `try` is evaluated normally.
- If it produces a value, the `try` produces that same value.
- If it raises an exception, the exception is matched against the
  `with` clauses. The matching clause's right-hand side becomes
  the result.
- Both must have the *same type*: `try` is an expression, so its
  type is one thing.

:::slide

## Catching

```ocaml
let safe_head xs =
  try Some (List.hd xs)
  with Failure _ -> None

let _ = safe_head [1; 2; 3]
let _ = safe_head []
```

`Some 1`, `None`.

- `try ... with` runs the body.
- If an exception is raised, the matching clause's right-hand side
  becomes the result.
- The `with` part uses **pattern matching**: clauses match
  exception constructors.
- You can catch specific exceptions:

```ocaml
let safe_divide a b =
  try Some (a / b)
  with Division_by_zero -> None

let _ = safe_divide 10 0
let _ = safe_divide 10 3
```

`None`, `Some 3`.

:::

The patterns on the right of `with` are real
[*patterns*](M05-L01-basic-patterns.html): they can match on the
constructor, bind the payload, and even include
[nested patterns](M05-L02-nested-and-or-patterns.html). The
wildcard `_` matches any payload. You can have multiple clauses,
each catching a different exception:

```ocaml
let safely f x =
  try Ok (f x)
  with
  | Failure msg -> Error ("failure: " ^ msg)
  | Invalid_argument msg -> Error ("invalid: " ^ msg)
  | Division_by_zero -> Error "div by zero"

let _ = safely (fun n -> 100 / n) 4
let _ = safely (fun n -> 100 / n) 0
```

`Ok 25` for `n = 4`, `Error "div by zero"` for `n = 0`. If the
exception raised does not match any of the clauses, it continues
propagating up the call stack; the `try` does not "consume" it.

You can include a wildcard pattern `| _ -> ...` to catch any
exception, but this is *almost always a mistake*. It will swallow
exceptions you did not anticipate, hiding bugs that would
otherwise surface as a crash. Catch specific exceptions; let
unexpected ones propagate.

## Defining your own exception

Custom exceptions are declared with the `exception` keyword, much
like a [variant constructor](M04-L03-variants.html).

```ocaml
exception Negative_input

let factorial n =
  if n < 0 then raise Negative_input
  else
    let rec go acc n =
      if n = 0 then acc else go (acc * n) (n - 1)
    in
    go 1 n

let _ =
  try factorial 5 with Negative_input -> -1

let _ =
  try factorial (-1) with Negative_input -> -1
```

`120` for `factorial 5`; `-1` for `factorial (-1)`, because the
exception was raised and caught.

An exception can also carry a payload, just like a
[variant constructor with arguments](M04-L03-variants.html). The
declaration uses `of`:

```ocaml
exception Parse_error of string * int  (* message, line *)
```

To raise: `raise (Parse_error ("unexpected token", 42))`. To
catch: `| Parse_error (msg, line) -> ...`. The payload can be any
type or tuple of types.

:::slide

## Defining your own exception

```ocaml
exception Negative_input

let factorial n =
  if n < 0 then raise Negative_input
  else
    let rec go acc n =
      if n = 0 then acc else go (acc * n) (n - 1)
    in
    go 1 n

let _ =
  try factorial 5 with Negative_input -> -1

let _ =
  try factorial (-1) with Negative_input -> -1
```

`120`, `-1`.

- Custom exceptions can carry a **payload**:
  `exception Parse_error of string * int`, raised as
  `raise (Parse_error ("unexpected token", 42))`.

:::

Under the hood, exceptions are an *extensible variant*: they all
share a single type called `exn`, and every `exception` declaration
adds a new constructor to that type. This is unusual: most
[OCaml variants](M04-L03-variants.html) are closed (the set of
constructors is fixed at the declaration). The `exn` type is the
one exception, because libraries throughout a program need to be
able to add their own exception constructors. We will not need the
deeper machinery of extensible variants; the practical takeaway is
that you can declare new exception types anywhere and they all flow
through the same `try ... with` mechanism.

## Exception vs option vs result

The three shapes for "this might fail," compared.

```text
val find_x : string -> int                    (* may raise *)
val find_x_opt : string -> int option         (* None on failure *)
val find_x_result : string -> (int, string) result   (* Error msg *)
```

**Raise.** Cheapest at the call site: the caller writes
`let x = find_x "key"` and uses `x` directly. The cost is that the
*type* says nothing about failure. A reader of the type cannot
tell whether the function might raise. The compiler will not warn
a caller that forgot to handle the failure.

**Option.** The failure is in the type. The caller is forced to
pattern-match on `Some` and `None`. The cost is two things: every
call site is slightly more code, and the failure carries no
information (`None` is just "no value here," with no reason).

**Result.** The same as option, but the failure side has a
payload: an error message, an error code, a structured error
variant. Best when the caller might want to log or recover based
on what went wrong.

:::slide

## Exception vs `option` vs `result`

Three shapes for "this might fail":

```text
val find_x : string -> int                    (* may raise *)
val find_x_opt : string -> int option         (* None on failure *)
val find_x_result : string -> (int, string) result   (* Error msg *)
```

- **Raise**: cheap at call site; failure not in the type.
- **Option**: failure in the type; no reason carried.
- **Result**: failure in the type, with a payload.
- **Stdlib**: each function in *both* shapes (`List.find` raises,
  `List.find_opt` returns).
- **Default**: prefer `_opt`.

:::

The OCaml standard library follows a clear convention: any
function that raises an exception on failure comes in a paired
form that returns `option`, with the suffix `_opt`. So
`List.find` raises `Not_found`; `List.find_opt` returns `None`.
`List.assoc` raises `Not_found`; `List.assoc_opt` returns `None`.
`Hashtbl.find` raises; `Hashtbl.find_opt` returns. The convention
extends to types: the raising form usually exists for historical
reasons, and the `_opt` form is the one to prefer in new code.

Why two forms? The raising form is older; the `_opt` form was
added as OCaml moved toward making partial failures visible in
the type system. The library keeps both for backward compatibility,
but the social convention is clear: new code uses `_opt`.

The naming `_opt` suffix is the OCaml convention; expect to see
it everywhere.

## try is an expression

A reminder: like every other control construct in OCaml, `try`
produces a value.

```ocaml
let _ =
  try List.hd [10; 20; 30]
  with Failure _ -> 0
```

`int = 10`. The body returns `10`, no exception is raised, the
`try` produces `10`. Had the body raised, the handler would have
returned `0`. Either way, the expression's type is `int`, and the
result can be used wherever an `int` is wanted.

:::slide

## `try` is an expression

```ocaml
let _ =
  try List.hd [10; 20; 30]
  with Failure _ -> 0
```

`int = 10`.

- The `try` expression has a value: either the body's result (if
  no exception was raised), or the value of the matching handler.
- Both have to have the *same type*.
- Here: `List.hd` returns `int`, the handler returns `int`, the
  `try` has type `int`.

:::

## When not to use exceptions

A short list of cases where reaching for an exception is the
wrong call.

:::slide

## When *not* to use exceptions

**Avoid for:**

- Control flow you'd handle anyway: prefer `option`.
- "This won't happen" assertions: use `assert false`, or redesign.
- Deep nesting where the escape path is hard to follow.

**Good fit:**

- Rare failures (parse failed, file not found) where error
  handling would pollute every step.

**Bad fit:**

- Predictable "missing value" cases: `option` is clearer.

:::

**For predictable missing values.** "The key might be missing from
the map" is not an exceptional case, it is the expected behaviour
of a lookup. Use [`option`](M04-L04-recursive-types.html#the-option-type);
the caller will pattern-match cleanly.

**For "this can't happen" assertions.** If a code path is
unreachable, write `assert false` or, better, restructure the
types so the unreachable case is genuinely impossible (a
[variant](M04-L03-variants.html) without that constructor).
Exceptions are not a substitute for type-driven design.

**For deeply nested control flow.** An exception raised three
levels deep, caught at the top, can be hard to follow when you
read the code. Each `try` introduces a place where execution can
jump; a function with many `try`s scattered through it is hard to
reason about.

The genuine sweet spot for exceptions: *unexpected, rare
failures* that callers usually do not handle locally. Parse
failures in a parser used inside a larger pipeline, file-system
errors that propagate to the top of a CLI, that kind of thing.
The convention here matches the convention in Python and Java:
exceptions for things that "should not normally happen."

## A quick check

:::quiz mcq id=M07-L03-q3
What is the type of `raise (Failure "oops")`?

- [ ] `unit`
- [ ] `exn`
- [x] `'a`
- [ ] `Failure`

**Why:** `raise` has type `exn -> 'a`. Its return type is
polymorphic because a `raise` never produces a normal value; it
can stand in any type-checking context. The exception value
itself (`Failure "oops"`) has type `exn`, but the *raise
expression* has type `'a`.
:::

:::quiz mcq id=M07-L03-q2
What does this evaluate to?

```ocaml
try
  let _ = List.hd [] in
  "no exception"
with
  | Not_found -> "not found"
  | Failure _ -> "failure"
```

- [ ] `"no exception"`
- [ ] `"not found"`
- [x] `"failure"`
- [ ] runtime crash

**Why:** `List.hd []` raises `Failure "hd"`. The `Failure _`
handler matches and returns `"failure"`. The `Not_found` clause
does not match (different exception); the body never finishes.
:::

## Activity

:::slide

## Activity

Write `find_first : ('a -> bool) -> 'a list -> 'a` that returns
the first element matching the predicate, raising `Not_found` if
none does. Then write `find_first_opt` returning `None` instead.

:::

:::quiz code id=M07-L03-q1
Write `find_first` raising `Not_found`, then wrap it to give
`find_first_opt`.

```ocaml
let rec find_first p xs =
  failwith "not implemented"

let find_first_opt p xs =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (find_first (fun n -> n > 5) [1; 7; 3] = 7) "found";
  (match (try Some (find_first (fun _ -> false) [1; 2]) with Not_found -> None) with
   | None -> ()
   | Some _ -> failwith "expected Not_found");
  check (find_first_opt (fun n -> n > 5) [1; 7; 3] = Some 7) "opt found";
  check (find_first_opt (fun n -> n > 100) [1; 2; 3] = None) "opt missing";
  check (find_first_opt (fun _ -> false) [] = None) "opt empty";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```ocaml
let rec find_first p = function
  | [] -> raise Not_found
  | x :: rest -> if p x then x else find_first p rest

let find_first_opt p xs =
  try Some (find_first p xs)
  with Not_found -> None
```

:::

:::slide

## Activity solution

```ocaml
let rec find_first p = function
  | [] -> raise Not_found
  | x :: rest -> if p x then x else find_first p rest

let find_first_opt p xs =
  try Some (find_first p xs)
  with Not_found -> None

let _ = find_first_opt (fun n -> n > 5) [1; 7; 3]
let _ = find_first_opt (fun n -> n > 100) [1; 2; 3]
```

`Some 7`, `None`.

- `find_first_opt` is the **safe wrapper**: catches the exception
  and turns it into an `option`.
- Standard pattern when you want to expose both APIs.
- The stdlib's `List.find` and `List.find_opt` are exactly this
  pair.

:::

The `find_first_opt` definition is the standard pattern for
turning a raising function into an optional one: wrap the call in
a `try`, and convert the exception into `None`. This is exactly
how the standard library's `_opt` forms are typically defined.
You can also go the other way (a raising version from an optional
version) with a `match`:

```text
let find_first p xs =
  match find_first_opt p xs with
  | Some x -> x
  | None -> raise Not_found
```

Either direction works; pick the one whose implementation is
easier to read for your case.

## What's next

That closes the imperative trio of Module 7. The
[next two lectures](M07-L04-streams-and-laziness.html) take a
small detour: *streams* (infinite data structures, built using
thunks and refs from this module) and *memoization* (caching
function results, again using a ref to hold the cache). Then
the [last three lectures](M07-L06-module-basics.html) turn to
*modules*: how OCaml structures code at scale, namespaces large
libraries, and hides representation behind type signatures. The
standard library you have been using all course (`List`,
`Array`, `String`, `Option`) is a tree of modules; we finally
meet the machinery that builds it.

:::slide

## What's next

Lecture 4: **streams and laziness**.

- Recursive values and infinite data structures.
- Streams: pausing evaluation with thunks; lazy values; lazy
  streams.
- Higher-order ops on streams; primes by the Sieve of
  Eratosthenes; Fibonacci as a stream.

:::

## Reading

- **Cornell CS3110**, *Exceptions*:
  <https://cs3110.github.io/textbook/chapters/data/exceptions.html>
- **Real World OCaml**, *Error Handling*:
  <https://dev.realworldocaml.org/error-handling.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
