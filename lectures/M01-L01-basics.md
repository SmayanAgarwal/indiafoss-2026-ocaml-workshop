---
title: "OCaml - Basics"
lecture_no: 1
week: 1
duration_target_min: 145
concepts: [primitive types, literal syntax, OCaml number representation, string syntax, let bindings, let-in expressions, scope, shadowing, immutability, inference rules, static typing, dynamic typing, type errors, type inference, type signatures, operator precedence, arithmetic operators, comparison, logical operators, common type errors, if as expression, expression-oriented language, branches must agree, type rule for if, expression composition, reading type errors, writing small programs]
keywords: [OCaml, int, float, bool, string, literals, primitive types, let, let-in, scope, shadowing, immutability, bindings, semantics, static typing, dynamic typing, type inference, Hindley-Milner, type errors, operators, precedence, comparison, equality, logical operators, if expression, conditional, branches, expression-oriented, tutorial, expressions, beginner exercises]
reading:
  - title: "Real World OCaml, A Guided Tour (numbers, let bindings, and type-inference sections)"
    url: https://dev.realworldocaml.org/guided-tour.html
  - title: "Cornell CS3110, Basics chapter (types and values, let expressions, type checking, conditional expressions)"
    url: https://cs3110.github.io/textbook/chapters/basics/intro.html
  - title: "The OCaml manual, Basics section"
    url: https://ocaml.org/manual/5.5/coreexamples.html#s%3Abasics
---


# Basics

In this notebook, we will cover the basics of the OCaml
programming language.

## Why OCaml

- OCaml is an industrial-strength, functional programming
  language.
  - In the same family as Haskell and Standard ML.
  - Initially developed at INRIA, and is now a healthy
    open-source project developed on
    [Github](https://github.com/ocaml/ocaml)
- Good mix of functional, imperative and object-oriented
  features.
- A fast compiler that produces efficient native code for x86,
  ARM, RISC-V, etc., as well as JavaScript.
- Users include
  - JaneStreet (almost everything from Hardware that ingests
    market data to trading algorithms to infrastructure)
  - Microsoft (Everest project, F* programming language)
  - Facebook (Hack, Infer, Flow, ReasonML). [More than 50%
    messenger.com is
    ReasonML](https://reasonml.github.io/blog/2017/09/08/messenger-50-reason.html).
  - Docker (for Mac and Windows use MirageOS libraries).
  - and a variety of other research projects including Coq
    proof assistant, Compcert verified C compiler, MirageOS
    Unikernel OS, etc.

Ultimately, functional programming offers an alternative way to
think about *programming*, which is useful even if you don't
intend to use a functional programming language. That said,
functional programming concepts such as immutability, lambdas,
coroutines, promises, monads, lenses, applicatives, functors,
Hindley-Damas-Milner type inference are being adopted in
mainstream imperative languages in C++, Java, Python, Rust etc.,
but also new languages that run on your favourite platform:
Clojure and Kotlin on the JVM, Elixir on Erlang OTP, etc.

## Variables

### Let binding

At its simplest, a variable is an identifier whose meaning is
bound to a particular value. In OCaml these bindings are
introduced using the let keyword.

:::slide

## Let binding

```ocaml
let pi = 3
```

- `pi` is now bound to the value `3`.
- Its type has also been inferred, as `int`.

:::

Every variable binding has a scope, which is the portion of the
code that can refer to that binding. The scope of top-level let
bindings (like the one above) is everything that follows it.

```ocaml
2 * pi * 5
```

### Primitive data types

OCaml offers the following primitive data types int, float,
bool, char, string and unit.

```ocaml
let one = 1

let pi = 3.1415

let are_you_awesome = true

let a = 'a'

let hello = "Hello"

let unit = ()
```

Observe that the types are inferred. One of the key features of
OCaml is type inference and type checking. For example, checking
the equality of incompatible types fails with a compile time
error.

```ocaml skip
one = pi
```

```mdx-error
Line 1, characters 6-8:
Error: This expression has type float but an expression was
       expected of type int
```

### Local let bindings

We can also use let to create a variable binding whose scope is
limited to a particular expression using the in keyword:

:::slide

## Local `let ... in` binding

```ocaml
let i =
  let j = 5 in
  j + 2
```

- A `let` binding's scope can be limited to a particular
  expression using the `in` keyword.
- Only `i` is bound at the top level; `j` is no longer in scope
  once the `in` expression has finished.

:::

As you can see from the output, only i has been bound to a value
at the top-level. The j variable is no longer in scope:

```ocaml skip
j+4
```

## Conditionals

Unsurprisingly, OCaml provides conditional expressions using the
if keyword:

```ocaml
let a = if i < 10 then i else 10
```

## Functions

### Function definition

The let keyword can also be used to define functions:

:::slide

## Function definition

```ocaml
let succ x = x + 1
```

- This defines a function called `succ` which takes an argument
  `x` and returns the value of `x + 1`.
- The type inferred for `succ` is `int -> int`, meaning it is a
  function from `int` to `int`; it takes an integer argument and
  returns an integer.

:::

You can also provide explicit type annotations, but generally we
elide them.

```ocaml
let succ (x : int) : int = x + 1
```

The latter definition of `succ` shadows the former.

### Multiple arguments

Functions with multiple arguments are defined the same way:

```ocaml
let add x y = x + y
```

### Function application

Unlike most imperative languages, functions are applied without
any brackets:

```ocaml
let b = succ 8

let c = add a b
```

(* ### Exercise

Implement a function to compute the sum of successors of the
given two numbers using `add` and `succ`.

```ocaml
let sum_of_succ x y = failwith "for you to implement"
```

```ocaml skip
assert (sum_of_succ 5 6 = 13)
```
*)

### Recursive functions

We can also create recursive functions by adding the rec keyword
to a let binding. For example, the sum of first `n` integers can
be implemented as follows:

```ocaml
let rec sum_of_first_n n = 
  if n <= 0 then 0
  else sum_of_first_n (n-1) + n
```

```ocaml
assert (sum_of_first_n 5 = 15)
```

(* ### Exercise

Implement a recursive function that computes the nth fibonacci
number.

\begin{align}
fib(n) =
  \begin{cases}
    1 & \quad \text{if } n < 2 \\
    fib(n-1) + fib(n-2)       & \quad \text{otherwise}
  \end{cases}
\end{align}

```ocaml
let rec fib n = failwith "for you to implement"
```

```ocaml skip
assert (fib 10 = 89)
```
*)

### Labelled arguments

Consider the following function

```ocaml
let divide dividend divisor = dividend / divisor
```

Looking at just the signature, it's not obvious which int
argument is the dividend and which is the divisor.

We can fix this using labelled arguments. To label an argument in
a signature, `NAME:` is put before the type. When defining the
function, we put a tilde (`~`) before the name of the argument:

:::slide

## Labelled arguments

```ocaml
let divide ~dividend ~divisor = dividend / divisor
```

- Without labels it isn't obvious which `int` argument is the
  dividend and which is the divisor.
- Label an argument in the signature with `NAME:` before the
  type; when defining the function, put a tilde (`~`) before the
  argument name.

:::

We can then call it using:

```ocaml
divide ~dividend:9 ~divisor:3
```

Labelled arguments can be passed in in any order (!)

```ocaml
divide ~divisor:3 ~dividend:9 
```

We can also pass variables into the labelled argument:

```ocaml
let dividend = 9 in
let divisor  = 3 in
divide ~dividend:dividend ~divisor:divisor
```

If the variable name happens to be the same as the labelled
argument, we don't even have to write it twice:

```ocaml
let dividend = 9 in
let divisor  = 3 in
divide ~dividend ~divisor
```

(* ### Exercise

Implement `modulo ~dividend ~divisor` using our version of divide
with labelled arguments.

```ocaml
let modulo ~dividend ~divisor = failwith "for you to implement"
```

```ocaml skip
assert (2 = modulo ~dividend:17 ~divisor:5)
```

```ocaml skip
assert (0 = modulo ~dividend:99 ~divisor:9)
```
*)

### Higher-order functions

Since OCaml is a functional language, functions are regular
values which can be used like any other. In particular, they can
be used as arguments to other functions. Functions which take
other functions as arguments as called higher-order functions.

For example, the `List.map` function takes two arguments: a
function and a list, and returns a new list created by applying
the function to each of the elements of the list.

We can use `List.map` to apply the succ function to all the
numbers in the list `[1; 2; 3]`:

:::slide

## Higher-order functions

```ocaml
let l = List.map succ [1;2;3]
```

- Functions are regular values, so they can be passed as
  arguments to other functions ("higher-order functions").
- `List.map` takes a function and a list, and returns a new list
  created by applying the function to each element of the list.

:::

This jupyter notebook comes equipped with `merlin`, an OCaml IDE
service plugin that provides auto-completion, documentation
search, etc. Using merlin, you can look up the available
functions in `List` by typing `List.<tab>`.

You can also get documentation for a particular function by
typing the function and pressing `shift+tab`. For example, try
typing `List.map<shift+tab>`. A pop up should appear displaying
the documentation.

```ocaml
List.map
```

### Currying

Like many functional languages, OCaml provides support for
partial application of functions in the form of currying.

You may have noticed that the type of our add function was
written:

`int -> int -> int`

another way to write this type would be

`int -> (int -> int)`.

In other words, add is actually a function which takes an int
and returns a function from int to int. For example, we could
redefine our succ function by partially applying add to 1:

:::slide

## Currying

```ocaml
let succ = add 1
```

- `add`'s type `int -> int -> int` is the same as
  `int -> (int -> int)`: `add` takes an `int` and returns a
  function from `int` to `int`.
- We can redefine `succ` by partially applying `add` to `1`.

:::

### Anonymous functions

Instead of defining each function with a let, often times it is
handy to define functions on the fly. OCaml has support for
anonymous functions, which allows you to define unnamed
functions. To write an anonymous function, the `fun` keyword is
used in the following form `(fun ARG1 ARG2 ... -> BODY)`. We can
define an anonymous function for `succ` and use it as follows:

```ocaml
List.map (fun x -> x + 1) [1;2;3]
```
