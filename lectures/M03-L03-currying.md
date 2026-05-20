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
of one-argument functions. This shape is called *currying*, after
the logician [Haskell Curry](https://en.wikipedia.org/wiki/Haskell_Curry)
(the same person the [Haskell](https://www.haskell.org/) language is
named for), and it makes a useful trick available: *partial
application*, supplying some of the arguments and getting back a
function that wants the rest.

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
[M03-L01](M03-L01-functions-as-values.html#reading-function-types-is-right-associative)
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

- `add` is a one-argument function with argument `x`.
- Its result is a *function* of one argument `y` returning `x + y`.

The type confirms:

```
val add : int -> int -> int
```

- Right-associative: `int -> (int -> int)`.
- *Takes an int, returns a function from int to int.*

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

The picture is exactly the closure picture from
[M03-L01](M03-L01-functions-as-values.html#a-function-value-remembers-its-environment).
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
let xs_plus_10 = List.map (add 10) xs
```

- `int list = [11; 12; 13; 14]`.
- `List.map` wants an `int -> int` function.
- No need for the one-off lambda `fun x -> add 10 x`.
- `add 10` already *is* that function.
- Common reason to like currying: eliminates small wrapper lambdas in higher-order code.

:::

Without currying you would write:

```ocaml
let xs_plus_10 = List.map (fun x -> add 10 x) xs
```

which works but is noisier. The version `List.map (add 10) xs` reads
as "map the add-10 function over `xs`." That is the pleasant form.

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

let _ = increment 5
let _ = double 5
```

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

let _ = in_human_range 42
let _ = in_celsius_room 22.5
```

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

This simplification is called *eta-reduction* (after the Greek letter
"eta" used to label this rule in the lambda calculus). It is not a
deep idea: just notice that wrapping a function in a lambda that
does nothing but call it is busywork.

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
let xs = [1; 2; 3; 4]
let xs_plus_10 = List.map ((+) 10) xs
```

- We didn't need `fun x -> List.map ((+) 10) x`.
- Same eta-reduction idea.

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

let _ = add_pair (3, 4)
```

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
Given `let add x y = x + y`, what is the type of `add 5`?

- [ ] `int`
- [x] `int -> int`
- [ ] `int -> int -> int`
- [ ] `unit -> int`

**Why:** `add` has type `int -> int -> int`, which reads as `int ->
(int -> int)`. Apply it to one `int` argument and you get back the
`int -> int` half. The result is a function value waiting for the
second `int`.
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

The body is `fun x -> h (g (f x))`, or equivalently
`let compose3 h g f x = h (g (f x))`. Notice how the three functions
chain right-to-left: `f` runs first, then `g`, then `h`. This is the
standard mathematical convention for composition.

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

:::slide

## Activity discussion

- Type of `add 5`: `int -> int`. It's the function `fun y -> 5 + y`.
- `add 5` evaluates to a function value. Toplevel: `int -> int = <fun>`.
- `(add 5) 3` evaluates to `8`. First compute `add 5`, then apply to `3`.
- `add 5 3` (no parens) gives the same `8`.
- Function application is left-associative: `((add) 5) 3`.
- The parens version just makes partial application explicit.

:::

Before reading on, predict the three answers.

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
`sum_to` from Lecture 2 overflow the stack on large inputs; the
tail-recursive versions do not. The mechanism is small (an extra
parameter), but the payoff is that you can recurse on inputs of
any size without worrying about the stack.

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
