---
title: "Function composition and pipelines"
lecture_no: 5
week: 6
duration_target_min: 20
concepts: [function composition, pipeline operator, point-free style, readability]
keywords: [OCaml, function composition, pipeline, |>, @@, point-free]
activity_question: "Write the function 'square then increment by 1' two ways: as an explicit lambda [fun x -> square x + 1], and as a composition using a helper [compose]."
think_about_this: "The pipeline operator [|>] is *just* application, written right-to-left in operand order. Why is its existence in the language worth more than zero, given that you could always write [f (g (h x))]?"
reading:
  - title: "Cornell CS3110, Pipeline"
    url: https://cs3110.github.io/textbook/chapters/hop/index.html
---

# Function composition and pipelines

When you chain several functions together, you have a choice of
syntax. Nested calls (`f (g (h x))`) read right-to-left, which
is awkward. **Composition** packages two functions into a third.
The **pipeline operator** `|>` lets you write the chain in
data-flow order, left-to-right.

:::slide

## The pipeline operator `|>`

`x |> f` is *exactly* `f x`. It's defined in the standard library
as:

```ocaml
let ( |> ) x f = f x
```

The only reason it exists: it lets you write a chain of operations
in the order they happen, instead of inside-out.

```ocaml
let _ =
  [1; 2; 3; 4; 5]
  |> List.map (fun x -> x * x)
  |> List.filter (fun y -> y > 5)
  |> List.fold_left (+) 0
```

`int = 50`. Squares of 1-5: [1;4;9;16;25]. Keep those > 5: [9;16;25]. Sum: 50.

Read top-to-bottom: start with a list, square, filter, sum.

:::

:::slide

## Without `|>`: parens and reading right-to-left

The same computation:

```ocaml
let _ = List.fold_left (+) 0
          (List.filter (fun y -> y > 5)
             (List.map (fun x -> x * x)
                [1; 2; 3; 4; 5]))
```

`int = 50`. Same answer, but you have to mentally start at the
*innermost* parens (the list `[1; 2; 3; 4; 5]`), then move
outward. The reading direction is opposite to the dataflow.

The `|>` version doesn't introduce new computation; it changes the
visual order to match the conceptual order.

:::

:::slide

## The application operator `@@`

There's a dual: `f @@ x` is also `f x`. Used to avoid parens on
the right:

```ocaml
let _ = print_endline @@ string_of_int 42
let _ = print_endline (string_of_int 42)
```

Same thing. `@@` is right-associative and low precedence, so
`f @@ g @@ x` parses as `f (g x)`. It's the application
counterpart of `|>` in the *other* direction.

You'll see `@@` mostly when the alternative is `(f x)` with
parentheses around a long expression.

:::

:::slide

## Function composition

A composition operator could be defined as:

```ocaml
let compose f g = fun x -> f (g x)

let square_then_inc = compose (fun x -> x + 1) (fun x -> x * x)
let _ = square_then_inc 4
```

`int = 17`. `4 * 4 = 16`, then `+ 1 = 17`.

`compose f g` is "do `g` first, then `f`". Mathematically this is
function composition `f ∘ g`.

The standard library doesn't ship a built-in composition operator
(some projects define one as `(>>)` or `(<<)`); it's easy enough to
write your own when you need it.

:::

:::slide

## Point-free style

When you can express a function as a composition of others without
naming the argument, that's called **point-free** style:

```ocaml
let compose f g = fun x -> f (g x)

let process = compose (fun x -> x * 2) (fun x -> x + 1)
let _ = process 5
```

`12`. `process` doesn't mention its argument explicitly; it's
defined entirely as a pipeline of two functions.

Some people love point-free; some find it cryptic. The pragmatic
rule: use it when the composition is *obvious* (`compose g f`
clearly does `g` after `f`); name the argument when the chain has
any twist (a condition, a destructuring).

:::

:::slide

## Pipelines are point-free at runtime

```ocaml
let normalize_words text =
  text
  |> String.lowercase_ascii
  |> String.split_on_char ' '
  |> List.filter (fun s -> s <> "")
  |> List.map String.trim

let _ = normalize_words "  Hello World  "
```

`["hello"; "world"]`. Each step is a clear transformation: lowercase
the whole string; split on spaces; drop empty pieces; trim each
piece.

The argument `text` is named at the top, but inside the pipeline
each function receives an *unnamed* value (the output of the
previous step). This is the readable middle ground between "tons of
lambdas" and "deep parens nesting".

:::

:::slide

## When to use composition / pipeline / explicit lambdas

Three options for the same kind of code:

```ocaml
(* (1) explicit *)
let f1 xs = List.map (fun x -> x + 1) xs

(* (2) partial application + map *)
let f2 = List.map ((+) 1)

(* (3) pipeline (only useful when there's a chain) *)
let f3 xs = xs |> List.map ((+) 1)
```

All three are `int list -> int list`. The differences:

- `f1` is the most explicit; you see the lambda.
- `f2` is point-free; clean for short functions.
- `f3` is useful when there are *more* steps; otherwise it just
  adds noise.

Reach for `|>` when you have three or more steps in a row.

:::

:::slide

## Activity

Write "square then increment by 1" two ways:

1. As an explicit lambda `fun x -> ...`.
2. Using a `compose` helper you define yourself.

:::

:::slide

## Activity solution

```ocaml
let f1 = fun x -> (x * x) + 1

let compose g f = fun x -> g (f x)
let square x = x * x
let inc x = x + 1
let f2 = compose inc square

let _ = f1 5
let _ = f2 5
```

`26`, `26`. Same answer.

`f1` is direct: take `x`, square it, add 1. `f2` is constructed
by composing `inc` with `square`: first do `square`, then do
`inc`. Both forms have their place; pick whichever reads better in
context.

:::

:::slide

## What's next

Lecture 6: the **tutorial** for Module 6. We rebuild small parts of
the `List` module (`map`, `filter`, `fold`, `concat`) using only
the techniques from this module.

:::

## Reading

- **Cornell CS3110**, *Pipeline*:
  <https://cs3110.github.io/textbook/chapters/hop/index.html>
