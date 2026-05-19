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

- `x |> f` is *exactly* `f x`.
- Defined in the standard library as:

```ocaml
let ( |> ) x f = f x
```

- The only reason it exists: write chains in the order they happen,
  instead of inside-out.

```ocaml
let _ =
  [1; 2; 3; 4; 5]
  |> List.map (fun x -> x * x)
  |> List.filter (fun y -> y > 5)
  |> List.fold_left (+) 0
```

`int = 50`.

- Squares of 1-5: `[1;4;9;16;25]`.
- Keep those > 5: `[9;16;25]`.
- Sum: `50`.
- Read top-to-bottom: start with a list, square, filter, sum.

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

`int = 50`. Same answer, but:

- You start at the *innermost* parens (`[1; 2; 3; 4; 5]`).
- Then move outward.
- Reading direction is opposite to the dataflow.
- `|>` doesn't introduce new computation: it aligns visual order
  with conceptual order.

:::

:::slide

## The application operator `@@`

- Dual of `|>`: `f @@ x` is also `f x`.
- Used to avoid parens on the right:

```ocaml
let _ = print_endline @@ string_of_int 42
let _ = print_endline (string_of_int 42)
```

Same thing.

- `@@` is right-associative and low precedence.
- `f @@ g @@ x` parses as `f (g x)`.
- It's the application counterpart of `|>` in the *other* direction.
- Use `@@` when the alternative is `(f x)` with parens around a
  long expression.

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

- `compose f g` means "do `g` first, then `f`".
- Mathematically: `f ∘ g`.
- Standard library has no built-in composition operator.
- Some projects define one as `(>>)` or `(<<)`; easy to write yourself.

:::

:::slide

## Point-free style

- Express a function as a composition of others **without** naming
  the argument: this is **point-free** style.

```ocaml
let compose f g = fun x -> f (g x)

let process = compose (fun x -> x * 2) (fun x -> x + 1)
let _ = process 5
```

`12`.

- `process` doesn't mention its argument explicitly.
- It's defined entirely as a pipeline of two functions.
- Some love point-free; some find it cryptic.
- Pragmatic rule: use it when the composition is *obvious*; name
  the argument when there's any twist (a condition, a destructuring).

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

`["hello"; "world"]`.

Each step is a clear transformation:

- Lowercase the whole string.
- Split on spaces.
- Drop empty pieces.
- Trim each piece.

- `text` is named at the top.
- Inside the pipeline, each function receives an *unnamed* value
  (the previous step's output).
- Readable middle ground between "tons of lambdas" and "deep parens".

:::

:::slide

## When to use composition / pipeline / explicit lambdas

Three options for the same code:

```ocaml
(* (1) explicit *)
let f1 xs = List.map (fun x -> x + 1) xs

(* (2) partial application + map *)
let f2 = List.map ((+) 1)

(* (3) pipeline (only useful when there's a chain) *)
let f3 xs = xs |> List.map ((+) 1)
```

All three are `int list -> int list`.

- `f1`: most explicit; you see the lambda.
- `f2`: point-free; clean for short functions.
- `f3`: useful when there are *more* steps; otherwise just noise.
- Reach for `|>` when you have **three or more** steps in a row.

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

- `f1` is direct: take `x`, square it, add 1.
- `f2` composes `inc` with `square`: first `square`, then `inc`.
- Both forms have their place; pick whichever reads better in context.

:::

:::slide

## What's next

Lecture 6: the **tutorial** for Module 6.

- Rebuild small parts of the `List` module.
- (`map`, `filter`, `fold`, `concat`.)
- Using only the techniques from this module.

:::

## Reading

- **Cornell CS3110**, *Pipeline*:
  <https://cs3110.github.io/textbook/chapters/hop/index.html>
