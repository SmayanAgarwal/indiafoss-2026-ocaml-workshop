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
