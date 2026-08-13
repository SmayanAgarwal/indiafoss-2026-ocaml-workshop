---
title: "Tuples, Records, Variants, Recursive Types"
lecture_no: 1
week: 4
duration_target_min: 118
concepts: [tuples, product types, pair, fst, snd, destructuring, tuple patterns, records, named fields, record types, functional update, dot access, variants, sum types, constructors, payloads, parameterised variants, recursive types, list, tree, ADT, expression trees, structural induction, worked ADT design, recursive variants, abstract syntax, AST]
keywords: [OCaml, tuple, pair, product type, destructuring, record, named fields, record type, functional update, variant, sum type, constructor, ADT, algebraic data type, recursive types, list, tree, expression, AST, abstract syntax tree, recursive variant, tutorial]
reading:
  - title: "Cornell CS3110, Records and Tuples"
    url: https://cs3110.github.io/textbook/chapters/data/records_tuples.html
  - title: "Real World OCaml, Lists and Patterns"
    url: https://dev.realworldocaml.org/lists-and-patterns.html
  - title: "Real World OCaml, Records"
    url: https://dev.realworldocaml.org/records.html
  - title: "Cornell CS3110, Variants"
    url: https://cs3110.github.io/textbook/chapters/data/variants.html
  - title: "Cornell CS3110, Algebraic data types"
    url: https://cs3110.github.io/textbook/chapters/data/algebraic_data_types.html
  - title: "Real World OCaml, Variants"
    url: https://dev.realworldocaml.org/variants.html
  - title: "Cornell CS3110, Lists"
    url: https://cs3110.github.io/textbook/chapters/data/lists.html
  - title: "Cornell CS3110, Trees"
    url: https://cs3110.github.io/textbook/chapters/data/trees.html
---

# Module 4: Data Types

:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Fun and Profit with OCaml</p>
<h2 class="title-slide-lecture">Module 4: Data Types</h2>
<p class="title-slide-instructor">FP Launchpad<br>IIT Madras</p>
</div>

:::

So far we have moved single values around: `int`s, `string`s,
`bool`s, one at a time. Real programs deal with *aggregates*. This
module is about the three building blocks OCaml gives you for
*every* data type, plus the one idea (self-reference) that lets
those building blocks describe data of unbounded size.

:::slide

## The plan for this module

- **[Tuples](#tuples)** — bundle values by *position*, e.g.
  `(3, "hi")`. 
- **[Records](#records)** — bundle values by *name*, e.g.
  `{x = 3; y = 4}`. 
- **[Variants](#variants)** — "one of several shapes", e.g.
  `Some 3` vs `None`. 
- **[Recursive types](#recursive-types)** — types that refer to
  themselves: lists, trees.

:::

## Tuples

A *tuple* bundles several values together, by position.
`(3, "hello")` is a tuple of *arity* (size) two — "arity" is
borrowed from logic, where it names the number of arguments a
relation takes.

:::slide

### A tuple is several values bundled

Put several expressions inside parentheses, separated by commas.

```ocaml
let pair    = (3, true)
let triple  = (1, "two", 3.0)
```

- `pair : int * bool`
- `triple : int * string * float`
- `*` in a type reads as "and" (`int * bool` is "an `int` *and* a `bool`") —
  a *product type*, and a different thing from the `*` in `3 * 4`.

:::

OCaml tuples differ from Python tuples or JavaScript arrays in one
important way: the arity is encoded into the type itself. A pair
and a triple aren't "tuples of different lengths" — they're
different types outright, and the compiler checks this before your
code ever runs.

:::slide

### Fixed arity is part of the type

```ocaml
let _ : int * int       = (1, 2)
let _ : int * int * int = (1, 2, 3)
```

These are *different types*. An `int * int * int` cannot be used
where an `int * int` is expected — the compiler rejects it:

```ocaml skip
let _ : int * int = (1, 2, 3)
```

- *Arity* = number of components a tuple carries.
- Contrast Python: 2-tuples and 3-tuples are both just `tuple`. OCaml
  tuples are for *small, fixed* groups; when the size varies, use a list.

:::

Building a tuple is just the literal syntax already shown —
parentheses and commas. Getting values back out is where OCaml
gives you two different tools, depending on how many components
you're pulling apart.

:::slide

### Extracting: `fst`/`snd`, or destructure

For pairs, the standard library gives you `fst` and `snd`:

```ocaml
let p = (10, 20)
let _ = fst p  (* = 10 *)
let _ = snd p  (* = 20 *)
```

`fst : 'a * 'b -> 'a` and `snd : 'a * 'b -> 'b` work on any pair,
but only pairs — there is no `third`. For triples and larger,
*destructure* instead:

```ocaml
let (x, y, z) = (1, 2, 3)
let _ = x  (* = 1 *)
```

- `(x, y, z)` is a **pattern**: binds one name per component.
- `_` ignores a component: `let (x, _, _) = (1, "two", 3.0)`.

:::

Patterns aren't limited to `let` bindings — they show up anywhere a
value gets bound, including function parameters, where a pattern
destructures its argument the moment the function is called.

:::slide

### Patterns in function arguments

Patterns work in function parameters too:

```ocaml
let distance (x1, y1) (x2, y2) =
  sqrt ((x2 -. x1) ** 2.0 +. (y2 -. y1) ** 2.0)

let _ = distance (0.0, 0.0) (3.0, 4.0)  (* = 5. *)
```

- Each parameter is a *pattern* `(x1, y1)`.
- `distance` takes *two* pair-shaped arguments — inferred type
  `float * float -> float * float -> float`.

:::

An important detail hides in that last example: `distance` takes
*two* arguments, each of which happens to be a pair — it is not one
function taking a single four-tuple. That distinction, several
curried arguments versus one tupled argument, is the single most
common point of confusion for programmers arriving from C-family
languages.

:::slide

### Argument list vs tuple

A common confusion for students from C-family languages:

```ocaml
let add_curried x y    = x + y
let add_tupled (x, y)  = x + y
```

- `add_curried : int -> int -> int`. Two arguments, partially applicable.
- `add_tupled  : int * int -> int`. One argument: a pair.
- Prefer curried by default; tuple only when values **belong together**.

:::

Idiomatic OCaml leans curried by default, since curried functions
support partial application and fit the higher-order style Module 6
builds on. Save tuple arguments for cases where the values
genuinely form one conceptual unit — a coordinate pair, a
key-value entry — not for "a function of several arguments" in
general.

:::slide

### Returning multiple values

OCaml functions return *one* value, but that value can be a tuple:

```ocaml
let divmod a b = (a / b, a mod b)
let (q, r) = divmod 17 5
```

This is the OCaml idiom for multiple return values — the caller destructures.

:::

You'll often see *lists of tuples*, each tuple a "row":

```ocaml
let pairs = [(1, "one"); (2, "two")]
```

The type is `(int * string) list`. Building a table like this is
immediately possible; searching it by key needs pattern matching,
which Module 5 covers — the standard library's `List.assoc_opt`
becomes available once you know `option` and patterns.

:::quiz mcq id=M04-L01-q3
What is the type of the function below?

```ocaml
let swap (x, y) = (y, x)
```

- [ ] `'a -> 'a -> 'a * 'a`
- [x] `'a * 'b -> 'b * 'a`
- [ ] `'a * 'a -> 'a * 'a`
- [ ] `'a -> 'b -> 'b * 'a`

**Why:** `swap` takes *one* argument, a pair, and returns the
components swapped. The two components can have *different* types,
so the answer is `'a * 'b -> 'b * 'a`.
:::

:::quiz code id=M04-L01-q1
Write `pair_max : int * int -> int` that returns the larger of the
two components.

```ocaml
let pair_max p =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (pair_max (3, 7) = 7) "3,7";
  check (pair_max (10, 2) = 10) "10,2";
  check (pair_max (5, 5) = 5) "equal";
  check (pair_max (-1, -8) = -1) "negative";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution: `let pair_max (x, y) = if x > y then x else y`.

:::

Next: **records**. Same idea as tuples, but components have
*names* — clearer once your bundle has more than a couple of things.

## Records

A record is a bundle, like a tuple, but with each component
identified by *name* instead of position. It plays the same role as
a C `struct` or a Java data class, except:

- *Immutable* by default.
- *Structurally* compared, like an `int` or a `string`.

Both of those make a record behave more like a value — an `int`, a
`string` — than like an object.

:::slide

### Declaring a record type

Unlike tuples, records require a *type declaration* before you can
construct one — declare the type first, then construct values.

```ocaml
type point = { x : float; y : float }

let origin = { x = 0.0; y = 0.0 }
let p      = { x = 3.0; y = 4.0 }
```

- `point` is a type; `origin` and `p` are values of type `point`.
- Construction: braces, `field = value`, `;` between fields.
- Field order in a literal doesn't matter.

:::

Fields use `;` (not `,`) in both the type and the value; the type
uses `:`, the value uses `=`. Records are also *nominally* typed:
`type a = { x : int }` and `type b = { x : int }` are not
interchangeable despite the identical shape — the opposite of
TypeScript's structural object types.

:::slide

### Accessing fields: dot or destructure

Two ways to pull data out of a record: *dot syntax*, and *destructuring*.

```ocaml
type point = { x : float; y : float }
let p = { x = 3.0; y = 4.0 }
let _ = p.x  (* = 3. *)
let { x; y } = p
```

- Dot syntax: `p.x`. The name after `.` must be a literal field
  name (no `p.(expr)`).
- Destructuring: `let { x; y } = p` binds `x` and `y`; sugar for
  `{ x = x; y = y }`.

:::

Destructuring matches JavaScript's `const { x, y } = p;`. You can
rename fields while destructuring:

```ocaml
type point = { x : float; y : float }
let p = { x = 3.0; y = 4.0 }
let { x = ax; y = ay } = p
```

:::slide

### Records in function parameters

A function taking a record can use either style.

```ocaml
type point = { x : float; y : float }

let distance p q =
  let dx = q.x -. p.x in
  let dy = q.y -. p.y in
  sqrt (dx *. dx +. dy *. dy)

let _ = distance { x = 0.0; y = 0.0 } { x = 3.0; y = 4.0 }  (* = 5. *)
```

- Dot syntax: fields accessed at the call site (`p.x`, `q.y`).
- Or destructure in the parameter list: `let distance { x = x1; y
  = y1 } { x = x2; y = y2 } = ...` — common when the body uses
  every field.
- No functional difference; pick whichever reads better.

:::

There is no functional difference between the two styles — the
destructuring form is denser at the top of the function and looser
in the body, the dot-syntax form is the reverse. For a function
that touches two or three fields of a larger record, dot syntax
tends to read more cleanly; for one that uses every field,
destructuring usually wins.

:::slide

### Functional update

Records are immutable. To "modify" a field, you build a *new*
record that differs in just that field:

```ocaml
type point = { x : float; y : float }
let p = { x = 3.0; y = 4.0 }
let p2 = { p with y = 10.0 }
let _ = p.y   (* = 4. *)
let _ = p2.y  (* = 10. *)
```

- `with` produces a *new* record, identical to `p` except `y = 10.0`.
- `p` is **unchanged** — the immutable equivalent of "mutate this field".

:::

This buys *equational reasoning*: nothing later in the program can
have changed `p.y` underneath you. `with` matters most for wide
records, where rewriting every field to change one would be silly.

:::slide

### Records vs tuples: when to use which

Use a **record** when:

- More than three fields.
- Fields have meaningful names (`first_name`, `phone`).
- Positions are *not* self-evident (rectangle corners).
- You want functional update of a few fields (`with`).

Use a **tuple** when:

- Two or three components; positions *are* self-evident.
- Short-lived (destructure right after building).

:::

The same argument shows up elsewhere: `("Alice", "Smith", 30,
"alice@example.com")` leaves you guessing which `string` is the
email, while a record names each field at every access site.


No `equals()` to write, no `hashCode()` to keep consistent with it.

This rarely surfaces in practice; fix with an annotation if it does:
`let p : point2 = { x = 1.0; y = 2.0 }`. OCaml records can also
have `mutable` fields ([Module
7](M07-L02-arrays-and-mutation.html#mutable-record-fields)), but
for now every record is immutable and `{ p with ... }` is how you
"change" a field.

:::quiz mcq id=M04-L02-q2
Given:

```ocaml
type rgb = { r : int; g : int; b : int }
let red = { r = 255; g = 0; b = 0 }
```

What does `{ red with g = 128 }` evaluate to?

- [ ] `{ r = 0; g = 128; b = 0 }`
- [x] `{ r = 255; g = 128; b = 0 }`
- [ ] `{ r = 255; g = 0; b = 0 }` (and `red.g` becomes 128)
- [ ] A type error.

**Why:** `with` copies `red`'s fields and overrides `g`; `red`
itself is unchanged.
:::

:::quiz code id=M04-L02-q1
Define a record `circle` with fields `cx : float`, `cy : float`,
`radius : float`, and write a function `circle_area : circle ->
float` that returns the area. Use `Float.pi`.

```ocaml
type circle = { cx : float; cy : float; radius : float }

let circle_area c =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let approx_eq a b = abs_float (a -. b) < 1e-6
let () =
  check (approx_eq (circle_area { cx = 0.0; cy = 0.0; radius = 1.0 }) Float.pi) "unit";
  check (approx_eq (circle_area { cx = 5.0; cy = 5.0; radius = 2.0 }) (4.0 *. Float.pi)) "r=2";
  check (approx_eq (circle_area { cx = 0.0; cy = 0.0; radius = 0.0 }) 0.0) "zero";
  print_endline "all tests passed"
```

:::

:::solution

Reference solution: `let circle_area c = Float.pi *. c.radius *.
c.radius` (or destructure: `let circle_area { radius; _ } = ...`).

:::

Next: **variants** (also called sum types or tagged unions).
Records are "this *and* that". Variants are "this *or* that". The
combination of records and variants is how you model real data in
OCaml.

## Variants

[Tuples](#tuples) and [records](#records)
express *and*. Variants express *or*: a `shape` is a circle *or* a
square *or* a rectangle. Also called a *sum type*, *disjoint
union*, or *tagged union* — all names for the same idea.

:::slide

### Product types vs. sum types

- [Tuples](#tuples) and
  [records](#records) are **product types**: AND.
  - A `point` has an `x` *and* a `y`.
  - A `person` has a `name` *and* an `age` *and* an `email`.
- **Variants** are **sum types**: OR.
  - A `shape` is a `Circle` *or* a `Square` *or* a `Rectangle`.
  - A parse result is `Ok` *or* `Error`.
- Like a C / Java `enum`, but each alternative can carry data.
- Most useful data types combine both: variants for the *kinds*,
  records / tuples for the data inside each kind.

:::

Variants resemble C and Java enumerations, but they go further by
letting each alternative carry data of its own. The simplest case,
though, carries no data at all — just plain named alternatives.

:::slide

### Declaring a variant: the enum case

The simplest variant has alternatives that carry no data:

```ocaml
type direction = North | South | East | West

let d = North
```

- Four *constructors*, separated by `|` — a `direction` value holds
  *exactly one* of the four, the OCaml equivalent of an `enum`.
- Constructors are **capitalized**: OCaml tells a constructor from a
  variable by the first character alone.

:::

There is no implicit numeric encoding. If you want a mapping to
ints, write a function — [Module 5](M05-L01-basic-patterns.html)
covers `match`, the tidy way to do it.

:::slide

### Combining variants and records: a shirt

Domains often have more than one axis of choice. A shirt has a
*size* and a *color*: each axis is a small enum variant, and the
shirt itself is a record bundling both.

```ocaml
type size  = Small | Medium | Large
type color = Red | Blue | Green

type shirt = { size : size; color : color }

let my_shirt = { size = Medium; color = Blue }
```

:::

This pattern — variants for the axes of choice, records for
bundling them — is the everyday shape of Module 4 data. But
enum-style variants and record-bundling only get you so far;
variants become genuinely more expressive once a constructor is
allowed to carry its own data, not just a bare tag.

:::slide

### Constructors with payload

Variants get interesting when constructors carry data. Each `of
TYPE` clause says what the constructor carries: a `Circle` carries
its radius, a `Rectangle` carries width and height.

```ocaml
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float

let c = Circle 3.0
let s = Square 5.0
let r = Rectangle (4.0, 6.0)
```

- `Circle of float`: radius. `Square of float`: side. `Rectangle of
  float * float`: width, height.
- All three are values of type `shape` — the constructor says
  *which kind*; the payload is the data for that kind.

:::

A constructor is *applied* by juxtaposition, like a function call
without parentheses. `Rectangle` takes *one* argument, a pair, so
`Rectangle (4.0, 6.0)` needs the parens — never `Rectangle w h`.

To *use* a variant we inspect which constructor was used and bind
its payload — that's *pattern matching*, the subject of
[Module 5](M05-L01-basic-patterns.html). It brings compiler-checked
**exhaustiveness**: a warning if your code forgets a case.

:::slide

### Constructors with multi-field payloads: inline records

When a payload has more than one or two components, the tuple form
becomes unwieldy. OCaml supports *inline records* as payloads:

```ocaml
type task =
  | Todo
  | Doing of { who : string }
  | Done of { who : string; hours : int }

let t1 = Todo
let t2 = Doing { who = "alice" }
let t3 = Done  { who = "alice"; hours = 3 }
```

:::

Variants are *pervasive* in OCaml: `bool`, `list`, `option`, and
`result` are all variants. The
[next section](#recursive-types) covers recursive
variants and polymorphism.

:::quiz mcq id=M04-L03-q2
Given:

```ocaml
type shape =
  | Circle of float
  | Square of float
  | Rectangle of float * float
```

Which of these are **valid** constructor applications?

- [x] `Circle 3.0`
- [ ] `Square "5"` (wrong payload type)
- [x] `Rectangle (4.0, 6.0)`
- [ ] `Triangle 5.0` (not a constructor of `shape`)

**Why:** each payload must match its constructor's declared type.
`Square "5"` gives a `string` where `float` is expected; `Triangle`
isn't a constructor of `shape` at all.
:::

:::quiz code id=M04-L03-q1
Design a variant `http_response` for HTTP responses. Cover three
shapes:

- A `Success` carrying the response `body : string`.
- A `Redirect` carrying the target `url : string`.
- An `Error` carrying a `code : int` and a `message : string`.

Then construct one example value of each constructor.

```ocaml
(* declare http_response here *)
type http_response = unit

(* construct one example of each *)
let example_success  = ()
let example_redirect = ()
let example_error    = ()
```

```ocaml skip
(* Each example must type-check, using three different constructors. *)
let check b m = if not b then failwith m
let () =
  ignore (example_success  : http_response);
  ignore (example_redirect : http_response);
  ignore (example_error    : http_response);
  check (example_success <> example_redirect) "success vs redirect";
  check (example_success <> example_error) "success vs error";
  check (example_redirect <> example_error) "redirect vs error";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```ocaml
type http_response =
  | Success of string
  | Redirect of string
  | Error of { code : int; message : string }

let example_success  = Success "<html>hello</html>"
let example_redirect = Redirect "https://example.com/new-page"
let example_error    = Error { code = 404; message = "not found" }
```

`Error` uses an inline record: two named fields read more cleanly
than `Error of int * string`.

:::

This lecture only *declared* variant types and *constructed*
values. Taking one apart is pattern matching's job, in
[Module 5](M05-L01-basic-patterns.html).

Next: **recursive types** — variants whose payloads include
the type being defined. Lists, trees, expressions, and JSON values
all fit this shape.

## Recursive types

A variant becomes recursive when one of its constructors carries a value
of *the same type* being defined. That self-reference lets a *fixed*
declaration describe data of *unbounded size* — lists, trees,
expressions — and a recursive type calls for a recursive function of
the same shape.

:::slide

### Recursive types

- Types defined in terms of themselves. 
- One fixed declaration describes data of *unbounded size*: lists,
  trees, expressions.

:::

This connects recursion at the *function* level, from Module 3,
with recursion at the *type* level: the code you write to walk
such a value will mirror the shape of the value itself. The
simplest example is one you already know informally — a list.

:::slide

### A first recursive variant: a list of integers

A list is either empty, or a head element plus a *smaller list* of
the same kind:

```ocaml
type intlist =
  | INil
  | ICons of int * intlist

let ints = ICons (1, ICons (2, ICons (3, INil)))
```

- `INil`: empty list. `ICons`: head `int` plus a *tail* `intlist`.
- `intlist` appears inside its own definition — the **recursive
  variant** pattern that lets one declaration describe lists of any
  length.

:::

If you needed a list of strings instead of integers, the shape
would be identical — only the element type changes. Writing out
that same shape again for every element type you need is exactly
the repetition a type parameter is meant to avoid.

:::slide

### Parameterised variants

Writing `stringlist`, `pointlist`, `shapelist` would each just repeat
the `intlist` shape with a different element type. Instead, leave the
element type as a parameter — a *type variable*:

```ocaml
type 'a lst =
  | Nil
  | Cons of 'a * 'a lst

let ints = Cons (1, Cons (2, Cons (3, Nil)))
let strs = Cons ("hello", Cons ("world", Nil))
```

- One declaration covers every element type: `ints : int lst`,
  `strs : string lst`.
- Inside a single value every `'a` is the **same** type —
  `Cons (1, Cons ("oops", Nil))` is a type error.

:::

The `'a` doing the work here is worth naming precisely: it stands
for an unknown *type*, the same way an ordinary variable stands
for an unknown *value*.

:::slide

### `'a` is a type variable

A *type variable* is a name standing for an unknown *type*, the way a
regular variable stands for an unknown *value*.

- OCaml writes them `'a`, `'b`, pronounced "alpha", "beta".
- Same idea: Java `List<T>`, C++ `std::vector<T>`, Rust `Vec<T>`.

:::

A definition that contains type variables is called *polymorphic*
— literally "many shapes" — because one declaration covers many
instantiations at once.

:::slide

### Polymorphism

A definition containing type variables is *polymorphic* (*poly* =
many, *morph* = shape): one declaration covering many shapes (`int
lst`, `string lst`, ...). The simplest polymorphic function is the
identity:

```ocaml
let id x = x
```

- `lst` is a **type constructor**: takes a type, gives a type — same
  idea as Java generics, C++ templates, Rust generics.
- `id`: `val id : 'a -> 'a`. One definition, works at every `'a`.

:::

Everything built up so far — a recursive, parameterised variant
for "a chain of elements" — is not a toy. It is, structurally,
exactly what the standard library's own list type already is.

:::slide

### OCaml's built-in lists are just variants

The standard library's `list` has exactly the shape we just built:

```text
type 'a list =
  | []
  | (::) of 'a * 'a list
```

- `[]` and `::` are constructors — informally *nil* and *cons* (from
  Lisp), special-cased so they need not start with a capital letter.
- `::` is infix; `[1; 2; 3]` desugars to `1 :: 2 :: 3 :: []`.
- Strip the sugar and it is a normal parameterised variant.

:::

Most mainstream languages have a special "no value here" —
`null`, `nil`, `undefined` — whose *type* doesn't say whether the
value is actually there, so a lookup can compile cleanly and still
crash at runtime. Tony Hoare, who introduced `null` in 1965, later
called it his "billion-dollar mistake." OCaml's fix is to have no
implicit null at all: "no value" becomes its own type, built the
same way lists are.

:::slide

### The `option` type

OCaml's answer is a built-in parameterised variant — a *box* that
either contains one value (`Some x`) or is empty (`None`).

```ocaml
type 'a option =
  | None
  | Some of 'a

let y = Some 10   (* : int option *)
let z = Some "hi" (* : string option *)
```

- Compare `val lookup : string -> string` (never fails) with
  `val lookup : string -> string option` (might return `None`) — the
  second is **honest**, in the type, about maybe-failing.

:::

Reach for `option` whenever "may be absent" is genuinely part of
the domain — a mark that hasn't been entered yet, a lookup that
might miss — never as a stand-in for a value you just haven't
decided how to compute. When `None` isn't informative enough and
the caller needs to know *why* something failed, the standard
library's two-parameter `result` type (`Ok of 'a | Error of 'e`)
carries a reason alongside the failure. And because a list is
built by prepending (`0 :: xs`), adding a new head is cheap and
never disturbs the list it was built from — the next recursive
shape, a tree, simply lets that same chaining branch in two
directions instead of one.

:::slide

### A binary tree

The next-simplest recursive variant, branching instead of chaining:

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree

let example = Node (Node (Leaf, 1, Leaf), 2, Node (Leaf, 3, Leaf))
```

```text
  2
 / \
1   3
```

- `Leaf`: empty. `Node`: left subtree, value, right subtree.
- The recursive reference appears **twice** inside `Node` — that's
  what makes trees branch where lists only chain.
- `'a tree` works for any element type, just like `'a list`.

:::

We now have variants for *kinds*, recursion for *nesting*, and type
variables for *polymorphism*. The missing piece is how to *walk* one
of these structures — that's pattern matching, in
[Module 5](M05-L01-basic-patterns.html).

:::quiz mcq id=M04-L04-q2
Given:

```ocaml
type expr =
  | Num of int
  | Add of expr * expr
  | Mul of expr * expr
```

Which of these are **valid** values of type `expr`?

- [x] `Num 0`
- [x] `Add (Num 1, Num 2)`
- [x] `Mul (Add (Num 1, Num 2), Num 3)`
- [ ] `Add (1, 2)`

**Why:** `Add` and `Mul` take payloads that are themselves `expr`s,
not raw `int`s, so `Add (1, 2)` doesn't type-check. The recursive
nesting (`Mul` of `Add` of `Num`s) is exactly what makes this a
*recursive* variant.
:::

:::quiz mcq id=M04-L04-q3
What type does the toplevel report for `None`?

- [ ] `unit`
- [ ] `None`
- [x] `'a option`
- [ ] `int option`

**Why:** `None` carries no payload, so its element type is
unconstrained until it's *used* in a context that demands a
particular type — same as `[]` reporting `'a list`.
:::

:::quiz code id=M04-L04-q4
Write `safe_sqrt : float -> float option` that returns
`Some (sqrt x)` for non-negative `x`, and `None` when `x` is
negative. This is a *construction-only* exercise: build an
`option` value with `if`/`then`/`else`; you don't need pattern
matching yet (that's M05).

```ocaml
let safe_sqrt x =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (safe_sqrt 4.0   = Some 2.0) "4";
  check (safe_sqrt 0.0   = Some 0.0) "0";
  check (safe_sqrt 9.0   = Some 3.0) "9";
  check (safe_sqrt (-1.0) = None)    "negative";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```ocaml
let safe_sqrt x =
  if x < 0.0 then None else Some (sqrt x)
```

`sqrt` returns `nan` on a negative input rather than signalling an
error. Wrapping it as `float option` is honest: the type tells the
caller that negatives aren't handled, and forces them to look at the
`None` case when they consume the result.

:::
