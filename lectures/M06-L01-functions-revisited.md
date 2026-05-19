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
    url: https://cs3110.github.io/textbook/chapters/hop/index.html
---

# Functions as values, revisited

We touched on higher-order functions in Module 3. This lecture
makes them the main course. A **higher-order function** is one that
either takes another function as an argument or returns a function
as its result. The four canonical examples (`map`, `filter`,
`fold`, function composition) make up the rest of the module.

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

:::slide

## Why it matters: extract the common shape

Several functions that all "do something for each element of a list":

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

let _ = all_doubled [1; 2; 3]
let _ = all_squared [1; 2; 3]
let _ = all_plus_one [1; 2; 3]
```

- Three functions; same shape.
- Only the per-element work differs.
- Higher-order functions let us extract *the walk* from *the work*:

```ocaml
let rec map f = function
  | [] -> []
  | x :: rest -> f x :: map f rest

let _ = map (fun x -> x * 2) [1; 2; 3]
let _ = map (fun x -> x * x) [1; 2; 3]
let _ = map (fun x -> x + 1) [1; 2; 3]
```

`[2; 4; 6]`, `[1; 4; 9]`, `[2; 3; 4]`.

- One function captures the *shape* (walking the list).
- Three different per-element computations are passed in.

:::

`map` is the protagonist of Lecture 2. We're previewing it here to
make the case: extracting *the walk* into a higher-order function
lets you express many concrete computations as data passed to one
generic function. That's the higher-order programming idiom in a
nutshell.

:::slide

## Callbacks: the GUI / event idiom

Higher-order functions show up everywhere in GUI / network code:

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

:::slide

## Operators are functions too

The infix operators have prefix forms:

```ocaml
let _ = (+) 3 4
let _ = ( * ) 3 4
let _ = (^) "hi " "there"
```

`7`, `12`, `"hi there"`. Wrap an operator in parens and it's a
function.

This is useful with higher-order functions:

```ocaml
let _ = List.map ((+) 10) [1; 2; 3]
```

`[11; 12; 13]`.

- Partial application of `(+)` to `10` gives a function `int -> int`.
- Pass that function directly to `map`.

:::

:::slide

## Functions can return functions can return functions...

```ocaml
let curry3 f x y z = f (x, y, z)

let dist3 (x, y, z) =
  sqrt (float_of_int (x*x + y*y + z*z))

let _ = curry3 dist3 3 4 12
```

`13.0`.

- `curry3` takes a function expecting a triple.
- It turns that into a function of three arguments.
- We pass `dist3` (wants a triple) plus three numbers; `curry3` bundles.

The point: functions are values you can shape and reshape at will.

:::

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
- The signature `('a -> 'a) -> 'a -> 'a` says exactly this: any
  `'a`, as long as the function maps `'a` to `'a`, can be repeated.

:::

:::slide

## What's next

Lecture 2: **`map`** in detail.

- Canonical "do something to each element" operation.
- The most common higher-order function in practice.
- Prototype for everything in this module.

:::

## Reading

- **Cornell CS3110**, *Higher-order functions*:
  <https://cs3110.github.io/textbook/chapters/hop/index.html>
