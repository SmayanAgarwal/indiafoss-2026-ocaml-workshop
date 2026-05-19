---
title: "`option`, `result`, and type abbreviations"
lecture_no: 5
week: 4
duration_target_min: 22
concepts: [option type, None, Some, result type, type abbreviation, optional values]
keywords: [OCaml, option, result, type alias, None, Some, optional values]
activity_question: "Write [safe_div : int -> int -> int option] that returns [None] on division by zero and [Some (a / b)] otherwise."
think_about_this: "Many languages use [null] to mean 'no value'. OCaml uses [option]. What does a function signature like [val find : key -> value option] tell a caller that [val find : key -> value] (with null possible) does not?"
reading:
  - title: "Cornell CS3110, Options"
    url: https://cs3110.github.io/textbook/chapters/data/options.html
---

# `option`, `result`, and type abbreviations

A function that *might* fail to produce a value is everywhere in
real software: lookup, parsing, division. This lecture is about how
OCaml expresses "maybe a value" without `null`, the related "value
or error" pattern, and the small feature of *type abbreviations*
for keeping types readable.

:::slide

## The `option` type

```ocaml
type 'a option =
  | None
  | Some of 'a
```

- `'a option` is one of two things: `None` (no value) or `Some x` (a value `x : 'a`)
- A variant with two constructors, parameterized by the inner type
- `int option`: `None` or `Some i` where `i : int`
- `string option`: `None` or `Some s` where `s : string`

```ocaml
let x : int option = Some 42
let y : int option = None
```

:::

:::slide

## Why not `null`?

- Many languages use `null` (Java, C, Go) or `undefined` (JavaScript) for "no value"
- Trouble: **every** reference might secretly be null
- The type system doesn't tell you which

`var name = lookup("alice");
println(name.length());`

- Compiles fine
- Crashes at runtime if `lookup` returned `null`
- Every reader must remember to check on **every** reference

OCaml's `option`:

```
val lookup : string -> string option
```

- Forces you to spell out that both cases are handled
- The type **tells** reader and compiler the function may not return a value
- No way to use the inner string without inspecting for `None` first

:::

The shift from `null` to `option` is one of the everyday wins of
the OCaml type system. Compile-time it's a small annoyance: you
have to handle both cases. Run-time, you stop having
NullPointerExceptions / SegmentationFaults / `TypeError: cannot read
property of undefined` errors entirely. The trade is almost always
worth it.

:::slide

## Using an `option`

You pattern-match it:

```ocaml
let describe = function
  | None -> "no value"
  | Some x -> "got " ^ string_of_int x

let _ = describe (Some 7)
let _ = describe None
```

- Results: `"got 7"` and `"no value"`
- Can't write `(Some 7) + 1`: that's adding `int option` to `int`, a type error
- Must **unwrap** first:

```ocaml skip
match find_age "alice" with
| None -> 0
| Some n -> n + 1
```

- Either you handle the missing case, or it doesn't compile

:::

:::slide

## A safe division

```ocaml
let safe_div a b =
  if b = 0 then None
  else Some (a / b)

let _ = safe_div 10 2
let _ = safe_div 10 0
```

- Results: `Some 5` and `None`
- Type: `int -> int -> int option`
- Caller is **forced** to handle the divide-by-zero case explicitly
- Compare a C-style version returning `-1` on error:
  - Callers might forget the check
  - Or mistake a legitimate `-1` result for the error code
- `option` makes the error case **unmistakable**

:::

:::slide

## Chained `option` access

When several option-returning operations are chained, nested
matches get verbose:

```ocaml
let lookup_age (name : string) : int option = (* ... *)
  ignore name; None  (* stub *)

let increment_age name =
  match lookup_age name with
  | None -> None
  | Some n -> Some (n + 1)
```

A standard helper makes this cleaner:

```ocaml skip
let increment_age name =
  Option.map (fun n -> n + 1) (lookup_age name)
```

- `Option.map f x`:
  - `None` if `x` is `None`
  - `Some (f v)` if `x = Some v`
- Standard `Option` module also has `Option.bind`, `Option.get`, `Option.value` (with default), etc.

:::

`Option.map` is the cleanest example of why `option` is more
useful than `null`: you can *operate on the optional value as if
it were present*, and the absence-of-value case is propagated
automatically. The monad-shaped APIs in Module 8 are this pattern
in fuller form.

:::slide

## The `result` type

```ocaml
type ('a, 'e) result =
  | Ok of 'a
  | Error of 'e
```

- Like `option`, but the failure case **carries a value**
- That value: error message, error code, structured error type
- `Ok 42`: "success with value 42"
- `Error "out of memory"`: "failure with this reason"

```ocaml
let parse_int s =
  try Ok (int_of_string s)
  with Failure _ -> Error ("not an int: " ^ s)

let _ = parse_int "42"
let _ = parse_int "frog"
```

- Results: `Ok 42`, `Error "not an int: frog"`
- Use `result` when callers need to know **why** it failed, not just *that* it failed

:::

:::slide

## Type abbreviations

You can give a short name to a longer type:

```ocaml
type point = float * float
type points = point list
```

- `point` and `(float * float)` are the **same** type
- `points` and `(float * float) list` are the same
- Names exist purely for **readability**

```ocaml
let origin : point = (0.0, 0.0)
let triangle : points = [(0.0, 0.0); (1.0, 0.0); (0.5, 1.0)]
```

- Type signature documents intent
- Compiler treats `point` and `float * float` interchangeably

:::

:::slide

## When to use a type abbreviation vs a record

Both let you give a name to a compound type:

- **Type abbreviation** (`type point = float * float`):
  - Underlying representation **leaks**: `(1.0, 2.0)` and a `point` are the same
  - Field access is positional (`fst`, `snd`)
- **Record** (`type point = { x : float; y : float }`):
  - A *new* type
  - Construction requires the type name (or context)
  - Access by field name

- Records: nominally typed, self-documenting
- Abbreviations: aliases
- Use records for a **real new type**
- Use abbreviations to **name** an existing type for readability

:::

:::slide

## Activity

Write `safe_div : int -> int -> int option` returning `None` on
division by zero, `Some (a / b)` otherwise.

:::

:::slide

## Activity solution

```ocaml
let safe_div a b =
  if b = 0 then None
  else Some (a / b)

let _ = safe_div 100 7
let _ = safe_div 100 0
```

- Results: `Some 14` and `None`
- Caller decides what to do with each

A common idiom for handling it.

```ocaml skip
match safe_div 100 b with
| None -> 0  (* or: raise, or: log, or: ask the user *)
| Some q -> q
```

- Compiler enforces **both** branches
- Cannot pretend the `None` case won't happen

:::

:::slide

## What's next

Lecture 6: the **tutorial** for Module 4. We design a small ADT for
a domain (a tiny JSON-like value type), implement a couple of
operations on it, and use everything from Module 4 (records,
variants, recursion, option).

:::

## Reading

- **Cornell CS3110**, *Options*:
  <https://cs3110.github.io/textbook/chapters/data/options.html>
