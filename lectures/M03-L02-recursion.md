---
title: "Recursion"
lecture_no: 2
week: 3
duration_target_min: 25
concepts: [recursion, base case, recursive case, structural recursion, termination]
keywords: [OCaml, recursion, recursive functions, base case, factorial, list length]
activity_question: "Write a recursive function [count_down : int -> unit] that prints n, n-1, ..., 1, 0. What is the base case?"
think_about_this: "Every recursive function needs a base case. What goes wrong if you forget one? What goes wrong if you have one but the recursive call never approaches it?"
reading:
  - title: "Cornell CS3110, Recursion"
    url: https://cs3110.github.io/textbook/chapters/basics/functions.html
---

# Recursion

A recursive function is one that calls itself. In a language without
mutable loop variables, recursion is the main way to "do something N
times" or "walk through a structure". This lecture is about how to
write a recursive function safely, and how to think about whether
it terminates.

:::slide

## A first recursive function

```ocaml
let rec factorial n =
  if n = 0 then 1
  else n * factorial (n - 1)

let _ = factorial 5
```

`int = 120`. Three things to notice:

1. The keyword `rec` after `let`. Without it, `factorial` would not
   be visible inside its own body.
2. The **base case**: `if n = 0 then 1`. Without a base case, the
   function never stops calling itself.
3. The **recursive case**: `else n * factorial (n - 1)`. This case
   refers back to the function, but on a *smaller* argument.

:::

The two halves of a recursive definition mirror the structure of
the data: a number is either zero (base) or one more than another
number (recursive). The factorial of zero is one; the factorial of
a positive number is that number times the factorial of one less.
Every recursive function you write will have this same shape: one
or more base cases plus one or more recursive cases.

:::slide

## Why `let rec` and not just `let`?

```ocaml
let factorial n =
  if n = 0 then 1
  else n * factorial (n - 1)
```

- OCaml rejects this: `Error: Unbound value factorial`.
- Inside the body of a *non-recursive* `let factorial = ...`, the name `factorial` isn't in scope yet.
- `let rec` says "bring the name into scope inside the body too".
- That's the only difference.
- Use `let rec` when the function refers to itself; `let` otherwise.

:::

The "Unbound value" error here is one of the most common beginner
mistakes. The fix is simple: add `rec`. The reason OCaml *requires*
you to be explicit is so that ordinary `let` doesn't surprise you:
when you write `let foo = ...`, references to `foo` inside the
right-hand side mean the *outer* `foo` (if any), not the one being
defined. That property is useful for shadowing.

:::slide

## Recursion on lists

```ocaml
let rec length xs =
  match xs with
  | [] -> 0
  | _ :: rest -> 1 + length rest

let _ = length [10; 20; 30; 40]
```

- `int = 4`.
- Base case: empty list `[]` (length 0).
- Recursive case: unpack cons cell `_ :: rest`, add 1 to the length of the rest.
- Using pattern matching (full coverage in Module 5).

Read the cases:

- `[] -> 0`: empty list has length 0.
- `_ :: rest -> 1 + length rest`: non-empty has length 1 plus length of tail.

:::

This shape (one base case for the empty list, one recursive case
that strips one element and recurs on the rest) is so common it has
a name: **structural recursion on lists**. Most list-processing
functions in OCaml's standard library are written this way under
the hood: `List.map`, `List.length`, `List.filter`, `List.fold_left`.

:::slide

## Recursion on numbers, counting down

```ocaml
let rec count_down n =
  if n < 0 then ()
  else begin
    print_endline (string_of_int n);
    count_down (n - 1)
  end

let _ = count_down 5
```

- Prints `5`, `4`, `3`, `2`, `1`, `0`.
- Base case: `n < 0`, do nothing.
- Recursive case: print `n`, then recur on `n - 1`.
- `begin ... end` brackets a sequenced block; more in Module 7 (side effects).

:::

:::slide

## Recursion on numbers, summing

```ocaml
let rec sum_up_to n =
  if n = 0 then 0
  else n + sum_up_to (n - 1)

let _ = sum_up_to 10
```

- `int = 55`.
- We recurse on the integer itself: each step reduces `n` by one until zero.
- Mathematically: `n + (n-1) + ... + 1`.
- Closed form exists (`n * (n + 1) / 2`) and is faster.
- We use recursion here to illustrate the pattern.

:::

:::slide

## Termination

- Every recursive function must **terminate**: it must eventually hit a base case.

```ocaml
let rec bad n = bad (n + 1)
```

- Type-checks fine.
- Run it: never returns.
- Eventually OCaml's stack overflows and you get a runtime error.

For termination:

- *Every* recursive call must move *closer* to a base case.
- `factorial (n - 1)` is closer to `0` than `factorial n`, if `n` started ≥ 0.
- `length rest` is closer to `[]` than `length xs`.

Always ask: *is the argument to the recursive call strictly smaller, by some measure, than the current argument?*

:::

:::slide

## What if the input is negative?

```ocaml skip
let rec factorial n =
  if n = 0 then 1
  else n * factorial (n - 1)

let _ = factorial (-1)
```

- Stack overflow eventually.
- Base case is `n = 0`, but negative inputs go `-1 → -2 → -3 → ...`, never reaching `0`.

Two fixes:

```ocaml
let rec factorial n =
  if n <= 0 then 1
  else n * factorial (n - 1)
```

- `<= 0` treats all non-positive inputs as base.

Or be strict:

```ocaml
let rec factorial n =
  if n < 0 then invalid_arg "factorial: negative input"
  else if n = 0 then 1
  else n * factorial (n - 1)
```

- Rejects negative inputs at runtime.
- Surfaces the bug instead of producing a wrong answer.

:::

:::slide

## The mental model

The rhythm for reading or writing a recursive function:

1. **What is the input made of?** Number? List? Each has a natural shape (zero or successor; empty or cons).
2. **What is the base case?** What does the function return for the smallest input?
3. **What is the recursive case?** Given the answer for a *smaller* input (trust the function), how do I combine it with the current piece to get the bigger answer?

- This is the famous **inductive style**.
- Once you have it, writing recursive functions becomes mechanical.

:::

:::slide

## Worked example: power

`power x n = x^n` for integer `n ≥ 0`.

```ocaml
let rec power x n =
  if n = 0 then 1
  else x * power x (n - 1)

let _ = power 2 10
```

- `int = 1024`.
- Base case: anything to the zero is `1`.
- Recursive case: `x^n = x * x^(n-1)`.
- Recursive call has `n - 1`: moving toward the base.

:::

:::slide

## Two recursive calls: Fibonacci

```ocaml
let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)

let _ = fib 10
```

- `int = 55`.
- Two base cases bundled: `fib 0 = 0`, `fib 1 = 1`.
- Recursive case has *two* calls.
- Slow for large `n`: each call recomputes overlapping subproblems from scratch.
- We'll revisit in the tail-recursion lecture and in Module 6.

:::

:::slide

## Activity

Write a recursive function `count_down : int -> unit` that prints
each integer from `n` down to `0` (inclusive). What is the base
case?

:::

:::slide

## Activity discussion

```ocaml
let rec count_down n =
  if n < 0 then ()
  else begin
    print_endline (string_of_int n);
    count_down (n - 1)
  end
```

- Base case: `n < 0`, do nothing (`()`).
- Recursive case: print `n`, recur on `n - 1`.

`count_down 3` trace:

- prints `3`, calls `count_down 2`
- prints `2`, calls `count_down 1`
- prints `1`, calls `count_down 0`
- prints `0`, calls `count_down (-1)`
- base case, done.

:::

:::slide

## What's next

Lecture 3: **currying and partial application**.

- Make explicit the "function returning function" pattern.
- Use it to write small reusable utilities.

Lecture 4: **tail recursion**.

- Fixes the stack-overflow risk of naive recursive functions.

:::

## Reading

- **Cornell CS3110**, *Recursion*:
  <https://cs3110.github.io/textbook/chapters/basics/functions.html>
