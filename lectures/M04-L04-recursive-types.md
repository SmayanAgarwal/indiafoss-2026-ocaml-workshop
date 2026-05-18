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
  - title: "Cornell CS3110, Lists and trees"
    url: https://cs3110.github.io/textbook/chapters/data/lists.html
---

# Recursive types

A variant becomes interesting when one of its constructors holds a
value of *the same type*. That's how you describe data that can
contain itself: lists (the tail is another list), trees (the
subtrees are themselves trees), arithmetic expressions (an `Add` is
two more expressions). This lecture covers the canonical recursive
shapes and how to walk them.

:::slide

## Lists are a recursive variant

```
type 'a list =
  | []
  | (::) of 'a * 'a list
```

(This is the conceptual definition; the actual syntax in the
standard library is the same idea with built-in sugar.)

A `'a list` is either:

- `[]`: the empty list.
- `x :: rest`: an element `x` of type `'a` *prepended to* another
  `'a list` called `rest`.

The recursive bit is the `'a list` inside the cons constructor.
Lists are arbitrarily long because each node points to *another
list* of any size, including empty.

:::

:::slide

## Lists in practice

```ocaml
let xs = [1; 2; 3]
let ys = 0 :: xs
let _ = ys
```

`int list = [0; 1; 2; 3]`. The `0 :: xs` notation prepends `0` to
`xs`. The original `xs` is unchanged; `ys` is a fresh list that
*shares* its tail with `xs`.

```ocaml
let _ = xs
```

`int list = [1; 2; 3]`. Still.

:::

The "sharing tails" property is important. Prepending is O(1):
allocate one cons cell, point its tail at the existing list, done.
Appending to the end is O(n) because you have to walk to the end
of the list first. This is why OCaml programmers think of lists
*head-first*: you grow them by prepending.

:::slide

## A recursive walk

```ocaml
let rec sum = function
  | [] -> 0
  | x :: rest -> x + sum rest

let _ = sum [1; 2; 3; 4; 5]
```

`int = 15`. Two cases, matching the two constructors of `list`.
Each case handles its constructor; the recursive case calls
`sum` on the *smaller* tail.

This is **structural recursion**: the function's recursion
mirrors the data type's recursion. Every recursive variant gives
you this pattern.

:::

:::slide

## A binary tree

```ocaml
type 'a tree =
  | Leaf
  | Node of 'a tree * 'a * 'a tree
```

A tree is either a `Leaf` (empty) or a `Node` with a left subtree,
a value, and a right subtree. Same shape as a list, but two
recursive references instead of one.

```ocaml
let example =
  Node (
    Node (Leaf, 1, Leaf),
    2,
    Node (Leaf, 3, Node (Leaf, 4, Leaf)))
```

Drawing this:

```
        2
       / \
      1   3
           \
            4
```

The `Leaf` constructors are at the bottom (each empty subtree is
`Leaf`). The shape is built bottom-up by nesting `Node`s.

:::

:::slide

## Walking the tree

```ocaml
let rec size = function
  | Leaf -> 0
  | Node (l, _, r) -> 1 + size l + size r

let _ = size example
```

`int = 4`. We count the number of `Node` constructors. Base:
`Leaf` is `0`. Recursive: `1 + size left + size right`. Two
recursive calls per step, just like trees have two subtrees per
node.

```ocaml
let rec sum_tree = function
  | Leaf -> 0
  | Node (l, v, r) -> v + sum_tree l + sum_tree r

let _ = sum_tree example
```

`int = 10`. Same shape; we add the node's value to the recursive
sums of left and right.

:::

:::slide

## Mutual recursion at the type level

Two types can refer to each other:

```ocaml
type 'a forest = 'a rose_tree list
and  'a rose_tree = Rose of 'a * 'a forest
```

A `rose_tree` has a value and a *forest* of children; a `forest`
is a list of rose trees. Each definition refers to the other.
The `and` keyword ties the two together, just like with mutual
recursion at the value level.

This is how you model a *node-labelled* tree where each node has
an arbitrary number of children, not just two.

:::

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

`int = 23`. We just defined an arithmetic expression mini-language
and an evaluator for it. Each constructor is a piece of syntax; the
evaluator pattern-matches and computes.

This is the embryo of every interpreter and compiler. Same recipe
for JSON values, regular expressions, configuration files, network
protocols.

:::

This is the pattern Module 4 was building toward. **Variants for
the kinds, recursion for the nesting, pattern matching for the
walks.** Once you can write this kind of code, you can model any
tree-shaped data and process it.

:::slide

## Structural induction

The reason these walks "just work" is **structural induction**.

To prove (or just convince yourself) that a function on a recursive
type is correct, you need to show:

1. It is correct on the base case (`Leaf`, `[]`, `Num n`).
2. Assuming it is correct on the immediate substructures, it is
   correct on each recursive case (`Node`, `::`, `Add`).

This is the same induction principle from school math (`P(0)` and
`P(n) ⇒ P(n+1)` give you `P(n)` for all `n`), applied to data
shapes.

When a function over a recursive type matches every constructor and
delegates the recursive cases properly, structural induction
basically *guarantees* the function is correct.

:::

:::slide

## Activity

Define `'a tree` and write `size : 'a tree -> int` that counts
the number of `Node` constructors. Test on a non-empty tree.

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

`int = 2`. Two nodes in the tree (root `2`, left child `1`).

The base case is `Leaf -> 0`; the recursive case adds 1 for the
current node plus the size of each subtree. The pattern `Node (l,
_, r)` ignores the value at the node (we just count, we don't read
the data).

:::

:::slide

## What's next

Lecture 5: **type abbreviations** (giving short names to longer
types) and **`option`** (the standard way to represent "maybe a
value, maybe not"). After that, the Module 4 tutorial.

:::

## Reading

- **Cornell CS3110**, *Lists*:
  <https://cs3110.github.io/textbook/chapters/data/lists.html>
