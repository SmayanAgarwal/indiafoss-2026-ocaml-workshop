# Index of lectures

All 76 lecture files under [`lectures/`](lectures/), grouped by
module in course order. Each entry links to the source markdown;
the rendered, interactive version of every lecture is available at
the [live preview site](https://fplaunchpad.github.io/ocaml_nptel/),
which also has its own landing page with the same listing.

## M01: Intro to functional programming

- L01 [Course introduction: what you'll learn, how it's run](lectures/M01-L01-course-intro.md)
- L02 [Why functional programming?](lectures/M01-L02-why-fp.md)
- L03 [A tour of OCaml: values, types, and the toplevel](lectures/M01-L03-ocaml-tour.md)
- L04 [Your first OCaml program: hello, world (and beyond)](lectures/M01-L04-hello-world.md)
- L05 [Tutorial: temperature conversions and small expressions](lectures/M01-L05-tutorial-recap.md)

## M02: Expressions

- L01 [Literals: integers, floats, booleans, strings](lectures/M02-L01-literals.md)
- L02 [`let` bindings and shadowing](lectures/M02-L02-let-bindings.md)
- L03 [Static vs dynamic semantics, and type inference](lectures/M02-L03-types-and-inference.md)
- L04 [Operators, precedence, and common pitfalls](lectures/M02-L04-operators.md)
- L05 [`if`/`then`/`else` as an expression](lectures/M02-L05-if-expressions.md)
- L06 [Tutorial: small expressions, end to end](lectures/M02-L06-tutorial.md)

## M03: Functions

- L01 [Functions as values, and anonymous functions](lectures/M03-L01-functions-as-values.md)
- L02 [Recursion](lectures/M03-L02-recursion.md)
- L03 [Currying and partial application](lectures/M03-L03-currying.md)
- L04 [Tail recursion and accumulators](lectures/M03-L04-tail-recursion.md)
- L05 [Local functions and mutual recursion](lectures/M03-L05-local-and-mutual.md)
- L06 [Tutorial: Fibonacci, powers of two, fast power, digits](lectures/M03-L06-tutorial.md)
- L07 [Practice: recursion, currying, and tail recursion](lectures/M03-L07-practice.md)

## M04: Data types

- L01 [Tuples](lectures/M04-L01-tuples.md)
- L02 [Records](lectures/M04-L02-records.md)
- L03 [Variants (sum types)](lectures/M04-L03-variants.md)
- L04 [Recursive types: lists, trees, expressions](lectures/M04-L04-recursive-types.md)
- L05 [Tutorial: a tiny AST for OCaml](lectures/M04-L05-tutorial.md)
- L06 [Tutorial: a tiny file system](lectures/M04-L06-tutorial-fs.md)

## M05: Pattern matching

- L01 [Basic patterns: literals, variables, wildcards](lectures/M05-L01-basic-patterns.md)
- L02 [Pattern matching on lists and trees](lectures/M05-L02-recursive-patterns.md)
- L03 [Nested patterns and or-patterns](lectures/M05-L03-nested-and-or-patterns.md)
- L04 [Guards: when-clauses on patterns](lectures/M05-L04-guards.md)
- L05 [Exhaustiveness checking](lectures/M05-L05-exhaustiveness.md)
- L06 [Tutorial: an interpreter for the OCaml AST](lectures/M05-L06-tutorial.md)
- L07 [Practice: pattern matching, by hand](lectures/M05-L07-practice.md)

## M06: Higher-order programming

- L01 [Functions as values, revisited](lectures/M06-L01-functions-revisited.md)
- L02 [`map`: transform every element](lectures/M06-L02-map.md)
- L03 [`filter`: keep what passes the predicate](lectures/M06-L03-filter.md)
- L04 [`fold`: reduce a list to a single value](lectures/M06-L04-fold.md)
- L05 [Function composition and pipelines](lectures/M06-L05-pipelines.md)
- L06 [Tutorial: fold across data structures](lectures/M06-L06-tutorial.md)
- L07 [Practice: recursion, higher-order functions, and syntax trees](lectures/M06-L07-practice.md)

## M07: Side effects and modular programming

- L01 [Mutable references](lectures/M07-L01-references.md)
- L02 [Mutable records and arrays](lectures/M07-L02-arrays-and-mutation.md)
- L03 [Exceptions](lectures/M07-L03-exceptions.md)
- L04 [Streams and laziness](lectures/M07-L04-streams-and-laziness.md)
- L05 [Memoization](lectures/M07-L05-memoization.md)
- L06 [Module basics](lectures/M07-L06-module-basics.md)
- L07 [Module signatures](lectures/M07-L07-signatures.md)
- L08 [Functors](lectures/M07-L08-functors.md)
- L09 [Tutorial: a queue functor](lectures/M07-L09-tutorial.md)
- L10 [Practice: mutability, modules, and streams](lectures/M07-L10-practice.md)

## M08: Monads and GADTs

- L01 [The option monad and `let*`](lectures/M08-L01-option-monad.md)
- L02 [Monad laws, the list monad, and the result monad](lectures/M08-L02-laws-list-result.md)
- L03 [The state monad and parameterised state](lectures/M08-L03-state-monad.md)
- L04 [GADTs: variants with type-level information](lectures/M08-L04-gadts-basics.md)
- L05 [GADTs: use cases beyond toy interpreters](lectures/M08-L05-gadts-use-cases.md)
- L06 [GADTs: hlists and witnesses](lectures/M08-L06-hlists-witnesses.md)
- L07 [Tutorial: a tiny well-typed evaluator](lectures/M08-L07-tutorial.md)
- L08 [Practice: monads and GADTs](lectures/M08-L08-practice.md)

## M09: Testing

- L01 [Why test a type-safe program?](lectures/M09-L01-why-test-typed-code.md)
- L02 [Specifications and invariants](lectures/M09-L02-specifications-invariants.md)
- L03 [Designing test cases: black-box and glass-box](lectures/M09-L03-test-design.md)
- L04 [Unit testing](lectures/M09-L04-unit-testing.md)
- L05 [Property-based testing with QCheck](lectures/M09-L05-property-based-testing.md)
- L06 [Model-based testing of stateful data structures](lectures/M09-L06-model-based-testing.md)
- L07 [Tutorial: testing the expr evaluator with OUnit2 and QCheck](lectures/M09-L07-tutorial.md)
- L08 [Practice: writing tests](lectures/M09-L08-practice.md)

## M10: Memory safety and security

- L01 [What memory safety is, and why it is a security story](lectures/M10-L01-memory-safety-and-security.md)
- L02 [Memory safety by construction](lectures/M10-L02-memory-safety-by-construction.md)
- L03 [Data races are undefined behaviour](lectures/M10-L03-data-races-are-ub.md)
- L04 [Where OCaml itself has UB](lectures/M10-L04-where-ocaml-has-ub.md)
- L05 [Tutorial: walking Heartbleed end to end](lectures/M10-L05-tutorial.md)

## M11: OxCaml: type-level extensions of safety

- L01 [Locality: safe stack allocation](lectures/M11-L01-locality.md)
- L02 [Uniqueness: the only reference](lectures/M11-L02-uniqueness.md)
- L03 [Linearity: use at most once](lectures/M11-L03-linearity.md)
- L04 [Contention: synchronisation at compile time](lectures/M11-L04-contention.md)
- L05 [Portability: data-race freedom across domains](lectures/M11-L05-portability.md)
- L06 [Tutorial: a resource-management API](lectures/M11-L06-tutorial.md)
- L07 [Practice: programming with modes](lectures/M11-L07-practice.md)

## M12: Unikernels (MirageOS)

- L01 [Why do we need an OS?](lectures/M12-L01-why-an-os.md)
- L02 [MirageOS Unikernel Background](lectures/M12-L02-unikernel-background.md)
- L03 [MirageOS Basics](lectures/M12-L03-mirageos.md)
- L04 [Suresh the Stationmaster: a worked unikernel example](lectures/M12-L04-suresh-the-stationmaster.md)

