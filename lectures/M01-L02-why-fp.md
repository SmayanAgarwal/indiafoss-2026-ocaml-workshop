---
title: "Why functional programming?"
lecture_no: 2
week: 1
duration_target_min: 25
concepts: [paradigms, pure functions, immutability, referential transparency, equational reasoning]
keywords: [functional programming, OCaml, pure functions, immutability, referential transparency, side effects, equational reasoning]
activity_question: "Which of the following functions is referentially transparent? (a) [let f x = x + 1]; (b) [let f x = Random.int x]; (c) [let counter = ref 0 in let f () = incr counter; !counter]; (d) [let f x = print_endline (string_of_int x); x]."
think_about_this: "If a function is pure, can you replace any call to it by its result without changing the meaning of the surrounding program? If a function is impure, can you still do the same?"
reading:
  - title: "Cornell CS3110, Chapter 1: Introduction"
    url: https://cs3110.github.io/textbook/chapters/intro/intro.html
  - title: "Why Functional Programming Matters (John Hughes, 1990)"
    url: https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf
---

# Why functional programming?

A reasonable question to open with: if you can already write programs
in C or Python or Java, why spend twelve weeks learning a new style?
You are not, after all, going to ship code in OCaml at every job
you ever have. The answer is the same answer that justifies learning
*any* new language: it changes how you think about programming, and
the new habits transfer back to whatever language you write in
tomorrow. This lecture makes that case concrete.

We will get there in three steps. First, an observation about
programming languages in general: Turing-completeness is a low bar,
and the interesting question is not *what* a language can compute
but *how easily* you can express what you want. Second, the
functional-programming thesis: programs built around pure functions
and immutable data are easier to reason about, easier to test,
easier to parallelise, and easier to refactor than programs built
around mutable state. Third, an honest accounting of where this
breaks down: functional programming is not a free lunch, and OCaml
is functional-*first* rather than functional-only specifically so
you can step outside the discipline when you need to.

## A one-instruction programming language

Here is a thought experiment that will sharpen what we mean by "what
a language is for". Imagine a programming language with a single
instruction. It is called `subleq`, which stands for *subtract and
branch if less than or equal to zero*. The instruction takes three
arguments:

```
subleq A, B, C
```

The semantics is one line: store at memory location `B` the
difference `mem[B] - mem[A]`, and if the result is `≤ 0`, jump to
instruction `C`. That is the entire language. There are no other
instructions. No `add`, no `load`, no `if`, no `while`. There is
not even a separate `goto`. The `subleq` instruction itself does
the conditional jump.

:::slide

## A one-instruction language

Consider a language with exactly one instruction:

```
subleq A, B, C
```

Read it as: store at `B` the difference of the values at `B` and `A`,
and if the result is `<= 0`, jump to `C`.

That's the whole language.

:::

Three `subleq` instructions, working with one scratch memory
location `Z` that starts at zero, implement *addition*. The pattern
is:

```
subleq A, Z, next1        ; Z := Z - A     (so Z = -A)
subleq Z, B, next2        ; B := B - Z = B + A
subleq Z, Z, end          ; Z := 0 again
```

You can work out for yourself, with patience, that after these three
instructions, the memory at location `B` contains `B + A` and the
memory at `Z` is back to zero. With slightly more work you can write
the `subleq` equivalents of "copy a memory cell", "branch on a
condition", "multiply by a constant", and so on. After enough such
gadgets, you have all the building blocks of a Turing machine.
`subleq` is *Turing complete*: it can compute anything any other
programming language can compute.

:::slide

## What can it compute?

- *Everything.*
- Three `subleq` instructions implement addition.
- A few more: copy, move, conditional, multiply.
- `subleq` is **Turing complete** — same power as any other language.

So why not write everything in `subleq`?

:::

So why not write all our programs in `subleq`? The flippant answer
is "because we would never finish anything." The more careful answer
is the one that motivates this entire course: a programming language
is not primarily a way of telling a CPU what to do. A programming
language is a way of *thinking about a problem*. When you write a
program, you are doing two things at once: communicating an
algorithm to a machine, and communicating that algorithm to a human
reader (often your future self). The first is a solved problem;
once you have a Turing-complete language, you can compute anything.
The second is the hard part.

`subleq` fails badly at the second task. A `subleq` program that
implements anything non-trivial looks like a long sequence of memory
manipulations with no high-level structure visible: you cannot see
what the program is *for* by reading it. You have to *simulate* it
in your head, instruction by instruction, to figure out what it
does. That is fine for a CPU; it is murder for a human reader.

:::slide

## Because language is about more than what you *can* compute

- A Facebook clone in `subleq`: theoretically possible, practically catastrophic.
- Languages exist to let you **say what you mean.**
- A programming language is for **thinking**, not just running.
- Richer abstractions $\Rightarrow$ thinking closer to the running code.

:::

The whole point of higher-level languages is to push *what you say*
closer to *what you mean*, so that reading code is closer to reading
your problem statement than it is to simulating a CPU. C raises the
level above assembly: variables instead of memory addresses,
expressions instead of single instructions, loops instead of
explicit branches. Java raises it above C: classes group related
data and behaviour, exceptions structure error handling, garbage
collection removes a class of bugs. Python raises it above Java:
list comprehensions, dynamic types, less ceremony.

Functional programming, the subject of this course, raises the level
in a different direction. Instead of adding ever-more-elaborate
structures *around* the assignments and loops of imperative
programming, it asks a more radical question: what if we got rid of
assignment and loops in the first place? What if every value was
immutable, every function was a pure mathematical mapping from
input to output, and the only way to "change" a data structure was
to build a new one? It sounds restrictive (and we will see where it
genuinely is) but it turns out to free up a lot of mental energy
that imperative programs eat without you noticing.

## The functional thesis

There are two ideas at the centre of functional programming. They
are simple to state and have far-reaching consequences. The rest of
this course is largely about working out those consequences in
detail.

:::slide

## The functional thesis

Two load-bearing abstractions:

1. **Functions as values.** Pass them around, return them, store them. First-class.
2. **Immutability.** Data is constructed, not mutated. New states $=$ new values.

Together: programs as **compositions of values**, not **sequences of state changes**.

:::

**Functions are values.** In OCaml, a function is a value of a
particular type, exactly the same way an integer is a value of type
`int`. You can pass functions to other functions. You can return
functions from other functions. You can store them in lists. You
can bind them to names with `let`. There is no separate "function"
construct that exists outside the value language; functions are
ordinary values that happen to be callable.

You may have seen lambdas in C++ (added in C++11), arrow functions
in JavaScript, or lambda expressions in Java (added in 8). All of
these are descended from the way functional languages have always
treated functions. The difference is that in OCaml, this is the
default, not an opt-in. You do not write `class Greeter { String
greet(String who) { ... } }` and then maybe pass a method reference
around; you write `let greet who = ...` and pass `greet` around.
The amount of ceremony required to express "I want to apply this
operation to each element of a list" is dramatically lower in OCaml
than in Java or C++.

**Data is immutable.** When you bind a name to a value in OCaml,
that binding does not change. The value `xs = [1; 2; 3]` does not
get *modified*; if you want a longer list, you build a new one
that starts with a new element and continues with the old list.
The old list is still there, untouched, and any code that was
holding it sees the same thing it always saw.

This is the change of perspective that takes the most adjusting to
if you arrive from C or Python. Mutation feels natural in those
languages: `i++` increments `i`, `arr[3] = 7` modifies the array,
`obj.field = value` updates the field. In functional programming,
you do not do any of that. There is no `++`. There is no `arr[3] =
7`. There is no `obj.field = value`. Instead, you write functions
that *return new values* with the desired change: `i + 1`, `replace
arr 3 7`, `{ obj with field = value }`. The old `i`, `arr`, and
`obj` are unchanged; you have new ones.

Together, these two ideas reframe programming. A program is no longer
a recipe of *steps* that *change* a *state*. A program is an
*expression* built out of smaller expressions, each producing a
value. Running the program means evaluating the top-level expression
to a value. The state of the world enters and leaves only at the
edges, where the program reads input or writes output; in between,
everything is value-to-value.

## Pure functions and what they buy you

A function is *pure* when its behaviour is fully determined by its
arguments. Two specific things have to be true: the function's
output depends only on its inputs (the same arguments always
produce the same output), and the function produces no observable
side effects (no I/O, no mutation, no exception, no reading or
writing of hidden state). A pure function is, in the mathematical
sense, just a *function*: a mapping from inputs to outputs.

:::slide

## Pure functions

A function is **pure** when:

- Its output depends only on its arguments.
- It produces no observable side effects: no I/O, no mutation, no
  exception, no hidden state read or written.

```ocaml
let double x = x + x
```

`double 21` is `42`. Always. Anywhere. Whether you call it once,
twice, or never.

:::

The function `double` above is pure. `double 21` is `42`, and not
just on a Tuesday: always, every time, in every context. You can
write `double 21` in any place a program needs the value `42`. Your
program does not care which is there.

That property, that a pure function call can be replaced by its
result without changing the meaning of the surrounding program, is
called *referential transparency*. It is the most important property
of pure functions, and arguably the most important property of
functional programming as a discipline. We will use it constantly.

:::slide

## Equational reasoning

- Pure functions $\Rightarrow$ reason about code like algebra.
- `double 21` is *equal to* `42`.
- Replace one with the other, anywhere — meaning unchanged.

```ocaml
let total = double 21 + double 21
(* same as *)  let total = 42 + 42
(* same as *)  let total = 84
```

Sounds modest. Powerful tool for **refactoring, testing, proving**.

:::

Referential transparency licenses *equational reasoning*: the same
kind of substitution you do in algebra. From middle-school algebra
you know that if `x = 5`, then any expression that contains `x`
gives the same answer when you replace `x` with `5`. Pure-function
calls give you the same right: if `double 21 = 42`, then any
expression containing `double 21` is equal to the same expression
with `42` substituted in. Run this calculation in your head:

```ocaml
let total = double 21 + double 21
```

You know `double 21 = 42`, so `total = 42 + 42 = 84`. You did not
need to *run* the program to know that. You did not need to
*trace* anything. You just substituted. This is what we mean when
we say functional code is "easier to reason about": you have
permission to do this kind of substitution.

This sounds like a small thing and it is in fact one of the largest
practical advantages of FP. It is the foundation of:

- **Refactoring.** You can replace any pure function call with its
  body, or extract a chunk of expression into a new helper, without
  worrying about whether some intermediate state changes the answer.
  The compiler will catch the type-level mistakes; the
  referential-transparency property guarantees there are no
  *semantic* mistakes hiding in the move.
- **Testing.** A pure function depends only on its inputs, so a unit
  test that calls it with a fixed input gets a fixed output, every
  time, forever. There are no flaky tests, no test ordering issues,
  no "but it worked on my machine". The space of inputs is the
  space of behaviours.
- **Parallelisation.** Two pure function calls that do not share
  arguments can be run in parallel without any synchronisation,
  because neither can affect the other's result. No locks. No
  data races. No memory model. The same property that makes
  refactoring safe makes concurrency safe.
- **Caching.** If `f x` is expensive to compute and pure, you can
  cache its result the first time and re-use the cached value forever.
  This is called *memoisation*. The fact that the function is pure
  means caching is always correct.

## Imperative code resists equational reasoning

Compare what you can do with this C function:

:::slide

## Imperative code resists this

```c
int counter = 0;
int next() {
  return ++counter;
}
```

- `next()` is **not** `next()`.
- Reordering two calls: breaks meaning.
- Caching the result: breaks meaning.
- Reading imperative code = reconstructing implicit state.

:::

The function `next` returns a different value every time you call
it. `next() == next()` is *false* (the first call returns one
value, the second returns the next). You cannot substitute `next()`
with its result, because there is no single "result"; each call
returns a different thing depending on the global state at the
moment of the call. You cannot reorder two calls to `next` without
changing the program's meaning. You cannot cache them. You cannot
parallelise them. Most importantly, you cannot read code that calls
`next` and know what it does without also knowing the history of
every previous call to `next` that the program has made.

This is not a contrived example. In real imperative programs, most
functions are not pure. Almost every Java method modifies its
receiver's fields. Almost every C function with side effects
implicitly reads and writes memory the caller did not pass in. To
understand what such a function does, you have to know what state
it touches, which means reading the function's source, which means
reading other functions it calls, recursively. This is one of the
reasons large imperative codebases become hard to change: every
function you call drags in a transitive cone of state, and reading
any local fragment requires reasoning about a non-local set of
facts.

Functional programming asks: what if we just did not let functions
read and write outside of their argument list? The discipline costs
you the ability to do certain things easily (we will come back to
the costs). The payback is that you can read any function in
isolation, and reasoning about a 100,000-line FP codebase decomposes
into reasoning about 100,000 lines, one function at a time.

## Immutability in practice

The other half of the FP thesis is immutability. Here is what it
looks like in OCaml. We will use the list type, which is the
workhorse data structure of every ML-family language.

```ocaml
let xs = [1; 2; 3]
let ys = 0 :: xs
let _ = xs
```

:::slide

## Immutability in practice

```ocaml
let xs = [1; 2; 3]
let ys = 0 :: xs
let _ = xs
```

- `ys` is `[0; 1; 2; 3]`. `xs` is **unchanged.**
- Both live at once. No "newer" version of `xs`.
- No copy cost: runtime shares the tail.

:::

The expression `0 :: xs` is "cons": it builds a new list whose first
element is `0` and whose tail is `xs`. So `ys` is `[0; 1; 2; 3]`.
But notice: `xs` is *unchanged*. If you look at `xs` after the
second line, it is still `[1; 2; 3]`. We did not modify `xs`; we
built a new list `ys` that *shares* its tail with `xs`.

This sharing is the practical reason immutability does not cost an
arm and a leg. The runtime does not copy `xs` when it builds `ys`;
it just points to the existing list. Both `xs` and `ys` live in
memory at the same time, sharing the `[1; 2; 3]` portion. This is
called *persistent* or *purely functional* data structures, and an
entire subfield of computer science is devoted to designing them so
that operations like "add an element" or "remove an element" are
cheap.

Immutability is what makes equational reasoning extend from individual
function calls to data structures. If `xs` cannot be modified
underneath you, then "the list that `xs` names" is a fact about your
program: it is the same fact one line down, one function call deep,
or twenty function calls deep, as long as `xs` is in scope. You can
pass `xs` to a function and *know* the function cannot change it.

Compare this to C, where if you pass `int *p` to a function, the
function can freely write `*p = 7` and you have to read the function
to know whether it does. Java is worse: every reference is
implicitly mutable, and a method can rearrange the inside of a
collection you passed it. Some Java libraries make a point of
documenting which arguments are "modified", which is a tacit
admission that the language defaults are wrong.

## Practising on a small example

Let's make this concrete with a quiz before moving on.

:::quiz mcq
Look at this OCaml code:

```ocaml
let xs = [1; 2; 3]
let ys = 0 :: xs
```

What is the value of `xs` after the second line?

- [ ] `[0; 1; 2; 3]`
- [x] `[1; 2; 3]`
- [ ] An empty list
- [ ] A runtime error: cannot modify a list

**Why:** `::` (cons) does not modify `xs`. It builds a *new* list
whose head is `0` and whose tail is `xs`. So `ys` is `[0; 1; 2; 3]`
and `xs` is still `[1; 2; 3]`. This is the central immutability
property of OCaml's data structures: the language gives you no way
to mutate `xs` in place. (In imperative pseudocode, the analogue is
`ys = [0] + xs` in Python or `ys = new ArrayList<>(...); ys.add(0);
ys.addAll(xs);` in Java. The Python expression also leaves `xs`
unchanged; the Java version creates a new list explicitly. In both
cases, the imperative language *also* gives you ways to mutate
`xs` in place, which OCaml does not.)
:::

## Where functional programming shines

Bringing the thread together: functional programming is at its
strongest in problem domains where reasoning about code matters
more than micro-optimising the hot path. Four such domains:

:::slide

## When functional shines

- **Parallelism without locks.** No mutable state means no races.
- **Refactoring.** Equational reasoning is a license to move code
  around with confidence.
- **Testing.** Pure functions are deterministic; tests are stable.
- **Domain modelling.** Algebraic data types make illegal states
  unrepresentable.

:::

**Parallelism without locks.** If pure functions have no side
effects, two pure functions cannot interfere with each other. You
can run them on different cores, in different threads, on different
machines, and the program's meaning is preserved. Concurrent
programs in functional languages typically do not need locks,
mutexes, or atomics, because there is no shared mutable state to
protect. We will see this in Module 12 of the secure-systems half.

**Refactoring at scale.** The Jane Street codebase is millions of
lines of OCaml, written over twenty years by hundreds of engineers.
That kind of codebase only stays maintainable if the language has
your back when you rewrite things. Functional code refactors well
because of equational reasoning: pulling an expression out into a
new helper, or inlining a small function back into its caller,
does not change the program's meaning. You can do these refactors
mechanically; the type checker catches the mistakes.

**Testing.** Pure-function tests are stable. You call the function
with an input, you assert the output, you do not have to worry
about whether some other test left state behind. In imperative
languages with hidden state, test order matters and "flaky tests"
are a real category of bug. In FP they are essentially impossible.

**Domain modelling.** Algebraic data types (variants and records,
which we will see in Module 4) let you describe the *shape* of your
domain so precisely that the compiler can check, statically, that
no part of your code can construct a value that does not make
sense. "Make illegal states unrepresentable" is a slogan you will
hear repeated in the OCaml community; it captures a real and
remarkable property.

## Where functional programming does not shine (be honest)

It is worth being clear-eyed about the costs. Functional programming
is not a free lunch.

:::slide

## When functional doesn't (be honest)

- **Hardware-level performance.** Cache-aware algorithms want mutation.
- **Imperative APIs.** Database, file system, network — effects exist.
- **Idiom carry-over.** Your first programs will fight your intuition. Normal.

OCaml is **functional-first**: disciplined escape hatches, used only when they help.

:::

**Hardware-level performance.** The very best algorithms for some
problems are inherently mutation-heavy. In-place sorting, hash
tables, union-find with path compression, cache-aware matrix
multiplication: these have purely-functional counterparts, but the
mutating version is sometimes substantially faster because it does
not allocate. OCaml lets you use mutation when you need it; you
just have to opt in (with the `ref` type, or with mutable record
fields, which we will see in Module 7).

**Imperative APIs.** The world is full of stateful interfaces.
Files have to be opened and closed. Databases have transactions.
Networks have sockets. Your program has to interact with these
things, which means your program has to have some effectful code in
it somewhere. Functional purists go to elaborate lengths to "wrap"
these effects (monads, in Haskell); OCaml takes a more pragmatic
view, lets you do I/O directly, and only asks that you keep the
effectful parts of your program small and identifiable. Module 7
covers this discipline.

**Your intuition will fight you.** If you arrive in this course
having written C or Python for years, your first OCaml programs
will look weird to you. You will reach for a `for` loop and have
to remind yourself it is not the right tool. You will want to
"just modify this list" and have to think about how to express the
same operation by returning a new list. This is normal. The
discomfort lasts a few weeks and then fades. After Module 4 or so,
the recursive, expression-oriented style starts feeling like the
natural way to write code, and reaching back for a mutable
variable feels like the unusual move.

## Why OCaml in particular

There are several functional languages we could have chosen for this
course. Haskell is the famously-pure one; F# is Microsoft's
.NET-friendly variant; Scheme is the elegant Lisp dialect; Scala is
the JVM-friendly mainstream compromise; Rust is the systems
language that inherited many ML ideas. So why OCaml?

:::slide

## Why OCaml specifically

Three things that don't often appear together:

- A serious **type system** — compile-time errors, not runtime.
- **Native-code performance** close to C.
- **Pragmatic effects** — state, exceptions, I/O when you need them; types make the boundary explicit.

That combination is what lets the second half of the course tackle **secure systems software**.

:::

OCaml hits a sweet spot that is unusual in language design. It has
a serious type system, native-code performance close to C, and
pragmatic treatment of effects. Haskell has the type system and
something close to native performance, but its purity discipline
makes practical I/O code more elaborate than it needs to be. F#
has the type system and the practicality, but its performance is
JVM-bounded and its ecosystem is .NET-bounded. Scheme has the
elegance but no static types. Scala has the practical balance but
the language is large and its JVM ceiling matters for systems
work. Rust gives you most of OCaml's safety with much more
hands-on memory management, which is appropriate when you need it
and overkill when you do not.

The second half of this course tackles secure systems software:
the OCaml runtime, the garbage collector, memory safety, the C
FFI, unikernel operating systems, concurrency, capability-based
security. Of all the functional languages, OCaml is the one where
this material is *natural*. It is the language MirageOS (a
unikernel OS) is written in. It is the language the Tezos
blockchain runtime is written in. It is the language that the user
of this course (me) and a substantial part of the OCaml team at
Tarides use to do this kind of work day-to-day. We get to teach
both halves of the course in the same language.

## Activity

:::slide

## Activity

Which of these is referentially transparent (the call can be replaced
by the result without changing program meaning)?

- (a) `let f x = x + 1`
- (b) `let f x = Random.int x`
- (c) `let counter = ref 0 in let f () = incr counter; !counter`
- (d) `let f x = print_endline (string_of_int x); x`

Think before peeking at the next slide.

:::

Before you read on, try the activity yourself. Predict the answer.
Then check it against the discussion below.

:::quiz mcq
Which of these functions is referentially transparent (i.e. a call
`f arg` can be replaced by its return value without changing the
meaning of the surrounding program)?

- [x] `let f x = x + 1`
- [ ] `let f x = Random.int x`
- [ ] `let counter = ref 0 in let f () = incr counter; !counter`
- [ ] `let f x = print_endline (string_of_int x); x`

**Why:** only the first one is pure. `Random.int x` returns a
different value each call (depends on hidden RNG state).
`f ()` with `incr counter` reads and writes a `ref`, which is
hidden state. `print_endline` produces an observable I/O effect:
the moment you replace the call with the return value, the side
effect (writing to stdout) goes away, so the program changes.
Pureness requires *both* deterministic output *and* no observable
effects.
:::

:::slide

## Activity discussion

Only **(a)** is referentially transparent.

```ocaml
(* (a) is pure: f 5 is always 6 *)
let f x = x + 1
```

- **(b)** is random.
- **(c)** reads and writes hidden state.
- **(d)** prints — an observable effect.

Replace any of these with a previous result: program behaviour changes.

:::

It is worth being precise about what makes (d) impure, since
beginners often miss it. The function returns the same value `x`
that it took as input, so the return value *is* deterministic. The
issue is the *side effect*: calling `f 5` writes "5\n" to standard
output. If you replace `f 5` with its return value `5`, the
program no longer writes "5\n". So the call is *not* equivalent to
the return value. The output is observable; the side effect is the
difference; therefore `f` is not pure.

## Looking ahead

We have argued for functional programming in the abstract. The rest
of the course is the concrete part: how do you actually write
programs in this style? Module 2 starts with the simplest
expressions and bindings; Module 3 gets to functions; Module 4
introduces algebraic data types and Module 5 pattern matching,
which together are how you do most of your data modelling; Module 6
puts higher-order functions to work. By the end of Module 8 you
will have all the basic FP tools.

The second half of the course (Modules 9-12) is where we use those
tools to talk about the things imperative languages traditionally
own: memory, the runtime, low-level interfaces, concurrency. Doing
those topics in a functional setting changes what you can say about
them.

:::slide

## What's next

- Next video: **a tour of OCaml.**
- Numbers, booleans, strings, basic let bindings, type inference,
  toplevel workflow.
- The lecture *is* the tour.

:::

The next lecture (M01-L03) is a quick tour of OCaml: numbers,
booleans, strings, basic `let` bindings, type inference, the
toplevel workflow. It is the most cell-heavy lecture in the
course, because the lecture *is* the tour. Open the page, click
Run on every cell, and you will end the lecture knowing the basic
shape of OCaml programs.

## Reading

- **Cornell CS3110, Chapter 1**: free online textbook, very
  accessible:
  <https://cs3110.github.io/textbook/chapters/intro/intro.html>
- **John Hughes, *Why Functional Programming Matters* (1990)**: one
  of the foundational papers in the area, still readable, makes the
  case for higher-order functions and lazy evaluation as
  modularity tools:
  <https://www.cs.kent.ac.uk/people/staff/dat/miranda/whyfp90.pdf>
- **Real World OCaml**, Chapter 1 *A Guided Tour*: complementary
  introduction:
  <https://dev.realworldocaml.org/guided-tour.html>
