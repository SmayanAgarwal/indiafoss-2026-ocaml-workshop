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
  - title: "Cornell CS3110, Type synonyms"
    url: https://cs3110.github.io/textbook/chapters/data/type_synonym.html
  - title: "Real World OCaml, Error handling"
    url: https://dev.realworldocaml.org/error-handling.html
---

# `option`, `result`, and type abbreviations

A function that *might fail to produce a value* is everywhere in
real software: a hashtable lookup that finds nothing; a parser
fed garbage; division by zero. Every language has to answer the
question "how do I express that?" Some answers (use `null`, return
`-1`, throw an exception) have well-known downsides. OCaml's answer
is a single type, `option`, that makes "no value" explicit in the
type system, and a closely related type, `result`, for "no value
*because*..."

This lecture covers both, plus a small but separate feature:
*type abbreviations*, which let you give a short name to a longer
type for readability. Together, these three pieces wrap up Module
4's introduction to OCaml's data-type vocabulary. The
[tutorial in the next lecture](M04-L06-tutorial.html) puts
everything together.

## The `option` type

`option` is a variant with two constructors:

```
type 'a option =
  | None
  | Some of 'a
```

A value of type `'a option` is one of two things: `None` (meaning
"there is no value here") or `Some x` (meaning "there is a value,
and that value is `x`"). The `'a` parameter is the type of the
value inside, if there is one.

:::slide

## The `option` type

```
type 'a option =
  | None
  | Some of 'a
```

- `'a option` is one of two things: `None` (no value) or `Some x` (a value `x : 'a`).
- A variant with two constructors, parameterised by the inner type.
- `int option`: `None` or `Some i` where `i : int`.
- `string option`: `None` or `Some s` where `s : string`.

```ocaml
let x : int option = Some 42
let y : int option = None
```

:::

You can think of an `option` as a small box that either contains
something of type `'a` or does not. To use the value inside, you
have to open the box and check which case you got.

`option` is defined in the standard library; you do not need to
declare it. `None` and `Some` are the constructors; both are in
scope by default. (Like `bool` and `list`, `option` is itself a
[variant](M04-L03-variants.html#variants-you-have-already-used);
we have been pattern-matching on these without naming the shape.)

## Why not `null`?

Most mainstream languages use a sentinel value, `null` in Java/Go,
`None` in Python (a single global value, not a constructor), `nil`
in Ruby, `undefined` in JavaScript, to mean "no value." This
*works*, but it has a quiet structural problem: the type of a
reference does not tell you whether `null` is a legitimate value.
In Java:

```
String name = lookup("alice");
System.out.println(name.length());
```

Compiles fine. Runs fine if `lookup` returns a real string. Crashes
with a `NullPointerException` if `lookup` returned `null` and the
programmer forgot to check.

Tony Hoare, who invented null references in 1965, calls them his
"[billion-dollar mistake](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare/)":
every null pointer exception in every Java codebase since 1995 is
a descendant of that decision. The problem is not that null
*exists*; it is that the type system does not distinguish
"reference that might be null" from "reference that is guaranteed
to be non-null." Every reference might secretly be `null`, and
every reader of the code has to remember to check.

OCaml's solution: there is no implicit `null`. If a function might
fail to return a value, its return type *says so*. Compare:

```
val lookup : string -> string         (* never fails, always returns a string *)
val lookup : string -> string option  (* might return None *)
```

:::slide

## Why not `null`?

- Many languages use `null` (Java, C, Go) or `undefined` (JavaScript) for "no value".
- Trouble: **every** reference might secretly be null.
- The type system doesn't tell you which.

```
String name = lookup("alice");
System.out.println(name.length());
```

- Compiles fine.
- Crashes at runtime if `lookup` returned `null`.

OCaml's `option`:

```
val lookup : string -> string option
```

- Type **tells** reader and compiler that the function may not return a value.
- No way to use the inner string without first inspecting for `None`.

:::

The shift from `null` to `option` is one of the everyday wins of
the OCaml type system. The compile-time cost is small: you have to
handle both cases explicitly. The runtime payoff is large: you
stop having `NullPointerException`s, `SegmentationFault`s, or
`TypeError: cannot read property of undefined` errors. The trade
is essentially always worth it.

Tony Hoare's "billion-dollar" remark is not hyperbole. Languages
designed since the 2010s, Rust, Swift, Kotlin, all default to
non-nullable references and require explicit opt-in for nullable
types. They are following ML's lead, which had `option` in the
1970s.

## Using an `option`

You inspect an option with pattern matching:

```ocaml
let describe = function
  | None -> "no value"
  | Some x -> "got " ^ string_of_int x

let _ = describe (Some 7)
let _ = describe None
```

The two clauses, one per constructor, give two answers. The compiler
checks that you have handled both cases, just as it would for any
other variant.

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

- Results: `"got 7"` and `"no value"`.
- Can't write `(Some 7) + 1`: that's adding `int option` to `int`, a type error.
- Must **unwrap** first:

```ocaml skip
match find_age "alice" with
| None -> 0
| Some n -> n + 1
```

- Either you handle the missing case, or it doesn't compile.

:::

The compiler refuses to let you "accidentally" treat an `option`
as a plain value. You cannot write `(Some 7) + 1` (the operator
`+` does not accept `int option`); you must explicitly destructure
the option first. That forced explicitness is the safety property.

## A safe division

The canonical example: division that does not crash on zero.

```ocaml
let safe_div a b =
  if b = 0 then None
  else Some (a / b)

let _ = safe_div 10 2
let _ = safe_div 10 0
```

The function returns `Some 5` for `safe_div 10 2`, `None` for
`safe_div 10 0`. The return type is `int option`. Any caller is
*forced* by the type system to handle the `None` case before they
can use the integer.

:::slide

## A safe division

```ocaml
let safe_div a b =
  if b = 0 then None
  else Some (a / b)

let _ = safe_div 10 2
let _ = safe_div 10 0
```

- Results: `Some 5` and `None`.
- Type: `int -> int -> int option`.
- Caller is **forced** to handle the divide-by-zero case explicitly.

Compare a C-style version returning `-1` on error:

- Callers might forget the check.
- Or mistake a legitimate `-1` result for the error code.

`option` makes the error case **unmistakable**.

:::

Contrast this with two other approaches:

1. *Return a sentinel* like `-1`. The caller might forget to check
   (especially in a chain of operations), or might genuinely
   compute a `-1` and confuse it with the error code. The
   sentinel-vs-real-value ambiguity is the heart of why sentinels
   are fragile.
2. *Throw an exception*. We will see exceptions in
   [Module 7](M07-L03-exceptions.html). They work, but they
   introduce a *non-local* control flow that the caller's type
   does not advertise. A caller can forget to catch the exception
   (especially in code that crosses module boundaries), and you
   get a runtime crash.

`option` is the type-driven middle ground: the function returns
normally in both cases, but the type forces the caller to inspect
the result before using it. This makes "what to do on failure" an
*explicit local decision* rather than a forgotten check or an
unhandled exception.

## Chained `option` access

When several option-returning operations are chained, nested
matches become verbose:

```ocaml
let lookup_age (_name : string) : int option = None  (* stub *)

let increment_age name =
  match lookup_age name with
  | None -> None
  | Some n -> Some (n + 1)
```

The pattern (return `None` if `None`; otherwise unwrap, transform,
re-wrap) is so common that the standard library has a helper:

```ocaml skip
let lookup_age (_name : string) : int option = None
let increment_age name =
  Option.map (fun n -> n + 1) (lookup_age name)
```

`Option.map f x` returns:

- `None` if `x` is `None`,
- `Some (f v)` if `x = Some v`.

:::slide

## Chained `option` access

Nested matches get verbose:

```ocaml
let lookup_age (_name : string) : int option = None
let increment_age name =
  match lookup_age name with
  | None -> None
  | Some n -> Some (n + 1)
```

Standard helper:

```ocaml skip
let increment_age name =
  Option.map (fun n -> n + 1) (lookup_age name)
```

- `Option.map f`: applies `f` to the value inside, or propagates `None`.
- `Stdlib.Option` also: `Option.bind`, `Option.get`, `Option.value` (with default).

:::

`Option.map` is the cleanest example of why `option` is more
useful than `null`: you can *operate on the optional value as if
it were present*, and the absence-of-value case is propagated for
you. When the wrapping gets deeper (several option-returning
calls in sequence), `Option.bind` chains them similarly. The
[monad-shaped APIs in Module 8](M08-L02-option-monad.html) are
this same pattern in fuller form.

Two other useful functions in `Stdlib.Option`:

- `Option.value : 'a option -> default:'a -> 'a` extracts the
  inner value or returns a default. `Option.value (Some 7) ~default:0`
  is `7`; `Option.value None ~default:0` is `0`.
- `Option.get : 'a option -> 'a` extracts the inner value or
  *raises an exception* if the value is `None`. Use with caution;
  most code prefers explicit handling.

## The `result` type

Sometimes `None` is not informative enough. If `parse_int` fails,
the caller might want to know *why*. For these cases, the standard
library has `result`:

```
type ('a, 'e) result =
  | Ok of 'a
  | Error of 'e
```

A `result` is either `Ok v` (success, carrying a value of type
`'a`) or `Error e` (failure, carrying a value of type `'e`,
typically an error message or structured error type).

```ocaml
let parse_int s =
  try Ok (int_of_string s)
  with Failure _ -> Error ("not an int: " ^ s)

let _ = parse_int "42"
let _ = parse_int "frog"
```

The function returns `Ok 42` for `"42"`, and `Error "not an int:
frog"` for `"frog"`. The caller inspects the result and acts
accordingly.

:::slide

## The `result` type

```
type ('a, 'e) result =
  | Ok of 'a
  | Error of 'e
```

- Like `option`, but the failure case **carries a value**.
- That value: error message, error code, structured error type.
- `Ok 42`: "success with value 42".
- `Error "out of memory"`: "failure with this reason".

```ocaml
let parse_int s =
  try Ok (int_of_string s)
  with Failure _ -> Error ("not an int: " ^ s)

let _ = parse_int "42"
let _ = parse_int "frog"
```

- Use `result` when callers need to know **why** it failed, not just *that* it failed.

:::

The choice between `option` and `result` is about what the caller
needs to know. If the only sensible response to failure is "use a
default" or "give up," `option` is enough. If the caller might
distinguish among kinds of failure ("user gave a bad input" vs
"the disk is full"), `result` lets you carry that information. The
[`result` monad in M08-L03](M08-L03-result-monad.html) returns to
this type with the `let*` sugar applied to error chains.

The `try ... with` syntax catches the exception `Failure _`
raised by `int_of_string`. We will cover exceptions properly in
[Module 7](M07-L03-exceptions.html); for now, read
`try Ok ... with Failure _ -> Error ...` as "do the thing; if it
raises, convert to `Error`."

## Type abbreviations

Quite separate from `option` and `result`, OCaml lets you give a
short name to an existing type. This is called a *type
abbreviation* (or *type synonym*).

```ocaml
type point = float * float
type points = point list
```

After these declarations, `point` and `float * float` are *the
same type*; the compiler treats them as interchangeable. The name
exists purely for readability. `points` is `point list`, which is
`(float * float) list`. Three names for the same type, depending
on what you want to emphasise at each call site.

```ocaml
type point = float * float
type points = point list
let origin : point = (0.0, 0.0)
let triangle : points = [(0.0, 0.0); (1.0, 0.0); (0.5, 1.0)]
```

:::slide

## Type abbreviations

Give a short name to a longer type:

```ocaml
type point = float * float
type points = point list
```

- `point` and `(float * float)` are the **same** type.
- `points` and `(float * float) list` are the same.
- Names exist purely for **readability**.

```ocaml
type point = float * float
type points = point list
let origin : point = (0.0, 0.0)
let triangle : points = [(0.0, 0.0); (1.0, 0.0); (0.5, 1.0)]
```

- Type signature documents intent.
- Compiler treats `point` and `float * float` interchangeably.

:::

Abbreviations are useful when:

- The underlying type is verbose: `string -> int -> int option`
  becomes more readable as `lookup` if you write `type lookup =
  string -> int -> int option`.
- The same compound type appears in many signatures, and you want
  to talk about it in one place.
- The name carries information beyond the structure: `type ms =
  int` and `type fps = int` are both `int`, but the names tell the
  reader (not the compiler!) which one is intended.

Abbreviations are *not* useful when you want type safety between
two structurally-identical concepts. Because `ms` and `fps` above
are the same type to the compiler, you can freely substitute one
for the other; the type system will not warn you. For real type
safety here, you need a [record](M04-L02-records.html) or a
[single-constructor variant](M04-L03-variants.html#constructors-with-payload)
(the *newtype* idiom). The cost of a real wrapper is one
allocation per value and one constructor name in every literal;
the benefit is the compiler catching `add_durations 30 60` when
30 is fps and 60 is ms.

## Abbreviation vs record: a choice

Both let you give a name to a compound type. The difference:

:::slide

## Abbreviation vs record

Both let you give a name to a compound type:

**Type abbreviation** (`type point = float * float`):

- Underlying representation **leaks**: `(1.0, 2.0)` and a `point` are the same.
- Field access is positional (`fst`, `snd`).

**Record** (`type point = { x : float; y : float }`):

- A *new* type.
- Construction requires the type name (or context).
- Access by field name.

- Records: nominally typed, self-documenting.
- Abbreviations: aliases.
- Use records for a **real new type**.
- Use abbreviations to **name** an existing type for readability.

:::

The rule of thumb: if you genuinely have a new abstraction (a
"point" is a *kind of thing*, not just a `float * float`), use a
record. If you are just sparing yourself from writing the long
form many times in signatures, use an abbreviation.

## Mini check

:::quiz mcq
What is the type of the following function?

```ocaml
let first_or zero xs =
  match xs with
  | [] -> zero
  | x :: _ -> x
```

- [ ] `int -> int list -> int`
- [x] `'a -> 'a list -> 'a`
- [ ] `'a -> 'b list -> 'a`
- [ ] `'a -> 'b list -> 'b`

**Why:** the function returns either `zero` (the first argument)
or `x` (the first list element). For both to have the same type,
`zero` and the list elements must be the same type. So the input
list is `'a list`, the default is `'a`, and the result is `'a`.
:::

:::quiz mcq
Given:

```ocaml
let lookup k xs =
  match List.assoc_opt k xs with
  | None -> "missing"
  | Some v -> v
```

What is the type of `lookup`?

- [x] `'a -> ('a * string) list -> string`
- [ ] `string -> ('a * 'b) list -> 'b`
- [ ] `'a -> ('a * 'b) list -> 'b`
- [ ] `string -> string list -> string`

**Why:** `List.assoc_opt` has type `'a -> ('a * 'b) list -> 'b
option`. Here the `None` branch returns the string `"missing"`,
forcing `'b = string`. So the function is `'a -> ('a * string)
list -> string`.
:::

:::quiz code
Write `find_first : ('a -> bool) -> 'a list -> 'a option` that
returns the first element of the list satisfying the predicate,
or `None` if none does.

```ocaml
let rec find_first pred xs =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (find_first (fun x -> x > 3) [1; 2; 3; 4; 5] = Some 4) "first > 3";
  check (find_first (fun x -> x > 100) [1; 2; 3] = None) "none";
  check (find_first (fun x -> x = 0) [0; 1; 2] = Some 0) "first match at head";
  check (find_first (fun _ -> true) [] = None) "empty";
  print_endline "all tests passed"
```
:::

Reference solution:

```ocaml
let rec find_first pred = function
  | [] -> None
  | x :: rest -> if pred x then Some x else find_first pred rest
```

A standard library equivalent already exists: `List.find_opt`.

## Activity

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

- Results: `Some 14` and `None`.

A common idiom for using it.

```ocaml
let safe_div a b = if b = 0 then None else Some (a / b)
let quotient =
  match safe_div 100 7 with
  | None -> 0  (* or: raise, or: log, or: ask the user *)
  | Some q -> q
```

- Compiler enforces **both** branches.
- Cannot pretend the `None` case won't happen.

:::

This is the everyday rhythm: a function that might fail returns an
`option`; the caller pattern-matches and decides what to do. The
type system does not let you forget.

## What's next

:::slide

## What's next

Lecture 6: the **tutorial** for Module 4. We design a small ADT
for a domain (a tiny JSON-like value type), implement a couple of
operations on it, and use everything from Module 4: records,
variants, recursion, `option`.

:::

We have collected the pieces. The
[next lecture](M04-L06-tutorial.html), the module tutorial,
builds something with them: a small algebraic data type for
JSON-like values, a few operations on it, and the experience of
writing OCaml's data-driven idioms end-to-end.

## Reading

- **Cornell CS3110**, *Options*:
  <https://cs3110.github.io/textbook/chapters/data/options.html>
- **Cornell CS3110**, *Type synonyms*:
  <https://cs3110.github.io/textbook/chapters/data/type_synonym.html>
- **Real World OCaml**, *Error handling*:
  <https://dev.realworldocaml.org/error-handling.html>
