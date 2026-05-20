---
title: "Recursive types: lists, trees, expressions"
lecture_no: 4
week: 4
duration_target_min: 25
concepts: [recursive types, list, tree, ADT, expression trees, structural induction]
keywords: [OCaml, recursive types, list, tree, ADT, expression]
activity_question: "Define [type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree]. Write [size : 'a tree -> int] that counts the number of Node constructors."
think_about_this: "If you compare a value of type [int list] and a value of type [int tree], can [=] tell them apart? What property of structural equality lets one operator handle both?"
reading:
  - title: "Cornell CS3110, Lists"
    url: https://cs3110.github.io/textbook/chapters/data/lists.html
  - title: "Cornell CS3110, Trees"
    url: https://cs3110.github.io/textbook/chapters/data/trees.html
---

# Recursive types

A variant becomes much more interesting when one of its constructors
carries a value of *the same type* being defined. That single
self-reference is what makes it possible to describe data of
*unbounded size* with a *fixed* type declaration: lists of any
length, trees of any depth, arithmetic expressions of any
complexity. This lecture covers the canonical recursive shapes,
how OCaml encodes them, and how to walk them with recursive
functions.

We have already met recursion at the *function* level
([M03-L02](M03-L02-recursion.html)). This lecture connects it
with recursion at the *type* level. The two go together: a
recursive type asks for a recursive function to process it, and
the structural shape of the recursion mirrors the shape of the
type. Once you see the connection, writing functions on recursive
data becomes almost mechanical.

[Module 5](M05-L01-basic-patterns.html) will lean heavily on
this: pattern matching on recursive variants is the everyday tool
for processing structured data.
[Module 6](M06-L02-map.html) generalises with higher-order
combinators like `map` and [`fold`](M06-L04-fold.html). The
foundation, the *types themselves*, is what we introduce now.

## Lists are a recursive variant

You have been using lists since
[Module 3](M03-L02-recursion.html#recursion-on-lists). We will
now look at how they are *defined*. Conceptually:

```
type 'a list =
  | []
  | (::) of 'a * 'a list
```

This is essentially how OCaml's standard library defines `list`,
with one syntactic concession: the constructor names `[]` and `::`
have built-in syntactic sugar (you can write `[1; 2; 3]` instead of
`1 :: 2 :: 3 :: []`, and you can write `::` as an infix operator).
Modulo that sugar, `list` is a normal recursive variant.

A value of type `'a list` is one of two shapes:

- `[]`: the empty list.
- `x :: rest`: an element `x` (of type `'a`) *prepended to* another
  `'a list` named `rest`.

The recursion is in the second constructor: the cons cell carries
a tail, which is itself a list, which can itself be empty or
another cons cell, and so on, for as long as you want. That single
self-reference is how lists of arbitrary length fit in a type
declaration of two cases.

:::slide

## Lists are a recursive variant

```
type 'a list =
  | []
  | (::) of 'a * 'a list
```

A `'a list` is either:

- `[]`: the empty list.
- `x :: rest`: an element `x : 'a` prepended to another `'a list` `rest`.

- Recursive bit: the `'a list` inside the cons constructor.
- Each cons cell points to *another list* of any size (including empty).
- Hence: arbitrarily long.

:::

The same shape produces every list you have ever seen in OCaml.
`[1; 2; 3]` is `1 :: 2 :: 3 :: []`, a chain of three cons cells
ending in the empty list. `[]` is just `[]`. There is no separate
"length field" or "array of elements"; the structure of the value
*is* the data.

## Lists in practice

Because cons prepends an element to an existing list, building a
new list by adding a head is cheap:

```ocaml
let xs = [1; 2; 3]
let ys = 0 :: xs
let _ = ys
let _ = xs
```

`ys` is `[0; 1; 2; 3]`. `xs` is still `[1; 2; 3]` afterwards: lists
are immutable. The new value `ys` *shares* its tail with `xs`. No
copying happens.

:::slide

## Lists in practice

```ocaml
let xs = [1; 2; 3]
let ys = 0 :: xs
let _ = ys
```

- `int list = [0; 1; 2; 3]`.
- `0 :: xs` prepends `0` to `xs`.
- Original `xs` is **unchanged**.
- `ys` shares its tail with `xs` (no copy).

```ocaml
let xs = [1; 2; 3]
let _ = xs
```

- `int list = [1; 2; 3]`. Still.

:::

The "sharing tails" property is important. Prepending is `O(1)`:
allocate one cons cell, point its tail at the existing list, done.
Appending to the *end* is `O(n)` because you have to walk to the
end first to find the empty list that needs replacing. This is why
OCaml programmers think of lists *head-first*: you grow them by
prepending, you walk them by stripping off the head.

If you find yourself constantly appending to the end of a list,
you probably want a different data structure (an array, a Queue,
or a reversed list that you reverse once at the end).

## A recursive walk

To process a list, you write a function with the *same shape* as
the type: one clause per constructor.

```ocaml
let rec sum = function
  | [] -> 0
  | x :: rest -> x + sum rest

let _ = sum [1; 2; 3; 4; 5]
```

The base case (`[] -> 0`) handles the empty list. The recursive
case (`x :: rest -> x + sum rest`) destructures the cons cell into
head and tail, computes the sum of the tail recursively, and adds
the head.

:::slide

## A recursive walk

```ocaml
let rec sum = function
  | [] -> 0
  | x :: rest -> x + sum rest

let _ = sum [1; 2; 3; 4; 5]
```

- Result: `int = 15`.
- Two clauses, one per constructor of `list`.
- Recursive case calls `sum` on the *smaller* tail.
- This is **structural recursion**: the function's recursion mirrors the data type's.
- Every recursive variant gives you this pattern.

:::

This shape (one base case per *terminal* constructor, one recursive
case per *recursive* constructor) is called *structural recursion*.
The recursion of the function follows the recursion of the type.
Once you see this pattern, it works the same way for every
recursive type you will define: identify the constructors, write
one clause per constructor, recurse on the recursive payload.

Termination is automatic by induction: each recursive call peels
off one constructor, so the input is strictly smaller than the
caller's input. Eventually the recursion bottoms out at a base
case. There is no way to write structural recursion that fails to
terminate, as long as you genuinely recurse only on substructures
of the input.

## A binary tree

The next-simplest recursive variant is a binary tree:

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
```

Two constructors: `Leaf` (the empty tree) and `Node` (a left
subtree, a value, and a right subtree). The recursive references
appear *twice* in `Node`, which is why trees can branch.

A concrete tree:

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree

let example =
  Node (
    Node (Leaf, 1, Leaf),
    2,
    Node (Leaf, 3, Node (Leaf, 4, Leaf)))
```

Drawing this tree:

```
        2
       / \
      1   3
           \
            4
```

The four `Leaf` constructors are the empty-subtree placeholders at
the bottom. They make the tree's shape explicit: every node has
exactly two children, even if one (or both) of them is empty.

:::slide

## A binary tree

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
```

- `Leaf`: empty.
- `Node`: left subtree, value, right subtree.
- Same shape as a list, but **two** recursive references.

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
let example =
  Node (
    Node (Leaf, 1, Leaf),
    2,
    Node (Leaf, 3, Node (Leaf, 4, Leaf)))
```

Drawing it:

```
    2
   / \
  1   3
       \
        4
```

:::

A list is, in a sense, a *unary* tree: each cons cell has a value
and *one* successor (the tail). A binary tree has each node with
*two* successors. You can generalise further: ternary trees, $n$-ary
trees, even trees with an unbounded number of children (called
*rose trees*, which we will see in a moment).

## Walking the tree

Two clauses, one per constructor, recurse on each subtree:

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
let example =
  Node (Node (Leaf, 1, Leaf), 2, Node (Leaf, 3, Node (Leaf, 4, Leaf)))

let rec size = function
  | Leaf -> 0
  | Node (l, _, r) -> 1 + size l + size r

let _ = size example
```

`size` counts the number of `Node` constructors. Base case: `Leaf
-> 0`. Recursive case: `1 + size left + size right`. The function
recurses on both subtrees and adds their sizes plus one.

:::slide

## Walking the tree

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
let example =
  Node (Node (Leaf, 1, Leaf), 2, Node (Leaf, 3, Node (Leaf, 4, Leaf)))
let rec size = function
  | Leaf -> 0
  | Node (l, _, r) -> 1 + size l + size r

let _ = size example
```

- Result: `int = 4`.
- Two recursive calls per `Node`.

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
let example =
  Node (Node (Leaf, 1, Leaf), 2, Node (Leaf, 3, Node (Leaf, 4, Leaf)))
let rec sum_tree = function
  | Leaf -> 0
  | Node (l, v, r) -> v + sum_tree l + sum_tree r

let _ = sum_tree example
```

- Result: `int = 10`. Same shape; adds the node's value.

:::

The pattern is the same as for lists, just with two recursive
calls instead of one. For every constructor of the type, you have
one clause; for every recursive sub-position, you have one
recursive call. The function structure is *dictated* by the type
structure.

We are using `_` in the pattern `Node (l, _, r)` because `size`
does not care about the value at the node. For `sum_tree`, we do
care about it, so we bind it with `v`. The convention is the same
as for tuples: use `_` for components you do not use.

## Mutual recursion at the type level

Two types can be mutually recursive (each referring to the other).
The keyword is `and`, just like for
[mutual recursion of functions in M03-L05](M03-L05-local-and-mutual.html#mutual-recursion-two-functions-calling-each-other).
A small example: a "rose tree" or "n-ary tree," where each node
has a value and an arbitrary number of children:

```ocaml
type 'a forest = 'a rose_tree list
and  'a rose_tree = Rose of 'a * 'a forest
```

A rose tree carries a value and a *forest* of children; a forest
is a list of rose trees. Each definition refers to the other; the
`and` ties them together into one declaration.

:::slide

## Mutual recursion at the type level

Two types can refer to each other:

```ocaml
type 'a forest = 'a rose_tree list
and  'a rose_tree = Rose of 'a * 'a forest
```

- `rose_tree`: a value and a *forest* of children.
- `forest`: a list of rose trees.
- `and` ties them together (same as value-level mutual recursion).
- Models a node-labelled tree with **arbitrary number** of children per node.

:::

The same `and` keyword serves three purposes in OCaml: mutual
recursion of `let` bindings, mutual recursion of `type` declarations,
and (we will see in [Module 7](M07-L04-module-basics.html)) mutual
recursion of `module` declarations. The intuition is the same in
each case: the names introduced together are all in scope for each
other.

## Modelling arithmetic expressions

Here is the example that, in many people's experience, *clicks*:
a recursive variant for arithmetic expressions, plus a recursive
function that evaluates them.

```ocaml
type expr =
  | Num of int
  | Add of expr * expr
  | Mul of expr * expr

let e = Add (Num 3, Mul (Num 4, Num 5))

let rec eval = function
  | Num n -> n
  | Add (a, b) -> eval a + eval b
  | Mul (a, b) -> eval a * eval b

let _ = eval e
```

We have declared an *arithmetic mini-language* and a *one-pass
interpreter* in twelve lines of code. The expression `Add (Num 3,
Mul (Num 4, Num 5))` represents the arithmetic expression `3 + (4
* 5)`, which evaluates to `23`. The evaluator pattern-matches on
each constructor and recurses on the subexpressions.

:::slide

## Modelling arithmetic expressions

```ocaml
type expr =
  | Num of int
  | Add of expr * expr
  | Mul of expr * expr

let e = Add (Num 3, Mul (Num 4, Num 5))

let rec eval = function
  | Num n -> n
  | Add (a, b) -> eval a + eval b
  | Mul (a, b) -> eval a * eval b

let _ = eval e
```

- Result: `int = 23`.
- We've defined an arithmetic mini-language **and** its evaluator.
- Each constructor: a piece of syntax.
- Evaluator: pattern-matches and computes.
- The embryo of every interpreter and compiler.
- Same recipe for: JSON values, regular expressions, configurations, network protocols.

:::

This pattern, *variants for the kinds, recursion for the nesting,
pattern matching for the walks*, is what Module 4 has been
building toward. Once you can write code like this fluently, you
can model and process essentially any tree-structured data. The
tutorial in [M04-L06](M04-L06-tutorial.html) builds a slightly
larger example along the same lines (a JSON-like value type), and
we will keep returning to this shape throughout the course. The
[Module 5 tutorial](M05-L06-tutorial.html) revisits the
arithmetic-expression example with the full pattern-matching
toolkit.

## Structural induction

The reason these recursive walks "just work," and the reason you
can reason about their correctness, is *structural induction*. The
principle is a small generalisation of mathematical induction on
the natural numbers.

To prove (or convince yourself) that a function on a recursive
type is correct:

1. Show correctness on the *base* constructors (`Leaf`, `[]`, `Num
   n`). These have no recursive substructure; correctness here is
   usually direct.
2. Show that, *assuming* correctness on each immediate substructure,
   the function is correct on each recursive constructor (`Node`,
   `::`, `Add`).

:::slide

## Structural induction

To prove (or convince yourself) a function on a recursive type is correct:

1. Show correctness on the **base case** (`Leaf`, `[]`, `Num n`).
2. Assuming correctness on immediate substructures, show correctness on each **recursive case** (`Node`, `::`, `Add`).

- Same principle as school induction: `P(0)` and `P(n) -> P(n+1)` give `P(n)` for all `n`.
- Applied here to **data shapes**.
- If a function matches every constructor and delegates recursive cases properly:
  - Structural induction basically *guarantees* correctness.

:::

This is the same kind of reasoning you used for inductive proofs
in discrete math, lifted from natural numbers to recursive data
shapes. The base cases are the "zero" cases of the type; the
inductive step is the recursive constructor. Together they cover
*every possible value* of the type, by the same argument that `P(0)`
and `P(n) -> P(n+1)` cover every natural number.

The practical implication: when you write a structural recursion,
if you handle every constructor and you "trust" the recursive calls
to do the right thing on smaller inputs, you are almost certainly
correct. The compiler enforces the "every constructor handled"
part (via [exhaustiveness checking](M05-L04-exhaustiveness.html));
structural induction enforces the "trust the recursive call" part.

## A short check

:::quiz mcq id=M04-L04-q2
For the function below, what is its type?

```ocaml
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let rec map_tree f = function
  | Leaf -> Leaf
  | Node (l, v, r) -> Node (map_tree f l, f v, map_tree f r)
```

- [ ] `'a tree -> 'a tree`
- [ ] `('a -> 'a) -> 'a tree -> 'a tree`
- [x] `('a -> 'b) -> 'a tree -> 'b tree`
- [ ] `'a tree -> ('a -> 'b) -> 'b tree`

**Why:** `f` is applied to the value at each node; its argument is
of type `'a` (the tree's element type) and its result is of type
`'b` (a possibly-different type). The output tree has values of
type `'b`. The function takes `f` first, then the tree, so the
argument order is `('a -> 'b) -> 'a tree -> 'b tree`.
:::

:::quiz code id=M04-L04-q1
Define `height : 'a tree -> int` for the binary tree type. The
height of a `Leaf` is `0`; the height of a `Node` is `1` plus the
maximum of its two subtree heights.

```ocaml
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let rec height = function
  | Leaf -> failwith "not implemented"
  | Node (_, _, _) -> failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let t =
  Node (Node (Leaf, 1, Leaf),
        2,
        Node (Leaf, 3, Node (Leaf, 4, Leaf)))
let () =
  check (height Leaf = 0) "leaf";
  check (height (Node (Leaf, 1, Leaf)) = 1) "one";
  check (height t = 3) "example";
  print_endline "all tests passed"
```
:::

Reference solution:

```ocaml
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree
let rec height = function
  | Leaf -> 0
  | Node (l, _, r) -> 1 + max (height l) (height r)
```

The `max` function comes from `Stdlib` and works on any comparable
type.

## Activity

:::slide

## Activity

Define `'a tree` and write `size : 'a tree -> int` that counts the
number of `Node` constructors. Test on a non-empty tree.

:::

:::slide

## Activity solution

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree

let rec size = function
  | Leaf -> 0
  | Node (l, _, r) -> 1 + size l + size r

let t = Node (Node (Leaf, 1, Leaf), 2, Leaf)
let _ = size t
```

- Result: `int = 2` (two nodes: root `2`, left child `1`).
- Base case: `Leaf -> 0`.
- Recursive case: `1` + size of each subtree.
- Pattern `Node (l, _, r)` ignores the value (we count, not read).

:::

The pattern `Node (l, _, r)` shows how patterns *project*: we want
the two subtrees, we do not care about the value, so we use `_` to
discard the value position. This is the same idiom as in tuples.

## What's next

:::slide

## What's next

Lecture 5: **type abbreviations** (giving short names to longer
types) and **`option`** (the standard way to represent "maybe a
value, maybe not"). After that, the Module 4 tutorial.

:::

We now have variants, records, tuples, and recursive variants. The
[next lecture](M04-L05-option-and-aliases.html) adds two small but
important pieces: type *abbreviations* (short names for existing
types) and the `option` type (the standard idiom for "maybe a
value"). Then the [module tutorial](M04-L06-tutorial.html) puts
all of it together.

## Reading

- **Cornell CS3110**, *Lists*:
  <https://cs3110.github.io/textbook/chapters/data/lists.html>
- **Cornell CS3110**, *Trees*:
  <https://cs3110.github.io/textbook/chapters/data/trees.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
