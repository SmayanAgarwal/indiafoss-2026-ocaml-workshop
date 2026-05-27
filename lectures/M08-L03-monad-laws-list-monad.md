---
title: "Monad laws and the list monad"
lecture_no: 3
week: 8
duration_target_min: 21
concepts: [monad laws, left identity, right identity, associativity, list monad, non-determinism]
keywords: [OCaml, monad laws, list monad, concat_map, Cartesian product, let*]
activity_question: "Use the option monad to chain three steps that each parse one piece of a temperature reading: a sign character, a magnitude string, and a unit suffix. Return the temperature in Kelvin, or [None] if any step fails."
think_about_this: "The list monad's [bind] is [List.concat_map]. If the option monad models 'maybe one value', what does the list monad model?"
reading:
  - title: "Cornell CS3110, Monads and laws"
    url: https://cs3110.github.io/textbook/chapters/ds/monads.html
---

# Monad laws and the list monad


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Monad laws and the list monad</h2>
<p class="title-slide-label">Module 8 &middot; Lecture 3</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

We have built the option monad in
[Lecture 2](M08-L02-option-monad.html) and met `return` and `bind`.
We claimed a monad is "any type plus `return` and `bind`". That is
not quite the whole story: a *lawful* monad is one whose `return`
and `bind` also satisfy three equations called the *monad laws*.
This lecture states the three laws, checks them on `option`, then
introduces a completely different-looking monad (the *list monad*)
to show how the same shape captures non-determinism. We close with
a small temperature-conversion pipeline that revisits the
[M01-L05](M01-L05-tutorial-recap.html) Celsius/Kelvin/Fahrenheit
thread under `let*`.

:::slide

## This lecture

- Three monad laws (left-id, right-id, associativity).
- Verify them on `option` and sketch them for `result`.
- The **list monad**: `bind = List.concat_map`.
- Non-determinism intuition: many values per step.
- Temperature pipeline (`celsius -> kelvin -> fahrenheit`) under `let*`.
- Validator activity chaining several optional steps.

:::

## Why laws at all?

When we say "monad" we mean a type plus two operations *that
behave well*. The three laws state what "well" means. They are
the contract that lets a reader trust monadic code without
reasoning about each `let*` from scratch.

:::slide

## Why laws at all?

- A monad is a type plus `return` and `bind`.
- The **laws** are the "good behaviour" contract:
  - `return` is a do-nothing wrapper.
  - `bind` is sequencing with no hidden surprises.
- The laws let you refactor monadic code with confidence.
- Every monad we use in this course satisfies them.
- If a "monad" violates a law, it is a leaky abstraction.

:::

We will not enforce the laws in OCaml's type system (we cannot;
they are equalities, not types). We check them on paper for each
monad. The point is to recognise them, not to prove them every
time.

## Law 1: left identity

The first law says: wrapping a value with `return` and then binding
it into a function is the same as just calling the function on the
value.

:::slide

## Left identity

```text
bind (return x) f  ===  f x
```

For the option monad:

```ocaml
let return x = Some x
let bind opt f = match opt with
  | Some y -> f y
  | None -> None

let _ = bind (return 5) (fun x -> Some (x + 1))
  (* = bind (Some 5) (fun x -> Some (x + 1)) *)
  (* = (fun x -> Some (x + 1)) 5 *)
  (* = Some 6 *)
```

- `return 5` is `Some 5`.
- `bind (Some 5) f` matches the `Some` case and calls `f 5`.
- Result: `f 5`, which is what the law says.

:::

The reading is: "lifting a value into the monad and immediately
binding it is the same as calling the function directly". In other
words, `return` is a no-op when bound. If `return` did anything
besides wrap (logged, allocated, fired a side effect), this law
would fail.

## Law 2: right identity

The second law goes the other way: binding a monadic value into
`return` is the same as the monadic value itself.

:::slide

## Right identity

```text
bind m return  ===  m
```

For the option monad:

```ocaml
let _ = bind (Some 5) return
  (* = match Some 5 with Some y -> return y | None -> None *)
  (* = return 5 *)
  (* = Some 5 *)

let _ = bind None return
  (* = match None with Some y -> return y | None -> None *)
  (* = None *)
```

- `bind (Some 5) return` unwraps and re-wraps; same value.
- `bind None return` short-circuits; same value.
- Both cases: the binding to `return` is invisible.

:::

This says binding into `return` is also a no-op. Together with
left identity, the two laws fence `return` in: it cannot do
anything except wrap.

## Law 3: associativity

The third law is the most interesting. It says nested `bind`s can
be reassociated like a chain of `let`s.

:::slide

## Associativity

```text
bind (bind m f) g  ===  bind m (fun x -> bind (f x) g)
```

Read in `let*` form:

```text
let* y = (let* x = m in f x) in g y
   ===
let* x = m in let* y = f x in g y
```

- A nested `let*` and a flat `let*` chain compute the same thing.
- This is why we can write `let* a in let* b in let* c in ...`
  without worrying about which pair to parenthesise.

:::

This is the law that makes monadic code look like a flat sequence.
Without associativity you would have to be careful about how `bind`s
group. With it, the chain reads top to bottom and the parser-style
nested forms compute the same answer as the flat forms.

## Verifying associativity on option

A one-line check that this works for option:

:::slide

## Option satisfies associativity

```ocaml
let m = Some 5
let f x = if x > 0 then Some (x * 2) else None
let g y = Some (y + 1)

let _ = bind (bind m f) g
let _ = bind m (fun x -> bind (f x) g)
```

Both evaluate to `Some 11`:

- `bind (Some 5) f` is `f 5` is `Some 10`.
- `bind (Some 10) g` is `g 10` is `Some 11`.

The alternative grouping also gives `Some 11`. The two forms agree
on every input where the same intermediate values flow through.

:::

The two right-hand sides are literally different OCaml expressions,
but they compute to the same value. That is the law working.

## Why the laws matter (in one example)

Here is a piece of code that uses the associativity law without
naming it. Suppose you write a long `let*` chain:

```text
let chain s =
  let* a = step1 s in
  let* b = step2 a in
  let* c = step3 b in
  step4 c
```

You can refactor part of it into a helper:

```text
let helper a =
  let* b = step2 a in
  let* c = step3 b in
  step4 c

let chain s =
  let* a = step1 s in
  helper a
```

The two are equivalent. *Associativity is what guarantees that.*
If `bind` were not associative, refactoring a sub-chain would
change the result. With the law, you can carve up `let*` chains
freely.

## Result obeys the same laws

The result monad satisfies the three laws by the same one-line
arguments, with `Ok` replacing `Some` and `Error` replacing `None`.

:::slide

## Result satisfies the same laws

```ocaml
let return x = Ok x
let bind r f = match r with
  | Ok y -> f y
  | Error e -> Error e

let _ = bind (return 5) (fun x -> Ok (x + 1))
  (* = Ok 6, matches f 5 *)

let _ = bind (Ok 5) return
  (* = Ok 5 *)

let _ = bind (Error "boom") return
  (* = Error "boom" *)
```

- Left identity, right identity, associativity: all hold.
- The structural argument is the same; only the case names change.

:::

This is the pattern: when you define a new monad, you write down
`return` and `bind`, and you sketch the three checks on paper. If
they hold, the monad behaves predictably and `let*` chains are
safe to refactor.

## A different shape: the list monad

So far our monads have been about *one* value or none. The list
monad is about *many* values. `'a list` has the right shape:
`return x` is `[x]` (a single-element list), and `bind` is
"for every value in the input list, run the continuation, and
flatten":

:::slide

## The list monad: definition

```ocaml
let return x = [x]
let bind xs f = List.concat_map f xs
let ( let* ) = bind

let _ = bind [1; 2; 3] (fun x -> [x; x * 10])
let _ = return 7
```

`[1; 10; 2; 20; 3; 30]`, `[7]`.

- `bind [1;2;3] f` runs `f` on each element and concatenates the
  results.
- `List.concat_map` is exactly that: stdlib function from
  `'a list -> ('a -> 'b list) -> 'b list`.
- `return x = [x]`: one value, lifted to a one-element list.

:::

Read `bind` again: it takes a list and a function from each
element to a list. It maps the function across the input and
flattens, producing a new list. That is `concat_map` (also known
as `flat_map` in many other languages).

## What does the list monad mean?

The list monad models *non-determinism*: a computation that may
produce multiple values, and the next step runs on every one of
them. `let*` becomes "for every value in the previous step's
output, do the next step".

:::slide

## Non-determinism: a Cartesian-product example

```ocaml
let ( let* ) xs f = List.concat_map f xs

let pairs =
  let* x = [1; 2; 3] in
  let* y = ["a"; "b"] in
  [(x, y)]

let _ = pairs
```

`[(1, "a"); (1, "b"); (2, "a"); (2, "b"); (3, "a"); (3, "b")]`.

- Six pairs: every `x` paired with every `y`.
- `let*` over lists is the Cartesian product written like a
  sequence of binds.
- Each `let*` adds one dimension to the search.

:::

This is striking the first time you see it. The same `let*`
notation that meant "short-circuit on failure" for `option` now
means "consider every combination" for lists. The notation has not
changed; the monad has.

## Search problems are list-monad problems

Whenever you need to "try every possibility and collect what
worked", the list monad gives you a clean way to write it. A
small example: find all pairs `(x, y)` with `1 <= x <= 3` and
`x < y <= 4`.

:::slide

## All ordered pairs

```ocaml
let ( let* ) xs f = List.concat_map f xs

let ordered_pairs =
  let* x = [1; 2; 3] in
  let* y = [1; 2; 3; 4] in
  if x < y then [(x, y)] else []

let _ = ordered_pairs
```

`[(1, 2); (1, 3); (1, 4); (2, 3); (2, 4); (3, 4)]`.

- `if ... then [...] else []` is the list-monad's `guard`.
- Empty list at a step = "discard this branch".
- Singleton list at a step = "keep this branch with one value".

:::

The trick on the last line is that `[]` and `[(x, y)]` are both
valid list-monad values. Returning `[]` from one branch of the
chain drops that branch (because `concat_map` of `[]` contributes
nothing to the final list). Returning a singleton keeps it. This
"filter via empty list" is how you write search problems in the
list monad.

## Verifying the laws for the list monad

The list monad obeys the three laws too. A quick sketch:

:::slide

## List monad satisfies the laws

```ocaml
let return x = [x]
let bind xs f = List.concat_map f xs

let _ = bind (return 5) (fun x -> [x; x * 10])
  (* = bind [5] (fun x -> [x; x * 10]) *)
  (* = List.concat_map ... [5] *)
  (* = [5; 50] *)
  (* = (fun x -> [x; x*10]) 5  ✓ left identity *)

let _ = bind [1; 2; 3] return
  (* = List.concat_map (fun x -> [x]) [1;2;3] *)
  (* = [1; 2; 3]  ✓ right identity *)
```

Associativity follows from `List.concat_map`'s flattening: nested
or flat, you concatenate the same sublists in the same order.

:::

This works for the three laws because `List.concat_map`'s
flattening is itself associative: `concat (concat ...)` and the
flat form land on the same list.

## Back to temperatures (option monad as a sanity check)

A practical example to anchor `let*`. Recall from
[M01-L05](M01-L05-tutorial-recap.html) the Celsius / Kelvin /
Fahrenheit conversions. Suppose now each step can fail (the input
might be a bad string; Kelvin must be non-negative; rounded
Fahrenheit might overflow our small `int` budget). The option
monad chains them:

:::slide

## Temperature pipeline with `let*`

```ocaml
let ( let* ) = Option.bind

let parse_celsius s = float_of_string_opt s

let celsius_to_kelvin c =
  let k = c +. 273.15 in
  if k < 0.0 then None else Some k

let kelvin_to_fahrenheit k = Some ((k -. 273.15) *. 1.8 +. 32.0)

let pipeline s =
  let* c = parse_celsius s in
  let* k = celsius_to_kelvin c in
  let* f = kelvin_to_fahrenheit k in
  Some (Printf.sprintf "%.1f F" f)
```

- Three steps, three `let*`s.
- Any step returning `None` short-circuits the rest.

:::

:::slide

## Trying the temperature pipeline

```ocaml
let _ = pipeline "100"
let _ = pipeline "frog"
let _ = pipeline "-300"
```

`Some "212.0 F"`, `None`, `None`.

- `"100"` parses, converts cleanly: 100 C is 373.15 K is 212 F.
- `"frog"` fails at the parse step.
- `"-300"` parses but makes Kelvin negative; `celsius_to_kelvin`
  rejects it.

:::

This is the option monad doing its job: a pipeline that *might*
fail at any step, written as if every step succeeded, with the
plumbing left to `let*`. The
[M01-L05](M01-L05-tutorial-recap.html) version of the same
calculation chained the operations with `|>`, but that version
had no story for failure; this one does.

## A quick check

:::quiz mcq id=M08-L03-q3
Which law guarantees that you can refactor part of a `let*` chain
into a helper function without changing the result?

- [ ] Left identity.
- [ ] Right identity.
- [x] Associativity.
- [ ] None of them; refactoring monadic code is risky.

**Why:** associativity says nested `bind`s can be reassociated.
Extracting a sub-chain into a helper is exactly reassociating
those `bind`s. Left and right identity govern `return`, not the
shape of long chains. Refactoring is safe precisely because
associativity holds.
:::

:::quiz mcq id=M08-L03-q2
In the list monad, what does

```text
let* x = [1; 2] in
let* y = [10; 20] in
[x + y]
```

evaluate to?

- [ ] `[11; 22]`.
- [ ] `[11; 21]`.
- [x] `[11; 21; 12; 22]`.
- [ ] `[1; 2; 10; 20]`.

**Why:** the list monad runs the continuation once per element of
the previous step, then concatenates. For `x = 1` we get
`[11; 21]`; for `x = 2` we get `[12; 22]`. Concatenated:
`[11; 21; 12; 22]`. This is the Cartesian product wired up by
`concat_map`.
:::

## Activity

:::slide

## Activity

Build a validator with the option monad. Parse a temperature
reading string of the form `"+25C"` or `"-100K"` into Kelvin.
Three steps:

- The first character is a sign: `+` or `-`.
- The middle part is a magnitude: an integer.
- The last character is a unit: `C` (Celsius) or `K` (Kelvin).

Return the temperature in Kelvin as a `float option`. Any
malformed step gives `None`.

:::

:::solution

:::slide

## Activity solution: setup

```ocaml
let ( let* ) = Option.bind

let parse_sign c =
  if c = '+' then Some 1.0
  else if c = '-' then Some (-1.0)
  else None

let parse_magnitude s = float_of_string_opt s

let parse_unit c =
  match c with
  | 'C' -> Some `Celsius
  | 'K' -> Some `Kelvin
  | _ -> None
```

Three little parsers, one per piece. Each returns `Some _` on a
valid piece and `None` otherwise.

:::

:::

:::solution

:::slide

## Activity solution: the validator

```ocaml
let parse_temp s =
  let n = String.length s in
  if n < 3 then None
  else
    let* sign = parse_sign s.[0] in
    let* mag = parse_magnitude (String.sub s 1 (n - 2)) in
    let* unit_ = parse_unit s.[n - 1] in
    let value = sign *. mag in
    Some (match unit_ with
      | `Kelvin -> value
      | `Celsius -> value +. 273.15)

let _ = parse_temp "+25C"
let _ = parse_temp "-100K"
let _ = parse_temp "+25Z"
let _ = parse_temp "frog"
```

`Some 298.15`, `None` (Kelvin cannot be negative semantically, but
we accept it here as a parse), `None` (bad unit), `None`
(bad shape).

- Wait, `"-100K"` returns `Some (-100.)` in our code (we did not
  reject sub-zero Kelvin). Sharpen the spec to taste.

:::

:::

:::solution

:::slide

## Activity solution in action

```ocaml
let _ = parse_temp "+0C"    (* = Some 273.15 *)
let _ = parse_temp "-273K"  (* = Some (-273.) *)
let _ = parse_temp ""       (* = None (too short) *)
```

Three `let*`s, three failure modes covered, no nested matches.

- This is the option monad working: explicit failure, linear code,
  the wiring stays out of sight.

:::

:::

A code quiz to consolidate:

:::quiz code id=M08-L03-q1
Use the list monad to write `divisors_of_each : int list -> int
list` that returns every pair of integers whose product is in the
input list. (For input `[6]`, valid pairs include `(1, 6)`,
`(2, 3)`, `(3, 2)`, `(6, 1)`. Return them as `a * b` to confirm.)

```ocaml
let ( let* ) xs f = List.concat_map f xs

let divisors_of_each xs =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  let r = divisors_of_each [6] in
  check (List.length r >= 4) "at least four factor pairs of 6";
  check (List.for_all (fun n -> n = 6) r) "every entry should equal 6";
  print_endline "all tests passed"
```
:::

:::solution

Reference solution:

```
let ( let* ) xs f = List.concat_map f xs

let divisors_of_each xs =
  let* n = xs in
  let* a = List.init n (fun i -> i + 1) in
  let* b = List.init n (fun i -> i + 1) in
  if a * b = n then [a * b] else []
```

Three `let*`s, one per dimension of the search: pick an `n` from
the input, pick `a` and `b` from `1..n`, keep only the pairs
whose product equals `n`. The list monad makes the nested search
read like ordinary sequential code.

:::

## What is next

:::slide

## What is next

Lecture 4: the **result monad** in detail.

- Same `bind`, same `let*`, richer failure type.
- Worked example: a parser with informative error messages.

:::

The [next lecture](M08-L04-result-monad.html) takes the same
shape and changes the failure side: instead of `None`, we report
`Error reason`. The laws still hold; the intuition still holds;
only the failure type changes.

## Reading

- **Cornell CS3110**, *Monads*:
  <https://cs3110.github.io/textbook/chapters/ds/monads.html>

## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. The list-monad framing and the monad-laws layout draw
on the CS3100 monads notebook
(`_references/cs3100_m20/lectures/lec15_monads/`), used here as a
private structural reference; the surface code, comments, and
explanations are written from scratch. Cornell CS3110 and Real
World OCaml are CC BY-NC-ND-licensed and have not been
derivatively reused. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
