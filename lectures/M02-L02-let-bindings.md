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

A `let` binding gives a name to a value. Almost every line of OCaml
contains at least one. This lecture covers the two forms (`let` at
the top level and `let ... in` as an expression), how scope works,
and a feature that surprises people coming from C: **shadowing**, the
ability to re-bind an existing name without mutating anything.

:::slide

## Two forms of `let`

OCaml has *the same keyword* for two related things:

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

Same idea, different scope. The expression form does not pollute the
outer namespace.

:::

The top-level form is what you use when writing a program: a file is
a sequence of `let` bindings, one per definition. The `let ... in`
form is what you use inside a function body or inside a larger
expression, when you want to *name* an intermediate result so the
rest of the expression reads more clearly.

:::slide

## Local bindings inside a function

```ocaml
let circle_area r =
  let r_sq = r *. r in
  3.14159 *. r_sq

let _ = circle_area 5.0
```

`r_sq` is in scope inside the body of `circle_area`. Outside the
function it doesn't exist; `let _ = r_sq` after the function would
fail with `Unbound value r_sq`.

This is the equivalent of a local variable in C, except no mutation
is happening and the name disappears at the end of the expression.

:::

The chapter prose between slides is for the long-form read. When
you watch the slides as a video, the next slide is what comes next.
When you read this in chapter mode, the prose below builds the
intuition that the next slide depends on.

The really important property of `let` bindings is what they
*don't* do: they do not create a mutable variable cell. Once you
write `let x = 1`, `x` refers to `1` forever in that scope. There is
no later assignment `x = 2;` that changes what `x` is. In OCaml, to
re-use a name like `x` for a different value, you write a *new*
`let` binding. The old binding still exists in the parts of the
program that came before; the new binding takes over from where
it's written.

:::slide

## Shadowing

```ocaml
let x = 1
let x = x + 1
let x = x * 10
```

After these three lines, what is `x`?

Step through:

1. After line 1: `x` is `1`.
2. After line 2: a new `x` is bound to `(old x) + 1 = 2`. The first
   `x` still exists; the *name* `x` now refers to the new binding.
3. After line 3: another new `x`, bound to `(previous x) * 10 = 20`.

So `x = 20`.

This is **shadowing**. No mutation, three distinct bindings, and the
name happens to be the same.

:::

:::slide

## Shadowing is not mutation

```ocaml
let x = 1
let f () = x
let x = 99
let _ = f ()
```

What does `f ()` return?

`1`. The function `f` was defined when `x` was `1`. It captured the
value `1`, not "the current value of `x`". The later `let x = 99`
does not retroactively change what `f` sees.

If `let` were mutation, `f` would return `99` and the language would
be much less predictable.

:::

This is the property of *closures*: a function body, when defined,
captures the bindings that were in scope at its definition site. We
will see more of closures in Module 3 (Functions); the key fact here
is that the *value* gets captured, not a reference.

In dynamically-scoped languages (rare, but a few exist), `f` would
look up `x` at call time and would return `99`. OCaml is statically
scoped: `f` returns what `x` meant when `f` was defined.

:::slide

## Nested `let ... in`

You can chain `let ... in`s to compute intermediate values:

```ocaml
let _ =
  let a = 3 in
  let b = 4 in
  let c = a * a + b * b in
  c
```

`int = 25`. Each `let ... in` introduces a name, and the body of
that `let ... in` can use it.

Shadowing works in nested bindings too:

```ocaml
let _ =
  let x = 10 in
  let x = x + 1 in
  let x = x * 2 in
  x
```

`int = 22`.

:::

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

`demo ()` returns `1`; the top-level `x` is `100`. The local
binding inside `demo` shadows the outer one, but only inside the
function body. Outside, the outer `x` is unchanged.

This is the same shape as nested scopes in C / Java: an inner
local hides the outer name within the inner scope.

:::

The shadowing pattern is used a lot in idiomatic OCaml when you
want to *transform* a value through several steps. Instead of
inventing names like `x1`, `x2`, `x3`, you can shadow `x` each
time. Each line is one transformation step.

```ocaml
let process input =
  let cleaned   = String.trim input in
  let lowered   = String.lowercase_ascii cleaned in
  let no_spaces =
    String.concat "" (String.split_on_char ' ' lowered) in
  no_spaces
```

Three intermediate names, each named what it *is*. Each `let` is
visible inside the rest of the function. Cleaner than `let x1 = ...`,
`let x2 = ...`, etc., and cleaner than threading parentheses.

:::slide

## Underscore: "I don't care about the name"

```ocaml
let _ = print_endline "hi"
let _ = 3 + 4
```

The pattern `_` matches any value and discards it. We use `let _ =
...` when the expression is being evaluated for its side effect (the
first line) or its type-check (the second; the compiler will report
the result but no name is taken).

This is also why you sometimes see `let _name = ...` (with a leading
underscore on a real name): "I'm binding this but might not use
it; please don't warn me about that".

:::

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

:::slide

## Activity discussion

- Outer: `x = 1`
- After first inner: `x = 2`
- After second inner: `x = 20`

Result: `20`. Three shadowing bindings, no mutation.

The original `1` is still in memory at the moment line 2 evaluates;
after that, no reachable code refers to it, so the garbage collector
will reclaim it the next time it runs. Garbage collection is what
lets you write shadowing-heavy code without leaking memory.

:::

:::slide

## What's next

In the next lecture we make the type system explicit: **static vs
dynamic semantics**. What it means for a language to *catch errors
before running the program*, and where OCaml lands on that spectrum.

:::

## Reading

- **Cornell CS3110**, *Let expressions*:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
