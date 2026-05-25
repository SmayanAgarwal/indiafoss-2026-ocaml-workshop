---
title: "Tutorial: testing the expr evaluator with OUnit2, QCheck, and effect-handler stubs"
lecture_no: 8
week: 9
duration_target_min: 25
concepts: [testing tutorial, OUnit2, QCheck, properties, invariants, expression evaluator, debugging, effect-handler stubs, dependency stubbing]
keywords: [OCaml, testing, OUnit2, QCheck, tutorial, expression evaluator, AST, property-based testing, debugging, shrinking, effect handlers, stubs]
activity_question: "Take the expr AST eval from M05-L06 and pretend its Sub case is buggy (swapped arguments). Which OUnit2 case catches this? Which QCheck property catches this most quickly, and what is the shrunk counterexample likely to look like?"
think_about_this: "If your QCheck property compares the OCaml-implemented eval against a hand-written reference (e.g. via float arithmetic in the property itself), what happens when the reference is also buggy? How do you avoid testing one bug against itself?"
reading:
  - title: "Cornell CS3110, Testing and OUnit"
    url: https://cs3110.github.io/textbook/chapters/correctness/ounit.html
  - title: "QCheck README and tutorial"
    url: https://github.com/c-cube/qcheck
---

# Tutorial: testing the `expr` evaluator with OUnit2, QCheck, and effect-handler stubs


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Tutorial: testing the expr evaluator with OUnit2, QCheck, and effect-handler stubs</h2>
<p class="title-slide-label">Module 9 &middot; Lecture 8</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

This tutorial puts the testing half of this module (lectures
L01 through L05) to work on a single larger example, then
borrows one idea from the concurrency half (L06's effect
handlers) to stub a side effect so the function under test
becomes pure. We take the [`expr` AST and `eval`
function from M05-L06](M05-L06-tutorial.html), give them a full
test suite, deliberately break the implementation, and watch
QCheck find the bug. By the end you should have a complete test
file you could copy into a project and adapt.

We have made one choice that runs through the whole tutorial: the
function under test is `eval` from M05-L06, which evaluates a
tree of arithmetic operations to a `float`. We chose it because
it is small enough to fit on one screen, rich enough to have
interesting properties, and from a part of the course (Module 5)
that every student has already seen. Two alternatives would have
worked: [`safe_div` from M04-L05](M04-L04-recursive-types.html)
or a list reversal function. We chose `expr` because it gives
us *both* simple-case unit tests AND structural properties that
exercise the recursive nature of the function. The other two
are mentioned in passing where they would teach something
different.

:::slide

## What this tutorial does

- Take the `expr` evaluator from
  [M05-L06](M05-L06-tutorial.html).
- Write **4-5 OUnit2 unit tests** for specific cases.
- Write **3-4 QCheck properties** for invariants.
- Break one operation deliberately; watch QCheck find the bug.
- Extend the evaluator with a *side effect* (a `Print`).
- Use an **effect-handler stub** from L06 to test it without
  touching stdout.
- Walk away with a complete test file.

:::

## The function under test

From [M05-L06](M05-L06-tutorial.html), restated:

```ocaml
type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec eval = function
  | Num n      -> n
  | Add (a, b) -> eval a +. eval b
  | Sub (a, b) -> eval a -. eval b
  | Mul (a, b) -> eval a *. eval b
  | Div (a, b) -> eval a /. eval b
```

Five constructors, five clauses, recursive on the structure of
the expression. The expected behaviour: the leaf case returns
the carried number; each internal case recursively evaluates its
two sub-expressions and combines with the named operator.

This is small enough to read at a glance but rich enough that
testing it well takes more than one assertion. Each operator is
a separate place a bug could hide. The recursion is a separate
mechanism that could itself be wrong (off-by-one on which sub-
expression goes left). And `Div` introduces a numerical edge case
(division by zero, infinity, NaN) that needs explicit thought.

:::slide

## Function under test

```ocaml
type expr =
  | Num of float
  | Add of expr * expr | Sub of expr * expr
  | Mul of expr * expr | Div of expr * expr

let rec eval = function
  | Num n      -> n
  | Add (a, b) -> eval a +. eval b
  | Sub (a, b) -> eval a -. eval b
  | Mul (a, b) -> eval a *. eval b
  | Div (a, b) -> eval a /. eval b
```

- Five constructors, five clauses.
- Recursion on the tree structure.
- Each operator a separate place a bug could hide.
- `Div` introduces NaN / infinity edge cases.

:::

## Part 1: OUnit2 unit tests

We start with hand-written cases. Each one nails down a *known
specific behaviour*. Five cases:

### Case 1: a leaf

The simplest possible expression: a single `Num`. The evaluator
should return its carried value.

```ocaml
open OUnit2

let test_num_leaf _ =
  assert_equal ~printer:string_of_float 3.0 (eval (Num 3.0))
```

This case looks trivial but exercises one constructor and the
non-recursive base of the function. If the leaf case were wrong
("`Num n -> 0.0`", a copy-paste mistake we have seen in real
code), every test that does *any* arithmetic would also fail; but
the failure would be hard to diagnose. This case isolates the
leaf.

### Case 2: each binary operator

Four small expressions, one per binary constructor:

```ocaml
let test_add _ =
  assert_equal ~printer:string_of_float 5.0
    (eval (Add (Num 2.0, Num 3.0)))

let test_sub _ =
  assert_equal ~printer:string_of_float (-1.0)
    (eval (Sub (Num 2.0, Num 3.0)))

let test_mul _ =
  assert_equal ~printer:string_of_float 6.0
    (eval (Mul (Num 2.0, Num 3.0)))

let test_div _ =
  assert_equal ~printer:string_of_float 0.5
    (eval (Div (Num 1.0, Num 2.0)))
```

One case per operator. Each is the smallest possible expression
that exercises that operator: two leaves joined by one internal
node. The `Sub` case uses asymmetric inputs (`2.0 - 3.0`, not
`3.0 - 2.0`) deliberately, because a swapped-arguments bug would
return `1.0` instead of `-1.0` and the case would catch it; a
symmetric input like `3.0 - 3.0` would not distinguish the bug.

### Case 3: nested expressions

The recursion is its own thing to test. A two-level nested
expression exercises both leaf and recursive cases:

```ocaml
let test_nested _ =
  (* (1 + 2) * (4 - 0.5) = 3 * 3.5 = 10.5 *)
  let expr =
    Mul (Add (Num 1.0, Num 2.0),
         Sub (Num 4.0, Num 0.5))
  in
  assert_equal ~printer:string_of_float 10.5 (eval expr)
```

This is the M05-L06 running example. It exercises the recursive
case for `Mul`, which has two sub-expressions, each of which is
itself a binary node. If the recursion forgot to recurse (e.g.
`Mul (a, _) -> eval a *. eval a`, a typical typo), this case
would catch it.

### Case 4: division by zero

The honest edge case. In IEEE-754 float, `1.0 /. 0.0` is
`infinity`, not an exception. So:

```ocaml
let test_div_by_zero _ =
  assert_equal ~printer:string_of_float infinity
    (eval (Div (Num 1.0, Num 0.0)))
```

We are not asserting that `eval` raises here; we are asserting it
returns `infinity`, which is what float division actually does.
This case documents the function's behaviour on a corner that
naive code might handle differently. If a future revision adds a
guard "raise if dividing by zero", this case will fail
immediately, which is the *desired* signal: someone has changed
the contract, and the test suite is forcing them to acknowledge
it.

If you wanted the *option* shape (`int_eval` returning `int
option`, raising on division by zero), you would replace this
case with `assert_raises`. The choice depends on your contract.

### Assembling the OUnit2 suite

```text
let suite =
  "expr evaluator" >::: [
    "leaf" >:: test_num_leaf;
    "binary operators" >::: [
      "add" >:: test_add;
      "sub" >:: test_sub;
      "mul" >:: test_mul;
      "div" >:: test_div;
    ];
    "nested" >:: test_nested;
    "edges" >::: [
      "division by zero produces infinity" >:: test_div_by_zero;
    ];
  ]

let () = run_test_tt_main suite
```

Seven cases, three named groups. Run with `dune runtest`. All
pass on the correct implementation; the report is seven dots and
an `OK`.

:::slide

## OUnit2 suite shape

```ocaml
let suite =
  "expr evaluator" >::: [
    "leaf" >:: test_num_leaf;
    "binary operators" >::: [
      "add" >:: test_add;
      "sub" >:: test_sub;
      "mul" >:: test_mul;
      "div" >:: test_div;
    ];
    "nested" >:: test_nested;
    "edges" >::: [
      "division by zero" >:: test_div_by_zero;
    ];
  ]
```

One leaf case, one per binary operator with asymmetric inputs, one
nested case to exercise recursion, one edge case (div-by-zero → ∞).

:::

## Part 2: QCheck properties

The unit tests check seven specific behaviours. We now write
*properties* that should hold of any well-formed `expr`. The
generator for `expr` is the new piece; once we have it, the
properties almost write themselves.

### A generator for `expr`

`expr` is not a built-in type, so QCheck does not have a generator
out of the box. We have to build one. The recursive case is the
interesting part: we need to limit recursion depth so we do not
generate infinite trees.

```ocaml
let rec gen_expr depth =
  let open QCheck.Gen in
  if depth <= 0 then
    map (fun n -> Num n) (float_range (-100.0) 100.0)
  else
    oneof [
      map  (fun n -> Num n) (float_range (-100.0) 100.0);
      map2 (fun a b -> Add (a, b)) (gen_expr (depth - 1)) (gen_expr (depth - 1));
      map2 (fun a b -> Sub (a, b)) (gen_expr (depth - 1)) (gen_expr (depth - 1));
      map2 (fun a b -> Mul (a, b)) (gen_expr (depth - 1)) (gen_expr (depth - 1));
      map2 (fun a b -> Div (a, b)) (gen_expr (depth - 1)) (gen_expr (depth - 1));
    ]

let arb_expr =
  QCheck.make ~print:(fun _ -> "<expr>") (gen_expr 4)
```

The generator picks a depth (we hard-code 4 here), and at each
level either generates a leaf or recurses into one of the four
binary constructors. The depth bound is essential: without it
the random walk has a positive probability of recursing
indefinitely, and the test would hang. Depth 4 is enough to
exercise nontrivial trees but not so deep that float arithmetic
loses precision.

`QCheck.make ~print:... gen_expr 4` wraps the generator into a
QCheck `arbitrary` so it can be used with `QCheck.Test.make`.

A real `expr` test would write a slightly fancier printer (one
that produces source-like output, useful in failure messages),
but `<expr>` is enough to see the shape of the lecture.

:::slide

## Generator for `expr`

```ocaml
let rec gen_expr depth =
  let open QCheck.Gen in
  if depth <= 0 then
    map (fun n -> Num n) (float_range (-100.0) 100.0)
  else
    oneof [
      map (fun n -> Num n) (float_range (-100.0) 100.0);
      map2 (fun a b -> Add (a, b))
        (gen_expr (depth - 1)) (gen_expr (depth - 1));
      (* ... Sub, Mul, Div similarly ... *)
    ]
```

- Depth bound prevents infinite recursion.
- At each level: leaf or one of four binary nodes.
- Wrap with `QCheck.make` for use with `QCheck.Test.make`.

:::

### Property 1: `eval` terminates and returns a `float`

The weakest possible property: just *running* `eval` on any
generated expression should return *something*, without exception
(except possibly via division-by-zero producing `infinity`/`nan`,
which is a normal `float` value in IEEE-754, not an exception).

```ocaml
let test_eval_terminates =
  QCheck.Test.make
    ~name:"eval returns a float on any expr"
    arb_expr
    (fun e ->
       let _ : float = eval e in
       true)
```

A trivial body: ignore the result; return `true`. The point of
this property is *not* the boolean it returns; it is that the
test fails if `eval` *raises* on any generated input. If our
generator ever produced an expression that crashed the
evaluator, this property would catch the crash.

This is sometimes called a *liveness* property: "the function
makes progress, on any input." It is the floor of correctness.
Many real-world bugs at the API boundary (unhandled NaN, stack
overflow on deep recursion) get caught by exactly this style of
property.

### Property 2: `Add` is commutative

A genuinely mathematical property. Floating-point addition is *not*
exactly commutative for all inputs (associativity fails too), but
within the bounds of our `float_range`, commutativity holds modulo
floating-point ordering of operands. We will assert exact equality
and see what happens:

```ocaml
let test_add_commutes =
  QCheck.Test.make
    ~name:"Add commutes"
    QCheck.(pair arb_expr arb_expr)
    (fun (a, b) ->
       eval (Add (a, b)) = eval (Add (b, a)))
```

The property: for every pair of expressions `(a, b)`, evaluating
`Add (a, b)` gives the same `float` as evaluating `Add (b, a)`.

For most inputs this is true. But pure IEEE-754 `+.` of two
distant magnitudes can produce slightly different results depending
on the order, because rounding happens at the bit level. Running
this property on enough inputs will likely turn up a counter-
example, and QCheck will shrink it to a small pair where the
order matters.

This is one of the *educational* moments of PBT: a property you
*thought* was self-evidently true turns out to have caveats once
you let a fuzzer hammer at it. The counterexample is genuine: it
exposes a subtlety of floating-point arithmetic the unit tests
would never have surfaced.

### Property 3: identity laws

`Add (Num 0.0, e)` should evaluate to the same value as `e`.
Similarly `Mul (Num 1.0, e)` should give `e`.

```ocaml
let test_add_identity =
  QCheck.Test.make
    ~name:"0 + e = e"
    arb_expr
    (fun e -> eval (Add (Num 0.0, e)) = eval e)

let test_mul_identity =
  QCheck.Test.make
    ~name:"1 * e = e"
    arb_expr
    (fun e -> eval (Mul (Num 1.0, e)) = eval e)
```

Again, modulo floating-point edge cases (multiplying `1.0 *.
infinity` is `infinity`, fine; `1.0 *. nan` is `nan`, but NaN is
not equal to itself in IEEE-754, so `nan = nan` is `false`). For
most generated `expr`s these will hold; for ones where `eval e`
is `nan` the property will trip. That is again a useful signal:
"my law holds *except* in the case where the sub-expression
evaluated to NaN."

### Property 4: distributivity (carefully)

`Mul (a, Add (b, c))` should equal `Add (Mul (a, b), Mul (a, c))`
in mathematics. In IEEE-754, distributivity fails for many inputs
(rounding accumulates differently in the two expansions). We can
write the property as an *approximate* equality:

```ocaml
let test_distributes_approx =
  QCheck.Test.make
    ~name:"Mul distributes over Add (approx)"
    QCheck.(triple arb_expr arb_expr arb_expr)
    (fun (a, b, c) ->
       let lhs = eval (Mul (a, Add (b, c))) in
       let rhs = eval (Add (Mul (a, b), Mul (a, c))) in
       let denom = max (abs_float lhs) (abs_float rhs) in
       abs_float (lhs -. rhs) <= 1e-6 *. denom +. 1e-9)
```

The threshold (`1e-6` of the magnitude plus a small absolute
floor) is a typical pattern for float comparison: equal if the
relative error is small *or* if both sides are small. This
property captures "the algebra is right" in a way that tolerates
the floating-point reality.

:::slide

## Four QCheck properties

1. **`eval` terminates**: a liveness floor.
2. **`Add` commutes**: classical algebra; surfaces float caveats.
3. **Identity laws**: `0 + e = e`, `1 * e = e`.
4. **Distributivity (approx)**: `a * (b + c) ≈ a*b + a*c`, with a
   float tolerance.

Each is one line of OCaml. Each surfaces a different *class* of
bug. Together: a sieve no incorrect `eval` will pass cleanly.

:::

## Part 3: a deliberately buggy implementation

Now the dramatic part. Suppose someone "refactors" `eval` and
introduces a bug. The classic version of this is: they confuse
left and right operand in `Sub`:

```text
let rec bad_eval = function
  | Num n      -> n
  | Add (a, b) -> bad_eval a +. bad_eval b
  | Sub (a, b) -> bad_eval b -. bad_eval a    (* SWAPPED! *)
  | Mul (a, b) -> bad_eval a *. bad_eval b
  | Div (a, b) -> bad_eval a /. bad_eval b
```

A single character changed: `bad_eval b -. bad_eval a` instead of
`bad_eval a -. bad_eval b`. The function still type-checks. All
the leaves still work. `Add`, `Mul`, `Div` are unaffected. Only
`Sub` is wrong.

How does our test suite catch this?

**The OUnit2 cases catch it on `test_sub`** specifically:

```
.F.....
Test expr evaluator:binary operators:sub (...):
  expected -1.0 but got 1.0
FAILED: 1 of 7 tests failed.
```

One case fails out of seven. The failure message names the
function (`Sub`) and the expected and actual values. The
diagnosis is immediate: `Sub` is producing the negative of the
right answer, so the arguments are probably swapped.

**The QCheck properties catch it differently**: most of them
*do not* catch this bug, because `Sub` is irrelevant to additive
commutativity, multiplicative identity, and termination. The
*distributivity* property catches it, because the right-hand side
of distributivity uses `Mul`-of-`Sub` patterns implicitly via the
generated expressions, and the bad subtraction leaks through.

Suppose we *also* add a generator-aware Sub-specific property:

```ocaml
let test_sub_antisymmetric =
  QCheck.Test.make
    ~name:"Sub (a, b) = -(Sub (b, a))"
    QCheck.(pair arb_expr arb_expr)
    (fun (a, b) ->
       eval (Sub (a, b)) = -. (eval (Sub (b, a))))
```

The mathematical fact: `a - b = -(b - a)`. The correct `eval`
satisfies this. The buggy one does, too. Surprise: this property
*does not catch the bug*, because the bug *swaps the operands of
Sub*, which is an involutive transformation: the property is
symmetric under it. This is a real and useful warning sign: a
property whose *form* is symmetric in the inputs cannot catch a
bug that swaps those inputs.

A better property:

```ocaml
let test_sub_eval_matches_minus =
  QCheck.Test.make
    ~name:"eval (Sub (Num a, Num b)) = a -. b"
    QCheck.(pair (float_range (-100.0) 100.0) (float_range (-100.0) 100.0))
    (fun (a, b) -> eval (Sub (Num a, Num b)) = a -. b)
```

This pins `eval` to a *reference*: the OCaml `-.` operator itself.
The buggy `bad_eval` immediately fails. QCheck shrinks; the
counterexample comes out as `(a, b)` with `a` something simple
like `0.0` or `1.0` and `b` something nonzero, the smallest
asymmetric pair the shrinker can find.

Output:

```
random seed: 42
Law eval (Sub (Num a, Num b)) = a -. b: FAIL (1 shrink step).
Test failed on input: (0.0, 1.0).
  expected: -1.0   (correct: a -. b  =  0.0 -. 1.0)
  got:       1.0   (bad_eval: b -. a  =  1.0 -. 0.0)
```

Two-element pair. Bug is obvious. From a 4-element nested
expression that the fuzzer originally found the failure on,
shrinking reduced to "just a pair of two numbers, with subtract
applied"; that is enough.

:::slide

## Watching QCheck catch the bug

```ocaml
let rec bad_eval = function
  | Sub (a, b) -> bad_eval b -. bad_eval a    (* SWAPPED *)
  | ...
```

Right property to catch this:

```ocaml
let test_sub_matches_minus =
  QCheck.Test.make
    QCheck.(pair (float_range (-100.0) 100.0)
                 (float_range (-100.0) 100.0))
    (fun (a, b) -> eval (Sub (Num a, Num b)) = a -. b)
```

Result:

```
Test failed on input: (0.0, 1.0).
expected: -1.0; got: 1.0
```

- A *symmetric* property would NOT catch this (consider why).
- An *anchored* property (pin to `-.`) does, in one shrink step.

:::

## The lesson: choose properties that distinguish bugs

The reason the antisymmetric property `Sub (a, b) = -(Sub (b, a))`
did not catch the bug is illustrative. If a property is invariant
under the *transformation that the bug performs*, the property is
blind to that bug. Swapping operands of `Sub` is the bug; the
property's left and right sides swap operands of `Sub`; the
property is invariant under that swap; therefore the property
holds even on the buggy code.

The general rule, and one of the deeper craft-skills of PBT:
*each property should break some specific implementation that you
care about ruling out.* A good test of a property is to ask, "what
bug would this property catch?" If the answer is "any function
satisfying the right type", the property is too weak.

Properties anchored against an external reference (the
`-.` operator, in our case) are the strongest. They are also the
most demanding to write, because you have to have a reference at
hand. For many functions you do: `List.length`, `( + )`, `( *. )`,
`String.equal` are all in the standard library and serve as
references for the things they implement.

:::slide

## The PBT craft

- If a property is *invariant under the bug's transformation*,
  the property will not catch the bug.
- The strongest properties are *anchored*: pin to an external
  reference (`-.`, `( + )`, `List.length`, ...).
- Ask: "what bug would this property catch?" If "none specific",
  the property is too weak.

:::

## Part 4: putting it together

The complete test file, all parts assembled:

```text
open OUnit2

type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr

let rec eval = function
  | Num n      -> n
  | Add (a, b) -> eval a +. eval b
  | Sub (a, b) -> eval a -. eval b
  | Mul (a, b) -> eval a *. eval b
  | Div (a, b) -> eval a /. eval b

(* --- OUnit2 unit tests --- *)
let test_num_leaf _ =
  assert_equal ~printer:string_of_float 3.0 (eval (Num 3.0))

let test_add _ =
  assert_equal ~printer:string_of_float 5.0
    (eval (Add (Num 2.0, Num 3.0)))

let test_sub _ =
  assert_equal ~printer:string_of_float (-1.0)
    (eval (Sub (Num 2.0, Num 3.0)))

let test_mul _ =
  assert_equal ~printer:string_of_float 6.0
    (eval (Mul (Num 2.0, Num 3.0)))

let test_div _ =
  assert_equal ~printer:string_of_float 0.5
    (eval (Div (Num 1.0, Num 2.0)))

let test_nested _ =
  let e = Mul (Add (Num 1.0, Num 2.0), Sub (Num 4.0, Num 0.5)) in
  assert_equal ~printer:string_of_float 10.5 (eval e)

let test_div_by_zero _ =
  assert_equal ~printer:string_of_float infinity
    (eval (Div (Num 1.0, Num 0.0)))

let ounit_suite =
  "expr evaluator (ounit2)" >::: [
    "leaf"   >:: test_num_leaf;
    "add"    >:: test_add;
    "sub"    >:: test_sub;
    "mul"    >:: test_mul;
    "div"    >:: test_div;
    "nested" >:: test_nested;
    "div by zero" >:: test_div_by_zero;
  ]

(* --- QCheck properties --- *)
let rec gen_expr depth =
  let open QCheck.Gen in
  if depth <= 0 then
    map (fun n -> Num n) (float_range (-100.0) 100.0)
  else
    oneof [
      map  (fun n -> Num n) (float_range (-100.0) 100.0);
      map2 (fun a b -> Add (a, b)) (gen_expr (depth - 1)) (gen_expr (depth - 1));
      map2 (fun a b -> Sub (a, b)) (gen_expr (depth - 1)) (gen_expr (depth - 1));
      map2 (fun a b -> Mul (a, b)) (gen_expr (depth - 1)) (gen_expr (depth - 1));
      map2 (fun a b -> Div (a, b)) (gen_expr (depth - 1)) (gen_expr (depth - 1));
    ]

let arb_expr = QCheck.make ~print:(fun _ -> "<expr>") (gen_expr 4)

let qcheck_tests = [
  QCheck.Test.make
    ~name:"eval terminates"
    arb_expr
    (fun e -> let _ : float = eval e in true);

  QCheck.Test.make
    ~name:"0 + e = e"
    arb_expr
    (fun e -> eval (Add (Num 0.0, e)) = eval e);

  QCheck.Test.make
    ~name:"Sub matches -."
    QCheck.(pair (float_range (-100.0) 100.0)
                 (float_range (-100.0) 100.0))
    (fun (a, b) -> eval (Sub (Num a, Num b)) = a -. b);
]

(* --- entry point ---
   Illustrative only. `run_test_tt_main` calls `exit` after the
   OUnit2 run, so the QCheck call below never fires. In a real
   project, split the two suites into separate test executables
   (see the dune note that follows). *)
let () =
  run_test_tt_main ounit_suite;
  QCheck_runner.run_tests_main qcheck_tests
```

Two suites, one entry point. `run_test_tt_main` exits after
running OUnit2, so the QCheck call below it never actually
fires. In a real project, you split them: one test executable
per suite, each with its own `(test ...)` stanza in `dune`. For
this tutorial we keep them adjacent in one file to highlight
the contrast between specific OUnit2 cases and quantified
QCheck properties.

And the corresponding `dune`:

```dune
(test
 (name test_expr)
 (libraries ounit2 qcheck))
```

Two library dependencies, one test executable, one `dune runtest`
that exercises everything.

:::slide

## The complete test file

```dune
(test
 (name test_expr)
 (libraries ounit2 qcheck))
```

- 7 OUnit2 cases for specific behaviours.
- 3 QCheck properties (terminates, identity, anchored-Sub).
- Single `dune runtest` runs the lot.
- Bug in `eval`? `test_sub` catches it; `Sub matches -.`
  catches it with a shrunk counterexample.

:::

## Part 5: stubbing side effects with effect handlers

So far the function under test is pure: input goes in, output
comes out. Real code is not always like that. Suppose we
extend the AST with a `Print` constructor (mimicking a
statement-style language):

```ocaml skip
type expr =
  | Num of float
  | Add of expr * expr
  | Sub of expr * expr
  | Mul of expr * expr
  | Div of expr * expr
  | Print of expr  (* evaluate, then send to stdout, return value *)
```

The natural evaluator calls `print_endline`:

```ocaml skip
let rec eval = function
  | ...
  | Print e ->
    let v = eval e in
    print_endline (string_of_float v);
    v
```

Now `eval` is not pure: every call writes to stdout. Two
problems for the test suite.

1. **Output noise.** Running 1000 QCheck cases on a generator
   that produces nested `Print`s buries the test runner's
   output in numeric noise.
2. **No oracle.** We cannot assert in OCaml that "the program
   would have printed exactly these values." Capturing stdout
   from inside the same process is awkward; using
   `Unix.dup2` to redirect is brittle.

The clean fix, in OCaml 5: replace the direct call to
`print_endline` with an effect. The effect's *handler* is the
boundary: in production, it calls `print_endline`; in tests,
it records the printed values into a buffer the test can
inspect.

```ocaml skip
open Effect
open Effect.Deep

type _ Effect.t += Print : float -> unit Effect.t

let rec eval = function
  | ...
  | Print e ->
    let v = eval e in
    perform (Print v);
    v
```

`eval` now mentions no I/O primitive. The `perform` is the only
side-effecting construct; the *meaning* of `Print` depends
entirely on whichever handler is in scope.

:::slide

## A side-effecting evaluator

```ocaml skip
type _ Effect.t += Print : float -> unit Effect.t

let rec eval = function
  | ...
  | Print e ->
    let v = eval e in
    perform (Print v);
    v
```

- `Print` is an effect, not a direct I/O call.
- The handler decides what `Print` does.
- Production: `print_endline`. Test: append to a buffer.
- The evaluator's *source* does not change between the two.

:::

### The production handler: print to stdout

```ocaml skip
let with_stdout_printing f =
  try f () with
  | effect (Print v), k ->
    print_endline (string_of_float v);
    continue k ()
```

A four-line wrapper. Any code run inside `with_stdout_printing
(fun () -> ...)` sees `Print` translated to a real
`print_endline`. The semantics are exactly what we removed
from `eval`.

### The test handler: capture the trace

```ocaml skip
let with_captured_printing f =
  let trace = ref [] in
  let result =
    try f () with
    | effect (Print v), k ->
      trace := v :: !trace;
      continue k ()
  in
  (List.rev !trace, result)
```

This handler does not print; it appends to a local list. The
return value is `(list_of_printed_floats, original_result)`.
A test can call

```ocaml skip
let trace, v = with_captured_printing (fun () ->
  eval (Print (Add (Num 1.0, Num 2.0)))) in
assert (trace = [3.0]);
assert (v = 3.0)
```

The evaluator under test is *exactly* the production
evaluator, byte for byte. No mocks, no dependency injection,
no global flags. The substitution happens at the handler
boundary.

:::slide

## Stubbing Print: production vs test handler

```ocaml skip
(* production *)
let with_stdout_printing f =
  try f () with
  | effect (Print v), k ->
    print_endline (string_of_float v); continue k ()

(* test *)
let with_captured_printing f =
  let trace = ref [] in
  let r = try f () with
    | effect (Print v), k -> trace := v :: !trace; continue k ()
  in (List.rev !trace, r)
```

- Same `eval`. Two handlers.
- Production: real I/O.
- Test: capture into a list the test can assert on.

:::

### A QCheck property that uses the stub

The combination is striking. We can now write QCheck
properties that *predict* the printed output:

```ocaml skip
let test_print_returns_value =
  QCheck.Test.make
    ~name:"Print e returns the same value as e"
    arb_expr
    (fun e ->
       let trace, v = with_captured_printing (fun () -> eval (Print e)) in
       List.length trace = 1 && List.hd trace = v)
```

This property asserts two things at once: `Print e` prints
exactly one value, and the value it prints equals the value
it returns. The production handler would not let us assert
this without intercepting stdout; the test handler does.

The same recipe scales to *any* side effect: file I/O, network,
database, random number generation, time-of-day, even
non-determinism in a scheduler. Declare an effect, perform
inside the code under test, swap the handler between
production and test.

:::slide

## QCheck + captured trace

```ocaml skip
let test_print_returns_value =
  QCheck.Test.make ~name:"Print e returns e's value"
    arb_expr
    (fun e ->
       let trace, v =
         with_captured_printing (fun () -> eval (Print e))
       in
       List.length trace = 1 && List.hd trace = v)
```

- Generate any expression, wrap in `Print`.
- Run under the test handler; capture the trace.
- Assert that what was printed matches what was returned.
- Stubbing a side effect = swapping a handler.

:::

The technique generalises beyond testing. The same handler
swap lets a debugger record every print, lets a
deterministic-replay system log every random choice, lets a
golden-file test compare actual vs expected traces, lets a
property-based test on a "would-be-stateful" function
exercise it as if it were pure. Effect handlers turn side
effects into *programmable* boundaries.

## Activity

:::quiz code id=M09-L08-q1
The `eval` function above does not have an explicit property
asserting that *multiplication by zero gives zero*. Write a
QCheck property that:

- takes an arbitrary `expr` (use `arb_expr`),
- evaluates `Mul (Num 0.0, e)`,
- and checks the result equals `0.0`.

The expected name of the property: `"0 * e = 0"`.

Be careful: floating-point `0.0 *. nan` is `nan`, not `0.0`. The
property as stated will trip on any `expr` whose evaluation
yields NaN. You may add a `QCheck.assume (not (Float.is_nan
(eval e)))` precondition if you wish; or leave it and treat the
resulting failure as a feature, not a bug, of strict floating-
point semantics.

```ocaml
let test_mul_zero =
  failwith "not implemented"
```

```ocaml skip
let () =
  (* Pretend the student's property has been threaded into
     QCheck and run.  The point of this check cell is to
     verify the *property formula* is correct on a handful of
     non-NaN inputs. *)
  let prop e = eval (Mul (Num 0.0, e)) = 0.0 in
  assert (prop (Num 5.0));
  assert (prop (Add (Num 1.0, Num 2.0)));
  assert (prop (Sub (Num 3.0, Num 1.0)));
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```ocaml
let test_mul_zero =
  QCheck.Test.make
    ~name:"0 * e = 0"
    arb_expr
    (fun e ->
       QCheck.assume (not (Float.is_nan (eval e)));
       eval (Mul (Num 0.0, e)) = 0.0)
```

Four lines (counting the `assume`): a property whose formal
statement is just one equation, plus a NaN guard.

:::

:::quiz mcq id=M09-L08-q2
A colleague writes a single QCheck property for the
[`safe_div` function from M04-L05](M04-L04-recursive-types.html):

```ocaml skip
let test = QCheck.Test.make QCheck.(pair int int)
  (fun (a, b) ->
     match safe_div a b with
     | Some q -> q * b + (a mod b) = a   (* division law *)
     | None -> b = 0)
```

The property passes on 1000 random inputs. Why is this a *stronger*
test than a hand-written unit test that just checks
`safe_div 10 2 = Some 5`?

- [ ] Because PBT proves correctness; unit tests merely sample.
- [x] Because the property exercises *every* generated `(a, b)`
  pair, including unusual ones (negatives, zero divisors,
  overflow-adjacent), and the property simultaneously checks the
  arithmetic law AND the contract that `None` means "divisor was
  zero".
- [ ] Because OCaml's type system makes properties redundant.
- [ ] Because PBT runs faster than unit tests.

**Why:** PBT *generates* inputs the author would not think to
write, including negatives, zero divisors, and large values. The
property checks two things at once: when `safe_div` returns
`Some q`, the result obeys the division law; when it returns
`None`, the contract guarantees the divisor was zero. A unit
test checks one pair `(10, 2)` and trusts that the rest of the
function behaves analogously. PBT does *not* prove correctness
(1000 cases is still a sample), but it is a much stronger sample
than one case can be.
:::

## Common pitfalls

**Pitfall 1: properties that hold of the bug.** Discussed above.
The antisymmetric `Sub` property satisfies the buggy
implementation; an anchored property does not. Anchor when you
can.

**Pitfall 2: float equality in properties.** `nan <> nan`,
`0.1 +. 0.2 <> 0.3`. Use approximate comparison
(`abs_float (a -. b) < eps`) when working with floats, or
restrict the generator to integers when you do not want to
think about it.

**Pitfall 3: generators that produce mostly trivial inputs.**
A generator that almost always returns `Num 0.0` will not exercise
much. Use `QCheck.oneof` to balance leaves and internal nodes.

**Pitfall 4: missing edge cases in the manual suite.** Unit
tests are still the place for *specific known behaviours*. If
the spec says "the empty list returns 0", a unit test that
checks exactly that is more honest than a property which sort-of
implies it.

**Pitfall 5: trusting the test suite to be exhaustive.** Even
when OUnit2 and QCheck agree, you have *not* proved the function
correct. You have a strong sample. Trust it; do not deify it.

:::slide

## Common pitfalls

1. **Properties invariant under the bug**: anchor properties
   against an external reference.
2. **Float equality**: use approximate comparison, or restrict
   to ints.
3. **Trivial-input generators**: balance leaves and internal
   nodes.
4. **Missing specific cases**: unit tests for *known* behaviours,
   PBT for *invariants*.
5. **Strong sample, not a proof**: testing is evidence, not
   verification.

:::

## What you should be able to do now

After this module:

- Articulate why a well-typed program can still be wrong, and
  what testing adds on top of types
  ([L01](M09-L01-why-test-typed-code.html)).
- Write OUnit2 unit tests for any module of your own:
  `assert_equal`, `assert_raises`, `>::`, `TestList`, `dune`
  integration ([L02](M09-L02-unit-testing.html)).
- Write QCheck properties for invariants of a function:
  generators, properties, shrinking, statistics
  ([L03](M09-L03-property-based-testing.html)).
- Build custom generators (sorted lists, valid BSTs, DAGs)
  by construction, and bundle generator + printer + shrinker
  into an `arbitrary` ([L04](M09-L04-custom-generators-stateful.html)).
- Test stateful data structures against a reference
  implementation using sequences of operations
  ([L05](M09-L05-model-based-testing.html)).
- Write code that uses **effect handlers** for non-local
  control flow, including cooperative concurrency
  ([L06](M09-L06-effect-handlers.html),
  [L07](M09-L07-fibers-concurrency.html)).
- Combine OUnit2 + QCheck on a real function, including
  catching a deliberately introduced bug, and stubbing side
  effects with effect handlers (this lecture).

The next module, [Memory safety and security](M10-L01-ub-and-the-zoo.html),
moves in the other direction: from what tests catch to what
*types and the runtime* catch. We have argued that types and tests
are complementary; M10 makes the type side precise in the
context of memory safety, with security as the application.

:::slide

## What you can do now

- Explain why a well-typed program can still be wrong (L1).
- Write OUnit2 unit tests (L2).
- Write QCheck properties for invariants (L3).
- Build custom generators and stateful PBT harnesses (L4).
- Apply model-based testing to stateful code (L5).
- Use effect handlers for non-local control flow and
  cooperative concurrency (L6-L7).
- Combine OUnit2 + QCheck + handler-stubs on a real function
  (this lecture).

Next module: M10 on memory safety. Tests catch behaviour;
*types and the runtime* catch the next layer.

:::

## Reading

- **Cornell CS3110**, *Testing, Debugging, and Specifications*
  (chapter spanning unit testing, randomised testing, and
  specifications):
  <https://cs3110.github.io/textbook/chapters/correctness/index.html>
- **QCheck README and tutorial**:
  <https://github.com/c-cube/qcheck>
- **OUnit2 README and API documentation**:
  <https://github.com/gildor478/ounit>
- **Real World OCaml**, *Testing*:
  <https://dev.realworldocaml.org/testing.html>

## Sources

This tutorial's prose, worked examples, and quizzes are original
to this course. The `expr` AST and `eval` function are reused
from [M05-L06](M05-L06-tutorial.html), itself original. The
deliberate-bug pattern (swapping operands of `Sub`) is folklore
in the PBT community, presented here in our own words. Cornell
CS3110's testing chapter is the conceptual antecedent for the
unit-and-property structure of this lecture; its prose is
CC BY-NC-ND licensed and has not been derivatively reused. The
QCheck library (Simon Cruanes and contributors) and OUnit2
(Sylvain Le Gall and contributors) are linked above and used
through their public APIs. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
