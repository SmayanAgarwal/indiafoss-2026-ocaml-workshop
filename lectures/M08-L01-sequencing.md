---
title: "Sequencing computations: motivation for monads"
lecture_no: 1
week: 8
duration_target_min: 22
concepts: [pyramid of doom, sequencing failures, monad shape, bind]
keywords: [OCaml, monad, sequencing, bind, option, let*]
activity_question: "Take the nested [match ... with None -> None | Some x -> ...] pattern and write a helper [bind : 'a option -> ('a -> 'b option) -> 'b option] that captures it. Use it to flatten a four-step optional pipeline."
think_about_this: "What other shapes besides 'maybe a value' might want the same kind of sequencing helper? List three."
reading:
  - title: "Cornell CS3110, Monads"
    url: https://cs3110.github.io/textbook/chapters/ds/monads.html
---

# Sequencing computations


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Sequencing computations: motivation for monads</h2>
<p class="title-slide-label">Module 8 &middot; Lecture 1</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

Module 8 is about a pattern that shows up everywhere in OCaml code,
once you learn to look for it: *sequencing computations that might
fail*. We already have the shapes for "something may go wrong":
[`option`](M04-L05-option-and-aliases.html#the-option-type) from
Module 4, [`result`](M04-L05-option-and-aliases.html#the-result-type)
from Module 4 as well, and [exceptions](M07-L03-exceptions.html)
from Module 7. What we do not yet have is a tidy way to *chain* such
computations. Without one, code grows into a *pyramid of doom* of
nested [`match`](M05-L01-basic-patterns.html) statements where the
actual logic is buried inside six levels of indentation.

This lecture sets up the problem and motivates the solution. The
next three lectures
([option monad](M08-L02-option-monad.html),
[result monad](M08-L03-result-monad.html),
[state monad](M08-L04-state-monad.html))
study the solution in detail. After that we turn to a different
but related advanced feature, generalized algebraic data types, or
GADTs, in lectures [five](M08-L05-gadts-basics.html) and
[six](M08-L06-gadts-use-cases.html). The Module 8 tutorial in
[lecture seven](M08-L07-tutorial.html) combines both.

The word *monad* sounds scarier than it is. The mathematical
machinery behind it lives in [category theory](https://en.wikipedia.org/wiki/Category_theory),
which is a beautiful subject but not what we are doing today.
For programming purposes, a monad is a small *design pattern*: a
type, plus two operations (`return` and `bind`), that lets you
sequence computations of a particular shape without writing the
plumbing by hand. By the end of this module you will recognise that
pattern in several different guises.

## A motivating problem

Suppose you are writing a small piece of code that parses a number
out of a string, doubles it, checks that it fits in some bound, and
prints it. Each of the four steps might fail. We will use `option`
to model the possible failure: `Some x` for success carrying a
value, `None` for failure.

```ocaml
let parse_int s = int_of_string_opt s
let twice x = Some (x * 2)
let small x = if x < 100 then Some x else None
let print_num x = print_endline (string_of_int x); Some ()
```

`parse_int` uses the standard-library `int_of_string_opt`, which
returns `None` if the string is not a valid integer. The other
three return `Some` of something, with one of them, `small`,
choosing `None` when the input is out of range. Each function has
the same *shape* in its return type: an
[`'a option`](M04-L05-option-and-aliases.html#the-option-type).

Now we want to wire them together: parse, then double, then check,
then print. At each step, if the previous step said `None`, we want
the whole pipeline to give up and produce `None` itself; if it said
`Some x`, we want to feed `x` to the next step.

The naive translation, written with nested pattern matching, looks
like this:

:::slide

## The pyramid of doom

```ocaml
let parse_int s = int_of_string_opt s
let twice x = Some (x * 2)
let small x = if x < 100 then Some x else None
let print_num x = print_endline (string_of_int x); Some ()

let demo s =
  match parse_int s with
  | None -> None
  | Some x ->
      match twice x with
      | None -> None
      | Some y ->
          match small y with
          | None -> None
          | Some z -> print_num z

let _ = demo "5"
let _ = demo "frog"
let _ = demo "100"
```

- Four steps, four `match`es, four `None -> None` clauses.
- The interesting logic is buried four levels deep.
- The `None -> None` arms are pure noise: they say nothing about the program.

:::

Run those three calls in your head. `demo "5"` parses to `5`,
doubles to `10`, passes the `< 100` check, prints `10`, returns
`Some ()`. `demo "frog"` fails at the first step: `parse_int "frog"`
is `None`, so `demo "frog"` is `None`. `demo "100"` parses to `100`,
doubles to `200`, fails the `< 100` check, returns `None` without
printing.

The pyramid shape is visible: each `match` indents one more level
to the right. With four steps it is already uncomfortable; with
seven or eight (a real parser, say) the line lengths run off the
right side of the editor. Worse, the *interesting* code (what each
step does after a successful previous step) is on the inside; the
*boring* code (`None -> None` four times) is on the outside. The
ratio of signal to noise is bad.

A bigger problem hides under the noise: the pattern of repetition.
Every step has *exactly the same shape*: "if the previous step is
`None`, return `None`; otherwise, unwrap and continue." We write
it once, then twice, then four times, and it gets longer in linear
proportion to the number of steps. This is a clear signal to look
for an abstraction.

## Capturing the pattern in a helper

Pick the repetition out as a function. The function takes an
`option` and a function that says "what to do if we have a value",
and produces the next `option`:

```ocaml
let bind opt f =
  match opt with
  | None -> None
  | Some x -> f x
```

Two arguments, three lines. Its type, inferred by OCaml, is
`'a option -> ('a -> 'b option) -> 'b option`. Read it slowly: it
takes an `'a option`, plus a function from `'a` to `'b option`, and
gives back a `'b option`. The first argument is the previous step's
result; the second is what to do next; the result is the
combined-and-possibly-short-circuited new step.

With `bind` in hand we can rewrite `demo` without the pyramid:

:::slide

## What we want

```ocaml
let bind opt f =
  match opt with
  | None -> None
  | Some x -> f x

let parse_int s = int_of_string_opt s
let twice x = Some (x * 2)
let small x = if x < 100 then Some x else None
let print_num x = print_endline (string_of_int x); Some ()

let demo s =
  bind (parse_int s) (fun x ->
  bind (twice x) (fun y ->
  bind (small y) (fun z ->
  print_num z)))

let _ = demo "5"
```

- Each step is one line: `bind <previous> (fun x -> <next step>)`.
- The "what to do if `None`" logic is captured once, inside `bind`.
- The pyramid is flattened to a vertical sequence.

:::

The structure is now linear in the number of steps. There is one
`bind` per step. The shape of each line tells the same story: "feed
the previous option into `bind`; if it had a value, name it (`x`,
`y`, `z`), and continue."

It still has noise. Each line opens an extra parenthesis (which
piles up on the last line), and `bind ... (fun x -> ...)` is
heavier than just `let x = ... in ...`. We are halfway to a good
abstraction but not all the way there. OCaml has one more piece of
sugar that closes the gap.

## A preview of `let*`

OCaml has a feature called *let-operators* (introduced in OCaml
4.08) that lets you define your own binding constructs that look
like `let`. We will study them properly in the next lecture; for
now, the punchline. We can define an operator named `( let* )` to
be exactly our `bind`:

```ocaml
let ( let* ) opt f =
  match opt with
  | None -> None
  | Some x -> f x
```

Once that is in scope, OCaml lets us write `let* x = e in rest`,
and it desugars to `( let* ) e (fun x -> rest)`, which is `bind e
(fun x -> rest)`. The whole pipeline becomes:

:::slide

## `let*` syntax (preview)

```ocaml
let ( let* ) opt f =
  match opt with
  | None -> None
  | Some x -> f x

let parse_int s = int_of_string_opt s
let twice x = Some (x * 2)
let small x = if x < 100 then Some x else None
let print_num x = print_endline (string_of_int x); Some ()

let demo s =
  let* x = parse_int s in
  let* y = twice x in
  let* z = small y in
  print_num z

let _ = demo "5"
```

- Each step is a `let* name = expression in ...`.
- Looks almost identical to ordinary `let name = expression in ...`.
- Hidden: if any step gives `None`, the rest is skipped.
- This is what is meant by *the option monad*.

:::

`demo "5"` evaluates to `Some ()` and prints `10`. `demo "frog"`
evaluates to `None` and prints nothing. `demo "100"` evaluates to
`None` and prints nothing.

Compare the three forms. The nested-`match` form is fifteen lines
of code, deeply indented. The explicit-`bind` form is four lines,
all parenthesised. The `let*` form is four lines, no parentheses,
and reads top to bottom like a sequence of ordinary `let` bindings.
The compiled code is identical for all three: `let*` is purely
syntactic sugar that elaborates back to `bind`.

What makes this *a monad* is the shape: a type (`option`) and two
operations (`return`, sometimes called `pure`, which is `fun x ->
Some x`; and `bind`, which is what we wrote above). Anything that
fits that shape is a candidate for the same `let*` notation, with
the same intuition: "give the value a name; if there is no value,
short-circuit." There are also three equational laws (left identity,
right identity, associativity) that a "good" monad's `return` and
`bind` are expected to satisfy; we sketch them in the
[next lecture](M08-L02-option-monad.html#the-monad-laws-a-teaser),
but they are background, not something you check by hand each time
you write a `bind`.

## Why this matters

The pattern is so common that you should learn to spot it. Once
you do, you will see it in every corner of a real OCaml codebase:

:::slide

## Why this matters

- Module 4: `option` is OCaml's answer to null pointers.
- Cost: option-flavoured code requires many `match` statements.
- The pyramid is that cost in practice.
- Monad-shaped helpers: type safety of `option` **and** linear code.
- Same pattern lifts to other shapes (`result`, promises, parsers, state).
- One notation (`let*`), one intuition, many concrete monads.

:::

The trade-off when we introduced `option` was: "you get explicit
control over the case where there is no value, at the cost of more
pattern matching." The pyramid of doom is exactly that cost,
showing up in real code. The monad pattern lets us keep the safety
of `option` while paying almost no syntactic cost: code reads top
to bottom, names introduced with `let*` are bound for the rest of
the block, and the short-circuit-on-failure plumbing is invisible.

The same pattern lifts to other shapes, and that is the second
reason it is worth learning. The next three lectures show three
different monads:

:::slide

## Three monads we will cover

- **Option monad** (Lecture 2): `'a option`. "Maybe a value."
- **Result monad** (Lecture 3): `('a, 'e) result`. "Either a value or an error with information."
- **State monad** (Lecture 4): `state -> ('a * state)`. "A computation that threads state."
- Lectures 5-6: GADTs, a separate type-system feature.
- Lecture 7: tutorial, combining GADTs with the monad pattern.

:::

After that we turn to a different topic, GADTs. Monads are about
sequencing computations; GADTs are about giving variants more
precise types. They are unrelated in mechanics but commonly used
together in [embedded domain-specific languages](https://en.wikipedia.org/wiki/Domain-specific_language),
where you build a small typed language inside OCaml. The tutorial
in lecture seven combines them.

## Where else does this come up?

A short list, before we move on. Each of the following has the
same `'a t` + `return` + `bind` shape, with `t` being something
different in each case:

- `'a option`: maybe a value (this module's lecture 2).
- `('a, 'e) result`: a value or an error message (lecture 3).
- `'a list`: zero, one, or many values; `bind` is "flat-map across
  all of them" (the *list monad*; sometimes used for non-determinism).
- `state -> 'a * state`: a value computed against a piece of
  ambient state ([lecture 4](M08-L04-state-monad.html)).
- `'a Lwt.t` or `'a Eio.Promise.t`: a value that will become
  available after I/O completes (concurrent programming; covered
  in the secure-systems half of the course, to be added).
- `'a parser`: a parser that reads bytes and either returns an
  `'a` plus the remaining input or signals failure (parser
  combinators; not in this course but a common application).

If you build a habit of asking "is this shape a monad?" when you
write any kind of "computation that may not produce a plain value",
you will notice the pattern far more often than you would expect.

## A quick check

Two small comprehension checks before the activity.

:::quiz mcq id=M08-L01-q3
In the pyramid-of-doom version of `demo`, how many times does the
text `None -> None` appear in the source?

- [ ] One.
- [ ] Two.
- [x] Three.
- [ ] Four.

**Why:** there is one `match` per step (four steps), but the *last*
step's match does not need a `None -> None` arm because its only
caller is the surrounding `Some _ ->` branch, and the value of the
whole expression is just the result of `print_num z`. We had three
intermediate `match`es, each contributing one `None -> None` arm.
The pyramid grows linearly with the number of intermediate steps.
:::

:::quiz mcq id=M08-L01-q2
What is the type of the helper `bind` we defined?

- [ ] `'a option -> 'a option -> 'a option`
- [x] `'a option -> ('a -> 'b option) -> 'b option`
- [ ] `'a -> ('a -> 'b option) -> 'b option`
- [ ] `'a option -> ('a -> 'b) -> 'b option`

**Why:** `bind` takes an option (the previous step's result), a
function that turns the unwrapped value into the next option, and
returns that next option. The two type variables `'a` and `'b` are
independent because the value type can change from step to step
(parse a string to an int, then double the int, etc.).
:::

:::slide

## Activity

Write `bind : 'a option -> ('a -> 'b option) -> 'b option`. Use it
to chain three optional steps in a flat pipeline. Watch the shape:
each step is one line.

:::

:::slide

## Activity solution

```ocaml
let bind opt f =
  match opt with
  | None -> None
  | Some x -> f x

let parse_int s = int_of_string_opt s
let double x = Some (x * 2)
let positive x = if x > 0 then Some x else None

let pipeline s =
  bind (parse_int s) (fun x ->
  bind (double x) (fun y ->
  positive y))

let _ = pipeline "5"
let _ = pipeline "frog"
let _ = pipeline "-3"
```

- `Some 10`, `None`, `None`.
- Three steps, three `bind`s, no nested `match`.

:::

A code-quiz to consolidate:

:::quiz code id=M08-L01-q1
Define `bind_opt : 'a option -> ('a -> 'b option) -> 'b option`
that captures the "short-circuit on `None`, otherwise unwrap and
continue" pattern.

```ocaml
let bind_opt opt f =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let safe_div a b = if b = 0 then None else Some (a / b)
let () =
  check (bind_opt (Some 10) (fun x -> Some (x + 1)) = Some 11) "step";
  check (bind_opt None (fun x -> Some (x + 1)) = None) "short-circuit";
  check (bind_opt (Some 10) (fun x -> safe_div x 0) = None) "step gives None";
  check (bind_opt (Some 10) (fun x -> safe_div x 2) = Some 5) "step gives Some";
  print_endline "all tests passed"
```
:::

Reference solution: `let bind_opt opt f = match opt with | None ->
None | Some x -> f x`. This is exactly the helper we built up over
the lecture. We will give it a sugared name (`let*`) in the next
lecture and start using it as our default vocabulary for
option-flavoured sequencing.

## A pitfall to flag now

It is tempting, once you understand `bind`, to reach for it
everywhere, even when the computation only has one or two optional
steps. Resist that. For two steps, the nested `match` is just
fine: shorter, no helper to import, and equally clear:

```ocaml
let _ =
  match int_of_string_opt "42" with
  | None -> "could not parse"
  | Some n -> "got " ^ string_of_int n
```

The pyramid only becomes a problem with three or more sequential
optional steps. We will come back to the threshold question in the
next lecture; for now the rule of thumb is: if you find yourself
typing your second `None ->` arm of the day, consider whether
`let*` would shorten the code.

## What is next

:::slide

## What is next

Lecture 2: the **option monad** in detail.

- The `let*` syntax-sugar for option-flavoured sequencing.
- The stdlib's `Option.bind` and `Option.map`.
- A real example: parsing a pair of integers.

:::

The [next lecture](M08-L02-option-monad.html) defines `let*`
formally as a let-operator, points at the standard library's
`Option.bind` and `Option.map` (the same functions, just shipped
in the stdlib), and walks through a realistic example: parsing
`"(3, 4)"` into the pair `(3, 4)`. After that,
[lecture three](M08-L03-result-monad.html) swaps `option` for
`result`: same shape, richer failure information.

## Reading

- **Cornell CS3110**, *Monads*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>
## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
