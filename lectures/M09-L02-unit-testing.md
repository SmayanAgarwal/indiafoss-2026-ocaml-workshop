---
title: "Unit testing in OCaml with OUnit2"
lecture_no: 2
week: 9
duration_target_min: 25
concepts: [unit testing, OUnit2, assert_equal, assert_raises, test fixtures, test suites, dune integration]
keywords: [OCaml, OUnit2, unit test, assert_equal, assert_raises, dune, TestList, TestCase]
activity_question: "Suppose you have a Stack module with push, pop, peek, and is_empty. Write an OUnit2 test that asserts that calling pop on an empty stack raises an exception. Which OUnit2 primitive do you reach for?"
think_about_this: "If a single test_case fails partway through, what happens to the rest of the cases in the same TestList? Does OUnit2 stop, or does it keep going? What is the right answer for a test runner, and why?"
reading:
  - title: "Cornell CS3110, OUnit"
    url: https://cs3110.github.io/textbook/chapters/correctness/ounit.html
  - title: "OUnit2 GitHub repository and API docs"
    url: https://github.com/gildor478/ounit
---

# Unit testing in OCaml with OUnit2

[Lecture 1](M09-L01-why-test-typed-code.html) made the case that
types and tests are complementary: types catch type errors on every
build, tests catch behaviour on the inputs you choose. The example
to keep in mind was a `sort` of type `'a list -> 'a list` that
returned its input unchanged. The compiler was happy; the function
was wrong; a test would have caught it.

This lecture is the practical follow-up. We pick *one* unit-testing
tool, [**OUnit2**](https://github.com/gildor478/ounit), and use it
end to end. We integrate it into a `dune` project, we learn the
small set of primitives the framework exposes (`assert_equal`,
`assert_bool`, `assert_raises`), and we build a test suite for a
real module, the `Stack` from [M07-L04](M07-L04-module-basics.html).
By the end you should be able to write a test file for any module
you have written so far in the course.

OUnit2 is not the only choice. The OCaml ecosystem has at least
three other testing libraries you will encounter eventually:
[Alcotest](https://github.com/mirage/alcotest) (used in *Real
World OCaml*), [`ppx_inline_test`](https://github.com/janestreet/ppx_inline_test)
(Jane Street's preferred style), and
[expect tests](https://github.com/janestreet/ppx_expect) (output
capture). They are all reasonable. We use OUnit2 because Cornell's
CS3110 uses it, because it has the cleanest mapping from the
generic unit-test vocabulary (test case, suite, fixture, assertion)
to OCaml code, and because *one* tool used consistently is more
useful than four tools each used briefly. Skim the others later if
you encounter them; the conceptual content carries over.

:::slide

## What this lecture covers

- One unit-testing tool: **OUnit2**.
- The primitives: `assert_equal`, `assert_bool`, `assert_raises`.
- Test organisation: `TestList`, `TestCase`, fixtures.
- `dune` integration: how to wire tests into a project.
- Worked example: a test suite for the `Stack` from M07-L04.

:::

## Vocabulary

Three words appear constantly in unit-testing literature, and they
mean the same thing across frameworks. Worth pinning them down now.

A **test case** is a single named scenario: a fixed input, an
expected output, and the boilerplate that compares them. "If we
push three items onto an empty stack and then peek, we see the
third item" is one test case.

A **test suite** is a collection of test cases run together. The
suite is the unit of execution: you tell the framework to run a
suite, and the framework reports how many cases passed, how many
failed, and where each failure was.

A **test fixture** is the setup-and-teardown code that runs around
each case so the case starts from a known state. For a stack, the
fixture is "create a fresh empty stack." For a database test, it
would be "open a transaction, run the test, roll back at the end."
Fixtures exist so the cases stay short and independent: case 7 must
not depend on whether case 6 left the world in some particular
state.

:::slide

## Three words

| Term | Meaning |
| --- | --- |
| **Test case** | A single named scenario: input + expected output + comparison. |
| **Test suite** | A collection of cases run as one unit. |
| **Test fixture** | Setup/teardown that runs around each case. |

- The framework's job is to *run the cases* and *report what
  failed*. Everything else is you.

:::

## OUnit2 at a glance

OUnit2 is a small library: about a dozen public functions, most of
which are variants of "assert that this thing is true." The API
divides into three layers:

1. **Assertions**: the calls inside a test case that compare actual
   to expected. `assert_equal`, `assert_bool`, `assert_raises`,
   `assert_failure`.
2. **Test constructors**: the values that *are* tests. `test_case`
   wraps a function into a runnable case; `>::` is the
   infix-operator shorthand for the same thing. `TestList` groups
   cases.
3. **Runners**: the entry point that actually executes the suite
   and prints results. `run_test_tt_main` is the standard one.

That is essentially the whole framework. The rest is matter of
arranging your own code into the right shape so each function under
test gets its own case.

:::slide

## OUnit2's three layers

1. **Assertions** inside a case:
   - `assert_equal expected actual`
   - `assert_bool message condition`
   - `assert_raises exn (fun () -> ...)`
2. **Test constructors** that *are* tests:
   - `"name" >:: (fun _ -> ...)` builds one case.
   - `TestList [c1; c2; c3]` groups cases into a suite.
3. **Runners** that execute:
   - `run_test_tt_main suite`

:::

## A first test, by hand

Before we let `dune` do the work, let us see the smallest possible
OUnit2 program. The shape:

```ocaml skip
open OUnit2

let test_addition _ =
  assert_equal 4 (2 + 2)

let suite =
  "arithmetic" >::: [
    "two plus two" >:: test_addition;
  ]

let () = run_test_tt_main suite
```

Six lines of test code plus a one-line entry point. The pieces:

- `open OUnit2` brings the framework into scope.
- `test_addition` is the case body. It is a function taking one
  argument (a context, which we ignore with `_`); inside, we call
  `assert_equal 4 (2 + 2)`.
- `"two plus two" >:: test_addition` constructs a `TestCase` whose
  display name is `"two plus two"`. The `>::` operator is just
  syntactic sugar for `test_case`.
- `"arithmetic" >::: [ ... ]` constructs a named *list* of cases.
  Note the extra colon: `>::` makes a single case, `>:::` makes a
  list. (This will catch you at least once; we have caught it
  several times each.)
- `run_test_tt_main` is the entry point. It parses the test-runner
  CLI arguments (so you get `-verbose`, filtering by name, etc.
  for free) and runs the suite.

Run this program; you should see something like:

```
.
Ran: 1 test in: 0.00 seconds.
OK
```

A passing test is a dot. A failure is an `F` plus a stack of
context. The summary line at the bottom tells you the count.

:::slide

## The smallest OUnit2 program

```ocaml
open OUnit2

let test_addition _ =
  assert_equal 4 (2 + 2)

let suite =
  "arithmetic" >::: [
    "two plus two" >:: test_addition;
  ]

let () = run_test_tt_main suite
```

- `>::` builds one case from a name and a function.
- `>:::` builds a *named list* of cases.
- `run_test_tt_main` runs the suite and prints the report.

:::

## Wiring it into `dune`

A real OCaml project has its tests in a separate `test/` directory
with its own `dune` file. The minimal `dune` for an OUnit2 test is:

```dune
(test
 (name test_stack)
 (libraries ounit2 my_library))
```

The `(test ...)` stanza tells `dune` that this directory contains a
test executable: a regular OCaml program that, when run, exercises
your library. `(name test_stack)` is the module name (so the file
on disk is `test_stack.ml`). `(libraries ounit2 my_library)` lists
the libraries to link against: OUnit2 plus whatever you are testing.

To run the suite:

```
dune runtest
```

`dune` rebuilds anything stale, runs the test executable, and shows
its output. If all tests pass, you see the summary line. If a test
fails, `dune` exits non-zero, which is exactly the signal you want
in CI: a failing test breaks the build, just like a type error
does.

:::slide

## `dune` integration

```dune
(test
 (name test_stack)
 (libraries ounit2 my_library))
```

- File on disk: `test/test_stack.ml`.
- `dune runtest` builds and runs.
- Failing tests exit non-zero; CI fails the build.

This is the same pattern as a regular `(executable ...)` stanza
plus a runtest hook.

:::

A small `dune` aside: when your library lives in `lib/` and its
tests live in `test/`, the test file imports the library by its
public module name. So if `lib/dune` has `(library (name stack))`,
then `test/test_stack.ml` writes `open Stack` to bring its
functions into scope. We will see this on a real example shortly.

## The three primitive assertions

OUnit2's vocabulary of *what counts as a failure* is small. Three
assertions cover almost everything you will ever write.

### `assert_equal`

The workhorse. Used for "did this expression evaluate to that
value?"

```ocaml
open OUnit2
let _ = assert_equal 6 (1 + 2 + 3)
```

The argument order is *expected first, actual second*. This matters
because the failure message says "expected E, got A"; if you swap
them, the messages will be misleading even though the test still
detects the failure.

By default `assert_equal` uses OCaml's structural equality `=`. If
you want to compare values for which `=` is the wrong notion
(records of floating point with NaNs, abstract types, etc.), pass
an explicit `~cmp`:

```ocaml skip
assert_equal ~cmp:(fun a b -> abs_float (a -. b) < 1e-9) 0.1 (0.05 +. 0.05)
```

And a `~printer` so the failure message shows the values in a
useful form:

```ocaml skip
assert_equal ~printer:string_of_int 6 (1 + 2 + 3)
```

If `assert_equal` fails without a printer, the message says
"expected ... got ..." with no values, because OUnit2 has no
generic way to format arbitrary OCaml values as strings. Adding a
printer turns the failure from cryptic to obvious. Get into the
habit of passing it.

### `assert_bool`

Used when the test is not "two things are equal" but "some
condition is true." First argument is a message printed on failure;
second argument is the condition.

```ocaml skip
assert_bool "list should be empty" (List.length xs = 0)
```

You could write the same thing as `assert_equal 0 (List.length
xs)`, and most of the time `assert_equal` is what you want. But
when the condition is a compound property ("sorted and same
length"), `assert_bool` reads more naturally.

### `assert_raises`

The one assertion that has no obvious analogue in equality testing:
"this expression should raise the following exception." Used to
test the *negative* path: error cases, contract violations.

```ocaml skip
assert_raises Stack.Empty (fun () -> Stack.pop empty_stack)
```

The expected exception is the first argument; the second is a
*thunk* (a `unit -> _` function) that the framework will call. If
the thunk raises the expected exception, the case passes. If it
raises a different exception or returns normally, the case fails.

The thunk is essential. If you wrote `assert_raises Stack.Empty
(Stack.pop empty_stack)` without the `fun () ->`, OCaml would
evaluate `Stack.pop empty_stack` *before* `assert_raises` was
called, and the exception would escape uncaught. The thunk hands
the framework an unevaluated computation it can wrap in its own
`try ... with`.

:::slide

## Three primitive assertions

| Name | Use it for | Argument order |
| --- | --- | --- |
| `assert_equal` | "These two values are equal" | `expected actual` |
| `assert_bool` | "This condition is true" | `message condition` |
| `assert_raises` | "This thunk raises that exception" | `exn thunk` |

Helpers worth knowing:
- `~printer:string_of_int` on `assert_equal` for readable failures.
- `~cmp:(...)` for custom equality.
- `assert_raises` *requires* a thunk; pass `fun () -> ...`.

:::

## Test fixtures: setup and teardown

For tests on stateful code (a mutable stack, a database handle, a
file), each case must start from a known state. OUnit2 has two
ways to do this.

The *small* way: a helper function that returns a fresh value, and
each case calls it.

```ocaml skip
let fresh_stack () =
  let s = Stack.create () in
  s

let test_peek_one _ =
  let s = fresh_stack () in
  Stack.push 42 s;
  assert_equal (Some 42) (Stack.peek s)
```

This is the OCaml idiom for fixtures most of the time: call the
setup helper at the top of each case. Teardown happens
automatically: when the case body exits, the stack is unreferenced
and the GC collects it.

The *bigger* way: OUnit2's `bracket` helper, which makes the
setup-run-teardown structure explicit and is useful when teardown
is non-trivial (closing a file, releasing a lock):

```ocaml skip
let test_with_file _ =
  bracket
    (fun _ -> open_in "fixture.txt")        (* setup *)
    (fun _ -> close_in)                     (* teardown *)
    (fun ic ->                              (* test body *)
       let line = input_line ic in
       assert_equal "hello" line)
```

For a pure data structure like a stack, the small way is plenty.
For tests that hold resources, the bigger way ensures teardown
runs even if the body raises.

:::slide

## Fixtures: keep each case independent

```ocaml
let fresh_stack () = Stack.create ()

let test_peek_one _ =
  let s = fresh_stack () in
  Stack.push 42 s;
  assert_equal (Some 42) (Stack.peek s)
```

- A helper returns a fresh value; each case calls it.
- For resource-holding tests, use `bracket setup teardown body`
  so teardown runs even if the body raises.

:::

## Organising tests: `TestList` and named hierarchies

A real test file has dozens of cases, not one. OUnit2 lets you
group them into a tree of `TestList` nodes, each with a name:

```ocaml skip
let suite =
  "stack" >::: [
    "creation" >::: [
      "fresh stack is empty" >:: test_fresh_is_empty;
    ];
    "push and pop" >::: [
      "push then pop returns pushed" >:: test_push_pop_one;
      "push twice, pop twice, LIFO order" >:: test_push_pop_lifo;
    ];
    "errors" >::: [
      "pop on empty raises" >:: test_pop_empty_raises;
      "peek on empty raises" >:: test_peek_empty_raises;
    ];
  ]
```

This is just nested lists of cases, with names attached. The names
have two purposes: they appear in test output, so you can tell *which*
case failed; and they form a path you can filter on from the CLI
(`./test_stack.exe -only-test "stack:errors:pop on empty raises"`).

For small suites, a flat list of cases is fine. For anything beyond
a dozen cases, grouping pays off, because the names give you a
table of contents to your tests.

## Worked example: a test suite for `Stack`

We now write a full test suite for the `Stack` module from
[M07-L04](M07-L04-module-basics.html). The module under test:

```ocaml
exception Empty

module Stack = struct
  type 'a t = { mutable items : 'a list }

  let create () = { items = [] }

  let is_empty s = s.items = []

  let push x s = s.items <- x :: s.items

  let pop s =
    match s.items with
    | [] -> raise Empty
    | x :: rest -> s.items <- rest; x

  let peek s =
    match s.items with
    | [] -> raise Empty
    | x :: _ -> x
end
```

A small change from M07-L04: instead of a single global stack, each
call to `Stack.create ()` returns a fresh stack value, and `push`/
`pop`/`peek`/`is_empty` take that value as an argument. This is
the standard "value-oriented" shape for a data structure, and it
makes tests much easier because every case can start from a fresh
stack.

We also moved the empty-stack behaviour: instead of returning `None`,
`pop` and `peek` now *raise* `Empty`. This gives us a chance to
exercise `assert_raises`.

:::slide

## The `Stack` under test

```ocaml
exception Empty

module Stack = struct
  type 'a t = { mutable items : 'a list }
  let create () = { items = [] }
  let is_empty s = s.items = []
  let push x s = s.items <- x :: s.items
  let pop s = match s.items with
    | [] -> raise Empty
    | x :: rest -> s.items <- rest; x
  let peek s = match s.items with
    | [] -> raise Empty
    | x :: _ -> x
end
```

- A *value-oriented* stack: every operation takes a `Stack.t`.
- Empty-stack operations raise `Empty` (good target for
  `assert_raises`).

:::

### Positive cases

The positive cases assert that the stack behaves as expected on
normal inputs. We start with the smallest possible cases:

```ocaml
open OUnit2

let test_fresh_is_empty _ =
  let s = Stack.create () in
  assert_bool "fresh stack should be empty" (Stack.is_empty s)

let test_push_makes_nonempty _ =
  let s = Stack.create () in
  Stack.push 42 s;
  assert_bool "stack should be nonempty after push"
    (not (Stack.is_empty s))

let test_push_peek _ =
  let s = Stack.create () in
  Stack.push 42 s;
  assert_equal ~printer:string_of_int 42 (Stack.peek s)

let test_push_pop_returns_pushed _ =
  let s = Stack.create () in
  Stack.push 42 s;
  assert_equal ~printer:string_of_int 42 (Stack.pop s)
```

Four cases, each exercising one specific behaviour. Each starts
with `Stack.create ()`, so they are independent: no case can
corrupt another.

Now a slightly bigger case that exercises the *order* property of
a stack: last in, first out.

```ocaml
let test_lifo_three _ =
  let s = Stack.create () in
  Stack.push 1 s;
  Stack.push 2 s;
  Stack.push 3 s;
  assert_equal ~printer:string_of_int 3 (Stack.pop s);
  assert_equal ~printer:string_of_int 2 (Stack.pop s);
  assert_equal ~printer:string_of_int 1 (Stack.pop s);
  assert_bool "stack empty after popping all" (Stack.is_empty s)
```

One case with four assertions. That is fine; each assertion
checks a specific consequence of the same sequence of operations.
If any fails, the failure message identifies *which*
`assert_equal` failed, because OUnit2 reports the source line of
the failing call.

:::slide

## Positive cases: the LIFO property

```ocaml
let test_lifo_three _ =
  let s = Stack.create () in
  Stack.push 1 s;
  Stack.push 2 s;
  Stack.push 3 s;
  assert_equal ~printer:string_of_int 3 (Stack.pop s);
  assert_equal ~printer:string_of_int 2 (Stack.pop s);
  assert_equal ~printer:string_of_int 1 (Stack.pop s);
  assert_bool "empty after popping all" (Stack.is_empty s)
```

- Several assertions in one case is fine if they share setup.
- The failure message identifies the specific line that failed.

:::

### Negative cases

The cases that exercise *error paths*: what happens on inputs the
function is *not* supposed to accept? For our stack, the obvious
ones are `pop` and `peek` on an empty stack. Both should raise
`Empty`.

```ocaml
let test_pop_empty_raises _ =
  let s = Stack.create () in
  assert_raises Empty (fun () -> Stack.pop s)

let test_peek_empty_raises _ =
  let s = Stack.create () in
  assert_raises Empty (fun () -> Stack.peek s)
```

Note the thunks. `fun () -> Stack.pop s` is a *function* that, when
called, will try to pop from the empty stack. OUnit2 calls it
inside its own `try ... with`, so the exception is caught and
compared against the expected one. If we had written
`assert_raises Empty (Stack.pop s)` (no thunk), OCaml would
evaluate `Stack.pop s` first, the exception would escape, and the
test would crash with an uncaught exception instead of failing
cleanly.

A subtler negative case: a stack that has had items pushed and
then *all* popped should be back to empty, and a further pop
should raise `Empty`.

```ocaml
let test_pop_after_drain_raises _ =
  let s = Stack.create () in
  Stack.push 1 s;
  Stack.push 2 s;
  let _ = Stack.pop s in
  let _ = Stack.pop s in
  assert_raises Empty (fun () -> Stack.pop s)
```

This is testing a *state transition*: empty → push → push → pop →
pop → empty. If `pop` left the internal list in some half-broken
state, this case would catch it.

:::slide

## Negative cases: exercise the error paths

```ocaml
let test_pop_empty_raises _ =
  let s = Stack.create () in
  assert_raises Empty (fun () -> Stack.pop s)
```

- Thunk is essential: pass `fun () -> ...`, not the value itself.
- Test both initial empty *and* "drained back to empty"; these
  often diverge in buggy implementations.

:::

### Assembling the suite

The cases assemble into a hierarchical suite:

```ocaml skip
let suite =
  "stack" >::: [
    "creation" >::: [
      "fresh is empty" >:: test_fresh_is_empty;
      "push makes nonempty" >:: test_push_makes_nonempty;
    ];
    "single push" >::: [
      "push then peek" >:: test_push_peek;
      "push then pop" >:: test_push_pop_returns_pushed;
    ];
    "LIFO" >::: [
      "three pushes, three pops" >:: test_lifo_three;
    ];
    "errors" >::: [
      "pop on empty raises" >:: test_pop_empty_raises;
      "peek on empty raises" >:: test_peek_empty_raises;
      "pop after drain raises" >:: test_pop_after_drain_raises;
    ];
  ]

let () = run_test_tt_main suite
```

Eight cases, four named groups. Running `dune runtest` (or
executing the test binary directly) prints something like:

```
........
Ran: 8 tests in: 0.00 seconds.
OK
```

Eight dots, eight passing cases.

If we deliberately break the implementation, say by changing
`push` to do nothing:

```ocaml skip
let push _ _ = ()        (* deliberately broken *)
```

then the run looks like:

```
.FFFFFFF
Ran: 8 tests in: 0.01 seconds.
test stack:single push:push then peek (...):
  expected 42 but got None
test stack:LIFO:three pushes, three pops (...):
  expected 3 but got None
...
FAILED: 7 of 8 tests failed.
```

A single broken function takes out the seven cases that
exercise it; the eighth (`fresh is empty`) still passes because
it does not depend on `push`. That is exactly the signal you
want: the test output points at the function whose contract
just broke.

:::slide

## A deliberately broken implementation

If we change `push` to a no-op:

```ocaml
let push _ _ = ()        (* DELIBERATELY BROKEN *)
```

the test run prints:

```
.FFFFFFF
Ran: 8 tests in: 0.01 seconds.
FAILED: 7 of 8 tests failed.
```

- Seven cases fail, one passes (the one that doesn't push).
- Test output identifies *which* group of cases failed.
- This is the test runner doing exactly its job.

:::

## What OUnit2 does NOT do

It is worth being honest about the boundary. OUnit2 is a *test
runner*: it executes named cases, runs assertions, reports
failures. It does not, on its own:

- **Generate inputs.** Every case you write is a single
  hand-picked input. For random exploration of an input space,
  see [Lecture 3](M09-L03-property-based-testing.html) and QCheck.
- **Measure code coverage.** "Did my tests touch every branch of
  the implementation?" is the job of a coverage tool like
  [`bisect_ppx`](https://github.com/aantron/bisect_ppx). OUnit2
  has no built-in coverage view.
- **Compare against snapshots.** "The output matched what I
  captured last time" is the realm of *expect tests*. OUnit2's
  `assert_equal` requires you to write down the expected value
  inline.

These are not OUnit2 weaknesses; they are deliberate scope
choices. OUnit2 does one thing (run cases, report failures) and
does it cleanly. The other things are jobs for other libraries.

## Test design heuristics

A short list of habits that pay off as your test suite grows.

**Heuristic 1: name your cases after the behaviour, not the
function.** "pop on empty raises Empty" is informative; "test_pop_1"
is not. When a case fails in CI six months from now, the name is
the only context you have. Make it useful.

**Heuristic 2: arrange / act / assert.** Each case body should have
three sections, in order: setup the world (arrange), call the
function under test (act), check the result (assert). This is a
universal pattern across testing frameworks. Resist the urge to
interleave them.

**Heuristic 3: one logical behaviour per case.** A case that
asserts five unrelated properties is hard to interpret when one
of them fails. (Multiple assertions on the same setup, as in
`test_lifo_three`, are fine; that is *one* behaviour, namely the
LIFO property, expressed with several checks.)

**Heuristic 4: positive AND negative.** For every function, ask:
what is the contract? What inputs should it accept? What inputs
should it reject? Test both. Most production bugs we have seen
are in the error paths, which are often less exercised.

**Heuristic 5: tests are code; refactor them like code.** If
three cases share the same setup, extract a fixture helper. If a
group of cases tests the same property under different inputs,
write a parameterised test (a function that *makes* a case from
some input):

```ocaml
let lifo_test input expected =
  let name = "LIFO on " ^ string_of_int (List.length input) ^ " items" in
  name >:: (fun _ ->
    let s = Stack.create () in
    List.iter (fun x -> Stack.push x s) input;
    let popped = List.init (List.length input)
                   (fun _ -> Stack.pop s) in
    assert_equal expected popped)

let suite =
  "stack" >::: [
    lifo_test [1; 2; 3] [3; 2; 1];
    lifo_test [42]      [42];
    lifo_test []        [];
  ]
```

Three cases for the price of one helper function.

:::slide

## Test design heuristics

1. **Name** cases after behaviour, not function names.
2. **Arrange / act / assert** inside each case body.
3. **One logical behaviour** per case (several assertions on the
   same setup is fine).
4. **Positive AND negative** cases for every function.
5. **Tests are code.** Refactor: fixture helpers, parameterised
   cases.

:::

## Activity

:::quiz mcq id=M09-L02-q1
You have a function `fact : int -> int` that computes factorial.
You write `assert_equal 120 (fact 5)` in an OUnit2 case, and the
test fails. The output reads:

```
test "factorial 5" (...):
  expected ... got ...
```

Why are the actual values missing from the message, and what is
the fix?

- [ ] OUnit2 is broken; report the issue upstream.
- [ ] The argument order is wrong; should be `assert_equal (fact 5) 120`.
- [x] OUnit2 cannot generically print arbitrary OCaml values; pass
  `~printer:string_of_int` to `assert_equal` to get readable output.
- [ ] The function `fact` does not return an `int`, so the test is
  ill-typed.

**Why:** OCaml has no generic value-to-string function, so OUnit2
cannot print expected and actual without a printer. The argument
order *does* matter, but for failure message clarity rather than
correctness ("expected E, got A" reads sensibly only with
`expected` first). The fix is to pass `~printer:string_of_int`,
which OUnit2 calls on both values to format the failure message.
:::

:::quiz mcq id=M09-L02-q2
Which of the following is the correct way to assert that
`List.hd []` raises `Failure "hd"` using OUnit2?

- [ ] `assert_raises (Failure "hd") (List.hd [])`
- [x] `assert_raises (Failure "hd") (fun () -> List.hd [])`
- [ ] `assert_equal (Failure "hd") (List.hd [])`
- [ ] `assert_bool "should raise" (List.hd [] = raise (Failure "hd"))`

**Why:** `assert_raises` expects a *thunk* (a `unit -> _`
function), not a value. Without the `fun () ->`, OCaml evaluates
`List.hd []` immediately, the exception escapes before
`assert_raises` is called, and the case crashes with an uncaught
exception rather than reporting a clean failure. `assert_equal`
is the wrong primitive for testing exceptions (it compares
*values*, and an exception is not a value the assertion can
inspect). The `assert_bool` form would also crash, for the same
reason: the exception is raised inside the boolean argument.
:::

:::quiz code id=M09-L02-q3
Write an OUnit2 test case named `"push then pop on a fresh
stack returns the pushed value"`. Use the value-oriented `Stack`
shown in this lecture. The case should:

1. create a fresh stack,
2. push the integer `7`,
3. pop, and assert that the result equals `7` (with a printer).

```ocaml
let test_push_pop_seven _ =
  failwith "not implemented"
```

```ocaml skip
let () =
  (* Pretend we ran the case body and inspect what it did. *)
  (* The test should not raise; the assertion should pass. *)
  let s = Stack.create () in
  Stack.push 7 s;
  assert (Stack.pop s = 7);
  print_endline "all tests passed"
```
:::

Reference solution:

```ocaml
let test_push_pop_seven _ =
  let s = Stack.create () in
  Stack.push 7 s;
  assert_equal ~printer:string_of_int 7 (Stack.pop s)
```

Three lines: arrange (create + push), act (pop is inside the
assertion), assert (with a printer). This is the canonical shape.

## Common pitfalls

**Pitfall 1: `>::` vs `>:::`.** Single colon makes one case; triple
colon makes a list. Beginners mix these up; the compiler error is
often confusing (it complains about a type mismatch between
`test` and `test list`). Memorise: more dots means more cases.

**Pitfall 2: forgetting the thunk for `assert_raises`.** Always
`fun () -> ...`. Always.

**Pitfall 3: shared mutable fixtures.** If you declare a single
`let s = Stack.create ()` at the *top* of the file and let every
case mutate it, case 5 will be affected by what cases 1-4 did. The
test order is no longer free, and one broken case cascades. Use a
fresh stack per case, even if it feels redundant.

**Pitfall 4: argument order of `assert_equal`.** Expected first,
actual second. The test still passes or fails correctly with the
order swapped, but the failure message becomes a lie ("expected 42
but got 7" when actually 42 *is* what your code produced). The
order is a convention, not a correctness requirement, which makes
it easy to ignore. Don't.

**Pitfall 5: testing the implementation, not the contract.** If
your stack happens to be implemented as a list and you write
`assert_equal [3; 2; 1] s.items`, you have tied your test to one
specific representation. The day someone switches the stack to an
array, every such case breaks even though the *behaviour* is
preserved. Test what `Stack.peek` and `Stack.pop` return, not what
the private field looks like.

:::slide

## Common pitfalls

1. **`>::` vs `>:::`**: one colon = one case, three colons = a list.
2. **`assert_raises` thunk**: pass `fun () -> ...`, never the value.
3. **Shared fixtures**: use a fresh value per case.
4. **`assert_equal` order**: expected first, actual second.
5. **Test the contract, not the implementation**: don't depend on
   private fields or representation choices.

:::

## What's next

[Lecture 3](M09-L03-property-based-testing.html) takes the next
step: instead of hand-writing each input and its answer, we
generate inputs randomly and check that a *property* holds over
all of them. This is property-based testing with QCheck. We will
see how PBT complements unit tests, why functional programming
makes properties especially natural to state, and watch the
shrinker minimise a failing input to its smallest form.

[Lecture 4](M09-L04-tutorial.html) puts both tools to work on a
real function from earlier in the course.

:::slide

## What's next

- L3: **property-based testing with QCheck**. Generators,
  shrinking, why FP makes PBT natural.
- L4: **tutorial**. Both tools on a function from M01-M08; a
  deliberately buggy implementation; QCheck finds it.

:::

## Reading

- **Cornell CS3110**, *OUnit*, the chapter from which this
  lecture takes its OUnit2 narrative and the
  `assert_equal`/`>::` conventions:
  <https://cs3110.github.io/textbook/chapters/correctness/ounit.html>
- **OUnit2 repository**, README and API documentation (current
  upstream, MIT-licensed):
  <https://github.com/gildor478/ounit>
- **Real World OCaml**, *Testing* (uses Alcotest rather than
  OUnit2 but covers the same conceptual ground):
  <https://dev.realworldocaml.org/testing.html>

## Sources

This lecture's prose, worked examples, and quizzes are original
to this course. Cornell CS3110's OUnit chapter is the primary
conceptual source for the OUnit2 API tour and the
`assert_equal`/`>::` conventions; its prose is CC BY-NC-ND
licensed and has not been derivatively reused. The `Stack`
example is the same module as
[M07-L04](M07-L04-module-basics.html), shifted to a
value-oriented API to make tests independent. OUnit2 itself is
MIT-licensed; we link to its repository and use its public
API surface.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
