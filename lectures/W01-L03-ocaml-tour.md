---
title: "A tour of OCaml: values, types, and the toplevel"
lecture_no: 3
week: 1
duration_target_min: 25
concepts: [literals, types, type inference, let bindings, the toplevel, integer vs float arithmetic]
keywords: [OCaml, toplevel, let, types, type inference, int, float, bool, string]
activity_question: "What is the type of [let f x = x +. 1.0] in OCaml? Why is it [float -> float] and not [int -> int]?"
think_about_this: "Why does OCaml distinguish [+] (for integers) from [+.] (for floats), instead of overloading [+] like Python and C do?"
reading:
  - title: "Real World OCaml, Chapter 1: A Guided Tour"
    url: https://dev.realworldocaml.org/guided-tour.html
  - title: "Cornell CS3110, OCaml syntax and semantics"
    url: https://cs3110.github.io/textbook/chapters/basics/basics.html
---

# A tour of OCaml

The goal of this lecture is to get you typing OCaml. Every cell on
this page is runnable: click **Run** and the toplevel evaluates it
right here. Don't just read; press the buttons.

:::slide

## The toplevel

OCaml has an interactive **toplevel** (often called a REPL): you type
an expression, it tells you the value and the type.

```ocaml
1 + 2
```

The toplevel responds with `- : int = 3`, read as: "the result has no
name, has type `int`, and is equal to `3`".

:::

:::slide

## Integers

```ocaml
2 + 3 * 4
```

Standard precedence. `*` binds tighter than `+`. Integer division
truncates:

```ocaml
17 / 5
```

```ocaml
17 mod 5
```

OCaml integers are 63-bit on a 64-bit machine (one bit goes to the
runtime for tagging). For arbitrary precision you reach for `zarith`,
not the built-in `int`.

:::

:::slide

## Floats

OCaml's float operators are **distinct** from the integer ones:

```ocaml
1.0 +. 2.5
```

`+.` instead of `+`. `*.` instead of `*`. `/.` instead of `/`.

Mixing them is a *type error*, caught at compile time:

```ocaml
1 + 2.0
```

This will refuse to evaluate. OCaml is telling you something other
languages hide: integer addition and floating-point addition are
genuinely different operations.

:::

:::slide

## Booleans and comparison

```ocaml
1 < 2
```

```ocaml
"apple" = "apple"
```

```ocaml
true && (false || true)
```

`=` is structural equality; `==` is physical (pointer) equality. Use
`=`. `&&` and `||` short-circuit.

:::

:::slide

## Strings

```ocaml
"hello, " ^ "world"
```

`^` is string concatenation. Strings in OCaml are bytes; for
proper Unicode reach for `uutf` or `Camomile`, depending on the era of
your codebase.

```ocaml
String.length "OCaml"
```

:::

:::slide

## Let bindings

`let` names a value:

```ocaml
let pi = 3.14159
```

```ocaml
let area_of_circle r = pi *. r *. r
```

```ocaml
let _ = area_of_circle 2.0
```

Bindings are **immutable** by default. `let pi = 3.14159` does not
create a variable cell you can later assign to; it just makes the name
`pi` refer to the value `3.14159` from then on.

:::

:::slide

## Let in expressions

`let ... in ...` lets you name an intermediate value inside a larger
expression:

```ocaml
let circle_area r =
  let r_sq = r *. r in
  3.14159 *. r_sq
```

```ocaml
let _ = circle_area 5.0
```

The name `r_sq` is in scope inside the body of `circle_area` and
nowhere else.

:::

:::slide

## Shadowing

You can rebind a name to a new value. The old binding is **shadowed**,
not mutated:

```ocaml
let x = 1
let x = x + 1
let y = x
```

After this, `y` is `2`. The first `x` (the one equal to `1`) is no
longer reachable by name, but if some earlier code captured it, that
old value is still alive and still equal to `1`.

:::

:::slide

## Type inference

OCaml *infers* types. You almost never have to write them down:

```ocaml
let add x y = x + y
```

The toplevel reports `val add : int -> int -> int = <fun>`. OCaml has
worked out that:

- `x + y` uses integer addition, so both `x` and `y` must be `int`.
- The result of `+` on ints is an `int`, so `add x y` is `int`.

Without writing a single type annotation.

:::

:::slide

## Inference for floats

```ocaml
let add_f x y = x +. y
```

Now the toplevel reports `val add_f : float -> float -> float = <fun>`,
because `+.` constrains the arguments to be floats.

The distinction between `+` and `+.` is what makes this work without
any "guess what the user meant" heuristics.

:::

:::slide

## Annotations, when you want them

You can write types explicitly. They have to *agree* with what OCaml
would have inferred, otherwise it's a type error:

```ocaml
let double (x : int) : int = x + x
```

```ocaml
let triple : int -> int = fun x -> x + x + x
```

Most of the time you leave them off and let inference do the work. In
public APIs you put them on for documentation.

:::

:::slide

## Putting it together

```ocaml
let kelvin_of_celsius c = c +. 273.15
let celsius_of_kelvin k = k -. 273.15
let boiling_kelvin = kelvin_of_celsius 100.0
let back_to_celsius = celsius_of_kelvin boiling_kelvin
```

What does the toplevel say about each binding? Type, value? Walk
through it.

:::

:::slide

## Activity

What is the type of:

```ocaml
let f x = x +. 1.0
```

And why is it not `int -> int`?

Take a moment, then peek.

:::

:::slide

## Activity discussion

`f : float -> float`. The `+.` operator forces `x` to be a `float`, so
the result is a `float`, so the function is `float -> float`.

If you had written `let f x = x + 1`, you would get `int -> int`. The
choice of operator drives inference.

This is the entire trick to reading OCaml type errors: ask which
operators or constructors are constraining each variable.

:::

:::slide

## What's next

Week 2 zooms into expressions: literals, let bindings, operators, type
inference, `if`/`then`/`else`. We start writing real (small) programs.

:::

## Reading

- **Real World OCaml**, *A Guided Tour*: <https://dev.realworldocaml.org/guided-tour.html>
- **Cornell CS3110**, *OCaml syntax and semantics*:
  <https://cs3110.github.io/textbook/chapters/basics/basics.html>
