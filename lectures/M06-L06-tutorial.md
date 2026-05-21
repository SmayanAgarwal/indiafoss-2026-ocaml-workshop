---
title: "Tutorial: rebuild parts of `List`"
lecture_no: 6
week: 6
duration_target_min: 28
concepts: [worked higher-order, reimplement standard library, fold-everywhere, composition]
keywords: [OCaml, List, tutorial, higher-order, rebuild]
activity_question: "Write [maximum : 'a list -> 'a option] that returns the largest element of a list, or [None] if empty. Express it using [List.fold_left]."
think_about_this: "Almost every concrete list function can be written in terms of [fold_left] or [fold_right]. Why aren't they written that way in the standard library? What would you lose if they were?"
reading:
  - title: "Cornell CS3110, Re-implementing the List module"
    url: https://cs3110.github.io/textbook/chapters/hop/fold.html
---

# Tutorial: rebuild parts of `List`


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Tutorial: rebuild parts of `List`</h2>
<p class="title-slide-label">Module 6 &middot; Lecture 6</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

This lecture is the worked-exercise capstone of Module 6. Across the
previous five lectures we built up a small but powerful toolkit:
[higher-order functions](M06-L01-functions-revisited.html),
[`map`](M06-L02-map.html), [`filter`](M06-L03-filter.html),
[`fold_left` and `fold_right`](M06-L04-fold.html), the
[pipeline operator `|>`, and function composition](M06-L05-pipelines.html).
The thesis of this module has been that this small toolkit is enough
to express a surprising amount of list processing without writing a
single hand-coded recursion. In this tutorial we try to make good on
that claim: pick a list function from the standard library, then
build it from the toolkit.

The point of the exercise is not that you should always re-derive
standard library functions in real code; you should not. Use
`List.length` rather than `List.fold_left (fun n _ -> n + 1) 0`,
because the standard library version expresses intent more clearly
and is usually faster. The point is to *see how versatile the
toolkit is*: how few primitives you need before the rest follows. By
the end of this lecture, if I asked you to write a new list-flavoured
function on the spot, you should reach for `map`, `filter`, or
`fold` first.

We will work through eight problems, increasing in subtlety.

## Problem 1: `length`

Given a list, return how many elements it has.

```ocaml
let length xs = List.fold_left (fun n _ -> n + 1) 0 xs

let _ = length [10; 20; 30; 40]
```

:::slide

## Problem 1: `length`

```ocaml
let length xs = List.fold_left (fun n _ -> n + 1) 0 xs

let _ = length [10; 20; 30; 40]
```

`int = 4`.

- Ignore the element; bump the counter.
- Tail-recursive, constant stack.

:::

The fold's accumulator is the running count, starting at `0`. The
combining function ignores the element (we wrote `_` to make that
explicit) and adds one to the accumulator. Tail-recursive, constant
stack.

Notice we did not write `match xs with [] -> 0 | _ :: t -> 1 +
length t`. The hand-written recursion works fine, but it is *not*
[tail-recursive](M03-L04-tail-recursion.html) and would overflow the
stack on very long lists. The fold version is automatically
tail-recursive. This is one of the small wins of using the
higher-order toolkit: you get the safe recursion shape for free.

## Problem 2: `sum` and `product`

```ocaml
let sum xs = List.fold_left (+) 0 xs

let _ = sum [1; 2; 3; 4; 5]
```

:::slide

## Problem 2: `sum`

```ocaml
let sum xs = List.fold_left (+) 0 xs

let _ = sum [1; 2; 3; 4; 5]
```

`int = 15`.

- `+` is the combining function.
- `0` is the starting accumulator.

Same shape for `product`:

```ocaml
let product xs = List.fold_left ( * ) 1 xs

let _ = product [1; 2; 3; 4; 5]
```

`int = 120`.

- Accumulator starts at `1` (identity for multiplication).

:::

`sum` is the canonical fold: pass the operator `(+)` and the
identity element for the operator (`0`). For `product`, the operator
is `( * )` and the identity is `1`. The general pattern: any
associative binary operator with an identity element gives you a
one-line fold-based aggregation.

(Why does the identity element matter? Because of the empty-list
case. `fold_left (+) 0 []` returns `0`; `fold_left ( * ) 1 []`
returns `1`. Picking the identity makes those answers consistent
with the mathematical convention that an empty sum is zero and an
empty product is one.)

## Problem 3: `rev`

Reverse a list.

```ocaml
let rev xs = List.fold_left (fun acc x -> x :: acc) [] xs

let _ = rev [1; 2; 3; 4]
```

:::slide

## Problem 3: `rev`

```ocaml
let rev xs = List.fold_left (fun acc x -> x :: acc) [] xs

let _ = rev [1; 2; 3; 4]
```

`[4; 3; 2; 1]`.

- Prepend each element to the accumulator.
- Left-to-right traversal + prepending: first element ends up *deepest*.
- Result is reversed.

:::

The trick: walk the list left to right, but cons each element onto
the *front* of the accumulator. The first element processed (`1`)
ends up the deepest cons cell; the last (`4`) is on top. Reversed.

This is the standard library's `List.rev`. The combining function is
`fun acc x -> x :: acc`. If you want the original order back, use
`List.fold_right (fun x acc -> x :: acc) xs []`, which walks
right-to-left and rebuilds the list in order. (That is the identity
fold we discussed in [Lecture 4](M06-L04-fold.html#what-foldright-computes):
replace `::` with `::` and `[]` with `[]`.)

## Problem 4: `map` (via `fold_right`)

Rebuild `map` itself.

```ocaml
let map f xs =
  List.fold_right (fun x acc -> f x :: acc) xs []

let _ = map (fun n -> n * n) [1; 2; 3; 4]
```

:::slide

## Problem 4: `map` (via fold_right)

```ocaml
let map f xs =
  List.fold_right (fun x acc -> f x :: acc) xs []

let _ = map (fun n -> n * n) [1; 2; 3; 4]
```

`[1; 4; 9; 16]`.

- `fold_right` walks right-to-left.
- Cons-order matches the original order.
- Combining function: take `x`, apply `f`, cons onto the running list.

Same with `fold_left + rev`:

```ocaml
let map_tail f xs =
  List.rev (List.fold_left (fun acc x -> f x :: acc) [] xs)

let _ = map_tail (fun n -> n * n) [1; 2; 3; 4]
```

Two passes, but tail-recursive.

:::

The `fold_right` version walks right-to-left, so consing onto the
accumulator naturally preserves order. It is not tail-recursive,
which is fine for small lists and matches the standard library's
`List.map` behaviour. The `fold_left + rev` version is
tail-recursive but makes two passes.

It is worth pausing here: we have just rebuilt [`map`](M06-L02-map.html),
one of the three pillars of this module, from `fold_right`. This is
a small but real piece of evidence for the claim that `fold` is the
most general of the three: anything `map` does, `fold` can do too.

## Problem 5: `filter` (via `fold_right`)

```ocaml
let filter p xs =
  List.fold_right
    (fun x acc -> if p x then x :: acc else acc)
    xs []

let _ = filter (fun n -> n mod 2 = 0) [1; 2; 3; 4; 5; 6]
```

:::slide

## Problem 5: `filter` (via fold_right)

```ocaml
let filter p xs =
  List.fold_right
    (fun x acc -> if p x then x :: acc else acc)
    xs []

let _ = filter (fun n -> n mod 2 = 0) [1; 2; 3; 4; 5; 6]
```

`[2; 4; 6]`.

- For each element, decide whether to include it.
- Combining function picks either `x :: acc` or `acc`.

:::

The combining function chooses, per element, whether to include `x`
in the accumulator or to drop it. We have now rebuilt the second
pillar from `fold`. We could keep going (concat, take, drop,
zip, ...). Almost every list-shaped function in the standard library
is some specialised fold.

## Problem 6: `concat`

Flatten a list of lists into a single list. (Also called `flatten`
in some libraries.)

```ocaml
let concat xss =
  List.fold_right (fun xs acc -> xs @ acc) xss []

let _ = concat [[1; 2]; [3; 4; 5]; [6]]
```

:::slide

## Problem 6: `concat`

Flatten a list of lists into a single list.

```ocaml
let concat xss =
  List.fold_right (fun xs acc -> xs @ acc) xss []

let _ = concat [[1; 2]; [3; 4; 5]; [6]]
```

`[1; 2; 3; 4; 5; 6]`.

- `@` is list-append.
- Fold over the outer list; append each inner list to the accumulator.
- `O(n)` in total length, but builds up garbage from intermediate appends.
- For very long inputs, `List.concat` from the standard library is
  more efficient.

:::

The operator `@` is list-append. Each inner list is appended to the
accumulator; the rightmost inner list ends up at the back, the
leftmost at the front. Note the use of `fold_right` rather than
`fold_left`: with `fold_left`, the accumulator would build up
backwards because we would append the *first* inner list last.
(Try it on paper if it is not obvious why.) `fold_right` walks
right-to-left, so the leftmost inner list is the last one prepended,
and ends up at the front of the result.

The standard library's `List.concat` is similar but optimised for
the common case.

## Problem 7: `for_all` and `exists`

Two list predicates.

```ocaml
let for_all p xs = List.fold_left (fun acc x -> acc && p x) true xs

let exists p xs = List.fold_left (fun acc x -> acc || p x) false xs

let _ = for_all (fun n -> n > 0) [1; 2; 3]
let _ = for_all (fun n -> n > 0) [1; -2; 3]
let _ = exists (fun n -> n < 0) [1; -2; 3]
```

:::slide

## Problem 7: `for_all` and `exists`

```ocaml
let for_all p xs = List.fold_left (fun acc x -> acc && p x) true xs

let exists p xs = List.fold_left (fun acc x -> acc || p x) false xs

let _ = for_all (fun n -> n > 0) [1; 2; 3]
let _ = for_all (fun n -> n > 0) [1; -2; 3]
let _ = exists (fun n -> n < 0) [1; -2; 3]
```

`true`, `false`, `true`.

- `for_all`: accumulator starts `true`; an element with `p x = false`
  drags the whole `&&` to false.
- `exists`: accumulator starts `false`; a passing element flips the
  `||` to true.
- These don't short-circuit: fold visits every element.
- The standard library's `List.for_all` / `List.exists` do
  short-circuit; prefer those for long lists with early failure.

:::

`for_all p xs` is `true` if every element satisfies `p`; `exists p
xs` is `true` if at least one does. The two fold-based
implementations use `&&` and `||` respectively, with the appropriate
identity (`true` for AND, `false` for OR).

A subtlety: these implementations *do not short-circuit*. The fold
visits every element of the list, even if the answer is already
determined. The standard library's `List.for_all` and `List.exists`
are written directly and *do* short-circuit (returning `false` as
soon as an element fails `for_all`, returning `true` as soon as one
succeeds in `exists`). For long lists where failure or success
arrives early, the standard library is faster. Another reason to
prefer the library version over the home-rolled fold one in real
code.

## Problem 8: `count`

Count how many elements satisfy a predicate.

```ocaml
let count p xs =
  List.fold_left (fun n x -> if p x then n + 1 else n) 0 xs

let _ = count (fun n -> n > 0) [-1; 5; -3; 8; 0; 2]
```

:::slide

## Problem 8: `count`

How many elements satisfy a predicate?

```ocaml
let count p xs =
  List.fold_left (fun n x -> if p x then n + 1 else n) 0 xs

let _ = count (fun n -> n > 0) [-1; 5; -3; 8; 0; 2]
```

`int = 3`.

- Three positive elements.
- Accumulator counts; combining function bumps on a passing element.
- Alternative: `List.length (List.filter p xs)`.
- Fold version is one pass, no intermediate list.

:::

The result is `3` (the three strictly positive elements: `5`, `8`,
`2`). We could have written this as `List.length (List.filter p
xs)`: filter to keep the passing elements, then count. The
two-step version is arguably clearer; the fold version makes one
pass and never allocates the intermediate list. For short lists this
does not matter; for long ones the fold version saves both time and
garbage.

## A wider example: word frequencies

Let us combine pieces from across the module into a slightly larger
example. We count how often each word appears in a piece of text.
We will return the answer as an *association list* (a list of
pairs); in [Module 7](M07-L06-functors.html) we will see proper hash
tables and balanced maps.

```ocaml
let word_counts text =
  text
  |> String.lowercase_ascii
  |> String.split_on_char ' '
  |> List.filter (fun s -> s <> "")
  |> List.fold_left (fun counts w ->
       let n = try List.assoc w counts with Not_found -> 0 in
       (w, n + 1) :: List.remove_assoc w counts
     ) []

let _ = word_counts "the quick brown fox jumps over the lazy dog the fox"
```

The result is something like `[("fox", 2); ("dog", 1); ("lazy", 1);
("over", 1); ("jumps", 1); ("brown", 1); ("quick", 1); ("the", 3)]`
(the exact ordering depends on the fold's traversal).

The pipeline reads top-to-bottom: lowercase, split into words, drop
empty pieces, then fold to build up a frequency table. The fold's
accumulator is an association list of word/count pairs; for each
word, we look up its current count (or 0 if absent), remove the old
entry, and prepend a new one with the bumped count.

This is the kind of code that, in Python or Java, would take a
small loop with a hash table. In OCaml with the higher-order
toolkit, it is a single pipeline. The trade-off is that this
implementation is `O(n^2)` in the number of distinct words (each
`List.assoc` and `List.remove_assoc` is linear); the proper solution
uses `Map` or `Hashtbl`, which we will meet in
[Module 7](M07-L06-functors.html). For now, the point is that the
*shape* of the computation is captured cleanly.

## A quick check

:::quiz mcq id=M06-L06-q3
Which of the following is *not* expressible as a fold over a single list?

- [ ] `List.length`
- [ ] `List.filter p`
- [ ] `List.map f`
- [x] `List.sort compare`

**Why:** `length`, `filter`, and `map` are all linear walks of the
list with an accumulator. They are folds. Sorting (`List.sort`) is
`O(n log n)`: it cannot be expressed as a single left-to-right fold
that examines each element once. A fold has to compare elements that
are far apart, which a single linear pass cannot do. (You can
*implement* a sorting algorithm using fold inside a more complex
construction, but the sort itself is not a fold.)
:::

:::quiz mcq id=M06-L06-q2
`List.fold_left (fun acc x -> x :: acc) [] [1; 2; 3]` is...

- [ ] `[1; 2; 3]`
- [x] `[3; 2; 1]`
- [ ] `[]`
- [ ] An error.

**Why:** `fold_left` walks left to right. Initial `acc = []`. After
`1`: `[1]`. After `2`: `[2; 1]`. After `3`: `[3; 2; 1]`. So this is
the classic one-line `List.rev`. To get back the original order, use
`fold_right` (which walks right-to-left).
:::

A code challenge:

:::quiz code id=M06-L06-q1
Write `maximum : 'a list -> 'a option` that returns the largest
element of a list, or `None` for an empty list. Use `List.fold_left`
with the `compare` function or `max`. (Hint: the accumulator is an
`'a option`.)

```ocaml
let maximum xs =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (maximum [3; 7; 1; 9; 5]      = Some 9)   "ints";
  check (maximum ([] : int list)      = None)     "empty";
  check (maximum [42]                 = Some 42)  "singleton";
  check (maximum [-5; -3; -1; -10]    = Some (-1)) "all negative";
  check (maximum ["a"; "c"; "b"]      = Some "c") "strings";
  print_endline "all tests passed"
```
:::

Reference solution:

```
let maximum xs =
  List.fold_left
    (fun acc x ->
      match acc with
      | None -> Some x
      | Some m -> Some (max m x))
    None xs
```

The accumulator is an `'a option`, starting at `None`. For each
element: if the accumulator is `None`, take this element as the
current best. If it is `Some m`, compare and keep the bigger. The
result is `None` if the list was empty, `Some v` otherwise.

## Activity

:::slide

## Activity

Write `maximum : 'a list -> 'a option` returning the largest
element of a list, or `None` if empty. Use `List.fold_left`.

:::

:::slide

## Activity solution

```ocaml
let maximum xs =
  List.fold_left
    (fun acc x ->
      match acc with
      | None -> Some x
      | Some m -> Some (max m x))
    None xs

let _ = maximum [3; 7; 1; 9; 5]
let _ = maximum ([] : int list)
```

`Some 9`, `None`.

- Accumulator is an `int option`.
- Starts at `None` (no element seen yet).
- For each element: if `None`, take this element; otherwise keep the larger.
- `([] : int list)` annotation is needed: `[]` alone is polymorphic
  and OCaml needs to pick a type.

:::

## What you should be able to do now

By the end of Module 6 you should be able to:

- Recognise a higher-order function (one that takes or returns a
  function) and read its type fluently.
- Reach for `List.map` whenever you have "transform each element of
  a list."
- Reach for `List.filter` whenever you have "drop elements that fail
  a test," and for `List.filter_map` when you also want to transform.
- Reach for `List.fold_left` / `List.fold_right` when the answer
  is not a list, or when you need both summary and transformation in
  one pass.
- Chain operations with `|>` pipelines, top-to-bottom.
- Recognise when the standard library already has a function for
  the job (it almost always does).

:::slide

## What you should be able to do now

After Module 6 you can:

- Write functions that take or return other functions.
- Use `List.map` to transform every element of a list.
- Use `List.filter` to keep elements that pass a predicate.
- Use `List.fold_left` / `List.fold_right` to reduce a list to any
  value.
- Chain operations with `|>` pipelines.
- Recognize when the standard library has a function for the job.

What's coming up:

- [Module 7](M07-L01-references.html): side effects (`ref`, mutation, exceptions) and **modules** (the OCaml language feature, not the NPTEL kind).
- [Module 8](M08-L01-sequencing.html): monads and GADTs.

:::

## What's next

[Module 7](M07-L01-references.html) is a turn back toward the
imperative side of OCaml: *side effects* (mutable references,
exceptions, `Printf`), and *modules* (the OCaml language feature for
organising code into named, type-bearing units). Higher-order
functions remain in play throughout; we will see them again in
Module 7 in the form of references that hold functions and in
[Module 8](M08-L02-option-monad.html) in the form of monads, where
the whole programming pattern is built on higher-order composition.

## Reading

- **Cornell CS3110**, *Fold (re-implementing the List module)*:
  <https://cs3110.github.io/textbook/chapters/hop/fold.html>
- **John Hughes**, *Why Functional Programming Matters*: the
  classic case for the higher-order style and how it scales:
  <https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
