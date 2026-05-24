---
title: "Nested patterns and or-patterns"
lecture_no: 2
week: 5
duration_target_min: 22
concepts: [nested patterns, or-patterns, tuple patterns inside variants, alternation]
keywords: [OCaml, pattern matching, nested patterns, or-patterns, alternation]
activity_question: "Write [first_of_pair_in_list : (int * int) list -> int option] returning the first component of the first pair, or [None] if the list is empty. Use nested patterns."
think_about_this: "An or-pattern lets multiple shapes share a right-hand side. What constraint does the compiler impose on the variables bound by each alternative?"
reading:
  - title: "Cornell CS3110, Pattern matching (continued)"
    url: https://cs3110.github.io/textbook/chapters/data/pattern_matching.html
---

# Nested patterns and or-patterns


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Nested patterns and or-patterns</h2>
<p class="title-slide-label">Module 5 &middot; Lecture 2</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The pattern forms we saw in [Lecture 1](M05-L01-basic-patterns.html)
(literals, variables, wildcards) match a value at exactly one level:
"this is the constant `0`", or "this is anything, call it `x`." Real
OCaml values are usually built out of pieces: a [tuple](M04-L01-tuples.html)
holds two things, a [constructor](M04-L03-variants.html#constructors-with-payload)
wraps a payload, a [list](M04-L04-recursive-types.html#lists-are-a-recursive-variant)
is a head followed by a tail. Patterns mirror that nested structure.
A pattern can contain *other patterns* inside it, exactly the way a
value contains other values.

This lecture covers two extensions:

1. **Nested patterns**: a pattern inside another pattern. `Some
   (x, _)` is a pattern with a tuple pattern inside a
   constructor pattern. `(0, _) :: _` is a pattern with a tuple
   inside a cons inside another cons-context.
2. **Or-patterns**: alternation. `1 | 2 | 3` is a pattern that
   matches `1`, `2`, or `3`. Or-patterns let you give several
   shapes the same right-hand side.

Both forms compose, and you will use them heavily. Almost every
nontrivial pattern match you write uses one or both.

:::slide

## This lecture: nested and or-patterns

- L1's patterns matched at *one level* (literal, variable, wildcard).
- Real values are built of pieces: tuples, constructors, lists.
- Patterns mirror that nested structure: a pattern can contain
  other patterns.
- Two extensions covered here:
  - *Nested* patterns: `Some (x, _)`, `(0, _) :: _`.
  - *Or-patterns*: `1 | 2 | 3`, alternation with one right-hand side.
- Both compose; almost every nontrivial match uses one or both.

:::

## Patterns inside constructors

The most common nested pattern is to look inside a constructor's
payload. We saw [variant types in M04-L03](M04-L03-variants.html)
and you have seen `Some` and `None` and you have seen [records](M04-L02-records.html)
and [lists](M04-L04-recursive-types.html#lists-are-a-recursive-variant).
Here is a record example:

```ocaml
type point = { x : float; y : float }

let describe = function
  | { x = 0.0; y = 0.0 } -> "origin"
  | { x = 0.0; y = _   } -> "on the y-axis"
  | { x = _;   y = 0.0 } -> "on the x-axis"
  | { x = _;   y = _   } -> "somewhere else"

let _ = describe { x = 0.0; y = 0.0 }
let _ = describe { x = 3.0; y = 0.0 }
let _ = describe { x = 1.0; y = 2.0 }
```

:::slide

## Nesting in record patterns

```ocaml
type point = { x : float; y : float }

let describe = function
  | { x = 0.0; y = 0.0 } -> "origin"
  | { x = 0.0; y = _   } -> "on the y-axis"
  | { x = _;   y = 0.0 } -> "on the x-axis"
  | { x = _;   y = _   } -> "somewhere else"
```

`"origin"`, `"on the x-axis"`, `"somewhere else"` for the three calls.

- The values after `=` are themselves patterns.
- A literal `0.0`, a wildcard `_`. **Nested**.
- The compiler matches each field's pattern against that field's value.

:::

Notice that inside the curly braces, we are not just listing
field names: each field is matched against a *pattern*. `x =
0.0` is the field-match pattern "`x` must equal `0.0`." `y = _`
is "`y` can be anything." Both are sub-patterns of the larger
record pattern. When you read the clause `{ x = 0.0; y = 0.0 }`,
read it as: this record's `x`-field matches `0.0`, *and* its
`y`-field matches `0.0`. Both must hold.

A pattern can also nest inside a variant constructor:

```ocaml
type shape =
  | Circle of float
  | Rectangle of float * float

let is_unit_circle = function
  | Circle 1.0 -> true
  | _ -> false

let _ = is_unit_circle (Circle 1.0)
let _ = is_unit_circle (Circle 2.0)
let _ = is_unit_circle (Rectangle (1.0, 1.0))
```

:::slide

## Tuple/value inside a variant

```ocaml
type shape =
  | Circle of float
  | Rectangle of float * float

let is_unit_circle = function
  | Circle 1.0 -> true
  | _ -> false
```

`true`, `false`, `false`.

- `Circle 1.0` requires the constructor to be `Circle`.
- **And** its payload must be exactly `1.0`.
- Two checks combined into one pattern.

:::

The pattern `Circle 1.0` is a constructor pattern (`Circle`) with
a literal pattern (`1.0`) for its payload. The match succeeds if
both checks succeed: the constructor is `Circle`, *and* its
argument equals `1.0`. If you wrote `Circle x`, the second check
would be "x is anything, bind it to the name `x`." If you wrote
`Circle (_)`, the second check would be "anything, do not bind."
The point is that a constructor's payload position takes any
pattern; you choose how specific to be.

The same nesting works for tuple constructors:

```ocaml
let unit_square = function
  | Rectangle (1.0, 1.0) -> true
  | _ -> false
```

The pattern `Rectangle (1.0, 1.0)` looks for the constructor
`Rectangle` whose payload is the tuple `(1.0, 1.0)`. Two literal
patterns nested inside a tuple pattern inside a constructor
pattern. Three levels.

## Nesting in lists

Lists are where nested patterns earn their keep. A list is built
from `[]` (empty) and `::` (cons), and most list-processing
functions pattern-match on those constructors. Once you start
combining `::` with other patterns, the nesting gets interesting
fast.

Here is "the first component of the first pair":

```ocaml
let head_first = function
  | (x, _) :: _ -> Some x
  | [] -> None

let _ = head_first [(1, "a"); (2, "b"); (3, "c")]
let _ = head_first []
```

:::slide

## Nesting in lists

```ocaml
let head_first = function
  | (x, _) :: _ -> Some x
  | [] -> None
```

`Some 1`, `None`.

- Pattern `(x, _) :: _` matches a non-empty list whose head is a pair.
- Binds the first component of that head to `x`.
- Three layers of nesting: cons, tuple, inner positions.

:::

Read the pattern `(x, _) :: _` from the outside in:

1. The outermost shape is `something :: something_else`, a
   non-empty list. Call the two pieces *head* and *tail*.
2. The head is `(x, _)`: a tuple whose first component is bound
   to `x` and whose second is discarded.
3. The tail is `_`: anything, discarded.

So we have three nested patterns in one clause:

- A cons pattern at the top.
- A tuple pattern in the head position.
- Variable and wildcard patterns inside the tuple.

This is the everyday shape for "look inside the first element."
Almost every list-processing function in real OCaml code has at
least one clause that looks like this.

You can go deeper. A pattern can extract the *second* element
too:

```ocaml
let first_two = function
  | a :: b :: _ -> Some (a, b)
  | _ -> None

let _ = first_two [10; 20; 30]
let _ = first_two [10]
let _ = first_two []
```

The pattern `a :: b :: _` matches a list of length at least two:
the first element bound to `a`, the second to `b`, the rest
discarded. This is just `::` cascaded, but read it carefully: it
parses as `a :: (b :: _)`, i.e. a cons whose head is `a` and
whose tail is itself a cons (head `b`, tail anything). The
right-associative reading of `::` is what makes this work.

## A note on reading nested patterns

The trick to reading deeply nested patterns is the same as
reading nested JSON or nested HTML: peel from the outside, and
name what you see at each layer. With practice you will start to
see the shape instinctively. Until then, a useful exercise is to
say the pattern out loud:

"`(x, _) :: _`: a list whose head is a pair, the first component
of the pair bound to `x`, the rest of the pair and the rest of
the list ignored."

If you can say it cleanly in English, the pattern is doing what
you think it does.

## Or-patterns: shared right-hand sides

Often you want several patterns to share the same right-hand
side. A classic example: testing whether a character is a vowel.

```ocaml
let is_vowel = function
  | 'a' | 'e' | 'i' | 'o' | 'u' -> true
  | _ -> false

let _ = is_vowel 'a'
let _ = is_vowel 'b'
```

:::slide

## Or-patterns

```ocaml
let is_vowel = function
  | 'a' | 'e' | 'i' | 'o' | 'u' -> true
  | _ -> false
```

`true`, `false`.

- `'a' | 'e' | 'i' | 'o' | 'u'`: an **or-pattern**, five literals.
- Any one matching triggers the same right-hand side.
- Without or-patterns: five clauses, all returning `true`. Noisy.

:::

The `|` between `'a'`, `'e'`, `'i'`, `'o'`, `'u'` is the
*or-pattern combinator*. It is not the same as the leading `|` at
the start of each clause. The leading `|` separates clauses; the
internal `|` combines sub-patterns. Reading left to right: "match
if the value is `'a'`, or if it is `'e'`, or if it is `'i'`, or
..." If any alternative matches, the whole or-pattern matches and
the right-hand side runs.

Without or-patterns, the same logic needs five clauses:

```text
let is_vowel = function
  | 'a' -> true
  | 'e' -> true
  | 'i' -> true
  | 'o' -> true
  | 'u' -> true
  | _ -> false
```

The or-pattern version is shorter and reads better. It also
groups related cases visually, which makes intent clearer.

Or-patterns work on variants too:

```ocaml
type direction = North | South | East | West

let is_horizontal = function
  | East | West -> true
  | North | South -> false

let _ = is_horizontal East
let _ = is_horizontal North
```

:::slide

## Or-patterns on variants

```ocaml
type direction = North | South | East | West

let is_horizontal = function
  | East | West -> true
  | North | South -> false
```

`true`, `false`.

- Two groups, each sharing a right-hand side.
- Reads almost like English.

:::

`East | West -> true` reads "if it is `East` or `West`, return
true." The two groups partition the four constructors. The
compiler can see that the four constructors are all covered, so
this is exhaustive: no warning needed.

## The binding constraint on or-patterns

There is one rule about or-patterns that, when you violate it,
produces a confusing error message. The rule is:

> Every alternative of an or-pattern must bind *exactly the same
> set of variables*, at *the same types*.

That is, if the left alternative binds `x : int`, the right
alternative must also bind `x : int`. Not `y`; not `x` at a
different type. The reason is that the right-hand side of the
clause references those names, and the compiler needs to know
they are bound regardless of which alternative succeeded.

:::slide

## Constraint: alternatives bind the same names

```ocaml skip
type tagged = A of int | B of int

let _ =
  match A 5 with
  | A x | B y -> x   (* error: y unbound, x unbound on right *)
```

- OCaml rejects this.
- Or-pattern requires all alternatives to bind the **same set of variables**.
- And at **compatible types**.

If both alternatives bind `x` at the same type, the right-hand side
can use `x`:

```ocaml
type tagged = A of int | B of int

let to_int = function
  | A x | B x -> x

let _ = to_int (A 5)
let _ = to_int (B 7)
```

`5` and `7`. Each alternative binds an `int` to `x`.

:::

If you write `| A x | B y -> x`, the compiler complains because
the right-hand side mentions `x`, but `x` is only bound in the
left alternative; if the value were `B`, there would be no `x`.
The reverse problem appears too: if your right-hand side uses
`y`, the compiler complains because `y` is only bound in the
right alternative.

The fix is to use the same name in both alternatives, *and to
mean the same thing by it*. In `A x | B x -> x`, both `A` and `B`
carry an `int`, and we name that `int` `x` in either case. The
right-hand side `x` is then unambiguously typed `int`.

This constraint is what makes or-patterns *type-safe*: the
compiler can guarantee, just from the pattern, that the
right-hand side has consistent types for all the names it
references.

## Combining or-patterns and nesting

Or-patterns can appear *anywhere* a pattern can appear, including
inside other patterns. This lets you write quite elegant clauses:

```ocaml
let summary = function
  | (0 | 1) :: _ -> "starts with 0 or 1"
  | _ :: _       -> "starts with something else"
  | []           -> "empty"

let _ = summary [0; 5; 6]
let _ = summary [1; 5; 6]
let _ = summary [5; 6]
let _ = summary []
```

:::slide

## Or-patterns nested inside other patterns

```ocaml
let summary = function
  | (0 | 1) :: _ -> "starts with 0 or 1"
  | _ :: _       -> "starts with something else"
  | []           -> "empty"
```

- Pattern `(0 | 1) :: _` reads "either 0 or 1, followed by anything".
- Or-pattern appears in the **head position** of a cons.
- Or-patterns can sit inside constructors, tuples, lists.

:::

The pattern `(0 | 1) :: _` says: a non-empty list whose head is
`0` or `1`. The or-pattern `(0 | 1)` sits in the head position of
the cons. The parentheses are necessary: without them, `0 | 1 ::
_` would parse incorrectly. As a rule, parenthesise an or-pattern
whenever it appears nested inside another pattern.

You can also or together more elaborate sub-patterns. Here is "a
non-empty list whose first element is either zero or negative":

```ocaml
let starts_nonpositive = function
  | (0 | -1 | -2 | -3) :: _ -> "small non-positive"
  | _ -> "other"
```

The or-pattern has four literal alternatives. (For a real
"non-positive" check, you would use a guard, which is the topic
of [Lecture 3](M05-L03-guards.html); this is just an illustration.)

## The `as` binder: keep a name for the whole

One more pattern form fits naturally in this lecture: `as`,
which lets you destructure a value *and* keep a name for the
whole thing.

```ocaml
let head_and_full = function
  | (x :: _) as xs -> Some (x, List.length xs)
  | [] -> None

let _ = head_and_full [10; 20; 30]
```

:::slide

## `as` patterns: name what you matched

```ocaml
let head_and_full = function
  | (x :: _) as xs -> Some (x, List.length xs)
  | [] -> None
```

`Some (10, 3)`.

- `(x :: _) as xs` destructures: `x` is the head.
- Also binds the **whole** list to `xs`.
- Without `as`: you would `match` and then rebuild, or use the
  outer variable.

:::

The pattern `(x :: _) as xs` first destructures the value: `x`
becomes the head of the list. Then `as xs` binds the *entire
matched list* to the name `xs`. Inside the right-hand side, `x`
is the head and `xs` is the full list. The pattern matched the
same shape it would have matched without `as`; the only addition
is the name `xs` for the whole.

This is occasionally just what you want. The alternative is to
match without `as`, and then refer to the outer parameter
directly. That works only if the outer parameter has a name;
inside a `function` shorthand, it does not, and `as` is the
cleanest way to keep the name.

`as` reads almost like an English aside: "the head is `x`, and
the whole list is `xs`."

## Or-patterns with `as`

You can also use `as` with or-patterns to name the whole
matched value across alternatives:

```ocaml
type event =
  | Click
  | Tap
  | Drag
  | Scroll

let _ =
  match Click with
  | (Click | Tap) as touch -> "touchlike: " ^ (match touch with Click -> "click" | Tap -> "tap" | _ -> assert false)
  | other -> "other"
```

This is a bit awkward in practice; we are showing it only to
note that `as` binds whichever alternative matched. In most
real code you do not need this; an or-pattern with the same
binding name in each alternative is enough.

## Putting it together: a small parser shape

A common shape in real code is a multi-clause match where each
clause uses nesting *and* or-patterns:

```ocaml
type token =
  | Int of int
  | Plus
  | Minus
  | Times
  | LParen
  | RParen

let is_operator = function
  | Plus | Minus | Times -> true
  | Int _ | LParen | RParen -> false
```

The or-pattern `Plus | Minus | Times` groups the three operator
constructors. The complementary or-pattern groups the
non-operators. Notice `Int _`: that is a constructor pattern
with a wildcard payload. We do not care what integer it carries;
we only care that it is an `Int`.

The function reads cleanly because the structure of the data is
mirrored in the structure of the patterns. This is the goal: let
the patterns express *what shape* you are handling, and the
right-hand sides express *what to do*.

## Two checks

:::quiz mcq id=M05-L02-q3
What does `head_and_second [1; 2; 3]` return, given:

```ocaml
let head_and_second = function
  | a :: b :: _ -> Some (a, b)
  | _ -> None
```

- [x] `Some (1, 2)`
- [ ] `Some (1, 3)`
- [ ] `Some (2, 3)`
- [ ] `None`

**Why:** the pattern `a :: b :: _` matches a list with at least
two elements. `a` is the head (`1`), `b` is the next element
(`2`), and the tail (`[3]`) is discarded.
:::

:::quiz mcq id=M05-L02-q2
The compiler rejects this with an error. Why?

```ocaml skip
type t = A of int | B of string

let f = function
  | A x | B x -> x
```

- [ ] Or-patterns are not allowed in `function`.
- [ ] The names `x` clash.
- [x] The two `x`s have incompatible types: `int` in `A`, `string` in `B`.
- [ ] `A` and `B` cannot be grouped.

**Why:** the or-pattern constraint is that every alternative
must bind the same variables at the *same types*. `A x` binds
`x : int`; `B x` binds `x : string`. The compiler cannot give
the right-hand side a consistent type for `x`, so the pattern
is rejected.
:::

A code task:

:::quiz code id=M05-L02-q1
Write `first_of_pair_in_list : (int * int) list -> int option`
returning the first component of the first pair, or `None` if
the list is empty. Use a single clause with a nested pattern for
the non-empty case.

```ocaml
let first_of_pair_in_list xs =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (first_of_pair_in_list [(10, 20); (30, 40)] = Some 10) "two pairs";
  check (first_of_pair_in_list [(5, 5)] = Some 5) "one pair";
  check (first_of_pair_in_list [] = None) "empty";
  print_endline "all tests passed"
```
:::

:::solution

The shape: `function | (x, _) :: _ -> Some x | [] -> None`. The
nested pattern in the first clause extracts the first component
of the first pair in one step.

:::

## Common pitfalls

**Pitfall 1: forgetting parentheses around an or-pattern.** When
an or-pattern sits inside another pattern, parenthesise it.
`(0 | 1) :: _` is correct; `0 | 1 :: _` is parsed differently
and probably not what you meant.

**Pitfall 2: different names in different alternatives.** The
or-pattern constraint says every alternative must bind the same
names. `| A x | B y` will not work if the right-hand side uses
either name. Use the same name in both: `| A x | B x`.

**Pitfall 3: incompatible types in alternatives.** Even with the
same name, the bound types must agree. `| A x | B x` fails if
`A` carries `int` and `B` carries `string`. The fix in that case
is usually to *not* use an or-pattern, and handle the two
constructors separately.

**Pitfall 4: deep nesting without parentheses.** As patterns
grow, the parser can struggle. When in doubt, parenthesise. The
compiler is happy with extra parentheses, and your reader will
be too.

## Activity

:::slide

## Activity

Write `first_of_pair_in_list : (int * int) list -> int option`
returning the first component of the first pair, or `None` if
the list is empty. Use a nested pattern.

:::

Try it before reading the solution.

:::slide

## Activity solution

```ocaml
let first_of_pair_in_list = function
  | (x, _) :: _ -> Some x
  | [] -> None

let _ = first_of_pair_in_list [(10, 20); (30, 40)]
let _ = first_of_pair_in_list []
```

`Some 10`, `None`.

- `(x, _) :: _`: a list whose head is a pair.
- First component of that head is bound to `x`.
- Three nested patterns in one clause.

:::

The pattern `(x, _) :: _` reads inside-out: a list (the outer
`::`), whose head is a pair (the tuple pattern), whose first
component is `x`. The tail of the list is discarded; the second
component of the head pair is discarded.

This is the workhorse shape for "extract one piece of the front
of a list, ignore the rest." You will use it constantly.

## What's next

[Lecture 3](M05-L03-guards.html) introduces `when`-guards:
predicates attached to a pattern that further filter when the clause
fires. Guards let you express conditions that pure patterns cannot,
like "this list has a positive number at the front." They come with
one important caveat: they disable the compiler's exhaustiveness
check for that clause, which we will see why in
[Lecture 4](M05-L04-exhaustiveness.html#exhaustiveness-and-guards-one-more-reminder).

:::slide

## What's next

- Lecture 3: **guards** (`when`-clauses).
- Combine a pattern with an arbitrary boolean test.
- Express conditions that pure patterns cannot.

:::

## Reading

- **Cornell CS3110**, *Pattern matching (continued)*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
- **Real World OCaml**, *Lists and patterns* (or-patterns section):
  <https://dev.realworldocaml.org/lists-and-patterns.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
