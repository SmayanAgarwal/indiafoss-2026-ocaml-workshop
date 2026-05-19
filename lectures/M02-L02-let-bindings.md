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

- `r_sq` is in scope **inside** `circle_area`'s body.
- Outside the function it doesn't exist: `let _ = r_sq` would fail with `Unbound value r_sq`.
- Like a C local variable, except **no mutation**.
- The name disappears at the end of the expression.

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

- After line 1: `x` is `1`.
- After line 2: new `x` bound to `(old x) + 1 = 2`. First `x` still exists; the name now refers to the new binding.
- After line 3: another new `x`, bound to `(previous x) * 10 = 20`.
- Final: `x = 20`.

- This is **shadowing**: no mutation, three distinct bindings, same name.

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

- Answer: `1`.
- `f` was defined when `x` was `1`: it **captured the value** `1`.
- Not "the current value of `x`".
- Later `let x = 99` does **not** retroactively change what `f` sees.
- If `let` were mutation, `f` would return `99`: language would be much less predictable.

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

- `_` matches any value and discards it.
- Use `let _ = ...` when evaluating for:
  - **side effect** (first line)
  - **type-check** (second; compiler reports result, no name is taken)
- Related: `let _name = ...` (leading `_` on a real name) means "binding this, might not use it: don't warn me".

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
- Result: `20`. Three shadowing bindings, **no mutation**.
- Original `1` lingers in memory while line 2 evaluates.
- After that no reachable code refers to it: the GC reclaims it.
- **Garbage collection** is what lets shadowing-heavy code avoid leaks.

:::

:::slide

## What's next

- Next: **static vs dynamic semantics**.
- What it means to *catch errors before running the program*.
- Where OCaml lands on that spectrum.

:::

## Reading

- **Cornell CS3110**, *Let expressions*:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
