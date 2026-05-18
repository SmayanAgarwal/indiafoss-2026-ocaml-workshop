---
title: "Tutorial: a tiny JSON-like value type"
lecture_no: 6
week: 4
duration_target_min: 28
concepts: [worked ADT design, recursive variants, structural recursion, pretty printing]
keywords: [OCaml, ADT, JSON, recursive variant, structural recursion, tutorial]
activity_question: "Extend the [json] type with a [Null] constructor. Update [pretty] and [depth] to handle it. What does the compiler tell you to do?"
think_about_this: "If [pretty] returned a different output for [JNumber 3] vs [JNumber 3.0], would the round-trip [parse (pretty x) = x] still hold? What does that say about the design of [JNumber]?"
reading:
  - title: "Cornell CS3110, Algebraic data types and pattern matching"
    url: https://cs3110.github.io/textbook/chapters/data/intro.html
---

# Tutorial for Module 4

We design a small recursive ADT (a JSON-like value type), build
two operations on it, and use the full Module 4 toolkit:
variants, records, recursion, `option`.

:::slide

## The type

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list
```

Six constructors: the standard JSON kinds. The recursive cases are
`JArray` (a list of `json`s) and `JObject` (a list of key-value
pairs where each value is a `json`).

A small example:

```ocaml
let value =
  JObject [
    "name", JString "Alice";
    "age",  JNumber 30.0;
    "pets", JArray [JString "cat"; JString "dog"];
    "alive", JBool true
  ]
```

:::

:::slide

## Operation 1: depth

Maximum nesting depth. A `JNull`/`JBool`/`JNumber`/`JString` has
depth 1. A `JArray` or `JObject` has depth 1 + max depth of its
contents.

```ocaml
let rec depth = function
  | JNull | JBool _ | JNumber _ | JString _ -> 1
  | JArray xs ->
      1 + List.fold_left max 0 (List.map depth xs)
  | JObject fields ->
      1 + List.fold_left max 0 (List.map (fun (_, v) -> depth v) fields)

let _ = depth value
```

`int = 2`. The deepest field is `pets`, which is a `JArray`
containing strings (depth 1); the array itself adds 1, total 2.

`JNull | JBool _ | ...` is an *or-pattern*: it matches any of the
listed constructors. The compiler treats it as one case.

:::

:::slide

## Operation 2: lookup

A function that finds a top-level field in a `JObject`:

```ocaml
let lookup key = function
  | JObject fields ->
      (try Some (List.assoc key fields)
       with Not_found -> None)
  | _ -> None

let _ = lookup "name" value
let _ = lookup "phone" value
let _ = lookup "name" (JString "not an object")
```

`Some (JString "Alice")`, `None`, `None`.

The function returns `json option`. It's `None` when the input
isn't a `JObject` *or* when the key isn't present. `List.assoc`
raises `Not_found`; we catch and turn into `None`.

:::

We are using a try/with here for the first time. Module 7 covers
exceptions properly. For now, read it as "if `List.assoc` raises
`Not_found`, the whole expression is `None`; otherwise wrap the
result in `Some`."

The cleaner OCaml idiom is `List.assoc_opt`, which returns an
option directly:

```ocaml
let lookup key = function
  | JObject fields -> List.assoc_opt key fields
  | _ -> None
```

We'll prefer this style going forward.

:::slide

## Operation 3: a pretty printer

```ocaml
let rec pretty = function
  | JNull -> "null"
  | JBool true -> "true"
  | JBool false -> "false"
  | JNumber n -> string_of_float n
  | JString s -> "\"" ^ s ^ "\""
  | JArray xs ->
      "[" ^ String.concat ", " (List.map pretty xs) ^ "]"
  | JObject fields ->
      let one (k, v) = "\"" ^ k ^ "\": " ^ pretty v in
      "{" ^ String.concat ", " (List.map one fields) ^ "}"

let _ = pretty value
```

A long string like:

```
{"name": "Alice", "age": 30., "pets": ["cat", "dog"], "alive": true}
```

Each constructor gets a case; arrays and objects recurse. Notice we
*didn't* handle escaping inside strings (a real JSON pretty-printer
would escape `\`, `"`, control characters). For a toy ADT, this is
the spine.

:::

:::slide

## Operation 4: shallow update

Replace a field if it exists; add it if not. Returns a new `json`
value (immutable update):

```ocaml
let set_field key new_value = function
  | JObject fields ->
      let rec go = function
        | [] -> [(key, new_value)]
        | (k, _) :: rest when k = key ->
            (key, new_value) :: rest
        | pair :: rest -> pair :: go rest
      in
      JObject (go fields)
  | other -> other

let with_phone = set_field "phone" (JString "555-1234") value
let _ = lookup "phone" with_phone
```

`Some (JString "555-1234")`. The original `value` is unchanged;
`with_phone` is a fresh value with the field added.

This is structural recursion over the list of fields. We use a
*when-clause* (`when k = key`) on the pattern: it adds a runtime
guard that lets us distinguish "found the key" from "different
key". When-clauses are covered properly in Module 5.

:::

:::slide

## The shape of Module 4

This tutorial used everything:

- **Variants** (`json` itself).
- **Recursive types** (`json` contains `json list`).
- **Records** (none here, but `JObject` carries a list of
  key-value pairs; if we wanted named fields we'd use a record).
- **Tuples** (key-value pairs in `JObject`).
- **`option`** (return type of `lookup`).
- **Pattern matching** (every operation).
- **Recursion** (every operation on the recursive constructors).

This is the everyday Module 4 toolkit. You will reach for these
pieces in nearly every OCaml program you write.

:::

:::slide

## Activity

Add a `Null` constructor to `json`... wait, we already have
`JNull`.

Try this instead: extend `json` with a `JFloat of float` (keep
`JNumber of float` for the existing case; pretend the format used
to be loose and you're tightening it). Update `pretty` and `depth`
to handle the new case.

What does the compiler tell you about every other function on
`json`?

:::

:::slide

## Activity discussion

Adding a new constructor:

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JFloat of float       (* new *)
  | JString of string
  | JArray of json list
  | JObject of (string * json) list
```

The compiler now warns *every match* on `json` that doesn't handle
`JFloat`: `depth`, `pretty`, `set_field`, etc. You go down the
list and add a `| JFloat f -> ...` clause to each.

This is the *refactor-with-the-compiler* property. You don't have
to find call sites by reading; the compiler finds them for you and
won't be quiet until they're all handled.

:::

:::slide

## What you should be able to do now

After Module 4 you can:

- Bundle multiple values with tuples (`(x, y)`) and records
  (`{ x = ...; y = ... }`).
- Express "this or that" with variants.
- Build recursive types like lists, trees, expressions.
- Write functions over recursive types by pattern matching.
- Use `option` and `result` to express "maybe" and "succeeded or
  not" without nulls.

Module 5 zooms in on **pattern matching** itself: the syntax
features we've been sketching (or-patterns, when-clauses,
exhaustiveness checking, nested patterns, the `function`
shorthand) and how they fit together.

:::

## Reading

- **Cornell CS3110**, *Algebraic data types and pattern matching*:
  <https://cs3110.github.io/textbook/chapters/data/intro.html>
