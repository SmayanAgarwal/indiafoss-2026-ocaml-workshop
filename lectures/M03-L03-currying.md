---
title: "Currying and partial application"
lecture_no: 3
week: 3
duration_target_min: 24
concepts: [currying, partial application, function returning function, higher-order utilities]
keywords: [OCaml, currying, partial application, higher-order functions]
activity_question: "Given [let add x y = x + y], what is the type of [add 5]? What does [add 5] evaluate to? What is [(add 5) 3]?"
think_about_this: "Why is currying useful in practice? Name a situation where you would prefer [add 5] (a function with one argument already supplied) over [add] (the original two-argument function)."
reading:
  - title: "Cornell CS3110, Multiple-argument functions"
    url: https://cs3110.github.io/textbook/chapters/basics/functions.html
---

# Currying and partial application

In OCaml, a function with multiple arguments is secretly a *chain*
of one-argument functions. This shape is called **currying**, after
the logician Haskell Curry, and it makes a very useful trick
available: **partial application**, supplying some of the arguments
and getting back a function that wants the rest.

If you've used `map` or `filter` in Python or JavaScript, you have
seen the *need* for this trick (you want a function with most of
its arguments pre-supplied so you can pass it to map). Curried
functions give you the trick for free.

:::slide

## Two-argument functions, unfolded

```ocaml
let add x y = x + y
```

This is short for:

```ocaml
let add = fun x -> fun y -> x + y
```

- `add` is a one-argument function with argument `x`.
- Its result is a *function* of one argument `y` returning `x + y`.

The type confirms:

```
val add : int -> int -> int
```

- Right-associative: `int -> (int -> int)`.
- *Takes an int, returns a function from int to int.*

:::

:::slide

## What does `add 5` do?

```ocaml
let add x y = x + y
let add5 = add 5
```

- `add5 : int -> int`.
- Adds 5 to whatever int you give it.

```ocaml
let _ = add5 3
```

- `int = 8`.
- We *partially applied* `add` to one of its two arguments.
- Result: a function waiting for the second.
- Works for any curried function: supply some arguments, get back a function for the rest.

:::

:::slide

## Why is this useful?

```ocaml
let xs = [1; 2; 3; 4]
let xs_plus_10 = List.map (add 10) xs
```

- `int list = [11; 12; 13; 14]`.
- `List.map` wants an `int -> int` function.
- No need for the one-off lambda `fun x -> add 10 x`.
- `add 10` already *is* that function.
- Common reason to like currying: eliminates small wrapper lambdas in higher-order code.

:::

Without currying you'd write:

```ocaml
let xs_plus_10 = List.map (fun x -> add 10 x) xs
```

which works but is noisier. The version `List.map (add 10) xs` reads
as "map the add-10 function over xs". That's the pleasant form.

:::slide

## Argument order matters for partial application

```ocaml
let divide x y = x / y
let half x = divide x 2  (* not "divide 2 x" *)
```

- `divide 2` gives a function taking `y` and returning `2 / y`.
- That's "two divided by", not "half".
- The **first** argument is the one most easily fixed by partial application.
- Stdlib APIs often place arguments in the order most useful for partial application.

For example, `List.map` takes the *function* first, *list* second:

```ocaml skip
val List.map : ('a -> 'b) -> 'a list -> 'b list
```

- So you can write `List.map (add 10)` and partial-apply meaningfully.

:::

:::slide

## Function composition by partial application

```ocaml
let increment = (+) 1
let double    = ( * ) 2

let _ = increment 5
let _ = double 5
```

- `(+)` is the prefix-call form of `+`: it's `fun x y -> x + y`.
- Partial-apply to `1` to get `increment`.
- Same for `(*)` and `2`.
- Space inside `( * )` avoids being parsed as the comment `(*`.

:::

Most infix operators have this prefix form: `(+)`, `(*)`, `(<)`,
`(^)`, `(&&)`. Useful when you want to pass the operator as a
function.

:::slide

## Multi-argument functions, the same pattern

```ocaml
let between lo hi x = x >= lo && x <= hi

let in_human_range = between 0 150  (* age in years *)
let in_celsius_room = between 15.0 30.0

let _ = in_human_range 42
let _ = in_celsius_room 22.5
```

- Both `true`.
- `between` takes three arguments (`lo`, `hi`, `x`).
- Partial-applying two of them gives a *one-argument* predicate.
- We make two specialized predicates here.
- Same idea as `add 5`, with one more layer of nesting.

:::

:::slide

## Eta-reduction (small but useful)

When you have

```ocaml skip
let f x = g x
```

you can drop the `x`:

```ocaml skip
let f = g
```

- If `f` just *applies* `g` and returns the result, the two are equivalent.
- OCaml lets you write the shorter form.

```ocaml
let xs_plus_10 = List.map (add 10) xs
```

- We didn't need `fun x -> List.map (add 10) x`.
- Same eta-reduction idea.

:::

:::slide

## When currying isn't what you want

- Sometimes you want "a pair of ints", not "an int then another int".
- Use a tuple:

```ocaml
let add_pair (x, y) = x + y

let _ = add_pair (3, 4)
```

- `add_pair : int * int -> int`.
- Takes *one* argument: a pair.
- `add 3 4` and `add_pair (3, 4)` are different syntax.
- Can't partial-apply the tuple version.
- Most OCaml code prefers curried; tuple is used when the values are *conceptually one thing* (e.g. a 2D point).

:::

:::slide

## Activity

Given:

```ocaml
let add x y = x + y
```

Predict:

- The type of `add 5`.
- What `add 5` evaluates to.
- What `(add 5) 3` evaluates to.

:::

:::slide

## Activity discussion

- Type of `add 5`: `int -> int`. It's the function `fun y -> 5 + y`.
- `add 5` evaluates to a function value. Toplevel: `int -> int = <fun>`.
- `(add 5) 3` evaluates to `8`. First compute `add 5`, then apply to `3`.
- `add 5 3` (no parens) gives the same `8`.
- Function application is left-associative: `((add) 5) 3`.
- The parens version just makes partial application explicit.

:::

:::slide

## What's next

Lecture 4: **tail recursion**.

- Write recursive functions without stack-overflow risk on large inputs.
- Rewrite `factorial` and `sum` to be tail recursive.

:::

## Reading

- **Cornell CS3110**, *Multiple-argument functions*:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
