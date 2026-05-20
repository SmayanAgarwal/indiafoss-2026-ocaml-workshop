---
title: "Course introduction: what you'll learn, how it's run"
lecture_no: 1
week: 1
duration_target_min: 15
concepts: [course logistics, syllabus overview, in-browser dev environment, grading]
keywords: [OCaml, NPTEL, functional programming, course intro, syllabus, FP]
activity_question: "How is the certification score split between weekly assignments and the final exam?"
think_about_this: "Why do you think the course bothers to teach functional programming at all, when most software you've used is written in imperative languages?"
reading:
  - title: "Functional Programming in OCaml (Cornell CS3110)"
    url: https://cs3110.github.io/textbook/
  - title: "Real World OCaml"
    url: https://dev.realworldocaml.org/
---

# Course introduction

Welcome to **Functional Programming with OCaml**. This first lecture
is short and almost entirely logistical: what we will cover over the
twelve weeks, who the course is aimed at, how it is graded, and how
you will run OCaml code directly in your browser without installing
anything. The [next lecture](M01-L02-why-fp.html) is where the actual
technical content begins.

I want to spend this opening session on framing rather than on syntax,
because the choices a course makes about what to teach are themselves
worth understanding. There are dozens of programming language courses
on NPTEL and elsewhere, and they make very different choices about
which language to use, which features to emphasise, and how much
mathematical content to include. By the end of this lecture you
should know what *kind* of course this is, and whether it is the
right one for what you want to learn next.

A quick note on the format. Every lecture in this course comes as
both a 20-30 minute recorded video, where I work through slides
with you, and a long-form chapter, which is what you are reading now.
The chapter elaborates on the same material, with more worked
examples, asides, pitfalls, and inline quizzes you can attempt.
The slides are the spine; the chapter is the body. If you only have
time for one, watch the video. If you want to really learn the
material, read the chapter afterwards.

:::slide

## Functional Programming with OCaml

A 12-week NPTEL course on functional programming, taught through OCaml,
with a strong second half on secure systems software.

K. C. Sivaramakrishnan, IIT Madras. Most students call me KC.

:::

## Who is this course for?

This is a course about programming languages, taught through one
particular language. The audience I have in mind is a third- or
fourth-year undergraduate in computer science who has written some
C, maybe some Java or Python, knows what a pointer is, knows what
a `for` loop is, and has taken a data structures and algorithms
course. If that's you, you have everything you need.

It is also a course for working software engineers who want to
broaden the set of language paradigms they are comfortable in.
Functional programming concepts have crossed over into mainstream
languages over the last decade: lambdas in C++ and Java, type
inference in Rust and TypeScript, pattern matching in Swift and
Python (since 3.10), immutable data structures everywhere. Working
in OCaml for twelve weeks gives you a coherent setting where all of
these ideas hang together, instead of feeling like bolt-ons to a
language designed for something else.

It is *not* a first programming course. We will not pause to explain
what a variable is or what a function call does. If those concepts
are still wobbly for you, work through any introductory programming
text first, then come back. The course also assumes you can read C
syntax casually, because we will draw comparisons against C and C++
throughout, especially in the secure-systems half.

:::slide

## Who is this course for?

- Undergraduate and postgraduate students in CS and related disciplines.
- Systems engineers, software developers, researchers.
- Anyone who wants to build robust, reliable, type-safe software.

**Prerequisites:** C programming, basic data structures and algorithms.
Nothing more.

:::

## What you will learn

The course splits cleanly into two halves. The first eight modules
(weeks) teach functional programming proper, using OCaml as the
vehicle. We start with expressions and values, work up through
functions, data types, pattern matching, higher-order functions,
side effects, modules, and finally monadic abstractions and
generalised algebraic data types. By the end of Module 8 you will
be able to read and write idiomatic OCaml at the level of a working
professional, and you will have internalised the FP habits of
thought that transfer to every other language you will ever use.

The last four modules (weeks 9-12) cover secure systems software,
which sounds like a separate course but is intimately connected to
what we did in the first half. The OCaml runtime, the garbage
collector, undefined behaviour, memory safety, foreign function
interfaces, unikernel operating systems, and capability-based
concurrency: these are the parts of the language that touch real
hardware and real performance, and they are where OCaml's safety
properties pay the largest dividends. The reason we can talk about
"undefined behaviour" precisely in week 9 is that we will have
spent eight weeks pinning down what *defined* behaviour even means.

:::slide

## What you'll learn

![12-module course roadmap](/assets/diagrams/M01-roadmap.svg)

By the end:

- You write **idiomatic OCaml**.
- You **reason equationally** about your code.
- You understand how OCaml's design choices buy you safety where
  C and C++ traditionally fail.

:::

Three skills you will leave with, in increasing order of generality:

**You will write idiomatic OCaml.** Not just OCaml that compiles, but
OCaml that an experienced reviewer at [Jane Street](https://www.janestreet.com)
or [Tarides](https://tarides.com) would glance at and nod. Idiomatic
means *the natural way* to express an idea in this language: when to
reach for a record instead of a tuple, when a variant beats a class
hierarchy, when pattern matching is clearer than `if`, when a fold is
clearer than a loop. Each of these choices feels arbitrary at first
and obvious in retrospect; the course is largely about getting you
to the second state.

**You will reason equationally about your code.** This is shorthand
for a habit of mind that functional programming makes possible. When
every function is pure (returns a value, has no side effects), you
can substitute equals for equals: replace any expression with its
value, replace any call with its body. This sounds like a small thing
and is in fact one of the more profound differences between FP and
imperative programming. We will spend [the next lecture](M01-L02-why-fp.html#equational-reasoning)
setting up why this matters, and the rest of the course exercising
it.

**You will understand the safety story.** OCaml is one of a small
number of mainstream languages where memory safety is provided by
construction in the type system, without sacrificing C-level
performance. The way OCaml achieves this is *not* by being slow,
or by being garbage-collected (though it is). It is by being
careful about which language constructs admit undefined behaviour
in the first place. The secure-systems half of the course makes
this concrete: you will see what *defined* and *undefined* behaviour
mean, where the OCaml runtime draws the line, and how to interface
safely with C code that does not.

## Why OCaml?

The choice of OCaml deserves some defense, because it is not the most
popular language and you might reasonably ask why we did not pick
Python or Rust or Haskell. The short answer is that OCaml is the
best teaching language for the *concepts* we want to teach. The
long answer comes in three parts.

First, OCaml is *functional-first* with a *serious* type system.
"Functional-first" means immutability, expressions, recursion,
and higher-order functions are the natural way to write programs,
the same way classes and inheritance are natural in Java. "Serious"
means the type system is sound: if your program type-checks, certain
classes of bugs simply cannot happen. Sound type systems are
uncommon. JavaScript and Python have no real static types. Java
and C++ have type systems that they let you escape from too easily.
Rust is the closest sibling to OCaml in this respect, and a lot of
Rust's design is directly inherited from ML (the family OCaml
belongs to).

Second, OCaml is *practical*. It is used in production at
[Tarides](https://tarides.com),
[Jane Street](https://www.janestreet.com) (whose internal systems
are millions of lines of OCaml), [Bloomberg](https://www.bloomberg.com/company/values/tech-at-bloomberg/)
(financial infrastructure), Facebook (the [Hack](https://hacklang.org)
and [Flow](https://flow.org) type checkers for PHP and JavaScript
respectively, both written in OCaml),
[Docker](https://www.docker.com) (their virtualization toolkit),
the [Rocq theorem prover](https://rocq-prover.org) (formerly Coq),
the [Tezos blockchain](https://tezos.com), and across academia.
"Practical" here means: people use it to ship things that other
people depend on. This is not a research curiosity.

Third, OCaml is *fast*. The native-code compiler produces binaries
that run within a small constant factor of C for most workloads.
The garbage collector is incremental and concurrent in recent
versions. There is no virtual machine, no JIT warmup, no
interpretation overhead. When you write a tight loop in OCaml and
compile it to native code, you get something close to what you
would get from a C compiler. This matters because functional
programming has a reputation for being slow that comes from
JavaScript and Python and from Haskell's lazy evaluation. OCaml is
the counterexample.

:::slide

## Why OCaml?

- A **functional-first** language with a serious type system.
- **Practical:** used at Tarides, Jane Street, Bloomberg, Facebook (Hack/Flow),
  Docker, Mozilla, and across academia.
- **Fast:** native code performance close to C, with garbage collection
  and no undefined behaviour in the safe fragment.
- **A great teaching language** for ideas you will see again in Rust,
  Scala, Haskell, Swift, Kotlin, TypeScript.

:::

A fourth reason worth listing separately: OCaml is *small*. The core
language fits in a long afternoon: a handful of expression forms, a
handful of type constructors, a module system, a few sugar
constructs. Compare that to C++, where the full language is large
enough that no single human knows all of it. The smallness lets us
spend lecture time on *why* things are the way they are, rather than
on enumerating syntax.

You will also be re-using almost everything you learn here in other
languages. Type inference, sum types (also called variants or
algebraic data types or "enums" in Rust and Swift), pattern matching,
higher-order functions, generics with parametric polymorphism, the
`Option` type as a replacement for null, immutability by default,
the `Result` type for error handling: every one of these has crossed
over into the mainstream of language design. OCaml is the language
where you can see them in their natural habitat, where they were
designed together as a coherent set rather than added later as
features.

## Run code right in this page

Before we get to the syllabus and grading, let me show you how the
course infrastructure works, because it shapes what you can do with
the lecture pages.

Every lecture has runnable OCaml cells embedded in it. Like this:

```ocaml
let greeting who = "hello, " ^ who
let () = print_endline (greeting "NPTEL")
```

If you are reading this in a browser, you should see a "Run" button
near the top right of the code block above. Click it. The OCaml
toplevel runs *in your browser* (no server, no install, the bytes
never leave your machine) and the output appears below the cell.
The first run takes a few seconds to compile the toplevel; later
runs are instant.

You can edit the code. Try changing `"NPTEL"` to your own name and
clicking Run again. If you make a syntax mistake, you will see the
compiler error inline; fix it and run again.

:::slide

## Run code right in this page

- Every lecture has **runnable OCaml cells.**
- Click **Run** — output appears inline.
- Edit any cell, Run again.
- Nothing to install.

```ocaml
let greeting who = "hello, " ^ who
let () = print_endline (greeting "NPTEL")
```

:::

:::notes
Click Run live so the audience sees [hello, NPTEL] appear inline. If
they ask: the OCaml toplevel runs in their browser via [x-ocaml]; no
server, no install, everything stays on their machine.
:::

The little ↺ button next to Run resets the cell back to its original
source if you have edited it. Your edits are saved in your browser's
local storage, so if you close the tab and come back, your code is
still there. This is meant to be a notebook, not a one-shot demo.

A useful feature you might not discover by yourself: hover the
mouse over an expression in any cell and the editor shows its
inferred type as a tooltip. This is the same information the
toplevel prints as `val name : type = value` after a Run, but you
get it inline without running anything. When you are reading
unfamiliar code, the hover is the fastest way to find out what a
particular sub-expression has type.

## Anonymous quiz analytics

A small operational note. The site records *anonymous* responses to
the inline quizzes, so I can see which questions are hardest and
revise the surrounding material. No personal data is collected; no
account exists; no IP address is retained. A random reader
identifier is stored in your browser to associate your answers with
each other (so I can tell two responses came from the same reader)
and that identifier is the only thing tying responses together. The
methodology mirrors the [Brown PLT TRPL quiz study](https://rust-book.cs.brown.edu/)
that motivated the inline-quiz design.

If you would prefer to opt out, the [Privacy page](privacy.html) has
a one-click toggle and a "delete my data" button that scrubs every
response associated with your browser. The toggle is per-device, so
turning it off on your laptop does not affect your phone. Opting
out has no effect on grading or on your ability to use the cells
and quizzes locally.

Below the cell, look for inline quizzes (which I will show you in
later lectures). They come in two flavours: multiple-choice questions
with explanations, and code-completion challenges where you fill in
a function and click *Check* to run a set of tests against your
solution. Both are optional but recommended; they're the difference
between thinking you understood a chapter and actually understanding
it.

## A taste of OCaml

Here is something you will be able to write yourself by Week 6. Don't
worry about understanding the syntax now. Just click Run and look at
what comes out.

:::slide

## A taste: primes from a list

```ocaml
let rec sieve = function
  | [] -> []
  | p :: rest ->
      p :: sieve (List.filter (fun n -> n mod p <> 0) rest)

let rec range a b = if a > b then [] else a :: range (a + 1) b

let _ = sieve (range 2 50)
```

Press **Run.** You should see the primes up to 50 come out.

You will write code like this from scratch by Week 6. For now, just
enjoy the output and notice how short the program is.

:::

:::notes
This is the teaching sieve, not the efficient one. It's quadratic in
the number of primes and allocates a fresh list at every step. Worth
mentioning offhand if anyone asks; do not labour it. The point is
"five lines, runnable, OCaml", not algorithmic efficiency.
:::

The output is a list of integers, in OCaml notation: `[2; 3; 5; 7;
11; 13; 17; 19; 23; 29; 31; 37; 41; 43; 47]`. Those are the primes
up to 50, computed by a version of the Sieve of Eratosthenes that
fits in five lines. Without explaining anything yet, notice a few
things.

There is no loop in this code. There is no mutable counter, no
`++`, no array index. The function `sieve` is *recursive*: it calls
itself on a smaller input. The function `range` does the same. This
is how you express iteration in OCaml.

The line `| p :: rest -> ...` is [*pattern matching*](M05-L01-basic-patterns.html):
it says "if the input list has a first element `p` followed by some
rest, do the following." If you have written `switch` in C or Java,
pattern matching is like that but on the *structure* of values, not
just on their tags.

The expression `fun n -> n mod p <> 0` is an *anonymous function*: a
function with no name, defined inline. We pass it as an argument to
[`List.filter`](M06-L03-filter.html). Passing functions around like
this is normal in OCaml and central to what makes the language
compact. We will spend [Module 6](M06-L01-functions-revisited.html)
on this idea alone.

The point of showing you this in lecture one is not to teach the
syntax. It's to set the bar: in twelve weeks, you will look at this
five-line program and read it as easily as you would read a `for`
loop today. That is the destination. The route there is the rest of
the course.

## How the course is graded

NPTEL courses follow a standard grading structure that I do not
get to change. The split is 25% weekly assignments, 75% final
certification exam, with a 40% overall threshold to receive a
certificate.

:::slide

## How the course is graded

- **25%** weekly assignments. One assignment per week, due roughly a
  week after the corresponding videos appear.
- **75%** final certification exam. Two paper sets exist; you sit one.
- You need **40%** overall to receive a certificate.

The proctored final exam is conducted in person by NPTEL; the
assignments are submitted online via the SWAYAM portal.

:::

A few details worth knowing. The assignments are programming
problems with auto-graded test cases. You write OCaml code, submit
through the SWAYAM portal, and the autograder runs it against a
hidden set of inputs. You will see your score after the submission
deadline closes. There are no late submissions: the portal closes
at the deadline. NPTEL is strict about this and I cannot make
exceptions.

The final exam is a written paper, conducted in person by NPTEL at
their proctored centres across India. The questions are
short-answer and code-reading: things like "What is the type of this
expression?", "What does this program print?", "Implement this
function in OCaml." It is not open-book. You write code with a pen
on paper, which is unusual for a programming course but is the NPTEL
standard. The exam is multiple-choice-heavy by NPTEL convention; I
will make sure the questions test real understanding rather than
memorised syntax.

The 40% threshold for a certificate is the standard NPTEL pass mark.
Most students who follow along weekly comfortably clear it. The
distribution of marks in past iterations of similar courses has
been wide; serious engagement gets you well above 40%.

## The structure of each week

Every week of the course follows the same shape, so you can plan
your time once and then run on autopilot.

:::slide

## The structure of each week

Every week of the course follows the same shape:

- **5 to 7 short videos**, 20 to 30 minutes each. One concept per video.
- **A tutorial video** at the end of the week that walks through
  problems of the same flavour as that week's assignment.
- **One assignment** released alongside the videos.
- **A discussion forum** on the NPTEL platform, checked daily.

:::

The videos are deliberately short. Past experience with longer lecture
videos shows that engagement falls off sharply past 30 minutes, so I
have broken each topic into bite-sized pieces. You can watch one a
day over the working week and finish the week's content without ever
sitting down to a long session. The chapter pages (these documents
you are reading) elaborate on each video and are meant as the
read-after-watching companion.

The tutorial video at the end of each week is important. It walks
through 2-3 problems of the same flavour as the assignment, with me
working out the solutions on the fly. If you find an assignment
problem hard, the tutorial is the first place to look: there will
be a similar problem worked out.

The discussion forum is your main channel for questions. I check it
daily, and so do the teaching assistants. Use it. Asking questions
in public also helps the other students who had the same question
but were too shy to ask.

## What this course is not

It is worth being explicit about scope. There are several large
topics that this course *does not* cover, and a student who came in
expecting them would be disappointed.

:::slide

## What is *not* in this course

- We are not building a production system from scratch.
- We are not surveying every language feature OCaml has; we cover the
  ones that matter for clear, type-safe code.
- We are not doing pure type theory; we will use a little, where it
  helps. The course is engineering-flavoured.

If you want either of the first two, the Cornell CS3110 textbook and
*Real World OCaml* are excellent follow-on reading.

:::

We will not build a production system from scratch. That is a real
software-engineering course, and a worthwhile one, but not this
course. The longest piece of code you will write in this course
fits on one screen.

We will not survey every feature of OCaml. The language has many
corners: objects and classes (rarely used in modern code), camlp4
syntax extensions (deprecated), polymorphic variants (mostly
specialised), first-class modules (advanced),
[GADTs](M08-L05-gadts-basics.html) (we touch them briefly), effect
handlers (a Module 12 topic in the secure-systems half). I have
picked the subset that will be most useful to you in the largest
number of future situations.

We will not do pure type theory. This is a programming course, not
a programming-languages-theory course. I will use type-theoretic
language ("polymorphism", "parametricity", "soundness") where it
helps explain something, and I will not when it does not. If you
want the type-theory companion text, [Pierce's *Types and Programming
Languages*](https://www.cis.upenn.edu/~bcpierce/tapl/) is the
standard reference; if you want the OCaml-flavoured version, the
[Cornell CS3110 textbook](https://cs3110.github.io/textbook/) and
[*Real World OCaml*](https://dev.realworldocaml.org/) (both free,
both linked above) are excellent and complement this course well.

## A quick checkpoint

Before we move on, a small comprehension check on what we just
covered. Use it to see whether the logistics are clear.

:::quiz mcq
The certificate grade for this course is computed as:

- [ ] 50% weekly assignments + 50% final exam
- [x] 25% weekly assignments + 75% final exam
- [ ] 100% final exam (assignments don't count)
- [ ] 75% weekly assignments + 25% final exam

**Why this matters:** the final exam is the bigger lever, but
weekly assignments are still 25% of your grade and a much easier
way to bank marks. The students who miss assignments and then try
to make it up in the final usually struggle: 75% is high but you
have to clear it from a cold start. Doing weekly assignments also
teaches the material; the final exam tests that you learned.
:::

## What's next

Next video: [**why functional programming?**](M01-L02-why-fp.html)
The case for FP given that you can already write programs in
imperative languages. We will start by looking at a one-instruction
programming language (yes, really) and noticing what makes it hard
to read, then look at how functional programming makes programs
easier to read instead.

:::slide

## What's next

- Next video: **why functional programming?**
- The case for it, given that you can already write programs.

:::

## Reading

- Cornell **CS3110** textbook, Preface and Chapter 1:
  <https://cs3110.github.io/textbook/>
- **Real World OCaml**, Prologue:
  <https://dev.realworldocaml.org/prologue.html>
- The NPTEL course page (you're already there).
- John Whitington, *OCaml from the Very Beginning* (book) -- a
  gentler pace, useful as a parallel read if you find this course
  moving too quickly.
