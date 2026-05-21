---
title: "Undefined behaviour and the C memory-safety zoo"
lecture_no: 1
week: 10
duration_target_min: 25
concepts: [undefined behaviour, memory safety, use-after-free, buffer overflow, double-free, uninitialised read]
keywords: [OCaml, undefined behaviour, UB, memory safety, CVE, security, C]
activity_question: "What is the difference between *unspecified*, *implementation-defined*, and *undefined* behaviour in C? Which one is the dangerous one, and why?"
think_about_this: "If a C program has undefined behaviour on some input, the compiler is allowed to assume that input never occurs and optimise accordingly. What does that mean for code that worked yesterday and miscompiles tomorrow?"
reading:
  - title: "John Regehr, A Guide to Undefined Behavior in C and C++"
    url: https://blog.regehr.org/archives/213
  - title: "Microsoft Security Response Center, a proactive approach to more secure code"
    url: https://msrc.microsoft.com/blog/2019/07/a-proactive-approach-to-more-secure-code/
---

# Undefined behaviour and the C memory-safety zoo

Nine modules of OCaml have built up an intuition that, when your
program type-checks, certain whole classes of bugs simply cannot
happen. You have not seen a segmentation fault. You have not seen a
"use-after-free." You have not seen a buffer overflow. That is not
because we were careful; it is because the language rules them out
by construction.

This module asks: *what exactly are those classes of bugs?* To answer
honestly, we have to look at the canonical unsafe language, which is
C, and survey the family of memory bugs that real C programs write
every day and ship to production. The five lectures of this module
build, in order, to "and here is precisely how OCaml's design
eliminates each of these by construction." But to make that
argument credible, we first need a precise account of what we are
eliminating.

This first lecture has two halves. First, what *undefined behaviour*
means as a formal concept, why it is dangerous, and why compilers
choose to make it so. Second, the four canonical memory-safety bugs
in C, with one widely-reported real-world incident per bug class so
you can see what each looks like in the wild. The lecture is
deliberately C-heavy; that is what the rest of the module is
contrasting against.

:::slide

## Where we are

- Eight modules of OCaml safety: types catch type errors;
  pattern matching forces case-handling; GC eliminates lifetime
  questions.
- Module 10 asks: *what exactly* does OCaml rule out?
- To answer that, we look at the canonical unsafe language, **C**,
  and survey the memory bugs it admits.
- Next two lectures: how memory bugs become CVEs, then how OCaml
  rules them out by construction.

:::

## What "undefined" means

The C standard distinguishes three related but importantly different
kinds of "we are not telling you exactly what this does":

1. **Unspecified behaviour.** The standard lists several possible
   behaviours and lets the implementation pick one, without
   requiring documentation. Example: the order of evaluation of
   subexpressions inside `f(g(), h())` is unspecified; the compiler
   may call `g` before `h` or `h` before `g`, and either is legal.
2. **Implementation-defined behaviour.** The implementation must
   pick a behaviour from a documented set, and document its choice.
   Example: the size of `int`, or whether right-shift of a negative
   integer is arithmetic or logical, is implementation-defined.
3. **Undefined behaviour.** The standard places *no* requirement on
   what the program does. The program is said to have no defined
   meaning at all.

The first two are awkward but manageable: a portable C program
avoids relying on unspecified order, and consults the
implementation manual where it must depend on
implementation-defined choices. The third, undefined behaviour, is
qualitatively different. It is the dangerous one.

:::slide

## Three flavours of "this is not quite specified"

| Flavour | What the standard requires | Example |
| --- | --- | --- |
| **Unspecified** | Pick from a list, no documentation | Order of arg evaluation in `f(g(), h())` |
| **Implementation-defined** | Pick from a list, **document the choice** | `sizeof(int)`, signedness of `char` |
| **Undefined** | *No requirement at all* | Dereferencing `NULL`, signed overflow, use-after-free |

**Only the third one is the real problem.** It is the spine of
this whole module.

:::

The reason undefined behaviour is qualitatively different is that
the compiler is allowed to *assume* it does not happen. A modern C
compiler does not check, at runtime, "did you just trigger UB?"
because the standard says you cannot. Instead, the compiler
*propagates* this assumption backwards through its optimisation
passes, frequently in ways that the programmer did not anticipate.

A famous category-of-jokes goes: "if your program has undefined
behaviour, the compiler is allowed to format your hard drive, send
your browsing history to the NSA, or summon nasal demons." That is
funny, but slightly misleading; in practice, the compiler does not
actively try to misbehave. What it does is much subtler: it
optimises code on the *assumption* that UB never occurs, and the
resulting program then does something the programmer did not
intend. The end result, from the perspective of someone debugging
the resulting failure, looks like the compiler "misbehaving"; the
compiler's defence is that the source program was already broken.

## A concrete UB-driven miscompile

Consider this C function, simplified from a real Linux kernel
patch:

```c
struct sock *tun = ...;
struct sock *sk = tun->sk;
if (!tun) return POLLERR;
return POLLIN;
```

A C programmer reads this as: read `tun->sk` into `sk`, then check
whether `tun` is null; if it is null, return an error, otherwise
return the OK code. The intent is defensive: even if `tun` is null,
the program returns a clean error rather than crashing.

Now read what the *compiler* sees. On line 2, the code dereferences
`tun` (to read `tun->sk`). The C standard says dereferencing a null
pointer is undefined behaviour. The compiler concludes that, since
the program is well-defined, `tun` *cannot have been null* at line
2; if it were, the dereference would have been UB and the program
would have no defined meaning, which by assumption it does. Working
backwards, by line 3, `tun` is *known to be non-null*. Therefore
the test `if (!tun)` is dead code: it can never be true. The
compiler removes the check.

The "defensive" null check is silently deleted. The bug appears
later, when an attacker arranges for `tun` to actually be null, the
function tries to compute `tun->sk` (UB, but the program runs
anyway, reading some bytes from address 0 or its vicinity), the
function then returns `POLLIN` as if everything were fine, and the
caller proceeds with a corrupted view of the world. This was
[CVE-2009-1897](https://nvd.nist.gov/vuln/detail/CVE-2009-1897), a
real Linux kernel vulnerability.

The conceptual move worth pausing on: the *source program* contains
UB (the dereference on line 2, in the hypothetical case `tun` is
null). The compiler is allowed to optimise on the assumption that
UB does not occur. The *miscompile* (deleting the null check) is
the consequence of that assumption. The bug is *not* a compiler
bug. The C standard makes this behaviour legal. The bug is in the
source code's reliance on UB: the programmer wrote a check that
runs *after* the dereference, and the C standard interprets the
dereference as a promise that the check is unnecessary.

:::slide

## "Defensive" code, miscompiled

```c
struct sock *tun = ...;
struct sock *sk  = tun->sk;     // dereferences tun
if (!tun) return POLLERR;       // dead code per the compiler
return POLLIN;
```

- The dereference on line 2 is UB if `tun` is null.
- Compiler deduces: `tun` cannot be null at line 2.
- Therefore the check at line 3 can never be true.
- Compiler **deletes the check**.
- Result: real null-pointer dereference at runtime
  (CVE-2009-1897).

**The bug is in the source, not the compiler.**

:::

This pattern, where a compiler optimisation under a UB assumption
deletes a check the programmer added on purpose, has been at the
root of many CVEs. There is now a small literature on it; John
Regehr's *A Guide to Undefined Behavior in C and C++*, linked at
the bottom of this lecture, is the canonical introduction.

## Why compilers cling to UB

If undefined behaviour is dangerous, why does the C standard have
it at all? Two reasons.

First, *performance*. C was designed to be a thin layer over the
hardware. Many CPU operations have different behaviours on different
platforms: integer overflow wraps on x86 but traps on some embedded
chips; unaligned loads are fast on x86 but illegal on older ARM; the
result of dividing by zero is a hardware exception on some platforms
and a defined value on others. If the C standard demanded one specific
behaviour for all of these, the compiler would have to insert checks,
or emulate the "wrong" behaviour, on every platform where the
hardware disagreed. By calling these *undefined*, the standard tells
the compiler "do whatever the hardware does, do not insert checks,
optimise aggressively."

Second, *optimisation*. Aggressive optimisations like loop
unrolling, dead-code elimination, and pointer-aliasing assumptions
all rely on knowing what the program is and is not allowed to do.
UB carves out cases the optimiser can assume away. A C compiler
that took every "could this be UB?" question at face value would
generate much slower code.

These are real reasons. C earned its place as the systems-programming
language partly because it lets you write code that runs nearly as
fast as hand-written assembly. The price is that the language gives
you many ways to write code that has no defined meaning, and the
compiler will silently optimise on the assumption that you did not.

## The categories of UB that matter

The C standard lists hundreds of specific UB cases. They cluster
into four broad categories:

1. **Memory.** Reading or writing memory the program does not own.
   This is the category the rest of this lecture surveys, because
   it is the category that becomes most of the world's CVEs.
2. **Integer and arithmetic.** Signed-integer overflow, division by
   zero, shifts by negative amounts, shifts by amounts larger than
   the width of the operand.
3. **Aliasing and concurrency.** Reading a value through a pointer
   of the wrong type (strict-aliasing violations); two threads
   touching the same memory without synchronisation (data races).
4. **Lifetime.** Using a pointer after the memory it points to has
   been freed, or after a stack frame has been destroyed.

This module's primary target is the first and the fourth. Lectures
M10-L02 through M10-L04 deal with them; Module M11 on OxCaml's
modes extends the toolkit to handle the second-and-a-half category
(stack-pointer escape, which is a special lifetime case).

:::slide

## Four UB categories

1. **Memory.** Reading or writing memory you do not own. *Most CVEs
   live here.*
2. **Integer and arithmetic.** Signed overflow, divide by zero,
   pathological shifts.
3. **Aliasing and concurrency.** Strict aliasing, data races.
4. **Lifetime.** Use-after-free, dangling pointers to stack.

**(1) and (4) host the four named memory bugs we survey next:
use-after-free, buffer overflow, uninitialised read, double-free.**

:::

## The memory-safety zoo

Within the memory-and-lifetime UB cluster, four named bugs come up
again and again in real systems. Each has a precise definition, a
representative real-world incident, and a class of CVEs named after
it.

### Use-after-free

In C, the programmer manually requests memory with `malloc` and
returns it with `free`. Once you call `free` on a block, the
allocator considers the memory available to hand out to the next
`malloc`. If you keep using the original pointer after that point,
you are reading bytes the program no longer owns.

A program allocates a block of memory, frees it, then accesses the
freed block again. From the C compiler's point of view, the
program "owns" that memory for an interval starting at `malloc` and
ending at `free`; reading or writing outside that interval is
undefined.

```c
char *buf = malloc(64);
strcpy(buf, "hello");
free(buf);
printf("%s\n", buf);   // UB: buf points to freed memory
```

Use-after-free is dangerous because, between the `free` and the
later use, the allocator may have reused that block for something
entirely different. The later access might see fresh data
unrelated to the original allocation; with attacker assistance, it
might see data the attacker arranged to place there. This is the
basis of *heap spraying*.

**Real-world incident.** The Chromium browser tracks the most
common cause of high-severity security bugs in its codebase; in
2020 the Chrome team reported that
[70 percent of those bugs were memory-safety issues, and roughly
half of those were use-after-free](https://www.chromium.org/Home/chromium-security/memory-safety/).
Use-after-free in browser engines turns into arbitrary code
execution with high reliability because browsers run in a single
process with broad capabilities.

### Buffer overflow

In C, arrays do not carry their length at runtime. A function that
copies bytes into a buffer trusts the caller to pass a length that
fits; if the caller miscomputes (or, in the security setting, the
attacker controls the length), the copy walks past the buffer's
end and overwrites whatever was next in memory.

A program writes past the end of an allocated buffer, corrupting
whatever memory happens to lie beyond. C's standard library is
infamous for functions like `strcpy` and `gets` that do no bounds
checking:

```c
char buf[16];
gets(buf);   // UB if the user types more than 15 chars
```

The bytes written past the end of `buf` may be other local
variables, return addresses on the stack, or heap metadata; an
attacker who controls what gets written can hijack the program's
control flow.

**Real-world incident.** The canonical buffer-overflow CVE is
**Heartbleed** (CVE-2014-0160), a vulnerability in OpenSSL where a
length field in the TLS heartbeat message was used to copy bytes
from a buffer without checking whether the length matched the
buffer's actual size. An attacker could request up to 64 KB of the
server's memory per request, leaking private keys and session
tokens. Heartbleed affected an estimated two-thirds of all HTTPS
servers on the public internet; the cleanup took years.

The Heartbleed code in OpenSSL was technically *out-of-bounds read*
rather than out-of-bounds write; both are buffer-overflow bugs, and
both are UB under the C standard.

### Uninitialised read

A C variable, when allocated, contains whatever bytes happened to
be at that memory location from its previous use. Reading the
variable before assigning to it returns those leftover bytes; this
is undefined behaviour, even though the read does not corrupt
anything.

```c
int x;
printf("%d\n", x);   // UB: x is uninitialised
```

The danger is subtler than the other categories: an uninitialised
read does not crash and does not corrupt memory directly. It just
silently returns whatever bytes were left over from a previous
allocation. If those bytes happened to encode a secret (a session
key, a password, a memory address that defeats ASLR), the read
leaks the secret.

**Real-world incident.** Uninitialised-memory leaks are
catastrophic when they happen in OS kernels, because the kernel
sees secrets from every process. A class of CVEs around 2015 to
2018 found uninitialised reads in Linux kernel networking code
leaking kernel-stack contents to userspace via padding bytes in
network packet structures; one example is
[CVE-2017-7472](https://nvd.nist.gov/vuln/detail/CVE-2017-7472).

### Double-free

A program frees the same block twice. The second `free` is
undefined; in practice it corrupts the allocator's bookkeeping
data structures, often in ways an attacker can exploit to make a
future `malloc` return a pointer to memory the attacker chose.

```c
char *buf = malloc(64);
free(buf);
free(buf);   // UB: double-free
```

**Real-world incident.** Double-frees are common enough that glibc
added a runtime check in 2017 for the simplest cases ("tcache
double-free"), which fires an `*** double free detected ***`
message and aborts. The check is partial, however; sophisticated
double-frees still pass through. CVE-2021-3711 in OpenSSL is a
recent example: a double-free in SM2 decryption led to a heap
corruption that an attacker could weaponise.

:::slide

## The four canonical memory bugs

| Bug | What | Famous incident |
| --- | --- | --- |
| **Use-after-free** | Access memory after `free` | Chromium: 36% of high-severity bugs |
| **Buffer overflow** | Read or write past allocated end | Heartbleed (CVE-2014-0160) |
| **Uninitialised read** | Read memory you have not written | Linux kernel info-leaks (e.g. CVE-2017-7472) |
| **Double-free** | Free the same block twice | OpenSSL SM2 (CVE-2021-3711) |

Each is **undefined behaviour** under the C standard.
Each has produced thousands of CVEs.

:::

These four categories are not exhaustive, but they cover the
majority of memory-safety CVEs in the wild. Microsoft's Security
Response Center reported in 2019 that *roughly 70 percent of all
high-severity bugs across Microsoft products were memory-safety
issues*; the Chromium team has reported the same proportion;
Google's Android team has reported around 90 percent for native
code. These numbers have been stable across multiple years and
multiple codebases. We will return to them, with the original
charts, in [the next lecture](M10-L02-memory-bugs-as-security.html).

## How OCaml stands

You may already be ahead of me on this. Every bug in this lecture
is impossible in safe OCaml, by construction:

- **Use-after-free**: OCaml has no `free`. The garbage collector
  reclaims memory only after every reference to it has gone out of
  scope. By the time the GC frees a block, no part of the program
  holds a reference to it; "after free" is meaningless.
- **Buffer overflow**: indexing into a `string`, `bytes`, or `array`
  raises `Invalid_argument` at the offending index, not a memory
  write past the end. The bounds check is mandatory; you cannot
  opt out of it from safe code.
- **Uninitialised read**: every binding in OCaml is initialised at
  the point of binding; there is no `let x : int = (* later *)` in
  the language. The closest you can get is `ref None` plus an
  explicit `Some _` assignment, which still type-checks the read
  against `option`.
- **Double-free**: no `free`, no double-free.

The next lecture, M10-L02, looks at *why* these matter so much in
production by walking through how each bug becomes a security
incident. M10-L03 then makes the OCaml side of the story precise:
*which* parts of the language rule each bug out, *where* in the
runtime the rule is enforced, and where the boundary is.

## Activity

:::quiz mcq id=M10-L01-q1
A C program contains this code, where `x` is a `signed int`:

```c
if (x + 1 < x) {
  printf("overflow happened!\n");
}
```

On a typical optimising compiler with `-O2`, what happens?

- [ ] The `printf` runs whenever `x` is `INT_MAX`.
- [x] The compiler removes the `printf` call entirely; it is never reached.
- [ ] The program crashes with an overflow error.
- [ ] The `printf` runs whenever `x` is `INT_MIN`.

**Why:** signed-integer overflow is undefined behaviour in C. The
compiler is allowed to assume it never occurs. Under that
assumption, `x + 1 > x` is always true, so the test `x + 1 < x` is
always false, and the body of the `if` is dead code. The compiler
removes it. This is a real category of miscompile that has produced
multiple CVEs (search for "signed overflow check optimised away" for
examples). The "right" way to write an overflow check in C is to
compare against `INT_MAX - 1` *before* the add, not to add and
check the result.
:::

:::quiz mcq id=M10-L01-q2
Which of the following bugs is *impossible* in safe OCaml?

- [ ] Forgetting to handle the empty-list case of a function.
- [x] Reading from memory that has already been freed.
- [ ] An infinite loop.
- [ ] Returning the wrong answer because of a typo in the code.

**Why:** OCaml's GC eliminates the lifetime question entirely:
memory is freed only when nothing reachable refers to it, so
"reading from freed memory" cannot occur in safe code. The other
three are all bugs OCaml's type system does *not* catch:
non-exhaustive matching warns but does not prevent compilation if
you opt out; infinite loops are not detected (and cannot be in
general; this is the halting problem); typos that type-check are
exactly the case for tests, which we covered in Module 9.
:::

:::slide

## Activity discussion

- The signed-overflow check is a real category of UB-driven
  miscompile. Compilers assume UB does not happen and optimise
  accordingly.
- Of OCaml's safety properties, the **lifetime** one (no UAF) is the
  most clearly impossible-by-construction. The others (no buffer
  overflow, no uninit read, no double-free) follow from the GC plus
  the bounds-checked stdlib.

:::

## Common pitfalls

A short list of misunderstandings about UB that come up in early
discussions of memory safety.

**Pitfall 1: "UB is a compiler bug."** It is not. The C standard
explicitly allows the compiler to do whatever it likes when UB is
triggered. The bug is in the source program. The compiler is
faithfully following the standard; the source is asking the
standard to make no promise.

**Pitfall 2: "If my program works on my machine, it does not have
UB."** Many UB-driven bugs are timing- or input-sensitive. A
program may "work" on every input you test, then fail on the
attacker's input. Worse, a UB-triggering line may "work" with one
compiler version and miscompile with the next, because the optimiser
got smarter.

**Pitfall 3: "Memory-safe languages are slow."** OCaml's native
compiler produces code typically within a small constant factor of
C; the GC adds a fraction of a percent overhead in most workloads.
The performance argument for C is real but small; the safety
argument against C is large.

**Pitfall 4: "Just be careful when writing C."** Multiple decades of
trying have not made the world's C codebases safer. The
[Microsoft 2019 report](https://msrc.microsoft.com/blog/2019/07/a-proactive-approach-to-more-secure-code/)
notes that 70 percent has been the steady-state memory-safety bug
proportion across many releases. "Be more careful" is not a working
mitigation at industry scale.

## What's next

We now have a precise catalogue of the bugs OCaml rules out.
[Module 10 Lecture 2](M10-L02-memory-bugs-as-security.html)
takes the same four bugs and asks the security question: how does
each become a CVE? What is the path from "use-after-free" to
"attacker runs arbitrary code on your server"? The argument that
memory safety is worth the engineering cost comes through that
path.

After that, [M10-L03](M10-L03-how-ocaml-rules-them-out.html) makes
the OCaml side precise: which language construct rules out which
bug, with code examples and a tour of the OCaml runtime where the
rules are enforced. [M10-L04](M10-L04-where-ocaml-has-ub.html) is
the honest boundary: the small set of places OCaml itself has UB
(`Obj.magic`, races on `ref`, certain `Marshal` flows).
[M10-L05](M10-L05-tutorial.html) is the tutorial, where we walk a
real CVE.

:::slide

## What's next

- Lecture 2: **memory bugs as security incidents**. The path from
  use-after-free to arbitrary code execution. The 70% / 80% / 90%
  numbers, with the original charts.
- Lecture 3: **how OCaml rules them out by construction.** The
  type-system and GC-level mechanisms, precisely.

:::

## Reading

- **John Regehr**, *A Guide to Undefined Behavior in C and C++*, a
  three-part series that is the canonical introduction to UB and
  its discontents:
  <https://blog.regehr.org/archives/213>
- **Microsoft Security Response Center**, *A proactive approach to
  more secure code* (the 70% report):
  <https://msrc.microsoft.com/blog/2019/07/a-proactive-approach-to-more-secure-code/>
- **The Chromium project**, *Memory safety*:
  <https://www.chromium.org/Home/chromium-security/memory-safety/>
- **Heartbleed** (CVE-2014-0160):
  <https://heartbleed.com/>

## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. Materials referenced during preparation are listed in
the *Reading* section above; in particular, John Regehr's UB guide
and the Microsoft/Chromium/Google industry reports are
public-domain or
permissively-licensed government / industry publications. The
CVE-2009-1897 worked example draws on a widely-circulated kernel
analysis. See [`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
