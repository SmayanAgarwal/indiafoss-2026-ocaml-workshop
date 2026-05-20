---
title: "Guards: when-clauses on patterns"
lecture_no: 3
week: 5
duration_target_min: 20
concepts: [when-guards, conditional pattern matching, exhaustiveness with guards]
keywords: [OCaml, pattern matching, when, guard, conditional pattern]
activity_question: "Write [sign : int -> string] returning \"negative\", \"zero\", or \"positive\". Use a single match with when-clauses (no if/else)."
think_about_this: "Guards turn pattern matching into pattern+predicate matching. What does the compiler's exhaustiveness checker conservatively assume about a clause guarded by [when]? Why must it?"
reading:
  - title: "Cornell CS3110, Pattern matching guards"
    url: https://cs3110.github.io/textbook/chapters/data/pattern_matching.html
---

# Guards: when-clauses on patterns

A pattern by itself matches on *shape*: this constructor, that
literal, a wildcard. Sometimes you want to filter further on a
*computation*: not just "the head of the list is some integer",
but "the head of the list is a *positive* integer." Pure
patterns cannot express this. They cannot compare two bound
names. They cannot ask "is this string longer than 5
characters?" The pattern language is deliberately restricted
because the restriction is what lets the compiler check
exhaustiveness and compile the dispatch efficiently.

The escape hatch is the **guard**: a `when`-clause attached to a
pattern. A guard is a boolean expression evaluated after the
pattern matches. If the pattern matches *and* the guard is true,
the clause fires. If either fails, the matcher moves on to the
next clause.

Guards extend what you can express in a `match`, but they come at
a cost: they suppress exhaustiveness checking for the guarded
clause. We will see why and what to do about it in this lecture,
and revisit the trade-off in [Lecture 4](M05-L04-exhaustiveness.html#exhaustiveness-and-guards-one-more-reminder).

## A first example

```ocaml
let sign = function
  | n when n > 0 -> "positive"
  | n when n < 0 -> "negative"
  | _ -> "zero"

let _ = sign 5
let _ = sign (-3)
let _ = sign 0
```

:::slide

## A guard adds a predicate to a clause

```ocaml
let sign = function
  | n when n > 0 -> "positive"
  | n when n < 0 -> "negative"
  | _ -> "zero"
```

`"positive"`, `"negative"`, `"zero"`.

- Each clause has a pattern (`n` or `_`) and **optionally** a guard.
- Pattern matches **and** guard is `true`: clause fires.
- Otherwise: skip to the next clause.

:::

Read the first clause: "match the value against `n` (which
matches anything and binds it to `n`), *and* check that `n > 0`."
If both hold, return `"positive"`. If the pattern matched but the
guard was false, this clause does not fire and the matcher
proceeds to the next clause.

Three things to notice. First, the same name `n` is bound in
each of the first two clauses. Each binding is local to its
clause: the `n` in clause 1 is unrelated to the `n` in clause 2.
Second, the order matters: positive is checked before negative,
and the wildcard catches everything else (i.e., zero). Third,
the guard is an arbitrary OCaml expression of type `bool`, not a
new mini-language. You can call functions, do arithmetic,
compare strings, anything that returns a `bool`.

Without guards, you would write `sign` with nested `if`:

```ocaml
let sign n =
  if n > 0 then "positive"
  else if n < 0 then "negative"
  else "zero"
```

The two versions compute the same thing. The guarded `match`
version is preferred when:

- You are already pattern matching for other reasons (the
  function dispatches on a variant, say, and you also need a
  numerical predicate).
- You want the cases lined up vertically, with pattern and
  predicate side by side.

If the entire body is just a chain of threshold comparisons (as
in `sign`), nested `if`s are fine. Reach for guards when the
pattern part is doing real work too.

## Guards on more interesting patterns

The pattern can do *most* of the work, with the guard filtering
the rest:

```ocaml
let report = function
  | (x, y) when x = y    -> "diagonal"
  | (x, _) when x = 0    -> "on the y-axis"
  | (_, y) when y = 0    -> "on the x-axis"
  | _                    -> "elsewhere"

let _ = report (1, 1)
let _ = report (0, 5)
let _ = report (3, 0)
let _ = report (2, 4)
```

:::slide

## Guards on structured patterns

```ocaml
let report = function
  | (x, y) when x = y -> "diagonal"
  | (x, _) when x = 0 -> "on the y-axis"
  | (_, y) when y = 0 -> "on the x-axis"
  | _                 -> "elsewhere"
```

`"diagonal"`, `"on the y-axis"`, `"on the x-axis"`, `"elsewhere"`.

- Pattern destructures the pair; guard filters further.
- First clause: needs both names because we compare them.
- Pure patterns cannot express `x = y`.

:::

The first clause has a guard `x = y` that compares the two
components of the pair. *This is the kind of test pure patterns
cannot express.* A pattern can say "the first component is the
literal `0`", but it cannot say "the first component equals the
second", because the pattern language has no way to refer to
another binding from itself. The guard solves this with a clean
escape hatch: bind both pieces with the pattern, then compare
them in the guard.

Notice the second clause does *not* compare the first component
to the second; it compares the first component to the literal
`0`. We could equivalently write `| (0, _) -> "on the y-axis"`
with a pure literal pattern. The guarded version generalises:
swap `x = 0` for `x < 0` or `x mod 2 = 0` and you have a
predicate-on-a-bound-value that pure patterns can not write.

## Guards see what the pattern bound

A guard can use any name that the pattern in the *same clause*
introduces. It cannot peek at bindings from other clauses, and
it cannot use names that have not been bound yet.

```ocaml
let starts_negative = function
  | [] -> false
  | x :: _ when x < 0 -> true
  | _ -> false

let _ = starts_negative [-3; 5; 7]
let _ = starts_negative [1; 2; 3]
let _ = starts_negative []
```

:::slide

## Guards reference what the pattern bound

```ocaml
let starts_negative = function
  | [] -> false
  | x :: _ when x < 0 -> true
  | _ -> false
```

`true`, `false`, `false`.

- Guard `when x < 0` uses `x`, bound by the pattern `x :: _`.
- Guards see names from the **same clause's** pattern only.

:::

In the second clause, the pattern `x :: _` binds `x` to the head
of the list. The guard `x < 0` references that binding. If the
list is empty, the pattern fails and we never get to the guard.
If the list is non-empty but the head is non-negative, the
pattern matches but the guard fails, and the matcher moves on.

If the matcher reaches the third clause (wildcard), then either
the input was empty (caught by clause 1) or it was non-empty
with a non-negative head (clause 2 pattern matched, guard
failed). Either way, we return `false`. Clause 1 returns
`false` for empty too, so the final wildcard is only ever
reached when the head was non-negative.

A subtle point: when a guard fails, the matcher continues to the
next clause; it does *not* re-attempt the same pattern with
different bindings. So `x :: _ when x < 0` either fires (if both
match) or moves on; there is no backtracking.

## Exhaustiveness with guards is conservative

Here is the rub. Look at this version of `sign`:

```ocaml skip
let classify n =
  match n with
  | n when n > 0 -> "positive"
  | n when n < 0 -> "negative"
```

We have two clauses, and between them they cover positive and
negative numbers. They also leave zero uncovered. The compiler
warns:

```
Warning 8 [partial-match]: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched: 0
```

:::slide

## Exhaustiveness with guards is conservative

```ocaml skip
let classify n =
  match n with
  | n when n > 0 -> "positive"
  | n when n < 0 -> "negative"
```

```
Warning 8: this pattern-matching is not exhaustive.
Here is an example of a case that is not matched: 0
```

- Compiler treats every guard as if it can fail.
- Cannot prove arithmetic facts like "`n > 0` or `n < 0` or `n = 0` is total".
- Always add an unguarded clause (or wildcard) to close the match.

:::

The warning is correct: there is an integer (zero) that neither
clause handles. The fix is to add an explicit zero case (or a
wildcard) as we did earlier:

```ocaml
let classify = function
  | n when n > 0 -> "positive"
  | n when n < 0 -> "negative"
  | _ -> "zero"
```

But notice something deeper. The compiler's check is
*conservative*: even if you wrote

```ocaml skip
let classify n =
  match n with
  | n when n > 0 -> "positive"
  | n when n <= 0 -> "non-positive"
```

the compiler would still warn. The two guards together logically
cover every integer; the compiler does not know that. Its
exhaustiveness checker reasons about *patterns*, not about
arbitrary boolean expressions. A guard might do anything: call a
function, read from a file, depend on state. The compiler
treats every guard as "can fail," because it has to. The only
way to prove the match is total is to have at least one *unguarded*
clause that covers the remaining shapes.

This is the price of allowing arbitrary computation in guards.
The compiler proves what it can prove (which constructors and
shapes are covered); the rest is up to you.

So the rule for guards is: **add an unguarded catch-all to close
the match**, unless you are certain the guarded clauses are
total (and you do not mind the warning).

## Don't reach for guards when a pattern would do

Guards are powerful, but they are not free. Each guard suppresses
some compiler help. So a useful discipline: do not reach for a
guard when a pure pattern would express the same thing.

```ocaml
let is_origin = function
  | (x, y) when x = 0.0 && y = 0.0 -> true
  | _ -> false
```

This works, but it is unnecessarily heavy. The pattern can do
the comparison directly:

```ocaml
let is_origin = function
  | (0.0, 0.0) -> true
  | _ -> false
```

:::slide

## Prefer patterns when they suffice

```ocaml
(* heavy *)
let is_origin = function
  | (x, y) when x = 0.0 && y = 0.0 -> true
  | _ -> false

(* clean *)
let is_origin = function
  | (0.0, 0.0) -> true
  | _ -> false
```

- Same behaviour; no guard needed.
- Pure pattern preserves exhaustiveness checking.
- Use `when` only when a pure pattern cannot express the predicate.

:::

The pure-pattern version is shorter, more obviously correct, and
keeps exhaustiveness checking intact. Reach for `when` only when
the pattern language is genuinely not enough:

- Numeric inequalities: `n > 0`, `n <= max_size`.
- String predicates: `String.length s > 5`,
  `String.starts_with ~prefix:"foo" s`.
- Relationships between two bound names: `x = y`, `a < b`.
- Calls to external predicates: `is_valid_id name`.

These are things the pattern language cannot encode. For
anything else, prefer the pattern.

## Guards and side effects

A guard is just an expression, and an expression can have side
effects. Resist the urge.

```ocaml skip
let f = function
  | _ when (Printf.printf "checking\n"; true) -> "matched"
  | _ -> "no match"
```

Technically valid. Practically: if the guard prints, the print
happens *every time the guard is evaluated*, which depends on
how the compiler orders the clauses. Worse, the same value may
be re-matched against multiple clauses in some patterns, and
the guard fires once per attempt. Debugging this is a small
nightmare.

The discipline: guards should be *pure*, i.e., return a `bool`
without observable side effects. If you need a side effect,
sequence it before the `match` or inside the right-hand side.

## Compound guards and short-circuiting

A guard is just `bool`, so you can combine multiple conditions
with `&&` and `||`:

```ocaml
let in_range n = function
  | (low, high) when low <= n && n <= high -> true
  | _ -> false
```

The Boolean operators short-circuit, so this is well-behaved:
`low <= n` is evaluated first, and `n <= high` only if the first
was true. Standard rules apply.

For complex guards, you can also call a named predicate:

```ocaml
let valid_pair = function
  | (a, b) when a < b -> true
  | _ -> false
```

If the predicate gets large, lift it to a named function and
call it from the guard. Keeps the `match` readable.

## Two checks

:::quiz mcq id=M05-L03-q3
What does this evaluate to?

```ocaml
let classify = function
  | n when n > 0 -> "positive"
  | _ -> "non-positive"

let result = classify 0
```

- [ ] `"positive"`
- [x] `"non-positive"`
- [ ] Compile error
- [ ] `Match_failure`

**Why:** the first clause's guard `n > 0` is false when `n = 0`, so
the clause does not fire. The wildcard catches everything else
and returns `"non-positive"`.
:::

:::quiz mcq id=M05-L03-q2
Why does the compiler warn about this match as non-exhaustive?

```ocaml skip
let classify = function
  | n when n >= 0 -> "non-negative"
  | n when n < 0 -> "negative"
```

- [ ] The patterns `n` and `n` clash.
- [ ] The wildcard is missing.
- [x] The compiler does not reason about arbitrary boolean guards; it cannot prove the two guards together are total.
- [ ] Order is wrong.

**Why:** every guarded clause is treated as "may fail" by the
exhaustiveness checker. Even though `n >= 0` and `n < 0` cover
all integers between them, the compiler will not check arithmetic
facts. The fix is an unguarded `| _ -> ...` to close the match.
:::

A code task:

:::quiz code id=M05-L03-q1
Write `sign : int -> string` returning `"negative"`, `"zero"`, or
`"positive"`. Use a single `function` with `when`-guards; no
`if`/`else`. Make sure the match is exhaustive (no warning 8).

```ocaml
let sign n =
  failwith "not implemented"
```

```ocaml skip
let check b m = if not b then failwith m
let () =
  check (sign 5 = "positive") "positive";
  check (sign (-3) = "negative") "negative";
  check (sign 0 = "zero") "zero";
  check (sign max_int = "positive") "max_int";
  check (sign min_int = "negative") "min_int";
  print_endline "all tests passed"
```
:::

The shape: two guarded clauses followed by a wildcard for zero.

## Common pitfalls

**Pitfall 1: omitting the catch-all after guards.** The compiler
warns; do not silence the warning, add a wildcard or unguarded
clause. Otherwise, an input that no guard covers raises
`Match_failure` at runtime.

**Pitfall 2: using a guard where a pattern would do.** Pure
patterns preserve exhaustiveness; guards do not. Save guards for
predicates the pattern language cannot express.

**Pitfall 3: side effects in guards.** A guard may be evaluated
zero, one, or more times depending on the matcher. Keep guards
pure: return a `bool`, do nothing else.

**Pitfall 4: assuming the matcher backtracks.** It does not. If
a pattern matches but its guard fails, the matcher moves to the
next clause; it does not retry the same pattern with different
bindings.

## Activity

:::slide

## Activity

Write `sign : int -> string` returning `"negative"`, `"zero"`, or
`"positive"`. Use a single `match` with `when`-clauses; no `if`/
`else`.

:::

Try it before reading on.

:::slide

## Activity solution

```ocaml
let sign = function
  | n when n > 0 -> "positive"
  | n when n < 0 -> "negative"
  | _ -> "zero"

let _ = sign 7
let _ = sign (-3)
let _ = sign 0
```

`"positive"`, `"negative"`, `"zero"`.

- Two guarded clauses, one unguarded wildcard.
- The wildcard *must* be present; otherwise warning 8.

:::

The two guarded clauses handle positive and negative inputs. The
wildcard handles "anything not caught by a guard," which is
zero. Without the wildcard, the compiler warns that zero is
unmatched, and a `sign 0` call would crash with `Match_failure`
at runtime.

## What's next

We have now seen four pattern forms (literal, variable,
wildcard, structured) and one extension (`when` guards).
[Lecture 4](M05-L04-exhaustiveness.html) zooms in on the static
check that has been hovering in the background: exhaustiveness. Why
it matters, how the compiler proves it, what to do when it warns,
and why it is the single biggest argument for using
[variants](M04-L03-variants.html) in your designs.

:::slide

## What's next

- Lecture 4: **exhaustiveness checking** in depth.
- We've seen warning 8 in passing. Now we look at how it works.
- The strongest argument for variants over strings or ints.

:::

## Reading

- **Cornell CS3110**, *Pattern matching guards*:
  <https://cs3110.github.io/textbook/chapters/data/pattern_matching.html>
- **Real World OCaml**, *Lists and patterns* (guards):
  <https://dev.realworldocaml.org/lists-and-patterns.html>
