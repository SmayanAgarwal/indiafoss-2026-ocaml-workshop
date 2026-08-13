---
title: "Expressions"
lecture_no: 1
week: 1
duration_target_min: 145
concepts: [primitive types, literal syntax, OCaml number representation, string syntax, let bindings, let-in expressions, scope, shadowing, immutability, inference rules, static typing, dynamic typing, type errors, type inference, type signatures, operator precedence, arithmetic operators, comparison, logical operators, common type errors, if as expression, expression-oriented language, branches must agree, type rule for if, expression composition, reading type errors, writing small programs]
keywords: [OCaml, int, float, bool, string, literals, primitive types, let, let-in, scope, shadowing, immutability, bindings, semantics, static typing, dynamic typing, type inference, Hindley-Milner, type errors, operators, precedence, comparison, equality, logical operators, if expression, conditional, branches, expression-oriented, tutorial, expressions, beginner exercises]
reading:
  - title: "Real World OCaml, A Guided Tour (numbers, let bindings, and type-inference sections)"
    url: https://dev.realworldocaml.org/guided-tour.html
  - title: "Cornell CS3110, Basics chapter (types and values, let expressions, type checking, conditional expressions)"
    url: https://cs3110.github.io/textbook/chapters/basics/expressions.html
  - title: "OCaml manual, Operators section"
    url: https://v2.ocaml.org/manual/expr.html
  - title: "Cornell CS3110, Basics chapter (index)"
    url: https://cs3110.github.io/textbook/chapters/basics/index.html
---

# Expressions, Operators and Types

Almost every meaningful piece of an OCaml program is an
*expression*: a piece of syntax that the language evaluates to
produce a value.  

An expression has two things,
*syntax* (how you write it) and *semantics* (what it means). The
semantics in turn split in two:

- *Static semantics* are the type-checking rules. Before any
  evaluation happens, OCaml checks the expression and either
  produces a type or rejects it with an error message.
- *Dynamic semantics* are the evaluation rules. If type-checking
  succeeded, OCaml then evaluates the expression to produce a
  *value* (or it raises an exception, or it runs forever).

Crucially, evaluation rules apply *only to expressions that
type-check*. This is the static-vs-dynamic-language line:
statically typed languages like OCaml refuse to run an ill-typed
expression, where dynamically typed languages (Python, JavaScript)
start running anyway and may discover the type mismatch only at
runtime.


## Values

A *value* is an expression that does not need any further
evaluation. The literal `5` is already a value: there is nothing
left to compute. The expression `2 + 3` is *not* a value: it still
has work to do, namely the dynamic semantics of `+`, which reduces
it to `5`. Every successful evaluation in OCaml ends at a value.

Values form a *subset* of expressions: every value is an
expression, but not every expression is a value. Evaluation is the
process of taking a non-value expression and reducing it to one
inside that inner ring.

:::slide

<figure class="diagram values-diagram">
  <img src="/assets/m02/figures/val-expr.svg"
       alt="Values are a subset of expressions"
       style="max-height: 360px;">
</figure>

:::

## Literals

The simplest expressions are the ones that are *already values*:
they need no evaluation at all. We call those *literals*. OCaml's
primitive literal kinds are `int`, `float`, `bool`, `char`,
`string`, and `unit`. This lecture spends the bulk of its time on
the four that dominate everyday code: integers, floating-point
numbers, booleans, and strings. `char` (a single byte, written
`'a'`) shows up briefly in the strings section, and `unit` (the
single value `()`, used as a placeholder when there is nothing
meaningful to return). The
choice of "primitive" is the language
designer's: these are the kinds the compiler knows about
intrinsically, with dedicated syntax and built-in operators.
Every other value in the language, from a list of pairs to a
record of records, is ultimately built up out of literals like
these.

:::slide

## Primitive literal kinds

| Type | Example literal | What it represents |
| --- | --- | --- |
| `int` | `42`, `-7`, `0` | Whole number, signed, 63-bit on 64-bit |
| `float` | `3.14`, `2.0` | IEEE-754 double-precision |
| `bool` | `true`, `false` | Boolean |
| `char` | `'a'`, `'\n'` | Single byte |
| `string` | `"hello"`, `""` | Byte string |
| `unit` | `()` | The single placeholder value |

- Each literal is its own value.
- Compiler **infers** every literal's type.
- No `int x = 5;`. Just `let x = 5`.

:::

The first row of that table, `int`, deserves a longer look. The
others are mostly variations on what you already expect, but OCaml's
integers come with one small surprise that explains a lot of design
choices later in the language.

## Integers

OCaml's `int` is a *machine integer*: a fixed-width signed integer
that fits in a single register on whatever CPU you are running. On
the 64-bit machines that essentially every student has today, that
register is 64 bits wide. You might therefore expect OCaml's `int`
to give you the full 64-bit range, from `-2^63` up to `2^63 - 1`.
It does not. OCaml's `int` is 63 bits wide, with a range of about
`-4.6 × 10^18` to `4.6 × 10^18`.

<details>
<summary>Integer width and the OCaml runtime</summary>

Where did the missing bit go? The runtime stole it. OCaml needs a
way, at runtime, to tell an immediate integer apart from a pointer
to a heap-allocated object. The garbage collector, in particular,
has to walk every value the program is holding and decide whether
to follow it as a pointer or treat it as an inline scalar. The
trick OCaml uses is to set the low bit of every immediate integer
to `1`, and arrange the heap so that every pointer is even (its low
bit is `0`). One bit-test then suffices to classify any word in
memory. That stolen low bit costs us one bit of integer range, but
it makes the GC fast and predictable, and it is part of why OCaml
programs can run within a small constant factor of equivalent C
code.

You will not see this tagging in your code: it happens entirely at
the runtime level. The only place it surfaces for the programmer
is the slightly narrower `int` range. If you really need a true
64-bit integer, the standard library has a separate `Int64` module;
for arbitrary-precision integers, there is the
[`Zarith`](https://github.com/ocaml/Zarith) library. For the first
half of this course we will not need either.
</details>

:::slide

## Integer literals

```ocaml
let dec = 255
let hex = 0xff
let oct = 0o377
let bin = 0b11111111
```

- All four bindings: type `int`, value `255`.
- Base prefix is **syntactic only**: they are the same number under the hood.

:::

:::slide

## Underscores for readability

```ocaml
let million = 1_000_000
let mask    = 0xff_ff_ff_ff
```

- `_` is purely visual; the compiler ignores it.
- Use it wherever a long literal benefits from grouping.

:::

<details><summary>'_' in numbers</summary>.
The underscore in `1_000_000` is a small but worthwhile convention:
it is purely visual, the compiler discards it entirely, and it
makes large numeric constants enormously easier to read. The same
convention exists in Java 7+, Python 3.6+, and Rust. You can place
the underscores wherever you like; `1_0_0_0_0_0_0` is also a million,
just an unkind one to your reader. The most common groupings are by
three digits for decimal numbers and by bytes for hex masks.
</details>

:::slide

## Integer arithmetic

The four integer operators that come built in are `+`, `-`, `*`,
`/`, and `mod`. The first three behave exactly as you expect. The
last two, `/` and `mod`, have one subtlety worth understanding now,
because it differs from Python (the language students most often arrive in OCaml from).

```ocaml
let _ = 2 + 3
let _ = 10 - 4
let _ = 6 * 7
let _ = 17 / 5
let _ = 17 mod 5
```

- `+`, `-`, `*` behave as expected.
- `/` does **truncating integer division**: `17 / 5 = 3` (remainder dropped).
- `mod` gives the remainder: `17 mod 5 = 2`.

:::

:::slide

## Negative integer division: toward zero

```ocaml
let _ = (-17) / 5
```

- Result: `int = -3` (truncates toward zero, not toward minus infinity).
- Python rounds toward minus infinity: gives `-3.4`. 

:::

The `/` operator on `int` is *truncating integer division*: it
divides exactly and then throws the fractional part away. So
`17 / 5` is `3`, with the `0.4` discarded. The companion `mod`
operator returns what was discarded, scaled to an integer: `17 mod 5`
is `2`, because `17 = 3 * 5 + 2`. The identity `a = (a / b) * b + (a mod b)`
holds for any positive `a` and `b`.

### (***Please check the following paragraph***)
For negative operands, OCaml truncates *toward zero*, not toward
minus infinity. So `(-17) / 5` is `-3` in OCaml. Python, in
contrast, rounds toward minus infinity, so the same division in
Python gives (`-4` in the original lecture)`-3.4`. There is no universal right answer here; both
languages picked a convention and stuck with it. The OCaml
convention matches C and Java; the Python convention is mathematically
cleaner for some applications. The practical advice is: if you find
yourself doing arithmetic on signed integers near zero, write the
answer out for a couple of inputs and check that you have the
convention you wanted.

<details><summary>Integer arithmetic pitfalls</summary>

Integer overflow in OCaml is silent. `max_int` (from the Int module in the standard libary) returns the greatest representable integer. `max_int + 1` does not raise
an exception or produce a runtime error; it wraps around i.e. returns the maximum negative value for `-2^63`. This wrap-around is *defined* in the language and is a deliberate choice for performance. C is different in a way worth
flagging: signed-integer overflow in C is *undefined behaviour*,
so the compiler may assume it never happens (a distinction a later
module returns to). If you are doing arithmetic where overflow
might happen and would matter, the discipline is: use a wider
type (`Int64`) or check explicitly.

The stakes of "check explicitly" can be absolute. On 4 June
1996, the maiden Ariane 5 rocket tore itself apart 37 seconds
after launch, taking roughly 370 million dollars of vehicle and
satellites with it. The guidance software, reused from Ariane 4,
converted a 64-bit float (the horizontal velocity) into a 16-bit
integer; on Ariane 5's faster trajectory the value no longer
fit, and the range check had been *deliberately omitted* for
performance, because analysis of the old rocket had shown the
overflow could never happen. The conversion trapped, both
redundant guidance units ran the same code and failed the same
way, and the rocket veered and broke up. Numeric conversions are
where two representations meet; the
[inquiry report](https://en.wikipedia.org/wiki/Ariane_flight_V88)
is a classic precisely because every ingredient was reasonable
on its own.
</details>

## Floating-point numbers

OCaml's `float` is exactly IEEE 754 double precision: 64 bits, with
1 sign bit, 11 exponent bits, and 52 fraction bits. This is the same
representation that C calls `double`, that JavaScript uses for *all*
numbers, and that almost every modern language uses for its default
floating-point type. The range is roughly `±10^308`, with about 15
to 17 significant decimal digits of precision.

There is one small but very firm syntactic rule: a `float` literal
must contain a decimal point. Without it, the compiler reads the
number as an `int`. So `3.` and `3.0` and `3.14` are all floats;
`3` is an integer. The trailing dot after `3.` is enough, even
without a digit after it.

:::slide

## Float literals

```ocaml
let pi    = 3.14159
let half  = 0.5
let e_neg = 2.71828e-1   (* scientific: 2.71828 x 10^-1 *)
let tau   = 6.283185
```

- All `float`.
- `e-1` is the exponent suffix.

:::

:::slide

## No decimal point: it's an `int`

```ocaml
let bad = 3
```

- `bad : int`, not `float`.
- For a float, write `3.0` or `3.` (trailing zero optional after the dot).

:::

:::slide

## Float arithmetic uses different operators

```ocaml
let _ = 1.0 +. 2.5
let _ = 10.0 -. 3.0
let _ = 4.0 *. 2.5
let _ = 9.0 /. 4.0
```

- Float operators: `+.`, `-.`, `*.`, `/.`.
- The trailing `.` is **part of the operator name**.

:::

:::slide

## No implicit `int` / `float` promotion

Mixing types is a compile-time error:

```ocaml skip
let _ = 1 + 2.0
```

- Error: `The constant 2.0 has type float but an expression was expected of type int`.
- To add an `int` and a `float`, convert explicitly:

```ocaml
let _ = float_of_int 1 +. 2.0

let _ = int_of_float 200.0 * 100
```

:::

<details><summary>Lack of operator loading in OCaml</summary>


 Why should integer and float values have different sets of operators? 
 Why not let `+` do the obvious thing depending on its operands, the way Python and Java and JavaScript do? The answer
has two parts, one practical and one principled.

The practical part is that *operator overloading is expensive*.
In C++, when the compiler sees `a + b`, it has to
search for an `operator+` that takes the types of `a` and `b`. If
several such operators are in scope, it has to apply overload
resolution rules to pick one. This makes both compilation slower
and error messages worse: a misplaced `+` can produce error
messages that talk about candidate overloads in libraries the
programmer has never heard of. Languages with simpler type systems,
like C and Java, get around this by *baking the overloads into the
compiler*: the compiler knows that `+` on two `int`s is one
instruction, on two `double`s is a different one, and on a `String`
and anything is yet another. That is a workable design, but it
means you cannot decide for yourself, in your own code, what `+`
means on a new type you have written. OCaml takes the opposite
position: every operator has *one* meaning, fixed in the language,
and that meaning is determined by the operator symbol alone, not
by the types of its operands.

The principled part is *reasoning*. When you read OCaml code and
see `a + b`, you know, without checking anything else, that both
`a` and `b` are integers, and that the result is an integer add.
When you see `a +. b`, you know both are floats. That is one less
thing to verify in your head as you read code. We will come back
to this principle several times in the course: OCaml repeatedly
chooses *more syntax, less ambiguity*, and the dividend shows up
when you have to read someone else's code six months later.

The cost of this choice is that mixing numeric types requires an
explicit conversion. The function `float_of_int` turns an `int`
into a `float`; `int_of_float` does the reverse, truncating. The
opposite-direction conversion is so common in numerical code that
the standard library also exposes them as `Float.of_int` and
`Float.to_int`, with friendlier names.
</details> 

### Floating point arithmetic

One more property of `float` that is worth flagging now, because
students rediscover it the hard way: floating-point arithmetic is
*approximate*. The number `0.1` cannot be represented exactly in
binary floating point; neither can `0.2`. So `0.1 +. 0.2` does
not give `0.3`; it gives `0.300000000000000044`. This is not
a bug in OCaml; it is a fundamental property of IEEE 754, and
the same anomaly appears in Python, Java, JavaScript, and
essentially every mainstream language:
[`0.30000000000000004.com`](https://0.30000000000000004.com/)
tabulates `0.1 + 0.2` language by language.
We saw the same example in
[the Module 1 tutorial's float-precision aside](M01-L05-tutorial-recap.html#a-float-precision-aside).

The float
operators `+.` and `*.` give up both laws of associavity and distributivity, because each result is
rounded and the rounding depends on the grouping:

```ocaml
(* Integers: regrouping is safe. *)
let _ = (1 + 2) + 3    (* = 6 *)
let _ = 1 + (2 + 3)    (* = 6 *)

(* Floats: each step rounds, so regrouping changes the answer. *)
let _ = (0.1 +. 0.2) +. 0.3         (* = 0.600000000000000089 *)
let _ = 0.1 +. (0.2 +. 0.3)         (* = 0.6 *)

(* Distributivity breaks the same way. *)
let _ = 100. *. (0.1 +. 0.2)        (* = 30.0000000000000036 *)
let _ = 100. *. 0.1 +. 100. *. 0.2  (* = 30. *)
```

## Booleans

The `bool` type has exactly two values: `true` and `false`. There
is no concept of "truthy" values like Python's `0` or `""`; an `if`
or `&&` or `||` expects a `bool`, full stop. A `0` is an `int`, not
a `bool`, and the compiler will reject `if 0 then ...` outright. As
with the numeric operators, this is OCaml again preferring more
syntax over more ambiguity: when you read `if e then ...`, you know
`e` evaluates to one of two values, not to an arbitrarily-typed
value with one of seven possible truthiness rules.

The boolean operators are `&&` for conjunction, `||` for disjunction,
and `not` for negation. The familiar comparison operators `=`, `<>`,
`<`, `<=`, `>`, `>=` all return `bool`.

:::slide

## Booleans

```ocaml
let _ = true && false
let _ = true || false
let _ = not true
let _ = 3 < 5 && 5 < 10
let _ = "apple" = "apple"
let _ = "apple" <> "banana"
```

- `&&` and `||` **short-circuit** (as in C and Java).
- `=` is equality, `<>` is inequality.

:::

Both `&&` and `||` *short-circuit*, exactly as in C and Java:
`&&` evaluates its right argument only if the left was `true`, and
`||` evaluates its right only if the left was `false`. This lets
you safely write things like `x <> 0 && y / x > 1`: the division
is only attempted when `x` is nonzero. We will lean on this
behaviour later when we want to guard expensive computations.

The comparison operators (`=`, `<>`, `<`, `<=`, `>`, `>=`) all
return `bool`. We will look at them properly in the
[operators lecture](M01-L01-expressions.html#comparison-and-equality),
where the *structural* vs *physical* equality distinction also
gets its own treatment. For now: use `=` for equality, the way you
would use `==` in C.

## Strings

Strings in OCaml are sequences of bytes, written between double
quotes. They are *immutable*: once you have built a string, you
cannot modify a byte of it without explicitly converting through
the related type `bytes`. Most code never needs to do that, and so
treats strings as values, like integers: you build new ones from
old ones rather than mutating them in place.

A "byte string" is exactly that, a sequence of 8-bit bytes. OCaml's
`string` does not know about Unicode code points, or about encoding
in general. If your string contains the bytes that encode "café" in
UTF-8, then `String.length` reports 5 (the four ASCII letters plus
the two bytes that encode the accented "é"), not 4. For
Unicode-aware work the standard library is not enough; you reach
for an external library like `uutf` or `uucp`. Most code that just
concatenates, slices, or searches byte content does not need any of
that, and is perfectly happy with the byte view.

:::slide

## String literals

```ocaml
let hello = "hello"
let empty = ""
let multi = "first line\nsecond line"
let quote = "she said \"hi\""
let path  = "C:\\Users\\kc"
```

- Escape sequences (same as C): `\n` newline, `\t` tab,
  `\\` backslash, `\"` quote, `\NNN` decimal byte, `\xHH` hex byte.

:::

:::slide

## String concatenation: `^`

```ocaml
let s = "first" ^ " " ^ "second"
```

- `^` is the concatenation operator (not `+`).
- Separate from `+` because strings and numbers are different
  operations; each operator has one fixed meaning.

:::

The escape sequences inside string literals are the same family
you have seen in C: `\n` for newline, `\t` for tab, `\\` for a
literal backslash, `\"` for a literal double quote. 

:::slide

## String length and substrings

```ocaml
let _ = String.length "OCaml"
```

- Result: `int = 5`.
- `String` is the stdlib module for string functions.

:::fragment

```ocaml
let _ = String.sub "Functional programming" 0 10
```

- Result: `string = "Functional"`.
- `String.sub s start len` returns the substring of `s` of length
  `len` starting at position `start`.
- Indexing is **zero-based**.
- Out-of-bounds (`start + len > String.length s`) raises
  `Invalid_argument`.

:::

:::


Out-of-bounds access raises an exception, `Invalid_argument`. `String.sub s i n`
with `i + n` outside `0 .. length s` is a runtime error (`Invalid_argument`).

## Conversions between types

The standard library
provides explicit conversion functions wherever they make sense:

```ocaml
let _ = string_of_int 42      (* = "42" *)
let _ = float_of_int 7        (* = 7. *)
let _ = int_of_float 3.7      (* = 3, truncates toward zero *)
let _ = int_of_string "123"   (* = 123 *)
let _ = string_of_bool true   (* = "true" *)

let _ = int_of_float "test"
```
```mdx-error
Line 7, characters 24-30:
Error: This constant has type string but an expression was expected of type
         float
```

## Putting it together

Here is a function that uses three of the four primitive types we
have seen:

:::slide

## A larger expression

```ocaml
let password_strength len =
  if len < 8 then "weak"
  else if len < 12 then "ok"
  else if len < 16 then "good"
  else "strong"

let _ = password_strength 14  (* = "good" *)
```

- Function of type `int -> string`.
- Body is **one expression**: a chain of `if`/`then`/`else`.
- Full `if` lecture in Lecture 5.
- Literals (`8`, `12`, `"weak"`) combine into a working function.

:::

A C programmer reading this might object that the `if`s could be
rewritten as a `switch`. In OCaml, the equivalent of `switch` is
`match` (to be explained in a later lesson). But `match` is
overkill for a chain of *threshold comparisons* like this one; the right tool here is a nested `if`, the same as in any other language.

## Common pitfalls


**Pitfall 1: mixing `int` and `float`.** 

**Pitfall 2: using `==` for equality instead of `=`** 

**Pitfall 3: forgetting the decimal point.** 


**Pitfall 4: assuming string-on-string `=` is expensive.**

## A quick check

:::quiz mcq id=M02-L01-q2
What does this evaluate to?

```ocaml skip
let _ = 1 + 2.0
```

- [ ] `float = 3.0` (with an implicit cast)
- [ ] `int = 3` (the `2.0` is truncated)
- [x] Type error: `+` expects `int` on both sides; `2.0` is a `float`.
- [ ] Type error: `1` should have been `1.0`.

**Why:** OCaml never inserts implicit conversions between `int`
and `float`. The operator `+` takes two `int`s and returns an
`int`; the second operand `2.0` is a `float`, so the compiler
rejects the expression with "the constant 2.0 has type float but
an expression was expected of type int." Both the int-side and
the float-side framings are wrong: there is no preferred side, the
language simply refuses the call and asks you to insert a
`float_of_int` (or `int_of_float`) where you intended.
:::

:::quiz mcq id=M02-L01-q3
What does this evaluate to?

```ocaml
let _ = (-7) / 2
```

- [ ] `int = -4` (floor division)
- [x] `int = -3` (truncation toward zero)
- [ ] `float = -3.5`
- [ ] `exception Division_by_zero`

**Why:** OCaml's integer division `/` *truncates toward zero*,
not toward negative infinity. `(-7) / 2 = -3` (and `(-7) mod 2 =
-1`). Python 3 and many other languages floor instead, giving
`-4`; the convention is flipped relative to those languages. The
result is an `int` because both operands are `int` and OCaml does
not implicitly promote to `float`.
:::

----------------------------------

## `let` bindings and shadowing

So far we have seen literals: the smallest building
blocks of a program. This lecture introduces the next layer up:
*names*. Naming a value lets you compute it once and use it many
times; naming an intermediate result lets you break a long
calculation into readable steps. Almost every line of OCaml
contains at least one `let` binding.

We will treat `let` carefully. OCaml has two related forms with the
same keyword but different scoping, and the differences matter. We
will write down their syntax, give the typing rule (static
semantics) and the evaluation rule (dynamic semantics) for each,
and then look at *shadowing*, the property that reusing a name
introduces a new binding rather than mutating an old one.

## Two forms of `let`

The two forms share the keyword `let` but differ in *scope*: how
far through the program the bound name is visible.

- The **`let ... in` expression** introduces a name *local* to a
specific expression. Its abstract syntax is:

$$
\mathtt{let}\ x = e_1\ \mathtt{in}\ e_2
$$

Here $x$ is the bound identifier, $e_1$ is the *binding expression*
that supplies the value, and $e_2$ is the *body* in which $x$ is in
scope. The whole `let ... in` form is itself an expression: it
denotes the value $e_2$ evaluates to.

:::slide

## `let ... in` expression

$$
\mathtt{let}\ x = e_1\ \mathtt{in}\ e_2
$$

- $x$: the bound identifier.
- $e_1$: the binding expression (value to bind).
- $e_2$: the body (where $x$ is in scope).
- The whole form is *itself* an expression.

```ocaml
let _ = let y = 5 in y + 5
```

`int = 10`. Outside the `in`, `y` does not exist.

:::

- The **top-level `let`** introduces a name visible to the rest of
the file:

$$
\mathtt{let}\ x = e
$$

Read this as "let $x = e$ in *the rest of the program*". The body
is everything that follows in the same file (or in the toplevel
session). Top-level `let`s are sometimes called **definitions** to
emphasise that they bind a name into the program's namespace, not
into a local expression.

:::slide

## Top-level `let` (a *definition*)

$$
\mathtt{let}\ x = e
$$

Read as "$\mathtt{let}\ x = e\ \mathtt{in}$ *the rest of the program*."

```ocaml
let a = "Hello"
let b = "World"
let c = a ^ " " ^ b
```

`val c : string = "Hello World"`. The names `a` and `b` stay in scope
for every later binding in the file.

:::

The two forms are deeply related. A top-level `let x = e` is, in
effect, the same as `let x = e in <the rest of the file>`. The
language gives the `in` part implicitly at the file level so you
don't have to keep nesting.

## Typing judgements

Before we write down what the type system says about `let`, we
need a notation for *what type an expression has*. Programming-
languages people write this with a colon:

$$
e : t
$$

read as "expression $e$ has type $t$". This is a *typing
judgement*: a statement *about* a piece of program text. 

:::slide

## Typing judgements

$$
e : t
$$

reads "expression $e$ has type $t$". Some judgements:

- $5 : \mathtt{int}$
- $\mathtt{3.14} : \mathtt{float}$
- $\mathtt{"hello"} : \mathtt{string}$
- $\mathtt{true} : \mathtt{bool}$
- $(\mathtt{let}\ x = 5\ \mathtt{in}\ x + 5) : \mathtt{int}$


The compiler's job, when it type-checks your
program, is to produce a judgement like this for every expression
in it.

:::

## Inference rules

We rarely state typing judgements in isolation. Most of the time
we want to say: "*if* you know that these sub-expressions have
these types, *then* the bigger expression has this type." That is
exactly the job of an **inference rule**.

An inference rule has *premises* above a horizontal bar and a
*conclusion* below. Read it as "if every premise holds, then the
conclusion holds". The bar is shorthand for "implies".

Here is the inference rule that captures what `+` does to types:

$$
\dfrac{e_1 : \mathtt{int} \qquad e_2 : \mathtt{int}}
      {e_1 + e_2 : \mathtt{int}}
$$

Read top-to-bottom: *if* $e_1$ has type `int` *and* $e_2$ has type
`int`, *then* `e_1 + e_2` has type `int`. The whole type system is
a collection of such rules, one per language construct.

:::slide

## Inference rules

$$
\dfrac{\text{premise}_1 \qquad \text{premise}_2 \qquad \cdots
       \qquad \text{premise}_n}
      {\text{conclusion}}
$$

- Read as "if every premise holds, the conclusion holds".
- The horizontal bar is shorthand for "implies".

Example: the rule for integer `+`:

$$
\dfrac{e_1 : \mathtt{int} \qquad e_2 : \mathtt{int}}
      {e_1 + e_2 : \mathtt{int}}
$$

:::

## A typing rule for `let`

The typing rule for `let ... in` is:

$$
\dfrac{e_1 : t_1 \qquad x : t_1 \vdash e_2 : t_2}
      {(\mathtt{let}\ x = e_1\ \mathtt{in}\ e_2) : t_2}
$$

Read top-to-bottom: *if* $e_1$ has type $t_1$ *and* $e_2$ has type
$t_2$ *under the assumption that $x : t_1$*, *then* the whole `let`
has type $t_2$. The type of the binding form is the type of its
body. The bound expression's type flows in through the assumption
about $x$.

:::slide

## Typing rule for `let ... in` (static semantics)

$$
\dfrac{e_1 : t_1 \qquad x : t_1 \vdash e_2 : t_2}
      {(\mathtt{let}\ x = e_1\ \mathtt{in}\ e_2) : t_2}
$$

- **Static semantics**: this rule produces a *type*, not a value.
- $\vdash$ ("turnstile") reads as "assuming".
- The body's typing uses the assumption $x : t_1$.
- The whole `let` has the type of its **body** ($t_2$).
- Dynamic semantics (how it *evaluates*) comes next.

:::

For our example `let y = 5 in y + 5`: $e_1$ is `5`, which has type
`int`, so $t_1$ is `int`. Under the assumption $y : \mathtt{int}$,
the body `y + 5` has type `int` (by the rule for `+`). So $t_2$ is
`int`, and the whole expression has type `int`. The typing rule
reproduces what the toplevel told us.

## Dynamic semantics: how `let` evaluates

Static semantics gives us the *type* of an expression. *Dynamic*
semantics gives us its *value*. We use the same inference-rule
shape, but the judgement is now about evaluation: $e \to v$ reads
"$e$ evaluates to $v$". And $e_2[x := v]$ means "the result of
substituting $v$ for every free occurrence of $x$ in $e_2$".

The evaluation rule for `let ... in` is:

$$
\dfrac{e_1 \to v_1 \qquad e_2[x := v_1] \to v_2}
      {(\mathtt{let}\ x = e_1\ \mathtt{in}\ e_2) \to v_2}
$$

Read: evaluate $e_1$ first to a value $v_1$. Substitute $v_1$ for
every $x$ inside $e_2$. Evaluate the resulting expression to $v_2$.
That $v_2$ is the value of the whole `let`.

:::slide

## Evaluation rule for `let ... in` (dynamic semantics)

$$
\dfrac{e_1 \to v_1 \qquad e_2[x := v_1] \to v_2}
      {(\mathtt{let}\ x = e_1\ \mathtt{in}\ e_2) \to v_2}
$$

- **Dynamic semantics**: this rule produces a *value*, not a type.
- $e \to v$ reads "$e$ evaluates to $v$".
- Evaluate $e_1$ first; substitute $v_1$ for $x$ in $e_2$;
  evaluate the result.
- The *substitution model*. The implementation uses an environment,
  but the meaning is the same.

:::

## Nesting `let ... in`

Because `let ... in` is an expression, the body $e_2$ can itself
be another `let ... in`. Chain them to compute intermediate
values:

```ocaml
let _ =
  let x = 5 in
  let y = 10 in
  x + y  (* = 15 *)
```

Result: `int = 15`. The parsing is right-associative: the chain
above is `let x = 5 in (let y = 10 in (x + y))`. Each binding is
in scope for the rest of the chain.

:::slide

## Nested `let ... in`

```ocaml
let _ =
  let x = 5 in
  let y = 10 in
  x + y
```

`int = 15`. Parsed right-associatively:

$$
\mathtt{let}\ x = 5\ \mathtt{in}\ (\mathtt{let}\ y = 10\ \mathtt{in}\ x + y)
$$

:::

:::slide

## Tracing the substitution

$$
\begin{aligned}
& \mathtt{let}\ x = 5\ \mathtt{in}\ (\mathtt{let}\ y = 10\ \mathtt{in}\ x + y) \\
\to\ & \mathtt{let}\ y = 10\ \mathtt{in}\ (5 + y) \qquad [x := 5] \\
\to\ & 5 + 10 \qquad [y := 10] \\
\to\ & 15
\end{aligned}
$$

Each `→` applies the `let` evaluation rule once: evaluate the
bound expression, substitute its value for the name in the body,
evaluate the result.

:::

You can also let-bind an entire `let`. The right-hand side of a
binding is any expression, so:

```ocaml
let _ =
  let x = 5 in
  let y =
    let z = 10 in z + z
  in
  x + y  (* = 25 *)
```

Result: `int = 25`. The inner `let z = 10 in z + z` evaluates to
`20`, which becomes the value bound to `y`. Then `x + y` is `25`.

## Shadowing

OCaml lets you reuse a name in a new binding without mutating
anything. This is called **shadowing**. Here is the classic
example:

:::slide 

## Shadowing

```ocaml
let x = 1
let x = x + 1
let x = x * 10
```

After three lines, the name `x` refers to `20`.
:::

:::slide

## Shadowing in `let ... in`

```ocaml
let _ =
  let x = 5 in
  let x = x + 5 in
  x
```

`int = 10`. The RHS `x + 5` reads the outer `x = 5`; the result
`10` binds a fresh inner `x` that hides the outer for the body.
**Two separate $x$ slots, no mutation.**

:::

## Shadowing differs from mutation 

The clearest demonstration that shadowing is not mutation comes
from [closures](M03-L01-functions-as-values.html#a-function-value-remembers-its-environment) seen in the following example: 


:::slide

## Shadowing is not mutation

```ocaml
let x = 1
let f () = x
let x = 99
let _ = f ()
```

What does `f ()` return?

 <details><summary>`f ()`'s return value</summary>

The answer is `1`. 
In line `95`, when f was defined, x = `1`. The function body refers to `x`. OCaml does *not* re-look-up
the name `x` every time `f` is called; it captured the *value* `x
= 1` when `f` was defined. After `let x = 99`, the name `x` now
refers to a different binding, but `f` is unaffected; it still
returns what `x` meant when `f` was defined.

This is the property of *closures*: a function body, at the moment
of definition, captures the bindings that were in scope. We will
see closures in much more detail in
[Module 3](M03-L01-functions-as-values.html#a-function-value-remembers-its-environment).
The key fact for this lecture: the *value* gets captured, not "the
current meaning of the name."

In a language where `let` actually mutates a cell, the same code
would produce different behaviour. Some languages do work that way
(Python is closer to this model: a closure captures a *reference*
to the variable, not its value, so reassignment is visible through
the closure). OCaml's choice (capture the value) is what people
mean by *static scoping with value capture*: it is more
predictable, easier to reason about, and matches what mathematical
functions do.


</details>
:::


## Scope: outer versus inner

When a local `let ... in` shadows an outer binding, the inner
binding is in scope only inside its `in` expression. Outside, the
outer binding is restored.

:::slide

## Scope: outer vs inner

```ocaml
let x = 100

let _ =
  let x = 1 in
  x

let _ = x
```

- First `_` is `1`: inner `x` shadows for the body only.
- Second `_` is `100`: outer `x` restored after the `in`.

Same shape as nested scopes in C / Java.

:::

## Idiom: shadowing for step-by-step transformations

A common idiom is to transform a value through several steps and
rebind the same name at each step. This reads top-to-bottom like
a procedure, but it is a single expression with three nested
`let ... in`s:

```ocaml

(* with shadowing of variable `s` *)
let _ =
  let s = "  Hello World  " in
  let s = String.trim s in
  let s = String.lowercase_ascii s in
  s  (* = "hello world" *)



(* descriptive names instead of shadowing *)

let _ =
  let raw      = "  Hello World  " in
  let trimmed  = String.trim raw in
  let lowered  = String.lowercase_ascii trimmed in
  lowered  (* = "hello world" *)
```

Whether you prefer
shadowing or distinct names is taste. The shadowing version
emphasises "this is one value being transformed"; the descriptive
version names what each intermediate is.

## Underscore: "I don't care about the name"

The pattern `_` matches any value and discards it. You can use it
in a `let` binding when you want to evaluate something for its
side effect (or to make the toplevel print the result) but don't
need to bind a name.

:::slide

## Underscore: "I don't care about the name"

```ocaml
let _ = print_endline "hi"
let _ = 3 + 4  (* = 7 *)
```

- `_` matches any value and discards it.
- `let _ = print_endline ...`: side-effecting call; result is `()`.
- `let _ = 3 + 4`: toplevel prints, no binding kept.
- `let _name = ...`: bind but don't warn me if unused.

:::

## Sequencing with `;`

The sequencing operator `;` appeared when we wrote
[the first programs](M01-L04-hello-world.html#sequencing-with):
`e1; e2` evaluates `e1`, discards its value, then evaluates `e2`,
and the whole expression takes the value of `e2`:

```ocaml
let _ = print_endline "hi"; 6  (* = 6 *)
```

The connection to `let`: `e1; e2` is *syntactic sugar* for
`let _ = e1 in e2`. Same evaluation, same result. The semicolon
is shorter, which is why you will see it in most real code.

Because the value of `e1` is thrown away, the compiler expects
`e1` to have type `unit`: a value with nothing useful to discard.
If it does not, OCaml issues a *warning*, not an error:

```ocaml skip
let _ = 5; 6
```

The compiler emits `Warning 10 [non-unit-statement]: this
expression should have type unit.` The program still compiles and
runs (and produces `6`); the warning is OCaml suggesting that
discarding an `int` is probably a mistake.

## A small code challenge

:::quiz code id=M02-L02-q1
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

:::solution

One sample solution:

```ocaml
let four_step n =
  let x = n + 1 in
  let x = x * 2 in
  let x = x - 3 in
  let x = x * 5 in
  x
```

Four shadowing bindings, each one transformation step. There is no
mutation. Each `let x = ... in` is a brand new binding.

:::
-------------------------

## Type semantics, and type inference

:::slide

## Two kinds of semantics

Every expression has both:

- **Static semantics**: meaning *before* you run; mainly its **type**.
- **Dynamic semantics**: what happens when you *run* it; a **value**.

```ocaml
let _ = 23 + 45
```

- Static: `int + int`, expression has type `int`.
- Dynamic: evaluates to `68`.
- Static catches whole classes of bug before Run.

:::

The two kinds of meaning are independent: knowing the type of an
expression does not, in general, tell you its value (it tells you
which *kind* of values are possible). Knowing the value does not
formally tell you the type, though usually it constrains it.

A *type error* is a violation of static semantics: the compiler
notices a mismatch and refuses to produce a runnable program. A
*runtime exception* (like division by zero, or out-of-bounds array
access) is a violation of dynamic semantics: the program runs and
encounters an unexpected situation at execution time.

:::slide

## A spectrum of languages

Spectrum, not binary:

- **Mostly dynamic** (JavaScript, Python): everything checked at runtime.
- **Some static** (C): types declared but weak; casts and `void*` sidestep it.
- **More static** (Java, Scala, Rust, Kotlin, Swift): strong typing,
  but nulls and downcasts surface at runtime.
- **Mostly static** (OCaml, Haskell): almost no runtime type errors.

OCaml sits at the **mostly static** end.

:::

 <details><summary>Type semantics of different languages</summary>


**Mostly dynamic** (JavaScript, Python, Ruby). Almost everything is
checked at runtime. You can write `x + "1"` in Python and find out
*at execution time* whether it makes sense (it does not, in
Python 3). Programs work in test until an untested code path runs;
a typo in a method name is a runtime error, not a compile error.

**Some static, mostly dynamic** (C). Types are declared, but the
type system is weak: casts and `void*` give you escape hatches that
the compiler does not police. Pointer arithmetic can manufacture
nonsense without complaint. Memory errors (use-after-free,
buffer overflow) are detected (if at all) at runtime, often
silently corrupting data before crashing somewhere else.

**More static** (Java, Scala, Rust, Kotlin, Swift, C#). Stronger
type systems; many errors that would be runtime in dynamic
languages are compile-time here. But there are still escape
hatches: null references are usually nullable by default in Java
(NullPointerException at runtime), downcasts can fail at runtime,
generics have erasure issues. Rust is closer to fully static.

**Mostly static** (OCaml, Haskell, Idris). Almost no runtime type
errors in well-typed code. There is no `null` by default (you opt
in via `Option`, which the type system tracks). Casts that the
type checker can't verify are explicit and rare. Most of the
errors you would discover at runtime in Python or Java, you
discover at compile time in OCaml.

The trade-off is real: more static checking means more upfront
work to get the types right, in exchange for fewer runtime
surprises. OCaml's bet is that the upfront cost is small (because
of inference, see below) and the runtime payoff is large. The same
bet underlies Rust and Haskell.
</details>

:::slide

## A static error

```ocaml skip
let _ = 23 = 45.0
```

- Rejected: left is `int`, right is `float`.
- `=` requires both sides to have the **same type**.

```
Error: The constant 45.0 has type float but an expression was
       expected of type int
```

- Program does not run; static check fails first.

:::

:::slide

## A dynamic check (not an error)

```ocaml
let _ = 23 = 45
```

- Both sides `int`: static check passes, type is `bool`.
- Runtime: evaluates to `false`. A **value**, not an error.
  - This is the distinction worth internalising: type errors and
"wrong answers" are different categories of failure. The first is
a question about the *shape* of your program; the second is about
its *behaviour*. Static checking aims at the first.
:::



## Why catch errors statically?

Why bother with this whole static apparatus, when dynamic languages
let you write code faster? Four reasons that compound:

:::slide

## Why catch errors statically?

- **Earlier is cheaper.** Compile-time bugs can't ship.
- **Better localization.** Compiler points at file and line.
- **Fearless refactoring.** Rename a field; compiler lists every call site.
- **Documentation.** Types annotate the API, mechanically checked.

**Cost:** upfront friction. Trade fewer bugs later for more work now.

:::

<details><summary>Type inference algorithm for OCaml</summary>


The reason the static type system is bearable in OCaml is *type
inference*: the compiler works out what types your expressions have
without you having to write them down. OCaml's inference is based
on the [Hindley-Milner algorithm](https://en.wikipedia.org/wiki/Hindley%E2%80%93Milner_type_system)
(developed by Roger Hindley in combinatory logic and rediscovered
by Robin Milner for ML in the 1970s). The intuition is straightforward, even if the algorithm
itself has some clever parts:

1. Every expression has some type. Initially the compiler treats
   each unknown type as a fresh type variable (`'a`, `'b`, ...).
2. Operators and literal forms generate *constraints*: `+` says its
   two operands must be `int` and its result is `int`. The literal
   `3.14` says it is `float`. A function call says the argument's
   type must match the function's parameter type.
3. The compiler collects all these constraints and *solves* them: it
   finds a consistent assignment of types to every expression in
   the program. If no consistent assignment exists, you get a type
   error.
4. The final inferred type of each binding is reported.

You will never implement this algorithm yourself in this course;
you only need to read its output. When the toplevel reports a type
for a function you wrote, it ran inference.
</details>
:::slide

## Inference for a simple function

```ocaml
let mean x y = (x + y) / 2
```

Toplevel reports: `val mean : int -> int -> int = <fun>`.

- `+` and `/` both have type `int -> int -> int`.
- The literal `2` is `int`.
- So `x : int`, `y : int`, result `int`.
- Therefore `mean : int -> int -> int`.
- **Zero annotations written.** 

Every step is a constraint generated from an operator or literal;
the inference algorithm runs through them all and reports the type.
We wrote no annotations; everything was inferred by the compiler.

:::


### As an inference rule

The same reasoning, written formally. The typing rule for `+` is:

$$
\dfrac{e_1 : \mathtt{int} \qquad e_2 : \mathtt{int}}
      {e_1 + e_2 : \mathtt{int}}
$$

For our function body `(x + y) / 2`, the premises of `+` ask
`x : int` and `y : int`; the premises of `/` ask its operands to be
`int`. Those become the *constraints* the algorithm collects.
Solving them gives `mean : int -> int -> int`. The inference engine
is essentially building a derivation tree out of these rules and
reading the leaves to assign types to the parameters.


```ocaml
let mean_f x y = (x +. y) /. 2.0
```

Same shape, float operators. `+.` and `/.` both have type
`float -> float -> float`; the literal `2.0` is `float`. So `x`
and `y` are forced to be `float`, the result is `float`, and the
function has type `float -> float -> float`.

**The operator drives the inference.** To predict the type, we need to look at the operators and function calls; each one imposes constraints; the constraints propagate; the type
falls out.

## A trickier example

:::slide

## A trickier example

```ocaml
let mag x y = sqrt (x *. x +. y *. y)
```

`val mag : float -> float -> float = <fun>`.

- `sqrt : float -> float`, argument must be `float`.
- So `x *. x +. y *. y` must be `float`.
- `*.` and `+.` force operands to `float`.
- Hence `x : float`, `y : float`, result `float`.
- Many languages need this spelled out as annotations; OCaml infers it.

:::


## When to write annotations

Type annotations are optional, and the compiler checks them against what
inference would have produced. Now that we have seen what
inference actually does, the practical question is *when* to
write them.

Use annotations when:

- **The function is part of a public API.** Then the annotation is
  documentation: it tells a reader what the function expects without
  forcing them to read the body.
- **You want to constrain inference.** Occasionally inference would
  produce a more general type than you want. Annotating constrains
  it.
- **You are debugging a confusing type error.** Adding annotations
  to suspect functions narrows where the error gets reported. The
  compiler now blames *that* function instead of some caller.

Module signatures (`.mli` files) are entirely annotations: they list the types of a module's
exports, and the compiler enforces them against the module's
implementation. We will see this in detail later.

For ordinary local helpers, leave annotations off. They clutter.

## A quick check

:::quiz mcq id=M02-L03-q2
Which of the following best describes the difference between a
*static* error and a *dynamic* error?

- [ ] Static errors happen at runtime; dynamic errors happen at
      compile time.
- [x] Static errors are caught by the compiler before the
      program runs; dynamic errors only show up while the
      program is running.
- [ ] Static errors are warnings; dynamic errors are fatal.
- [ ] Static and dynamic errors are two names for the same
      thing.

**Why:** "static" means *at compile time*, before the program
runs. The OCaml compiler rejects programs whose types don't
line up; you never get to run them. "Dynamic" means *at run
time*: even a well-typed program can still raise an exception
(e.g. division by zero), but that surfaces only once execution
reaches the bad expression. Languages differ in where they put
that line; OCaml puts a lot on the static side.
:::

:::quiz mcq id=M02-L03-q3
The toplevel reports

```text
val g : float -> int -> float = <fun>
```

for some function `g`. Which call type-checks?

- [ ] `g 1 2`
- [ ] `g 1.0 2.0`
- [x] `g 1.0 2`
- [ ] `g 2 1.0`

**Why:** the inferred signature says `g` takes a `float` first
and an `int` second, and returns a `float`. So the first
argument must be a `float` literal (`1.0`) and the second must
be an `int` literal (`2`). OCaml does not implicitly convert
between `int` and `float`; the literal `1` is `int`, the
literal `1.0` is `float`, and the compiler does not silently
coerce one to the other.
:::

---

## Lecture 4: Operators, precedence, and common pitfalls

This lecture lays out the full set of operators and lays out the details of which bind tighter than
which, and walks through the small set of mistakes that beginners
reliably make in their first week. 

## Arithmetic, by type

OCaml has separate arithmetic operators for `int` and `float`. The
float versions all carry a trailing dot. You have seen this before;
the full table is worth having in one place.

:::slide

## Arithmetic, by type

| Operation | `int` | `float` |
| --- | --- | --- |
| Add | `a + b` | `a +. b` |
| Subtract | `a - b` | `a -. b` |
| Multiply | `a * b` | `a *. b` |
| Divide | `a / b` (truncating) | `a /. b` |
| Remainder | `a mod b` | (`Float.rem a b`) |

- Float operators all end in `.`.
- Mixing `int` and `float`: **type error**.
- Convert with `float_of_int` or `int_of_float`.

:::

:::slide

## Arithmetic, by type: power, negate, abs

| Operation | `int` | `float` |
| --- | --- | --- |
| Power | (no built-in; write `x * x * x`) | `a ** b` |
| Negate | `-a` | `-. a` |
| Absolute | `abs a` | `Float.abs a` |

- `**` is float-only; the stdlib has no integer `pow`. Spell out
  the multiplication, or write a small recursive `pow`.
- Float negation `-.` is the one prefix-operator-with-a-dot.
- `abs_float` is deprecated; prefer `Float.abs`.

:::

If you need float remainder, use `Float.rem a b` from the
standard library.

## Comparison and equality

The comparison operators (`<`, `<=`, `>`, `>=`) and the logical
operators (`&&`, `||`, `not`) were introduced with
[booleans](M01-L01-expressions.html#booleans).

OCaml has *two* equality
operators: 

- `=` is **structural** equality: do the two values have the same
  *contents*? It compares recursively (two ints are `=` when they
  are the same number, two strings when they have the same bytes,
  two pairs when their components are correspondingly `=`) and it
  is *polymorphic*: the one operator works on ints, floats,
  strings, pairs, and most other data. Its negation is `<>`.
- `==` is **physical** equality: are the two values the *same
  object in memory*? Its negation is `!=`. Physical equality only matters in advanced code
that cares about sharing and mutation; when you meet `==` in the
wild, read it as a deliberate, expert-level choice.

Let's see an example:

```ocaml
let p = (1, 2)
let q = (1, 2)

let _ = p = q    (* = true  : same contents *)
let _ = p == q   (* = false : two distinct objects in memory *)
let _ = p == p   (* = true  : literally the same object *)
```

`p` and `q` are structurally equal but physically distinct: each
`(1, 2)` allocated its own pair. This is the trap for programmers
arriving from C or Java, where `==` *is* the everyday equality
operator: an OCaml `==` test compiles fine and then returns
`false` for values you can plainly see are equal. If an equality
test in your code is mysteriously failing, check the operator
first.

The disagreement needs an *allocated* value to show up. An `int`
is stored directly in the machine word, not behind a pointer, so
two equal ints are the same bits and `==` cannot tell them apart:

```ocaml
let _ = 1 == 1      (* = true : no allocation, no separate identity *)
let _ = 'a' == 'a'  (* = true : chars and booleans work the same way *)
```

This is what makes the trap quiet: tested on ints, `==` appears to
behave as everyday equality, and it stops the moment the data is a
pair, a list, or a string. Always write `=`.

One caveat to file away: structural equality works on *data*, but
it raises a runtime exception (`Invalid_argument "compare:
functional value"`) if the values being compared contain
functions, because there is no general way to decide whether two
functions behave identically.

## String concatenation

:::slide

```ocaml
let _ = "first" ^ " " ^ "second"
```

- `^` is **right-associative**.
- Fine for a few; for many, use `String.concat`:

```ocaml
let _ = String.concat ", " ["apple"; "banana"; "cherry"]
```

- `String.concat sep xs`: joins `xs` with `sep` between.
- Faster than chained `^`.

:::

For formatted output, `Printf.sprintf` is the standard tool:

```ocaml
let _ = Printf.sprintf "value: %d" 5  (* = "value: 5" *)
(* The format string `"%d"` is the C-style integer specifier *)

```

## Function application is its own "operator"

:::slide

- **Function application is juxtaposition.** No parens.

```ocaml
let _ = succ 5
let _ = max 3 7
let _ = String.length "hello"
```

- Function application is **left-associative**: `f x y` parses as
  `(f x) y`.
- Parens only for **grouping**:

```ocaml
let _ = succ (max 3 7)
```

```ocaml
let _ = succ max 3 7 
```
```mdx-error
Line 1, characters 9-19:
Error: The function succ has type int -> int
       It is applied to too many arguments
Line 1, characters 18-19:
  This extra argument is not expected.
```

:::

The "no parentheses on function call" rule takes adjusting to if
you came from C-family languages. The reason OCaml does this is
that it makes *partial application* (supplying some but not all
arguments and getting back a function) a natural reading. We will
see in the next set of lessons.

## Operator precedence

Here is OCaml's operator precedence, tightest at the top, loosest at
the bottom. Levels separated by horizontal lines bind tighter than
levels below.

:::slide

## Operator precedence (tightest to loosest)

<div class="precedence-table">

| Lvl | Operators                                  | Notes              |
|----:|--------------------------------------------|--------------------|
|   1 | `.`                                        | record / module access |
|   2 | $f\ x$                                     | function application |
|   3 | `*`, `/`, `mod`, `*.`, `/.`                | multiplicative     |
|   4 | `+`, `-`, `+.`, `-.`                       | additive           |
|   5 | `^`, `@`                                   | string / list concat |
|   6 | `<`, `=`, `>`, `<=`, `>=`, `<>`            | comparisons        |
|   7 | `&&`                                       | logical and        |
|   8 | <code>&#124;&#124;</code>                  | logical or         |
|   9 | `,`                                        | tuple constructor  |
|  10 | `;`                                        | sequence           |

</div>

- When in doubt, **parenthesize**.

:::

:::slide

## Pitfall 1: `+` instead of `+.`

```ocaml skip
let area r = 3.14159 * r * r
```

OCaml refuses:

```
Error: The constant 3.14159 has type float
       but an expression was expected of type int
```

Fix: `3.14159 *. r *. r`. The operator drives the type.

:::

:::slide

## Pitfall 2: implicit conversion that isn't there

```ocaml skip
let _ = "value: " ^ 5
```

```
Error: The constant 5 has type int but an expression was expected
       of type string
```

- Python / JavaScript coerce silently. OCaml does not.

```ocaml
let _ = "value: " ^ string_of_int 5
```

Or `Printf.sprintf` for richer formatting:

```ocaml
let _ = Printf.sprintf "value: %d" 5
```

- The lack of implicit conversion is a feature, not a bug. Languages
that *do* coerce automatically have famously confusing edge cases
(JavaScript's `1 + "1" == "11"` but `1 - "1" == 0`; Python's
"strict but with surprises"). OCaml's "always be explicit" rule
means you read code and know exactly what conversion is happening.
:::

:::slide

## Pitfall 3: subtraction syntax

```ocaml skip
let _ = abs -5
```

- Looks like "absolute value of negative 5".
- **Parses as** `abs - 5`: type error.
- Fix: parenthesize the negative.

```ocaml
let _ = abs (-5)
```

- Same trap with `-.` for floats.

:::


## Pitfall 4: comparison chains are not a thing

In Python, `0 < x < 10` reads as you'd hope: "x is between 0 and
10." Python is unusual in supporting this; OCaml (like most
languages) does not (we bind `x` to `5` so the chain itself is
the only error):

```ocaml skip
let _ = let x = 5 in 0 < x < 10
```

:::slide

```ocaml skip
let _ = let x = 5 in 0 < x < 10
```

- Parses as `(0 < x) < 10`: compares a `bool` to `10`.
- Error: constant `10` has type `int` but expected `bool`.
- Spell it out with `&&`:

```ocaml
let _ = let x = 5 in 0 < x && x < 10  (* = true *)
```

- Python supports chains; OCaml (like most languages) does not.

:::

## A quick check

:::quiz mcq id=M02-L04-q2
What is the value of this OCaml expression?

```ocaml
let _ = 1 + 2 * 3 = 7 && true
```

- [ ] `false`
- [x] `true`
- [ ] A type error: `int` compared to `bool`.
- [ ] `7`

**Why:** apply precedence. `*` binds tighter than `+`, so `2 * 3 =
6`. Then `+`: `1 + 6 = 7`. Then `=`: `7 = 7` is `true`. Then `&&`:
`true && true` is `true`. Reading the implicit parentheses:
`(((1 + (2 * 3)) = 7) && true)`. The expression has type `bool`
and value `true`.
:::

A code challenge to close out:

:::quiz code id=M02-L04-q1
Write `in_range : int -> int -> int -> bool` that returns `true`
exactly when `x` lies in the closed interval `[lo, hi]`. Use the
`&&`-idiom this lecture introduced. Argument order:
`in_range lo hi x`.

```ocaml
let in_range lo hi x =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (in_range 0 10 5     = true)  "interior";
  check (in_range 0 10 0     = true)  "at lower bound";
  check (in_range 0 10 10    = true)  "at upper bound";
  check (in_range 0 10 (-1)  = false) "below";
  check (in_range 0 10 11    = false) "above";
  print_endline "all tests passed"
```
:::

:::solution

`let in_range lo hi x = lo <= x && x <= hi`. The `&&` short-circuits,
so the upper-bound check only runs when the lower-bound check
already passed.

:::


---

## `if`/`then`/`else` as an expression

The conditional construct is familiar from
every language you have written before: a way to choose between two
courses of action depending on a boolean. The OCaml version of
`if`/`then`/`else` looks similar at first, but it has a property
that changes how you write code: in OCaml, `if`/`then`/`else` is an
*expression* that has a value, not a *statement* that just runs
something. This is a small syntactic difference with a big
consequence for how programs are structured.

If you arrived from C, Java, or Python, you have written code like
"declare a variable; do an `if`; assign the variable in each
branch." OCaml lets you collapse that pattern: bind the variable
directly to the result of the `if`. The line shrinks, the
intermediate state disappears, the program becomes easier to read.
The cost is a single rule: both branches must produce values of the
same type. We will see why this rule is necessary and how to live
within it.

## In C, `if` is a statement

:::slide

## In C, `if` is a statement

```c
int abs_val;
if (x < 0) abs_val = -x; else abs_val = x;
```

- `if`/`else` **does something** but has **no value**.
- Can't write `int abs_val = if (x < 0) -x else x;` in C.
- Forces separate declaration plus separate statement.

:::

Some C-family languages have a *ternary* operator `cond ? a : b`
that *is* an expression, returning either `a` or `b`. So you can
write `int abs_val = (x < 0) ? -x : x` in C, Java, JavaScript. The
ternary is OCaml's `if`-as-expression in disguise. But the ternary
is awkward to nest, and most C programmers write the statement
form for anything beyond simple cases.

## In OCaml, `if` is an expression

:::slide

```ocaml
let abs_val x = if x < 0 then -x else x
```

- `if x < 0 then -x else x` is an **expression** with a value.
- Bind it, return it, pass it as an argument.
- No "first declare, then fill in"; the expression **is** the value.

:::

Anywhere an expression can
go, an `if` can go: as a function argument, as the right-hand side
of a `let`, inside another expression:

```ocaml
let _ = print_endline (if true then "yes" else "no")
```

```ocaml
let nat = let n = 7 in if n >= 0 then n else 0
```

## The shape and type rule

:::slide

## The shape

$$
\mathtt{if}\ e_1\ \mathtt{then}\ e_2\ \mathtt{else}\ e_3
$$

- $e_1$ **condition**: must be `bool`.
- $e_2$ **then-branch**: some type $t$.
- $e_3$ **else-branch**: must be the **same $t$** as $e_2$.
- Whole expression: type $t$.

```ocaml
let _ = if true then 13 else 14
```

`int = 13`. Both branches `int`, whole expression `int`.

:::


## Why the branches must agree

```ocaml skip
let _ = if true then 13 else 13.4
```

OCaml rejects this with:

```
Error: The constant 13.4 has type float
       but an expression was expected of type int
```

The branches return different types: `int` in one case, `float` in
the other. The compiler cannot assign a *single* type to the whole
`if`-expression. If it accepted the program, the type would depend
on which branch ran at runtime: dynamic, not static. This goes
against the entire point of static typing (a program's types are
known before it runs).

The fix is to bring both branches to the same type. Either both
floats:

```ocaml
let _ = if true then 13.0 else 13.4  (* = 13. *)
```

Or both ints:

```ocaml
let _ = if true then 13 else int_of_float 13.4  (* = 13 *)
```

The compiler will not pick for you. You decide which type you want
and convert the other branch to match.

The rule generalises to anything, not just numbers. If the branches
return a `string` and an `int`, you get a type error. If they
return a list of `int` and a list of `string`, same thing. The
rule is "both branches the same type", full stop.

## The typing rule, written out


:::slide

$$
\dfrac{e_1 : \mathtt{bool} \qquad e_2 : t \qquad e_3 : t}
      {(\mathtt{if}\ e_1\ \mathtt{then}\ e_2\ \mathtt{else}\ e_3) : t}
$$

- **Premises** above the bar; **conclusion** below.
- Same $t$ in both branches: that's the "branches must agree" rule.
- Whole expression has the branches' type, $t$.

:::

:::slide

## Evaluation rules for `if`

$$
\dfrac{e_1 \to \mathtt{true} \qquad e_2 \to v}
      {\mathtt{if}\ e_1\ \mathtt{then}\ e_2\ \mathtt{else}\ e_3 \to v}
$$

$$
\dfrac{e_1 \to \mathtt{false} \qquad e_3 \to v}
      {\mathtt{if}\ e_1\ \mathtt{then}\ e_2\ \mathtt{else}\ e_3 \to v}
$$

- Two rules; condition picks which fires.
- The other branch is **not evaluated**.

:::

You do not have to read these rules to use OCaml. They are useful
notation when we need to be precise about *exactly* what the type
checker does and what the program does. Later lessons that include data types and pattern matching introduce more constructs with their own rules.

## A typical use: multi-way branching


:::slide

```ocaml
let grade_letter score =
  if score >= 90 then "A"
  else if score >= 80 then "B"
  else if score >= 70 then "C"
  else if score >= 60 then "D"
  else "F"

let _ = grade_letter 87
```

- Result: `string = "B"`.
- Chain of `if`/`then`/`else` is **one expression** of type `string`.
- Shape for "compute X based on input Y".

:::

For multi-way branching on a *value's structure* (rather than on
threshold comparisons), the better tool is pattern matching. Use
`if` chains when you have threshold comparisons or boolean
predicates; use `match` when you are unpacking a value.

## `if` without `else`


:::slide

## `if` without `else`

- `if cond then expr` with no `else`: implicit `else ()`.
- So `expr` must have type `unit`.

```ocaml
let warn_if_negative x =
  if x < 0 then print_endline "warning: negative"
```

- `val warn_if_negative : int -> unit`.
- For positive `x`, function returns `()` and prints nothing.
- Use one-armed `if` only for **side effects**.
- For computing a value, you need both branches.

:::


## Nested `if`s

:::slide

## Branches can themselves be `if`s

```ocaml
let sign x =
  if x > 0 then 1
  else if x < 0 then -1
  else 0
```

- `else if` is just `else (if ... then ... else ...)`.
- Same expression, parens explicit:

<pre class="static-code"><code>let sign x =
  if x &gt; 0 then 1
  else (if x &lt; 0 then -1 else 0)
</code></pre>

- Idiomatic OCaml leaves the parens off.

:::

As we said: `else if` is sugar for `else (if ... then ... else
...)`. Either form is fine; the unparenthesised form reads more
naturally for a chain.

## A quick check

:::quiz mcq id=M02-L05-q3
Which of the following OCaml expressions has type `string`?

- [x] `if x > 0 then "positive" else "non-positive"`
- [ ] `if x > 0 then "positive" else 0`
- [ ] `if x > 0 then "positive"`
- [ ] `if "x" > 0 then "yes" else "no"`

**Why:** the first has both branches returning `string` (the
correct shape). The second mixes `string` and `int` branches:
type error. The third has no else, which OCaml treats as
`else ()`; the then-branch would have to be `unit`, but it's
`string`: type error. The fourth has the condition `"x" > 0`,
which compares `string` to `int`: type error.
:::

A code challenge:

:::quiz code id=M02-L05-q2
Define `max3 : int -> int -> int -> int` that returns the
largest of three integers. Use only nested `if`/`else`; do not
call any library function.

```ocaml
let max3 a b c =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (max3 1 2 3 = 3) "ascending";
  check (max3 3 2 1 = 3) "descending";
  check (max3 5 9 4 = 9) "middle largest";
  check (max3 7 7 7 = 7) "all equal";
  check (max3 (-1) (-5) (-3) = -1) "all negative";
  print_endline "all tests passed"
```
:::

:::solution

One shape: pick the larger of `a` and `b` first, then compare
that against `c`. `if a > b then (if a > c then a else c) else (if
b > c then b else c)`. The whole expression is an `int` because
every branch is an `int`.

:::

---

<!--  ## Lecture 6: Tutorial: small expressions, end to end

:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Tutorial: small expressions, end to end</h2>
<p class="title-slide-label">Module 2 &middot; Lecture 6</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

This is the tutorial video for Module 2. We will work through five
small programs that exercise everything in the module:
[literals](M01-L01-expressions.html), [`let` bindings](M01-L01-expressions.html#lecture-2-let-bindings-and-shadowing),
[type inference](M01-L01-expressions.html#lecture-3-static-vs-dynamic-semantics-and-type-inference),
[operators](M01-L01-expressions.html#lecture-4-operators-precedence-and-common-pitfalls), and
[`if`-expressions](M01-L01-expressions.html#lecture-5-ifthenelse-as-an-expression). After the worked
problems, we will dwell on the three type errors you will see most
often in your first programs, and close with an activity for you
to try.

The point of the tutorial is to *type code* and meet the type
errors when they show up. Every cell is editable. Make
deliberate mistakes; see what the compiler says; fix them. The
five-minute frustration of "why won't this compile" is the
fastest path to fluency.

## Problem 1: classify a response time

A function that returns a label for an HTTP response time in
milliseconds. The classification: under 50ms is "instant", under
200ms is "fast", under 1000ms is "noticeable", anything else is
"slow".

```ocaml
let response_class ms =
  if ms < 50.0 then "instant"
  else if ms < 200.0 then "fast"
  else if ms < 1000.0 then "noticeable"
  else "slow"

let _ = response_class 180.0  (* = "fast" *)
```

:::slide

## Problem 1: classify a response time

- Return a label for an HTTP response in milliseconds.
- Labels: "instant", "fast", "noticeable", "slow".

```ocaml
let response_class ms =
  if ms < 50.0 then "instant"
  else if ms < 200.0 then "fast"
  else if ms < 1000.0 then "noticeable"
  else "slow"

let _ = response_class 180.0
```

- Result: `string = "fast"`.
- Try `5.0`, `500.0`, `3000.0`.
- Boundary: `50.0` is "fast"; `<` is **strict**.

:::

Result for `180.0`: `string = "fast"`. Try the boundaries:
`response_class 50.0` returns `"fast"` (because `<` is strict; 50
is not less than 50); `response_class 200.0` returns
`"noticeable"`. The choice of `<` vs `<=` at thresholds is a
judgement call. Both are right; this version treats 50 ms as
"fast" and 200 ms as "noticeable". If you would rather it be the
other way (treat 50 ms as "instant"), swap `<` for `<=`. The
point is to be deliberate.

This is also a good example of a function that has type `float
-> string`: the operator drives inference. The comparisons are
against `float` literals (`50.0`, `200.0`, etc.), so `ms` is
`float`; the branches return string literals, so the body has
type `string`; the function is `float -> string`.

## Problem 2: leap year

A year is a leap year if it is divisible by 4, *unless* divisible
by 100, *unless again* divisible by 400. So 2000 is a leap year
(divisible by 400), 1900 is not (divisible by 100 but not by 400),
2024 is (divisible by 4, not by 100), 2025 is not (not divisible
by 4).

```ocaml
let is_leap y =
  (y mod 4 = 0 && y mod 100 <> 0) || y mod 400 = 0

let _ = is_leap 2024  (* = true *)
let _ = is_leap 2025  (* = false *)
let _ = is_leap 1900  (* = false *)
let _ = is_leap 2000  (* = true *)
```

:::slide

## Problem 2: a leap year predicate

- Leap year: divisible by 4, *unless* by 100, *unless again* by 400.

```ocaml
let is_leap y =
  (y mod 4 = 0 && y mod 100 <> 0) || y mod 400 = 0

let _ = is_leap 2024
let _ = is_leap 2025
let _ = is_leap 1900
let _ = is_leap 2000
```

- Expected: `true, false, false, true`.
- Parens around `&&` not strictly needed; they make the rule **readable**.

:::

Expected: `true, false, false, true`. The parentheses around the
first `&&` are not strictly needed (`&&` binds tighter than `||`,
so the parse is the same either way), but they make the rule
readable. The expression "either (divisible by 4 and not by 100)
or (divisible by 400)" reads off the code with the parens; without
them you have to mentally insert them. Explicit parens cost
nothing at runtime; spend them.

This is a useful place to notice that `mod` produces an `int`,
which we then compare with `=`. The comparisons are all
`int = int`, so they all type-check; the `&&` and `||` glue them
into one `bool`-typed expression.

## Problem 3: shipping cost label

A two-function problem: a shipping table that computes cost from
a package's weight (kg), and a labeller that categorises the cost
as "cheap", "standard", or "premium". Here is the solution:

```ocaml
let shipping_cost weight =
  if weight < 1.0 then 5.0
  else if weight < 5.0 then 10.0
  else if weight < 20.0 then 25.0
  else 100.0

let shipping_label weight =
  let cost = shipping_cost weight in 
  if cost < 10.0 then "cheap"
  else if cost < 25.0 then "standard"
  else "premium"

let _ = shipping_label 2.5  (* = "standard" *)
```

:::slide

## Problem 3: shipping cost label

- `shipping_cost weight` returns the cost in currency units:
  - under 1 kg → 5
  - under 5 kg → 10
  - under 20 kg → 25
  - else → 100
- `shipping_label weight` categorises that cost as
  "cheap" / "standard" / "premium".

:::

:::slide

## Problem 3: shipping cost label, solution

```ocaml
let shipping_cost weight =
  if weight < 1.0 then 5.0
  else if weight < 5.0 then 10.0
  else if weight < 20.0 then 25.0
  else 100.0

let shipping_label weight =
  let cost = shipping_cost weight in
  if cost < 10.0 then "cheap"
  else if cost < 25.0 then "standard"
  else "premium"

let _ = shipping_label 2.5
```

- Result: `string = "standard"`.
- `let cost = shipping_cost weight in`: compute **once**,
  then branch.

:::

Result for `2.5`: `string = "standard"` (weight `2.5` falls in the
`< 5.0` band, so `cost = 10.0`, which is `< 25.0`, so the label
is "standard"). The pattern `let cost =
shipping_cost weight in if cost < ... else ...` is idiomatic:
when you need to inspect the same value at several thresholds,
name it once and compare repeatedly. Without the `let`, you would
compute `shipping_cost weight` three times in the if-chain (once
for each threshold), which is wasteful and clutters the code.

The function `shipping_label` is built by composing two smaller
functions, `shipping_cost` and an if-chain. This is the rhythm
of functional programming: small, focused functions, combined
into larger behaviours. [Module 6](M06-L05-pipelines.html#function-composition)
will give us tools to make this composition explicit; here it is
just `let` + function call.

## Problem 4: clamp

Constrain a value to a given range. If the value is below the
lower bound, return the lower bound; if above the upper bound,
return the upper bound; otherwise return the value as-is.

```ocaml
let clamp lo hi x =
  if x < lo then lo
  else if x > hi then hi
  else x

let _ = clamp 0 10 7     (* = 7 *)
let _ = clamp 0 10 (-3)  (* = 0 *)
let _ = clamp 0 10 25    (* = 10 *)
```

:::slide

## Problem 4: clamp

Constrain a number to a range:

```ocaml
let clamp lo hi x =
  if x < lo then lo
  else if x > hi then hi
  else x

let _ = clamp 0 10 7
let _ = clamp 0 10 (-3)
let _ = clamp 0 10 25
```

- Results: `7, 0, 10`.
- Type: `int -> int -> int -> int`.
- Argument order: `lo`, `hi`, `x`.

:::

Results: `7`, `0`, `10`. The function's type is `int -> int -> int
-> int`. Note the argument order: `lo`, `hi`, `x`. There is no one
right argument order; this one mirrors the conceptual reading
("clamp into the range lo..hi, the value x"). Another defensible
order is `x lo hi`; both are fine, just be consistent.

The parenthesisation `(-3)` is the
[unary-minus pitfall from the operators lecture](M01-L01-expressions.html#pitfall-3-subtraction-syntax)
(without parens it would parse as subtraction). Worth remembering.

## Problem 5: tying it together

A small utility function for "divide safely":

```ocaml
let safe_divide a b =
  if b = 0.0 then 0.0
  else a /. b

let scaled value scale offset =
  safe_divide (value +. offset) scale

let _ = scaled 100.0 4.0 5.0  (* = 26.25 *)
let _ = scaled 100.0 0.0 5.0  (* = 0. *)
```

:::slide

## Problem 5: tying it together

```ocaml
let safe_divide a b =
  if b = 0.0 then 0.0
  else a /. b

let scaled value scale offset =
  safe_divide (value +. offset) scale

let _ = scaled 100.0 4.0 5.0
let _ = scaled 100.0 0.0 5.0
```

- Results: `26.25` and `0.0`.
- Second call avoids divide-by-zero via the `b = 0.0` guard.
- Sentinel `0.0` is a **design choice**, not always right.
- Alternatives: raise an exception, return a `result`. See Module 4.

:::

Results: `26.25` (which is `(100 + 5) / 4`) and `0.0`. The second
call would have been a divide-by-zero in `a /. b`, but `safe_divide`
intercepts it and returns `0.0` instead.

A short aside: replacing a bad case with a "sentinel" value
(returning `0.0` for divide-by-zero) is a *design decision*, and
not always the right one. The sentinel can hide real bugs: if your
caller didn't notice that you returned `0.0`, they might
incorporate it into a subsequent computation and silently produce
nonsense. The alternatives are:

- **[Raise an exception](M07-L03-exceptions.html)** (we cover
  exceptions in Module 7) so the caller has to handle the case
  explicitly.
- **Return an [`option`](M04-L04-recursive-types.html#the-option-type)
  or [`result`](M04-L04-recursive-types.html#the-result-type)
  type** (Module 4) that encodes "this might be a valid number, or
  it might be 'no answer'". Forces the caller to check.

For a tutorial example, the sentinel is fine. In production code,
either of the two alternatives is usually better. Mention this
to set up Modules 4 and 7.

## Reading type errors

Type errors are noisy at first. The cure is *repetition*: write
some code, read the message, fix, repeat. One error worth a
fresh slide here; two more were covered earlier in the module.

:::slide

## Reading a type error: int / float confusion

```ocaml skip
let bad r = 3.14 * r * r
```

```
Error: The constant 3.14 has type float
       but an expression was expected of type int
```

- Compiler points at `3.14`: type `float`, expected `int`.
- "Expected" is **driven by the operator**: `*` is integer mul.
- Fix: switch to `*.`.

:::

The int/float operator mix-up: you wrote `*` when you meant `*.`.
The compiler points at the `float` literal as the offender, says
it expected an `int` (because `*` is integer multiplication), and
tells you the actual type is `float`. The fix: change the
operator to `*.`.

The trick to reading the error: *the operator drives the expected
type*. If you see "expected int", look for an `int` operator
nearby; that's where the constraint came from.

Two more error shapes you have already seen elsewhere in the
module are worth re-skimming when you hit them:

- [The operators lecture, Pitfall 2](M01-L01-expressions.html#pitfall-2-implicit-conversion-that-isnt-there):
  `"value: " ^ 5` fails because OCaml does not silently coerce
  `int` to `string`. Convert with `string_of_int` or use
  `Printf.sprintf`.
- [The `if` lecture, mismatched branches](M01-L01-expressions.html#why-the-branches-must-agree):
  `if ... then "positive" else 0` fails because the two branches
  must share a type. Decide which type you want and rewrite the
  other branch.

Together these three shapes (operator mismatch, missing
conversion, mismatched branches) account for the bulk of first-week
type errors. After enough repetition the muscle memory takes over.

## Activity

:::slide

## Activity

Re-implement [`sign` from the `if` lecture](#nested-ifs), then write
the float twin:

- `sign : int -> int` returning `-1`, `0`, `1`.
- `sign_f : float -> float` returning `-1.0`, `0.0`, `1.0`.

Compare what changed between the two.

:::

Try this one yourself before reading on.

:::quiz code id=M02-L06-q2
Write `sign : int -> int` that returns `-1` for negative inputs,
`0` for zero, and `1` for positive inputs.

```ocaml
let sign x =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (sign 5    =  1) "sign 5";
  check (sign (-3) = -1) "sign -3";
  check (sign 0    =  0) "sign 0";
  check (sign 100  =  1) "sign 100";
  print_endline "all tests passed"
```
:::

:::quiz code id=M02-L06-q1
Now write the float version: `sign_f : float -> float`
returning `-1.0`, `0.0`, `1.0`.

```ocaml
let sign_f x =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (sign_f 5.0    =  1.0) "sign_f 5.0";
  check (sign_f (-3.7) = -1.0) "sign_f -3.7";
  check (sign_f 0.0    =  0.0) "sign_f 0.0";
  print_endline "all tests passed"
```
:::

:::solution

:::slide

## Activity solution

```ocaml
let sign x =
  if x < 0 then -1
  else if x > 0 then 1
  else 0
```

```ocaml
let sign_f x =
  if x < 0.0 then -1.0
  else if x > 0.0 then 1.0
  else 0.0
```

What changed:

- Literals: `0` to `0.0`; `-1, 0, 1` to `-1.0, 0.0, 1.0`.
- Type: `int -> int` to `float -> float`.

**Structure is identical.** OCaml made you spell out the type choice.

:::

:::

Compare the two versions. The *logic* (negative? zero? positive?)
is identical. What changed is the *literals*: `0` becomes `0.0`,
`-1` becomes `-1.0`, etc. OCaml made you write out the type choice;
the algorithm itself didn't change. This is the cost of the no-implicit-conversion
rule. The benefit is that anyone reading either function knows
unambiguously what types are involved.

A small philosophical aside, since the *think about this* prompt
invites it. Could you replace the three-way `if` in `sign` with
arithmetic? Almost; one `if` survives, to guard the zero case:

```ocaml
let sign_arith x =
  if x = 0 then 0 else x / abs x

let _ = sign_arith 5     (* = 1 *)
let _ = sign_arith (-3)  (* = -1 *)
let _ = sign_arith 0     (* = 0 *)
```

This works: `x / abs x` is `1` for positive and `-1` for negative,
and we handle the `0` case separately to avoid division by zero.
It is more compact than the three-branch `if`, but arguably
less clear: a reader has to think to convince themselves that
the formula gives the right answer. The three-branch version
*reads* like the specification.

This is a general theme: *cleverness* and *clarity* are different
virtues, and clarity usually wins. We will see this again with
recursion versus [higher-order functions](M06-L01-functions-revisited.html)
(Module 6).

## What you should be able to do now

By the end of Module 2 you should be comfortable doing the
following without checking references:

:::slide

## What you should be able to do now

After Module 2 you can:

- Write `int`, `float`, `bool`, `string` literals.
- Use `let` and `let ... in`.
- Read the type the toplevel reports.
- Recognise the common type errors.
- Write multi-branch `if` expressions.
- Compose small functions like `shipping_cost`, `clamp`, `sign`.

**Next, Module 3:** functions as values, currying, recursion.

:::

If any of these still feel shaky, the right move is to go back to
the relevant lecture (above) and re-attempt the quizzes.
[Module 3](M03-L01-functions-as-values.html) will assume Module 2
is solid: we will start treating functions as values you can pass
around, store, and return from other functions. That's where OCaml
starts to feel like a different language from C or
Python, and you'll want the expression-level mechanics from Module
2 to be automatic.

---
-->

## References for further reading

- **Real World OCaml**, *A Guided Tour*: numbers, let bindings, and
  type-inference sections:
  <https://dev.realworldocaml.org/guided-tour.html>
- **Cornell CS3110**, *Basics chapter*: types and values, let
  expressions, type checking, and conditional expressions, all in
  one chapter:
  <https://cs3110.github.io/textbook/chapters/basics/expressions.html>
- **Cornell CS3110**, *Basics chapter (index)*: a denser version of
  the same material if anything felt thin:
  <https://cs3110.github.io/textbook/chapters/basics/index.html>
- **OCaml manual**, *Expressions* (operator section): the
  authoritative precedence table:
  <https://v2.ocaml.org/manual/expr.html>

## Sources

This lesson has been adapted from the [NPTEL OCaml course](https://fplaunchpad.org/ocaml_nptel/) currently being offered by Prof. K.C. Sivaramakrishnan. 

Materials referenced during preparation are listed in
the *Reading* section above; Cornell CS3110 and Real World OCaml
are CC BY-NC-ND-licensed and have not been derivatively reused.
See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
