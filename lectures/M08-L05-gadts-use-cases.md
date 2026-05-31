---
title: "GADTs: use cases beyond toy interpreters"
lecture_no: 5
week: 8
duration_target_min: 22
concepts: [type witnesses, typed pretty-printers, type-safe builders]
keywords: [OCaml, GADT, type witness, builder]
activity_question: "Reusing the lecture's [type _ ty] witness, write [default : type a. a ty -> a] that produces a default value for the witnessed type (0, the empty string, false, a pair of defaults, the empty list). This runs the witness the opposite direction from [show]."
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
<p class="title-slide-label">Module 8 &middot; Lecture 5</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The [toy expression-AST from the previous lecture](M08-L04-gadts-basics.html#the-gadt-form)
is the standard "first example" of GADTs. It is useful for showing
the mechanics, but it leaves a misleading impression: that GADTs
are mostly for interpreters. They are not. This lecture shows two
idioms you will see in real OCaml code where GADTs earn their keep:
typed pretty-printers and type-safe builders. Two further idioms,
heterogeneous lists and the machinery behind `printf`, are big
enough to get their own treatment in the
[next lecture](M08-L06-hlists-witnesses.html).

The common thread across all of these is *type witnesses*. Where
an ordinary value carries data, a witness is a value whose runtime
shape is uninteresting but whose *type* carries information the
program needs at compile time. GADTs are how OCaml encodes
witnesses naturally.

:::slide

## This lecture: GADTs in real code

- Last lecture's toy expression AST leaves a misleading
  impression: that GADTs are mostly for interpreters.
- They are not. Two idioms where GADTs earn their keep:
  - Typed pretty-printers.
  - Type-safe builders that prevent illegal states.
- Two more, big enough for their own lecture next time:
  heterogeneous lists and the GADT behind `printf`.
- Common thread: *type witnesses*. A value whose runtime shape
  is uninteresting; whose *type* carries information.
- GADTs are how OCaml encodes witnesses naturally.

:::

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

## Use 2: type-safe builders

A *builder* is an API that lets you construct a value piece by
piece, where the partially-built value has some type that changes
as you add pieces. GADTs let you keep the type of the partial
value sharp:

:::slide

## Use 2: type-safe builders

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

## Two more idioms, next lecture

Two further GADT idioms are common enough to deserve their own
treatment, and the [next lecture](M08-L06-hlists-witnesses.html)
develops both:

- *Heterogeneous lists*: a list whose elements have different
  types, each tracked at compile time, that you can still recurse
  over. The witness pattern from `show` generalises to drive
  operations across such a list.
- *Format strings and `Printf`*: the most famous hidden use of
  GADTs in OCaml. A format string like `"%d %s\n"` has a *type*
  that forces the following arguments to be `int` then `string`,
  checked at compile time. It is a witness list encoded inside the
  string literal.

Both build directly on the typed-witness idea above, which is why
they fit naturally after this lecture rather than inside it.

## Do I need a GADT here?

The [last lecture's guidance on when to reach for a
GADT](M08-L04-gadts-basics.html#when-to-reach-for-gadts) applies
to these use cases too: most code is better served by plain
[records](M04-L02-records.html) and
[variants](M04-L03-variants.html), and the sharp edges (locally
abstract types, explicit annotations, hostile error messages) are
the same. Before reaching for the heavier machinery, a short
checklist:

:::slide

## Do I need a GADT here?

- Do different cases need to carry *different* type information?
  (If no: ordinary variant.)
- Will the compiler reject an illegal construction *and* can I
  name a concrete bug class that this prevents? (If no: not worth
  the cost.)
- Am I building a small embedded language or a typed-witness API?
  (If yes: GADTs are likely the right tool.)
- Is the complexity proportional to the safety win? (Always check.)

:::

Most real OCaml code never needs GADTs. The small fraction that
does (typed DSLs, query builders, the format-string code in the
stdlib) uses them heavily and to great effect. We are in this
course to know when they are right; that is the goal, not to make
GADTs the default.

## A quick check

:::quiz mcq id=M08-L05-q3
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

:::quiz mcq id=M08-L05-q2
In the builder GADT, `Map (All, fun () -> 42)` has type
`int query`. Why does the compiler reject
`Where (Map (All, fun () -> 42), fun s -> s = "x")`?

- [x] `Map (...)` is an `int query`, so `Where`'s predicate must
  be `int -> bool`; `fun s -> s = "x"` is `string -> bool`, which
  does not match.
- [ ] `Where` cannot follow `Map`; the constructors must appear in
  a fixed order.
- [ ] `All` is not a valid starting point for a builder.
- [ ] Predicates are not allowed to use `=`.

**Why:** the type parameter of `query` tracks the *current*
element type. `Map (All, fun () -> 42)` maps `unit` to `int`, so
its type is `int query`. `Where`'s signature is `'a query * ('a ->
bool) -> 'a query`, so the predicate must accept the same `'a`,
here `int`. A `string -> bool` predicate fails to unify, and the
mistake is caught at compile time rather than at query execution.
:::

:::slide

## Activity

`show` *consumes* a value given its witness. Go the other way:
reusing the lecture's `ty`, write `default : type a. a ty -> a`
that *produces* a default value for the witnessed type: `0` for
`T_int`, `""` for `T_string`, `false` for `T_bool`, a pair of
defaults for `T_pair`, and `[]` for `T_list`.

:::

:::solution

:::slide

## Activity solution

```ocaml
let rec default : type a. a ty -> a = fun t ->
  match t with
  | T_int    -> 0
  | T_string -> ""
  | T_bool   -> false
  | T_pair (a, b) -> (default a, default b)
  | T_list _ -> []

let _ = default T_int                       (* = 0 *)
let _ = default (T_pair (T_int, T_string))  (* = (0, "") *)
```

- `default` runs the witness *backwards*: instead of reading a
  value it builds one, with the type fixed per case as in `show`.
- `T_list` ignores its element witness: the empty list has no
  element to default.

:::

:::

A code quiz:

:::quiz code id=M08-L05-q1
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

Lecture 6: **hlists and witnesses**.

- Heterogeneous lists: mixed element types you can recurse over.
- Driving operations across them with a list of witnesses.
- The witness list behind `Format.printf`.

:::

The [next lecture](M08-L06-hlists-witnesses.html) takes the
typed-witness idea from this lecture and pushes it to
heterogeneous lists and the GADT machinery behind `printf`. After
that, the [tutorial](M08-L07-tutorial.html) brings together the
monad pattern from
lectures [1](M08-L01-option-monad.html)-[3](M08-L03-state-monad.html)
and the GADT pattern from
lectures [4](M08-L04-gadts-basics.html)-[6](M08-L06-hlists-witnesses.html):
a small expression language whose AST is a GADT (so ill-typed
programs cannot be constructed), evaluated through an option monad
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
