---
title: "Records"
lecture_no: 2
week: 4
duration_target_min: 22
concepts: [records, named fields, record types, functional update, dot access]
keywords: [OCaml, record, named fields, record type, functional update]
activity_question: "Define a record type [book] with fields [title : string], [author : string], [year : int]. Create one. Define a function that returns the title."
think_about_this: "Records have *named* fields where tuples have *positional* components. Which is better for a function that takes both a 'first name' and a 'last name'? Which is better for a 2D point?"
reading:
  - title: "Cornell CS3110, Records"
    url: https://cs3110.github.io/textbook/chapters/data/records_and_tuples.html
---

# Records

A record is like a tuple, but each field has a *name*. When your
data has more than a couple of components or when the components
are at risk of being mixed up (which is the first, x or y?), a
record is clearer.

:::slide

## Declaring a record type

Records are *nominally* typed in OCaml: you declare the type, then
construct values of that type.

```ocaml
type point = { x : float; y : float }

let origin = { x = 0.0; y = 0.0 }
let p      = { x = 3.0; y = 4.0 }
```

`point` is a type. `origin` and `p` are values of type `point`.
Construction syntax: braces, `field = value`, semicolons between.

:::

:::slide

## Accessing fields

Two ways: dot syntax, or destructuring.

```ocaml
let _ = p.x
let _ = p.y
```

`p.x` returns `3.0`, `p.y` returns `4.0`. Reads like Java or
Python.

```ocaml
let { x; y } = p
let _ = x
let _ = y
```

Destructuring pattern: introduce `x` and `y` as local names bound to
`p.x` and `p.y` respectively. The short form `{ x; y }` is sugar
for `{ x = x; y = y }`.

:::

The short-form binding (`{ x; y }` ≡ `{ x = x; y = y }`) is
exactly the same as ES6 / TypeScript's destructuring shorthand:
`const { x, y } = p`. Same idea, different sigil.

:::slide

## Records in function parameters

```ocaml
let distance p q =
  let dx = q.x -. p.x in
  let dy = q.y -. p.y in
  sqrt (dx *. dx +. dy *. dy)

let _ = distance { x = 0.0; y = 0.0 } { x = 3.0; y = 4.0 }
```

`float = 5.0`. The function takes two records. The body accesses
their fields by name.

Or, with destructuring in the parameters:

```ocaml
let distance { x = x1; y = y1 } { x = x2; y = y2 } =
  let dx = x2 -. x1 in
  let dy = y2 -. y1 in
  sqrt (dx *. dx +. dy *. dy)
```

Same function, fields pulled out into named locals up front. Choose
whichever reads better; the second form is common when you destructure
heavily.

:::

:::slide

## Functional update

You can't modify a record in place (records are immutable by
default). To get a record that *differs* from another in one field:

```ocaml
let p2 = { p with y = 10.0 }
```

The `with` syntax produces a *new* record, identical to `p` except
that `y` is `10.0`. `p` is unchanged.

```ocaml
let _ = p.y
let _ = p2.y
```

`4.0` and `10.0`. Functional update is the immutable equivalent of
"mutate this field"; you get a new value with the change, you don't
edit the old one.

:::

Functional update is a quiet but important feature. In any program
that needs to "modify" a record (the user's profile, a piece of
state), you write a new version with the changed field and pass
that around. The old version is still valid; nothing observable
changed about it.

This buys you the same property we discussed in Module 2: equational
reasoning. The value `p` *is* what it is forever; nothing later in
the program can have changed `p.y` underneath you.

:::slide

## Records vs tuples: when to use which

Use a **record** when:

- You have more than three fields.
- The fields have meaningful names (`first_name`, `last_name`,
  `phone`).
- You want to update one or two fields and keep the rest (`with`
  syntax).

Use a **tuple** when:

- You have two or three components and the positions are
  self-evident (`(x, y)`, `(key, value)`).
- The tuple is short-lived (you destructure it right after building
  it).

`(string, string)` is OK for "first_name, last_name" if it's local
and obvious. A function called `make_full_name (string, string) ->
string` reading `f "John" "Doe"` is fine. But once you write code
that *takes* such a tuple as input, you start wishing for names:
which one was first?

:::

:::slide

## Records compare structurally

```ocaml
let p1 = { x = 1.0; y = 2.0 }
let p2 = { x = 1.0; y = 2.0 }
let _ = p1 = p2
```

`true`. Structural equality compares field by field. Two records
with the same values are equal even if they live in different
memory.

This is the same `=` we have used for ints and strings; it works
on records out of the box.

:::

:::slide

## Type inference for records is brittle

OCaml's type inference handles tuples gracefully. For records, it
needs the type declaration *in scope* to know what `{ x; y }`
refers to.

If two record types have a field `x`:

```ocaml
type point2 = { x : float; y : float }
type point3 = { x : float; y : float; z : float }

let p = { x = 1.0; y = 2.0 }
```

The inferred type of `p` is `point2`, the *most recently declared*
record type with those fields. If you wanted `point3`, you'd have
to write `{ x = 1.0; y = 2.0; z = 0.0 }` (now the type is forced
by the presence of `z`).

In practice this is rarely a problem; just be aware that record
types live in a flat namespace by *field name*.

:::

:::slide

## Mutable record fields

Records are immutable *by default*. You can opt in to mutability
per field:

```ocaml
type counter = { mutable n : int }

let c = { n = 0 }
let () = c.n <- c.n + 1
let _ = c.n
```

`int = 1`. The `mutable` keyword on `n` allows `c.n <- new_value`
assignment. The `<-` is the OCaml assignment operator for mutable
record fields.

We're previewing this; full coverage of mutation comes in Module 7.
For now, prefer immutable records. Reach for `mutable` when you
need to model a counter, a cache, a position in a long-running
state machine.

:::

:::slide

## Activity

Define a record type `book` with fields `title : string`, `author :
string`, `year : int`. Create one. Define a function `book_title`
that returns the title.

:::

:::slide

## Activity solution

```ocaml
type book = { title : string; author : string; year : int }

let real_world_ocaml =
  { title = "Real World OCaml";
    author = "Minsky, Madhavapeddy, Hickey";
    year = 2013 }

let book_title b = b.title

let _ = book_title real_world_ocaml
```

`string = "Real World OCaml"`. Three fields, named access, simple
function.

For a more idiomatic style we'd destructure in the parameter:

```ocaml
let book_title { title; _ } = title
```

The `_` says "and ignore the other fields". `let { title; _ } = b
in title` is exactly what `b.title` is; the destructuring form
makes that explicit.

:::

:::slide

## What's next

Lecture 3: **variants** (also called sum types or tagged unions).
Records are "this *and* that". Variants are "this *or* that". The
combination of records and variants is how you model real data in
OCaml.

:::

## Reading

- **Cornell CS3110**, *Records*:
  <https://cs3110.github.io/textbook/chapters/data/records_and_tuples.html>
