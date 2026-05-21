---
title: "Ingredient 3: OCaml for systems"
lecture_no: 4
week: 12
duration_target_min: 25
concepts: [memory-safe languages, GC, type safety, industrial OCaml, FFI, OCaml performance, web server benchmarks]
keywords: [OCaml, memory safety, White House memo, CISA, NSA, OCaml performance, FFI, eio, Jane Street]
activity_question: "If 70 percent of CVEs in major C/C++ codebases are memory-safety bugs, and most of the kernel underneath any application is C, what is the lower bound on the security problem you cannot solve in user-space alone?"
think_about_this: "The White House publishing a memo telling industry to move to memory-safe languages is not a normal thing for the White House to do. Why now? What changed that made the federal government weigh in on programming-language choice?"
reading:
  - title: "White House ONCD, Press Release: Future Software Should Be Memory Safe (Feb 26, 2024)"
    url: https://bidenwhitehouse.archives.gov/oncd/briefing-room/2024/02/26/press-release-future-software-should-be-memory-safe/
  - title: "CISA / NSA / FBI / international partners, The Case for Memory Safe Roadmaps (Dec 2023)"
    url: https://www.cisa.gov/resources-tools/resources/case-memory-safe-roadmaps
---

# Ingredient 3: OCaml for systems


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Ingredient 3: OCaml for systems</h2>
<p class="title-slide-label">Module 12 &middot; Lecture 4</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

We have a library OS ([M12-L02](M12-L02-library-os.html)) that
collapses the kernel into ordinary function calls and a hypervisor
([M12-L03](M12-L03-virtualisation.html)) that isolates one library
OS from another. Between them, two of the three problems from
[M12-L01](M12-L01-why-an-os.html) are solved: the iceberg is gone
(only the libraries you use ship in your image), and the
cross-application protection boundary is back (the hypervisor
provides it).

One problem is left. *Inside* a single library-OS image, there is
no MMU wall between the application and the network stack, between
the network stack and the TLS library, between the TLS library and
the crypto primitives. A buffer overflow in the parser of the
network stack can corrupt the application's data. A use-after-free
in the TLS state machine can hand the attacker the keys. The
hypervisor cannot help here; it does not see inside a guest.

The third ingredient of MirageOS is the choice of *implementation
language* for the OS itself. If the library OS is going to be one
giant address space without internal protection, the language has to
provide the safety the MMU used to. That language has to be
memory-safe. It has to be productive enough to write an entire OS
in. It has to be fast enough that the resulting OS holds up against
hand-written C. And it has to have a clean escape hatch for the small
unsafe core that genuinely needs to talk to hardware.

OCaml fits these requirements. This lecture is the case for that
fit. It has four parts. First, the contemporary policy context: why
the world has finally noticed memory safety. Second, OCaml's safety
properties, re-grounded from earlier modules. Third, OCaml's
pragmatism: who actually uses it, where it sits in the performance
landscape, and why it has a working FFI for the small unsafe core.
Fourth, a concrete network benchmark that demonstrates that "safe"
does not mean "slow."

:::slide

## Where we are

- M12-L02 broke the kernel into libraries. **No internal
  protection.**
- M12-L03 added a hypervisor for between-unikernel isolation.
- This lecture: a **safe language** to do the internal-protection
  job the MMU used to do.
- Specifically, **OCaml**: memory-safe, type-safe, fast, pragmatic.

:::

## Why memory safety, why now

The technical case for memory safety has been overwhelming for
decades, but the *political* case has only recently caught up. Two
documents are worth seeing on a slide once.

The first is the **White House ONCD press release**, *Future Software
Should Be Memory Safe*, published on 26 February 2024. The body of
the release argues, on behalf of the Office of the National Cyber
Director, that "experts have identified a few programming languages
that both lack traits associated with memory safety and also have high
proliferation across critical systems, such as C and C++." It
recommends that organisations using such languages should adopt
"memory safe roadmaps" to migrate to memory-safe languages. The
specific languages it points to in the technical appendix include
Rust, Go, Java, C#, Python, and Swift. The release is short, plain,
and unusually direct for federal-government technical advice.

The second is the **CISA / NSA / FBI joint publication**, *The Case
for Memory Safe Roadmaps: Why Both C-Suite Executives and Technical
Experts Need to Take Memory Safe Coding Seriously*, published in
December 2023. The signatories are a long list of national cyber
authorities: the US CISA, NSA, FBI; Australia's ACSC; Canadian Centre
for Cyber Security; UK NCSC; New Zealand's NCSC and CERT NZ. The
document is longer (~30 pages) and aimed at executive audiences who
want to understand why their CISO is asking to fund a language-
migration project.

Both documents land on essentially the same set of statistics, and
those statistics are the empirical core of the case. They are worth
revisiting:

- **Microsoft Security Response Center, 2019**: of all high-severity
  CVEs in Microsoft products across more than a decade, roughly **70
  percent are memory-safety issues**. The proportion has been
  flat at that level for twelve years of measurement.
- **The Chromium project, 2020**: in the high-severity bug bucket
  for Google's browser engine, **around 70 percent** are memory-
  safety problems, of which roughly half are use-after-free.
- **Google Android, 2022**: of Android security vulnerabilities,
  **around 90 percent** are memory-safety issues.
- **Fish in a Barrel project**: of *exploited zero-day*
  vulnerabilities tracked between 2014 and 2019, **roughly 80
  percent** were memory-safety bugs. The annual proportion swung
  between 45 percent and 100 percent year to year, but the total
  across the period was 87 of 108 exploited 0-days.

We covered these numbers carefully in
[M10-L02](M10-L02-memory-bugs-as-security.html), and the four
canonical bugs that drive them (use-after-free, buffer overflow,
uninitialised read, double-free) in
[M10-L01](M10-L01-ub-and-the-zoo.html). The reason to re-encounter
them here is that they are *the* argument for the third ingredient
of MirageOS. If your TCB is mostly C, your TCB will keep producing
memory-safety CVEs no matter how well-managed it is. The only
sustainable answer at the OS level is to make the TCB itself
memory-safe.

:::slide

## The case for memory safety

- **Microsoft 2019**: ~70% of high-severity CVEs are
  memory-safety bugs. Stable for over a decade.
- **Chromium 2020**: ~70% high-severity, half of those use-
  after-free.
- **Android 2022**: ~90% of security vulnerabilities.
- **Fish in a Barrel, 2014-2019**: ~80% of exploited 0-days.
- **White House, Feb 2024**: "Future Software Should Be Memory
  Safe."
- **CISA / NSA / FBI**, Dec 2023: "Memory Safe Roadmaps."

The world has finally noticed.

:::

The interesting thing about these documents is what they *do not*
say. They do not say "C and C++ are bad." They do not name a single
recommended replacement; they list several. They do not give a
timeline. What they say, repeatedly, is: at the layers of the stack
that you most want to be secure, you should be writing in a memory-
safe language by default, and where you can't, you should have a
plan and a timeline for getting there.

That is the context for MirageOS. We are building an OS, which is
about as deep in the TCB as software gets, and we are choosing to
write it in a memory-safe language. The choice would be ideologically
extreme if we made it in 2003; in 2026 it lines up with what the
relevant national governments are telling everybody to do.

## What "memory-safe" buys you

We covered this in [M10-L03](M10-L03-how-ocaml-rules-them-out.html)
but it is worth re-anchoring the four pieces here.

**Garbage collection eliminates lifetime questions.** There is no
`free` in OCaml. The garbage collector reclaims memory only after
every reference to it has gone out of scope. Use-after-free is not
just unlikely; it is a category-error in the language. We saw in
[M10-L01](M10-L01-ub-and-the-zoo.html) that use-after-free is the
single most common source of high-severity browser CVEs.

**Types eliminate aliasing-via-cast.** OCaml's type system is sound:
every value has one statically known type, and there is no way to
"reinterpret" a value of one type as a value of another from within
safe code. The C `union`, the `void*` cast, the strict-aliasing
violation, the type-confusion CVE: all of these are simply
unexpressible. (The `Obj` module gives an unsafe escape; we cover
when that matters in [M10-L04](M10-L04-where-ocaml-has-ub.html).)

**Exhaustive pattern matching catches null-deref.** The `option` type
is the canonical case: every consumer of a value-that-might-be-
absent has to handle both `Some _` and `None`. The compiler warns
about non-exhaustive matches; turning that warning into an error is
common practice. The null-dereference CVE is not a category in OCaml
code.

**Immutability by default reduces aliasing surprises.** Values in
OCaml are immutable unless explicitly marked otherwise. Most data
structures the application builds (lists, records, variants, tuples)
cannot be mutated, so reasoning about whether some other piece of
code might have changed your value while you weren't looking is
unnecessary. We saw this in
[M03-L02](M03-L02-recursion.html) and through Module 4.

A handful of caveats are honest. OCaml has *some* internal UB,
mostly in `Obj`, in `Marshal`, and in races on `ref` cells under
multicore. [M10-L04](M10-L04-where-ocaml-has-ub.html) covers them;
the standard advice is to avoid those features in security-sensitive
code, or to wrap them in audited library boundaries. Neither
caveat undermines the basic claim: OCaml's TCB-relevant memory
properties are dramatically better than C's, and the categories of
bugs that drive the 70/80/90 percent statistics are essentially
impossible in safe OCaml.

:::slide

## Memory safety in OCaml (reprise from M10)

- **GC**: no `free`, no use-after-free, no double-free.
- **Type system**: no aliasing-via-cast, no type confusion.
- **Pattern matching**: exhaustive; the null-deref CVE is not a
  category.
- **Immutability by default**: less aliasing to reason about.

Honest caveats: `Obj.magic`, `Marshal`, ref races. Covered in
[M10-L04](M10-L04-where-ocaml-has-ub.html).

:::

## OCaml is pragmatic

Memory-safe languages exist on a spectrum, and the academic ones are
underrepresented in industry. OCaml is not academic in that sense.
Tens of millions of dollars of revenue depend on OCaml every day, in
domains ranging from finance to compilers to security to web search.

It is worth naming some industrial users, partly because their
existence is the answer to "is this just a research toy?":

- **Jane Street.** Probably the single largest deployment of OCaml in
  the world. Operates one of the largest equities trading
  operations on Wall Street; reportedly about 20 percent of Wall
  Street trade volume passes through systems written in OCaml.
  Maintains a fork of the compiler (which is the basis of OxCaml,
  the subject of Module 11) and contributes much of the upstream
  ecosystem.
- **Tarides.** Pure-OCaml engineering shop responsible for much of
  modern MirageOS, the Irmin storage layer, and the
  OCaml-multicore project.
- **Bloomberg.** Internal financial-analytics infrastructure.
- **Ahrefs.** SEO crawling and analytics infrastructure at scale.
- **Docker.** The original `docker` CLI for Mac was an OCaml program
  using a MirageOS-derived networking stack.
- **Tezos.** A production blockchain whose entire core protocol is
  written in OCaml.
- **Facebook (Meta).** Multiple internal tools, including the Hack
  type-checker, the Flow type-checker for JavaScript, the Pyre
  type-checker for Python, and Infer (the static analyser
  originally from the FBInfer team), all OCaml.
- **Semgrep.** A widely-used code-analysis tool implemented largely
  in OCaml.
- **SimCorp, Microsoft (parts of F\* and Lean tooling), CompCert
  (the formally verified C compiler).** And more.

This list matters because production OS work is hard, and using a
language that *only* exists in research labs would be a serious
maintenance risk. OCaml is not that language. It has a 30-year
industrial track record, a maintained compiler with regular releases,
a stable foreign-function interface, a working build system (dune), a
package manager (opam), and a community of professional engineers.

:::slide

## OCaml is industrial

- **Jane Street**: ~20% of Wall Street trade volume goes through
  OCaml.
- **Tarides**: maintains MirageOS, Irmin, ocaml-multicore.
- **Bloomberg, Ahrefs, Docker, Tezos, Meta** (Hack, Flow, Pyre,
  Infer), **Semgrep, SimCorp, CompCert, F\*, Lean tooling**,
  and more.
- Working FFI to C, native code on x86 / ARM / Power / RISC-V,
  JavaScript and WebAssembly backends.
- Not a research toy.

:::

## Performance: in the same league as C

The performance argument for staying in C is real but smaller than it
used to be. OCaml's native compiler produces straight-line machine
code at a quality that is in the same neighbourhood as C compiled
with `-O2`. For algorithmic workloads (parsers, evaluators, graph
algorithms, numerical kernels), the publicly available cross-language
shootouts (the
[Benchmarks Game](https://benchmarksgame-team.pages.debian.net/benchmarksgame/index.html),
academic and industrial micro-benchmarks of similar shape) typically
place OCaml within a 1.5x-2x window of equivalent C, with the exact
multiplier depending heavily on the workload. Java and Go are in the
same league. Python is typically 10x to 100x slower. Treat the "1.5x
to 2x" as the rough order of magnitude, not a precise figure.

Two facts soften the OCaml-vs-C gap:

1. **OCaml's GC is tuned for low latency.** A well-written OCaml
   program with normal allocation patterns has GC pauses in the
   millisecond range, often sub-millisecond. For the very large
   majority of server workloads, including network services, this is
   well below the tail-latency budget. The famous quote from the
   ocaml-multicore developers is that "if your application can
   tolerate 1 ms of latency, OCaml is a good fit." That covers
   roughly 95 percent of the code most engineers write.
2. **OCaml has a fast FFI to C.** For the small unsafe core where C
   really is the right answer (cryptographic primitives that need
   constant-time operations, raw hardware DMA descriptors, a few
   numerical libraries), OCaml lets you call C functions with very
   low overhead. The FFI's calling-convention is well documented
   and stable; entire libraries can be wrapped without rewriting
   any C.

The combined picture is: OCaml is fast enough that the performance
argument almost never decides against it for safety-relevant code,
and where speed truly matters in the inner loop, you can drop into C
through the FFI without giving up safety in the rest of the program.

:::slide

## Performance

- OCaml is typically **1.5x to 2x slower than C** on algorithmic
  workloads.
- Java and Go are in the **same league**.
- Python is **10x to 100x slower** than C.
- GC tuned for **low latency**: sub-millisecond pauses are normal.
  *"If your application can tolerate 1 ms of latency, OCaml is a
  good fit."*
- **Fast FFI to C** for the small unsafe core.

:::

## Concrete benchmark: HTTP servers

It is one thing to say "fast enough"; it is another to show numbers.
A useful concrete case is HTTP-serving throughput, because it is the
canonical workload for a server unikernel.

The benchmark to look at is from the ocaml-multicore eio project. It
compares several HTTP server implementations under increasing
synthetic load (requests/second offered) and measures *serviced*
requests per second:

- **`httpaf_eio`**: OCaml, httpaf parser, ocaml-multicore eio
  runtime. The modern recommended OCaml stack.
- **`httpaf_lwt`**: OCaml, httpaf parser, classic Lwt (cooperative
  thread library, single-core).
- **`httpaf_effects`**: OCaml, httpaf parser, direct effect-handler
  runtime.
- **`cohttp_lwt_unix`**: OCaml, cohttp (older HTTP library) with
  Lwt. The "old way" of writing an OCaml HTTP server.
- **`rust_hyper`**: Rust, the `hyper` library. The state-of-the-art
  Rust HTTP server.
- **`nethttp_go`**: Go, the standard library `net/http`.

The shape of the result, as measured by the ocaml-multicore eio
team's harness around 2023-2024 (full numbers in the talk's slide
26; absolute numbers will drift over time as the libraries are
tuned, but the relative ordering has been stable):

| Stack | Peak serviced requests/sec | Position |
| --- | --- | --- |
| `httpaf_eio` (OCaml) | ~200,000 req/s | best |
| `rust_hyper` (Rust) | ~175,000 req/s | second |
| `httpaf_lwt` (OCaml) | ~120,000 req/s | mid |
| `httpaf_effects` (OCaml) | ~115,000 req/s | mid |
| `cohttp_lwt_unix` (OCaml) | ~62,000 req/s | low |
| `nethttp_go` (Go) | ~53,000 req/s | low |

A few observations from this chart are worth pulling out:

- The fastest OCaml stack outperforms Rust's mainstream HTTP
  library on this benchmark, at around 200k req/s versus 175k.
- The fastest Rust HTTP library outperforms most of the OCaml
  field. Rust is in the same performance bracket; this is not a
  story of OCaml beating Rust by an order of magnitude.
- Go is *slower* than every OCaml option here. The single-language
  generalisation "managed languages are slow" does not hold up to
  the numbers.
- Old-style OCaml (`cohttp_lwt_unix`) is at the bottom alongside
  Go. Modern OCaml (`httpaf_eio`) is the chart-topping
  implementation.

The takeaway is not "OCaml is the fastest HTTP server"; it is *"OCaml
is in the same competitive bracket as Rust on the same kind of
workload, and far above Python or Node."* That is the performance
budget MirageOS gets to spend on safety.

:::slide

## Web-server benchmark (talk slide 26)

```
~200k r/s  httpaf_eio        (OCaml + eio)
~175k r/s  rust_hyper        (Rust)
~120k r/s  httpaf_lwt        (OCaml + Lwt)
~115k r/s  httpaf_effects    (OCaml direct effects)
 ~62k r/s  cohttp_lwt_unix   (OCaml older stack)
 ~53k r/s  nethttp_go        (Go stdlib)
```

- The best OCaml stack **beats Rust Hyper** here.
- The OCaml-old vs OCaml-modern spread is **3x**: ecosystem
  matters.
- Go's stdlib HTTP is slower than all of these. "Safe = slow" is
  not true.

:::

## The unsafe core

Even safe languages need an unsafe core. The reasons are
unavoidable: hardware-level operations, cross-language interop, and
performance-critical inner loops sometimes require leaving the safe
world. The honest design choice is not "no unsafe code" but "a small,
audited unsafe core, with the rest of the system in the safe
language."

OCaml's unsafe escape hatches are:

- **`Obj`**, the module that lets you cast between OCaml types. The
  whole language deliberately makes `Obj` ugly to use, both by name
  ("if you find yourself reaching for `Obj`...") and by API.
- **FFI to C**, with `external`. Functions declared `external` can
  call into C; the safety of the call depends on the C code on the
  other side.
- **The runtime itself**, written in C: the GC, the I/O wrappers,
  the threading primitives. This is the equivalent of the JVM's
  C++ core.

For MirageOS, the unsafe core is the OCaml runtime (~30,000 lines
of C, maintained by the upstream OCaml team) plus a small set of
audited FFI calls into Solo5 (~5,000 lines of C, maintained by the
Solo5 project) and into the cryptography library (a few hundred lines
of carefully-audited C extracted from Coq, which we will see in
[M12-L05](M12-L05-mirageos.html)). The C surface of a MirageOS
unikernel is on the order of 40,000 lines, compared with Linux's
30 million. Three orders of magnitude smaller. Same memory-safety
risk per line of C, but a thousand times less C.

:::slide

## A small, audited unsafe core

- **OCaml runtime in C**: ~30k lines, maintained upstream.
- **Solo5 in C**: ~5k lines, maintained by the Solo5 project.
- **Audited crypto C** (Fiat-Crypto extraction, see M12-L05): low
  hundreds of lines.

Total **TCB-C ~ 40,000 lines**, vs Linux's **~30,000,000**.

**Three orders of magnitude smaller.**

:::

## Activity

:::quiz mcq id=M12-L04-q1
According to the industry reports we covered, what proportion of
high-severity security bugs in major C/C++ codebases (Microsoft,
Chromium, Android) have been memory-safety issues over the past
decade?

- [ ] About 10 percent.
- [ ] About 30 percent.
- [x] About 70 to 90 percent, depending on the codebase.
- [ ] About 50 percent, evenly split between memory safety and
  logic bugs.

**Why:** Microsoft reports ~70%, Chromium ~70%, Android ~90%, Fish-
in-a-Barrel reports ~80% of exploited 0-days. The proportion has
been stable for over a decade despite enormous investment in static
analysis, fuzzing, and sandboxing of C code. This empirical
floor is the engineering case for memory-safe languages at the OS
level.
:::

:::quiz mcq id=M12-L04-q2
On the HTTP server benchmark from the talk, which best describes the
relative performance of the fastest OCaml stack (`httpaf_eio`) and
the leading Rust stack (`rust_hyper`)?

- [ ] Rust Hyper is about 10x faster.
- [ ] Rust Hyper is about 2x faster.
- [ ] They are roughly tied, with Rust slightly faster.
- [x] OCaml httpaf_eio is slightly faster (~200k vs ~175k
  req/s), and both are far above Go's standard `net/http`.

**Why:** the chart in the talk's slide 26 shows OCaml's modern
stack peaking around 200k requests/second, just above Rust Hyper's
~175k, and both substantially above Go's ~53k. The headline result
is not that OCaml dominates Rust everywhere, but that the modern
OCaml stack is in the same competitive bracket. Performance is not
the reason to avoid OCaml at the OS layer.
:::

:::slide

## Activity discussion

- **70-90% of high-severity CVEs** in major C/C++ codebases are
  memory-safety bugs. Stable for over a decade.
- OCaml's HTTP throughput is **competitive with Rust** and far
  above Go's stdlib.
- The performance argument for staying in C, at the OS layer, is
  weaker than the safety argument against it.

:::

## Common pitfalls

**Pitfall 1: "Memory safety means no performance."** Not in 2026.
OCaml, Rust, modern Java, and Go are all within a small constant
factor of C for serious workloads. The HTTP benchmark above is one
data point of many. Python is the outlier, and Python's slowness has
nothing to do with memory safety per se.

**Pitfall 2: "If we just write better C, we don't need a safe
language."** Decades of investment in static analysis, fuzzing,
sanitisers, and code review have not moved the 70-percent CVE number
in mature C codebases. The empirical evidence is that "be more
careful" does not scale.

**Pitfall 3: "FFI defeats memory safety."** It is a real attack
surface, but the relevant question is its *size*. MirageOS's total
FFI-into-C surface is a few thousand lines, all audited; that is
small enough to keep under control. The point is not that the
unsafe surface is zero, it is that it is small.

**Pitfall 4: "Rust would be better."** Rust is also fine; it is in the
same memory-safe-languages bucket. The reason MirageOS is in OCaml is
partly historical (the Cambridge / Tarides community), partly
ecosystem (the existing libraries listed in
[M12-L05](M12-L05-mirageos.html)), partly the natural fit between
OCaml's GC and the kind of long-running server workloads MirageOS
targets. Both languages exist; neither needs to be wrong for the
other to be right.

## What's next

We have now seen the three ingredients separately. The last lecture,
[M12-L05](M12-L05-mirageos.html), puts them together: MirageOS as the
sum of library OS plus virtualisation plus OCaml, with a walk-through
of the compiler pipeline (`config.ml` to `mirage configure` to `dune
build` to a static ELF binary), the available libraries, the TLS
story (Coq-extracted crypto, "rigorous engineering"), and a Hello
Unikernel code excerpt.

:::slide

## What's next

- Lecture 5: **MirageOS = Library OS + Virtualisation + OCaml.**
  - The compiler pipeline.
  - The library catalogue (network, storage, security, crypto).
  - TLS as rigorous engineering.
  - A Hello Unikernel example.
- This module **closes the course**: from M01's type system to
  M12's whole-OS application. Safety, all the way down.

:::

## Reading

- **White House ONCD**, *Press Release: Future Software Should Be
  Memory Safe*, 26 Feb 2024:
  <https://bidenwhitehouse.archives.gov/oncd/briefing-room/2024/02/26/press-release-future-software-should-be-memory-safe/>
- **CISA / NSA / FBI / international partners**, *The Case for Memory
  Safe Roadmaps*, Dec 2023:
  <https://www.cisa.gov/resources-tools/resources/case-memory-safe-roadmaps>
- **ocaml-multicore eio**, repository home:
  <https://github.com/ocaml-multicore/eio>
- **OCaml's industrial users**, a working list from the OCaml
  community:
  <https://ocaml.org/industrial-users>

## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. The structural argument (memory safety stats, White
House / CISA citations, OCaml's industrial pedigree, the web-server
benchmark) follows KC Sivaramakrishnan's January 2025 IIT Madras
talk *Towards smaller, safer, bespoke OSes with Unikernels*, slides
19 to 26. The memory-safety statistics are drawn from public
industry reports (Microsoft 2019, Chromium 2020, Android, Fish in
a Barrel) that we covered with citations in
[M10-L02](M10-L02-memory-bugs-as-security.html). See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
