---
title: "Functions as values, and anonymous functions"
lecture_no: 1
week: 2
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


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Functions as values, and anonymous functions</h2>
<p class="title-slide-label">Module 3 &middot; Lecture 1</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

In OCaml, a function is a *value*, the same way `42` and `"hello"`
are values. You can name a function with `let`, pass it as an
argument to another function, return it from a function, and store
it in a data structure. The slogan is that functions are
*first-class values*: they have the same rights as any other value
in the language. This lecture is about what that actually means in
practice, what new things you can express because of it, and the
syntax for creating functions on the fly.

:::slide

## Functions are values

- `42` is a value. `"hello"` is a value. **A function is a value too.**
- You can:
  - name a function with `let`,
  - pass it as an argument,
  - return it from another function,
  - store it in a list, tuple, record.
- The slogan: functions are **first-class values**.

:::

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

:::slide

## The plan for Module 3

- **L1** (today): functions as values; anonymous functions.
- **L2** ([recursion](M03-L02-recursion.html)): writing self-referential functions.
- **L3** ([currying](M03-L03-currying.html)): every multi-argument function in OCaml is really a chain of one-argument functions.
- **L4** ([tail recursion](M03-L04-tail-recursion.html)): recursion that runs in constant stack.
- **L5** ([local and mutual recursion](M03-L05-local-and-mutual.html)): `let rec ... and ...` and `let rec ... in ...`.
- **L6** ([tutorial](M03-L06-tutorial.html)): putting it together.

:::

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
- Evaluates to a function value; `let` binds it.
- Use the shorter form for named functions, `fun` for one-offs.

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
let _ = fun x -> x + 1  (* : int -> int = <fun> *)
```

The toplevel reports `int -> int = <fun>` and binds the result to
`_`. The function exists; we just have not named it. We could
apply it on the spot:

```ocaml
let _ = (fun x -> x + 1) 7  (* = 8 *)
```

:::slide

## Anonymous functions

- `fun x -> e` is the expression form.
- It's a value of function type.

```ocaml
let _ = fun x -> x + 1  (* : int -> int = <fun> *)
```

- The function exists; just unnamed.

:::

:::slide

## Anonymous functions, applied on the spot

```ocaml
let _ = (fun x -> x + 1) 7  (* = 8 *)
```

- Parenthesize, then apply.
- Parens are needed: application binds tighter than `fun`.
- Key point: `fun ... -> ...` is a real expression.

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
- Third form makes it explicit: a "two-argument function" is really
  a one-argument function returning another one-argument function.
- Deeper dive: **currying**, Lecture 3.

:::

All three define the same function. The third form makes this
explicit: a "two-argument function" in OCaml is really a
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

let _ = plus_one 5  (* = 6 *)
let _ = double 5    (* = 10 *)
let _ = triple 5    (* = 15 *)
```

:::slide

## Functions are values you can name

```ocaml
let plus_one = fun x -> x + 1
let double   = fun x -> x * 2
let triple   = fun x -> x * 3

let _ = plus_one 5  (* = 6 *)
let _ = double 5    (* = 10 *)
let _ = triple 5    (* = 15 *)
```

- Three function values, named with `let`, then applied.
- Same shape as `let pi = 3.14`; the value just happens to be a function.

:::

Three `let` bindings. The shape is identical to `let pi = 3.14`,
or `let greeting = "hello"`: a name bound to a value. The only
difference is that the *value* happens to be a function. The
language does not distinguish.

A related case: a *thunk* is a function whose parameter is the
unit value `()`. Its type is `unit -> 'a` for some `'a`. The body runs not when the thunk is
defined, but each time you call it with `()`:

```ocaml
let greet () = "hello"

let _ = greet     (* : unit -> string = <fun> *)
let _ = greet ()  (* = "hello" *)
```

`greet` is the thunk: a value of type `unit -> string`. The first
`let _ = greet` does not invoke the body; it simply names the
function value. The second, `greet ()`, applies the thunk and
produces `"hello"`. Each application re-runs the body. The thunk
is the canonical way to bundle a computation as a value and
decide *later* when to perform it; you will see thunks again in
[the streams-and-laziness lecture](M07-L04-streams-and-laziness.html),
where a stream's tail is exactly a `unit -> 'a stream` thunk.

## Functions can be returned from other functions

The next step: a function whose return value is *another function*.

```ocaml
let make_adder n = fun x -> x + n

let plus_five = make_adder 5
let plus_ten  = make_adder 10

let _ = plus_five 3  (* = 8 *)
let _ = plus_ten 3   (* = 13 *)
```

:::slide

## Functions can be returned from other functions

```ocaml
let make_adder n = fun x -> x + n

let plus_five = make_adder 5
let plus_ten  = make_adder 10

let _ = plus_five 3  (* = 8 *)
let _ = plus_ten 3   (* = 13 *)
```

- `make_adder : int -> (int -> int)`.
- `make_adder 5`: a new function that adds 5.
- `make_adder 10`: another that adds 10.
- First **higher-order function**: takes or returns functions.

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

Here is the subtle part. When `plus_five 3` runs, the body is
`x + n`. The parameter `x` is bound to `3`. But
where does `n` come from? It is not a parameter of `plus_five`. It
was a parameter of `make_adder`, and `make_adder` has long since
returned.

The answer is that the function value `plus_five` does not just
hold "the function body"; it also holds a record of "what `n` was
when this function was created." The value `n = 5` was *captured*
by the function at the moment of its creation. Such a function-value-with-captured-environment
is called a *closure*. We saw closures briefly in
[the let-bindings lecture](M02-L02-let-bindings.html#why-shadowing-differs-from-mutation-closures-see-the-old-value)
(the function captures the *value*, not the *name*).

:::slide

## A function value remembers its environment

```ocaml
let make_adder n = fun x -> x + n

let plus_five = make_adder 5
let _ = plus_five 100  (* = 105 *)
```

- In `plus_five 100`, body is `x + n`. Where does `n` come from?
- It was `make_adder`'s parameter; `make_adder` has long returned.
- OCaml functions are **closures**: they capture values at creation.
- `plus_five` remembers `n = 5` forever.

:::

`plus_five 100` returns `105`. The captured `n = 5` is used in
the body. The closure ensures that `plus_five` keeps working even
after `make_adder` has returned and its activation frame is gone.

## What is a closure?

Here is the definition in precise form. A name that appears in a
function's body but is not bound by the function's parameters or
by any `let` inside the body is called a *free variable* of the
function. When the function is created at runtime, OCaml records
the current value of each free variable into the function value
itself; this recording step is called *capture*, and the table
of captured values is called the *environment of the closure*. A
*closure*, then, is a function value paired with its environment.

At application time the rule for the body is: a parameter gets its
value from the call's argument, and a free variable gets its value
from the environment. In `plus_five 100`, the body `x + n` runs
with `x = 100` (the argument) and `n = 5` (read from the
environment); no other source of values exists.

The point of the environment is that the captured values can be
read *long after* the surrounding scope that originally bound
them has gone away. The function value is self-contained: body
plus environment.

One free variable:

```ocaml
let make_adder n = fun x -> x + n
```

The inner `fun x -> x + n` has parameter `x` and one free
variable `n`. Each call `make_adder k` returns a closure whose
environment contains `n = k`.

Two free variables:

```ocaml
let between lo hi = fun x -> lo <= x && x <= hi
```

The inner `fun x -> ...` has parameter `x` and two free
variables, `lo` and `hi`. `between 0 10` returns a closure whose
environment contains `lo = 0` and `hi = 10`; that closure then
takes one `int` and returns a `bool`.

A function with no free variables (`fun x -> x + 1`) is still a
closure, just with an empty environment.

:::slide

## What is a closure?

A function whose body refers to bindings that are in scope but
are **not** parameters of the function.

- The referenced name is a **free variable** of the function.
- When the function is created, the current value of each free
  variable is **captured**.
- The captured values form the closure's **environment**.

A function value = its body + its environment.

:::

:::slide

## Closures: one free variable

```ocaml
let make_adder n = fun x -> x + n
```

- The inner `fun x -> x + n` has
  - parameter `x` and
  - one free variable `n`.
- `make_adder 5` returns a closure.
- Environment holds `n = 5`.

:::

:::slide

## Closures: two free variables

```ocaml
let between lo hi = fun x -> lo <= x && x <= hi
```

- The inner `fun x -> ...` has
  - parameter `x` and
  - two free variables: `lo`, `hi`.
- `between 0 10` returns a closure.
- Environment holds `lo = 0`, `hi = 10`.

:::

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

- `f` captured the **value** `10` when defined.
- Later `let n = 99` shadows the outer `n` but doesn't change what `f` saw.
- Same shadowing-vs-mutation point from Module 2.

:::

Returns `11`. The closure captured `n = 10` when `f` was defined;
the later `let n = 99` shadows the outer `n` but does not change
the value `f` saw. This is the same point from
[the let-bindings lecture](M02-L02-let-bindings.html#shadowing)
(shadowing is not mutation), applied to function closures.

OCaml uses *static scoping with value capture*: the binding that
was in scope when `f` was defined is the one `f` uses, forever. In
a language where names were re-looked-up at call time, or where the
closure held a *reference* to the variable rather than its value,
`f 1` could see a later assignment. OCaml does neither.

## Functions can be passed as arguments

The third thing you can do with a value: pass it as an argument.

```ocaml
let apply_twice f x = f (f x)

let _ = apply_twice (fun x -> x + 1) 5  (* = 7 *)
let _ = apply_twice double 5            (* = 20 *)
```

:::slide

## Functions can be passed as arguments

```ocaml
let apply_twice f x = f (f x)

let _ = apply_twice (fun x -> x + 1) 5  (* = 7 *)
let _ = apply_twice double 5            (* = 20 *)
```

- `apply_twice f x = f (f x)`.
- First call: anonymous `fun x -> x + 1`. Second: `double`.
- Toplevel: `val apply_twice : ('a -> 'a) -> 'a -> 'a = <fun>`.
- `'a` is a **type variable**: any type, same one each occurrence.
- Works at `int -> int`, `float -> float`, `string -> string`, ...
- This is **polymorphism**. Formal treatment:
  [the recursive-types lecture](M04-L04-recursive-types.html#polymorphism).

:::

`apply_twice` takes a function `f` and a value `x`, and computes
`f (f x)`. The first call passes the anonymous function `fun x ->
x + 1` (so we get `((5 + 1) + 1) = 7`); the second passes `double`
(so we get `(5 * 2) * 2 = 20`).

The toplevel reports `val apply_twice : ('a -> 'a) -> 'a -> 'a =
<fun>`. Parsed: takes a function from `'a` to `'a`, plus an `'a`,
and returns an `'a`. The `'a` is a *type variable*: it stands for
"some type, the same one in each occurrence." A function whose
type contains type variables is called *polymorphic*: it works at
every choice of `'a`, with no special-casing per type. The same
`apply_twice` works for `int -> int` functions, `float -> float`
functions, `string -> string` functions, etc.

This is the first time we are seeing a type variable; we will
return to polymorphism formally in
[the recursive-types lecture](M04-L04-recursive-types.html#polymorphism),
once we have parameterised variants (lists of *anything*) to motivate
it. For now, read `'a -> 'a` as "any type to itself."

## Anonymous functions are everywhere

You will write `fun x -> ...` a lot. It is the standard way to pass
a small one-off function to a higher-order utility like `List.map`.

```ocaml
let nums = [1; 2; 3; 4; 5]
let _ = List.map (fun x -> x * x) nums  (* = [1; 4; 9; 16; 25] *)
```

:::slide

## Anonymous functions are everywhere

- Standard way to pass a small one-off function (e.g. to `List.map`).

```ocaml
let nums = [1; 2; 3; 4; 5]
let _ = List.map (fun x -> x * x) nums  (* = [1; 4; 9; 16; 25] *)
```

Without anonymous functions:

```ocaml
let square x = x * x
let _ = List.map square nums  (* = [1; 4; 9; 16; 25] *)
```

- First form is shorter; idiom leans this way for one-offs.

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
let _ = List.map square nums  (* = [1; 4; 9; 16; 25] *)
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

```text
val add : int -> int -> int
```

- Reads as `int -> (int -> int)`.
- Arrows associate right.

:::fragment

```text
val apply_twice : ('a -> 'a) -> 'a -> 'a
```

- Reads as `('a -> 'a) -> ('a -> 'a)`.
- First arg is a function; parens make it explicit.

Read left-to-right, inserting "and given an X, produces":

> "given an `('a -> 'a)`, produces (given an `'a`, produces an `'a`)"

:::

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
What is the type of `fun s -> s ^ "!"`?

- [x] `string -> string`
- [ ] `char -> string`
- [ ] `'a -> string`
- [ ] `'a -> 'a`

**Why:** the literal `"!"` is a `string`, and the concatenation
operator `^` works on strings only. It forces its left operand
(the parameter `s`) to be `string`, and the result of the
concatenation is `string`. So the anonymous function is
`string -> string`. The operator pins both ends; nothing is left
polymorphic.
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

:::solution

Reference solution: `let compose g f = fun x -> g (f x)`, or
equivalently `let compose g f x = g (f x)`. Function composition
is used constantly in functional programming; we will return to
it in [Module 6](M06-L05-pipelines.html#function-composition).

:::

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

```ocaml
fun x -> x +. 1.0
```

- Type: `float -> float`.
- `+.` forces `x` to be `float`; result is `float`.

Trickier:

```ocaml
fun f x -> f (f x)
```

- Anonymous `apply_twice`.
- Type: `('a -> 'a) -> 'a -> 'a`.

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

- Functions that call themselves to process structures.
- Bread and butter of functional programming.

:::

## Reading

- **Cornell CS3110**, *Functions*: the corresponding chapter:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
- **Real World OCaml**, *Variables and functions*: same material
  from a different angle:
  <https://dev.realworldocaml.org/variables-and-functions.html>
- John Whitington, *OCaml from the Very Beginning*, Chapter 3:
  for a gentler pace.
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.

<!-- ===== source: old/M03-L02-recursion.md ===== -->
---
title: "Recursion"
lecture_no: 2
week: 3
duration_target_min: 25
concepts: [recursion, base case, recursive case, structural recursion, termination]
keywords: [OCaml, recursion, recursive functions, base case, factorial, list length]
activity_question: "Write a recursive function [count_up : int -> int -> unit] that prints each integer from [lo] up to [hi] (inclusive). What is the base case, and how does the recursive call differ from [count_down]?"
think_about_this: "Every recursive function needs a base case. What goes wrong if you forget one? What goes wrong if you have one but the recursive call never approaches it?"
reading:
  - title: "Cornell CS3110, Recursion"
    url: https://cs3110.github.io/textbook/chapters/basics/functions.html
---

# Recursion


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Recursion</h2>
<p class="title-slide-label">Module 3 &middot; Lecture 2</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

:::slide

## This lecture: recursion

- A *recursive* function calls itself.
- In OCaml, recursion replaces most uses of `for` / `while` loops.
- Every recursive function has the same three-part shape:
  - one or more *base cases* (direct answer, no recursion);
  - a *recursive case* on a smaller input;
  - termination: the smaller input approaches a base case.
- Recursion in OCaml is cheap; the compiler is good at it.
- Tail recursion (next lecture) makes it efficient.

:::

A recursive function is one that calls itself. In a language without
mutable loop variables, recursion is the main way to "do something N
times" or "walk through a structure." This lecture is about how to
write a recursive function correctly: when to recur, where the base
case goes, why termination matters, and how to think about the whole
thing without getting dizzy.

You have written `for` loops and `while` loops in C, Java, or Python.
In OCaml you will write very few. The closest thing is a `for` loop,
which exists in the language (we cover it in
[the arrays-and-mutation lecture](M07-L02-arrays-and-mutation.html#ocamls-for-and-while-loops))
but is rarely used because mutable state is rarely the natural way
to express a computation. Almost everything that would be a loop
in C is a recursive function in OCaml. That sounds expensive
(function calls? for a loop?), but recursion in OCaml is cheap,
and the compiler is good at translating the natural recursive
style into efficient code. We will see how later in
[the tail-recursion lecture](M03-L04-tail-recursion.html). For now,
the goal is to get comfortable writing recursive functions in the
first place.

## A first recursive function

The classic example is factorial. `0!` is `1`; `n!` for positive
`n` is `n * (n-1)!`. Translated directly:

```ocaml
let rec factorial n =
  if n = 0 then 1
  else n * factorial (n - 1)

let _ = factorial 5  (* = 120 *)
```

:::slide

## A first recursive function

```ocaml
let rec factorial n =
  if n = 0 then 1
  else n * factorial (n - 1)

let _ = factorial 5  (* = 120 *)
```

Three things to notice:

- The keyword `rec`: without it, `factorial` isn't in scope in its body.
- The **base case** `if n = 0 then 1`: without one, recursion never stops.
- The **recursive case** `n * factorial (n - 1)`: refers back to the
  function on a *smaller* argument.

:::

Result: `int = 120`, the factorial of 5. Three things to notice in
the definition:

**The `rec` keyword.** OCaml writes `let rec` to introduce a
recursive function. Without `rec`, the name `factorial` is not in
scope inside its own body, and the compiler reports `Unbound value
factorial`. The next slide explains why this is the default.

**The base case.** `if n = 0 then 1`: when the input has the
smallest shape (here, zero), the function returns a direct answer
without recursing. Every recursive function needs at least one
base case. Without one, the function calls itself forever, exhausts
the stack, and crashes.

**The recursive case.** `else n * factorial (n - 1)`: the function
defines its answer in terms of its answer on a *smaller* input.
The smaller input is closer to the base case. The recursive case
trusts that the function works on the smaller input, and combines
that result with the current value to produce the answer for the
current input.

This three-part shape (one or more base cases, plus a recursive
case that reduces toward them) is *every* recursive function you
will write. The pieces vary; the shape does not. Module 3 is
largely about getting fluent with this shape.

## Why `let rec` and not just `let`?

If you forget `rec`, you get a perplexing error. Try:

```text
let factorial n =
  if n = 0 then 1
  else n * factorial (n - 1)
```

:::slide

## Why `let rec` and not just `let`?

```text
let factorial n =
  if n = 0 then 1
  else n * factorial (n - 1)
```

- OCaml rejects: `Unbound value factorial`.
- Inside a plain `let f = ...`, the name `f` isn't yet in scope.
- `let rec` brings the name into scope inside the body.
- Use `let rec` when the function refers to itself.

:::

OCaml rejects this: *"Error: Unbound value factorial."* The reason
is a deliberate choice in the language design. Inside the body of
a plain `let factorial = ...`, the name `factorial` is *not yet in
scope*. References to `factorial` inside the body mean the outer
`factorial` (if any), not the one being defined.

This is the same rule we used for shadowing in
[the let-bindings lecture](M02-L02-let-bindings.html#shadowing): `let x = x + 1`
means "the new `x` is the old `x` plus one." If `let` brought the
new name into scope eagerly, this would mean something different
(an infinite loop trying to reference itself). The default for
`let` is "right-hand side sees the outer scope."

`let rec` overrides this: it says "yes, the name *is* in scope
inside the body too, because the function needs to call itself."
The keyword is a small but important signal: any reader sees `let
rec` and knows this function is recursive, before reading the body.

## Recursion on lists

Lists are the workhorse data structure of every ML-family language,
and recursion on lists is the workhorse pattern. Here is the
classic: count the elements of a list.

```ocaml
let rec length xs =
  match xs with
  | [] -> 0
  | _ :: rest -> 1 + length rest

let _ = length [10; 20; 30; 40]  (* = 4 *)
```

:::slide

## Recursion on lists

```ocaml
let rec length xs =
  match xs with
  | [] -> 0
  | _ :: rest -> 1 + length rest

let _ = length [10; 20; 30; 40]  (* = 4 *)
```

- Base case `[] -> 0`: empty list has length 0.
- Recursive case `_ :: rest -> 1 + length rest`: strip head, recur.
- Uses pattern matching (full coverage in Module 5).

:::

The function uses `match ... with`, which we
will study in detail in [Module 5](M05-L01-basic-patterns.html).
For now, read it as a multi-way branch on the *shape* of the input:

- `[] -> 0`: if the list is empty, return 0.
- `_ :: rest -> 1 + length rest`: if the list has a head element
  (which we don't care about, denoted `_`) and a tail `rest`,
  return 1 plus the length of `rest`.

The `::` is the *cons* constructor: every non-empty list is some
element followed by another list. The pattern `_ :: rest` matches
any non-empty list and binds `rest` to the tail.

This shape (one base case for the empty list, one recursive case
that strips one element and recurs on the rest) is so common it
has a name: *structural recursion on lists*. Most list functions
in OCaml's standard library are written this way:
[`List.map`](M06-L02-map.html), `List.length`,
[`List.filter`](M06-L03-filter.html),
[`List.fold_left`](M06-L04-fold.html). We will revisit all of
them in Module 6.

## Recursion on numbers, counting down

We can also recurse on integers. Here is a function that prints
`n`, `n-1`, ..., 0, in order:

```ocaml
let rec count_down n =
  if n < 0 then ()
  else begin
    print_endline (string_of_int n);
    count_down (n - 1)
  end

let _ = count_down 5  (* prints 5 4 3 2 1 0, one per line *)
```

:::slide

## Recursion on numbers, counting down

```ocaml
let rec count_down n =
  if n < 0 then ()
  else begin
    print_endline (string_of_int n);
    count_down (n - 1)
  end

let _ = count_down 5  (* prints 5 4 3 2 1 0, one per line *)
```

- Base case `n < 0`: do nothing.
- Recursive case: print `n`, then recur on `n - 1`.
- `begin ... end`: sequenced block (more in Module 7).

:::

Run it; you should see `5`, `4`, `3`, `2`, `1`, `0`, each on its
own line. The base case is `n < 0`: do nothing, return `()`. The
recursive case prints the current number and recurs on one less.

The `begin ... end` brackets are just sugar for `(...)`: they
group multiple statements into one expression. Here, "print, then
recur" is the sequenced body. We need the bracketing because the
sequencing `;` would otherwise be ambiguous with the `else`
branch. `begin/end` is the more readable form in OCaml; plain
parens work too. (Side effects and sequencing get full treatment
in [the references lecture](M07-L01-references.html) of Module 7;
for this lecture, just trust the brackets do what you would
expect.)

## Recursion on numbers, summing

Here is a recursive sum function:

```ocaml
let rec sum_up_to n =
  if n = 0 then 0
  else n + sum_up_to (n - 1)

let _ = sum_up_to 10  (* = 55 *)
```

:::slide

## Recursion on numbers, summing

```ocaml
let rec sum_up_to n =
  if n = 0 then 0
  else n + sum_up_to (n - 1)

let _ = sum_up_to 10  (* = 55 *)
```

- Each step reduces `n` by one until zero.
- Closed form `n * (n + 1) / 2` is faster.
- Recursion here to illustrate the pattern.

:::

Result: `55` (which is `10 + 9 + ... + 1 + 0`). There is a
closed-form expression for this sum, `n * (n + 1) / 2`, which is
constant-time rather than linear-time; in real code you would use
the closed form. The recursive version exists to illustrate the
pattern.

This is the cleanest demonstration of the recursive shape on
numbers: base case is zero (the sum of nothing is zero); recursive
case is "the sum up to `n` is `n` plus the sum up to `n-1`."

## Termination: the thing that can go wrong

The most important property of a recursive function is that it
*terminates*: every recursion eventually hits a base case. Here is
a function that does not:

```text
let rec bad n = bad (n + 1)
```

:::slide

## Termination

Every recursive function must **terminate**: hit a base case.

```text
let rec bad n = bad (n + 1)
```

- Type-checks; runs forever; stack overflows.

For termination, every recursive call must move *closer* to a base case.

- `factorial (n - 1)` is closer to `0`.
- `length rest` is shorter than `length xs`.

Always ask: is the recursive argument strictly smaller?

:::

`bad` type-checks fine (the compiler does not verify termination
for arbitrary functions; in general, it cannot, because the
halting problem is undecidable). If you run it, the program calls
`bad (n+1)`, then `bad (n+2)`, then `bad (n+3)`, forever; each
call adds a frame to the stack; eventually the stack overflows
and the program crashes with `Stack overflow during evaluation`.

For termination, the discipline is: every recursive call must
move *closer* to a base case, by some measure. `factorial (n-1)`
is closer to `0` than `factorial n`, if `n` started non-negative.
`length rest` is shorter than `length xs`, if the pattern matched
`_ :: rest`. Whenever you write a recursive call, ask: by what
measure is the argument smaller? If you cannot give a clear
answer, the function might not terminate.

The compiler will not check this for you. You are responsible.
The good news is that for the standard shapes (recurse on a
number that decreases, recurse on a list that shrinks), the
measure is obvious. For more elaborate recursion patterns, you
sometimes have to think carefully.

## What if the input is unexpected?

Consider `factorial` again. What if you call it with a negative
input?

```text
let rec factorial n =
  if n = 0 then 1
  else n * factorial (n - 1)

let _ = factorial (-1)  (* Stack overflow! *)
```

:::slide

## What if the input is negative?

```text
let rec factorial n =
  if n = 0 then 1
  else n * factorial (n - 1)

let _ = factorial (-1)  (* Stack overflow! *)
```

- Stack overflow: `-1, -2, -3, ...` never reaches `0`.

Fix 1: loosen the base case.

```ocaml
let rec factorial n =
  if n <= 0 then 1
  else n * factorial (n - 1)
```

- `<= 0`: treat all non-positive inputs as base.

:::

:::slide

## What if the input is negative?: be strict

Fix 2: reject bad inputs.

```ocaml
let rec factorial n =
  if n < 0 then invalid_arg "factorial: negative input"
  else if n = 0 then 1
  else n * factorial (n - 1)
```

- Rejects negative inputs; surfaces the bug.
- Permissive `<= 0` silently accepts nonsense; strict version
  catches it early.
- Library code: prefer strict. Quick script: permissive is fine.

:::

Stack overflow. The base case is `n = 0`, but if `n = -1`, the
recursive call is `factorial (-2)`, then `factorial (-3)`, and so
on: the recursion moves *away* from the base case.

Two fixes:

1. **Loosen the base case** to catch the bad inputs:

   ```ocaml
   let rec factorial n =
     if n <= 0 then 1
     else n * factorial (n - 1)
   ```

   Now any non-positive input returns 1. This is permissive: it
   silently treats nonsense inputs as `0!`.

2. **Be strict** about valid inputs:

   ```ocaml
   let rec factorial n =
     if n < 0 then invalid_arg "factorial: negative input"
     else if n = 0 then 1
     else n * factorial (n - 1)
   ```

   `invalid_arg` raises an exception (we will see exceptions in
   [Module 7](M07-L03-exceptions.html)). This rejects nonsense
   inputs with a runtime error.

Which is better depends on your context. The strict version
catches bugs early; the permissive version "just works." For a
library function with documented preconditions, the strict version
is usually better. For a quick script where you control all the
inputs, the permissive version is fine. Both are defensible; the
key is to choose deliberately.

## The mental model

The rhythm for reading or writing a recursive function:

:::slide

## The mental model

Rhythm for reading or writing a recursive function:

1. **What is the input made of?** Number (zero or successor)? List (empty or cons)?
2. **What is the base case?** Answer for the smallest input.
3. **What is the recursive case?** Trust the function on smaller
   input; combine with current piece.

This is the **inductive style**.

:::

Three questions:

1. **What is the input made of?** A number is either zero or one
   more than another number. A list is either empty or a head
   followed by another list. Whatever data you are recursing on
   has a *shape* that determines the pattern of cases.

2. **What is the base case?** What is the smallest possible input,
   and what is the answer for it? For a number, usually zero. For
   a list, usually `[]`.

3. **What is the recursive case?** Given a non-smallest input,
   what is the answer in terms of the answer for a *smaller*
   input? You assume the function works correctly on smaller
   inputs (call this the *induction hypothesis*) and write the
   answer for the current input in terms of that.

This is the *inductive style*. It is the same kind of reasoning
you used for proofs by induction in discrete math: prove the base
case, prove that if it works for `n` it works for `n+1`, conclude
it works for all `n`. Recursive function definition is the
computational version of inductive proof. Once you internalise
this style, writing recursive functions becomes mechanical.

## Worked example: power

Compute `x^n` for non-negative integer `n`.

```ocaml
let rec power x n =
  if n = 0 then 1
  else x * power x (n - 1)

let _ = power 2 10  (* = 1024 *)
```

:::slide

## Worked example: power

`power x n = x^n` for integer `n ≥ 0`.

```ocaml
let rec power x n =
  if n = 0 then 1
  else x * power x (n - 1)

let _ = power 2 10  (* = 1024 *)
```

- Base case: anything to the zero is `1`.
- Recursive case: `x^n = x * x^(n-1)`. `n` moves toward the base.

:::

The function follows the same shape: base case `n
= 0` returns `1`; recursive case `x^n = x * x^(n-1)`. Note that
`x` is unchanged in the recursive call; only `n` is reduced. This
is fine: the *measure* by which the recursion makes progress is
`n`, not `x`.

## Two recursive calls: Fibonacci

A recursive function does not have to make exactly one recursive
call per case. Fibonacci makes two:

```ocaml
let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)

let _ = fib 10  (* = 55 *)
```

:::slide

## Two recursive calls: Fibonacci

```ocaml
let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)

let _ = fib 10  (* = 55 *)
```

- Two base cases bundled: `fib 0 = 0`, `fib 1 = 1`.
- Recursive case has *two* calls.
- Slow for large `n`: overlapping subproblems recomputed.
- Revisited in the tail-recursion lecture and in Module 6.

:::

Result: `55` (the 10th Fibonacci number). The base case is `n <
2`, which bundles two cases: `fib 0 = 0` and `fib 1 = 1`. The
recursive case calls `fib` twice with different smaller arguments.

This implementation is *slow* for large `n`. Each call computes
`fib (n-1)` and `fib (n-2)`; both of those compute overlapping
subproblems from scratch. The number of function calls grows
exponentially. `fib 40` already takes a noticeable second; `fib
50` takes minutes. The classic fix is *memoisation* (caching
already-computed results) or *iterative bottom-up computation*
(building up from `fib 0` and `fib 1`); we will see the latter
in the [Module 3 tutorial](M03-L06-tutorial.html#why-is-naive-fibonacci-so-slow).

## A small code challenge

:::quiz code id=M03-L02-q2
Write a recursive function `sum_list : int list -> int` that
returns the sum of a list of integers. Empty list sums to 0.

```ocaml
let rec sum_list xs =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (sum_list []           =  0) "empty";
  check (sum_list [1; 2; 3]    =  6) "small";
  check (sum_list [10; -3; 5]  = 12) "with negative";
  check (sum_list [0; 0; 0; 0] =  0) "all zeros";
  print_endline "all tests passed"
```
:::

:::solution

The shape: `match xs with | [] -> 0 | x :: rest -> x + sum_list
rest`. Structural recursion on the list: base case is `[]`,
recursive case is "first element plus sum of the rest."

:::

## Activity

:::slide

## Activity

Write a recursive function `count_up : int -> int -> unit` that
prints each integer from `lo` up to `hi` (inclusive). What is the
base case, and how does the recursive call differ from
`count_down`?

:::

:::solution

:::slide

## Activity solution

```ocaml
let rec count_up lo hi =
  if lo > hi then ()
  else begin
    print_endline (string_of_int lo);
    count_up (lo + 1) hi
  end
```

- Base case `lo > hi`: do nothing.
- Recursive case: print `lo`, recur on `(lo + 1) hi` (only `lo` changes).
- Trace `count_up 1 3`: prints `1, 2, 3`, then `count_up 4 3` hits base.

:::

:::

:::quiz mcq id=M03-L02-q1
For the function below, what is the base case?

```ocaml
let rec count_up lo hi =
  if lo > hi then ()
  else begin
    print_endline (string_of_int lo);
    count_up (lo + 1) hi
  end
```

- [ ] `lo = hi`
- [x] `lo > hi`
- [ ] `lo = 0`
- [ ] There is no base case.

**Why:** the function returns `()` (does nothing) when `lo > hi`.
The recursive case prints `lo` and then calls `count_up (lo + 1)
hi`. For `count_up 1 3`, the prints are `1`, `2`, `3`, then
`count_up 4 3` hits the base case and stops. If the base case
were `lo = hi`, the function would print `1`, `2` and stop
without printing `3`. The current base case (`lo > hi`) is what
makes `hi` print.
:::

## What's next

We have introduced the basic shape of recursion. The next two
lectures put recursion to better use.
[M03-L03](M03-L03-currying.html) covers *currying* and *partial
application*: making the "function returning function" pattern
explicit and using it to write small reusable utilities.
[M03-L04](M03-L04-tail-recursion.html) covers *tail recursion*:
how to make recursive functions run in constant stack space, so
you can recurse on lists of millions of elements without blowing
the stack.

:::slide

## What's next

Lecture 3: **currying and partial application**.

- Make explicit the "function returning function" pattern.

Lecture 4: **tail recursion**.

- Fixes the stack-overflow risk of naive recursive functions.

:::

## Reading

- **Cornell CS3110**, *Recursion*: the textbook chapter, with
  more worked examples and the math-induction connection
  explored:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
- **Real World OCaml**, *Lists and Patterns* (recursion section):
  <https://dev.realworldocaml.org/lists-and-patterns.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.

<!-- ===== source: old/M03-L03-currying.md ===== -->
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


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Currying and partial application</h2>
<p class="title-slide-label">Module 3 &middot; Lecture 3</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

:::slide

## This lecture: currying

- A multi-argument function is secretly a *chain* of one-argument functions.
- The shape is called *currying* (after Haskell Curry).
- It enables *partial application*: supply some arguments, get back a function wanting the rest.
- This is the Module 3 idea that most surprises C / Java / Python arrivals.
- Explains a lot of OCaml's API style:
  - why `List.map` takes the function first;
  - why operators have prefix forms like `(+)`.
- Four parts: unfolding, partial application, argument order, the tuple alternative.

:::

In OCaml, a function with multiple arguments is secretly a *chain*
of one-argument functions. This shape is called *currying*, after
the logician [Haskell Curry](https://en.wikipedia.org/wiki/Haskell_Curry)
(the same person the [Haskell](https://www.haskell.org/) language is
named for), and it makes a useful trick available: *partial
application*, supplying some of the arguments and getting back a
function that wants the rest.

Curry was generous about the name himself: the technique was
published in 1924 by Moses Schönfinkel, six years before Curry's
own work, so by the usual rule of priority we should arguably
call it *schönfinkelisation*. Curry built the systematic theory
and the catchier name stuck. It is a small lesson in how
mathematics, like software, often credits the person who
packaged an idea rather than the one who first had it.

This is, in my experience, the idea from Module 3 that most surprises
students arriving from C, Java, or Python. In those languages, a
function with two arguments is two arguments, full stop; you cannot
"call it with one and a half." Curried functions remove that
restriction. Once you internalise the picture, a number of common
patterns in OCaml code that previously looked mysterious become
obvious: why `List.map` takes the function before the list, why so
many standard library functions can be passed around fluently, why
operators have prefix forms like `(+)`. They are all corollaries of
one design choice.

The lecture has four parts. First, the unfolding: what `let f x y =
...` *really* desugars to. Second, partial application in everyday
use. Third, the consequences for API design (argument order matters).
Fourth, a comparison with the tuple alternative, so you know when
*not* to want currying.

## Unfolding a two-argument function

You already know how to define a two-argument function:

```ocaml
let add x y = x + y
```

The type is `int -> int -> int`. There are two ways to read that
type, and the design of OCaml only makes sense once you have both.

The first reading is the everyday one: "a function that takes two
`int`s and returns an `int`." That is how you will read it
ninety-nine percent of the time, and it is correct.

The second reading takes the type signature literally. We saw in
[the functions-as-values lecture](M03-L01-functions-as-values.html#reading-function-types-is-right-associative)
that `->` is right-associative, so `int -> int -> int` parses as
`int -> (int -> int)`. Under that parse, `add` is a function that
takes *one* `int` and returns *another function* of type
`int -> int`. The "returned function" is the one that does the
actual addition.

Both readings are correct, and they describe the same function,
because the desugaring of `let add x y = x + y` is literally
`let add = fun x -> fun y -> x + y`. The shorthand on the left and
the nested-`fun` form on the right are the same definition.

:::slide

## Two-argument functions, unfolded

```ocaml
let add x y = x + y
```

This is short for:

```ocaml
let add = fun x -> fun y -> x + y
```

- `add` takes one argument `x`.
- Result: a function of one argument `y` returning `x + y`.

Type confirms:

```text
val add : int -> int -> int
```

- Right-associative: `int -> (int -> int)`.
- Takes an int, returns a function from int to int.

:::

A useful slogan, from Cornell's [CS3110 textbook](https://cs3110.github.io/textbook/chapters/basics/functions.html):
*every OCaml function takes exactly one argument*. A "three-argument"
function is a one-argument function that returns a "two-argument"
function, which is itself a one-argument function that returns a
"one-argument" function. The function-type arrow is right-associative
to match this view; the application syntax is left-associative for
the same reason. The names *currying* and *uncurrying* describe
moving between this view and the "tuple of arguments" view we will
return to at the end of the lecture.

## Partial application: the payoff

Once you accept that `add` is "a one-argument function returning a
function," you can apply it to one argument and stop. The result is
a function value.

```ocaml
let add x y = x + y
let add5 = add 5
```

`add5` has type `int -> int`. It is the function that adds 5 to its
argument. We did not write a `fun` anywhere; we just stopped applying
`add` halfway through. The technical name for this trick is
*partial application*, and the underlying mechanism is currying.

:::slide

## What does `add 5` do?

```ocaml
let add x y = x + y
let add5 = add 5
```

- `add5 : int -> int`. Adds 5 to whatever you give it.

```ocaml
let _ = add5 3  (* = 8 *)
```

- We *partially applied* `add` to one argument.
- Result: a function waiting for the rest.

:::

The picture is exactly the closure picture from
[the functions-as-values lecture](M03-L01-functions-as-values.html#a-function-value-remembers-its-environment).
When we apply `add` to `5`, the body `fun y -> x + y` becomes a
value with `x` captured to `5`. That captured value lives inside
the closure as long as the closure exists. Calls to `add5` reuse
that captured `5` forever; each call supplies a new `y`, computes
`5 + y`, and returns.

It is sometimes useful to read partial application as *specialisation*:
`add5` is a *specialised* version of `add` with one knob (`x`)
permanently set to `5`. You can specialise the same function in
multiple ways, getting multiple specialised functions, all coexisting
peacefully:

```ocaml
let add1   = add 1
let add100 = add 100
```

`add1` always adds one; `add100` always adds a hundred; they share
no state. Each is a separate closure with its own captured `x`.

## Why partial application matters in practice

The motivating use case is *passing a function to another function*.
Higher-order functions like `List.map` expect a function as their
first argument; partial application lets you build that function
inline without writing `fun x -> ...` for every little operation.

:::slide

## Why is this useful?

```ocaml
let xs = [1; 2; 3; 4]
let xs_plus_10 = List.map (add 10) xs  (* = [11; 12; 13; 14] *)
```

- `List.map` wants `int -> int`. `add 10` already *is* that.
- Currying eliminates small wrapper lambdas in higher-order code.

:::

Without currying you would write:

```ocaml
let xs_plus_10 = List.map (fun x -> add 10 x) xs
```

which works but is noisier. The version `List.map (add 10) xs` reads
as "map the add-10 function over `xs`." That form reads more directly.

You will see this idiom constantly in real OCaml code. Anywhere a
higher-order function expects a unary function, partial application
of a binary function is the shortest way to produce one. The
[Jane Street](https://www.janestreet.com) `Base` library, and the
standard library itself, are designed with this in mind: the function
argument almost always comes first, precisely so that callers can
partial-apply.

## Argument order matters

The first argument is the easiest to partial-apply. The second
argument requires more work; the third even more. So when you design
a function with multiple arguments, the *order* of the arguments
matters for how it will feel to use.

Suppose you wanted a `half` function from a generic `divide`:

```ocaml
let divide x y = x / y
let half x = divide x 2
```

You might be tempted to write `let half = divide 2`, by analogy to
`add5 = add 5`. But `divide 2` is *not* the halving function: it is
"the function that divides 2 by its argument." `divide 2 4` is
`2 / 4 = 0`, not `4 / 2 = 2`. The first argument of `divide` is the
numerator, which is *not* the part we want to fix.

:::slide

## Argument order matters for partial application

```ocaml
let divide x y = x / y
let half x = divide x 2  (* not "divide 2 x" *)
```

- `divide 2`: takes `y`, returns `2 / y`. Not "half".
- The **first** argument is the easiest to fix.

:::fragment

- Stdlib places arguments accordingly.

`List.map` takes the *function* first, *list* second:

```text
val List.map : ('a -> 'b) -> 'a list -> 'b list
```

- So `List.map (add 10)` partial-applies meaningfully.

:::

:::

The lesson generalises. When you write a function `f a b c`, ask:
which of these arguments is the most likely to be held fixed while
the others vary? That argument should go *first*. The most
"configuration-like" parameter goes leftmost; the most
"data-like" parameter goes rightmost. `List.map` follows this
exactly: the function (configuration, often a constant) comes first;
the list (data, varying) comes last. So does `List.filter`,
`List.fold_left`, `List.iter`, and essentially every higher-order
combinator in the standard library.

The dual mistake is also worth flagging: do not panic about argument
order on functions you will only ever fully apply. `divide 10 2` is
fine; the order only matters when you want to partial-apply.

## Operators have prefix forms too

Every infix operator in OCaml has a prefix form, obtained by
surrounding it in parentheses. `(+)` is the function corresponding
to `+`; `(*)` to `*` (with a quirk we will see); `(<)` to `<`.

This means you can partial-apply operators too:

```ocaml
let increment = (+) 1
let double    = ( * ) 2

let _ = increment 5  (* = 6 *)
let _ = double 5     (* = 10 *)
```

:::slide

## Operators have prefix forms too

```ocaml
let increment = (+) 1
let double    = ( * ) 2

let _ = increment 5  (* = 6 *)
let _ = double 5     (* = 10 *)
```

- `(+)` is prefix form of `+`: `fun x y -> x + y`.
- Partial-apply to `1` to get `increment`.
- Space inside `( * )` avoids being parsed as comment `(*`.

:::

Most infix operators have this prefix form: `(+)`, `(*)`, `(<)`,
`(^)`, `(&&)`. Useful when you want to pass the operator as a
function, for instance to `List.fold_left (+) 0 xs` to sum a list.

The one syntactic curiosity is the multiplication operator. `(*)`
on its own would be parsed as the start of a block comment `(*`,
so OCaml requires a space: `( * )`. The same trick applies to any
operator that would otherwise collide with comment syntax.

## Currying composes: more than two arguments

The pattern scales to functions with any number of arguments. A
three-argument function is just a chain of three nested one-argument
functions; you can stop at any point and get back a partially-applied
function.

```ocaml
let between lo hi x = x >= lo && x <= hi

let in_human_range  = between 0 150
let in_celsius_room = between 15.0 30.0

let _ = in_human_range 42     (* = true *)
let _ = in_celsius_room 22.5  (* = true *)
```

:::slide

## Multi-argument functions, the same pattern

```ocaml
let between lo hi x = x >= lo && x <= hi

let in_human_range = between 0 150  (* age in years *)
let in_celsius_room = between 15.0 30.0

let _ = in_human_range 42     (* = true *)
let _ = in_celsius_room 22.5  (* = true *)
```

- `between` takes three arguments.
- Partial-apply two; get a one-argument predicate.
- Same idea as `add 5`, one more layer of nesting.

:::

`between` has type `'a -> 'a -> 'a -> bool`. Each partial application
fixes one argument and returns a function of the rest. `between 0
150` has type `int -> bool`; `between 15.0 30.0` has type
`float -> bool`. We have built two purpose-specific predicates out
of one general one. Each predicate is a closure carrying its captured
bounds.

This is a clean illustration of the trade-off between *generality*
and *specificity* in API design. The general `between` is useful
because it works on any ordered type. The specialised predicates are
useful because they take fewer arguments at the call site and read
more clearly. Currying lets you have both: one general definition,
many specialised closures.

## Eta-reduction: a small simplification

When you find yourself writing `fun x -> g x` for some function `g`,
you can usually replace it with just `g`. The two are the same
function: both take an `x` and call `g` on it.

This simplification is called *eta-reduction* (after the Greek
letter "eta" used to label this rule in the *lambda calculus*).
Lambda calculus is a minimal formal system of functions, introduced
by Alonzo Church in the 1930s, with only three constructs: a
*variable* (`x`), a *function* (`fun x -> body`, called an
*abstraction*), and a *function call* (`f x`, called an
*application*). Despite this minimal vocabulary it is
Turing-complete, and it is the mathematical foundation of every
functional language including OCaml. The `fun` keyword we have
been writing is direct syntax for lambda-calculus abstraction;
function application is just juxtaposition. Eta-reduction is one
of three small rewriting rules that this calculus codifies (the
others are *alpha-conversion*, renaming a bound variable, and
*beta-reduction*, substituting an argument into a body). Beyond
the name, the rule is just: wrapping a function in a lambda that
does nothing but call it is busywork.

:::slide

## Eta-reduction: the rule

```text
let f x = g x
```

is the same function as

```text
let f = g
```

- Wrapping `g` in `fun x -> g x` is busywork.
- Named after the Greek letter η in **lambda calculus**.
- Lambda calculus = minimal formal system of functions
  (Church, 1930s); `fun x -> body` is its native syntax.

:::

:::slide

## Eta-reduction: an example

```ocaml
let incr x = x + 1
let f x = incr x
let g = incr
```

- `f` and `g` are the same function.
- Both have type `int -> int`.
- The right-hand form reads "`g` *is* `incr`."

:::

:::slide

## Eta-reduction with `List.map`

Build a reusable transformer with `List.map`:

```text
let add_ten xs = List.map ((+) 10) xs
```

eta-reduces to:

```ocaml
let add_ten = List.map ((+) 10)

let _ = add_ten [1; 2; 3; 4]  (* = [11; 12; 13; 14] *)
```

- Reads cleanly: "`add_ten` *is* map with `+10`."
- No surplus `fun xs -> ...`.

:::

The shorter form is generally preferable when it does not hurt
readability. It also clarifies what the function *is*: not "a
function that applies `g` to its input," but just `g` itself. The
caveat is *evaluation timing*. `let f = g` evaluates `g` once, at
the point of `let`; `let f x = g x` evaluates `g` at every call.
For pure functions, this is invisible. For functions that have side
effects when *constructed* (rare, but possible with lazy values or
closures over mutable state), the two are not the same. In everyday
code, eta-reduce freely.

## When currying isn't what you want: tuples

Sometimes "two arguments" is the wrong picture. Sometimes you have
*one* argument that happens to be a pair. The classic example is a
2D point: it makes no sense to specialise `distance` by fixing the
x-coordinate while leaving the y-coordinate variable. The two
coordinates are conceptually one thing.

For that case, OCaml has *tuples*. Take one argument that is a pair;
pattern-match it inside the function:

```ocaml
let add_pair (x, y) = x + y

let _ = add_pair (3, 4)  (* = 7 *)
```

:::slide

## When currying isn't what you want

- Sometimes you want "a pair of ints", not "an int then another int".
- Use a tuple:

```ocaml
let add_pair (x, y) = x + y

let _ = add_pair (3, 4)  (* = 7 *)
```

- `add_pair : int * int -> int`. One argument: a pair.
- Can't partial-apply the tuple version.
- Prefer curried; use tuple when values are *conceptually one thing*.

:::

The type `int * int -> int` reads "takes a pair of ints and returns
an int." There is only one argument. You cannot partial-apply
`add_pair`: you have to pass the whole pair.

The default in OCaml is curried. Tuples are reserved for cases where
the bundling is meaningful: a 2D point is `(x, y)`, a record's
old-and-new value is `(before, after)`, a function returning multiple
results uses a tuple. If you ever catch yourself writing a function
of `(int * int * int * int)` for a four-parameter computation where
the four are independent quantities, that is a smell: it should
probably be curried, or, better, a record with named fields (Module
4).

The standard library has `fst` and `snd` for projecting the
components of a pair, and `(fun (a, b) -> ...)` patterns to
destructure them. For larger tuples there is no built-in projection;
you destructure with patterns. We will see all of this in detail
when we get to product types in
[Module 4](M04-L01-tuples.html).

## A quick check

:::quiz mcq id=M03-L03-q3
Given `let between lo hi x = x >= lo && x <= hi`, what is the
type of `between 0 150`?

- [ ] `bool`
- [ ] `int -> int -> bool`
- [x] `int -> bool`
- [ ] `'a -> bool`

**Why:** `between` has type `'a -> 'a -> 'a -> bool`. The integer
literals `0` and `150` pin `'a` to `int`, and supplying the first
two arguments peels two arrows off the chain. What remains is the
one-argument predicate `int -> bool`, waiting for `x`. (It is not
`'a -> bool`: once the bounds are `int`, the third argument must
be `int` too.)
:::

:::quiz mcq id=M03-L03-q2
Which of these is *not* an idiomatic use of partial application?

- [ ] `List.map ((+) 1) [1; 2; 3]`
- [ ] `let add5 = (+) 5`
- [x] `let half = ( / ) 2`
- [ ] `List.filter ((<) 0) xs`

**Why:** `( / ) 2` is "the function that divides 2 by its argument,"
not "the halving function." The intended `half` would need
`fun x -> x / 2` or a custom `divide` whose argument order puts the
divisor first. The other three are standard idioms: `(+) 1`
increments, `(+) 5` adds five, and `(<) 0` partial-applies the
left-hand side of `<` to 0, giving the predicate "is greater than
zero."
:::

:::quiz code id=M03-L03-q1
Define `compose3` that takes three functions `h`, `g`, `f` and
returns the composed function `fun x -> h (g (f x))`.

```ocaml
let compose3 h g f =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let inc x = x + 1
let dbl x = x * 2
let neg x = -x
let () =
  check ((compose3 neg dbl inc) 3 = -8) "neg . dbl . inc on 3";
  check ((compose3 inc inc inc) 0 = 3)  "inc thrice on 0";
  check ((compose3 dbl dbl dbl) 1 = 8)  "dbl thrice on 1";
  print_endline "all tests passed"
```
:::

:::solution

The body is `fun x -> h (g (f x))`, or equivalently
`let compose3 h g f x = h (g (f x))`. Notice how the three functions
chain right-to-left: `f` runs first, then `g`, then `h`. This is the
standard mathematical convention for composition.

:::

## Activity

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

Before reading on, predict the three answers.

:::slide

## Activity discussion

```ocaml
let add x y = x + y
```

- Type of `add 5`: `int -> int`. It's the function `fun y -> 5 + y`.
- `add 5` evaluates to a function value. Toplevel: `int -> int = <fun>`.
- `(add 5) 3` evaluates to `8`. First compute `add 5`, then apply to `3`.
  - `add 5 3` (no parens) gives the same `8`.
- Function application is left-associative: `((add) 5) 3`.
  - The parens version just makes partial application explicit.

:::

`add 5` has type `int -> int`. It is a closure: a function value
that has captured `x = 5` and is waiting for `y`. The toplevel
reports `int -> int = <fun>`, where `<fun>` is the toplevel's
placeholder for "a function value, can't print." There is no way
to inspect the body of a closure from OCaml; you can only call it.

`(add 5) 3` evaluates to `8`. We first compute `add 5` (a closure),
then apply it to `3`. Inside the closure, `x` is `5` and `y` is now
`3`, so `x + y` is `8`.

`add 5 3` without parentheses gives the same `8`. Function
application is left-associative: `add 5 3` parses as `(add 5) 3`,
exactly the explicit form. The parentheses make partial application
visible but they do not change what is computed.

## A harder check: n-fold application

We wrote `apply_twice f x = f (f x)` in
[the functions-as-values lecture](M03-L01-functions-as-values.html).
This check generalizes it, and needs recursion as well as
currying.

:::quiz code id=M03-L03-q4
Write `apply_n : int -> ('a -> 'a) -> 'a -> 'a` so that
`apply_n n f x` computes `f (f (... (f x)))` with `n` applications
of `f`. For `n <= 0`, return `x` unchanged. Note the payoff of the
argument order: `apply_n 5 ((+) 1)` is itself a function, "add 5
the slow way."

```ocaml
let rec apply_n n f x =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (apply_n 3 (fun x -> x * 2) 1 = 8) "double thrice";
  check (apply_n 5 ((+) 1) 10 = 15) "increment five times";
  check (apply_n 0 (fun x -> x * 9) 7 = 7) "zero applications";
  check (apply_n 5 ((+) 1) 100 = 105) "partial application";
  print_endline "all tests passed"
```
:::

:::solution

```ocaml
let rec apply_n n f x =
  if n <= 0 then x
  else apply_n (n - 1) f (f x)
```

Each step peels one application off: apply `f` once, recurse with
`n - 1`. The accumulator is `x` itself, so the definition is
tail-recursive. `apply_n 2 f x` computes exactly `apply_twice f x`.

:::

## What's next

:::slide

## What's next

Lecture 4: **tail recursion**.

- Write recursive functions without stack-overflow risk on large inputs.
- Rewrite `factorial` and `sum` to be tail recursive.

:::

We have unpacked currying and partial application. The next
lecture, [M03-L04](M03-L04-tail-recursion.html), returns to the
recursion from [M03-L02](M03-L02-recursion.html) with a sharper
tool: *tail recursion*, the technique that lets recursive
functions run in constant stack space. The naive `factorial` and
`sum_up_to` from the recursion lecture overflow the stack on
large inputs; the tail-recursive versions do not. The mechanism
is small (an extra parameter), but the payoff is that you can
recurse on inputs of any size without worrying about the stack.

## Reading

- **Cornell CS3110**, *Multiple-argument functions*:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
- **Real World OCaml**, *Variables and functions* (multi-argument and
  currying):
  <https://dev.realworldocaml.org/variables-and-functions.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.

<!-- ===== source: old/M03-L04-tail-recursion.md ===== -->
---
title: "Tail recursion and accumulators"
lecture_no: 4
week: 3
duration_target_min: 25
concepts: [tail call, tail-recursive functions, accumulator pattern, stack frames]
keywords: [OCaml, tail recursion, accumulator, stack overflow, optimization]
activity_question: "Take the [power : int -> int -> int] function from the recursion lecture and rewrite it tail-recursively with an accumulator. Same signature; same answers; constant stack."
think_about_this: "Why does the compiler need to *recognize* a tail call, instead of optimizing every recursive call? What does a non-tail call need to keep on the stack that a tail call doesn't?"
reading:
  - title: "Cornell CS3110, Tail recursion"
    url: https://cs3110.github.io/textbook/chapters/basics/functions.html
---

# Tail recursion and accumulators


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Tail recursion and accumulators</h2>
<p class="title-slide-label">Module 3 &middot; Lecture 4</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

:::slide

## This lecture: tail recursion

- Naive recursive functions crash on big inputs: *stack overflow*.
  - Each call keeps a frame to finish work after the return.
- The fix: rewrite so the recursive call is the *last* step.
  - The compiler then reuses the frame: constant stack space.
- The tool: the *accumulator pattern*, one extra parameter.
- After this lecture: recursion as cheap as a C `for` loop.

:::

The naive `factorial` and `sum_up_to` we wrote in
[the recursion lecture](M03-L02-recursion.html#a-first-recursive-function)
work fine for small inputs and crash with a stack overflow for
big ones.
The crash is not a bug in OCaml; it is a fundamental consequence
of how function calls use memory. This lecture shows what is going
wrong, introduces the technique that fixes it, and walks through
the rewrite on several standard functions.

The technique has two names. *Tail recursion* refers to the shape of
the recursive function. *Tail-call optimisation* (often abbreviated
TCO) refers to what the compiler does with such a function. The two
work together: you write your recursion in a particular form, and
the compiler turns that form into a constant-space loop. Neither
half works alone. The compiler cannot rewrite arbitrary recursive
functions to be tail-recursive; you cannot avoid stack overflows by
wishing.

The cost to you is small: an extra parameter (the *accumulator*) and
an inner helper. The benefit is large: your recursive functions stop
crashing on big inputs and they run as fast as the equivalent `for`
loop in C. The technique is standard across functional languages
(Scheme, Haskell, ML, F#) and appears in mainstream ones with
caveats: [GCC](https://gcc.gnu.org/) and
[Clang](https://clang.llvm.org/) eliminate tail calls in C code
when optimisation is enabled; among JavaScript engines, only
JavaScriptCore (Safari) implements the proper tail calls the
language standard calls for; Java does not do it at all.

## What a stack overflow looks like

The simplest recursion that demonstrates the problem is summing the
integers from `1` to `n`. We saw the naive version in
[the recursion lecture](M03-L02-recursion.html#recursion-on-numbers-summing):

```ocaml
let rec sum_up_to n =
  if n = 0 then 0
  else n + sum_up_to (n - 1)
```

`sum_up_to 10` works. `sum_up_to 1_000` works. Push the input
high enough and it crashes. Run this cell and watch:

```ocaml skip
let _ = sum_up_to 1_000_000  (* Stack overflow! *)
```

The error is `Stack overflow during evaluation (looping
recursion?)`. It is not a looping recursion; the recursion
terminates correctly, each step reducing `n` by one. The problem
is that each call needs its own stack frame, and a million frames
is more than any environment will give us. Exactly where the
limit falls depends on the environment: the in-browser toplevel
on this page gives up after a few thousand frames, and native
OCaml lasts longer but falls over too; a million exceeds them
all. To understand why each call needs a frame,
look at the body of the recursive case: `n + sum_up_to (n - 1)`.
After the recursive call returns, we still need to do an addition:
take its result and add `n` to it. To do that addition, we have to
remember `n` across the call. That memory has to live somewhere;
the standard place is the stack.

This crash is common enough to have named a landmark of the
internet: the programming question-and-answer site
[Stack Overflow](https://en.wikipedia.org/wiki/Stack_Overflow),
founded in 2008, takes its name from exactly this failure. The
rest of this lecture is about avoiding it.

:::slide

## What a stack overflow looks like

```ocaml skip
let rec sum_up_to n =
  if n = 0 then 0
  else n + sum_up_to (n - 1)

let _ = sum_up_to 1_000_000  (* Stack overflow! *)
```

- Crashes: `Stack overflow during evaluation`.
- Each call needs a stack frame to remember "what to do with the result".
- Body `n + sum_up_to (n - 1)`: must remember `n` across the call.
- A million frames: the stack runs out long before the base case.
  - Exact limit varies by environment (in-browser: a few
    thousand frames).

:::

Picture the stack during `sum_up_to 5`. We push a frame for
`sum_up_to 5`, which calls `sum_up_to 4`; we push a frame for
that, which calls `sum_up_to 3`; another frame; another; another.
By the time we hit the base case `sum_up_to 0 = 0`, the stack has
*six* frames. Each frame holds a copy of `n` (5, 4, 3, 2, 1, 0
respectively) and a "return-here-and-add" instruction. As
`sum_up_to 0` returns 0, the stack unwinds: frame for `n = 1`
returns `1 + 0 = 1`; frame for
`n = 2` returns `2 + 1 = 3`; and so on, building up `15` at the
top.

For `n = 5` the stack of six frames is fine. For `n = 1_000_000`,
the stack runs out. The operating system (or, in the browser, the
JS engine) imposes a stack size limit; the browser's is the
strictest, typically room for a few thousand frames. Each frame
is some tens of bytes; enough frames, and we crash.

The problem is not specific to OCaml. Try the equivalent recursive
sum in Python, in Java, in C: they all crash for large `n`. Python
even crashes faster, because its recursion limit defaults to about
1000 (you have to explicitly raise it). The difference is that in
those languages, the natural way to compute a sum is a `for` loop,
which uses no stack at all; in OCaml, the natural way is recursion,
so we run into the stack limit a lot sooner unless we are careful.

## What is a tail call?

The fix is to rewrite the function so that the recursive call has
*nothing left to do after it returns*. Such a call is in *tail
position*.

The crisp definition: a function call is in tail position if its
value is the immediate result of the enclosing function, with no
further computation between the call returning and the function
returning. The recursive call to `sum_up_to` in
`n + sum_up_to (n - 1)` is *not* in tail position: after it
returns, we have to do an addition before we can return ourselves.
The recursive call in `sum_up_to (n - 1)` *would* be in tail
position, if we wrote a function that does nothing but recur.

:::slide

## A tail call is a recursive call with nothing left to do

- A call is **in tail position** if its result is the final result.
- Nothing happens after the call returns.

```ocaml
let rec f n = if n = 0 then 0 else f (n - 1)    (* tail call *)
let rec g n = if n = 0 then 0 else 1 + g (n - 1)  (* NOT tail call *)
```

- In `f`, the call's result is returned directly: no stack frame needed.
- In `g`, we still need `1 + ...` after; the frame must persist.

:::

The key question for any recursive call is: *is the recursive call
the very last thing this function does in this branch?* If yes, it
is in tail position. If after it returns we still need to add, or
multiply, or cons, or compare, or anything else, it is not. Note
that "the last expression in the source code" is not quite the same
as "in tail position." The position is about *the order in which
operations happen*, not where they appear on the page.

A useful mental test: replace the recursive call with a placeholder
(say, the literal `42`) and look at what would happen. In `f`, the
function returns `42` directly. The call is in tail position. In
`g`, the function would compute `1 + 42 = 43` and return that.
There is computation after the call. The call is not in tail
position.

## The optimisation

The compiler can recognise tail calls. When it does, it generates
code that *reuses* the current stack frame for the call, instead of
allocating a new one. The old frame's contents (parameters, return
address) are overwritten with the new call's contents; control
transfers to the callee without growing the stack.

:::slide

## OCaml optimizes tail calls

- Compiler **reuses** the current stack frame for a tail call.
- This is **tail-call optimization** (TCO).
- Tail-recursive functions use *constant* stack space.
- Enabled automatically; just write recursion in tail form.

:::

This optimisation, named in a [classic 1977 paper by Guy
Steele](https://dl.acm.org/doi/pdf/10.1145/800179.810196), is what
makes recursion in functional languages competitive with iteration.
Without it, every recursive call grows the stack; with it, a
tail-recursive function runs in constant stack space, the same as a
`for` loop.

The optimisation is enabled by the OCaml compiler automatically. You
do not pass a flag. You do not annotate the function. The compiler
inspects the structure of each recursive call and, if it sees that
the call is in tail position, emits the frame-reusing code. The
*programmer's* job is just to *write* the recursion in tail form;
the *compiler's* job is to recognise it and optimise.

## The accumulator pattern

The most common way to make a non-tail-recursive function
tail-recursive is the *accumulator pattern*. The idea: move the work
that was happening *after* the recursive call to happen *before*
it. To do that, you add an extra parameter (the accumulator) that
carries the partial result down through the recursion. When you hit
the base case, the accumulator holds the answer; just return it.

For `sum_up_to`, the work after the recursive call is "add `n`."
Instead, we will add `n` *to a running total* on the way down, and
the base case will return that running total directly.

```ocaml
let sum_up_to n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc + n) (n - 1)
  in
  go 0 n

let _ = sum_up_to 1_000_000  (* = 500000500000 *)
```

No stack overflow this time, even though the non-tail version
crashed on the very same input. The recursive call no longer
needs an enclosing frame, so each call reuses the caller's
instead of pushing a new one. A million iterations run without
growing the stack at all.

:::slide

## The accumulator pattern

- Move the work *before* the recursive call; carry a running total.

```ocaml
let sum_up_to n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc + n) (n - 1)
  in
  go 0 n

let _ = sum_up_to 1_000_000  (* = 500000500000 *)
```

- **No stack overflow**: same input crashed the non-tail version.
- Tail call: recursive call is the *final* expression.

:::

The structure has three parts worth naming:

- An outer function, `sum_up_to n`, with the original API. The caller
  does not know or care about the accumulator.
- An inner helper, `go`, with an extra parameter `acc` (idiomatic
  shorthand for "accumulator"). The helper does the real recursion.
- An initial call `go 0 n` that supplies the starting accumulator.
  For sums, that is `0`; for products (and powers) it would be
  `1`. In general, the initial accumulator is whatever the base
  case of the original function returned.

This is the standard shape, and we will use it constantly. We
will use it again in
[the local-and-mutual-recursion lecture](M03-L05-local-and-mutual.html)
(where the local-helper pattern gets its own treatment) and
throughout [Module 6](M06-L04-fold.html), where `List.fold_left`
packages exactly this pattern.

## Tracing through it

Walking through `sum_up_to 4`, which calls `go 0 4`:

:::slide

## Walking through it

`sum_up_to 4` calls `go 0 4`.

```
go 0 4  =>  go (0+4) 3  =>  go 4 3
go 4 3  =>  go (4+3) 2  =>  go 7 2
go 7 2  =>  go (7+2) 1  =>  go 9 1
go 9 1  =>  go (9+1) 0  =>  go 10 0
go 10 0 =>  10                          (base case hit)
```

- New accumulator computed *before* the recursive call.
- At `n = 0`, accumulator holds the full sum.
- Same loop a C program would write, without mutation.

:::

Each line in the trace is one tail call. Because each call is in
tail position, the previous frame is overwritten in place: there is
never more than one frame for `go` on the stack at a time. By the
time we hit `go 10 0`, the accumulator holds `4 + 3 + 2 + 1 = 10`,
and we return it.

The trace also makes clear that this is the same computation a
procedural language would do as a loop:

```c
int sum_up_to(int n) {
  int acc = 0;
  for (int i = n; i > 0; i--) acc += i;
  return acc;
}
```

The C version and the tail-recursive OCaml version compile to nearly
identical assembly: same register usage, same loop structure, same
number of instructions. You should think of tail recursion as "the
functional way to write a `for` loop." The shape is recursive; the
behaviour is iterative.

## Factorial, tail-recursive

The same rewrite works for `factorial`. The base case of the original
returned `1`; that is our initial accumulator. The work after the
recursive call was a multiplication by `n`; that becomes a
multiplication into the accumulator on the way down.

```ocaml
let factorial n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc * n) (n - 1)
  in
  go 1 n

let _ = factorial 10  (* = 3628800 *)
```

:::slide

## Factorial, tail-recursive

```ocaml
let factorial n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc * n) (n - 1)
  in
  go 1 n

let _ = factorial 10  (* = 3628800 *)
```

- Running product passed as `acc`; base returns `acc`.
- Caveat: `factorial 100` overflows OCaml's `int`.
- For arbitrary precision: `Zarith`.

:::

Same pattern, slightly different glue: the operator is `*` instead
of `+`, and the initial accumulator is `1` (the identity for
multiplication) instead of `0` (the identity for addition). Compare
the two tail-recursive versions side by side and you will see they
are almost the same function; only the operator differs. This will
become familiar by Module 6, where we generalise the pattern to
`List.fold_left`.

One caveat worth noting: `factorial 100` does not overflow the stack
(thanks to TCO), but it *does* overflow OCaml's `int`. The
mathematical result of `100!` is a 158-digit number, far beyond the
range of any 63-bit integer. Multiplications silently wrap around,
and you get a garbage value. For arbitrary-precision arithmetic, the
[Zarith](https://github.com/ocaml/Zarith) library gives you `Z.t`,
which can hold integers of any size. We do not need it in this
course; just know it exists.

Not every recursive function admits this rewrite cleanly. We will
see one such case (`map`) in
[the `List.map` lecture](M06-L02-map.html#tail-recursion-and-listmap),
once we have the right vocabulary to discuss the two-pass
workaround.

## A heuristic for spotting tail calls

The heuristic for whether a call is in tail position: *after the
call returns, is there any computation left in the function?* If
yes, not tail; if no, tail.

:::slide

## A heuristic for spotting tail calls

After the call returns, is there *any* computation left?

- Yes: **not** a tail call.
- No: tail call.

:::

:::slide

## Tail-call heuristic: three examples

```ocaml
let rec a n = if n = 0 then 0 else a (n - 1) + 1
let rec b n = if n = 0 then 0 else 1 + b (n - 1)
let rec c n = if n = 0 then 0 else if n > 100 then c (n - 100) else c (n - 1)
```

- `a`: not tail (adds `1` *after* the call).
- `b`: not tail (the `+` runs *after* the call returns).
- `c`: tail; both branches' recursive calls are final.

:::

Try the heuristic on each:

- `a n`: the recursive call is `a (n - 1)`, and after it we add `1`.
  Not tail.
- `b n`: the recursive call is `b (n - 1)`, evaluated *after* the
  `1`, but the addition is the outermost operation, performed *after*
  the call returns. Not tail. (Note that the textual position is
  misleading here; `1` appears first in source but the recursive call
  must return *before* the `+` can run.)
- `c n`: both branches end in a bare recursive call. The "work" is
  in the test (which happens *before* the call). Both calls are in
  tail position.

A subtle case: what about `if` expressions? In `if test then e1 else
e2`, the calls inside `e1` and `e2` are in tail position relative to
the whole `if` if and only if the `if` itself is in tail position.
So `if n = 0 then 0 else f (n - 1)` has `f (n - 1)` in tail position
(if the `if` is at the top of the function). Compare:
`(if n = 0 then 0 else f (n - 1)) + 1`: now neither branch is in
tail position, because there is an addition after the `if`.

## Activity

:::slide

## Activity

Recall `power` from
[the recursion lecture](M03-L02-recursion.html#worked-example-power):

```ocaml
let rec power x n =
  if n = 0 then 1
  else x * power x (n - 1)
```

Not tail-recursive (the `*` runs after the call). Rewrite it
with an accumulator so that it is.

:::

Before reading on, do the rewrite yourself. The shape is the
`factorial` one we did above: outer function with the original
signature, inner helper with an extra `acc` parameter, base case
returns `acc`.

:::solution

:::slide

## Activity solution

```ocaml
let power x n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc * x) (n - 1)
  in
  go 1 n
```

- Outer function keeps the `int -> int -> int` signature.
- Inner `go` carries an accumulator; `x` stays the same each call.
- Starting accumulator: `1` (what `power x 0` returned).
- Recursive case: fold `* x` into `acc` *before* recursing.

:::

:::

Three questions to ask when you turn an `O(n)`-stack function into
a tail-recursive one:

1. *What is the running result?* This is the value the function
   computes incrementally as it walks the input. Make it a new
   parameter, conventionally `acc`.
2. *What is its starting value?* Whatever the original function
   would have returned in the base case. For `sum_up_to`, that is
   `0`; for `factorial` and `power`, `1`; for `sum_of_squares`,
   `0`.
3. *What happens to it at each step?* Whatever the original
   function did *after* the recursive call. Apply it to `acc`
   *before* recursing, so the recursive call sits in tail position.

The first two answers go into the outer wrapper (call the helper
with the starting value); the third answer reshapes the recursive
case. The base case just returns `acc`.

By the end of Module 4 this rewrite will be muscle memory. By the
end of Module 6, you will rarely write it by hand, because
`List.fold_left` packages exactly this pattern.

## A small code challenge

:::quiz code id=M03-L04-q2
Write a tail-recursive `sum_of_squares : int -> int` that returns
`1*1 + 2*2 + ... + n*n` for non-negative `n`. `sum_of_squares 0 = 0`.

```ocaml
let sum_of_squares n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (sum_of_squares 0 = 0)    "zero";
  check (sum_of_squares 1 = 1)    "one";
  check (sum_of_squares 3 = 14)   "small: 1 + 4 + 9";
  check (sum_of_squares 5 = 55)   "five: 1 + 4 + 9 + 16 + 25";
  print_endline "all tests passed"
```
:::

:::solution

`let sum_of_squares n = let rec go acc n = if n = 0 then acc else
go (acc + n * n) (n - 1) in go 0 n`. Initial accumulator is `0`
(the identity for addition); per-step work adds `n * n` into the
accumulator before recursing.

:::

:::quiz mcq id=M03-L04-q1
Which of these recursive calls is in tail position?

```ocaml
let rec h n =
  if n = 0 then 0
  else if n mod 2 = 0 then h (n - 1) else 1 + h (n - 1)
```

- [ ] Both calls to `h (n - 1)`.
- [ ] Only the one in the odd branch, inside `1 + h (n - 1)`.
- [x] Only the one in the even branch (no `1 +` after).
- [ ] Neither.

**Why:** in the even branch, `h (n - 1)` is the result of the
function directly; the call sits in tail position. In the odd
branch, `1 + h (n - 1)`: the `+ 1` runs *after* the recursive call
returns, so the call is not in tail position. The function counts
the odd integers from `1` to `n`; the point of the question is the
*shape* of the two recursive calls, not what the function computes.
:::

## What's next

:::slide

## What's next

Lecture 5: **local functions and mutual recursion**.

- The `go`-inside-a-function pattern, made explicit.
- Functions that refer to each other.

:::

We have used the `let rec go ... in` pattern twice in this
lecture (in `sum_up_to` and `factorial`) without explaining what it
does. The next lecture,
[M03-L05](M03-L05-local-and-mutual.html), is about that pattern:
*local* function definitions, scoped to inside another function.
It also covers *mutual recursion*, two or more functions that call
each other, which uses a related piece of syntax.

## Reading

- **Cornell CS3110**, *Tail recursion*: the textbook treatment, with
  the same recipe and more worked examples:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
- Guy Steele, *Debunking the "expensive procedure call" myth, or,
  procedure call implementations considered harmful, or, LAMBDA:
  The Ultimate GOTO* (1977): the original tail-call optimisation
  paper.
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.

<!-- ===== source: old/M03-L05-local-and-mutual.md ===== -->
---
title: "Local functions and mutual recursion"
lecture_no: 5
week: 3
duration_target_min: 22
concepts: [local let-bindings of functions, helper functions, mutual recursion, `and` keyword]
keywords: [OCaml, local functions, mutual recursion, and, helper, let rec ... and]
activity_question: "Define [mod3_eq_0], [mod3_eq_1], [mod3_eq_2 : int -> bool] for non-negative [n], using mutual recursion with three functions tied by [and]. The only arithmetic allowed is subtracting 1 and comparing to 0. Why does this need three functions in the same [let rec ... and ... and ...] declaration?"
think_about_this: "When is a helper function better as a local [let ... in] inside another function vs. a top-level definition? What changes when you make it top-level?"
reading:
  - title: "Cornell CS3110, Helper functions"
    url: https://cs3110.github.io/textbook/chapters/basics/functions.html
---

# Local functions and mutual recursion


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Local functions and mutual recursion</h2>
<p class="title-slide-label">Module 3 &middot; Lecture 5</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

:::slide

## This lecture: local helpers and mutual recursion

- Two related topics, both ordinary features of day-to-day OCaml.
- *Local* function definitions: helpers inside another function with `let ... in`.
  - Scoped only to the outer function; keeps the top level clean.
- *Mutual recursion*: two or more functions that call each other.
  - Glued with the `and` keyword; one `let rec ... and ... and ...`.
- Neither topic is conceptually deep.
- The point is the *conventions*: when local vs. top-level, and what `and` is for.

:::

Two related topics in this lecture. The first is *local* function
definitions: helpers defined inside another function with
`let ... in`, scoped only to that outer function. The second is
*mutual recursion*: two or more functions that call each other,
glued together with the `and` keyword. Both are ordinary features
of day-to-day OCaml; you have already seen the first in passing
(every tail-recursive function in
[the tail-recursion lecture](M03-L04-tail-recursion.html#the-accumulator-pattern)
used a local helper), and the second turns up the moment you
write a parser, a tree walker, or the classic `is_even` /
`is_odd` example.

Neither topic is conceptually deep. The point of the lecture is to
give you the conventions: when to make a helper local vs.
top-level, and what the `and` keyword does and why it has to exist.

## Local helpers: definitions inside `let ... in`

We saw `let rec go ... in ...` in every tail-recursive rewrite in
[the tail-recursion lecture](M03-L04-tail-recursion.html#the-accumulator-pattern).
The keyword combination defines `go` only inside the body of the
outer function:

```ocaml
let factorial n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc * n) (n - 1)
  in
  go 1 n
```

The shape: an outer function `factorial` with the API you want
callers to see, an inner helper `go` doing the real work, and a
call `go 1 n` to start the recursion. The name `go` is *not* visible
outside `factorial`; you cannot call `go 1 5` from somewhere else
in the file.

:::slide

## Local helpers with `let ... in`

You've already seen this in tail-recursive rewrites:

```ocaml
let factorial n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc * n) (n - 1)
  in
  go 1 n
```

- `go` defined *inside* `factorial` with `let rec ... in`.
- In scope only for the rest of that expression.
- Right place for an implementation-detail helper.

:::

The encapsulation matters more than it might first appear. Once a
name is part of a file's top-level scope, anyone reading the file
sees it. It autocompletes. It shows up in error messages. It might
get exported in an `.mli` (interface file), to be discussed in
[Module 7](M07-L07-signatures.html). If the helper is genuinely an
implementation detail of one function, all of that is noise. Local
definitions keep the top-level surface clean.

The local helper pattern is core to readable OCaml. Any time you
have a function that needs an accumulator, or a different argument
order from what the caller expects, define the helper locally and
shape the outer function to be the API you want callers to see.
The caller sees `factorial : int -> int`; they never have to know
about `go` or about the starting accumulator `1`.

## Why not just top-level?

You can, of course, write the same thing with a top-level helper:

```ocaml
let rec factorial_go acc n =
  if n = 0 then acc
  else factorial_go (acc * n) (n - 1)

let factorial n = factorial_go 1 n
```

It works. The factorial function behaves exactly the same. But the
helper `factorial_go` is now a public name. Anyone reading the file
or using IDE autocomplete will see it. They might call
`factorial_go 0 5` and get `0` (because the accumulator starts at
zero, and `0 * anything` is zero). That is a wrong answer the
`factorial` API would have prevented.

:::slide

## Why not just top-level?

```ocaml
let rec factorial_go acc n =
  if n = 0 then acc
  else factorial_go (acc * n) (n - 1)

let factorial n = factorial_go 1 n
```

- This works.
- Downside: `factorial_go` is a public name.
- Callers could pass `factorial_go 0 5` and silently get `0`.
- A local `let rec ... in` hides the helper.
- Encapsulation: the default choice.

:::

This is the same argument as for `private` methods in object-oriented
languages, or `static` functions in C: by default, hide
implementation details. Expose only the API. In OCaml the
hiding-mechanism for functions inside another function is `let ...
in`; the hiding-mechanism for functions inside a module is the
[`.mli` file](M07-L07-signatures.html#signatures-in-mli-files).
Both exist for the same reason: smaller surface, fewer ways for
callers to misuse the code.

## When to make a helper top-level

The other end of the trade-off: sometimes the "helper" is genuinely
useful on its own. The classic pair is `gcd` and `lcm`: the
greatest common divisor stands on its own (number theory uses it
constantly), and the least common multiple is defined in terms of
it. You do not want `gcd` hidden inside `lcm`; you want it
top-level so anyone can reuse it.

```ocaml
let rec gcd m n =
  if n = 0 then m
  else gcd n (m mod n)

let lcm m n =
  m * n / gcd m n
```

:::slide

## When to make a helper top-level

Sometimes the "helper" is useful on its own:

```ocaml
let rec gcd m n =
  if n = 0 then m
  else gcd n (m mod n)

let lcm m n =
  m * n / gcd m n
```

- `gcd` stands on its own; `lcm` reuses it.
- Both top-level, both public.

Rule of thumb:

- Reusable name other callers might want: top-level.
- Tactical helper for one function: local.

:::

The rule of thumb:

- *Top-level* if the helper has a meaningful, reusable name that
  other callers might want. `gcd`, `factorial`, `power`. The
  function stands on its own.
- *Local* if the helper is a tactical aid for one outer function:
  an accumulator-passing version, an unfolded base case, a
  renamed-and-reordered variant. `go`, `aux`, `loop`. Nobody
  outside the outer function would want to call it.

You will get a feel for this with practice. The bias in idiomatic
OCaml is toward locals: if in doubt, hide it. You can always promote
a local helper to top-level if a second caller materialises. Going
the other way (making a top-level function local) is harder, because
you do not know who is already using it.

## A code check: hide the helper

:::quiz code id=M03-L05-q1
Write `bit_count : int -> int` that returns the number of `1`s
in the binary representation of a non-negative integer. Use a
**local** tail-recursive helper inside `bit_count`; the helper
must not be visible at the top level.

```ocaml
let bit_count n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (bit_count 0   = 0) "zero";
  check (bit_count 1   = 1) "one";
  check (bit_count 2   = 1) "two (binary 10)";
  check (bit_count 3   = 2) "three (binary 11)";
  check (bit_count 7   = 3) "seven (binary 111)";
  check (bit_count 10  = 2) "ten (binary 1010)";
  check (bit_count 255 = 8) "255 (binary 11111111)";
  print_endline "all tests passed"
```
:::

:::solution

`n mod 2` is the lowest bit; `n / 2` drops it. A local
tail-recursive helper threads the running count:

```text
let bit_count n =
  let rec go acc n =
    if n = 0 then acc
    else go (acc + (n mod 2)) (n / 2)
  in
  go 0 n
```

`go` is the standard local-helper-with-accumulator shape we saw
in [Tail recursion](M03-L04-tail-recursion.html). Hiding it
inside `bit_count` keeps the accumulator out of the top-level
namespace.

:::

## Mutual recursion: two functions calling each other

Sometimes the natural shape of a problem is not "one function calls
itself" but "two functions call each other." The classic, slightly
contrived example is parity by recursion:

```ocaml
let rec is_even n =
  if n = 0 then true
  else is_odd (n - 1)
and is_odd n =
  if n = 0 then false
  else is_even (n - 1)
```

`is_even 10` is `true`. `is_odd 10` is `false`. Each function calls
the other, not itself: `is_even`'s recursive case calls `is_odd`,
and vice versa. The recursion alternates between the two functions
until one of them hits the base case.

:::slide

## Mutual recursion

Two functions can call each other:

```ocaml
let rec is_even n =
  if n = 0 then true
  else is_odd (n - 1)
and is_odd n =
  if n = 0 then false
  else is_even (n - 1)

let _ = is_even 10  (* = true *)
let _ = is_odd 10   (* = false *)
```

- Each function calls the other.
- Tied together by `and`.
- Both names in scope simultaneously inside both bodies.

:::

The new piece of syntax is the `and` keyword joining the two
definitions. The combined declaration is one big `let rec`:
`let rec is_even ... and is_odd ...`. Both names are introduced
together, and both names are in scope inside *both* bodies. That is
exactly what mutual recursion needs.

## Why `and` has to exist

Suppose you tried to write the two functions as separate `let rec`s:

```text
let rec is_even n = if n = 0 then true  else is_odd  (n - 1)
let rec is_odd  n = if n = 0 then false else is_even (n - 1)
```

OCaml rejects the first line: `Unbound value is_odd`. The reason
is the same one we saw for `let rec` vs. plain `let` in
[the recursion lecture](M03-L02-recursion.html#why-let-rec-and-not-just-let):
a `let rec` brings the name being defined into scope inside its
own body, but not *other* names that have not been defined yet.
When the compiler processes the first `let rec is_even`, the name
`is_odd` does not exist yet, so the reference to `is_odd` in
`is_even`'s body fails.

:::slide

## Why `and`, not `let` twice?

```text
let rec is_even n = if n = 0 then true  else is_odd  (n - 1)
let rec is_odd  n = if n = 0 then false else is_even (n - 1)
```

- OCaml rejects the first line: `Unbound value is_odd`.
- When `let rec is_even` is processed, `is_odd` doesn't exist yet.
- `and` threads multiple definitions through one name-resolution step:

```text
let rec X = ... and Y = ... and Z = ...
```

- All names in scope inside each body.

:::

The `and` keyword joins multiple recursive definitions into a single
declaration. All the names introduced by the joined declaration are
visible inside *all* the bodies. There is no limit to how many
functions can be joined: `let rec f = ... and g = ... and h = ...
and ...`. Two is by far the most common; three or four show up in
parsers and tree walkers; more than that is unusual.

A subtle property worth noting: `and` does *not* mean "evaluate
sequentially." All the bodies are processed by the type checker
together, with all the names already in scope. There is no left-to-right
dependency. You can write the definitions in any order; the
compiler will figure out which calls which.

The two-function ping-pong is not as artificial as `is_even` /
`is_odd` suggests. The shape shows up the moment you write a
recursive-descent parser (each grammar rule is a function, the
rules call each other), a tree walker over a language with
expressions *and* statements (`eval_expr` calls `eval_stmt` and
vice versa), or any state machine with two or more states. We
will see those examples in
[Module 4](M04-L04-recursive-types.html) (recursive data types)
and [Module 5](M05-L01-basic-patterns.html) (pattern matching),
once we have the data shapes to support them.

## Mutual recursion can be local too

Just as a single recursive function can be local with `let rec ... in`,
a set of mutually recursive functions can be local with
`let rec ... and ... in`:

```ocaml
let demo () =
  let rec ping n =
    if n = 0 then "done"
    else pong (n - 1)
  and pong n = ping n
  in
  ping 5

let _ = demo ()  (* = "done" *)
```

:::slide

## Mutual recursion can also be local

```ocaml
let demo () =
  let rec ping n =
    if n = 0 then "done"
    else pong (n - 1)
  and pong n = ping n
  in
  ping 5

let _ = demo ()  (* = "done" *)
```

- `let rec ... and ...` works inside `let ... in` too.
- Both names local; neither leaks outside `demo`.

:::

The syntax is exactly the same: `let rec X = ... and Y = ... in
body`. Both `X` and `Y` are local to the surrounding expression.
Outside `demo ()`, neither `ping` nor `pong` exists.

For a single (not mutual) local recursive helper, the same `let
rec ... in` shape works without `and`. The Collatz sequence is a
classic small example: take a positive integer; halve it if even,
triple-and-add-one if odd; stop at 1. The conjecture is that the
sequence reaches 1 for every positive starting value. Unproven,
but a tidy demonstration of `let rec ... in`:

```ocaml
let collatz n =
  let rec step n =
    print_endline (string_of_int n);
    if n = 1 then ()
    else if n mod 2 = 0 then step (n / 2)
    else step (3 * n + 1)
  in
  step n
```

## A quick check

:::quiz mcq id=M03-L05-q2
What happens when the toplevel reaches the last line?

```ocaml skip
let outer x =
  let inner y = y + 1 in
  inner x

let _ = outer 4
let _ = inner 5
```

- [ ] Both lines return `5`.
- [ ] `outer 4` returns `5`; `inner 5` returns `6`.
- [x] `outer 4` returns `5`; the last line fails with `Unbound value inner`.
- [ ] Both lines fail with a type error.

**Why:** `inner` is introduced by a `let ... in` *inside*
`outer`'s body, so it is in scope only inside that body. Outside
`outer`, the name `inner` has never been bound, and the compiler
rejects the reference. Hiding a helper inside a top-level
function is exactly the point of the local-helper pattern.
:::

:::quiz mcq id=M03-L05-q3
The compiler rejects this code. Where, and why?

```ocaml skip
let rec is_even n =
  if n = 0 then true  else is_odd  (n - 1)
let rec is_odd n =
  if n = 0 then false else is_even (n - 1)
```

- [ ] At `is_odd`'s definition: the body refers to `is_even`, which has type `int -> bool`; the recursive case is fine.
- [x] At `is_even`'s definition: the body refers to `is_odd`, which is not yet in scope.
- [ ] At the call site: `is_even` and `is_odd` have different types.
- [ ] The code is accepted; both functions work.

**Why:** `let rec` brings *only the name being defined* into
scope inside its own body. When the compiler processes the first
`let rec is_even`, `is_odd` has not yet been introduced, so the
recursive case fails with `Unbound value is_odd`. The fix is one
combined `let rec ... and ...` so both names are introduced
together and in scope inside both bodies.
:::


## Activity: mod-3 by three-way mutual recursion

:::slide

## Activity

`and` is not limited to two definitions. Define `mod3_eq_0`,
`mod3_eq_1`, `mod3_eq_2 : int -> bool` for non-negative `n`,
using **only** "subtract 1, compare to 0" (no `mod`, no `if`-on-
arithmetic). The three functions must call each other:

```text
let rec mod3_eq_0 n = ???
and mod3_eq_1 n = ???
and mod3_eq_2 n = ???
```

:::

Try it before reading the solution. Each function's base case is
fixed by definition (`mod3_eq_0 0` is `true`; the other two are
`false` on `0`). The recursive case has to hand off in a cycle:
subtracting 1 from `n` shifts the residue by 1, so
`mod3_eq_0 n = mod3_eq_2 (n - 1)`, `mod3_eq_1 n = mod3_eq_0 (n -
1)`, `mod3_eq_2 n = mod3_eq_1 (n - 1)`. Three functions, three
bases, three tail calls in a cycle.

:::solution

:::slide

## Activity solution

```ocaml
let rec mod3_eq_0 n =
  if n = 0 then true
  else mod3_eq_2 (n - 1)
and mod3_eq_1 n =
  if n = 0 then false
  else mod3_eq_0 (n - 1)
and mod3_eq_2 n =
  if n = 0 then false
  else mod3_eq_1 (n - 1)

let _ = mod3_eq_0 9   (* = true:  9 mod 3 = 0 *)
let _ = mod3_eq_1 10  (* = true: 10 mod 3 = 1 *)
let _ = mod3_eq_2 11  (* = true: 11 mod 3 = 2 *)
```

- Three bodies, all in scope inside all bodies.
- Recursive calls hand off in a cycle: 0 to 2, 2 to 1, 1 to 0.
- All three calls are in tail position; TCO works across all of them.

:::

:::

To watch the hand-off happen, shadow the three definitions with
instrumented copies (a print at the top of each body) and run one
on a small argument:

```ocaml
let rec mod3_eq_0 n =
  print_endline ("mod3_eq_0 " ^ string_of_int n);
  if n = 0 then true else mod3_eq_2 (n - 1)
and mod3_eq_1 n =
  print_endline ("mod3_eq_1 " ^ string_of_int n);
  if n = 0 then false else mod3_eq_0 (n - 1)
and mod3_eq_2 n =
  print_endline ("mod3_eq_2 " ^ string_of_int n);
  if n = 0 then false else mod3_eq_1 (n - 1)

let _ = mod3_eq_0 4  (* = false: 4 mod 3 = 1 *)
```

The printed lines are the call sequence: `mod3_eq_0 4`,
`mod3_eq_2 3`, `mod3_eq_1 2`, `mod3_eq_0 1`, `mod3_eq_2 0`. Each
line is one hand-off around the 0 to 2 to 1 cycle, one subtraction
per step, until a base case answers.

One important property of this example: every recursive call is
in tail position. OCaml's tail-call optimisation handles tail
calls *between* mutually recursive functions, not just self-calls.
So `mod3_eq_0 1_000_000` runs in constant stack space. The function
cycles through three frames as it descends, but none of them ever
stays around; each recursive tail call reuses the current frame for
the next call.

In real code you would write `n mod 3 = 0`, of course. The
mutual-recursion version is here as a clean illustration of the
pattern: a cycle of bodies tied together by `and`, every name in
scope inside every body.

## What's next

:::slide

## What's next

Lecture 6: the **tutorial** for Module 3.

- Work through `fib`, a power-of-two test, fast `power`, and
  digit counting.
- Trade-offs: naive vs tail recursion.

:::

The next lecture, [M03-L06](M03-L06-tutorial.html), is the
tutorial for Module 3. We will work through several classic small
problems: Fibonacci (naive and linear-time), testing whether a
number is a power of two, fast integer power by
square-and-multiply, and digit counting. The
goal is to consolidate the techniques (recursion, accumulators,
local helpers) on problems you have probably seen in some form
before, and to discuss when each approach is the right choice.

## Reading

- **Cornell CS3110**, *Helper functions* and *Mutual recursion*:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>

## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.

<!-- ===== source: old/M03-L06-tutorial.md ===== -->
---
title: "Tutorial: Fibonacci, powers of two, fast power, digits"
lecture_no: 6
week: 3
duration_target_min: 28
concepts: [worked recursive examples, tail vs naive recursion, memoization preview]
keywords: [OCaml, tutorial, fibonacci, power of two, power, digits, recursion, tail recursion]
activity_question: "Write [sum_digits : int -> int] that returns the sum of the base-10 digits of a non-negative integer. [sum_digits 12345 = 15]. Same shape as [count_digits]; what changes in the recursive case?"
think_about_this: "When a function does not terminate on certain inputs (like negative arguments to factorial), should it crash, return a sentinel, or return an [option] / [result]? What does each choice cost the caller?"
reading:
  - title: "Cornell CS3110, Recursion examples"
    url: https://cs3110.github.io/textbook/chapters/basics/functions.html
---

# Tutorial for Module 3


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Tutorial: Fibonacci, powers of two, fast power, digits</h2>
<p class="title-slide-label">Module 3 &middot; Lecture 6</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

:::slide

## This lecture: the Module 3 tutorial

- Four small problems: Fibonacci, power-of-two test, fast power,
  digit counting.
- Goal: consolidate recursion, accumulators, local helpers.
- Recurring choice: *naive* vs *tail-recursive* form.
  - Rule of thumb: write the clear naive version first.
  - Convert with an accumulator when inputs get large.

:::

This tutorial works through four small problems: Fibonacci (naive
and linear-time), testing whether a number is a power of two,
fast integer power (by square-and-multiply), and digit-counting.
None are individually
hard; the point is to consolidate the techniques from Module 3
([recursion](M03-L02-recursion.html),
[tail calls and accumulators](M03-L04-tail-recursion.html),
[local helpers](M03-L05-local-and-mutual.html)) and to make
explicit the choice between *naive recursive* and *tail-recursive*
implementations.

The general rule of thumb: write the naive recursive form first.
It is almost always the clearest expression of the algorithm and
it is what you should reach for in a sketch or a small script. If
the function will be called on large inputs (long lists, large
numbers, in hot paths), convert to tail-recursive form using the
[accumulator pattern](M03-L04-tail-recursion.html#the-accumulator-pattern)
from the tail-recursion lecture. Most code never needs the
conversion; practitioners
get a feel for which functions are likely to be called on big data
and rewrite those preemptively.

## Problem 1: Fibonacci, naively

The Fibonacci numbers are defined by `F(0) = 0`, `F(1) = 1`, and
`F(n) = F(n-1) + F(n-2)` for `n >= 2`. The natural recursive
translation:

```ocaml
let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)

let _ = fib 20  (* = 6765 *)
```

:::slide

## Problem 1: Fibonacci, naively

```ocaml
let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)

let _ = fib 20  (* = 6765 *)
```

- Two recursive calls per step; call tree branches.
- Total calls: exponential in `n`.
- `fib 30`: slow. `fib 40`: slower. `fib 50`: impractical.

:::

The function is correct and the code reads exactly like the
mathematical definition.

The trouble is performance. Each call to `fib n` (for `n >= 2`)
makes *two* recursive calls. So the work to compute `fib n` is
proportional to the number of nodes in a binary call tree of depth
`n`, which is exponential. Specifically, the number of function
calls to compute `fib n` is roughly `phi^n` where `phi = 1.618...`
is the golden ratio. So `fib 30` does about a million calls (takes
under a second), `fib 40` does about 150 million calls (takes
several seconds), `fib 50` does about 20 billion calls (takes
minutes). The naive `fib` is unusable for any `n` past 40 or so.

## Why is naive Fibonacci so slow?

The cause is *overlapping subproblems*. When `fib 5` computes
`fib 4 + fib 3`, the call to `fib 4` itself computes
`fib 3 + fib 2`. So
`fib 3` is computed *twice* (once directly, once inside `fib 4`).
`fib 2` is computed three times, `fib 1` five times, `fib 0` three
times. The deeper the recursion, the more redundant work.

The fix is to compute each value only once and feed it forward. The
cleanest way in a pure-functional style is to carry the last *two*
values as an accumulator pair and update them as you go:

```ocaml
let fib n =
  let rec go a b k =
    if k = n then a
    else go b (a + b) (k + 1)
  in
  go 0 1 0

let _ = fib 46  (* = 1836311903 *)
```

:::slide

## Why is naive Fibonacci so slow?

- `fib 4` recomputes the `fib 3` that `fib 5` already needed.
- Overlapping sub-problems blow up the work.
- Faster: carry a pair `(a, b) = (fib (k-2), fib (k-1))`:

```ocaml
let fib n =
  let rec go a b k =
    if k = n then a
    else go b (a + b) (k + 1)
  in
  go 0 1 0

let _ = fib 46  (* = 1836311903 *)
```

- Linear in `n`; one recursive call per step.

:::

`fib 46` now returns `1836311903` immediately. (We use 46 rather
than 50 because the in-browser `int` is 32-bit and `fib 47`
already overflows it; `fib 46` is the largest Fibonacci that fits.
On a native 64-bit OCaml, `fib 50 = 12_586_269_025` fits fine.)
The trick: the
accumulator holds *two* values rather than one. At each step, `a`
is `fib k` and `b` is `fib (k+1)`. The recursive call advances both:
the new `a` is `b` (the previous `fib (k+1)`), the new `b` is `a +
b` (the next Fibonacci number, by the recurrence).

The two-accumulator trick is the canonical way to make Fibonacci
fast. It works for any recurrence that depends on the last *k*
values: keep a window of those values as the accumulator. Many
common sequences (Lucas numbers, Padovan numbers, etc.) yield to
the same shape. The general technique of caching intermediate
results is called *memoisation*; we will see it more thoroughly
when we get to mutable state in
[Module 7](M07-L01-references.html).

This `fib` is also tail-recursive (the recursive `go` call is the
last thing in the else-branch), so it runs in constant stack space.
You can call `fib 1_000_000` without blowing the stack, although the
result is a number with hundreds of thousands of digits and would
overflow OCaml's native `int` long before that.

## Problem 2: is it a power of two?

A positive integer is a power of two (`1`, `2`, `4`, `8`, ...)
exactly when repeatedly halving it lands on `1` without ever
passing through an odd number bigger than `1`. The recursion: `1`
is a power of two (`2^0`); an even number is a power of two iff
its half is; everything else (zero, negatives, odd numbers above
`1`) is not.

```ocaml
let rec is_power_of_two n =
  if n = 1 then true
  else if n <= 0 || n mod 2 = 1 then false
  else is_power_of_two (n / 2)

let _ = is_power_of_two 64  (* = true *)
let _ = is_power_of_two 96  (* = false *)
```

:::slide

## Problem 2: is it a power of two?

```ocaml
let rec is_power_of_two n =
  if n = 1 then true
  else if n <= 0 || n mod 2 = 1 then false
  else is_power_of_two (n / 2)

let _ = is_power_of_two 64  (* = true *)
let _ = is_power_of_two 96  (* = false *)
```

- Base cases first: `1` succeeds; zero, negatives, odds fail.
- Recursive case: halve and ask again.
- Termination: `n / 2 < n` for `n >= 2`; strictly decreasing.
- Already tail-recursive.

:::

Trace the two calls: `is_power_of_two 64` -> `32` -> `16` -> `8`
-> `4` -> `2` -> `1` -> `true`; `is_power_of_two 96` -> `48` ->
`24` -> `12` -> `6` -> `3`, and `3` is odd -> `false`.

Three things to notice. First, the function is already
tail-recursive without any rewriting. The recursive call is the
final expression of its branch; there is no work after it. No
accumulator is needed because the answer needs no combining on
the way back up; the base case *is* the answer.

Second, termination: `n / 2 < n` whenever `n >= 2`, and the only
inputs that reach the recursive call satisfy `n >= 2` (the two
base tests have already filtered out everything below `2` and the
odds). The argument strictly decreases toward the base cases, and
the recursion is at most `log2 n` deep.

Third, the *order* of the tests matters. `1` is odd, so if the
`n mod 2 = 1` test ran first, the function would return `false`
on `1`; and since every successful chain of halvings bottoms out
at `1`, it would then return `false` on every input. When base
cases overlap with a catch-the-rest test, the base cases must
come first.

## Problem 3: fast integer power

The naive `power` we wrote in the recursion lecture takes `n`
recursive calls to compute `x^n`:

```ocaml
let rec power x n =
  if n = 0 then 1
  else x * power x (n - 1)
```

For `n = 1_000_000`, that is a million calls. We can do much
better by *halving* the exponent at each step instead of
decrementing. Two cases on the parity of `n`:

- `n` even: `x^n = (x^(n/2))^2`. One recursive call.
- `n` odd: `x^n = x * x^(n-1)`. One recursive call, but the new
  exponent `n - 1` is even.

```ocaml
let rec fast_power x n =
  if n = 0 then 1
  else if n mod 2 = 0 then
    let half = fast_power x (n / 2) in
    half * half
  else x * fast_power x (n - 1)

let _ = fast_power 2 30  (* = 1073741824 *)
```

:::slide

## Problem 3: fast integer power

```ocaml
let rec fast_power x n =
  if n = 0 then 1
  else if n mod 2 = 0 then
    let half = fast_power x (n / 2) in
    half * half
  else x * fast_power x (n - 1)

let _ = fast_power 2 30  (* = 1073741824 *)
```

- Even `n`: one squaring of `x^(n/2)`.
- Odd `n`: multiply by `x`, then the new exponent is even.
- Calls: about `2 * log2(n)` (`~10` for `n = 30`, vs `30` for naive).

:::

The recursion depth is *logarithmic* in `n`, not linear. For `n = 1_000_000`, the naive `power` makes a million
recursive calls; `fast_power` makes about forty. The transformation
is purely algorithmic: same answer, far fewer calls. The trick
("decompose by parity") is the same one that underlies fast matrix
exponentiation, modular exponentiation in cryptography, and many
related algorithms.

A nuance worth flagging: `fast_power` is *not* tail-recursive. The
even case has `half * half` running *after* the recursive call, and
the odd case has `x *` running after. The accumulator pattern
from the tail-recursion lecture does not unfold cleanly here: the
running result depends
on values you do not know yet. For typical exponents (`n` up to a
few thousand), the logarithmic depth is comfortably small (under
20 frames for `n` up to a million), so non-tail recursion is fine.

## When naive recursion is fine

A pragmatic note: not every recursive function needs to be
tail-recursive. If the input is bounded (you know `n` is at most a
few thousand, or the list has at most a few hundred elements), the
naive recursive form runs in plenty of stack and reads cleaner. The
extra clarity of `let rec sum xs = match xs with | [] -> 0 | x ::
rest -> x + sum rest` over the accumulator form is real, and worth
the constant-factor stack use when stack use is not a problem.

Tail recursion matters when:

- The input might be very large: lists with millions of elements,
  numeric arguments in the millions, recursion that walks deep
  trees.
- The function is called frequently and you want it cheap on any
  input.
- You are writing library code others will call with unknown-sized
  inputs.

For one-off computations on small data, write the natural recursive
form and move on. You can rewrite to tail-recursive later if a
profiler or a stack overflow tells you to.

## Problem 4: counting digits

The number of digits in a non-negative integer is the number of
times you can divide it by 10 before reaching zero. The natural
recursion:

```ocaml
let rec count_digits n =
  if n < 10 then 1
  else 1 + count_digits (n / 10)

let _ = count_digits 12345  (* = 5 *)
```

:::slide

## Problem 4: counting digits

```ocaml
let rec count_digits n =
  if n < 10 then 1
  else 1 + count_digits (n / 10)

let _ = count_digits 12345  (* = 5 *)
```

- Strips one digit at a time; base case is single-digit.
- Each step: `n / 10` shifts right by one place.

:::

:::slide

## `count_digits`: negative inputs misbehave

```ocaml
let _ = count_digits (-12345)  (* = 1, wrong! *)
```

- Wrong: `(-12345)` has five digits, not one.
- `n < 10` is true for *all* negatives.
- The recursion stops at the very first call.

:::

:::slide

## `count_digits`: fix with a wrapper

```ocaml
let count_digits n =
  let rec go n =
    if n < 10 then 1
    else 1 + go (n / 10)
  in
  go (abs n)

let _ = count_digits (-12345)  (* = 5 *)
```

- Outer wrapper strips the sign with `abs`.
- Local `go` only ever sees `n >= 0`; the base case behaves.

:::

The recursion strips one digit per step. The base case
is "a single-digit number" (`n < 10`), which catches both `0`
through `9` and recursive calls when the remaining `n` is below 10.

A subtle bug: negative inputs do not terminate cleanly. OCaml's `/`
truncates toward zero, so `(-12345) / 10` is `-1234` (not `-1235`).
The base test `n < 10` is true for all negatives, so the recursion
returns immediately with `1`, which is wrong. Even worse, with a
different base test like `n = 0`, you would get an infinite
recursion. The defensive version uses `abs`:

```ocaml
let count_digits n =
  let rec go n =
    if n < 10 then 1
    else 1 + go (n / 10)
  in
  go (abs n)
```

This strips the sign at the outermost call; the helper `go` only
ever sees non-negative inputs. The pattern (a defensive outer
function plus a local helper that handles only the well-behaved
case) is one we will see again. The helper is local because nobody
outside `count_digits` needs it; the outer function is the API.

Note that `count_digits 0` returns `1`, which matches the convention
that the integer `0` has one digit (the digit `0`). If you wanted a
different convention you would adjust the base case.

## A quick check

:::quiz mcq id=M03-L06-q2
In `is_power_of_two`, why must the `n = 1` test come *before*
the `n mod 2 = 1` test?

- [ ] It makes the function tail-recursive.
- [x] `1` is odd; tested the other way round, the function would return `false` for `1`.
- [ ] `n = 1` is cheaper to evaluate than `n mod 2 = 1`.
- [ ] No reason; the two tests can be swapped freely.

**Why:** `1 = 2^0` is a power of two, but `1` is also odd. If
the oddness test ran first, the function would return `false` on
`1`, and since every successful chain of halvings bottoms out at
`1`, it would return `false` on *every* input. When a base case
overlaps with a catch-the-rest test, the base case must be
checked first. Tail-recursion is unaffected by the test order.
:::

:::quiz mcq id=M03-L06-q3
What does `fast_power 2 10` evaluate to?

```ocaml
let rec fast_power x n =
  if n = 0 then 1
  else if n mod 2 = 0 then
    let half = fast_power x (n / 2) in
    half * half
  else x * fast_power x (n - 1)
```

- [ ] `20`
- [ ] `100`
- [x] `1024`
- [ ] `2048`

**Why:** `fast_power 2 10` computes `2^10`. The recursion
halves the exponent on each even step: `2^10 = (2^5)^2`, `2^5
= 2 * 2^4`, `2^4 = (2^2)^2`, `2^2 = (2^1)^2`, `2^1 = 2 * 2^0
= 2`. Folding back up: `2^2 = 4`, `2^4 = 16`, `2^5 = 32`, `2^10
= 32 * 32 = 1024`. About `2 * log2(10)` recursive calls, not
ten.
:::

## Activity: sum of digits

:::slide

## Activity

Write `sum_digits : int -> int` that returns the sum of the
base-10 digits of a non-negative integer. Examples:

- `sum_digits 0 = 0`.
- `sum_digits 9 = 9`.
- `sum_digits 12345 = 15`.

Same shape as `count_digits` above, with the per-step contribution
changed.

:::

Try this before reading the solution. The shape mirrors
`count_digits`: strip one digit per step. The base case is `n =
0`: an empty number has digit sum `0`. The recursive case takes
the last digit (`n mod 10`) and adds it to the digit sum of the
rest (`n / 10`).

:::solution

:::slide

## Activity solution

```ocaml
let rec sum_digits n =
  if n = 0 then 0
  else (n mod 10) + sum_digits (n / 10)

let _ = sum_digits 12345  (* = 15 *)
```

- Base case `n = 0`: empty number, digit sum `0`.
- Recursive case: last digit + digit sum of the rest.
- Same shape as `count_digits`; different per-step contribution.

:::

:::

The recursion uses two integer operations students have already
seen: `n mod 10` peels off the last digit, `n / 10` shifts the
number one place right. After enough steps `n` reaches `0` and the
recursion ends. As with `count_digits`, the function misbehaves on
negative inputs because of OCaml's truncate-toward-zero division;
wrap with `abs` if you want the convention `sum_digits (-12) =
3`.

## A small code challenge

:::quiz code id=M03-L06-q1
Write `is_prime : int -> bool` by trial division. Returns `true`
if `n` is prime, `false` otherwise. Edge cases: `is_prime 0` and
`is_prime 1` are `false`; `is_prime 2` is `true`. Use a *local*
helper that tries divisors `k = 2, 3, 4, ...` and stops at
`k * k > n` (no need to look past the square root).

```ocaml
let is_prime n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (is_prime 0   = false) "0";
  check (is_prime 1   = false) "1";
  check (is_prime 2   = true)  "2";
  check (is_prime 9   = false) "9 = 3*3";
  check (is_prime 17  = true)  "17";
  check (is_prime 100 = false) "100 = 4*25";
  check (is_prime 101 = true)  "101";
  print_endline "all tests passed"
```
:::

:::solution

Outer function handles the `n < 2` edge case and calls a local
`try_divisor` helper that walks `k = 2, 3, 4, ...` upward,
returning `true` if no divisor was found by the time `k * k > n`:

```text
let is_prime n =
  if n < 2 then false
  else
    let rec try_divisor k =
      if k * k > n then true
      else if n mod k = 0 then false
      else try_divisor (k + 1)
    in
    try_divisor 2
```

`try_divisor` is tail-recursive (the recursive call is the final
expression of its branch). The outer wrapper hides the helper from
callers; the API is just `is_prime : int -> bool`. The
square-root cap halves the work compared to trying all `k < n`.

:::

## What you should be able to do now

:::slide

## What you should be able to do now

After Module 3 you can:

- Define functions, including anonymous functions with `fun`.
- Use partial application (`add 5`).
- Write recursive functions with base and recursive cases.
- Convert to tail-recursive with an accumulator.
- Use local helpers and mutual recursion.

Module 4: **data types** (tuples, records, variants, recursive).

:::

By the end of Module 3 you can:

- Define a function with `let`, anonymous-function form `fun x ->
  ...`, or the curried multi-argument form `let f x y z = ...`.
- Read function types: `int -> int -> int` is right-associative,
  meaning `int -> (int -> int)`. A multi-argument function is
  really a function of one argument returning a function.
- Partially apply a curried function: `add 5` is a function value.
- Write recursive functions with `let rec`, in their natural
  inductive form (base case plus recursive case that reduces
  toward it).
- Convert a non-tail-recursive function to tail-recursive using an
  accumulator parameter.
- Use local helpers via `let rec go ... in ...` and write mutually
  recursive functions with `let rec ... and ... = ...`.

[Module 4](M04-L01-tuples.html) turns to *data types*: tuples,
records, and variants (the algebraic data types that distinguish
ML-family languages from mainstream OOP). Pattern matching, which
we have previewed all through Module 3, takes centre stage in
[Module 5](M05-L01-basic-patterns.html).

## Reading

- **Cornell CS3110**, *Recursion examples*: the textbook's worked
  examples, with more variations on the patterns above:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
- **Real World OCaml**, *Lists and Patterns*: the corresponding
  chapter, with a heavy emphasis on the list-recursion idioms:
  <https://dev.realworldocaml.org/lists-and-patterns.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.

<!-- ===== source: old/M03-L07-practice.md ===== -->
---
title: "Practice: recursion, currying, and tail recursion"
lecture_no: 7
week: 3
duration_target_min: 0
concepts: [practice problems, recursion, tail recursion, accumulators, mutual recursion, currying]
keywords: [OCaml, practice, assignment, recursion, accumulator, tail-recursion, mutual recursion, currying]
think_about_this: "Every problem here is a number (or a string) going in and a number (or string) coming out: no lists, no data structures, just recursion and if-expressions. When a problem has you carry a running answer in an extra parameter, ask yourself: what is the starting value, and what does one step do to it?"
reading:
  - title: "Cornell CS3110, Functions and recursion"
    url: https://cs3110.github.io/textbook/chapters/basics/functions.html
---

# Practice: recursion, currying, and tail recursion

This is a *Practice* chapter, not a Tutorial. There are no slides
and there is no video; it is a worksheet. The
[tutorial](M03-L06-tutorial.html) walked through worked examples on
screen. Here you solve the problems yourself, directly in the
browser. Each problem has an editable cell seeded with
`failwith "not implemented"` and a test cell that prints
`all tests passed` when your solution is correct. A reference
solution sits below each problem behind a collapsed *Reference
solution* panel: try the problem first, then reveal the solution to
compare.

Everything here uses only what the module has covered: functions,
recursion, currying and partial application, tail recursion with
accumulators, mutual recursion, and `if`-expressions. There are no
lists, no tuples, no records, and no pattern matching: those come
later. If you find yourself reaching for `match`, rewrite it with
`if ... then ... else`.

The worksheet comes in three parts:

- **Part 1: numbers in, numbers out** (Problems 1 to 5). Short
  warm-ups on recursion over integers and strings.
- **Part 2: divisors, counting, and search** (Problems 6 to 9).
  Recursion that scans a range while carrying a running answer.
- **Part 3: recursion patterns** (Problems 10 to 12). A
  value-returning loop, a pair of mutually recursive functions, and
  a higher-order function.

Difficulty rises roughly as you go, but not strictly; if you get
stuck on one, skip ahead and come back.

## Part 1: numbers in, numbers out

## Problem 1: `repeat_string`

Write a function

```text
repeat_string : string -> int -> string
```

so that `repeat_string s n` is `s` concatenated with itself `n`
times. If `n <= 0`, return the empty string. For example,

```text
repeat_string "ab" 3 = "ababab"
```

:::quiz code id=M03-L07-q1
Implement `repeat_string` so the tests below pass.

```ocaml
let rec repeat_string s n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (repeat_string "ab" 3 = "ababab") "ab three times";
  check (repeat_string "x" 0 = "") "n = 0";
  check (repeat_string "hi" (-2) = "") "negative n";
  check (repeat_string "-" 5 = "-----") "five dashes";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rec repeat_string s n =
  if n <= 0 then ""
  else s ^ repeat_string s (n - 1)
```

The base case is `n <= 0` (note `<=`, not `=`, so a negative count
is handled too). Each step glues one copy of `s` onto the front of
the result of repeating it `n - 1` more times.

:::

## Problem 2: `multiply`

Write a function

```text
multiply : int -> int -> int
```

that returns the product `a * b` **without using `*`**: build it up
by repeated addition and recursion. It should work when `b` is
negative too. For example, `multiply 6 7 = 42` and
`multiply 4 (-3) = -12`.

:::quiz code id=M03-L07-q2
Implement `multiply` using only `+`, `-`, and recursion.

```ocaml
let multiply a b =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (multiply 6 7 = 42) "six sevens";
  check (multiply 0 5 = 0) "zero times";
  check (multiply 4 (-3) = -12) "negative b";
  check (multiply 9 1 = 9) "times one";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let multiply a b =
  let rec go acc n =
    if n = 0 then acc
    else go (acc + a) (n - 1)
  in
  if b >= 0 then go 0 b
  else - (go 0 (- b))
```

The local helper `go` adds `a` to an accumulator `b` times,
counting `n` down to zero: this is the accumulator pattern from the
tail-recursion lecture. The wrapper handles a negative `b` by
multiplying by its absolute value and negating the result.

:::

## Problem 3: `reverse_int`

Write a function

```text
reverse_int : int -> int
```

that reverses the decimal digits of a non-negative integer. For
example, `reverse_int 1230 = 321` (a leading zero in the reversed
number simply disappears). `reverse_int 0 = 0`.

:::quiz code id=M03-L07-q3
Implement `reverse_int`.

```ocaml
let reverse_int n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (reverse_int 1230 = 321) "1230 reversed";
  check (reverse_int 0 = 0) "zero";
  check (reverse_int 7 = 7) "single digit";
  check (reverse_int 100 = 1) "trailing zeros vanish";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let reverse_int n =
  let rec go acc m =
    if m = 0 then acc
    else go (acc * 10 + m mod 10) (m / 10)
  in
  go 0 n
```

`m mod 10` peels off the last digit; `m / 10` drops it. Each step
shifts the accumulator left one decimal place (`acc * 10`) and adds
the peeled digit, so the digits come out in reverse order. When `m`
reaches `0` the accumulator holds the answer.

:::

## Problem 4: `is_palindrome_int`

Write a function

```text
is_palindrome_int : int -> bool
```

that returns `true` when a non-negative integer reads the same
forwards and backwards, and `false` otherwise. For example,
`is_palindrome_int 12321 = true` and `is_palindrome_int 1230 =
false`.

:::quiz code id=M03-L07-q4
Implement `is_palindrome_int`.

```ocaml
let is_palindrome_int n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (is_palindrome_int 12321 = true) "odd-length palindrome";
  check (is_palindrome_int 1230 = false) "not a palindrome";
  check (is_palindrome_int 0 = true) "zero";
  check (is_palindrome_int 4 = true) "single digit";
  check (is_palindrome_int 1221 = true) "even-length palindrome";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let is_palindrome_int n =
  let rec rev acc m =
    if m = 0 then acc
    else rev (acc * 10 + m mod 10) (m / 10)
  in
  n = rev 0 n
```

Reverse the digits with the same accumulator trick as the previous
problem, then compare the reversed number to the original. A number
is a palindrome exactly when reversing it leaves it unchanged.

:::

## Problem 5: `digital_root`

The *digital root* of a non-negative integer is what you get by
summing its digits, then summing the digits of that, and so on,
until a single digit remains. Write

```text
digital_root : int -> int
```

so that, for example, `digital_root 12345 = 6` (because
`1+2+3+4+5 = 15`, then `1+5 = 6`).

:::quiz code id=M03-L07-q5
Implement `digital_root`.

```ocaml
let rec digital_root n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (digital_root 0 = 0) "zero";
  check (digital_root 7 = 7) "already single digit";
  check (digital_root 12345 = 6) "12345";
  check (digital_root 99999 = 9) "99999";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rec digital_root n =
  if n < 10 then n
  else
    let rec sum m =
      if m = 0 then 0
      else (m mod 10) + sum (m / 10)
    in
    digital_root (sum n)
```

When `n` is already a single digit (`n < 10`) it *is* its own
digital root. Otherwise sum the digits with the local helper `sum`,
then take the digital root of that smaller number. The outer
recursion is on the *result* of summing, not on `n` directly, which
is why it terminates: each digit-sum of a number with two or more
digits is strictly smaller.

:::

## Part 2: divisors, counting, and search

## Problem 6: `count_divisors`

Write a function

```text
count_divisors : int -> int
```

that returns how many positive integers divide `n` exactly (for
`n >= 1`). For example, `count_divisors 12 = 6` (the divisors are
1, 2, 3, 4, 6, 12) and `count_divisors 13 = 2` (1 and 13).

:::quiz code id=M03-L07-q6
Implement `count_divisors`.

```ocaml
let count_divisors n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (count_divisors 1 = 1) "one";
  check (count_divisors 12 = 6) "twelve";
  check (count_divisors 13 = 2) "prime";
  check (count_divisors 36 = 9) "thirty-six";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let count_divisors n =
  let rec go d acc =
    if d > n then acc
    else go (d + 1) (if n mod d = 0 then acc + 1 else acc)
  in
  go 1 0
```

Walk `d` from `1` up to `n`, carrying a count in the accumulator
`acc`. Each step bumps the count when `d` divides `n` evenly
(`n mod d = 0`). The recursive call is in tail position, so this
runs in constant stack space.

:::

## Problem 7: `is_perfect`

A *perfect number* equals the sum of its proper divisors (its
divisors excluding itself). Write

```text
is_perfect : int -> bool
```

that returns `true` exactly when `n` is perfect. For example,
`is_perfect 6 = true` (because `1 + 2 + 3 = 6`) and
`is_perfect 28 = true`, while `is_perfect 12 = false`.

:::quiz code id=M03-L07-q7
Implement `is_perfect`.

```ocaml
let is_perfect n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (is_perfect 6 = true) "six";
  check (is_perfect 28 = true) "twenty-eight";
  check (is_perfect 12 = false) "twelve";
  check (is_perfect 1 = false) "one";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let is_perfect n =
  let rec sum d acc =
    if d >= n then acc
    else sum (d + 1) (if n mod d = 0 then acc + d else acc)
  in
  n > 0 && sum 1 0 = n
```

Sum the proper divisors by walking `d` from `1` up to but not
including `n` (the condition `d >= n` stops before `n` itself),
adding `d` to the accumulator whenever it divides `n`. Then `n` is
perfect when that sum equals `n`. The `n > 0 &&` guard keeps the
answer sensible for `n = 1` (whose only proper divisor sum is `0`).

:::

## Problem 8: `choose`

The binomial coefficient "`n` choose `k`" counts the ways to pick
`k` items from `n`. It satisfies Pascal's rule: `choose n k =
choose (n-1) (k-1) + choose (n-1) k`, with `choose n 0 = 1` and
`choose n n = 1`. Write

```text
choose : int -> int -> int
```

returning `0` when `k < 0` or `k > n`. For example,
`choose 5 2 = 10`.

:::quiz code id=M03-L07-q8
Implement `choose` directly from Pascal's rule.

```ocaml
let rec choose n k =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (choose 5 2 = 10) "5 choose 2";
  check (choose 6 0 = 1) "k = 0";
  check (choose 6 6 = 1) "k = n";
  check (choose 10 3 = 120) "10 choose 3";
  check (choose 4 5 = 0) "k > n";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rec choose n k =
  if k < 0 || k > n then 0
  else if k = 0 || k = n then 1
  else choose (n - 1) (k - 1) + choose (n - 1) k
```

The out-of-range case comes first so the other branches can assume
`0 <= k <= n`. The two unit base cases (`k = 0` and `k = n`) stop
the recursion; otherwise we apply Pascal's rule directly. This makes
two recursive calls per step (it is not tail-recursive), which is
fine for the small inputs here.

:::

## Problem 9: `int_sqrt`

Write a function

```text
int_sqrt : int -> int
```

that returns the *integer square root* of `n >= 0`: the largest `i`
with `i * i <= n`. For example, `int_sqrt 10 = 3` (since `3*3 = 9`
but `4*4 = 16`) and `int_sqrt 16 = 4`. Do not use any floating-point
or library square-root function; search with recursion.

:::quiz code id=M03-L07-q9
Implement `int_sqrt`.

```ocaml
let int_sqrt n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (int_sqrt 0 = 0) "zero";
  check (int_sqrt 10 = 3) "ten";
  check (int_sqrt 16 = 4) "perfect square";
  check (int_sqrt 1 = 1) "one";
  check (int_sqrt 1000000 = 1000) "one million";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let int_sqrt n =
  let rec go i =
    if i * i > n then i - 1
    else go (i + 1)
  in
  if n < 0 then 0 else go 0
```

Count `i` upward from `0`; the first `i` whose square exceeds `n`
has overshot, so the answer is the previous one, `i - 1`. The
recursive call is in tail position. (A binary search would be far
faster, but the linear scan keeps the recursion simple.)

:::

## Part 3: recursion patterns

## Problem 10: `trailing_zeros`

Write a function

```text
trailing_zeros : int -> int
```

that returns how many times `2` divides `n` evenly, for `n >= 1`:
equivalently, the number of trailing zeros in `n`'s binary form. For
example, `trailing_zeros 40 = 3` (since `40 = 8 * 5` and `8 = 2^3`),
and `trailing_zeros 7 = 0`.

:::quiz code id=M03-L07-q10
Implement `trailing_zeros`. Halve `n` while it stays even, counting
the halvings in an accumulator.

```ocaml
let trailing_zeros n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (trailing_zeros 1 = 0) "odd: one";
  check (trailing_zeros 12 = 2) "twelve";
  check (trailing_zeros 8 = 3) "power of two";
  check (trailing_zeros 40 = 3) "forty";
  check (trailing_zeros 7 = 0) "odd: seven";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let trailing_zeros n =
  let rec go n acc =
    if n mod 2 = 1 then acc
    else go (n / 2) (acc + 1)
  in
  go n 0
```

Keep halving while `n` is even, adding one to the accumulator each
time, and stop the moment `n` is odd, when no factors of two remain.
The recursive call is in tail position, so this is a constant-space
loop. For an already-odd `n` (such as `1` or `7`) the loop stops
immediately and the answer is `0`.

:::

## Problem 11: `female` and `male` (Hofstadter sequences)

Hofstadter's *Female* and *Male* sequences are defined together,
each in terms of the other:

```text
female 0 = 1                       male 0 = 0
female n = n - male (female (n-1))  male n = n - female (male (n-1))
```

Write both as a single mutually recursive declaration
(`let rec female n = ... and male n = ...`), each of type
`int -> int`. For example, `female 5 = 3` and `male 5 = 3`.

:::quiz code id=M03-L07-q11
Implement `female` and `male` with one `let rec ... and ...`.

```ocaml
let rec female n =
  failwith "not implemented"
and male n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (female 0 = 1 && male 0 = 0) "base cases";
  check (female 5 = 3) "female 5";
  check (male 5 = 3) "male 5";
  check (female 10 = 6 && male 10 = 6) "n = 10";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rec female n =
  if n = 0 then 1
  else n - male (female (n - 1))
and male n =
  if n = 0 then 0
  else n - female (male (n - 1))
```

Each function calls the other, so they must be tied together by
`and` in one `let rec`: neither would type-check if defined alone,
because the name of the other would be unbound. The base cases
(`female 0 = 1`, `male 0 = 0`) differ, which is what makes the two
sequences diverge.

:::

## Problem 12: `fixpoint`

Write a higher-order function

```text
fixpoint : (int -> int) -> int -> int
```

that applies `f` to `x`, then to the result, and so on, stopping as
soon as applying `f` no longer changes the value, and returning that
value. For example, `fixpoint (fun n -> n / 2) 100 = 0` (halving
repeatedly bottoms out at `0`, and `0 / 2 = 0`).

:::quiz code id=M03-L07-q12
Implement `fixpoint`.

```ocaml
let rec fixpoint f x =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (fixpoint (fun n -> n / 2) 100 = 0) "halving";
  check (fixpoint (fun n -> if n > 0 then n - 1 else n) 5 = 0) "count down";
  check (fixpoint (fun n -> n) 42 = 42) "already fixed";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let rec fixpoint f x =
  let y = f x in
  if y = x then x else fixpoint f y
```

Compute the next value `y = f x`. If it equals the current `x`, we
have reached a fixed point and return it; otherwise recurse on `y`.
Because `f` is a parameter, `fixpoint` works for any
integer-to-integer function: the caller decides what "one step"
means. (Whether it terminates is up to `f`: a function with no fixed
point, like `fun n -> n + 1`, would loop forever.)

:::

