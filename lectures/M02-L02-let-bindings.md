---
title: "`let` bindings and shadowing"
lecture_no: 2
week: 2
duration_target_min: 22
concepts: [let bindings, let-in expressions, scope, shadowing, immutability]
keywords: [OCaml, let, let-in, scope, shadowing, immutability, bindings]
activity_question: "Given [let x = 1 in let x = x + 1 in let x = x * 10 in x], what is the final value? Trace each step."
think_about_this: "If [let x = 1; let x = 2] does not mutate, where does the value [1] go? Can any code reach it after the second binding?"
reading:
  - title: "Cornell CS3110, Let expressions"
    url: https://cs3110.github.io/textbook/chapters/basics/expressions.html
---

# `let` bindings and shadowing

The previous lecture introduced literals: the smallest building
blocks of a program. This lecture introduces the next layer up:
*names*. Names let you build programs that are more than expressions
written in a single line. Naming a value lets you compute it once
and use it many times; naming an intermediate result lets you break
a long calculation into readable steps. Almost every line of OCaml
contains at least one `let` binding, and getting comfortable with
them is the precondition for everything else.

The OCaml `let` has two related forms with slightly different
purposes. We will introduce both and then look at the property that
makes OCaml's bindings work differently from variables in C or
Python: *shadowing*. Shadowing is the ability to reuse a name
without ever mutating anything. It is one of the more pleasant
features of working in an immutable language, but it confuses
people who arrive expecting `let x = 2` to "change" `x`. By the end
of the lecture you will know exactly what's happening.

## Two forms of `let`

OCaml uses the same keyword `let` for two related constructs.
Distinguishing them matters because they introduce names with
different *scope*: how far through the program the name is visible.

The **top-level `let`** introduces a name visible to everything
that follows it in the file (or in the toplevel session). A
program is a sequence of top-level `let` bindings, evaluated in
order; we saw this in M01-L04.

```ocaml
let pi = 3.14159
let r  = 5.0
let _  = pi *. r *. r
```

The **`let ... in` expression** introduces a name *local* to a
specific expression. The syntax is `let name = value in body`,
where `name` is in scope inside `body` only. Outside `body`, the
name does not exist.

```ocaml
let _ =
  let pi = 3.14159 in
  let r  = 5.0 in
  pi *. r *. r
```

:::slide

## Two forms of `let`

- Same keyword, two related uses:

**Top-level `let`:** introduces a name into the rest of the file.

```ocaml
let pi = 3.14159
let r  = 5.0
let _  = pi *. r *. r
```

**`let ... in` expression:** introduces a name scoped to the
following expression only.

```ocaml
let _ =
  let pi = 3.14159 in
  let r  = 5.0 in
  pi *. r *. r
```

- Same idea, different scope.
- The expression form does **not** pollute the outer namespace.

:::

The two examples above compute the same number. The difference is
that in the top-level form, the names `pi` and `r` are visible
forever after their definitions; the second form keeps them
inside the `let _ = ... ` expression.

When to use which: if you want a name that other parts of your
program will use, use a top-level binding. If you want a name that
exists only for the readability of a single expression, use
`let ... in`. In practice, you will see far more `let ... in` than
top-level `let` once functions get involved, because function
bodies are *expressions* and any names you introduce inside a
function body must be `let ... in`.

## Local bindings inside a function

The most common place you see `let ... in` is inside a function.
The function body is a single expression; if it would be cleaner
with intermediate names, you introduce them with `let ... in`.

```ocaml
let circle_area r =
  let r_sq = r *. r in
  3.14159 *. r_sq

let _ = circle_area 5.0
```

:::slide

## Local bindings inside a function

```ocaml
let circle_area r =
  let r_sq = r *. r in
  3.14159 *. r_sq

let _ = circle_area 5.0
```

- `r_sq` is in scope **inside** `circle_area`'s body.
- Outside the function it doesn't exist: `let _ = r_sq` would fail with `Unbound value r_sq`.
- Like a C local variable, except **no mutation**.
- The name disappears at the end of the expression.

:::

`r_sq` is in scope only inside `circle_area`. After the function
ends, you cannot refer to `r_sq` anywhere else. This is the same
scoping discipline you know from C local variables, except that
OCaml's bindings are immutable: `r_sq` does not get a new value
later in the body; it just stops existing when the body finishes.

There is also no need to declare anything in advance: a `let ...
in` *introduces* a name; you do not pre-declare names you might
use later. The compiler reads each binding in order and knows the
name from that point on.

## Immutability: the bit you have to internalise

The really important property of `let` bindings, and the one that
takes the longest to internalise if you come from imperative
languages, is what `let` *doesn't* do: it does not create a mutable
variable cell. Once you write `let x = 1`, `x` refers to `1`
forever in that scope. There is no later assignment `x = 2`
("update the value at `x`'s slot"). In OCaml, to reuse a name for
a new value, you write a *new* `let` binding. The old binding
still exists in the parts of the program that came before; the new
binding takes over from where it is written. We will get to that in
the shadowing section.

If you have written C or Python, this distinction can feel
philosophical at first. "I bound `x` to 1 and then I bound it to
2. So what?" The "so what" is that any code that captured the old
`x` (say, a function that takes `x` as a closure value, which we
will see in Module 3) keeps seeing `x = 1`. The old binding is
*alive*; the new binding just hides it for any code written after
the new binding.

## Shadowing

OCaml lets you reuse a name in a new binding without mutating
anything. This is called *shadowing*. Here is the classic example:

```ocaml
let x = 1
let x = x + 1
let x = x * 10
```

:::slide

## Shadowing

```ocaml
let x = 1
let x = x + 1
let x = x * 10
```

After these three lines, what is `x`?

- After line 1: `x` is `1`.
- After line 2: new `x` bound to `(old x) + 1 = 2`. First `x` still exists; the name now refers to the new binding.
- After line 3: another new `x`, bound to `(previous x) * 10 = 20`.
- Final: `x = 20`.

- This is **shadowing**: no mutation, three distinct bindings, same name.

:::

Read carefully. On line 2, on the *right-hand side* of the `=`,
`x` still means "the first `x` (which is `1`)". So the right-hand
side evaluates to `2`. After the line, the name `x` refers to the
new binding, where `x = 2`. The original binding of `x = 1` is
still there, just no longer reachable by typing `x`.

On line 3, on the right-hand side, `x` means "the most recently
bound `x`", which is `2`. So the right-hand side is `20`. After
the line, `x = 20` and the previous two bindings live in memory
where no name reaches them.

This is *not* mutation. There is no single cell named `x` that
holds successive values. There are three separate values, all
called `x` for the duration of their existence, with the most
recent one being the one you reach when you type `x`.

## Why shadowing differs from mutation: closures see the old value

The clearest demonstration that shadowing is not mutation comes
from closures, which we will study in Module 3 but can already use
in a simple example.

```ocaml
let x = 1
let f () = x
let x = 99
let _ = f ()
```

What does the last line evaluate to?

:::slide

## Shadowing is not mutation

```ocaml
let x = 1
let f () = x
let x = 99
let _ = f ()
```

What does `f ()` return?

- Answer: `1`.
- `f` was defined when `x` was `1`: it **captured the value** `1`.
- Not "the current value of `x`".
- Later `let x = 99` does **not** retroactively change what `f` sees.
- If `let` were mutation, `f` would return `99`: language would be much less predictable.

:::

The answer is `1`. Read carefully: when `f` was defined, `x` was
`1`. The function body refers to `x`. OCaml does *not* re-look-up
the name `x` every time `f` is called; it captured the *value* `x
= 1` when `f` was defined. After `let x = 99`, the name `x` now
refers to a different binding, but `f` is unaffected; it still
returns what `x` meant when `f` was defined.

This is the property of *closures*: a function body, at the moment
of definition, captures the bindings that were in scope. We will
see closures in much more detail in Module 3. The key fact for
this lecture: the *value* gets captured, not "the current meaning
of the name."

In a language where `let` actually mutates a cell, the same code
would produce different behaviour. Some languages do work that
way (Python is closer to this model: a closure captures a
*reference* to the variable, not its value, so reassignment is
visible through the closure). OCaml's choice (capture the value)
is what people mean by *static scoping with value capture*: it is
more predictable, easier to reason about, and matches what
mathematical functions do.

## Nested `let ... in`

You can chain `let ... in` bindings to compute intermediate values
in sequence.

```ocaml
let _ =
  let a = 3 in
  let b = 4 in
  let c = a * a + b * b in
  c
```

:::slide

## Nested `let ... in`

Chain `let ... in`s to compute intermediate values:

```ocaml
let _ =
  let a = 3 in
  let b = 4 in
  let c = a * a + b * b in
  c
```

- Result: `int = 25`.
- Each `let ... in` introduces a name visible in its body.

Shadowing works in nested bindings too:

```ocaml
let _ =
  let x = 10 in
  let x = x + 1 in
  let x = x * 2 in
  x
```

- Result: `int = 22`.

:::

Result: `int = 25` (Pythagoras). Each `let ... in` is its own
binding, scoped to the rest of the expression. The chain reads
top-to-bottom like a procedure, but it is a single expression: the
whole thing is `let a = 3 in (let b = 4 in (let c = a*a + b*b in
c))`.

Shadowing works inside nested bindings too:

```ocaml
let _ =
  let x = 10 in
  let x = x + 1 in
  let x = x * 2 in
  x
```

Result: `int = 22`. Each `let x = ... in` introduces a new
binding, hiding the previous `x` for the rest of the scope. The
right-hand sides reference the previous binding.

## Scope: outer versus inner

What happens when a local `let ... in` shadows a top-level
binding? The inner binding is in scope only inside its `in`
expression. Outside, the outer binding is restored.

```ocaml
let x = 100

let demo () =
  let x = 1 in
  x

let _ = demo ()
let _ = x
```

:::slide

## Scope: outer vs inner

```ocaml
let x = 100

let demo () =
  let x = 1 in
  x

let _ = demo ()
let _ = x
```

- `demo ()` returns `1`.
- Top-level `x` is still `100`.
- Local binding shadows the outer one **only inside** the function body.
- Outside, the outer `x` is unchanged.
- Same shape as nested scopes in C / Java: inner local hides outer within inner scope.

:::

`demo ()` returns `1`: inside the function, the local `x` shadows
the outer one. After `demo` returns, the local `x` is out of
scope; the outer `x` (still `100`) is what you see. This is the
same nesting rule you know from C blocks or Java methods: a local
variable hides any outer variable of the same name, only within
its own scope.

## Idiom: shadowing for step-by-step transformations

The shadowing pattern is used a lot in idiomatic OCaml when you
want to transform a value through several steps. Instead of
inventing artificial names like `x1`, `x2`, `x3`, you can shadow
one name (or name each step descriptively).

```ocaml
let process input =
  let cleaned   = String.trim input in
  let lowered   = String.lowercase_ascii cleaned in
  let no_spaces =
    String.concat "" (String.split_on_char ' ' lowered) in
  no_spaces
```

Three intermediate names, each named for *what it is*. Each `let
... in` is visible inside the rest of the function. This reads
cleanly: "I have an `input`; first I clean it; then I lowercase
the cleaned version; then I remove spaces from the lowercased
cleaned version; the result is what I return."

There is also a more compact variant that shadows a single name:

```ocaml
let process input =
  let s = String.trim input in
  let s = String.lowercase_ascii s in
  let s = String.concat "" (String.split_on_char ' ' s) in
  s
```

Same computation; one name `s` shadowed three times. Whether you
prefer this or the earlier variant is taste. Some style guides
prefer the descriptive-names variant for clarity; others use
shadowing-of-one-name to emphasise "this is a single value being
transformed." Both are idiomatic.

## Underscore: "I don't care about the name"

The pattern `_` matches any value and discards it. You can use it
in a `let` binding when you want to evaluate something for its
side effect (or to make the toplevel print the result) but don't
need to bind a name.

```ocaml
let _ = print_endline "hi"
let _ = 3 + 4
```

:::slide

## Underscore: "I don't care about the name"

```ocaml
let _ = print_endline "hi"
let _ = 3 + 4
```

- `_` matches any value and discards it.
- Use `let _ = ...` when evaluating for:
  - **side effect** (first line)
  - **type-check** (second; compiler reports result, no name is taken)
- Related: `let _name = ...` (leading `_` on a real name) means "binding this, might not use it: don't warn me".

:::

The first line is the same as `let () = print_endline "hi"`
except more permissive: `_` accepts any type, `()` only accepts
`unit`. In practice, prefer `let () = ...` for side-effecting
calls because it documents intent (and catches the case where you
forgot to return `unit`).

The second line is just for the toplevel: the value `7` gets
discarded, but the toplevel prints it (`- : int = 7`).

A related convention: a name starting with `_` (like `_unused`)
tells the compiler "I am binding this, but I might not use it; do
not warn me." This is useful in pattern matching when you want to
*name* something for documentation but never reference it. We will
see this in Module 5.

## Activity

:::slide

## Activity

Step through:

```ocaml
let _ =
  let x = 1 in
  let x = x + 1 in
  let x = x * 10 in
  x
```

What is the final value? Predict, then run.

:::

:::quiz mcq
What is the result of this nested expression?

```ocaml
let _ =
  let x = 1 in
  let x = x + 1 in
  let x = x * 10 in
  x
```

- [ ] `1`
- [ ] `2`
- [x] `20`
- [ ] `30`

**Why:** trace step by step. First `let x = 1`: `x` is 1. Second
`let x = x + 1`: the right-hand side uses the outer `x` (=1), so
the new `x` is 2. Third `let x = x * 10`: the right-hand side uses
the most recent `x` (=2), so the new `x` is 20. The whole
expression returns the innermost `x`, which is 20. No mutation
happens; three new bindings are introduced, each hiding the
previous.
:::

:::slide

## Activity discussion

- Outer: `x = 1`
- After first inner: `x = 2`
- After second inner: `x = 20`
- Result: `20`. Three shadowing bindings, **no mutation**.
- Original `1` lingers in memory while line 2 evaluates.
- After that no reachable code refers to it: the GC reclaims it.
- **Garbage collection** is what lets shadowing-heavy code avoid leaks.

:::

The aside about garbage collection is worth flagging. In a language
without GC (like C), reusing names by shadowing-style allocation
would leak: every "old `x`" you stopped referring to would still
take space. In OCaml the garbage collector recognises that nothing
reachable refers to the old `x` and frees it. This is one of the
reasons GC and immutability fit so well together: GC makes
immutability cheap, and immutability makes GC's job easier
(no in-place updates means no need for write barriers in the
common case). We will see the full GC story in Module 9.

## A small code challenge

:::quiz code
Define a function `four_step : int -> int` that, given input `n`,
returns `((n + 1) * 2 - 3) * 5`. Use shadowing (rebind a single
name `x` four times) so the code reads step by step.

```ocaml
let four_step n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (four_step 0  = ((0 + 1) * 2 - 3) * 5)  "four_step 0";
  check (four_step 5  = ((5 + 1) * 2 - 3) * 5)  "four_step 5";
  check (four_step 10 = ((10 + 1) * 2 - 3) * 5) "four_step 10";
  print_endline "all tests passed"
```
:::

One sample solution:

```
let four_step n =
  let x = n + 1 in
  let x = x * 2 in
  let x = x - 3 in
  let x = x * 5 in
  x
```

Four shadowing bindings, each one transformation step. There is no
mutation. Each `let x = ... in` is a brand new binding.

## What's next

We have looked at how `let` bindings work and shadowing in detail.
Next lecture (M02-L03) covers OCaml's type system in more depth:
type inference, type unification, the type annotations you can
write when you want to. After that, lectures on operators and
on `if`/`then`/`else` complete Module 2. Then Module 3 starts on
functions.

:::slide

## What's next

- Next: **static vs dynamic semantics**.
- What it means to *catch errors before running the program*.
- Where OCaml lands on that spectrum.

:::

## Reading

- **Cornell CS3110**, *Let expressions*: thorough chapter on
  the same material, with more worked examples:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
- **Real World OCaml**, *A Guided Tour* (let bindings section):
  <https://dev.realworldocaml.org/guided-tour.html>
