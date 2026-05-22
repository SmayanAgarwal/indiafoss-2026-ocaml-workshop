---
title: "The option monad and `let*` sugar"
lecture_no: 2
week: 8
duration_target_min: 24
concepts: [option monad, return, bind, let-operators, Option.bind, Option.map]
keywords: [OCaml, option monad, let*, bind, return, Option.bind]
activity_question: "Rewrite this with [let*]:\n\n[match parse_int s with None -> None | Some x -> match double x with None -> None | Some y -> small y]"
think_about_this: "The [let*] operator is just a regular OCaml let-operator binding. You can define it for any monad. What rules does the definition have to satisfy to be a 'lawful' monad?"
reading:
  - title: "Cornell CS3110, Option monad"
    url: https://cs3110.github.io/textbook/chapters/ds/monads.html
---

# The option monad


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">The option monad and `let*` sugar</h2>
<p class="title-slide-label">Module 8 &middot; Lecture 2</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

In the [previous lecture](M08-L01-sequencing.html) we built up a
helper `bind` for sequencing optional computations, and previewed
the `let*` syntactic sugar that lets such code read top to bottom.
This lecture turns that preview into a working tool: we define
`let*` formally as a *let-operator*, look at the standard library's
`Option.bind` and `Option.map`, walk through a realistic example,
and discuss when the monad is the right hammer.

The option monad is the workhorse for "this step may fail, and we
do not need to say why". A parser that may or may not match. A
lookup that may or may not find a key. An arithmetic step that may
or may not produce a sensible answer. Use
[`option`](M04-L04-recursive-types.html#the-option-type) when
the *identity* of the failure is the whole story; use `result`
([next lecture](M08-L03-result-monad.html)) when callers want a
message or an error code.

## Definition

A monad is a type plus two operations. Concretely for `option`:

:::slide

## Definition

```ocaml
module Opt = struct
  let return x = Some x
  let bind opt f =
    match opt with
    | None -> None
    | Some x -> f x
  let ( let* ) = bind
end
```

Two functions:

- `return : 'a -> 'a option`. Lift a plain value into the option world.
- `bind : 'a option -> ('a -> 'b option) -> 'b option`. Sequence two optional steps.

And one operator alias:

- `let*` is just `bind` under a syntactic-sugar name.
- `let* x = e in rest` desugars to `( let* ) e (fun x -> rest)`.

:::

`return` is sometimes called `pure` (the [Haskell](https://www.haskell.org/)
spelling). It is the trivial way to put a plain value into the
option world: wrap it in `Some`. The reason it has a name at all
(rather than just writing `Some x` everywhere) is that it is part
of the monad *interface*: anything that wants to claim to be a
monad has to provide `return`, and the rest of the code can pretend
not to know which monad it is using. We will not lean on this
abstraction in OCaml as heavily as Haskell does, but it is worth
the name.

`bind` is exactly the helper we wrote in the previous lecture:
"unwrap an option; if `None`, short-circuit; if `Some x`, pass `x`
to a continuation." Its type, `'a option -> ('a -> 'b option) -> 'b
option`, is worth memorising. Read it as: "given an option *now*
and a function that produces an option *later*, give me back an
option."

The line `let ( let* ) = bind` is where the magic happens. The
identifier `( let* )` is a *let-operator*, an OCaml feature
introduced in version 4.08. Any identifier of the form `let X`
(or `and X`) where `X` starts with a punctuation character can be
bound to a function. Once it is in scope, the compiler treats
`let X p = e in body` as syntactic sugar for `( let X ) e (fun p ->
body)`. That single rule is the whole feature.

## Using `let*`

Here is the pyramid from the previous lecture, rewritten with
`let*`:

:::slide

## Using `let*`

```ocaml
let ( let* ) opt f =
  match opt with
  | None -> None
  | Some x -> f x

let parse_int s = int_of_string_opt s
let double x = Some (x * 2)
let small x = if x < 100 then Some x else None

let demo s =
  let* x = parse_int s in
  let* y = double x in
  small y

let _ = demo "5"
let _ = demo "frog"
let _ = demo "200"
```

- Results: `Some 10`, `None`, `None`.
- Each `let* y = expr in` says: compute `expr`; if `None`,
  short-circuit; otherwise bind `y` and continue.

:::

The visual difference between this and a non-monadic `let` is the
asterisk: `let* x = e in rest`, not `let x = e in rest`. That is
the only syntactic mark of the monadic version. The semantic
difference, of course, is large: this version short-circuits on
`None`, the plain one cannot, because the plain one only works
when `e` is a plain `'a`, not an `'a option`.

A reader of monadic code learns to read `let*` as the keyword for
"this might fail, and if it does, give up." Each `let*` line
introduces a name that holds the *successful* result; the
short-circuit on failure is implicit. The whole function reads
top to bottom with no nested matches.

## `Option.bind` and `Option.map`

The standard library ships these functions, so you do not have to
write them yourself in real code:

:::slide

## `Option.bind` and `Option.map`

```ocaml
let _ = Option.bind (Some 5) (fun x -> if x > 0 then Some (x * 2) else None)
let _ = Option.bind None (fun x -> Some (x + 1))
let _ = Option.map (fun x -> x * 2) (Some 5)
```

`Some 10`, `None`, `Some 10`.

- `Option.bind` is exactly the `bind` we defined.
- `Option.map` is weaker: applies a *pure* function inside the option.
- The continuation cannot fail; it just produces a plain value.
- Use `bind` when the next step itself returns an option.
- Use `map` when the next step is a pure transformation.

:::

The two functions differ in the type of the continuation. `bind`
takes an `'a -> 'b option`: the continuation can decide to fail.
`map` takes an `'a -> 'b`: the continuation must produce a plain
value. So:

- Next step might fail (returns `'a option`): use `bind`.
- Next step always succeeds (returns `'a`): use `map`.

In monad-speak, `map` is the *functor* operation and `bind` is the
strictly stronger monad operation. `map` could be defined in terms
of `bind`: `let map f opt = bind opt (fun x -> Some (f x))`. We
keep both because using `map` when you mean `map` is a small
clarity win for the reader.

To set up an analogous `let+` operator for map-only chains (no
new failure introduced), people often write:

```ocaml
let ( let+ ) x f = Option.map f x
```

Note the flipped argument order: `Option.map` takes the function
first and the option second, while the let-operator convention is
the reverse. We will see this `let+` again in a moment.

## A realistic example: parsing a pair

A short parser to make the abstraction concrete. We want to read
strings like `"(3, 4)"` and produce the pair `(3, 4)`, or `None`
if the string does not match the shape:

:::slide

## A real example: parsing

```ocaml
let ( let* ) = Option.bind

(* parse "(x, y)" into a pair of ints; None if malformed *)
let parse_pair s =
  let s = String.trim s in
  let n = String.length s in
  if n < 5 || s.[0] <> '(' || s.[n - 1] <> ')' then None
  else
    let inner = String.sub s 1 (n - 2) in
    match String.split_on_char ',' inner with
    | [a; b] ->
        let* x = int_of_string_opt (String.trim a) in
        let* y = int_of_string_opt (String.trim b) in
        Some (x, y)
    | _ -> None
```

- The two `int_of_string_opt` calls can each fail.
- `let*` short-circuits on the first failure; otherwise the final
  `Some (x, y)` packages both successes.

:::

:::slide

## Trying the parser

```ocaml
let _ = parse_pair "(3, 4)"
let _ = parse_pair "(3, x)"
let _ = parse_pair "frog"
```

`Some (3, 4)`, `None`, `None`. The inner `let*` short-circuits on
the bad inner number; the outer `if`/`match` catches malformed
shapes before we even get to the integers.

:::

Without `let*`, the inner block would be two nested `match`es with
explicit `None ->` arms. With `let*`, the two `int_of_string_opt`
calls read linearly. If either fails, the whole `parse_pair`
returns `None`. If both succeed, we package the pair.

Notice the structure: there are two distinct *kinds* of failure
checking in this function. The outer checks (length, parentheses,
single comma) use ordinary `if` and `match`, because they are
local sanity checks where the value flowing through is not an
option. The inner checks (the two integer parses) use `let*`,
because each one *returns* an option and we need to short-circuit
on `None`. Monadic sequencing is for the case where each step has
the same shape; use ordinary control flow for the other cases.

## Combining `let*` and `let+`

When the last step of a chain is a pure transformation, the
parser-favourite combo is `let*` for the optional steps and
`let+` for the final transform:

:::slide

## Combining `let*` and `let+`

```ocaml
let ( let* ) = Option.bind
let ( let+ ) x f = Option.map f x

let demo s =
  let* x = int_of_string_opt s in
  let+ y = if x > 0 then Some (x * 2) else None in
  y + 1

let _ = demo "5"
```

`Some 11`.

- `let* x = parse in ...`: unwraps `x`, may short-circuit.
- `let+ y = ... in y + 1`: unwraps `y`, applies the pure transform.
- The `+ 1` cannot fail; `let+` is for that case.
- Saves us writing `Some (y + 1)` at the end of a `let*` chain.

:::

The intuition: `let*` is for "the next step might fail too" and
`let+` is for "the next step cannot fail; just apply this pure
function". With both in scope, a chain of three optional steps and
one pure final step reads:

```
let* a = step1 ... in
let* b = step2 a ... in
let* c = step3 b ... in
let+ d = step4 c ... in
final d
```

This is the same number of lines as the all-`let*` version, but
the reader sees at a glance that step 4 has a different character:
the `+` says "no more failure introduced from here."

You do not strictly need `let+`. You can always replace `let+ y =
... in body` with `let* y = ... in return body`. The `let+` form
is slightly shorter and slightly clearer when you have it. Some
codebases use it heavily; others stick to `let*` alone.

## A note on let-operators per monad

`let*` is not a fixed operator name in the language. It is a
regular binding you define for whatever monad you are working with.
Each monad has its own `let*`:

:::slide

## A note on `let*` per-monad

- `let*` is **not** a fixed operator: it's a regular binding.
- Each monad defines its own.
- `let open Opt in` brings option-flavoured `let*` into scope.
- For result-flavoured code (next lecture), you redefine `let*`.
- The compiler does not know which monad you are in; you choose by `open`.
- Languages with built-in `do`-notation (Haskell) avoid this per-monad redefinition.
- OCaml trades a bit of elegance for clarity: the type of `let*` is always visible.

:::

The trade-off is: in Haskell, the `do`-notation is one keyword that
adapts to whichever monad your function is annotated with. In
OCaml, you pick the right `let*` by opening the right module or
defining the right operator. The OCaml version is a little more
typing, but it is also a little less magical: the type of `let*`
is right there in front of you, and you cannot accidentally
confuse one monad's bind with another.

In practice, codebases that lean heavily on monads define a small
module per monad, with `bind`, `( let* )`, optionally `( let+ )`,
and any monad-specific helpers. You `let open M in` at the top of
the function that needs `M`'s flavour of bind, and the rest of the
function uses `let*` without saying which monad it means.

## When *not* to use a monad

A monad is overkill for a single optional step. The plain `match`
is shorter and equally clear:

:::slide

## When *not* to use a monad

```ocaml
let _ =
  match int_of_string_opt "frog" with
  | Some n -> n * 2
  | None -> 0
```

`int = 0`. Two cases, one `match`, three lines. No monad needed.

- Reach for `let*` when you have **three or more** sequential optional steps.
- Below three, the `match` is shorter and equally clear.
- Above three, the pyramid wins, and `let*` saves you.

:::

The rough threshold is three steps. Below that, a plain `match`
fits on screen and is just as readable. At three or above, the
pyramid bites and `let*` becomes the right tool. There is nothing
magic about three; it is a rule of thumb. If you find yourself
indenting past column 50 to handle a third level of `None`, switch
to `let*`.

A second case for *not* using a monad: when you want to *collect*
failures rather than short-circuit on the first one. The option
monad gives you the first-`None`-wins behaviour. If you want "try
all the parses and tell me everything that failed", that is the
*applicative* (or *validation*) shape, which is a sibling pattern.
We will not study it in detail in this course; the
[next lecture](M08-L03-result-monad.html#when-you-want-to-collect-all-errors)
will mention it again when we get to `result`.

## The monad laws (a teaser)

A *lawful* monad is one whose `return` and `bind` satisfy three
equations:

- **Left identity**: `bind (return x) f` is the same as `f x`.
- **Right identity**: `bind m return` is the same as `m`.
- **Associativity**: `bind (bind m f) g` is the same as `bind m
  (fun x -> bind (f x) g)`.

These say, roughly: `return` is a do-nothing wrapper; `bind` is a
"plug things together" operation that does not care about parenthesisation.
The option-monad definitions above satisfy all three; you can check
them on paper. Most monads you will meet do; the laws are the
"good behaviour" contract that lets you reason about monadic code
without worrying about hidden non-obvious effects.

We will not enforce or test the laws in this course. They are
worth knowing about (they are why category theorists like monads),
but day-to-day OCaml usage rarely turns on them.

## A quick check

:::quiz mcq id=M08-L02-q3
You have a chain `let* x = e1 in let* y = e2 in let* z = e3 in Some
(x, y, z)`, where `e1` evaluates to `Some 1`, `e2` evaluates to
`None`, and `e3` is some expression you do not have to evaluate.
What does the whole expression evaluate to, and how many times is
`e3` evaluated?

- [ ] `Some (1, ?, ?)`, evaluated once.
- [x] `None`, evaluated zero times.
- [ ] `Some (1, _, _)`, evaluated zero times.
- [ ] An exception is raised.

**Why:** the option monad short-circuits on the first `None`.
Once `e2` is `None`, the surrounding `let*` returns `None` without
evaluating its continuation, so `e3` is never run. This is the
useful efficiency property: failure is detected as soon as it
happens, and downstream code is skipped.
:::

:::quiz mcq id=M08-L02-q2
When should you reach for `let+` instead of `let*`?

- [x] When the right-hand side cannot itself fail; only a pure transformation is happening.
- [ ] When the right-hand side might fail; you want short-circuit semantics.
- [ ] When you want to collect multiple failures rather than the first.
- [ ] Never; `let*` covers all cases.

**Why:** `let* x = e in rest` expects `e : 'a option`. `let+ x = e
in body` also expects `e : 'a option`, but the *body* is treated
as a pure transformation: it produces a plain `'b`, and `let+`
wraps it back in `Some`. So `let+` is the right choice when the
*continuation* cannot fail (no further options being unwrapped),
even though `e` itself may.
:::

:::slide

## Activity

Rewrite this using `let*`:

```text
match parse_int s with
| None -> None
| Some x ->
    match double x with
    | None -> None
    | Some y -> small y
```

:::

:::slide

## Activity solution

```ocaml
let ( let* ) = Option.bind

let parse_int s = int_of_string_opt s
let double x = Some (x * 2)
let small x = if x < 100 then Some x else None

let pipeline s =
  let* x = parse_int s in
  let* y = double x in
  small y

let _ = pipeline "5"
let _ = pipeline "frog"
let _ = pipeline "200"
```

`Some 10`, `None`, `None`.

- Three steps, three `let*`s.
- Same logic as the nested `match`, but flat.

:::

A small code quiz:

:::quiz code id=M08-L02-q1
Write `lookup_chain : (string * int) list -> string -> string ->
int option` that looks up two keys in an association list, adds
their values if both are present, and returns `Some (sum)` or
`None`. Use `let*`.

```ocaml
let lookup_chain table k1 k2 =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let table = [("a", 1); ("b", 2); ("c", 3)]
let () =
  check (lookup_chain table "a" "b" = Some 3) "both present";
  check (lookup_chain table "a" "z" = None) "second missing";
  check (lookup_chain table "z" "b" = None) "first missing";
  check (lookup_chain table "z" "y" = None) "both missing";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let ( let* ) = Option.bind
let lookup_chain table k1 k2 =
  let* v1 = List.assoc_opt k1 table in
  let* v2 = List.assoc_opt k2 table in
  Some (v1 + v2)
```

Two optional lookups, one `let*` each, a pure final wrap with
`Some`. If either lookup fails, the chain short-circuits.

:::

## What is next

:::slide

## What is next

Lecture 3: the **result monad**.

- Like `option`, but the failure case carries information.
- The error type is a parameter: a `string`, a variant, anything you like.
- Same `let*` notation, different module.

:::

`option` is fine when "no value here" is all you need to know.
The [next lecture](M08-L03-result-monad.html) moves to `result`,
where the failure case carries a payload (an error message, a code,
a [variant](M04-L03-variants.html)). Same monad shape, richer
information. After that, [the state monad](M08-L04-state-monad.html)
in lecture four.

## Reading

- **Cornell CS3110**, *Option monad*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
