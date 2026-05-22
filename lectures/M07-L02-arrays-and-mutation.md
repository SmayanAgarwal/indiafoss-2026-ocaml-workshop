---
title: "Mutable records and arrays"
lecture_no: 2
week: 7
duration_target_min: 22
concepts: [mutable record fields, arrays, in-place update, when to use mutation]
keywords: [OCaml, mutable, array, record, in-place, mutation]
activity_question: "Write a function [reverse_in_place : 'a array -> unit] that reverses an array in place (mutating its contents). Test that the original array has been modified."
think_about_this: "Arrays are O(1) indexed access; lists are O(n). When does the constant-time access matter enough to give up the functional immutability of lists?"
reading:
  - title: "Cornell CS3110, Arrays"
    url: https://cs3110.github.io/textbook/chapters/mut/arrays.html
---

# Mutable records and arrays


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Mutable records and arrays</h2>
<p class="title-slide-label">Module 7 &middot; Lecture 2</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

Beyond the single-cell [`ref`](M07-L01-references.html), OCaml has
two more mutable building blocks: *records with mutable fields*
and *fixed-size arrays*. The
[previous lecture](M07-L01-references.html) introduced `ref` and
saw briefly that a `ref` is
[just a one-field record](M07-L01-references.html#a-ref-is-a-record-with-one-mutable-field)
with the field marked `mutable`. This lecture goes further. We pick
up the mutable record story, then spend most of our time on arrays:
when they are the right tool, how to allocate and access them, how
they compare with [the lists](M04-L04-recursive-types.html) we have
been using all course, and the loop syntax that lives alongside
them.

The decision of when in-place mutation pays for the equational
reasoning you give up runs through both halves of the lecture.

## Mutable record fields

You mark a [record](M04-L02-records.html) field `mutable` when you
want to update it in place after the record has been constructed.

```ocaml
type counter = { mutable n : int; name : string }

let c = { n = 0; name = "visits" }
let () = c.n <- c.n + 1
let () = c.n <- c.n + 1
let _ = c.n
let _ = c.name
```

The toplevel reports `int = 2` for `c.n` and `string = "visits"`
for `c.name`. Only fields marked `mutable` can be updated: trying
to write `c.name <- "x"` would be a *compile-time error*. The `<-`
operator is the field-assignment operator. It takes a field-access
expression on the left and a new value on the right, and produces
`unit`.

:::slide

## Mutable record fields

You declare a field `mutable` when you want to update it in place:

```ocaml
type counter = { mutable n : int; name : string }

let c = { n = 0; name = "visits" }
let () = c.n <- c.n + 1
let () = c.n <- c.n + 1
let _ = c.n
let _ = c.name
```

`int = 2`, `string = "visits"`.

- Only fields marked `mutable` can be updated.
- The `name` field is immutable.
- Trying to write `c.name <- "x"` would be a compile error.
- `<-` is the field-assignment operator.

:::

Marking *just* the fields that change makes design intent visible
right at the type. A reader sees `mutable n : int` and knows the
counter's number changes; they see `name : string` (no `mutable`)
and know the label does not. The constraint is checked by the
compiler: any code that tries to assign to `name` is rejected.

```ocaml
type buffer = {
  capacity : int;            (* fixed at creation *)
  mutable size : int;        (* changes as we push *)
  mutable contents : string  (* changes as we push *)
}
```

In a record like this, the type declaration is part of the
documentation. The capacity is set once; the size and contents
update as the buffer fills.

:::slide

## Why some fields mutable and others not

- Marking just the fields that change makes **design intent
  visible**.
- A `counter` with `mutable n` but immutable `name` says: "the
  number changes; the label does not".
- Anyone reading the type can tell from the declaration.

```ocaml
type buffer = {
  capacity : int;        (* fixed at creation *)
  mutable size : int;    (* changes as we push *)
  mutable contents : string  (* changes as we push *)
}
```

- The type declaration documents what's allowed to change.

:::

## Arrays

An *array* is a fixed-size, mutable sequence of values, all of the
same type. The literal syntax uses bar-brackets:

```ocaml
let a = [| 10; 20; 30; 40; 50 |]

let _ = a.(0)
let _ = a.(2)
let () = a.(2) <- 999
let _ = a
```

The toplevel reports `int = 10` for `a.(0)`, `int = 30` for
`a.(2)`, then `int array = [|10; 20; 999; 40; 50|]` for `a` after
the assignment.

A few syntactic things to note:

- Array literals are `[| e0; e1; ...; en |]`, with semicolons
  between elements. The bars distinguish them from lists, which
  use plain brackets.
- Indexing is `a.(i)`. The parentheses are mandatory; this is not
  the dot you use for records.
- Assignment is `a.(i) <- value`, the same `<-` operator we just
  saw on records.
- Indexing is zero-based.
- Out-of-bounds access raises the standard exception
  `Invalid_argument` (we cover exceptions in the
  [next lecture](M07-L03-exceptions.html)).

:::slide

## Arrays

A fixed-size, mutable sequence:

```ocaml
let a = [| 10; 20; 30; 40; 50 |]

let _ = a.(0)
let _ = a.(2)
let () = a.(2) <- 999
let _ = a
```

`int = 10`, `int = 30`, then `int array = [|10; 20; 999; 40; 50|]`.

- Array literals use `[| ... |]` with `;` separators.
- Indexing uses `a.(i)`.
- Assignment uses `a.(i) <- value`.
- Out-of-bounds access raises `Invalid_argument`.
- Arrays are *zero-indexed*, like lists.

:::

Why use array notation `a.(i)` instead of square brackets `a[i]`
like C, Java, or Python? Square brackets are already taken by list
syntax (`[1; 2; 3]`), and the language designers wanted indexing
to look syntactically distinct from list construction. The
parenthesised dot form was the result. The compiler treats
`a.(i)` and `a.(i) <- v` as primitive operations: there is no
function call overhead and they compile to direct array loads and
stores.

## Lists vs arrays

The choice between a list and an array is a recurring question.
The two have different cost profiles and different relationships
to immutability.

| | `'a list` | `'a array` |
| --- | --- | --- |
| Indexed access | O(n) | O(1) |
| Cons / prepend | O(1) | not direct |
| Append / extend | O(n) | not direct |
| Immutable | yes | no |
| Length fixed | no | yes |
| Sharing tails | yes | no |
| Equational reasoning | yes | no for mutated cells |

The standard trade-off is between O(1) random access (arrays) and
O(1) prepending plus immutability (lists). If your computation
walks the data front to back, building up a result as it goes, a
list is usually the more natural shape; we have seen this all
through [Module 5](M05-L01-basic-patterns.html) and
[Module 6](M06-L01-functions-revisited.html). If your computation
needs to *jump* to arbitrary positions, an array is the right tool.

:::slide

## Array vs list: a trade-off table

| | `'a list` | `'a array` |
| --- | --- | --- |
| Indexed access | O(n) | O(1) |
| Cons / prepend | O(1) | not direct |
| Append / extend | O(n) | not direct |
| Immutable | yes | no |
| Length fixed | no | yes |
| Sharing tails | yes | no |
| Equational reasoning | yes | no for mutated cells |

- **Arrays**: fast random access; **lists**: front-to-back + immutability.
- Dynamic size + indexed access: reach for `Dynarray` or `Buffer`.

:::

Neither structure is good for "dynamically growing with fast
indexed access." For that, OCaml 5.2 introduced `Dynarray`, a
resizable array akin to C++'s `std::vector` or Java's `ArrayList`;
for byte-string building, there is `Buffer`. We will not use
either in this course, but it is good to know what your options
are when you outgrow the trade-off above.

## Allocating arrays

You rarely write a large array as a literal. The standard library
gives you three workhorse constructors.

```ocaml
let _ = Array.make 5 0
let _ = Array.init 5 (fun i -> i * i)
let _ = Array.of_list [10; 20; 30]
```

`Array.make n x` allocates an array of length `n` with every
element initialised to `x`. `Array.init n f` allocates an array of
length `n` where element `i` is computed by calling `f i`.
`Array.of_list` converts an existing list into an array.

:::slide

## Building an array

```ocaml
let _ = Array.make 5 0
let _ = Array.init 5 (fun i -> i * i)
let _ = Array.of_list [10; 20; 30]
```

`[|0; 0; 0; 0; 0|]`, `[|0; 1; 4; 9; 16|]`, `[|10; 20; 30|]`.

- `Array.make n x` creates an array of length `n` with every
  element `x`.
- `Array.init n f` creates an array where element `i` is `f i`.
- `Array.of_list xs` converts a list to an array.

:::

`Array.init` is the one to remember: it is the array equivalent
of writing a list comprehension or a generator. Given a length and
a function from index to value, it allocates the array and runs
the function on each index. You do *not* see the function called
in a particular order, but in practice it is `0, 1, ..., n-1`.

## Iterating arrays

The [`Array`](https://v2.ocaml.org/api/Array.html) module mirrors
the [higher-order functions we have seen on lists](M06-L01-functions-revisited.html).
`Array.iter` is the side-effecting walk;
[`Array.map`](M06-L02-map.html) returns a new array; there are also
[`fold_left`, `fold_right`](M06-L04-fold.html), `length`,
`to_list`, and the obvious shape-shifters.

```ocaml
let a = [|10; 20; 30|]

let () = Array.iter (fun x -> print_endline (string_of_int x)) a
```

This prints `10`, `20`, `30` on separate lines. `Array.iter`
returns `unit`; it is for *effect*, not for value.

For a pure transformation that does not mutate the input, use
`Array.map`:

```ocaml
let a = [|10; 20; 30|]
let b = Array.map (fun x -> x * 2) a
let _ = b
let _ = a
```

`b` is `[|20; 40; 60|]`; `a` is unchanged at `[|10; 20; 30|]`.
`Array.map` allocates a new array. If you want to update the
input in place, use `Array.iteri` and write back explicitly, or
use the loop syntax we are about to see.

:::slide

## Iterating arrays

```ocaml
let a = [|10; 20; 30|]

let () = Array.iter (fun x -> print_endline (string_of_int x)) a
```

Prints 10, 20, 30 on separate lines.

- `Array.iter` is the **side-effecting walk**.
- The function returns unit.

For a pure transformation:

```ocaml
let b = Array.map (fun x -> x * 2) a
let _ = b
```

`int array = [|20; 40; 60|]`.

- `Array.map` returns a *new* array; the input is untouched.
- Other useful functions: `Array.fold_left`, `Array.length`,
  `Array.to_list`, etc.

:::

## OCaml's for and while loops

OCaml has imperative loops, and they live in the language
precisely to go with arrays and mutation. They are not the *only*
way to write iteration, and (as we have insisted all course) they
are not the default; but when you reach for an array, you usually
reach for a loop alongside it.

The two forms:

```ocaml skip
for i = lo to hi do
  body
done

for i = hi downto lo do
  body
done

while condition do
  body
done
```

`for i = lo to hi do body done` runs `body` once for each `i` from
`lo` to `hi` *inclusive*. The variable `i` is in scope inside the
body. `for i = hi downto lo do body done` is the reverse. `while
condition do body done` runs the body repeatedly while the
condition is true. All three are *expressions* of type `unit`.

The body must itself be of type `unit`. A loop whose body returns
some other type triggers a warning, the same way a sequence does:
the value is being discarded.

## A typical use: counting characters

Here is the kind of code where arrays earn their keep. Suppose
you want to count how many times each character appears in a
string. You make an array of length 256, indexed by character
code, mutate it as you scan the string.

```ocaml
let count_chars s =
  let counts = Array.make 256 0 in
  String.iter
    (fun c -> counts.(Char.code c) <- counts.(Char.code c) + 1)
    s;
  counts

let _ =
  let c = count_chars "hello" in
  (c.(Char.code 'l'), c.(Char.code 'o'))
```

The toplevel reports `(2, 1)`: two 'l's, one 'o'. The shape of
the algorithm is exactly what an imperative loop in C would do:
walk through the input, indexing by the current character into a
fixed-size table, incrementing the counter.

:::slide

## A typical use: counting

Count how many times each character appears in a string:

```ocaml
let count_chars s =
  let counts = Array.make 256 0 in
  String.iter
    (fun c -> counts.(Char.code c) <- counts.(Char.code c) + 1)
    s;
  counts

let _ =
  let c = count_chars "hello" in
  (c.(Char.code 'l'), c.(Char.code 'o'))
```

`(2, 1)`. Two 'l's, one 'o'.

- An array is the right shape here: **indexed by character code,
  mutated in place** during the scan.
- This is what an imperative loop in C looks like, translated to
  OCaml.
- We use mutation because the natural shape of the algorithm is
  "step through the input, update this counter table".

:::

Could you do this without mutation? Yes: walk the string with a
fold, building up a 256-tuple or a `Map`, returning a new structure
at each step. It would be much slower and much longer to read.
This is exactly the case where mutation is the right tool.

## When you do not want mutation

For most everyday list-shaped work, a [fold](M06-L04-fold.html) or
[map](M06-L02-map.html) is clearer than an array-and-loop.

```ocaml
let sum_lst xs = List.fold_left (+) 0 xs

let sum_arr a =
  let s = ref 0 in
  Array.iter (fun x -> s := !s + x) a;
  !s

let _ = sum_lst [1;2;3;4;5]
let _ = sum_arr [|1;2;3;4;5|]
```

Both compute `15`. The first version is one line and produces no
intermediate mutable state. The second version is three lines and
needs a `ref`. (You could also write the second with
`Array.fold_left (+) 0 a`, which is again one line.)

:::slide

## When you don't want mutation

For most everyday list-shaped work, a fold or map is clearer than
an array-and-loop:

```ocaml
let sum_lst xs = List.fold_left (+) 0 xs

let sum_arr a =
  let s = ref 0 in
  Array.iter (fun x -> s := !s + x) a;
  !s

let _ = sum_lst [1;2;3;4;5]
let _ = sum_arr [|1;2;3;4;5|]
```

Both give `15`.

- The fold version is **one line**.
- The array version is **three lines with a `ref`**.
- Reach for arrays only when you actually need the indexed-access
  or fixed-size properties.

:::

The discipline is the same as for `ref`: reach for arrays when
the algorithm wants random-access mutation. If your algorithm is
"walk the data and accumulate a result," a fold is clearer.

## A quick check

:::quiz mcq id=M07-L02-q3
What does the following expression evaluate to?

```ocaml
let a = [|1; 2; 3; 4; 5|] in
a.(2) <- 99;
a.(0) + a.(2) + a.(4)
```

- [ ] `9`
- [x] `105`
- [ ] `108`
- [ ] `Invalid_argument`

**Why:** the assignment changes `a.(2)` from `3` to `99`. The
sum is `1 + 99 + 5 = 105`.
:::

:::quiz mcq id=M07-L02-q2
What is the type of `Array.make 5 0.0`?

- [ ] `int array`
- [x] `float array`
- [ ] `int * float`
- [ ] `float`

**Why:** `Array.make` has type `int -> 'a -> 'a array`. The length
`5` is the first argument; the initial value `0.0` is the second.
The inferred type of `'a` is `float`, so the result is
`float array`.
:::

## Activity

:::slide

## Activity

Write `reverse_in_place : 'a array -> unit` that reverses an array
in place. After calling it, the array's contents are reversed.

:::

:::quiz code id=M07-L02-q1
Write `reverse_in_place` that reverses an array in place.

```ocaml
let reverse_in_place a =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  let a = [|1; 2; 3; 4; 5|] in
  reverse_in_place a;
  check (a = [|5; 4; 3; 2; 1|]) "five elements";
  let b = [|1; 2; 3; 4|] in
  reverse_in_place b;
  check (b = [|4; 3; 2; 1|]) "four elements";
  let c = [||] in
  reverse_in_place c;
  check (c = [||]) "empty array";
  let d = [|42|] in
  reverse_in_place d;
  check (d = [|42|]) "singleton";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution: the classic two-pointer swap.

```ocaml
let reverse_in_place a =
  let n = Array.length a in
  for i = 0 to (n / 2) - 1 do
    let j = n - 1 - i in
    let tmp = a.(i) in
    a.(i) <- a.(j);
    a.(j) <- tmp
  done
```

:::

:::slide

## Activity solution

```ocaml
let reverse_in_place a =
  let n = Array.length a in
  for i = 0 to (n / 2) - 1 do
    let j = n - 1 - i in
    let tmp = a.(i) in
    a.(i) <- a.(j);
    a.(j) <- tmp
  done

let a = [|1; 2; 3; 4; 5|]
let () = reverse_in_place a
let _ = a
```

`[|5; 4; 3; 2; 1|]`.

- Returns `unit`; effect is to mutate `a`.
- **Two-pointer reverse:** swap `a.(i)` and `a.(n-1-i)`, halfway.
- `for ... to ... do ... done`: OCaml's imperative loop.

:::

:::slide

## Destructive vs immutable

- The in-place version *loses* the original ordering of `a`.
- Immutable alternative: `Array.of_list (List.rev (Array.to_list a))`.
- Or simpler: keep the data as a list and use `List.rev` directly.

:::

A few things worth noticing in the solution. The loop runs to
`n / 2 - 1` rather than `n - 1`: each iteration swaps two
positions, so we only need to walk halfway through. For an array
of odd length, the middle element is its own mirror and stays in
place. The function returns `unit`; its observable effect is the
mutation. This is the standard signature pattern for in-place
operations: the function returns `unit` and the caller passes in
the structure to be modified.

If you want an immutable reverse instead, the right path is
usually `Array.of_list (List.rev (Array.to_list a))`, or simpler,
keep the data as a list in the first place.

## What's next

The [next lecture](M07-L03-exceptions.html) covers *exceptions*,
the third member of the imperative trio (alongside refs and arrays).
Exceptions let you signal "something went wrong" without threading
an [option or result](M04-L05-option-and-aliases.html) through every
layer of code. After that,
Lectures [4](M07-L04-module-basics.html) through
[6](M07-L06-functors.html) turn to *modules* and the way OCaml
organizes code at scale.

:::slide

## What's next

Lecture 3: **exceptions**.

- The other major form of "side effect" in OCaml.
- They let you signal "something went wrong" without threading an
  option / result through every layer of code.

:::

## Reading

- **Cornell CS3110**, *Arrays*:
  <https://cs3110.github.io/textbook/chapters/mut/arrays.html>
- **Cornell CS3110**, *Mutable fields*:
  <https://cs3110.github.io/textbook/chapters/mut/mutable_fields.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
