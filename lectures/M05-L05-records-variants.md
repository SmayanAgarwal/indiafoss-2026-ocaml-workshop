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

Records and variants are where pattern matching shines. You spend
most of your "real" OCaml time matching on them: walking trees,
processing events, handling option/result returns. This lecture
covers the everyday shapes.

:::slide

## Record patterns: list the fields you need

```ocaml
type user = { name : string; age : int; admin : bool }

let summary { name; age; _ } =
  Printf.sprintf "%s, age %d" name age

let _ = summary { name = "Alice"; age = 30; admin = true }
```

`"Alice, age 30"`.

- Pattern `{ name; age; _ }` binds `name` and `age` from the record.
- `_` says "more fields exist, ignored".
- Without `_`, OCaml warns about unhandled fields.

:::

:::slide

## Renaming on the way in

```ocaml
type user = { name : string; age : int; admin : bool }

let role { name = n; admin } =
  if admin then n ^ " (admin)" else n

let _ = role { name = "Bob"; age = 25; admin = true }
let _ = role { name = "Carol"; age = 28; admin = false }
```

`"Bob (admin)"`, `"Carol"`.

- Pattern `{ name = n; admin }` binds field `name` to local name `n`.
- Binds `admin` to itself (sugar for `admin = admin`).
- "Other fields are ignored" is implicit when you list specific fields.

:::

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

let _ = perimeter (Circle 1.0)
let _ = perimeter (Rectangle (3.0, 4.0))
let _ = perimeter (Polygon [1.0; 2.0; 3.0])
```

- Each clause matches a constructor.
- Binds the payload to a name (`r`, `(w, h)`, `sides`).
- The pattern says "this kind; here's how to take its data apart".

:::

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

let _ = describe (Click { x = 100; y = 200 })
let _ = describe (Key 'q')
let _ = describe Quit
```

`"click at (100, 200)"`, `"key: q"`, `"quit"`.

- `Click`'s payload is a *record* declared inline.
- The pattern destructures it like any top-level record pattern.

:::

`Click of { x; y }` is a more recent OCaml feature (4.03+) and a
common idiom now: when a constructor's payload has named
fields, you don't have to declare a separate record type.

:::slide

## Deep nesting: walking a tree

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

- Pattern `Node (l, v, r)` destructures the constructor.
- Names the three components.
- Recursive case rebuilds with subtrees swapped (and mirrored).

You can also nest deeper:

```ocaml
let only_root_value = function
  | Node (_, v, _) -> Some v
  | Leaf -> None

let _ = only_root_value example
```

`Some 2`. The pattern only cares about the value, not the subtrees.

:::

:::slide

## Multiple values: matching on a tuple

```ocaml
let zip_pair_status (a, b) =
  match a, b with
  | None, None     -> "both empty"
  | Some _, None   -> "first only"
  | None, Some _   -> "second only"
  | Some _, Some _ -> "both present"

let _ = zip_pair_status (Some 1, None)
```

`"first only"`.

- Pattern `None, None` is sugar for `(None, None)`; outer parens optional.
- We match on the *pair* of two options.
- Four cases cover all combinations.
- Recurring idiom: for two related options or variants, match on the **tuple of both**.

:::

:::slide

## Don't repeat yourself: variant + or-pattern

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

`true`, `false`.

- Group constructors with `|` to share a right-hand side.
- Same pattern as Lecture 2.

:::

:::slide

## When the variant has many constructors

- A status with 30 constructors makes `match` long.
- Common idiom: split into helpers grouping related cases.

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

`category : status -> [> ...]`.

- The category is a small "polymorphic variant" (different OCaml feature, mentioned in passing).
- Point: when constructors have natural groupings, encode them with helper functions.

:::

:::slide

## Activity

Given:

```ocaml
type event =
  | Click of { x : int; y : int }
  | Key of char
```

Write `describe : event -> string` that returns a useful summary
of each event.

:::

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

- Two cases, each destructuring the payload as needed.

:::

:::slide

## What's next

- Lecture 6: the **tutorial** for Module 5.
- Build a small AST walker.
- Uses every pattern shape: literals, variables, wildcards, nesting, or-patterns, guards.

:::

## Reading

- **Cornell CS3110**, *Record and variant patterns*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
