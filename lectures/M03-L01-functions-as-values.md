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

In OCaml, a function is a *value*, the same way `42` and `"hello"`
are values. You can name a function with `let`, pass it as an
argument to another function, return it from a function, and store
it in a data structure. The slogan is that functions are
*first-class values*: they have the same rights as any other value
in the language. This lecture is about what that actually means in
practice, what new things you can express because of it, and the
syntax for creating functions on the fly.

If you arrived from C or Python, the phrase "functions are values"
may sound right but the practice takes adjusting to. Functions in C
are *pointers to code*, not really values: you can pass a function
pointer but you cannot create new functions at runtime. Functions
in Python are objects, closer to the OCaml picture, but their
defining-and-using syntax is heavyweight (`def name(...)` then a
body) compared to OCaml's. Lambda-expressions ([added to Java in 8](https://docs.oracle.com/javase/tutorial/java/javaOO/lambdaexpressions.html),
to [C++ in 11](https://en.cppreference.com/w/cpp/language/lambda))
are how mainstream languages have caught up to the OCaml-style
treatment of functions; you may already know them. In OCaml this
treatment is *the default*, not a bolt-on.

Module 3 is built around this idea. This first lecture establishes
that functions are values; the next four lectures
([recursion](M03-L02-recursion.html),
[currying](M03-L03-currying.html),
[tail recursion](M03-L04-tail-recursion.html),
[local and mutual recursion](M03-L05-local-and-mutual.html))
put the machinery to work. By the end of the module you will be
writing functions that produce functions, returning functions from
functions, and reasoning about function types without effort.

## Two ways to define a function

You already know one syntax for defining a function:

```ocaml
let double x = x + x
```

`let name args = body` is the everyday form, used in every example
so far. There is a second form, more verbose but more revealing:

```ocaml
let double = fun x -> x + x
```

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

- `fun x -> x + x` is an **anonymous function** (a lambda).
- It evaluates to a function value; `let` binds it to `double`.
- Both definitions produce the same `double`.
- Use the shorter form for named functions; use `fun` for one-off functions.

:::

The expression `fun x -> x + x` is an *anonymous function*. In other
language traditions this is called a *lambda* (after Alonzo
Church's lambda calculus, the mathematical foundation of functional
programming). The `fun` keyword introduces a parameter list (one
parameter, `x`, in this case); the `->` separates the parameters
from the body; the body is the expression that defines what the
function does.

`fun x -> x + x` is, all on its own, a value. It has a type
(`int -> int`). It can be bound to a name with `let`. It can be
passed to another function. It can be returned from a function. It
can sit in a list. If you accept that `42` is a value with type
`int`, you should accept that `fun x -> x + x` is a value with type
`int -> int`. They participate in the language at exactly the same
level.

The shorthand `let double x = x + x` is *syntactic sugar* for
`let double = fun x -> x + x`. The compiler treats them as
identical. Use the shorthand for named functions; use the explicit
`fun` form for functions you do not want to name (one-off computations
passed to a higher-order function, for instance).

## Anonymous functions in expressions

`fun x -> e` is an expression. It evaluates to a function value.

```ocaml
let _ = fun x -> x + 1
```

The toplevel reports `int -> int = <fun>` and binds the result to
`_`. The function exists; we just have not named it. We could
apply it on the spot:

```ocaml
let _ = (fun x -> x + 1) 7
```

:::slide

## Anonymous functions

- `fun x -> e` is the expression form.
- It's a value of function type.

```ocaml
let _ = fun x -> x + 1
```

- Toplevel reports `int -> int = <fun>`, binds to `_`.
- The function exists; we just haven't named it.

We can apply it right there:

```ocaml
let _ = (fun x -> x + 1) 7
```

- `int = 8`. Parenthesize, then apply.
- Rarely done in practice (we'd just write `7 + 1`).
- Key point: `fun ... -> ...` is a real expression evaluating to a function.

:::

The parentheses are necessary because function application binds
tighter than the `fun` syntax: without them, OCaml would parse
`fun x -> x + 1 7` as `fun x -> (x + 1 7)`, which is nonsense.

In practice you rarely apply an anonymous function on the spot
(why not just write the value?), but you constantly *pass* anonymous
functions as arguments to other functions, which we will see in a
moment.

## Multiple parameters

What about a function of two or more parameters? Three ways to
write the same function:

```ocaml
let add x y = x + y
let add' = fun x y -> x + y
let add'' = fun x -> fun y -> x + y
```

:::slide

## Multiple parameters

```ocaml
let add x y = x + y
let add' = fun x y -> x + y
let add'' = fun x -> fun y -> x + y
```

- All three define the same function.
- The third form makes something explicit.
- A "two-argument function" in OCaml is really a *one-argument function returning another one-argument function*.
- Deeper dive: **currying**, Lecture 3.
- For now: `fun x y -> ...` and `fun x -> fun y -> ...` are the same.

:::

All three define the same function. The third form makes something
striking explicit: a "two-argument function" in OCaml is really a
*one-argument function that returns another one-argument function*.
The `fun x -> fun y -> x + y` reads "given `x`, return the function
that, given `y`, returns `x + y`." This is called *currying* (after
Haskell Curry, the same person Haskell is named for); we devote
Lecture 3 of this module to it.

For now, the takeaway: `fun x y -> ...` and `fun x -> fun y -> ...`
are interchangeable. The compiler treats them identically. The
shorthand `let add x y = ...` desugars to the curried form.

## Functions are values you can name

Once we accept that functions are values, three things follow:
you can name them, you can pass them around, and you can return
them. Let's see each.

```ocaml
let plus_one = fun x -> x + 1
let double   = fun x -> x * 2
let triple   = fun x -> x * 3

let _ = plus_one 5
let _ = double 5
let _ = triple 5
```

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

- Three function values, named with `let`, then applied.
- Same shape as `let pi = 3.14`.
- The only difference: the value happens to be a function.

:::

Three `let` bindings. The shape is identical to `let pi = 3.14`,
or `let greeting = "hello"`: a name bound to a value. The only
difference is that the *value* happens to be a function. The
language does not distinguish.

## Functions can be returned from other functions

The next step: a function whose return value is *another function*.

```ocaml
let make_adder n = fun x -> x + n

let plus_five = make_adder 5
let plus_ten  = make_adder 10

let _ = plus_five 3
let _ = plus_ten 3
```

:::slide

## Functions can be returned from other functions

```ocaml
let make_adder n = fun x -> x + n

let plus_five = make_adder 5
let plus_ten  = make_adder 10

let _ = plus_five 3
let _ = plus_ten 3
```

- `make_adder : int -> (int -> int)`.
- Takes an `int`, returns a function from `int` to `int`.
- `make_adder 5` produces a *new function* that adds 5.
- `make_adder 10` produces another that adds 10.
- This is our first **higher-order function**: takes or returns functions.
- More in Module 6.

:::

`make_adder` has type `int -> (int -> int)`: it takes an `int` and
returns a function from `int` to `int`. The two calls produce two
*different* functions: `plus_five` always adds 5 (regardless of
what other code does); `plus_ten` always adds 10. Each call to
`make_adder` produces a fresh function value.

This is our first *higher-order function*: a function that takes
or returns other functions. We will devote all of
[Module 6](M06-L01-functions-revisited.html) to higher-order
functions; for this lecture, just notice that the machinery exists
and works.

## A function value remembers its environment

Here is the subtle and important property. When `plus_five 3`
runs, the body is `x + n`. The parameter `x` is bound to `3`. But
where does `n` come from? It is not a parameter of `plus_five`. It
was a parameter of `make_adder`, and `make_adder` has long since
returned.

The answer is that the function value `plus_five` does not just
hold "the function body"; it also holds a record of "what `n` was
when this function was created." The value `n = 5` was *captured*
by the function at the moment of its creation. Such a function-value-with-captured-environment
is called a *closure*. We saw closures briefly in
[M02-L02](M02-L02-let-bindings.html#why-shadowing-differs-from-mutation-closures-see-the-old-value)
(the function captures the *value*, not the *name*).

:::slide

## A function value remembers its environment

```ocaml
let make_adder n = fun x -> x + n

let plus_five = make_adder 5
let _ = plus_five 100
```

- Calling `plus_five 100`, the body is `x + n`. Where does `n` come from?
- Not a parameter of `plus_five`.
- It was `make_adder`'s parameter; `make_adder` has long since returned.
- OCaml functions are **closures**: they capture the values of names they reference, at creation time.
- `plus_five` remembers that `n` was `5` when it was made.
- It always adds 5, no matter how the rest of the program changes.

:::

`plus_five 100` returns `105`. The captured `n = 5` is used in
the body. The closure ensures that `plus_five` keeps working even
after `make_adder` has returned and its activation frame is gone.

## Closures capture values, not names

The capture is of *values at the time of creation*, not of names
that get looked up later.

```ocaml
let n = 10
let f = fun x -> x + n
let n = 99
let _ = f 1
```

What does `f 1` return?

:::slide

## Closures are not magic

```ocaml
let n = 10
let f = fun x -> x + n
let n = 99
let _ = f 1
```

What does `f 1` return? `11`.

- `f` was defined when `n` was `10`.
- It captured the **value** `10`, not "the name `n`".
- The later `let n = 99` shadows the outer `n`.
- Shadowing does not retroactively change what `f` saw.
- Same shadowing-vs-mutation point from Module 2, applied to functions.

:::

Returns `11`. The closure captured `n = 10` when `f` was defined;
the later `let n = 99` shadows the outer `n` but does not change
the value `f` saw. This is the same point from
[M02-L02](M02-L02-let-bindings.html#shadowing) (shadowing is not
mutation), applied to function closures.

In dynamically-scoped languages, `f` would look up `n` at call time
and would return `100`. OCaml is statically scoped: the binding
that was in scope when `f` was defined is the one `f` uses, forever.

## Functions can be passed as arguments

The third thing you can do with a value: pass it as an argument.

```ocaml
let apply_twice f x = f (f x)

let _ = apply_twice (fun x -> x + 1) 5
let _ = apply_twice double 5
```

:::slide

## Functions can be passed as arguments

```ocaml
let apply_twice f x = f (f x)

let _ = apply_twice (fun x -> x + 1) 5
let _ = apply_twice double 5
```

- `apply_twice` takes a function `f` and a value `x`, computes `f (f x)`.
- First call: passes the anonymous `fun x -> x + 1`.
- Second call: passes `double` (defined earlier).
- Toplevel: `val apply_twice : ('a -> 'a) -> 'a -> 'a = <fun>`.
- Read: takes a function from `'a` to itself, plus an `'a`, returns an `'a`.

:::

`apply_twice` takes a function `f` and a value `x`, and computes
`f (f x)`. The first call passes the anonymous function `fun x ->
x + 1` (so we get `((5 + 1) + 1) = 7`); the second passes `double`
(so we get `(5 * 2) * 2 = 20`).

The toplevel reports `val apply_twice : ('a -> 'a) -> 'a -> 'a =
<fun>`. Parsed: takes a function from `'a` to `'a`, plus an `'a`,
and returns an `'a`. The function is polymorphic: it works at any
type `'a`, as long as `f` maps that type to itself. The same
`apply_twice` works for `int -> int` functions, `float -> float`
functions, `string -> string` functions, etc.

## Anonymous functions are everywhere

You will write `fun x -> ...` a lot. It is the standard way to pass
a small one-off function to a higher-order utility like `List.map`.

```ocaml
let nums = [1; 2; 3; 4; 5]
let _ = List.map (fun x -> x * x) nums
```

:::slide

## Anonymous functions are everywhere

- You will write `fun x -> ...` a lot.
- Standard way to pass a small one-off function to e.g. `List.map`.

```ocaml
let nums = [1; 2; 3; 4; 5]
let _ = List.map (fun x -> x * x) nums
```

Without anonymous functions:

```ocaml
let square x = x * x
let _ = List.map square nums
```

- First form is shorter; keeps logic close to where it's used.
- Both are fine.
- Idiom leans toward anonymous functions for small, single-use computations.

:::

`List.map` is the standard library function that applies a function
to every element of a list. We will see [`List.map`](M06-L02-map.html)
and its friends in detail in Module 6. For now, notice that the
natural way to write "the function `x -> x * x`" right at the call
site is the anonymous-function form `fun x -> x * x`.

Without anonymous functions, you would have to invent a name for
this little computation:

```ocaml
let square x = x * x
let _ = List.map square nums
```

Both are fine. The anonymous-function form is shorter and keeps the
logic close to where it is used; the named form is reusable
elsewhere. Idiomatic OCaml leans toward anonymous functions for
small, single-use functions.

## Reading function types: `->` is right-associative

When you write `int -> int -> int`, OCaml reads this as `int ->
(int -> int)`. The arrow is right-associative.

```
val add : int -> int -> int
val apply_twice : ('a -> 'a) -> 'a -> 'a
```

:::slide

## Type signatures: `->` is right-associative

```ocaml skip
val add : int -> int -> int
```

- Reads as `int -> (int -> int)`.
- Arrows associate right.

```ocaml skip
val apply_twice : ('a -> 'a) -> 'a -> 'a
```

- Reads as `('a -> 'a) -> ('a -> 'a)`.
- First argument is itself a function (parens make it explicit).
- Rest follows right-associativity.

When reading left to right, each arrow says "and given an X, produces":

> "given an `('a -> 'a)`, produces (given an `'a`, produces an `'a`)"

You'll get fluent with practice.

:::

`int -> int -> int` parses as `int -> (int -> int)`: a function
that takes an `int` and returns a `(int -> int)` (which is itself
a function from `int` to `int`). The right-associative reading
matches currying: `add 3` is meaningful (an `int -> int` function),
because `add` is really a one-argument function returning a function.

`('a -> 'a) -> 'a -> 'a` parses as `('a -> 'a) -> ('a -> 'a)`. The
parentheses around the first argument are *necessary*: without
them, the type would be `'a -> 'a -> 'a -> 'a`, meaning "takes
three `'a`s and returns one." With them, "takes a function from
`'a` to `'a`, then an `'a`, and returns an `'a`."

You will get fluent with practice. The trick: read left to right,
inserting "and given an X, produces" between each arrow.

## A quick check

:::quiz mcq id=M03-L01-q3
What is the type of `fun x -> x +. 1.0`?

- [ ] `int -> int`
- [ ] `int -> float`
- [x] `float -> float`
- [ ] `'a -> 'a`

**Why:** the literal `1.0` is `float`. The operator `+.` forces its
left operand (the parameter `x`) to be `float`, and the result is
`float`. So the anonymous function is `float -> float`. There is no
ambiguity here: the operator pins both ends.
:::

:::quiz mcq id=M03-L01-q2
What does `apply_twice (fun x -> x + 1) 5` evaluate to?

- [ ] `5`
- [ ] `6`
- [x] `7`
- [ ] `10`

**Why:** `apply_twice f x = f (f x)`. With `f = fun x -> x + 1`
and `x = 5`: the inner `f 5` is `6`; the outer `f 6` is `7`.
:::

A code challenge:

:::quiz code id=M03-L01-q1
Define `compose : ('b -> 'c) -> ('a -> 'b) -> ('a -> 'c)` that
takes two functions `g` and `f` and returns the composed function
`fun x -> g (f x)`.

```ocaml
let compose g f =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let inc x = x + 1
let neg x = -x
let () =
  check ((compose neg inc) 5 = -6) "neg . inc";
  check ((compose inc neg) 5 = -4) "inc . neg";
  check ((compose (fun x -> x * 2) (fun x -> x + 1)) 3 = 8) "*2 . +1";
  print_endline "all tests passed"
```
:::

Reference solution: `let compose g f = fun x -> g (f x)`, or
equivalently `let compose g f x = g (f x)`. Function composition is
one of the most useful tools in functional programming; we will
return to it in [Module 6](M06-L05-pipelines.html#function-composition).

## Activity

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

- Type: `float -> float`.
- `+.` forces `x` to be `float`; result is `float`.

Now try a trickier one:

```ocaml
fun f x -> f (f x)
```

- Anonymous version of `apply_twice`.
- Type: `('a -> 'a) -> 'a -> 'a`.
- Two arguments: a function (type loops on itself), and a starting value.

:::

The trickier one in the slide is the anonymous version of
`apply_twice`. The inferred type `('a -> 'a) -> 'a -> 'a` is forced
by the body: `f (f x)` requires that the output of `f` be a valid
input to `f`, so `f`'s output and input types must match (both
`'a`). The starting `x` must also be `'a` (since it is fed to `f`).
The whole expression's result is `f`'s output type, which is `'a`.

## What's next

We have established that functions are values. The next lecture,
[M03-L02](M03-L02-recursion.html), covers *recursion*: functions
that call themselves. This is how OCaml expresses iteration; you
do not write `for` loops in OCaml (well, you can, but you rarely
will). After recursion, [M03-L03](M03-L03-currying.html) covers
currying in full,
[M03-L04](M03-L04-tail-recursion.html) covers tail recursion and
the accumulator pattern (the technique for making recursion fast),
and [M03-L05](M03-L05-local-and-mutual.html) covers local and
mutual recursion. [M03-L06](M03-L06-tutorial.html) is the tutorial.

:::slide

## What's next

Lecture 2: **recursion**.

- Pattern for writing functions that process structures (lists, trees, counts).
- Function calls itself.
- The bread and butter of functional programming.

:::

## Reading

- **Cornell CS3110**, *Functions*: the corresponding chapter:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
- **Real World OCaml**, *Variables and functions*: same material
  from a different angle:
  <https://dev.realworldocaml.org/variables-and-functions.html>
- John Whitington, *OCaml from the Very Beginning*, Chapter 3:
  for a gentler pace.
