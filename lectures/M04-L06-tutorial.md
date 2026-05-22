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
  - title: "Cornell CS3110, Algebraic data types"
    url: https://cs3110.github.io/textbook/chapters/data/algebraic_data_types.html
  - title: "Real World OCaml, Variants"
    url: https://dev.realworldocaml.org/variants.html
---

# Tutorial for Module 4


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Tutorial: a tiny JSON-like value type</h2>
<p class="title-slide-label">Module 4 &middot; Lecture 6</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The five preceding lectures introduced the pieces:
[tuples](M04-L01-tuples.html), [records](M04-L02-records.html),
[variants](M04-L03-variants.html),
[recursive variants](M04-L04-recursive-types.html),
[`option`](M04-L05-option-and-aliases.html), and
[type abbreviations](M04-L05-option-and-aliases.html#type-abbreviations).
This tutorial puts them all together by walking through the
design of a small algebraic data type, building a handful of
operations on it, and showing the rhythm of writing data-driven
OCaml code.

The example is a *JSON-like value type*: a single OCaml type that
represents arbitrary JSON values (numbers, strings, booleans,
arrays, objects, null). [JSON](https://www.json.org/) is a small
enough format to fit in one lecture but rich enough to exercise
every piece of Module 4. We will define the type, write three
operations (`depth`, `lookup`, `pretty`), and then experience the
"add a constructor, follow the compiler's warnings" workflow.

If you have not yet written non-trivial recursive code on a
recursive variant, this is the lecture to slow down on and try
the examples in a top-level.
[Module 5](M05-L01-basic-patterns.html) will rely heavily on the
pattern matching idioms we use here.

## The type

A JSON value is one of: `null`, a boolean, a number, a string, an
array of JSON values, or an object (a map from strings to JSON
values). In OCaml that maps directly to a variant with six
constructors:

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list
```

Notice the recursion: `JArray` carries a `json list`, and
`JObject` carries a `(string * json) list`. Both refer back to
`json`. That self-reference is what allows JSON values to nest
arbitrarily.

Notice also the *tuple* `(string * json)` for object entries:
each entry is a key (string) and a value (json). We could have
defined a small record `type field = { key : string; value : json }`
instead; the tuple is more concise for this short-lived pair, and
matches the standard library's *association list* convention used
by `List.assoc_opt`.

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

- Six constructors: the standard JSON kinds.
- Recursive: `JArray of json list`; `JObject of (string * json) list`.

:::

:::slide

## The type: an example value

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list
let value =
  JObject [
    "name", JString "Alice";
    "age",  JNumber 30.0;
    "pets", JArray [JString "cat"; JString "dog"];
    "alive", JBool true
  ]
```

- Nesting just falls out: `"pets"` is itself a `JArray` of `JString`s.

:::

The example value, modelled as a JSON object, has four fields. One
of those fields (`"pets"`) is itself a `JArray` of `JString`s. The
type lets all of these nest naturally; the constructors carry the
structure.

The
["make illegal states unrepresentable" slogan from M04-L03](M04-L03-variants.html#parameterised-variants)
applies here. There is no way to build a `json` that has, say, a
"key" without a "value": each object entry is a pair, and a pair
must have both components. There is no way to use a value where a
key is expected: the type forces strings as keys. The compiler
enforces all of this at construction time.

## Operation 1: depth

The maximum nesting depth of a JSON value: a scalar has depth 1; a
`JArray` or `JObject` has depth `1 + max depth of contents`.

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list
let value =
  JObject [
    "name", JString "Alice";
    "age",  JNumber 30.0;
    "pets", JArray [JString "cat"; JString "dog"];
    "alive", JBool true
  ]
let rec depth = function
  | JNull | JBool _ | JNumber _ | JString _ -> 1
  | JArray xs ->
      1 + List.fold_left max 0 (List.map depth xs)
  | JObject fields ->
      1 + List.fold_left max 0 (List.map (fun (_, v) -> depth v) fields)

let _ = depth value
```

The result for `value` is `3`: the outer object adds 1, the `pets`
array adds another 1, the inner strings give 1. Total 3.

:::slide

## Operation 1: depth

The maximum nesting depth: scalars depth 1, containers `1 + max
depth of contents`.

- Scalars (`JNull` / `JBool` / `JNumber` / `JString`): depth 1.
- `JArray` or `JObject`: 1 + max depth of contents.
- `A | B | C` is an **or-pattern**: matches any listed constructor.

:::

:::slide

## Operation 1: depth, the code

```ocaml
type json =
  | JNull | JBool of bool | JNumber of float | JString of string
  | JArray of json list | JObject of (string * json) list
let value =
  JObject [ "name", JString "Alice";
            "pets", JArray [JString "cat"; JString "dog"] ]
let rec depth = function
  | JNull | JBool _ | JNumber _ | JString _ -> 1
  | JArray xs ->
      1 + List.fold_left max 0 (List.map depth xs)
  | JObject fields ->
      1 + List.fold_left max 0 (List.map (fun (_, v) -> depth v) fields)

let _ = depth value
```

:::

Two pieces of new syntax to note:

**Or-patterns.** The clause `JNull | JBool _ | JNumber _ | JString
_ -> 1` matches *any* of the four listed constructors and produces
the same result. This is OCaml's way to say "all of these cases
get the same treatment." The vertical bar inside a single clause
plays the same role as `|` between top-level constructors in a type
declaration.
[M05-L02](M05-L02-nested-and-or-patterns.html#or-patterns-shared-right-hand-sides)
covers or-patterns in detail.

**`List.fold_left`.** This is a higher-order function we will see
in [Module 6](M06-L04-fold.html); for now, read
`List.fold_left max 0 xs` as "the maximum of `xs`, with `0` as the
answer for the empty list." The combination
`List.fold_left max 0 (List.map depth xs)` computes the maximum
depth of `xs`, or `0` if `xs` is empty. If you have not seen
`fold_left` yet, you can write this with explicit recursion
instead:

```ocaml
let rec max_in = function
  | [] -> 0
  | x :: rest -> max x (max_in rest)
```

and call `1 + max_in (List.map depth xs)`. The two versions
compute the same value; `fold_left` is the idiomatic OCaml
phrasing.

## Operation 2: lookup

A function that finds a top-level field in a `JObject`, returning
the value or `None`. The signature is `lookup : string -> json ->
json option`.

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list
let value =
  JObject [
    "name", JString "Alice";
    "age",  JNumber 30.0;
  ]

let lookup key = function
  | JObject fields -> List.assoc_opt key fields
  | _ -> None

let _ = lookup "name" value
let _ = lookup "phone" value
let _ = lookup "name" (JString "not an object")
```

The function returns `Some (JString "Alice")` for `lookup "name"
value`, `None` for the missing key, and `None` for "input isn't an
object."

:::slide

## Operation 2: lookup

Find a top-level field in a `JObject`. Signature:
`lookup : string -> json -> json option`.

- Returns `json option`.
- `None` when input isn't a `JObject` or the key isn't present.
- `List.assoc_opt`: stdlib helper for association-list lookup.

:::

:::slide

## Operation 2: lookup, the code

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list
let value =
  JObject [
    "name", JString "Alice";
    "age",  JNumber 30.0;
  ]
let lookup key = function
  | JObject fields -> List.assoc_opt key fields
  | _ -> None

let _ = lookup "name" value
let _ = lookup "phone" value
let _ = lookup "name" (JString "not an object")
```

- Results: `Some (JString "Alice")`, `None`, `None`.

:::

`List.assoc_opt` is the version of `List.assoc` that returns an
option instead of raising `Not_found`. It is the idiomatic choice
for any code that wants to handle the "key missing" case
explicitly, rather than catch an exception.

The `_ -> None` wildcard case captures any non-`JObject` input.
Here it is appropriate: the meaning is "lookup on a non-object
returns `None`," which is a stable contract that does not depend
on which other constructors `json` has. If we ever add a new
constructor like `JBinary of bytes`, the wildcard still matches
it sensibly.

## Operation 3: a pretty printer

Now a function that turns a `json` value into a string. The
signature is `pretty : json -> string`.

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list
let value =
  JObject [
    "name", JString "Alice";
    "age",  JNumber 30.0;
    "pets", JArray [JString "cat"; JString "dog"];
    "alive", JBool true
  ]
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

The output for `value` is something like:

```
{"name": "Alice", "age": 30., "pets": ["cat", "dog"], "alive": true}
```

:::slide

## Operation 3: a pretty printer

Turn a `json` value into a string. Signature:
`pretty : json -> string`.

- One clause per constructor.
- Arrays and objects **recurse**.
- We skip string escaping. A real printer escapes `\`, `"`, etc.

:::

:::slide

## Operation 3: pretty printer, the code

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list
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
```

:::

Two further pattern-matching idioms appear here:

**Matching constants inside a constructor.** The clauses `JBool
true -> "true"` and `JBool false -> "false"` pattern-match on the
*payload* as well as the constructor. The pattern `JBool true`
matches only `JBool true`, not `JBool false`. Patterns nest in this
way;
[M05-L02](M05-L02-nested-and-or-patterns.html#patterns-inside-constructors)
covers nested patterns in detail.

**Local functions.** Inside the `JObject` case, we define a local
function `one` that converts a key-value pair to a string. This is
the
[M03-L05 idiom](M03-L05-local-and-mutual.html#local-helpers-definitions-inside-let-in)
of using `let` to give a name to a small helper that is only used
here. The alternative is to inline an anonymous function:
`List.map (fun (k, v) -> "\"" ^ k ^ "\": " ^ pretty v) fields`.
Either form is fine.

A real JSON printer would also handle escaping: a backslash in a
string should be output as `\\`, a double quote as `\"`, etc. We
have skipped that for clarity. A toy ADT is enough to demonstrate
the recursion pattern; production printers handle dozens of
edge cases that are not the point of this lecture.

## Operation 4: shallow update

A function that produces a *new* JSON value with a top-level field
either replaced (if it exists) or added (if it does not). This is
a "functional update" operation, mirroring what we did with
records but for an association list.

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list
let value =
  JObject [
    "name", JString "Alice";
    "age",  JNumber 30.0;
  ]
let lookup key = function
  | JObject fields -> List.assoc_opt key fields
  | _ -> None

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

The original `value` is unchanged; `with_phone` is a fresh value
with the `phone` field added.

:::slide

## Operation 4: shallow update

Produce a new JSON value with a top-level field either replaced
or added. Functional update, mirroring records but for an
association list.

- Returns a new `json` (immutable update).
- Structural recursion over the list of fields.
- `when k = key`: a **guard** on the pattern. Covered in Module 5.

:::

:::slide

## Operation 4: shallow update, the code

```ocaml
type json =
  | JNull | JBool of bool | JNumber of float | JString of string
  | JArray of json list | JObject of (string * json) list
let value = JObject [ "name", JString "Alice"; "age", JNumber 30.0 ]
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
```

:::

This brings in two more pieces of pattern-matching machinery:

**Inner recursion.** The local function `go` walks the
association list, looking for a key match. It is itself
structurally recursive on the list.

**Guards (`when` clauses).** The pattern `(k, _) :: rest when k =
key` matches a non-empty list whose head pair has a key equal to
`key`. The `when` clause is a runtime check that further filters
the pattern. Without it, both the "match the first pair" and the
"match any other pair" cases would have the same pattern shape,
and OCaml would not be able to distinguish them.
[M05-L03](M05-L03-guards.html) will cover when-clauses in full.

The structure of `go` is:

- Empty list: the key is not in the list. Add it.
- Head is the right key: replace.
- Head is a different key: keep it; recurse on the rest.

That covers all three sub-cases of "what to do at each step."

## The shape of Module 4

This tutorial used every piece introduced in the module:

:::slide

## The shape of Module 4

This tutorial used everything:

- **Variants** (`json` itself).
- **Recursive types** (`json` contains `json list`).
- **Tuples** ((string * json) for object entries).
- **`option`** (return type of `lookup`).
- **Pattern matching** (every operation).
- **Recursion** (every operation on recursive constructors).

:::

You will reach for some subset of these pieces in nearly every
OCaml program you write. Some programs use one heavily and another
lightly: a parser is mostly variants and recursion; a configuration
loader is mostly records; a search algorithm is mostly tuples and
lists. The Module 4 toolkit is broad on purpose; the rest of the
course uses these pieces in different combinations.

## A short check

:::quiz mcq id=M04-L06-q2
What does `pretty (JArray [])` evaluate to?

- [ ] `""`
- [ ] `"null"`
- [x] `"[]"`
- [ ] A runtime error.

**Why:** the `JArray` branch is `"[" ^ String.concat ", " (List.map
pretty xs) ^ "]"`. With `xs = []`, `List.map pretty xs = []` and
`String.concat ", " []` is `""`. So we get `"[" ^ "" ^ "]"` = `"[]"`.
:::

:::quiz code id=M04-L06-q1
Write `count_nulls : json -> int` that returns the number of `JNull`
constructors anywhere inside a `json` value (including nested
inside arrays and object values).

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list

let rec count_nulls = function
  | _ -> failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (count_nulls JNull = 1) "single null";
  check (count_nulls (JBool true) = 0) "bool";
  check (count_nulls (JArray [JNull; JNumber 1.0; JNull]) = 2) "array of two";
  check (count_nulls (JObject ["a", JNull; "b", JArray [JNull; JNull]]) = 3) "nested";
  check (count_nulls (JArray []) = 0) "empty array";
  print_endline "all tests passed"
```
:::

Reference solution:

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list

let rec count_nulls = function
  | JNull -> 1
  | JBool _ | JNumber _ | JString _ -> 0
  | JArray xs -> List.fold_left (fun acc x -> acc + count_nulls x) 0 xs
  | JObject fields ->
      List.fold_left (fun acc (_, v) -> acc + count_nulls v) 0 fields
```

Each constructor gets one clause; the recursive ones sum the
counts from their children using `List.fold_left`.

## Activity: extending the type

:::slide

## Activity

Extend `json` with a new constructor `JFloat of float` (keep
`JNumber of float` for the existing case; pretend the format used
to be loose and you're tightening it). Update `pretty` and `depth`
to handle it.

What does the compiler tell you about every other function on
`json`?

:::

:::slide

## Activity discussion

Adding a new constructor:

```ocaml skip
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JFloat of float       (* new *)
  | JString of string
  | JArray of json list
  | JObject of (string * json) list
```

- Compiler now warns every `match` on `json` that misses `JFloat`.
- Affects `depth`, `pretty`, `set_field`, `count_nulls`, etc.
- Add `| JFloat f -> ...` to each; repeat until silent.
- **Refactor with the compiler**: it finds call sites, not you.

:::

This is the experience
[M04-L03 promised](M04-L03-variants.html#adding-a-case-refactor-with-the-compiler):
a "punch list" of every function that touched the variant, served
up by the compiler. Each function that pattern-matched explicitly
on `json` will now get a warning pointing at the missing `JFloat`
case. You add the case to each, recompile, repeat. When the
warnings stop, the refactor is complete.

The functions that did *not* use a wildcard catch-all get the
warnings; the ones that did (like `lookup`'s `_ -> None`) silently
absorb the new constructor under their wildcard. The wildcard is
sometimes what you want (here, "any non-object input gives None"
is a stable contract), but it does hide refactor sites. The
trade-off is real.

## What you should be able to do now

:::slide

## What you should be able to do now

After Module 4 you can:

- Bundle values with tuples and records.
- Express "this or that" with variants.
- Build recursive types like lists, trees, expressions.
- Write functions over recursive types by pattern matching.
- Use `option` and `result` instead of nulls.

Module 5: **pattern matching** in depth (or-patterns, when-clauses,
exhaustiveness, nested patterns, `function`).

:::

You now have the full vocabulary for modelling data in OCaml. The
combination of records, variants, tuples, and recursion is enough
to express essentially any data shape you encounter.
[Module 5](M05-L01-basic-patterns.html) sharpens the
*consumption* side: pattern matching has more features than we
have used in this module, and they are the everyday tools for
writing concise code on these data types.

## Reading

- **Cornell CS3110**, *Algebraic data types*:
  <https://cs3110.github.io/textbook/chapters/data/algebraic_data_types.html>
- **Real World OCaml**, *Variants*:
  <https://dev.realworldocaml.org/variants.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
