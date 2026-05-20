---
title: "Matching records, variants, and combined shapes"
lecture_no: 5
week: 5
duration_target_min: 22
concepts: [record patterns, variant patterns with payloads, deep nesting, partial record patterns]
keywords: [OCaml, pattern matching, record pattern, variant pattern, payload, nesting]
activity_question: "Given [type event = Click of {x : int; y : int} | Key of char], write [describe : event -> string] that prints a useful summary of each event."
think_about_this: "Why does OCaml let you write [{ name; _ }] to ignore other fields? What would change if every field had to be listed in every record pattern?"
reading:
  - title: "Cornell CS3110, Record and variant patterns"
    url: https://cs3110.github.io/textbook/chapters/data/pattern_matching.html
---

# Matching records, variants, and combined shapes

Pattern matching on records and variants is where most of the
day-to-day OCaml work happens. You take a value apart, look at
its tag, look at its fields, dispatch on the combination, and
build a new value or trigger an effect. This lecture is the
everyday-syntax pass: the short forms, the deep nesting, the
combinations you will reach for over and over again.

We have already seen most of the pieces. Module 4 introduced
[records](M04-L02-records.html) and [variants](M04-L03-variants.html);
[Lecture 1](M05-L01-basic-patterns.html) introduced the basic
pattern forms; [Lectures 2](M05-L02-nested-and-or-patterns.html) and
[3](M05-L03-guards.html) added nesting, or-patterns, and guards.
This lecture pulls them together and shows the idiomatic
patterns: how to ignore record fields, how to rename them on the
way in, how to walk a tree, how to handle pairs of options,
and a few related idioms that recur in real code.

## Record patterns: name the fields you need

Suppose we have a user record:

```ocaml
type user = { name : string; age : int; admin : bool }
```

The most useful record-pattern syntax lets you list only the
fields you care about, ignoring the rest with `_`:

```ocaml
type user = { name : string; age : int; admin : bool }

let summary { name; age; _ } =
  Printf.sprintf "%s, age %d" name age

let _ = summary { name = "Alice"; age = 30; admin = true }
```

:::slide

## Record patterns: list the fields you need

```ocaml
type user = { name : string; age : int; admin : bool }

let summary { name; age; _ } =
  Printf.sprintf "%s, age %d" name age
```

`"Alice, age 30"`.

- Pattern `{ name; age; _ }` binds `name` and `age` from the record.
- `_` says "more fields exist, I ignore them".
- Without `_`, OCaml warns that fields are unhandled.

:::

The pattern `{ name; age; _ }` does three things at once:

1. It matches any record of type `user` (the type is inferred
   from the field names).
2. It binds the field `name` to a local name `name` (sugar for
   `name = name`).
3. It binds the field `age` to a local `age`.
4. The trailing `_` says "there are other fields; I am ignoring
   them on purpose."

Without the trailing `_`, OCaml warns:

```
Warning 9 [missing-record-field-pattern]: the following labels
are not bound in this record pattern: admin
```

This warning is one we usually want to leave on: it makes the
programmer think about whether the new field needs handling in
existing matches when the record grows. With `_`, you opt out
of that warning for *this* pattern, saying "I have seen the
new field, and I do not need to update this site."

The shorthand `{ name; age }` (no equals signs) is the everyday
form. The longer `{ name = name; age = age }` is equivalent but
verbose. Use the short form unless you want to rename a field
locally.

## Renaming on the way in

Sometimes you want to bind a field to a *different* name. The
syntax is `{ field = local_name }`:

```ocaml
type user = { name : string; age : int; admin : bool }

let role { name = n; admin } =
  if admin then n ^ " (admin)" else n

let _ = role { name = "Bob"; age = 25; admin = true }
let _ = role { name = "Carol"; age = 28; admin = false }
```

:::slide

## Renaming fields on the way in

```ocaml
type user = { name : string; age : int; admin : bool }

let role { name = n; admin } =
  if admin then n ^ " (admin)" else n
```

`"Bob (admin)"`, `"Carol"`.

- `{ name = n; admin }` binds the record's `name` field to local `n`.
- Binds `admin` to itself (shorthand for `admin = admin`).
- When you list only some fields, "ignore the rest" is implicit.

:::

The first field uses the renaming form: `name = n` says "match
the `name` field, and call it `n` locally." The second uses the
shorthand: `admin` alone is sugar for `admin = admin`.

When you explicitly list one or more specific fields, ignoring
the rest is implicit (no `_` needed). Some codebases write `_`
anyway, to make the intent more visible. Both styles are common.

## Variant patterns with payloads

Variants are the other half of OCaml's structured types. Each
constructor can carry a payload, and the pattern destructures
that payload:

```ocaml
type shape =
  | Circle of float
  | Rectangle of float * float
  | Polygon of float list

let perimeter = function
  | Circle r -> 2.0 *. 3.14159 *. r
  | Rectangle (w, h) -> 2.0 *. (w +. h)
  | Polygon sides -> List.fold_left (+.) 0.0 sides

let _ = perimeter (Circle 1.0)
let _ = perimeter (Rectangle (3.0, 4.0))
let _ = perimeter (Polygon [1.0; 2.0; 3.0])
```

:::slide

## Variant patterns with payloads

```ocaml
type shape =
  | Circle of float
  | Rectangle of float * float
  | Polygon of float list

let perimeter = function
  | Circle r -> 2.0 *. 3.14159 *. r
  | Rectangle (w, h) -> 2.0 *. (w +. h)
  | Polygon sides -> List.fold_left (+.) 0.0 sides
```

- Each clause matches a constructor.
- Binds the payload to a name: `r`, `(w, h)`, `sides`.
- Pattern says "this kind; here's how to take its data apart".

:::

Each clause's pattern is a constructor with a sub-pattern for the
payload. `Circle r` binds the payload to `r`. `Rectangle (w, h)`
binds a *tuple* payload by destructuring it directly: `w` is the
width, `h` the height. `Polygon sides` binds the entire payload
(a list) to `sides`; the function body then folds over the list.

The compiler reads off the type from the constructor names. We
did not have to write `: shape` anywhere; the use of `Circle`,
`Rectangle`, and `Polygon` is enough.

Note one place this differs from a function taking two arguments.
`Rectangle (w, h)` is a *constructor applied to a tuple*, not a
two-argument constructor. The parentheses and comma denote the
tuple payload. The constructor takes exactly one argument; that
argument happens to be a pair.

## Inline records inside constructors

Since OCaml 4.03, a constructor's payload can be a record
declared inline. This is the cleanest way to make a payload's
fields self-documenting:

```ocaml
type event =
  | Click of { x : int; y : int }
  | Key   of char
  | Quit

let describe = function
  | Click { x; y } -> Printf.sprintf "click at (%d, %d)" x y
  | Key c          -> Printf.sprintf "key: %c" c
  | Quit           -> "quit"

let _ = describe (Click { x = 100; y = 200 })
let _ = describe (Key 'q')
let _ = describe Quit
```

:::slide

## Variant with inline record payload

```ocaml
type event =
  | Click of { x : int; y : int }
  | Key   of char
  | Quit

let describe = function
  | Click { x; y } -> Printf.sprintf "click at (%d, %d)" x y
  | Key c          -> Printf.sprintf "key: %c" c
  | Quit           -> "quit"
```

`"click at (100, 200)"`, `"key: q"`, `"quit"`.

- `Click`'s payload is a **record declared inline**.
- Pattern destructures it like any record pattern.
- Avoids declaring a separate `type click = { x : int; y : int }`.

:::

`Click of { x : int; y : int }` is an inline record payload. You
do not need to declare a separate `type click = ...` and use
`Click of click`; the record is part of the constructor's
definition.

Inside the pattern, `Click { x; y }` destructures the inline
record exactly like any other record pattern. You can ignore
fields with `_`, rename fields, or list only some, all the same
way.

A small caveat: a value of type `event` cannot have a value of
type "click record" lifted out separately. The inline record
exists only as the payload of `Click`. If you want to share the
record shape between constructors, define it as a named record
type instead.

## Walking a tree: deep nesting in action

The classic example for variant pattern matching is walking a
recursive data structure. Trees are the canonical example:

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree

let rec mirror = function
  | Leaf -> Leaf
  | Node (l, v, r) -> Node (mirror r, v, mirror l)

let example = Node (Node (Leaf, 1, Leaf), 2, Node (Leaf, 3, Leaf))
let _ = mirror example
```

:::slide

## Deep nesting: walking a tree

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree

let rec mirror = function
  | Leaf -> Leaf
  | Node (l, v, r) -> Node (mirror r, v, mirror l)
```

- Pattern `Node (l, v, r)` destructures the constructor.
- Names the three components: left subtree, value, right subtree.
- Recursive case rebuilds with subtrees swapped (and mirrored).

```ocaml
let only_root_value = function
  | Node (_, v, _) -> Some v
  | Leaf -> None
```

`Some 2`. Same shape; we just care about the value.

:::

`mirror` reflects a binary tree left-to-right. The pattern `Node
(l, v, r)` names the left subtree, value, and right subtree; the
right-hand side rebuilds with the recursive calls swapped. The
base case (`Leaf -> Leaf`) handles the empty tree directly.

The second function `only_root_value` shows that you can pattern
match more loosely: `Node (_, v, _)` says we only care about the
root value, not the subtrees. You will see this often: pattern
on the *parts you need*, wildcards on the rest.

The general meta-pattern here (one clause per constructor, each
clause computing its result from the sub-parts) will be the
core of the tutorial in [Lecture 6](M05-L06-tutorial.html), and the
central idea of [Module 6](M06-L01-functions-revisited.html)
(higher-order functions and [folds](M06-L04-fold.html)).

## Matching a tuple of values: the diagonal idiom

A useful trick for handling combinations of values is to *form a
tuple* and pattern-match on it. The classic case is comparing two
options:

```ocaml
let combine a b =
  match a, b with
  | None,   None   -> "both empty"
  | Some _, None   -> "first only"
  | None,   Some _ -> "second only"
  | Some _, Some _ -> "both present"

let _ = combine (Some 1) None
```

:::slide

## Matching on a tuple of values

```ocaml
let combine a b =
  match a, b with
  | None,   None   -> "both empty"
  | Some _, None   -> "first only"
  | None,   Some _ -> "second only"
  | Some _, Some _ -> "both present"
```

`"first only"`.

- `match a, b with` is sugar for `match (a, b) with`.
- Four cases cover all combinations of two options.
- Recurring idiom: for two related options/variants, match the **pair**.

:::

`match a, b with` is shorthand for `match (a, b) with`: the comma
forms an implicit tuple. The four clauses cover the 2x2 grid of
option combinations. This is *more readable* than the alternative,
which would nest a match inside a match:

```ocaml skip
let combine a b =
  match a with
  | None ->
    (match b with
     | None -> "both empty"
     | Some _ -> "second only")
  | Some _ ->
    (match b with
     | None -> "first only"
     | Some _ -> "both present")
```

Same logic, much harder to read. Reach for the tuple-form when
you have two (or more) related values whose combination
determines the answer. The compiler does the exhaustiveness check
on the cross-product, so it will tell you if you missed `(None,
Some _)`.

## Or-patterns to group constructors

Or-patterns from [Lecture 2](M05-L02-nested-and-or-patterns.html#or-patterns-shared-right-hand-sides)
shine when several constructors share a right-hand side. HTTP status
codes are a classic example:

```ocaml
type http_status =
  | OK
  | NotFound
  | InternalError
  | ServiceUnavailable

let is_error = function
  | OK -> false
  | NotFound | InternalError | ServiceUnavailable -> true

let _ = is_error NotFound
let _ = is_error OK
```

:::slide

## Or-patterns to group constructors

```ocaml
type http_status =
  | OK
  | NotFound
  | InternalError
  | ServiceUnavailable

let is_error = function
  | OK -> false
  | NotFound | InternalError | ServiceUnavailable -> true
```

`true`, `false`.

- Group the three "error" constructors with `|`.
- Keeps exhaustiveness: every constructor is listed.
- Prefer this to `| _ -> true`, which silently swallows new constructors.

:::

We could have written this with a wildcard:

```ocaml skip
let is_error = function
  | OK -> false
  | _ -> true
```

Same behaviour today, but if someone later adds `Redirect` to the
type, the wildcard silently classifies it as an error. The
or-pattern version forces the compiler to warn: a new constructor
is unhandled, please decide which side.

This is the "avoid wildcards on variants" discipline from
[Lecture 4](M05-L04-exhaustiveness.html#when-to-use-a-wildcard-catch-all-on-variants),
applied here.

## When there are many constructors

If your variant has 20 constructors and the function does
something different for each, the `match` will be long. There is
no avoiding that; the cases are intrinsic to the problem. The
usual approach is to group related constructors into helper
functions:

```ocaml
type status =
  | S_200 | S_201 | S_204
  | S_301 | S_302
  | S_400 | S_401 | S_404
  | S_500 | S_502 | S_503

let category = function
  | S_200 | S_201 | S_204 -> `Success
  | S_301 | S_302 -> `Redirect
  | S_400 | S_401 | S_404 -> `Client_error
  | S_500 | S_502 | S_503 -> `Server_error
```

:::slide

## Many constructors: group with helpers

```ocaml
type status =
  | S_200 | S_201 | S_204
  | S_301 | S_302
  | S_400 | S_401 | S_404
  | S_500 | S_502 | S_503

let category = function
  | S_200 | S_201 | S_204 -> `Success
  | S_301 | S_302 -> `Redirect
  | S_400 | S_401 | S_404 -> `Client_error
  | S_500 | S_502 | S_503 -> `Server_error
```

- Group constructors into broad buckets.
- Return values use a **polymorphic variant** (`` `Success ``); separate feature, mentioned in passing.
- Point: helper functions tame large variants.

:::

The return type `[> `Success | `Redirect | `Client_error |
`Server_error ]` uses *polymorphic variants*, a different
OCaml feature that lets you write a constructor with a leading
backtick without first declaring a type. They are useful for
internal helpers and prototyping. We will not dig into them in
this course; the standard variant types (which require a type
declaration) are the right tool the vast majority of the time.

## Combining: variants and records together

Real types often combine variants with records. The pattern for
this is straightforward: match the constructor first, then
destructure the record payload:

```ocaml
type request =
  | Get of { url : string }
  | Post of { url : string; body : string }
  | Delete of { url : string }

let url_of = function
  | Get { url }
  | Post { url; _ }
  | Delete { url } -> url

let _ = url_of (Get { url = "/" })
let _ = url_of (Post { url = "/submit"; body = "hello" })
```

Notice the or-pattern across constructors that all share the
field `url`. Each alternative pattern destructures its own
record payload, but each binds the same name `url` at the same
type (`string`). The compiler accepts this: same name, same
type, in each alternative.

If you needed `Post`'s `body` field too, the or-pattern would
not work (`Get` and `Delete` do not have a `body`). In that
case, fall back to separate clauses.

## Two checks

:::quiz mcq id=M05-L05-q3
What does `summary { name = "Alice"; age = 30; admin = false }`
evaluate to, given:

```ocaml
type user = { name : string; age : int; admin : bool }

let summary { name; _ } = "Hello, " ^ name
```

- [ ] Compile error: missing fields.
- [ ] Warning, then `"Hello, Alice"`.
- [x] `"Hello, Alice"`.
- [ ] `"Hello, Alice (admin=false)"`.

**Why:** the pattern `{ name; _ }` binds the `name` field and
ignores the rest. No warning, since the trailing `_` explicitly
says "ignore other fields." The function returns
`"Hello, Alice"`.
:::

:::quiz mcq id=M05-L05-q2
Which of the following correctly extracts the `url` from any
constructor of:

```ocaml
type req = Get of string | Post of string * string
```

- [ ] `let url_of = function Get url -> url`
- [x] `let url_of = function | Get url -> url | Post (url, _) -> url`
- [ ] `let url_of = function | Get url | Post (url, _) -> url`
- [ ] `let url_of (Get url | Post (url, _)) = url`

**Why:** the second answer (separate clauses) is correct. The
third would also work *syntactically*, since both alternatives
bind `url : string`, but it relies on or-pattern semantics that
require the same binding name and type in every alternative;
this is exactly the case where or-patterns are allowed across
constructors. Some readers find the explicit clauses clearer;
both forms are idiomatic. The first option is non-exhaustive.
The fourth has a syntax issue (parameter pattern would need
parenthesisation).
:::

A code task:

:::quiz code id=M05-L05-q1
Given the type below, write `describe : event -> string`:

- A `Click { x; y }` becomes `"click at (x, y)"`, e.g. `"click at (50, 75)"`.
- A `Key c` becomes `"key: c"`, e.g. `"key: a"`.
- A `Quit` becomes `"quit"`.

```ocaml
type event =
  | Click of { x : int; y : int }
  | Key   of char
  | Quit

let describe e =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (describe (Click { x = 50; y = 75 }) = "click at (50, 75)") "click";
  check (describe (Key 'a') = "key: a") "key a";
  check (describe (Key 'Z') = "key: Z") "key Z";
  check (describe Quit = "quit") "quit";
  print_endline "all tests passed"
```
:::

The shape: one clause per constructor, each destructuring the
payload as needed. Note: use `Printf.sprintf "click at (%d, %d)"
x y` for the click, `Printf.sprintf "key: %c" c` for the key.

## Common pitfalls

**Pitfall 1: forgetting the `_` in a partial record pattern.**
`let f { name } = ...` warns about the unhandled `age` and `admin`
fields. If you genuinely want to ignore them, add `_`:
`let f { name; _ } = ...`.

**Pitfall 2: confusing constructor-with-tuple-payload with a
multi-argument constructor.** OCaml does not have multi-argument
constructors; a constructor takes exactly one argument, which may
happen to be a tuple. So `Rectangle (w, h)` is a constructor
applied to a tuple, and the pattern `Rectangle (w, h)` destructures
that tuple.

**Pitfall 3: wildcards on variants.** Avoid them; they silently
suppress the exhaustiveness benefit when new constructors are
added. Use or-patterns to group instead.

**Pitfall 4: nested-match indentation.** When you nest a `match`
inside another expression, parenthesise or use `begin...end` to
prevent the `else`/clause-bar from being parsed as belonging to
an outer match. We will see this in the tutorial.

## Activity

:::slide

## Activity

Given:

```ocaml skip
type event =
  | Click of { x : int; y : int }
  | Key of char
```

Write `describe : event -> string` that returns a useful summary
of each event.

:::

Try it before reading the solution.

:::slide

## Activity solution

```ocaml
type event =
  | Click of { x : int; y : int }
  | Key of char

let describe = function
  | Click { x; y } -> Printf.sprintf "click at (%d, %d)" x y
  | Key c -> Printf.sprintf "key pressed: %c" c

let _ = describe (Click { x = 50; y = 75 })
let _ = describe (Key 'a')
```

`"click at (50, 75)"`, `"key pressed: a"`.

- Two clauses, each destructuring its payload.
- Exhaustive: every constructor is listed.

:::

The match destructures `Click`'s inline record and `Key`'s
char payload. The compiler verifies exhaustiveness: the two
clauses cover both constructors. If you later add `Quit` to the
type, this match will warn until you handle it.

## What's next

We have now covered the static checking *and* the everyday
syntax for matching records and variants. [Lecture 6](M05-L06-tutorial.html)
is the tutorial: a worked walkthrough of an arithmetic expression
AST, implementing an evaluator, a pretty-printer, a depth function,
and a constant-folder, each as a single pattern match on the
expression type. By the end you will have the workhorse
pattern of Module 5 firmly in your hands.

:::slide

## What's next

- Lecture 6: **tutorial**.
- Build an arithmetic AST walker: evaluator, pretty-printer,
  depth, constant folder.
- Every function is a pattern match on the same type.

:::

## Reading

- **Cornell CS3110**, *Record and variant patterns*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
- **Cornell CS3110**, *Pattern matching examples* (the Pokemon
  section, several ways to extract a field):
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching_advanced.html>
- **Real World OCaml**, *Variants*:
  <https://dev.realworldocaml.org/variants.html>
