---
title: "Functions as values, revisited"
lecture_no: 1
week: 6
duration_target_min: 20
concepts: [higher-order functions, functions as arguments, callbacks, function composition (preview)]
keywords: [OCaml, higher-order functions, callbacks, functions as values]
activity_question: "Write [twice : ('a -> 'a) -> 'a -> 'a] that applies a function to its argument twice. Test with [twice (fun x -> x + 3) 10]."
think_about_this: "A higher-order function takes a *function* as a parameter. Why is this more flexible than what you could do with overloading or templates in C++/Java?"
reading:
  - title: "Cornell CS3110, Higher-order functions"
    url: https://cs3110.github.io/textbook/chapters/hop/higher_order.html
  - title: "John Hughes, Why Functional Programming Matters"
    url: https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf
---

# Functions as values, revisited

Back in [Module 3](M03-L01-functions-as-values.html) we said,
almost in passing, that functions are *first-class values* in OCaml:
a function is a value the same way `42` is a value, with the same
rights to be named, passed around, returned from another function,
or dropped into a data structure. We even saw a couple of small
consequences of that fact: `let plus_one = fun x -> x + 1` looks
like a perfectly ordinary `let` binding; `make_adder 5` returns a
brand new function value; `apply_twice f x` takes a function as an
argument.

This module is where we take that idea and lean on it. The remaining
five lectures in Module 6 are, in a sense, a single sustained
exercise in higher-order programming: writing functions that take
other functions, returning functions from other functions, and
combining the two to express computations that would be much more
verbose in a first-order language. We are going to meet the famous
trio [`map`](M06-L02-map.html), [`filter`](M06-L03-filter.html), and
[`fold`](M06-L04-fold.html); the [pipeline operator `|>`](M06-L05-pipelines.html);
and finally, in [the tutorial](M06-L06-tutorial.html), rebuild a
sizeable slice of the standard library out of those few pieces.

A **higher-order function** is one that does either of two things:
it takes a function as an argument, or it returns a function as its
result. (Most of the interesting ones do both.) That is the entire
definition. Once you have higher-order functions, a remarkable amount
of mileage opens up: you can extract the *pattern* of a computation
from the *details* it operates on, parameterise the pattern by the
details, and reuse the same pattern across dozens of concrete
computations.

The canonical paper on this style is John Hughes's
[*Why Functional Programming Matters*](https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf)
from 1990. Hughes argues that higher-order functions are not merely
a notational convenience; they are the *glue* that lets a functional
programmer combine small parts into large programs. If you read only
one optional paper this course, read that one.

## A function that takes a function

Let us start with the simplest example. Suppose we want a function
that applies its argument twice:

```ocaml
let twice f x = f (f x)

let _ = twice (fun n -> n + 3) 10
let _ = twice (fun s -> "(" ^ s ^ ")") "x"
```

:::slide

## A function that takes a function

```ocaml
let twice f x = f (f x)

let _ = twice (fun n -> n + 3) 10
let _ = twice (fun s -> "(" ^ s ^ ")") "x"
```

`16` and `"((x))"`.

- Type: `('a -> 'a) -> 'a -> 'a`.
- Takes a function `'a -> 'a` and a value `'a`; returns an `'a`.
- Works for **any** type `'a`.
- Both calls above instantiate `'a` differently (`int`, `string`).

:::

The first call returns `16` (the increment-by-3 function applied to
`10` gives `13`, then to `13` gives `16`). The second returns
`"((x))"` (the parenthesise function wraps once, then wraps again).
The same `twice` works for both because its type is *polymorphic*:
`('a -> 'a) -> 'a -> 'a`. As long as the function we pass maps a
type to itself, `twice` will apply it twice to a value of that type
and return a value of that same type.

The polymorphism here is doing real work. In Java or C++, you would
write two separate `twice` functions (one for `int`, one for `String`),
or you would reach for generics. In OCaml, polymorphism is the
default and a single definition handles every type. Templates in C++
and generics in Java give you something similar, but the OCaml
version is checked at compile time without code duplication, and it
reads as plain OCaml rather than as a separately-defined template
language.

## A function that returns a function

We have already met `make_adder` in Module 3:

```ocaml
let make_adder n = fun x -> x + n

let plus_five = make_adder 5
let plus_ten  = make_adder 10

let _ = plus_five 1
let _ = plus_ten 1
```

:::slide

## A function that returns a function

```ocaml
let make_adder n = fun x -> x + n

let plus_five = make_adder 5
let plus_ten  = make_adder 10

let _ = plus_five 1
let _ = plus_ten 1
```

`6` and `11`.

- `make_adder 5` produces *a new function* that adds 5.
- The new function holds onto `n` from the enclosing scope.
- This is the **closure** we saw in Module 3.

:::

`make_adder 5` returns the function that adds 5 to its argument.
That returned function remembers, in its closure, that `n` was `5`
at the moment of creation. Different calls to `make_adder` produce
*different* functions, each with its own captured `n`. This is the
mechanism that makes higher-order programming practical: a function
returned from another function is not a stripped-down code pointer
but a full value carrying whatever local state it needs.

We say a function is *higher-order* if it takes a function as a
parameter, or returns one as a result, or both. `twice` qualifies
on the first count; `make_adder` qualifies on the second. Most of
the rest of this module is about higher-order functions that do
both at once.

## Why bother? The Abstraction Principle

The slogan is *do not say the same thing twice*. Higher-order
functions are how we cash that slogan out for repeated patterns of
computation.

Suppose we have three functions, all of the same shape:

```ocaml
let rec all_doubled = function
  | [] -> []
  | x :: rest -> (x * 2) :: all_doubled rest

let rec all_squared = function
  | [] -> []
  | x :: rest -> (x * x) :: all_squared rest

let rec all_plus_one = function
  | [] -> []
  | x :: rest -> (x + 1) :: all_plus_one rest
```

Three functions; the same skeleton ("walk the list, do something to
each element, build the result"). The *only* difference is the
"something" applied to each element: `x * 2`, `x * x`, `x + 1`. Every
other line of code is identical.

That repetition is begging to be factored out. The trick: pull the
per-element computation up into a parameter. We get one function
that captures *the walk*, and pass in three different parameters for
*the work*:

```ocaml
let rec map f = function
  | [] -> []
  | x :: rest -> f x :: map f rest

let _ = map (fun x -> x * 2) [1; 2; 3]
let _ = map (fun x -> x * x) [1; 2; 3]
let _ = map (fun x -> x + 1) [1; 2; 3]
```

:::slide

## The same shape, three times

Three first-order functions:

```ocaml
let rec all_doubled = function
  | [] -> []
  | x :: rest -> (x * 2) :: all_doubled rest

let rec all_squared = function
  | [] -> []
  | x :: rest -> (x * x) :: all_squared rest

let rec all_plus_one = function
  | [] -> []
  | x :: rest -> (x + 1) :: all_plus_one rest
```

- Same shape.
- Only the per-element work differs.

Factor the work out as a parameter:

```ocaml
let rec map f = function
  | [] -> []
  | x :: rest -> f x :: map f rest

let _ = map (fun x -> x * 2) [1; 2; 3]
let _ = map (fun x -> x * x) [1; 2; 3]
let _ = map (fun x -> x + 1) [1; 2; 3]
```

`[2; 4; 6]`, `[1; 4; 9]`, `[2; 3; 4]`.

- One function captures *the walk*.
- Three per-element computations are passed in.

:::

`map` is the protagonist of [Lecture 2](M06-L02-map.html). We are
previewing it here to make the larger point: factoring *the walk*
out of *the work* gives you one general-purpose function plus a
small data-like description of what to do at each step. Three
concrete computations collapsed into three one-line definitions.
This is the *Abstraction Principle* (Bruce MacLennan's name for
it): identify a pattern that repeats, abstract it into a reusable
form, and supply only the variations as parameters.

The Abstraction Principle is at the heart of why higher-order
functions matter. It is not just an aesthetic gain: when you later
need to optimise the walk (say, make it tail-recursive), every
client of the abstracted function benefits at once. When you write
`all_doubled`, `all_squared`, `all_plus_one` separately, you have
to find and fix three places. Module 6 is essentially one extended
case study in this principle.

## Functions are values: what that really means

Three things follow from "functions are values":

**They have a type.** `fun x -> x + 1` has type `int -> int`. You
can ask the compiler what type a function has, and it will tell you.
We have seen this from the start of the course.

**They can be passed around.** Anywhere you can put a value (an
argument, a list element, a record field, a tuple component), you
can put a function. There is no need for a special "function type"
marker; the type system already covers it.

**They can be created on the fly.** `fun x -> x + n` is an
*expression*: writing it down produces a function value. You do not
need a separate "compile" step. You can compute a function inside
another function and return the result.

This is what people mean by *first-class*. In a language where
functions are not first-class (C is the classic example; you can
pass function pointers, but you cannot create new functions at
runtime), each of these three points fails in some way. C function
pointers cannot capture local variables; they are not values in the
same sense as an `int`. OCaml functions can capture; they really are
values.

## Callbacks: the everyday higher-order pattern

Outside of strictly functional programming, the most common form of
higher-order function in everyday code is the *callback*. A
callback is a function you give to another piece of code so that it
can call you back later. GUIs, network code, and event loops all
work this way.

:::slide

## Callbacks: the GUI / event idiom

Higher-order functions are everywhere in GUI / network code:

```ocaml
let on_click handler =
  (* imagine a real GUI here *)
  handler "user clicked at (100, 200)"

let _ =
  on_click (fun msg ->
    print_endline ("got event: " ^ msg))
```

- `on_click` calls its argument `handler` with an event description.
- You pass a function that decides *what to do* with the event.
- That function is a **callback**.

Across languages:

- **Java**: needs an interface (`OnClickListener`).
- **JavaScript**: pass a lambda.
- **OCaml**: pass a function (functions are values).

:::

`on_click` does not know what should happen when the user clicks;
that is the caller's problem. So it asks the caller for a function,
calls that function with the relevant event data, and lets the
caller decide. The whole arrangement is one function passed as an
argument to another, used once and discarded.

In [Java](https://docs.oracle.com/javase/tutorial/java/javaOO/lambdaexpressions.html)
prior to Java 8, this idiom required defining an interface
(`OnClickListener`, say), instantiating an anonymous class that
implemented the interface, and passing an instance to `on_click`.
Java 8 added lambdas precisely so that this would not be so painful.
In JavaScript, callbacks have been the everyday building block since
the language was born; one of the foundational books on the language,
*JavaScript: The Good Parts*, devotes a whole chapter to them. In
OCaml, no special machinery is needed: a function is a value, you
just pass it.

## Operators are functions too

A small but useful piece of syntax: any OCaml infix operator can be
turned into a regular function by wrapping it in parentheses. The
operator `+` is normally infix, but `(+)` is a normal two-argument
function value.

```ocaml
let _ = (+) 3 4
let _ = ( * ) 3 4
let _ = (^) "hi " "there"
```

:::slide

## Operators are functions too

Wrap an infix operator in parens, get a function:

```ocaml
let _ = (+) 3 4
let _ = ( * ) 3 4
let _ = (^) "hi " "there"
```

`7`, `12`, `"hi there"`.

This composes well with higher-order functions:

```ocaml
let _ = List.map ((+) 10) [1; 2; 3]
```

`[11; 12; 13]`.

- `(+) 10` is the partial application "add 10".
- Pass that function directly to `map`; no lambda needed.

:::

Notice the small piece of whitespace inside `( * )`. Without the
spaces, OCaml parses `(*` as the start of a comment, which is rarely
what you want. So the convention for the multiplication operator is
to write it with spaces: `( * )`.

Combining operators-as-functions with partial application gives a
particularly compact higher-order idiom:

```ocaml
let _ = List.map ((+) 10) [1; 2; 3]
```

`(+) 10` is the function "add 10": we have applied `(+)` to one of
its two arguments, leaving a function from `int` to `int`. We then
pass that function directly to `List.map`. The result, `[11; 12;
13]`, comes out without us having to write a single anonymous
function. You will see this pattern repeatedly in idiomatic OCaml.

## Function composition

If you have two functions `f : 'b -> 'c` and `g : 'a -> 'b`, you can
build a new function `fun x -> f (g x)` that runs `g` first and then
`f`. This is *function composition*, and it is so common that it has
its own name in mathematics:

$$
(f \circ g)(x) = f(g(x))
$$

In OCaml, the standard library does *not* provide a composition
operator by default (some projects define one as `(>>)` or `(<<)`),
but you can write one yourself in a single line:

```ocaml
let compose f g = fun x -> f (g x)

let square = fun x -> x * x
let inc    = fun x -> x + 1
let square_then_inc = compose inc square
let _ = square_then_inc 4
```

The result of `square_then_inc 4` is `17`: first square (`16`), then
increment (`17`). We will revisit composition in Lecture 5 alongside
the pipeline operator `|>`. For now, notice the signature:

```
val compose : ('b -> 'c) -> ('a -> 'b) -> 'a -> 'c
```

Read as: "given a function from `'b` to `'c`, and a function from
`'a` to `'b`, produce a function from `'a` to `'c`." Composition is
a *function that takes two functions and returns a function*. It is
higher-order on both ends.

## Closures revisited: capture happens once

We saw closures in [Module 3](M03-L01-functions-as-values.html#a-function-value-remembers-its-environment).
The one point worth repeating, because it surprises people, is that
a closure captures values *at the time the function is created*,
not names that get re-looked-up later.

```ocaml
let n = 10
let f = fun x -> x + n
let n = 99
let _ = f 1
```

What is `f 1`? It is `11`, not `100`. When `f` was defined, the
binding for `n` in scope was `n = 10`; the closure captured that
value. The later `let n = 99` shadows the outer `n` for code written
*after* it, but does not retroactively update what `f` saw. Closures
freeze the environment at the moment of creation.

This is the same point we made in [Module 2](M02-L02-let-bindings.html#why-shadowing-differs-from-mutation-closures-see-the-old-value)
(shadowing is not mutation), applied here to function values.
Functions returned from `make_adder` work the same way: the captured
`n` is whatever it was when that particular function was created.
Each `make_adder` call creates an independent closure with its own
captured `n`.

## Functions can return functions can return functions

Once we accept that functions are values, there is no reason a
function cannot return *another* function, which itself returns
another function, and so on. In fact this is exactly what
multi-argument functions in OCaml are: a chain of one-argument
functions, each returning the next.

```ocaml
let curry3 f x y z = f (x, y, z)

let dist3 (x, y, z) =
  sqrt (float_of_int (x*x + y*y + z*z))

let _ = curry3 dist3 3 4 12
```

:::slide

## Functions can return functions can return functions

```ocaml
let curry3 f x y z = f (x, y, z)

let dist3 (x, y, z) =
  sqrt (float_of_int (x*x + y*y + z*z))

let _ = curry3 dist3 3 4 12
```

`13.0`.

- `curry3` takes a function expecting a triple.
- It turns that into a function of three arguments.
- We pass `dist3` (which wants a triple) plus three numbers; `curry3` bundles.

:::

`curry3 dist3` is a value that, given three arguments one at a time,
will eventually bundle them into a triple and apply `dist3`.
"Currying" is the term for this technique: turning an `n`-argument
function into a chain of `n` one-argument functions. We saw it in
[M03-L03](M03-L03-currying.html) and will see it again as a recurring
background hum throughout this module.

The point of the example above is not currying itself; it is the
demonstration that *functions are values you can shape and reshape
at will*. You can repackage them, partially apply them, pass them
to other functions that then partially apply them, and so on. The
language puts no special restrictions on what you can do.

## A quick check

:::quiz mcq
What is the type of `twice`, where `let twice f x = f (f x)`?

- [ ] `('a -> 'b) -> 'a -> 'b`
- [x] `('a -> 'a) -> 'a -> 'a`
- [ ] `'a -> 'a -> 'a`
- [ ] `('a -> 'b) -> 'b -> 'a`

**Why:** for `f (f x)` to type-check, the output of the inner `f x`
must be a valid input to the outer `f`. So `f`'s input and output
types must coincide. Calling that type `'a`, `f` is `'a -> 'a`, `x`
is `'a`, and the result is `'a`. So `twice : ('a -> 'a) -> 'a -> 'a`.
:::

:::quiz mcq
Which of these is *not* a higher-order function?

- [ ] `let apply f x = f x`
- [ ] `let make_adder n = fun x -> x + n`
- [x] `let add x y = x + y`
- [ ] `let compose f g = fun x -> f (g x)`

**Why:** a higher-order function either takes or returns a function.
`apply` takes a function. `make_adder` returns a function (so does
every two-argument function in OCaml, technically, by currying, but
the explicit `fun` makes it especially clear). `compose` does both.
`add` takes two `int`s and returns an `int`; no functions involved.

(Pedantic note: `add` is internally curried, so `add 3` *is* a
function `int -> int`. By that strict reading every multi-argument
function is higher-order. The everyday usage of "higher-order"
reserves the term for functions that take or return functions
*by intent*. `add` is not such a function.)
:::

A small code challenge:

:::quiz code
Write `apply_n : int -> ('a -> 'a) -> 'a -> 'a` that applies `f` to
`x`, `n` times. So `apply_n 3 f x` is `f (f (f x))`, and `apply_n 0
f x` is just `x`.

```ocaml
let rec apply_n n f x =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let inc x = x + 1
let () =
  check (apply_n 0 inc 5 = 5)   "zero applications";
  check (apply_n 1 inc 5 = 6)   "one application";
  check (apply_n 3 inc 5 = 8)   "three applications";
  check (apply_n 10 (fun x -> x * 2) 1 = 1024) "ten doublings";
  print_endline "all tests passed"
```
:::

Reference solution:

```
let rec apply_n n f x =
  if n = 0 then x
  else apply_n (n - 1) f (f x)
```

The base case is `n = 0`: nothing left to do, return `x`. The
recursive case: apply `f` once, then apply `n - 1` more times.

## Activity

:::slide

## Activity

Write `twice : ('a -> 'a) -> 'a -> 'a` that applies a function
twice. Test with `twice (fun x -> x + 3) 10`.

:::

:::slide

## Activity solution

```ocaml
let twice f x = f (f x)

let _ = twice (fun x -> x + 3) 10
let _ = twice (fun s -> s ^ "!") "wow"
let _ = twice (List.cons 0) [1; 2; 3]
```

`16`, `"wow!!"`, `[0; 0; 1; 2; 3]`.

- Three different types of `'a` (`int`, `string`, `int list`).
- Same `twice` works for all of them.
- The signature `('a -> 'a) -> 'a -> 'a` says exactly this.

:::

The three calls instantiate `'a` at three different types: `int`,
`string`, `int list`. The same `twice` works for all of them. The
type signature `('a -> 'a) -> 'a -> 'a` records this: any `'a`, as
long as the function maps `'a` to `'a`, can be repeated.

## What's next

We have set the stage. The next four lectures take the abstraction-of-a-walk
idea and follow it to the three canonical higher-order list
functions: [`map`](M06-L02-map.html) (transform each element),
[`filter`](M06-L03-filter.html) (keep some elements), and
[`fold`](M06-L04-fold.html) (combine all elements).
[Lecture 5](M06-L05-pipelines.html) introduces the pipeline operator
`|>`, which lets us chain these three together in left-to-right
reading order. [Lecture 6](M06-L06-tutorial.html) is the tutorial:
rebuild parts of the `List` module from this small toolkit.

:::slide

## What's next

Lecture 2: **`map`** in detail.

- Canonical "do something to each element" operation.
- The most common higher-order function in practice.
- Prototype for everything in this module.

:::

## Reading

- **Cornell CS3110**, *Higher-order functions*:
  <https://cs3110.github.io/textbook/chapters/hop/higher_order.html>
- **John Hughes**, *Why Functional Programming Matters* (1990): the
  classic paper arguing that higher-order functions and lazy evaluation
  are the glue of modular functional programs.
  <https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf>
