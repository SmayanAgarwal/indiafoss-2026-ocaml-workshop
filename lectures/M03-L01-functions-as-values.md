---
title: "Functions as values, and anonymous functions"
lecture_no: 1
week: 3
duration_target_min: 24
concepts: [first-class functions, anonymous functions, fun, lambda, higher-order, function values]
keywords: [OCaml, functions, first-class, anonymous functions, fun, lambda, higher-order]
activity_question: "What is the type of [fun x -> x +. 1.0]? Predict, then check by binding it to a name."
think_about_this: "What does it mean for a function to be a 'first-class value'? Name three things you can do with a value (like an int). Now name the corresponding three things you can do with a function in OCaml."
reading:
  - title: "Cornell CS3110, Functions"
    url: https://cs3110.github.io/textbook/chapters/basics/functions.html
  - title: "Real World OCaml, Functions"
    url: https://dev.realworldocaml.org/variables-and-functions.html
---

# Functions as values

In OCaml, a function is a **value**, the same way `42` and `"hello"`
are values. You can name a function with `let`, pass it as an
argument to another function, return it from a function, and store
it in a data structure. This lecture is about what that actually
means, and the syntax for creating functions on the fly.

If your background is C or Python, the words may sound right but the
practice takes getting used to. Functions in C are pointers to code,
not really values: you can pass them around but you can't construct
new ones at runtime. Functions in Python are objects, closer to the
OCaml picture. In OCaml, the design is fully through-thought: a
function is a value, end of story.

:::slide

## Two ways to define a function

You already know one:

```ocaml
let double x = x + x
```

This is **syntactic sugar** for:

```ocaml
let double = fun x -> x + x
```

The `fun x -> x + x` is an **anonymous function** (sometimes called
a lambda). It evaluates to a function value, which the `let` then
binds to the name `double`.

Both definitions produce the same `double`. Use the shorter form
when defining a named function; use the `fun` form when you need a
function on the fly.

:::

:::slide

## Anonymous functions

`fun x -> e` is the expression form. It's a value of function type:

```ocaml
let _ = fun x -> x + 1
```

The toplevel reports `int -> int = <fun>` and binds the value to
`_`. The function exists; we just haven't named it. We can apply it
right there:

```ocaml
let _ = (fun x -> x + 1) 7
```

`int = 8`. Parenthesize the `fun ... -> ...` and apply it as a
function. We almost never do this; we'd just write `7 + 1`. But the
point is that `fun ... -> ...` is a real expression that evaluates
to a function.

:::

:::slide

## Multiple parameters

```ocaml
let add x y = x + y
let add' = fun x y -> x + y
let add'' = fun x -> fun y -> x + y
```

All three define the same function. The third form makes something
explicit: a "two-argument function" in OCaml is actually a
*one-argument function that returns another one-argument function*.

We will dive deeper into this (currying) in Lecture 3. For now,
just notice that `fun x y -> ...` and `fun x -> fun y -> ...` are
the same.

:::

The unfolding `fun x y -> ...` ≡ `fun x -> fun y -> ...` is the most
distinctive thing about OCaml functions. In C, a function `int
add(int x, int y)` takes two arguments at once and you can only call
it with both. In OCaml, `add 3` is a perfectly meaningful expression:
it's `add` with its first argument supplied, waiting for the second.
We'll see what you do with that in the **currying** lecture.

:::slide

## Functions are values you can name

```ocaml
let plus_one = fun x -> x + 1
let double   = fun x -> x * 2
let triple   = fun x -> x * 3

let _ = plus_one 5
let _ = double 5
let _ = triple 5
```

Three function values, named with `let`, then applied. Nothing magic;
this is the same shape as `let pi = 3.14`.

The difference is that the value happens to be a function.

:::

:::slide

## Functions can be returned from other functions

```ocaml
let make_adder n = fun x -> x + n

let plus_five = make_adder 5
let plus_ten  = make_adder 10

let _ = plus_five 3
let _ = plus_ten 3
```

`make_adder` is `int -> (int -> int)` (read: takes an `int`, returns
a function from `int` to `int`). Applying `make_adder 5` produces
a *new function* that adds 5; applying `make_adder 10` produces
another one that adds 10.

This is the first example of a **higher-order function**: a function
that returns or takes functions. We'll see more in Module 6.

:::

:::slide

## A function value remembers its environment

```ocaml
let make_adder n = fun x -> x + n

let plus_five = make_adder 5
let _ = plus_five 100
```

When we call `plus_five 100`, the function body is `x + n`. At call
time `n` is... where does it come from? It's not a parameter of
`plus_five`. It was the parameter of `make_adder`, which has long
since returned.

OCaml functions are **closures**: they capture the values of any
names they reference, at the point they are created. `plus_five`
remembers that, when it was made, `n` was `5`. It will always add
5, no matter how the rest of the program changes.

:::

:::slide

## Closures are not magic

```ocaml
let n = 10
let f = fun x -> x + n
let n = 99
let _ = f 1
```

What does `f 1` return? `11`.

The function `f` was defined when `n` was `10`. It captured the
value `10`, not "the name n". The later `let n = 99` shadows the
outer `n` but does not retroactively change what `f` saw.

This is the same shadowing-vs-mutation point we made in Module 2,
applied to functions.

:::

:::slide

## Functions can be passed as arguments

```ocaml
let apply_twice f x = f (f x)

let _ = apply_twice (fun x -> x + 1) 5
let _ = apply_twice double 5
```

`apply_twice` takes a function `f` and a value `x`, then computes
`f (f x)`. The first call passes the anonymous function `fun x -> x + 1`;
the second passes `double` (which we defined earlier as `fun x -> x * 2`).

The toplevel reports
`val apply_twice : ('a -> 'a) -> 'a -> 'a = <fun>`.

Read: `apply_twice` takes a function from some type `'a` to itself,
plus a value of type `'a`, and returns an `'a`.

:::

:::slide

## Anonymous functions are everywhere

You will write `fun x -> ...` a lot. It is the standard way to pass
a small one-off function to something like `List.map`:

```ocaml
let nums = [1; 2; 3; 4; 5]
let _ = List.map (fun x -> x * x) nums
```

Without anonymous functions you'd need to:

```ocaml
let square x = x * x
let _ = List.map square nums
```

The first form is shorter and keeps the logic close to where it is
used. Both are fine; idiom leans toward anonymous functions for
small, single-use computations.

:::

We will see `List.map` more in Module 6 (Higher-order programming).
For now the takeaway is that `fun x -> ...` is the syntax you use
whenever you want to construct a function "right here" without
giving it a name.

:::slide

## Type signatures: `->` is right-associative

```ocaml
val add : int -> int -> int
```

Reads as `int -> (int -> int)`. The arrows associate right.

```ocaml
val apply_twice : ('a -> 'a) -> 'a -> 'a
```

Reads as `('a -> 'a) -> ('a -> 'a)`. The first argument is itself
a function (parens make it explicit). The rest follow the
right-associativity rule.

When reading a function type from left to right, each arrow says
"and given an X, produces":

> "given an `('a -> 'a)`, produces (given an `'a`, produces an `'a`)"

You'll get fluent at this with practice.

:::

:::slide

## Activity

What does the toplevel report as the type of:

```ocaml
fun x -> x +. 1.0
```

Predict before binding it.

:::

:::slide

## Activity discussion

`float -> float`. The `+.` forces `x` to be `float`, the result is
`float`.

Now try a slightly trickier one:

```ocaml
fun f x -> f (f x)
```

This is the anonymous version of `apply_twice`. Its type is
`('a -> 'a) -> 'a -> 'a`. Two arguments: a function (the type that
loops on itself), and a starting value.

:::

:::slide

## What's next

Lecture 2: **recursion**. The pattern for writing functions that
process structures (lists, trees, numbers built by counting up) by
having the function call itself. The bread and butter of functional
programming.

:::

## Reading

- **Cornell CS3110**, *Functions*:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
- **Real World OCaml**, *Variables and functions*:
  <https://dev.realworldocaml.org/variables-and-functions.html>
