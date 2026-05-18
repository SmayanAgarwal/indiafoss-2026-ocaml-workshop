---
title: "GADTs: use cases beyond toy interpreters"
lecture_no: 6
week: 8
duration_target_min: 22
concepts: [type witnesses, heterogeneous lists, type-safe APIs, printf-like format types]
keywords: [OCaml, GADT, type witness, hlist, format]
activity_question: "Define a GADT [type _ t] with [String_t : string t] and [Int_t : int t]. Write [convert : type a. a t -> a -> string] that pretty-prints the value."
think_about_this: "A GADT lets you write a function whose return type depends on the input *value* (not just the input type). Why is that more powerful than overloading or type classes?"
reading:
  - title: "Real World OCaml, More GADTs"
    url: https://dev.realworldocaml.org/gadts.html
---

# GADTs: use cases beyond toy interpreters

The toy interpreter from Lecture 5 is the canonical "first" GADT
example. This lecture shows three idioms you'll meet in real
OCaml code.

:::slide

## Use 1: typed pretty-printers

```ocaml
type _ ty =
  | T_int    : int ty
  | T_string : string ty
  | T_bool   : bool ty
  | T_pair   : 'a ty * 'b ty -> ('a * 'b) ty
  | T_list   : 'a ty -> 'a list ty

let rec show : type a. a ty -> a -> string = fun t v ->
  match t with
  | T_int    -> string_of_int v
  | T_string -> "\"" ^ v ^ "\""
  | T_bool   -> string_of_bool v
  | T_pair (a, b) ->
      let (x, y) = v in
      "(" ^ show a x ^ ", " ^ show b y ^ ")"
  | T_list t' ->
      "[" ^ String.concat "; " (List.map (show t') v) ^ "]"

let _ = show T_int 42
let _ = show (T_pair (T_int, T_string)) (3, "hi")
let _ = show (T_list T_int) [1; 2; 3]
```

`"42"`, `"(3, \"hi\")"`, `"[1; 2; 3]"`.

`ty` is a *witness* of the OCaml type of a value: `T_int` is the
witness for `int`, `T_pair (a, b)` is the witness for `'a * 'b`,
etc. The `show` function takes a witness and a value of the type
that witness describes. Each case refines the type and unpacks the
value accordingly.

Without GADTs, you couldn't write a single function whose return
type depends on the constructor of the type-witness argument. With
GADTs, the compiler ties the pieces together.

:::

:::slide

## Use 2: heterogeneous lists

A list whose elements have *different* types, each tracked at
compile time:

```ocaml
type _ hlist =
  | HNil  : unit hlist
  | HCons : 'a * 'rest hlist -> ('a * 'rest) hlist

let example : (int * (string * (bool * unit))) hlist =
  HCons (42, HCons ("hi", HCons (true, HNil)))
```

The type tells you the exact tuple-shape of the list: an `int`, a
`string`, a `bool`. Pattern matching can destructure each piece
with the correct type:

```ocaml
type _ hlist =
  | HNil  : unit hlist
  | HCons : 'a * 'rest hlist -> ('a * 'rest) hlist

let example : (int * (string * (bool * unit))) hlist =
  HCons (42, HCons ("hi", HCons (true, HNil)))

let first : type a r. (a * r) hlist -> a = function
  | HCons (x, _) -> x

let _ = first example
```

`int = 42`. The compiler knows that the first element of `example`
is an `int`, so `first example` has type `int` without a cast.

This is what `tuple<...>` in C++ or `Tuple` types in some
functional languages do; in OCaml it's an explicit GADT.

:::

:::slide

## Use 3: type-safe builders

Building up something piece by piece where the *type* of the
partial value changes as you add pieces. Classic example: a
typed query / DSL.

```ocaml
type _ query =
  | All        : unit query
  | Where      : 'a query * ('a -> bool) -> 'a query
  | Map        : 'a query * ('a -> 'b) -> 'b query

let _ : int query =
  Where (Map (All, fun () -> 42), fun n -> n > 0)
```

Each builder step refines the type, and the next step's expected
input type is fixed by the previous. You can't `Where`-filter by
a predicate that expects the wrong type; it's a type error at
build time.

:::

:::slide

## Use 4: format strings

OCaml's `Printf.printf` is implemented with a GADT. The format
string `"%d %s\n"` has a *type* that encodes "this format takes an
`int`, then a `string`, then prints":

```
val printf : ('a, out_channel, unit) format -> 'a
```

When you call `Printf.printf "%d %s\n" 42 "hello"`, the format
type forces the next argument to be `int`, the one after to be
`string`. Calling `printf "%d %s\n" "wrong" 42` is a type error.

You won't write `printf`'s format type machinery yourself; it's
built into the standard library. But you'll feel its safety every
time you use it: typed format strings, courtesy of GADTs.

:::

:::slide

## When GADTs *don't* help

For:

- Modelling business data (just use records and variants).
- Configuring options (a record is fine).
- Most parsing tasks (a regular ADT + interpreter is fine).
- Code that's exhausted by simple types.

GADTs are tools for code that *needs* the type system to do real
work. If the existing variants + records do the job, prefer them.
The GADT toolchain is more involved (locally abstract types,
explicit annotations) and worth pulling out when you genuinely
have heterogeneous typed data flowing through.

:::

:::slide

## Activity

Define a GADT `type _ t` with `String_t : string t` and `Int_t :
int t`. Write `convert : type a. a t -> a -> string` that
pretty-prints the value of the given type.

:::

:::slide

## Activity solution

```ocaml
type _ t =
  | String_t : string t
  | Int_t    : int t

let convert : type a. a t -> a -> string = fun t v ->
  match t with
  | String_t -> "\"" ^ v ^ "\""
  | Int_t    -> string_of_int v

let _ = convert Int_t 42
let _ = convert String_t "hello"
```

`"42"`, `"\"hello\""`.

The function's return type is `string`, but the *input* value's
type depends on the witness. With `String_t`, `v : string`; with
`Int_t`, `v : int`. The compiler refines `a` per case.

Without GADTs you'd write two functions (one for each type) or
take an `option` of either and hand-code the dispatch. GADTs let
one function do both with the type guarantee.

:::

:::slide

## What's next

Lecture 7: the Module 8 **tutorial**. We pull together the option
monad, GADTs, and pattern matching to build a small well-typed
expression evaluator. The capstone for the OCaml half of the
course.

:::

## Reading

- **Real World OCaml**, *More GADTs*:
  <https://dev.realworldocaml.org/gadts.html>
