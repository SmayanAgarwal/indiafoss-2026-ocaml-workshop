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


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">GADTs: use cases beyond toy interpreters</h2>
<p class="title-slide-label">Module 8 &middot; Lecture 6</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The [toy expression-AST from Lecture 5](M08-L05-gadts-basics.html#the-gadt-form)
is the standard "first example" of GADTs. It is useful for showing
the mechanics, but it leaves a misleading impression: that GADTs
are mostly for interpreters. They are not. This lecture shows four
idioms you will see in real OCaml code where GADTs earn their keep.

The common thread across all four is *type witnesses*. Where an
ordinary value carries data, a witness is a value whose runtime
shape is uninteresting but whose *type* carries information the
program needs at compile time. GADTs are how OCaml encodes
witnesses naturally.

## Use 1: typed pretty-printers

Suppose you want one function `show` that pretty-prints any value
whose type you know at compile time. With
[ordinary variants](M04-L03-variants.html) you would write a
separate `show_int`, `show_string`, `show_list`, and so on. With a
GADT *witness* of OCaml types, you can have one `show`:

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
```

- `'a ty` is a *witness* for OCaml type `'a`.
- `show t v` takes a witness and a value of the type it witnesses.

:::

:::slide

## Using the typed pretty-printer

```ocaml
let _ = show T_int 42
let _ = show (T_pair (T_int, T_string)) (3, "hi")
let _ = show (T_list T_int) [1; 2; 3]
```

`"42"`, `"(3, \"hi\")"`, `"[1; 2; 3]"`. Each case of `show`
refines the type and unpacks the value accordingly.

:::

Read the GADT carefully. A value of type `int ty` is a witness for
the OCaml type `int`. The only such value is `T_int`. A value of
type `string ty` witnesses `string`, and the only such value is
`T_string`. Compound types get compound witnesses: `T_pair (a,
b) : ('a * 'b) ty` is built out of sub-witnesses `a : 'a ty` and
`b : 'b ty`.

The function `show` takes a witness `t : 'a ty` plus a value `v :
'a`. The key trick: when we pattern-match on `t`, each case refines
`'a` to the specific concrete type the constructor witnesses. In
the `T_int` case, `'a = int`, so `v : int`, and we can call
`string_of_int v`. In the `T_pair (a, b)` case, `'a = 'b * 'c` for
some types `'b` and `'c` that match the sub-witnesses, so we can
destructure `v` as a pair and recursively show each side.

Without GADTs, no single function could have its parameter type
depend on the value of an earlier argument. The first argument's
*value* (which constructor of `ty`) determines the second
argument's *type*. That dependency is what GADTs encode.

This pattern is used heavily in serialisation libraries and
[`type-conv`-style](https://github.com/janestreet/ppx_jane)
deriving infrastructure: you derive a value of type `'a ty` for
your record type, then use it to serialise, deserialise, generate
test cases, or print values, all without writing the code by hand.

## Use 2: heterogeneous lists

A list whose elements have *different* types, each tracked at
compile time:

:::slide

## Use 2: heterogeneous lists

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

`int = 42`. The type `(int * (string * (bool * unit))) hlist`
spells out the sequence of element types; pattern matching
destructures with the right type per slot.

:::

A heterogeneous list (often `hlist`) is a list where each element
can have a different type, and the type system tracks the
*sequence* of types. The type `(int * (string * (bool * unit)))
hlist` says "this list has an `int`, then a `string`, then a
`bool`, then nothing".

The constructor `HCons : 'a * 'rest hlist -> ('a * 'rest) hlist`
is the workhorse: it takes a head of any type `'a` and a tail of
type `'rest hlist`, producing a list whose type is `('a * 'rest)
hlist`. The encoding uses tuples in the type to record the
sequence; you could equally use a list-in-the-type structure with
some other notation.

Why would you want this? When you have a *fixed-shape but
heterogeneous* collection, an ordinary [list](M04-L04-recursive-types.html)
`'a list` cannot encode it (the elements must all share `'a`).
[Tuples](M04-L01-tuples.html) work for small fixed shapes
(`(int, string, bool)` for three) but do not generalise to
"n elements with given types". Heterogeneous lists are the OCaml
answer: a type-level encoding of "list with these exact element
types".

You see this in the implementation of typed printf (next use case),
in some database libraries that map tuple types to column types,
and in type-safe builder APIs.

## Use 3: type-safe builders

A *builder* is an API that lets you construct a value piece by
piece, where the partially-built value has some type that changes
as you add pieces. GADTs let you keep the type of the partial
value sharp:

:::slide

## Use 3: type-safe builders

```ocaml
type _ query =
  | All        : unit query
  | Where      : 'a query * ('a -> bool) -> 'a query
  | Map        : 'a query * ('a -> 'b) -> 'b query

let _ : int query =
  Where (Map (All, fun () -> 42), fun n -> n > 0)
```

- Each builder step refines the type.
- The next step's expected input type is fixed by the previous.
- A `Where` filter expecting the wrong type is a compile-time error.

:::

Reading the constructors: `All` is the trivial unit query. `Map (q,
f)` takes a query producing `'a` and a function `f : 'a -> 'b`,
giving a query producing `'b`. `Where (q, p)` keeps a query
producing `'a` and a predicate `'a -> bool`, giving a query still
producing `'a`. The composition `Where (Map (All, fun () -> 42),
fun n -> n > 0)` chains them: start from `unit`, map to `int`,
filter the `int`s, giving `int query` overall.

The type tracks the *current* element type of the query. If you
try to `Where`-filter an `int query` with a predicate that expects
a string, the compiler refuses: the predicate's type does not
match the query's element type. Bugs that would otherwise hide in
the dynamic SQL generation become compile errors.

Several real OCaml libraries are built on this style: query
builders, configuration DSLs, and parser combinators all use type
parameters that change as you compose pieces, with GADTs ensuring
the composition is type-safe.

## Use 4: format strings (and Printf)

The most famous use of GADTs in OCaml is hidden: it is the
machinery behind [`Printf`](https://v2.ocaml.org/api/Printf.html).
A format string like `"%d %s\n"` has a *type* that encodes which
arguments must follow:

:::slide

## Use 4: format strings

- `Printf.printf` is implemented with a GADT.
- The format string `"%d %s\n"` has a *type*.
- That type encodes "this format takes an `int`, then a `string`,
  then prints":

```
val printf : ('a, out_channel, unit) format -> 'a
```

- `Printf.printf "%d %s\n" 42 "hello"`: the format type forces the
  next argument to be `int`, then `string`.
- `Printf.printf "%d %s\n" "wrong" 42` is a type error.
- You will not write `printf`'s format type machinery yourself;
  the stdlib provides it.
- You feel its safety on every use: typed format strings via GADTs.

:::

The format-string type in OCaml is `('a, 'b, 'c) format`, and the
GADT machinery inside `printf` decodes the format string at
*compile time* into a function type that pinpoints what arguments
are required. So `printf "%d\n"` has type `int -> unit` and
`printf "%d %s\n"` has type `int -> string -> unit`. Pass the
wrong type and the compiler complains; pass too few arguments and
the call type-checks but produces a partially-applied function.

This is the polished version of the "type-safe builder" idea above:
the GADT machinery tracks state (which format specifiers remain
unprocessed) and the resulting function's type reflects that state.
You will use it constantly; you will not write the machinery
yourself.

## When GADTs do not help

For everyday OCaml code, GADTs are usually the wrong hammer.
[Records](M04-L02-records.html) and
[variants](M04-L03-variants.html) cover most needs:

:::slide

## When GADTs do not help

Prefer plain types for:

- Business data: records and variants.
- Configuration: a record.
- Most parsing: regular ADT plus interpreter.
- Anything well-served by simple types.

**Sharp edges of GADTs:**

- Locally abstract types.
- Explicit annotations.
- Sometimes-hostile error messages.

Reach for GADTs only when heterogeneous typed data must flow
through one function.

:::

A short checklist of "do I need a GADT here?":

- Do different cases need to carry *different* type information?
  (If no: ordinary variant.)
- Will the compiler reject an illegal construction *and* I can
  show a concrete bug class that this prevents? (If no: not worth
  the cost.)
- Am I building a small embedded language or a typed-witness API?
  (If yes: GADTs are likely the right tool.)
- Is the complexity proportional to the safety win? (Always check.)

Most real OCaml code never needs GADTs. The small fraction that
does (typed DSLs, query builders, the format-string code in the
stdlib) uses them heavily and to great effect. We are in this
course to know when they are right; that is the goal, not to make
GADTs the default.

## A quick check

:::quiz mcq id=M08-L06-q3
In the `show` function with a GADT witness, why does
`show (T_pair (T_int, T_string)) (3, "hi")` type-check while
`show T_int (3, "hi")` does not?

- [ ] The pair `(3, "hi")` is illegal in OCaml.
- [x] The first call refines `'a = int * string`, matching the
  pair's actual type; the second call refines `'a = int`, but `(3,
  "hi") : int * string`, which does not match `int`.
- [ ] `show` cannot handle tuples.
- [ ] `T_int` is not a valid value.

**Why:** the witness in the first argument determines the type
the second argument must have. `T_pair (T_int, T_string) : (int *
string) ty`, so the second argument must be `int * string`. `T_int
: int ty`, so the second argument must be `int`. The pair does
not match `int`, hence the type error in the second case.
:::

:::quiz mcq id=M08-L06-q2
Why is a heterogeneous list (`'a hlist`) different from a tuple
like `int * string * bool`?

- [x] An `hlist` is built and pattern-matched constructor by
  constructor, so it composes recursively; a tuple is a flat fixed
  shape.
- [ ] `hlist`s are mutable; tuples are not.
- [ ] `hlist`s have a single uniform element type, like an
  ordinary list.
- [ ] There is no difference; one is just an alias for the other.

**Why:** an `hlist` is structurally a chain of `HCons` cells with
`HNil` at the end, like an ordinary list, but each cell can carry
a different element type tracked at the type level. You can write
recursive functions over an `hlist`; you cannot recurse over a
tuple. That recursion is the whole reason for the encoding.
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

- `convert`'s return type is always `string`.
- The *input* value's type depends on the witness.
- With `String_t`, `v : string`; with `Int_t`, `v : int`.
- The compiler refines `a` per case.
- Without GADTs you would write two functions (one per type) or
  hand-code dispatch on an `option`.

:::

A code quiz:

:::quiz code id=M08-L06-q1
Extend the witness GADT with a `Bool_t : bool t` constructor and
write `convert3 : type a. a t -> a -> string` that handles all
three.

```ocaml
type _ t =
  | String_t : string t
  | Int_t    : int t
  | Bool_t   : bool t

let convert3 : type a. a t -> a -> string = fun t _ ->
  match t with
  | String_t -> failwith "not implemented"
  | Int_t    -> failwith "not implemented"
  | Bool_t   -> failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (convert3 Int_t 42 = "42") "int";
  check (convert3 String_t "hi" = "\"hi\"") "string";
  check (convert3 Bool_t true = "true") "bool true";
  check (convert3 Bool_t false = "false") "bool false";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let convert3 : type a. a t -> a -> string = fun t v ->
  match t with
  | String_t -> "\"" ^ v ^ "\""
  | Int_t    -> string_of_int v
  | Bool_t   -> string_of_bool v
```

The compiler refines `a` per branch. In the `Bool_t` case, `a =
bool`, so `v : bool`, and `string_of_bool v` produces the right
output.

:::

## What is next

:::slide

## What is next

Lecture 7: the Module 8 **tutorial**.

- We combine the option monad, GADTs, and pattern matching.
- Build a tiny well-typed expression evaluator.
- Capstone for the OCaml half of the course.

:::

The [tutorial in lecture 7](M08-L07-tutorial.html) brings together
the monad pattern from
lectures [1](M08-L01-sequencing.html)-[4](M08-L04-state-monad.html)
and the GADT pattern from
lectures [5](M08-L05-gadts-basics.html)-[6](M08-L06-gadts-use-cases.html).
We build a small
expression language whose AST is a GADT (so ill-typed programs
cannot be constructed), and an evaluator that returns `'a option`
(so runtime failures like division-by-zero short-circuit cleanly).

## Reading

- **Real World OCaml**, *More GADTs*:
  <https://dev.realworldocaml.org/gadts.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
