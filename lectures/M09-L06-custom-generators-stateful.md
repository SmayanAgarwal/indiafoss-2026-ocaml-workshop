---
title: "Custom generators and stateful property tests"
lecture_no: 6
week: 9
duration_target_min: 22
concepts: [custom generators, QCheck, sorted-list generator, BST generator, balanced BST, DAG generator, bundled arbitrary, custom shrinker, stateful PBT, command sequences]
keywords: [OCaml, QCheck, custom generator, invariant, sorted list, balanced BST, red-black tree, DAG, custom arbitrary, printer, shrinker, stateful testing, command sequence, frequency, choose]
activity_question: "You have an [insert : int -> avl -> avl] you trust, and an [extract_min : avl -> (int * avl) option] you don't. How would you generate a stream of valid AVL trees to feed into [extract_min] without writing a "generate-from-scratch" balanced-tree generator?"
think_about_this: "If your generator is biased away from edge cases, your property runs 1000 times and passes, and your code still has a bug at the edge. PBT is a sieve. What shape are the holes in the sieve, and how do you adjust them?"
reading:
  - title: "QCheck README and tutorial"
    url: https://github.com/c-cube/qcheck
  - title: "QCheck API documentation"
    url: https://c-cube.github.io/qcheck/
  - title: "Cornell CS3110, Black-box and glass-box testing"
    url: https://cs3110.github.io/textbook/chapters/correctness/black_glass_box.html
---

# Custom generators and stateful property tests


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Custom generators and stateful property tests</h2>
<p class="title-slide-label">Module 9 &middot; Lecture 6</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

[Lecture 5](M09-L05-property-based-testing.html) gave us
QCheck's core API: write a property as a pure function `'a ->
bool`, hand it a generator, let the library try a thousand
random inputs, and let the shrinker minimise any failure. That
loop works beautifully for any function whose input fits one of
the built-in generators (lists of ints, strings, pairs,
options).

Real codebases want more. Two pressures push past the built-ins:

- **Invariant-rich inputs.** Many functions take inputs that
  must satisfy a non-trivial precondition: a *sorted* list, a
  *valid* BST, a JSON value matching a schema, an arithmetic
  expression with no zero divisors. A uniformly random `list
  int` almost never satisfies "sorted"; a uniformly random tree
  almost never satisfies "valid BST." Naive generators produce
  garbage, the property fires on garbage, the test is useless.

- **Stateful APIs.** A hash table is not a function; it is a
  sequence of calls (`add`, `find`, `remove`) whose result on
  the *n*th call depends on every prior call. There is no
  single input to generate; there is a *history* of operations.

This lecture is about extending QCheck to handle both. We
build *custom generators* that produce only inputs satisfying
the invariant we want, *bundle* generator + printer + shrinker
into a reusable `arbitrary`, and then take the first step into
*stateful PBT* by generating sequences of commands. The full
treatment of stateful PBT against a reference implementation
follows in [Lecture 7](M09-L07-model-based-testing.html).

:::slide

## What this lecture covers

- The **input-space problem**: random does not mean
  "uniformly visits interesting cases."
- **Three reactions**: read your stats, bias the generator,
  generate-by-construction.
- **Sorted-list, valid-BST, DAG generators**: invariant by
  construction.
- **Bundling**: generator + printer + shrinker into a single
  `arbitrary`.
- **Stateful PBT**: generate *sequences of commands*; full
  model-based version in L05.

:::

## The input-space problem, sharpened

Take a function that sorts. A list with three random integers,
generated independently, is *almost certainly* not sorted. The
sorter has to do something. But the *interesting* sorting bugs
fire on inputs the default generator visits rarely:

- the *already-sorted* list (does the sorter detect this and
  short-circuit, or perform redundant work?);
- the *reverse-sorted* list (worst case for many algorithms);
- a list with many duplicates (does the comparison handle ties?);
- a list of length 0, 1, 2 (boundary conditions);
- a list near `min_int` or `max_int` (overflow-adjacent).

A uniformly random `(list int)` of length 7 visits the random
*permutation* region of the input space densely and the boundary
regions sparsely. The bug at the boundary may go undetected for
1000 trials and then surface in production, on a customer's
already-sorted input.

This is *the* distribution problem. Random does not mean
"uniformly explores the interesting cases." Random means
"uniform in some specific way, often a way that misses
interesting cases."

The framework Cornell CS3110 uses for this is *paths through the
specification* (see the Reading section). The idea is to look at
the spec and identify the disjoint *regions* of input space
where the function behaves differently: empty input, singleton
input, "happy path", boundary case, error case. PBT does not
free you from that thinking; it changes *where* you do it.
Instead of writing 20 hand-picked inputs, you write a generator
that *covers each region*.

:::slide

## The input-space problem, in one slide

For `List.sort`, the *interesting* cases are at boundaries:

- already-sorted, reverse-sorted;
- many duplicates;
- length 0, 1, 2;
- near `min_int` / `max_int`.

The default `QCheck.(list int)` visits the *permutation* region
densely and the boundary regions rarely. 1000 passing trials
does not exclude a boundary bug.

:::

:::slide

## Three reactions to the distribution problem

1. **Read your statistics.** `QCheck.collect` reports the
   distribution of generated inputs. If lengths cluster in one
   bucket, the generator is not exercising the others.
2. **Bias the generator.** `QCheck.frequency` (or `choose`)
   weights cases so the interesting regions are visited often.
3. **Generate-by-construction.** Build a generator whose
   outputs are *by construction* in the region you care about.

The third is the most powerful and the most reusable.

:::

## Biasing with `frequency`

The smallest step beyond the default. Pick from several
generators, weighted by importance:

```ocaml
let biased_list_gen : int list QCheck.arbitrary =
  let open QCheck in
  let small = list_of_size (Gen.return 0) int in
  let medium = list_of_size (Gen.int_range 1 10) int in
  let large = list_of_size (Gen.int_range 100 200) int in
  QCheck.choose [small; medium; large]
```

`QCheck.choose` picks uniformly among the listed generators.
`QCheck.frequency` is the weighted version: give each generator
a positive integer weight, and the picker samples in proportion.
A small list shows up often, a large list shows up rarely, but
*both* are exercised. The distribution is now in your hands.

:::slide

## Biasing with `choose` and `frequency`

```ocaml
let biased_list_gen =
  let open QCheck in
  let small  = list_of_size (Gen.return 0)         int in
  let medium = list_of_size (Gen.int_range 1 10)   int in
  let large  = list_of_size (Gen.int_range 100 200) int in
  QCheck.choose [small; medium; large]
```

- `choose`: pick a sub-generator uniformly.
- `frequency`: same idea, with integer weights.
- Every generated list belongs to one of your buckets; the
  framework no longer picks for you.

:::

## Generating values that satisfy an invariant

The single hardest skill in PBT is writing a generator that
produces inputs satisfying a non-trivial precondition. "Generate
a sorted array" is not "generate an array"; "generate a valid
red-black tree" is far harder than "generate a tree." The
default `QCheck.list int` produces something that has *almost
certainly* none of the structural properties you want.

Three escalating examples.

### Example A: a sorted list

The naive approach is rejection sampling: generate a random
list, check if it is sorted, retry if not. For length-3 lists
of small integers this works (about one in six are sorted); for
length-20 lists the rejection rate is ~99.999999% and the
generator stalls.

The correct approach is *constructive*: build something that is
sorted *by construction*. Two natural recipes.

**Recipe A1: generate, then sort.** Generate a random list, then
apply `List.sort compare` and return the result. The output is
guaranteed sorted.

```ocaml
let sorted_int_list_gen : int list QCheck.arbitrary =
  QCheck.(map (fun xs -> List.sort compare xs) (list int))
```

`QCheck.map` lifts a function `'a -> 'b` over a generator,
producing an `'b QCheck.arbitrary`. Every output of this
generator is sorted. The cost is one `List.sort` per test,
which is cheap.

**Recipe A2: prefix-sum of non-negative increments.** Start with
an initial value, generate a list of non-negative increments,
take the running sum. The output is sorted *and* you control
the distribution of gaps.

```ocaml
let sorted_int_list_via_prefix_sum_gen : int list QCheck.arbitrary =
  let open QCheck in
  map
    (fun (start, gaps) ->
       let _, acc =
         List.fold_left
           (fun (cur, acc) gap ->
              let next = cur + gap in
              (next, next :: acc))
           (start, [start])
           gaps
       in
       List.rev acc)
    (pair small_int (list small_nat))
```

If you want sorted lists with possible duplicates, the gaps can
be zero. If you want strictly increasing, force a `+1` to make
each gap positive. The point is that the distribution is now in
your hands, not the framework's.

:::slide

## Sorted lists, recipe A1: generate, then sort

```ocaml
let sorted_a =
  QCheck.(map (fun xs -> List.sort compare xs) (list int))
```

- Transform arbitrary output into invariant-satisfying output.
- Simple and cheap.
- Biased toward random-shape distributions
  - the sort erases any structure you wanted in the gaps.

:::

:::slide

## Sorted lists, recipe A2: sorted by construction

```ocaml
let sorted_b =
  QCheck.(map
    (fun (start, gaps) ->
       let _, acc =
         List.fold_left
           (fun (c, acc) g -> let n = c + g in (n, n :: acc))
           (start, [start]) gaps
       in List.rev acc)
    (pair small_int (list small_nat)))
```

- A start plus non-negative gaps *is* a sorted list.
- More control over the gap distribution.
- Both recipes produce *only* sorted lists; no rejection.

:::

### Example B: a valid binary search tree

Now the harder case. Operations on a binary search tree
(`mem`, `delete`, `union`, `inorder`) all assume the input tree
*is* a valid BST. If we generate a random tree shape and stuff
random integers into it, we get a tree that violates the BST
invariant. The test exercises the function on garbage; its
results tell us nothing.

**Recipe B1: insert random keys into an empty tree.** This is
the *operation-based generator* pattern, and it is the canonical
way to generate values of a complex algebraic data structure
with a non-trivial invariant.

```ocaml
type tree = Leaf | Node of tree * int * tree

let rec insert t x =
  match t with
  | Leaf -> Node (Leaf, x, Leaf)
  | Node (l, y, r) ->
    if x < y then Node (insert l x, y, r)
    else if x > y then Node (l, y, insert r x)
    else t  (* already present *)

let bst_gen : tree QCheck.arbitrary =
  QCheck.(map
    (fun xs -> List.fold_left insert Leaf xs)
    (list int))
```

A list of random integers folded with `insert` over the empty
tree produces *exactly* the BSTs that `insert` itself can
produce. The BST invariant is preserved by `insert`, so every
generated tree is a valid BST.

Now we can write the defining property of a BST: in-order
traversal yields a sorted sequence.

```ocaml
let rec inorder = function
  | Leaf -> []
  | Node (l, x, r) -> inorder l @ [x] @ inorder r

let is_sorted xs =
  let rec go = function
    | [] | [_] -> true
    | a :: (b :: _ as t) -> a <= b && go t
  in
  go xs

let test_inorder_is_sorted =
  QCheck.Test.make
    ~name:"in-order traversal of a BST is sorted"
    bst_gen
    (fun t -> is_sorted (inorder t))
```

The same recipe scales to red-black, AVL, splay trees. Use the
library's `insert`; the invariant is whatever the library
promises; the generator inherits it from the operation.

A nice bonus: a bug in `insert` will *also* show up via the
consumer property. If `insert` ever produces a tree whose
inorder traversal is not sorted, the property fires.
Operation-based generators are a beautiful self-checking
technique.

:::slide

## Generator for a valid BST

```ocaml
let bst_gen : tree QCheck.arbitrary =
  QCheck.(map
    (fun xs -> List.fold_left insert Leaf xs)
    (list int))
```

Use the data structure's *own* `insert` as the generator.

- Every output is a valid BST (because `insert` preserves the
  invariant).
- Same recipe works for red-black, AVL, splay, etc.
- Bonus: a bug in `insert` shows up via consumer properties
  (in-order traversal should be sorted, height should be
  logarithmic, ...).

:::

### Example C: invariants by construction, in passing

The same patterns generalise.

**Acyclic graph.** Generate vertices as `0 .. n-1`. For each
ordered pair `(i, j)` with `i < j`, decide whether to include
the edge. The resulting graph is a DAG by construction because
no edge points backward in the vertex ordering.

```ocaml
let dag_gen : (int * int) list QCheck.arbitrary =
  let open QCheck in
  small_int >>= fun n ->
  let pairs = ref [] in
  for i = 0 to n - 1 do
    for j = i + 1 to n - 1 do
      pairs := (i, j) :: !pairs
    done
  done;
  list_of_size (Gen.int_range 0 (List.length !pairs)) (oneofl !pairs)
  |> map (fun edges -> List.sort_uniq compare edges)
```

**Arithmetic expression with no zero divisor.** Recursively
build the tree, but in the `Div` case generate the right-hand
side from `Gen.int_range 1 max_int` or `Gen.int_range min_int
(-1)`, never including 0.

**JSON value matching a schema.** Generate at each step the
constructor allowed by the schema's grammar. The generator *is*
the grammar.

The shared pattern: don't generate-then-filter,
*generate-by-construction*. Filtering with `QCheck.assume` works
when most inputs satisfy the precondition; it does not work when
the precondition is restrictive ("sorted, balanced, acyclic").
For those, build the structure to satisfy the invariant from
the start.

:::slide

## The general pattern

| Invariant | Generator pattern |
| --- | --- |
| Sorted list | `map List.sort (list int)` |
| Valid BST | Fold `insert` over a random list |
| Balanced BST | Sort, then midpoint-split |
| DAG | Edges only from low to high vertex index |
| Non-zero divisor | Pick from `int_range 1 max_int` |
| Schema-valid JSON | Generator mirrors the grammar |

**Don't generate-then-filter. Generate-by-construction.**

:::

## Bundling generator, printer, and shrinker

A custom generator is only half the API. To get good failure
messages and small counterexamples, an `'a QCheck.arbitrary`
needs three things:

- a **generator** (a `'a QCheck.Gen.t`);
- a **printer** (so failure messages show what was generated);
- a **shrinker** (so a 17-node tree fails on a 1-node tree).

The end-to-end shape for a custom recursive type:

```ocaml
type 'a tree = Leaf | Node of 'a tree * 'a * 'a tree

let rec tree_gen depth elem_gen =
  let open QCheck.Gen in
  if depth <= 0 then return Leaf
  else
    frequency [
      1, return Leaf;
      3, (let* x = elem_gen in
          let* l = tree_gen (depth - 1) elem_gen in
          let* r = tree_gen (depth - 1) elem_gen in
          return (Node (l, x, r)));
    ]

let rec tree_to_string elem_to_string = function
  | Leaf -> "Leaf"
  | Node (l, x, r) ->
    Printf.sprintf "Node (%s, %s, %s)"
      (tree_to_string elem_to_string l)
      (elem_to_string x)
      (tree_to_string elem_to_string r)

let rec tree_shrink shrink_elem = function
  | Leaf -> QCheck.Iter.empty
  | Node (l, x, r) ->
    let open QCheck.Iter in
    (* Drop a sub-tree: replace the whole node by either child *)
    of_list [l; r] <+>
    (* Or shrink the element *)
    (shrink_elem x >|= fun x' -> Node (l, x', r)) <+>
    (* Or shrink the left sub-tree *)
    (tree_shrink shrink_elem l >|= fun l' -> Node (l', x, r)) <+>
    (* Or shrink the right sub-tree *)
    (tree_shrink shrink_elem r >|= fun r' -> Node (l, x, r'))

let tree_arb : int tree QCheck.arbitrary =
  QCheck.make
    ~print:(tree_to_string string_of_int)
    ~shrink:(tree_shrink QCheck.Shrink.int)
    (tree_gen 4 QCheck.Gen.small_int)
```

The generator uses `frequency` (1 leaf for every 3 nodes) and a
depth bound to keep the tree finite. The printer is recursive
descent into the tree. The shrinker tries, in order: replacing
the node by one of its children, shrinking the element,
shrinking the left subtree, shrinking the right subtree.

Once `tree_arb` exists, properties on the type are one-liners:

```ocaml
let rec size = function Leaf -> 0 | Node (l, _, r) -> 1 + size l + size r
let rec mirror = function
  | Leaf -> Leaf
  | Node (l, x, r) -> Node (mirror r, x, mirror l)

let test_mirror_size_preserved =
  QCheck.Test.make ~name:"mirror preserves size"
    tree_arb
    (fun t -> size (mirror t) = size t)

let test_mirror_involutive =
  QCheck.Test.make ~name:"mirror is its own inverse"
    tree_arb
    (fun t -> mirror (mirror t) = t)
```

The printer is the cheapest investment with the largest payoff:
write one whenever a type appears in any property. Skipping the
printer means failure messages say `<opaque>` and you lose the
counter-example. The shrinker is worth writing once a type
appears in more than one property, or once a property fails
often enough that the minimal counterexample matters.

:::slide

## Bundle generator + printer + shrinker

```ocaml
let tree_arb : int tree QCheck.arbitrary =
  QCheck.make
    ~print:(tree_to_string string_of_int)
    ~shrink:(tree_shrink QCheck.Shrink.int)
    (tree_gen 4 QCheck.Gen.small_int)
```

- **Generator**: produces values of the type.
- **Printer**: makes failures legible (without it: `<opaque>`).
- **Shrinker**: minimises a failing input.
- The three together form an `'a QCheck.arbitrary`.

:::

## From data to commands: the first step toward stateful PBT

So far the inputs we generate are *data*: lists, trees, JSON
values. What about a *stateful* API like a hash table, where
the function under test is not really a function but a sequence
of `add`/`find`/`remove` calls?

The pattern, in two moves:

1. **Represent each operation as a constructor of a variant
   type.** Each constructor carries the arguments the operation
   takes.
2. **Generate a *list* of commands.** The same generator
   machinery: `QCheck.list_of_size`, `frequency`, `let*`. The
   shrinker on lists is exactly the shrinker we want: drop a
   command, simplify an argument.

For a stack with three operations:

```ocaml
type command =
  | Push of int
  | Pop
  | Top

let key_gen = QCheck.Gen.int_range 0 20
(* Small key space => collisions, lookups of present keys *)

let command_gen : command QCheck.Gen.t =
  let open QCheck.Gen in
  oneof [
    (let* k = key_gen in return (Push k));
    return Pop;
    return Top;
  ]

let command_list_gen : command list QCheck.arbitrary =
  QCheck.make
    ~print:(fun cs ->
      "[" ^ String.concat "; "
        (List.map
          (function
           | Push k -> Printf.sprintf "Push %d" k
           | Pop -> "Pop"
           | Top -> "Top")
          cs) ^ "]")
    (QCheck.Gen.list_size (QCheck.Gen.int_range 0 30) command_gen)
```

A test using this generator picks a random *sequence* of stack
operations. The property is then "run this sequence; check some
invariant of the stack at the end" (or, more interestingly,
"check the invariant at every step", which is what L05 does).

A subtle design choice: **the key space is small (0..20)**, not
the default `QCheck.int` range. If keys were uniformly random
across all 63-bit integers, two `Push`es would essentially
never push the same key, and `Top` after a `Pop` would
essentially never find a key from an earlier `Push`. By
restricting the key space, we force *collisions*: the
interesting behaviour of a stack (LIFO order under repeated
pushes of the same value) actually gets exercised.

:::slide

## Generating command sequences

```ocaml
type command = Push of int | Pop | Top

let command_gen =
  let open QCheck.Gen in
  oneof [
    (let* k = int_range 0 20 in return (Push k));
    return Pop;
    return Top;
  ]

let command_list_gen =
  let open QCheck.Gen in
  QCheck.make (list_size (int_range 0 30) command_gen)
```

- One constructor per public operation.
- Small key/value ranges force interesting collisions.
- The default list shrinker handles deletion + per-command
  simplification automatically.

:::

## What's still missing: the oracle

We can now generate a command sequence and run it on our stack.
What property do we check? "Did anything crash?" is a low bar.
What we *really* want is: "the stack behaves the same as a
much simpler reference implementation."

That comparison, applied step-by-step over the operation
sequence, is the technique of [model-based testing](M09-L07-model-based-testing.html),
the topic of the next lecture. The pieces we built in this
lecture (command type, command-list generator, default list
shrinker) are exactly the pieces the next lecture will assemble
into a complete stateful test harness.

:::slide

## What is still missing: the oracle

- We can generate operation sequences and run them.
- "Did anything crash?" is too weak.
- What we want: "the implementation behaves *the same as*
  a much simpler reference."
- Step-by-step equivalence with a reference is L05's
  technique.

:::

## Activity

:::quiz mcq id=M09-L06-q1
You are testing operations on a balanced binary search tree
(BST). You have a trusted `insert : int -> tree -> tree` and
want to test a new `delete : int -> tree -> tree`. The default
QCheck generator for the recursive `tree` type produces random
tree shapes with random integer labels.

Why is the default generator a bad choice for testing `delete`?

- [ ] QCheck cannot generate recursive types.
- [x] A random tree shape with random labels is almost never
  a valid BST (the BST invariant is violated). `delete` is
  only defined on valid BSTs; running it on garbage input
  tells us nothing about its behaviour on real BSTs.
- [ ] `delete` is too complex to property-test.
- [ ] The default generator is too slow.

**Why:** the right generator folds `insert` over a list of
random integers. The output is *exactly* a tree that `insert`
itself produces, which preserves the BST invariant by
construction. The property `delete` is then exercised on real
BSTs. This is the operation-based-generator pattern from this
lecture; the recipe scales to any data structure with a
non-trivial invariant.
:::

:::quiz mcq id=M09-L06-q2
A QCheck `arbitrary` bundles three things:

- a generator,
- a printer,
- a shrinker.

You write a custom `arbitrary` for a record type `point = { x :
int; y : int }` but supply only the generator (no printer, no
shrinker). The test passes 999 times; the 1000th input fails.
What do you see in the failure message?

- [ ] The failing input, fully printed, with no minimisation.
- [ ] An error: QCheck refuses to run a property whose generator
  has no shrinker.
- [x] An opaque `<opaque>` (or similar) for the input, and the
  original failing value, not a shrunk version.
- [ ] The shrunk minimum, but no printer output.

**Why:** without a printer, QCheck cannot turn the failing
value into a string; the framework prints `<opaque>` and you
lose the counterexample. Without a shrinker, QCheck reports the
original failing input verbatim, which may be far larger than
the minimal failure. The printer is the cheapest investment
with the largest payoff: a five-line `to_string` function turns
an unreadable failure into a debuggable one.
:::

:::quiz code id=M09-L06-q3
Write a QCheck arbitrary that generates *non-empty* lists of
positive integers. Call it `nonempty_pos_list_gen`.

You should not use `QCheck.assume`; build the invariant into
the generator. (Hint: `QCheck.list_of_size` with a size at
least 1; `QCheck.Gen.int_range` to bound the elements.)

```ocaml
let nonempty_pos_list_gen : int list QCheck.arbitrary =
  failwith "not implemented"
```

```ocaml skip
let () =
  (* Pretend the generator has been wired into a property and
     run.  Sanity-check the *shape* on a couple of small lists.
   *)
  let prop xs = xs <> [] && List.for_all (fun x -> x > 0) xs in
  assert (prop [1]);
  assert (prop [3; 7; 42]);
  assert (prop [1; 1; 1]);
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```ocaml
let nonempty_pos_list_gen : int list QCheck.arbitrary =
  let open QCheck in
  make
    ~print:(fun xs ->
      "[" ^ String.concat "; " (List.map string_of_int xs) ^ "]")
    (Gen.list_size (Gen.int_range 1 30) (Gen.int_range 1 100))
```

Three lines. `list_size (int_range 1 30)` bounds the length away
from zero; `int_range 1 100` bounds elements to positives. The
optional `~print` makes failures legible.

:::

## Common pitfalls

**Pitfall 1: forgetting the printer.** Without `~print`, failure
messages say `<opaque>` and you cannot read the counter-example.
Always write a printer.

**Pitfall 2: shrinker that loses the invariant.** A custom
shrinker on a "sorted list" must produce only sorted lists. If
it drops a random middle element and breaks the sort, QCheck
will think it found a smaller failing case but the new case
exercises the function on garbage.

**Pitfall 3: trusting one property to validate a custom
generator.** If you write a generator for "balanced BSTs" and
only test "inorder is sorted", a bug in your generator that
produces *un*balanced BSTs goes undetected. Add a sanity
property: `is_balanced (bst_gen ())` should always hold.

**Pitfall 4: ignoring `QCheck.collect`.** Once a generator gets
non-trivial, you have very little intuition for what it
produces. Add a `collect` annotation, run the property, eyeball
the distribution. Surprises are common.

**Pitfall 5: too-large command sequences.** For stateful PBT,
30-50 commands is a sensible default. Going to 500 makes each
test slow and the shrinker slow as well, with little marginal
coverage.

:::slide

## Common pitfalls

1. **No printer**: failures say `<opaque>`. Write one.
2. **Shrinker loses the invariant**: produce only valid
   instances.
3. **No sanity property on the generator itself**: a buggy
   generator silently invalidates every test.
4. **Ignoring `collect`**: surprises about the distribution
   are common.
5. **Command sequences too long**: 30-50 is the sweet spot.

:::

## What's next

[Lecture 7](M09-L07-model-based-testing.html) completes the
stateful-PBT story. We take the command-sequence generator
we built here, point it at a real stateful API (a custom hash
table), and *also* run it against a tiny reference
implementation (a list-backed map). The property: the two
implementations agree on every observable step. When they
disagree, QCheck shrinks the sequence to the smallest one that
still diverges, and that shrunk sequence is the bug report.

After that, [the tutorial](M09-L08-tutorial.html) wraps the
module up: the full toolkit, from specification to shrunk
counterexample, applied to one evaluator.

:::slide

## What's next

- L7: **model-based testing.** Custom hash table vs list
  reference. The command-sequence harness we just built,
  plus an oracle.
- L8: **wrap-up tutorial.** The full toolkit on the arithmetic
  evaluator from the pattern-matching module.

:::

## Reading

- **QCheck README and tutorial**:
  <https://github.com/c-cube/qcheck>
- **QCheck API documentation**:
  <https://c-cube.github.io/qcheck/>
- **Cornell CS3110**, *Black-box and glass-box testing*. The
  framework of "paths through the specification" used in the
  input-space section:
  <https://cs3110.github.io/textbook/chapters/correctness/black_glass_box.html>
- **Real World OCaml**, *Testing*. Discusses
  `ppx_quickcheck`, which auto-derives many of the boilerplate
  pieces above from the type definition:
  <https://dev.realworldocaml.org/testing.html>

## Sources

This lecture's prose, worked examples, and quizzes are original
to this course; the sorted-list, operation-based-BST, and DAG
generator recipes follow folklore patterns in the PBT community,
presented here in our own words and OCaml. The QCheck library by
Simon Cruanes and contributors is BSD-2-Clause licensed; we link
to its repository and use its public API surface, with no
derivative reuse of its prose. Cornell CS3110's testing chapters
are CC BY-NC-ND licensed and have not been derivatively reused;
the *paths through the specification* framing follows their
pedagogical sequence with our own examples and prose. Real World
OCaml's Testing chapter has a parallel discussion of
`ppx_quickcheck` that we link to but have not reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
