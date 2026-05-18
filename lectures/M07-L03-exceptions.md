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

OCaml has exceptions for situations where threading an `option` or
`result` through every layer of the call stack is impractical. This
lecture covers how to raise, how to catch, and when the
`option`/`result` shape we saw in Module 4 is the better choice.

:::slide

## Built-in exceptions

```ocaml
let _ = try List.hd [] with Failure _ -> 0
```

`int = 0`. `List.hd` raises `Failure "hd"` on an empty list. The
`try ... with` catches.

A handful of exceptions are defined in the standard library:

- `Failure of string` - raised by `failwith "..."`.
- `Invalid_argument of string` - raised by `invalid_arg "..."`.
- `Not_found` - raised by lookup functions when the key is absent.
- `Division_by_zero` - raised by `/` and `mod` on `0`.
- `End_of_file` - raised when reading past the end.

Plus a few others. You'll see these as the failures of various
standard library functions.

:::

:::slide

## Raising

```ocaml
let head = function
  | [] -> failwith "head of empty list"
  | x :: _ -> x

let _ = head [1; 2; 3]
```

`int = 1`.

`failwith s` is short for `raise (Failure s)`. `invalid_arg s` is
`raise (Invalid_argument s)`. They're convenience wrappers; you
can also `raise some_exception` directly.

:::

:::slide

## Catching

```ocaml
let safe_head xs =
  try Some (List.hd xs)
  with Failure _ -> None

let _ = safe_head [1; 2; 3]
let _ = safe_head []
```

`Some 1`, `None`. The `try ... with` runs the body; if an
exception is raised, the matching clause's right-hand side
becomes the result.

The `with` part uses pattern matching: clauses match exception
constructors. You can catch specific exceptions:

```ocaml
let safe_divide a b =
  try Some (a / b)
  with Division_by_zero -> None

let _ = safe_divide 10 0
let _ = safe_divide 10 3
```

`None`, `Some 3`.

:::

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

`120`, `-1`. Custom exceptions can carry payload:

```ocaml
exception Parse_error of string * int  (* message, line *)
```

`raise (Parse_error ("unexpected token", 42))` and catch with
`Parse_error (msg, line) -> ...`.

:::

:::slide

## Exception vs `option` vs `result`

Three shapes for "this might fail":

```ocaml skip
val find_x : string -> int                    (* may raise *)
val find_x_opt : string -> int option         (* None on failure *)
val find_x_result : string -> (int, string) result   (* Error msg *)
```

Trade-offs:

- **Raise**: cheapest at the call site (no wrapping), but the
  failure isn't in the type. Callers may forget to handle.
- **Option**: failure is in the type; caller must match on
  `None`. No reason for the failure.
- **Result**: failure has a payload (an error message, an error
  code).

Convention in the standard library: each function comes in
*both* shapes. `List.find` raises `Not_found`; `List.find_opt`
returns `None`. Reach for the `_opt` form by default.

:::

The naming `_opt` suffix is the OCaml convention: any function
that returns `option` instead of raising is named the same as its
raising counterpart with `_opt` appended. `List.assoc` /
`List.assoc_opt`, `Hashtbl.find` / `Hashtbl.find_opt`, etc.

:::slide

## `try` is an expression

```ocaml
let _ =
  try List.hd [10; 20; 30]
  with Failure _ -> 0
```

`int = 10`. The `try` expression has a value: either the body's
result (if no exception was raised), or the value of the matching
handler.

Both have to have the *same type*. `List.hd` returns `int`, the
handler returns `int`, the `try` has type `int`.

:::

:::slide

## Catching multiple exceptions

```ocaml
let safely f x =
  try Ok (f x)
  with
  | Failure msg -> Error ("failure: " ^ msg)
  | Invalid_argument msg -> Error ("invalid: " ^ msg)
  | Division_by_zero -> Error "div by zero"
  | _ -> Error "unknown"

let _ = safely (fun n -> 100 / n) 4
let _ = safely (fun n -> 100 / n) 0
```

`Ok 25`, `Error "div by zero"`.

Multiple handlers, one for each exception kind. The wildcard `_`
catches anything else; use it sparingly because it can hide bugs
(an unrelated `Stack_overflow` would be silently swallowed).

:::

:::slide

## When *not* to use exceptions

- For control flow you'd handle anyway (`option` is cleaner).
- For "this won't happen" assertions (use `assert false` or, better,
  redesign to make it unrepresentable).
- For deeply nested computations where reasoning about *when* the
  exception escapes is hard.

Exceptions are good for genuinely rare failures (parse failed,
file not found) where the calling code's structure shouldn't be
polluted by error handling at every step. For predictable
"missing value" cases, `option` is clearer.

:::

:::slide

## Activity

Write `find_first : ('a -> bool) -> 'a list -> 'a` that returns
the first element matching the predicate, raising `Not_found` if
none does. Then write `find_first_opt` returning `None` instead.

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

`find_first_opt` is the safe wrapper: it catches the exception and
turns it into an `option`. This is the standard pattern when you
want to expose both APIs.

The standard library's `List.find` and `List.find_opt` are exactly
this pair.

:::

:::slide

## What's next

Lecture 4: **module basics**. OCaml has a powerful module system,
distinct from the variants/records/functions we've been using.
Modules let you group related definitions, hide internals, and
parameterize over implementations.

:::

## Reading

- **Cornell CS3110**, *Exceptions*:
  <https://cs3110.github.io/textbook/chapters/data/exceptions.html>
