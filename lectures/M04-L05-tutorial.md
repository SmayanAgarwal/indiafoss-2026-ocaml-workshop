---
title: "Tutorial: a tiny JSON-like value type"
lecture_no: 5
week: 4
duration_target_min: 28
concepts: [worked ADT design, recursive variants, structural recursion, pretty printing]
keywords: [OCaml, ADT, JSON, recursive variant, structural recursion, tutorial]
activity_question: "Extend the [json] type with a [JDate of string] constructor and construct a JSON object with fields [release], [authors], and [version]."
think_about_this: "Would you represent a JSON object as an association list, a Map, or a record? Each is a different design choice; what does each cost the consumer, and what does each cost the implementer?"
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
<p class="title-slide-label">Module 4 &middot; Lecture 5</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The five preceding lectures introduced the pieces:
[tuples](M04-L01-tuples.html), [records](M04-L02-records.html),
[variants](M04-L03-variants.html),
[recursive variants](M04-L04-recursive-types.html),
[`option`](M04-L04-recursive-types.html), and
[type abbreviations](M04-L04-recursive-types.html#type-abbreviations).
This tutorial puts them all together by walking through the
design of a small algebraic data type, building a handful of
operations on it, and showing the rhythm of writing data-driven
OCaml code.

The example is a *JSON-like value type*: a single OCaml type
that represents arbitrary JSON values (numbers, strings,
booleans, arrays, objects, null). [JSON](https://www.json.org/)
is a small enough format to fit in one lecture but rich enough
to exercise every piece of Module 4. We will design the type,
construct several concrete values, weigh a couple of design
decisions, and finish by extending the type with a new
constructor.

We are deliberately staying on the *design* side of the toolkit.
Walking a JSON value (writing `depth`, `lookup`, or a pretty
printer) needs pattern matching, which gets its full treatment
in [Module 5](M05-L01-basic-patterns.html); we will return to
`json` there.

## What is JSON?

[JSON](https://www.json.org/) (JavaScript Object Notation) is the
data format used to carry structured data between programs. Every
web API, configuration file, and inter-service message format you
have used likely speaks JSON. It is built from six kinds of
value:

- `null`: the explicit "no value."
- Booleans: `true` or `false`.
- Numbers: integers or decimals (JSON does not distinguish).
- Strings: text in double quotes.
- Arrays: ordered lists of JSON values inside `[...]`.
- Objects: key-value bags inside `{...}` where keys are strings.

A couple of concrete examples. A single number is already a
valid JSON value:

```json
3.14
```

A web request for a single user might look like:

```json
{
  "name": "Alice",
  "age": 30,
  "admin": true
}
```

And nesting (arrays and objects inside other values) is what
makes the format expressive. A book with multiple authors:

```json
{
  "title": "Real World OCaml",
  "authors": ["Yaron Minsky", "Anil Madhavapeddy", "Jason Hickey"],
  "year": 2022,
  "out_of_print": false
}
```

A JSON value can nest *any* of the six kinds inside arrays or
objects. The grammar is genuinely recursive: an object's value can
itself be an array, whose elements can themselves be objects, and
so on.

:::slide

## What is JSON?

Six kinds of value:

- `null`
- booleans (`true`, `false`)
- numbers (`3.14`, `42`)
- strings (`"hello"`)
- arrays (`[...]`)
- objects (`{key: value, ...}`)

Used by every web API and most configuration files.

:::

:::slide

## JSON: an object example

```json
{
  "title": "Real World OCaml",
  "authors": ["Minsky", "Madhavapeddy", "Hickey"],
  "year": 2022,
  "out_of_print": false
}
```

- An *object* with four keys.
- Values are: string, array of strings, number, boolean.

:::

:::slide

## JSON nests

```json
{
  "user": {
    "name": "Alice",
    "address": {
      "city": "Chennai",
      "pin": 600036
    }
  },
  "orders": [
    { "id": 7, "total": 250.0 },
    { "id": 9, "total": 80.5 }
  ]
}
```

- Objects inside objects, arrays of objects.
- A value's children can be **any** JSON value.
- Grammar is genuinely **recursive**; we will model that
  directly in OCaml next.

:::

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

## Constructing more JSON values

Let's build a few more concrete values to make the type feel
ordinary. A flat object:

```ocaml
type json =
  | JNull
  | JBool of bool
  | JNumber of float
  | JString of string
  | JArray of json list
  | JObject of (string * json) list

let book =
  JObject [
    "title",  JString "Real World OCaml";
    "year",   JNumber 2022.0;
    "online", JBool true
  ]
```

An array of scalars:

```ocaml
let primes = JArray [JNumber 2.0; JNumber 3.0; JNumber 5.0; JNumber 7.0]
```

A deeply nested value, mirroring the JSON nesting example from the
intro:

```ocaml
let order =
  JObject [
    "user", JObject [
      "name", JString "Alice";
      "address", JObject [
        "city", JString "Chennai";
        "pin",  JNumber 600036.0;
      ]
    ];
    "items", JArray [
      JObject ["id", JNumber 7.0; "total", JNumber 250.0];
      JObject ["id", JNumber 9.0; "total", JNumber 80.5];
    ];
    "delivered", JNull;
  ]
```

The OCaml value is the JSON value. The constructors carry the
shape; the compiler enforces it. There is no way to build a
`JObject` whose "key" is a `JNumber`, or a `JArray` containing a
mix of `json` and raw OCaml `string`s; the type rules those out.

:::slide

## Constructing more JSON values

```ocaml
let book =
  JObject [
    "title",  JString "Real World OCaml";
    "year",   JNumber 2022.0;
    "online", JBool true
  ]

let primes = JArray [JNumber 2.0; JNumber 3.0; JNumber 5.0; JNumber 7.0]
```

- A flat object and a flat array.
- Each `JObject` entry is a tuple `(string, json)`.

:::

:::slide

## Constructing more JSON values: nesting

```ocaml
let order =
  JObject [
    "user",  JObject ["name", JString "Alice"];
    "items", JArray [
      JObject ["id", JNumber 7.0; "total", JNumber 250.0];
      JObject ["id", JNumber 9.0; "total", JNumber  80.5];
    ];
    "delivered", JNull;
  ]
```

- Object inside object, array of objects; the OCaml value *is*
  the JSON, recursive structure and all.

:::

## Design decision: representing objects

Why did we use `(string * json) list` for objects, rather than
something else? The choices on the table for "map from string keys
to JSON values" include:

- Association list: `(string * json) list`. What we picked.
- Map from `Stdlib.Map`: `string -> json` view via a tree
  structure. Faster lookup, more imports.
- Hashtable: `(string, json) Hashtbl.t`. Faster lookup, but
  mutable; we avoided that.

For pedagogy and JSON's typical "a few keys per object" shape, the
association list is plenty. For a production-grade JSON library,
you would reach for a `Map` or hashtable. The type expresses the
choice; consumers see it and program accordingly.

A second decision worth flagging: a JSON object's keys are
*unordered* in the spec, but a `(string * json) list` *is*
ordered. Our representation preserves whatever order the
constructor was called with. That can be a feature (round-trip
print stable order) or a bug (two equivalent JSON values compare
unequal because their keys are listed in different orders). The
spec is permissive; the OCaml type, more specific.

:::slide

## Design decision: representing objects

`JObject of (string * json) list` is one of several choices:

- Association list: `(string * json) list`. *Our choice.* Simple,
  small.
- Stdlib `Map`: `(string, json) Map.t`. Faster lookup.
- `Hashtbl.t`: faster lookup, but **mutable**.

- For a tutorial / few-key objects, the assoc list is fine.
- Production JSON libraries reach for `Map` or `Hashtbl`.

:::

## Design decision: `JNull` vs `json option`

We chose to have a `JNull` constructor inside `json` rather than
expressing "maybe a JSON value" as `json option`. Why?

`option` would force the caller to handle absence even when the
JSON spec *itself* says null is a value. Consider a key whose
value is intentionally `null`:

```json
{ "spouse": null }
```

The JSON value at `"spouse"` *is* `null`; it is not "no value."
Representing it as `JObject [("spouse", JNull)]` carries that
distinction cleanly. Compare with `JObject [("spouse", None)]`,
which conflates "the value is JSON null" with "the key has no
associated value."

The general rule: use `option` when the *consumer* of an API may
need to handle absence; use a dedicated constructor when *the
domain itself* has an explicit "null" or "empty" notion.

:::slide

## Design decision: `JNull` vs `json option`

- We chose `JNull` *inside* the `json` variant.
- Alternative: leave it out; force callers to use `json option`.

Why a constructor:

- JSON null is a **first-class value** in the spec.
- `JObject [("spouse", JNull)]` says "value present, equals null."
- `JObject [("spouse", None)]` would conflate that with "key
  missing."

Rule of thumb: `option` for *consumer* uncertainty, a dedicated
constructor for *domain* nullness.

:::

## The shape of Module 4

This tutorial used every Module 4 idea:

- **Tuples** for object entries (`string * json`).
- **Records** would also fit (we will use them in the activity).
- **Variants** with payloads for the `json` constructors.
- **Recursive variants** for nested arrays and objects.
- **Parameterised variants** in the underlying `'a list`.
- **`option`** when we needed to express "maybe."

What we have *not* used yet is pattern matching, the standard way
to take any of these values apart. That is the whole of
[Module 5](M05-L01-basic-patterns.html). With pattern matching
in hand, we can write `depth`, `lookup`, `pretty`, and
"refactor-with-the-compiler" workflows for evolving the variant.

:::slide

## The shape of Module 4

This tutorial used:

- **Tuples** (string * json for entries).
- **Variants** with payloads (the json constructors).
- **Recursive variants** (nested arrays and objects).
- **Parameterised variants** (`'a list`).
- **`option`** when "maybe" is in play.

What we have not used yet: **pattern matching**. That is the
whole of [Module 5](M05-L01-basic-patterns.html); we will write
`depth`, `lookup`, and `pretty` for `json` then.

:::

## Activity: extending the type

:::slide

## Activity

Extend `json` with a new constructor `JDate of string` that
represents an ISO-8601 date string (e.g., `"2026-06-15"`) as a
distinct kind of value. Then construct a JSON object with:

- A `release` field whose value is `JDate "2026-06-15"`.
- An `authors` field whose value is a JSON array of two strings.
- A `version` field whose value is the number `1.0`.

:::

:::slide

## Activity discussion

Add one constructor:

```text
type json =
  ...
  | JDate of string                  (* new *)
```

Construct:

```ocaml
let release_notes =
  JObject [
    "release", JDate "2026-06-15";
    "authors", JArray [JString "Alice"; JString "Bob"];
    "version", JNumber 1.0;
  ]
```

- One new constructor; everything else is unchanged.
- The type checker accepts the new value; nothing else needs
  to compile differently.

:::

## What you should be able to do now

:::slide

## What you should be able to do now

After Module 4 you can:

- Bundle values with tuples and records.
- Express "this or that" with variants.
- Build recursive types like lists, trees, expressions.
- Use `option` and `result` instead of nulls.
- Design a domain type with the right mix of these pieces.

Module 5: **pattern matching** (the way to take any of these
values apart) in depth.

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
