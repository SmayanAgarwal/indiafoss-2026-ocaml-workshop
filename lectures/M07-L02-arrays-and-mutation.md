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

Beyond the single-cell `ref`, OCaml has two more mutable building
blocks: **records with mutable fields** and **fixed-size arrays**.
This lecture covers both, and the decision of when in-place
mutation is worth giving up immutability for.

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

Only fields marked `mutable` can be updated. The `name` field is
immutable; trying to write `c.name <- "x"` would be a compile
error.

The `<-` is the field-assignment operator.

:::

:::slide

## Why some fields mutable and others not

Marking just the fields that change makes the design intent
visible. A `counter` with `mutable n` but immutable `name` says:
"the number changes; the label does not". Anyone reading the type
can tell from the declaration.

```ocaml
type buffer = {
  capacity : int;        (* fixed at creation *)
  mutable size : int;    (* changes as we push *)
  mutable contents : string  (* changes as we push *)
}
```

The type declaration documents what's allowed to change.

:::

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

Arrays are *zero-indexed*, like lists.

:::

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

Use **arrays** when you need fast random access by index and the
size is fixed.

Use **lists** when you're traversing front-to-back and want
immutability.

For *dynamic-size, indexed access*, neither is great; reach for
`Dynarray` (added in OCaml 5.2) or `Buffer` (for byte strings).

:::

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

:::slide

## Iterating arrays

```ocaml
let a = [|10; 20; 30|]

let () = Array.iter (fun x -> print_endline (string_of_int x)) a
```

Prints 10, 20, 30 on separate lines. `Array.iter` is the
side-effecting walk; the function returns unit.

For a pure transformation:

```ocaml
let b = Array.map (fun x -> x * 2) a
let _ = b
```

`int array = [|20; 40; 60|]`. `Array.map` returns a *new* array;
the input is untouched.

There's also `Array.fold_left`, `Array.length`, `Array.to_list`,
etc.

:::

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

`(2, 1)`. Two 'l's, one 'o'. An array is the right shape: indexed
by character code, mutated in place during the scan.

This is what an imperative loop in C looks like, translated to
OCaml. We use mutation because the natural shape of the algorithm
is "step through the input, update this counter table".

:::

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

Both give `15`. The fold version is one line; the array version is
three lines with a `ref`. Reach for arrays only when you actually
need the indexed-access or fixed-size properties.

:::

:::slide

## Activity

Write `reverse_in_place : 'a array -> unit` that reverses an array
in place. After calling it, the array's contents are reversed.

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

`[|5; 4; 3; 2; 1|]`. The function returns `unit`; its effect is to
mutate `a`.

The classic two-pointer reverse: swap element at index `i` with
the one at `n - 1 - i`, for `i` from `0` to halfway through. The
`for ... to ... do ... done` is OCaml's standard imperative loop;
it's pretty much only used in arrays-and-mutation code.

Note this is *destructive*. The original list of values is lost.
For an immutable reverse, prefer `Array.of_list (List.rev (Array.to_list a))`
or just keep it as a list.

:::

:::slide

## What's next

Lecture 3: **exceptions**. The other major form of "side effect"
in OCaml. They let you signal "something went wrong" without
threading an option / result through every layer of code.

:::

## Reading

- **Cornell CS3110**, *Arrays*:
  <https://cs3110.github.io/textbook/chapters/mut/arrays.html>
