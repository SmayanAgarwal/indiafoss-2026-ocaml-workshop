---
title: "Memory bugs as security incidents"
lecture_no: 2
week: 10
duration_target_min: 25
concepts: [memory safety, CVE, exploit, heap spray, type confusion, return-oriented programming, ASLR, DEP, memory-safe roadmap]
keywords: [OCaml, memory safety, CVE, exploit, heap spray, ROP, ASLR, DEP, White House, CISA, memory safe roadmap]
activity_question: "If buffer overflows and use-after-free bugs have been understood for decades, and mitigations like ASLR and DEP exist, why has the proportion of memory-safety bugs in shipped software stayed at roughly 70 percent year after year?"
think_about_this: "What does it mean for a national cyber agency to publish, in 2023, an official document urging vendors to adopt memory-safe languages? When does a programming-language choice become a matter of policy?"
reading:
  - title: "Microsoft Security Response Center, A proactive approach to more secure code"
    url: https://msrc.microsoft.com/blog/2019/07/a-proactive-approach-to-more-secure-code/
  - title: "Chromium project, Memory safety"
    url: https://www.chromium.org/Home/chromium-security/memory-safety/
  - title: "White House ONCD, Future Software Should Be Memory Safe (February 2024)"
    url: https://bidenwhitehouse.archives.gov/oncd/briefing-room/2024/02/26/press-release-technical-report/
  - title: "CISA, NSA, FBI et al., The Case for Memory Safe Roadmaps (December 2023)"
    url: https://www.cisa.gov/resources-tools/resources/case-memory-safe-roadmaps
---

# Memory bugs as security incidents

The previous lecture catalogued the four canonical memory-safety
bugs in C: use-after-free, buffer overflow, uninitialised read,
double-free. Each is undefined behaviour. Each is something the
C standard explicitly does not promise to do anything sensible
with. That is the language-theoretic side of the story.

This lecture is the security side. It asks: *so what?* If a
program triggers undefined behaviour, the worst case is presumably
that the program crashes, which is bad but recoverable. Why is the
industry treating these bugs as a strategic risk worthy of policy
intervention from national cyber agencies?

The answer is that a memory-safety bug, in practice, is rarely
"just a crash." With modest attacker effort it becomes
*arbitrary code execution*: the attacker convinces your program
to start running code of their choosing, with your program's
privileges. Once that happens, every other security boundary in
the system has been bypassed.

We will spend this lecture walking that pipeline. First we look
at the industry numbers: how big is the memory-safety problem
across the actual codebases that run the internet? Then we walk a
concrete exploit pattern end-to-end, at the conceptual level,
without writing actual exploit code. Then we look at what the
existing partial mitigations buy us, and why none of them solve
the problem structurally. We finish with the policy turn: why
national cyber agencies now write public memos urging vendors to
move to memory-safe languages.

:::slide

## Roadmap

- The industry numbers: 70 / 80 / 90 percent.
- How a memory bug becomes arbitrary code execution.
- Partial mitigations: ASLR, DEP, stack canaries.
- The structural fix: memory-safe languages.
- The policy turn: White House 2024, CISA/NSA/FBI 2023.

:::

## The industry numbers

For most of the 2010s, the security-research community had a
running argument about whether memory-safety bugs were really
*that* dominant in modern shipping software. The argument ended
around 2019 when several large vendors independently published
the same number from their own internal data.

### Microsoft: 70 percent

In July 2019 the
[Microsoft Security Response Center published its first detailed
post-mortem](https://msrc.microsoft.com/blog/2019/07/a-proactive-approach-to-more-secure-code/)
on the kinds of bugs that became CVEs across Microsoft products.
The headline number from that report: *roughly 70 percent of all
high-severity bugs Microsoft assigned a CVE to were memory-safety
issues.* The remaining 30 percent were scattered across logic
errors, configuration mistakes, and cryptographic flaws.

The 70 percent number was not a one-year spike. The MSRC's data
went back twelve years and the proportion had stayed essentially
flat. Microsoft was, at that point, spending hundreds of millions
of dollars a year on tooling (static analysis, fuzz testing,
managed-code rewrites, SafeInt libraries, the SDL process), and
*the proportion of memory-safety bugs in their shipping products
had not moved.*

That is the moment the conversation shifted. If decades of
investment in better C tooling had not reduced the proportion, the
problem was not "we are not trying hard enough." The problem was
structural: the language permits these bugs, so they will keep
happening.

:::slide

## Microsoft MSRC, 2019

> Roughly 70 percent of vulnerabilities Microsoft assigned a CVE
> to are memory safety issues.

- Twelve years of data, proportion stable.
- Microsoft has spent hundreds of millions on C tooling.
- The proportion **has not moved**.
- Conclusion: "be more careful" does not work at industry scale.

:::

### Chromium: 70 percent (and the UAF pie)

Around the same time the Chromium project, the open-source codebase
behind Google Chrome, published its own analysis on the
[Chromium memory-safety
page](https://www.chromium.org/Home/chromium-security/memory-safety/).
Their headline number was indistinguishable from Microsoft's: 70
percent of high-severity security bugs in Chromium were memory
safety issues.

Chromium went further and broke down the memory-safety bugs by
sub-class. The pie chart, reproduced in many subsequent talks,
showed:

- *Use-after-free*: roughly 36 percent of all high-severity bugs
  (the largest single category).
- *Out-of-bounds reads and writes*: roughly 32 percent.
- *Other memory unsafety* (uninitialised use, double-free, type
  confusion): the remainder.

The 36 percent number for use-after-free alone is striking. UAF
is harder to reason about than buffer overflow, because it is
*temporal*: the buggy access is not in the wrong place spatially,
it is in the wrong place in time. The pointer is to a valid
address; that address simply no longer belongs to the program.
Static analysis can sometimes catch buffer overflows; UAF is much
harder to catch without runtime support.

:::slide

## Chromium, 2020

> 70 percent of high-severity security bugs in Chromium are
> memory safety bugs.

- About **36 percent** are use-after-free alone.
- About **32 percent** are out-of-bounds (read or write).
- Temporal bugs (UAF) are *harder* to find statically than
  spatial bugs (overflow).

:::

### Google Android: 90 percent of native vulnerabilities

In May 2021 the Google Android security team published
their own retrospective. The Android codebase is split: a large
amount of *managed* code (Java, Kotlin) plus a lower layer of
*native* code (mostly C and C++) for performance-sensitive
components and platform APIs. Bugs are reported in both layers,
but the security impact differs.

The Android headline number was *more than 90 percent of
vulnerabilities in the native (C/C++) code were memory safety
issues.* In the managed code, the proportion was negligible: the
JVM and Android Runtime catch the same classes of bugs at runtime
(bounds checks on arrays, null checks on dereferences,
garbage-collected lifetimes).

The implication of the 90 percent number is the cleanest demonstration
of the structural argument. The *same* organisation, with the
*same* engineering culture, shipping code in *two* languages, sees
memory-safety bugs concentrated entirely in the unsafe language.
The variable that explains the disparity is the language, not the
team's discipline.

:::slide

## Google Android, 2021

- > 90 percent of vulnerabilities in the **native** (C/C++)
  code are memory safety.
- Negligible in managed (Java / Kotlin) code in the same product.
- Same team, same culture, same release process.
- *The language is the variable that explains the disparity.*

:::

### Fish in a Barrel: 0-days in the wild

Project Zero (Google's offensive-security research group)
maintains a public spreadsheet of zero-day exploits observed being
used in the wild against real targets. A
project called *Fish in a Barrel* further classified those
0-days by root cause. As of 2023 the standing number is *roughly
80 percent of in-the-wild 0-days are memory-safety bugs.*

This is a smaller sample than the MSRC or Chromium data (zero-days
are rare), but it has a different selection bias: these are the
bugs *attackers actually chose to invest in*. If memory-safety bugs
were now rare or hard to exploit, attackers would have moved on.
They have not.

:::slide

## In-the-wild 0-days

- ~80 percent of observed 0-day exploits target memory-safety
  bugs.
- Source: *Fish in a Barrel* analysis of Project Zero data.
- These are bugs **attackers actually use**.
- They keep choosing memory-safety bugs because they keep working.

:::

So the headline numbers, repeated and cross-checked, are 70
percent of all CVEs at Microsoft, 70 percent at Chromium, 90
percent of Android native, 80 percent of in-the-wild 0-days. There
is no debate about magnitude.

Now to the second half of the question: why does a memory bug
become a security incident?

## From a memory bug to arbitrary code execution

A memory-safety bug, in isolation, looks innocuous. A use-after-free
returns garbage from a stale pointer. A buffer overflow scribbles a
few bytes past the end of an array. These are bad, but they sound
like reliability bugs, not security bugs. The reason they are
security bugs is that an *attacker who controls the program's
inputs* can choose what those bytes are and where they go, and
chain that into an exploit.

Let us walk one such chain. We will use a use-after-free in a
browser-like program as the running example, because the Chromium
data above identifies UAF as the single most exploited bug class.
The same shape generalises to buffer overflows.

### Step 1: the free

A program allocates an object; some asynchronous event (a callback,
a JavaScript timer, a network response) causes the object to be
freed; another part of the program still holds a pointer to that
object and uses it.

```c
struct widget *w = malloc(sizeof *w);
init_widget(w);
register_callback(w);

/* ... time passes; the callback fires; it calls free(w) ... */

w->draw(w);                /* UB: w now points to freed memory */
```

At the moment of `free(w)`, the allocator marks the block as
available for reuse. The bytes are still there; nothing has been
zeroed. The pointer `w` still holds the same numerical address. So
the next access through `w` does not crash.

:::slide

## Step 1: free, but pointer lingers

```c
struct widget *w = malloc(sizeof *w);
init_widget(w);
register_callback(w);

/* asynchronous callback fires, calls free(w) */

w->draw(w);  /* UB: address is still valid, content is stale */
```

- Memory marked free; bytes are not zeroed.
- Pointer `w` still holds the same numeric address.
- *The next access does not crash. That is the problem.*

:::

### Step 2: the heap spray

Between the `free` and the use, the attacker needs to arrange for
the freed memory to be re-allocated to *something the attacker
controls*. The technique is called *heap spraying*. The attacker
causes the program to allocate many small objects whose contents
are under attacker control: typically by, in a browser, allocating
many JavaScript strings or ArrayBuffers; in a server, by sending
many requests whose payloads end up in heap-allocated buffers.

The allocator's free-list is now full of attacker-controlled
blocks. Because heap allocators reuse recently-freed blocks
quickly (this is good for cache locality but bad for security),
when the attacker can predict or influence which block the
allocator hands out next, they can arrange for *their* bytes to
land in the location previously occupied by `widget *w`.

:::slide

## Step 2: heap spray

- Attacker forces many small allocations.
- Each block's content is attacker-controlled (string, buffer).
- Allocator hands these out from the freed region.
- *The bytes at `w` are now whatever the attacker chose.*

:::

### Step 3: type confusion

The original `widget` struct had a field `draw`, which was a
function pointer. The C compiler emitted `w->draw(w)` as: load
the word at offset 8 in the block `w` points to; call it as a
function.

After the heap spray, the bytes at offset 8 in that block are
*attacker-controlled bytes*. If the attacker put a chosen address
there, the call instruction jumps to that address. The control
flow of the program is now wherever the attacker pointed it.

```text
+--------------------+
| original widget    |
| draw  -> 0x401000  |   (legitimate code)
| state -> 0x600100  |
+--------------------+

  free(w)
  heap spray: attacker controls these bytes

+--------------------+
| attacker bytes     |
| draw  -> 0x7fff... |   (attacker-chosen address!)
| state -> ...       |
+--------------------+
```

This is sometimes called *type confusion*: the program reads
attacker-controlled bytes as if they were a `widget` struct, and
the C type system has no way to notice.

:::slide

## Step 3: type confusion

- `w->draw(w)` becomes: load the word at `*(w+8)`, call it.
- After heap spray, that word is attacker-chosen.
- Call instruction jumps to **attacker-chosen address**.
- C's type system has no way to notice.

:::

### Step 4: return-oriented programming

The next obstacle is *DEP* (data-execution prevention, sometimes
called NX or W^X), a hardware-level mitigation that marks data
pages as non-executable. The attacker cannot simply jump to bytes
they sprayed onto the heap, because those bytes live on a page
marked non-executable; the CPU will fault if the program tries to
execute them.

The workaround is *return-oriented programming* (ROP). Instead of
supplying new code, the attacker supplies a *sequence of return
addresses* that point into existing legitimate executable code,
each ending in a `ret` instruction. These short snippets, called
*gadgets*, are chained: each `ret` pops the next address off the
stack and jumps there. The attacker assembles a payload entirely
from existing instructions, but in an order the original
programmer never intended.

A ROP chain can be Turing-complete: any computation the attacker
wants can be expressed as a sequence of gadgets. Common chains
end by calling `system("/bin/sh")` or by mapping a fresh page as
executable and copying the attacker's actual shellcode into it.

:::slide

## Step 4: return-oriented programming (ROP)

- DEP prevents executing data pages.
- Solution: do not execute new code; *reuse existing code*.
- A *gadget* is a short instruction sequence ending in `ret`.
- A *ROP chain* is a stack of gadget addresses.
- Each `ret` jumps to the next gadget.
- Chain is Turing-complete; ends in `system("/bin/sh")` or
  similar.

:::

### Step 5: payload

At the end of the chain, the attacker has the program executing
code of their choosing in the program's address space, with the
program's privileges. From here, what they do is up to them:
exfiltrate data, install a rootkit, pivot into the rest of the
network, mine cryptocurrency. The damage is no longer constrained
by anything the program's author intended.

This is the path from "a freed pointer was used" to "an attacker
runs arbitrary code." The chain has five conceptual steps and
exists in essentially every real-world exploit. The Chromium UAF
bugs, the OpenSSL Heartbleed disclosure, the various Linux-kernel
LPE exploits, the iOS browser sandbox escapes: all follow this
shape with local variation.

:::slide

## End of the chain

- Attacker is executing chosen code, with the program's
  privileges, inside the program's address space.
- All other security boundaries are now bypassed.
- *This is the steady state for every UAF and overflow exploit
  in the wild.*

:::

## Partial mitigations and why they are partial

The security community has not been idle. Several mitigations
have been deployed at the OS, compiler, and hardware level. Each
makes exploitation harder; none eliminate it.

**ASLR (Address Space Layout Randomisation).** Loads the program,
libraries, and stack at randomised addresses each run, so the
attacker cannot hard-code addresses into a payload. ASLR adds
roughly 20 to 30 bits of entropy on a 64-bit system. It is
defeated routinely by *information disclosure*: an attacker who
can read a few bytes of memory (a separate, lesser bug) recovers
a code-section address and computes the offset to everything
else. Heartbleed itself was an information-disclosure bug;
chained with a UAF it could defeat ASLR and proceed to RCE.

**DEP / NX / W^X.** Marks data pages non-executable. Defeated by
ROP, as above. Existed since the mid-2000s; ROP was developed in
response by 2007.

**Stack canaries.** A random value placed between local variables
and the stack frame's return address; checked before `ret`. A
buffer overflow that overruns local variables will corrupt the
canary first, and the check will trip. Defeated by:
information-disclosure (read the canary, write it back); by
overflows that skip the canary (writing only specific bytes via
format-string bugs); and by attacks that target heap rather than
stack.

**Control-Flow Integrity (CFI), Intel CET, ARM PAC, etc.**
Newer hardware-assisted mitigations that constrain the set of
addresses a control-flow instruction can transfer to. They raise
the bar significantly but do not close it. Each year sees new
research showing how a sufficiently capable attacker can chain
around them.

The pattern across all of these: each mitigation costs the
attacker some additional engineering, and each is eventually
defeated by another layer of bug or a more careful payload. The
attacker's economics are: pay the additional engineering cost
once, then exploit thousands of installations. The defender's
economics are: pay the mitigation's runtime cost on every
installation, every day, forever, and hope the attacker has not
got around it yet.

:::slide

## Partial mitigations

| Mitigation | What it does | Defeated by |
| --- | --- | --- |
| ASLR | Randomises addresses | Info-disclosure bugs |
| DEP / NX | Non-executable data | ROP |
| Stack canaries | Detects stack overflow | Info-disclosure; heap attacks |
| CFI / CET / PAC | Constrains control flow | Research keeps chipping away |

**Each is partial. Each costs runtime. None close the class.**

:::

The economics never balance. After three decades of layered
mitigations, the MSRC's 70 percent number has not moved. The
mitigations slow attackers down; they do not stop the bugs from
shipping.

## The structural fix: a memory-safe language

The structural fix is to write the program in a language where
the bugs in question *cannot be expressed*. That is the entire
point of memory safety as a language property. The compiler and
runtime are responsible for the invariants; the programmer cannot
violate them even if they try.

This is the connection to
[Module 1 Lecture 2](M01-L02-why-fp.html). That lecture made the
argument for functional programming as *safety by design*: pure
functions and immutable data eliminate entire categories of bugs
not by being careful but by removing the syntactic means to write
them. The memory-safety argument is the security-flavoured version
of the same argument. Eliminate UAF by removing `free`. Eliminate
buffer overflow by mandating a bounds check on every access.
Eliminate uninitialised read by requiring binding-time
initialisation. Eliminate double-free by removing `free`.

We do not need to be careful. We need the language to make the
unsafe operation un-writable.

:::slide

## Safety by design (callback to M01-L02)

- M01-L02: pure functions and immutability eliminate aliasing
  bugs by design.
- The security version: memory safety eliminates UAF, overflow,
  uninit, double-free *by design*.
- Compiler and runtime maintain the invariants.
- The unsafe operation is not in the surface language.

:::

[Lecture 3](M10-L03-how-ocaml-rules-them-out.html) lays out
exactly how OCaml does this. The remainder of this lecture
covers the policy turn that has made this argument operational.

## The policy turn

Until about 2022 the memory-safety argument was a technical
argument inside the security community. Around then it broke into
public policy.

### CISA / NSA / FBI: The Case for Memory Safe Roadmaps (December 2023)

In December 2023, a joint publication appeared from the US
Cybersecurity and Infrastructure Security Agency (CISA), the
National Security Agency (NSA), the FBI, and the cyber agencies
of the United Kingdom, Australia, Canada, and New Zealand. Five
national cyber agencies, on one document, urging software
vendors to publish *memory-safe roadmaps*: a public plan with
dates for moving each component of a vendor's product to a
memory-safe language.

The document is called
[*The Case for Memory Safe Roadmaps*](https://www.cisa.gov/resources-tools/resources/case-memory-safe-roadmaps).
Its argument compresses to: the proportion of memory-safety bugs
has not improved despite massive investment in C tooling; the
problem is structural; the only effective intervention is to
adopt a language that does not allow the bugs. Vendors should
plan, publicly and on a timeline.

Naming a list of "memory-safe languages" was part of the
publication. The list includes Rust, Go, Java, C#, Swift, Python,
JavaScript, and (relevant here) *the ML family, including
OCaml*. Each of these guarantees memory safety in the safe
fragment; each has a different mix of performance and
expressiveness trade-offs; the agencies took no position on
which to choose.

:::slide

## CISA / NSA / FBI, December 2023

> *The Case for Memory Safe Roadmaps*

- Five national cyber agencies: US, UK, AU, CA, NZ.
- Vendors should publish public roadmaps for migrating off
  memory-unsafe languages.
- Named memory-safe languages: Rust, Go, Java, C#, Swift,
  Python, JavaScript, **the ML family (including OCaml)**.
- No agency position on which to choose.

:::

### The White House: Future Software Should Be Memory Safe (February 2024)

Two months later the White House Office of the National Cyber
Director (ONCD) published
[*Future Software Should Be Memory Safe*](https://bidenwhitehouse.archives.gov/oncd/briefing-room/2024/02/26/press-release-technical-report/).
This is the same argument from a higher altitude: the federal
government, the largest single customer of commercial software
in the world, was on record saying that critical software should
move to memory-safe languages.

What is notable about both documents is the absence of hedging.
Earlier government cybersecurity writing tended to phrase such
recommendations as one of a portfolio of mitigations. The 2023
and 2024 documents do not. They identify the language choice as
the single highest-leverage intervention available.

:::slide

## White House ONCD, February 2024

> *Future Software Should Be Memory Safe*

- The federal government, the largest single software customer
  in the world.
- On record: critical software should move to memory-safe
  languages.
- No portfolio-of-mitigations hedging.
- *Language choice is the highest-leverage intervention.*

:::

This is the context in which an OCaml course in 2026 talks about
memory safety. It is not a niche technical concern. The largest
software vendors and the federal governments of the
English-speaking world have publicly named the problem. The
course's job here is to make the safety mechanism precise so you
can read those reports and know exactly what guarantees you are
buying.

## Activity

:::quiz mcq id=M10-L02-q1
Microsoft, Chromium, and Google Android have each published
analyses of memory-safety bug proportions in their codebases.
Which of the following best summarises the headline numbers?

- [ ] All three found memory-safety bugs to be a small minority
  of high-severity issues.
- [x] All three found memory-safety bugs to be the majority of
  high-severity issues: about 70 percent at Microsoft and
  Chromium, and around 90 percent in Android native code.
- [ ] Memory-safety bugs are a problem in operating-system code
  but not in user-space applications.
- [ ] The proportions have been steadily declining over the
  last decade thanks to better static analysis.

**Why:** the three vendors independently report the same shape
of result. Microsoft's MSRC reports about 70 percent of CVEs are
memory safety. Chromium reports the same. Google Android
reports over 90 percent in native C/C++ code, but negligible in
the managed (Java/Kotlin) layer of the same product. The
proportions have *not* declined despite very large investments
in C/C++ tooling, which is the central evidence for the
structural argument. The Android cross-language comparison is
the cleanest single demonstration that the language is the
variable.
:::

:::quiz mcq id=M10-L02-q2
The exploit pipeline for a use-after-free typically involves
several conceptual steps. Which of the following correctly
orders them?

- [ ] heap spray, type confusion, free, ROP, payload
- [x] free (pointer lingers), heap spray, type confusion, ROP,
  payload
- [ ] free, ROP, heap spray, type confusion, payload
- [ ] free, payload, heap spray, type confusion, ROP

**Why:** the chain starts with a `free` that leaves a dangling
pointer (the actual bug). The attacker then *heap-sprays* to
fill the freed region with attacker-controlled bytes. When the
program next accesses the dangling pointer, it interprets the
attacker's bytes as the original type (*type confusion*), often
following an attacker-chosen function pointer. To execute on a
DEP-protected system, the chain uses *return-oriented
programming* (ROP) to assemble execution from existing code
gadgets. The final *payload* runs whatever attacker code the
chain has bootstrapped.
:::

:::slide

## Activity discussion

- The 70/80/90 numbers are stable across vendors, codebases,
  and years. Not a sample bias; not a fad.
- The exploit chain is also stable: free, spray, confusion, ROP,
  payload. Variations exist but the shape is universal.
- ASLR, DEP, canaries raise the bar but do not close the class.

:::

## Common pitfalls

**Pitfall 1: "A crash is not a security bug."** It often is. A
crash on attacker-controlled input is, at minimum, denial of
service. It frequently turns into RCE under modest attacker
effort. The boundary between "crash" and "exploit" is engineering
effort, not nature.

**Pitfall 2: "The mitigations are good enough."** The mitigations
do real work (an attacker who finds an arbitrary-read bug and an
arbitrary-write bug separately must now chain them; ten years ago
they could ship either one as an exploit on its own). They also
cost runtime budget, and they do not close the class. The
MSRC's flat 70-percent line through twelve years of mitigations
is the evidence.

**Pitfall 3: "Memory-safe languages are too slow for security-
critical code."** OCaml's native compiler produces code typically
within a small constant factor of C. Several memory-safe
languages (Rust most prominently) target C-equivalent
performance with no GC, by trading away some expressiveness for
ownership-tracking. For most security-critical workloads the
performance argument is no longer the limiting factor.

**Pitfall 4: "Rewriting everything in a safe language is
impractical."** It is impractical to do all at once, which is
why the agency documents recommend *roadmaps*: move the most
exposed, most security-sensitive components first. New code in
a memory-safe language; old code with the highest exploit risk
rewritten on a priority order; the deep core can remain in C with
hardening for a long time.

## What's next

[Lecture 3](M10-L03-how-ocaml-rules-them-out.html) is where the
OCaml side of this story becomes precise. The four bug classes
from M10-L01: which language construct in OCaml rules each one
out, where in the runtime the rule is enforced, and what the
runtime overhead is. That is the lecture where the 63-bit-int
aside from [M02-L01](M02-L01-literals.html) finally pays off:
tagged pointers, block headers, the GC's job. After that,
[L04](M10-L04-where-ocaml-has-ub.html) is the honest boundary
(the places in OCaml that *do* admit UB), and
[L05](M10-L05-tutorial.html) is the tutorial that walks one
real CVE end to end.

:::slide

## What's next

- Lecture 3: **how OCaml rules them out by construction.** The
  GC for lifetimes, bounds checks for overflow, binding-time
  initialisation, no `free` for double-free. The runtime sketch.
- Lecture 4: where OCaml itself has UB. The honest boundary.
- Lecture 5: walk one real CVE end-to-end.

:::

## Reading

- **Microsoft Security Response Center**, *A proactive approach
  to more secure code*:
  <https://msrc.microsoft.com/blog/2019/07/a-proactive-approach-to-more-secure-code/>
- **The Chromium project**, *Memory safety*:
  <https://www.chromium.org/Home/chromium-security/memory-safety/>
- **Google Security Blog**, *Queue the Hardening Enhancements*
  (Android memory-safety analysis):
  <https://security.googleblog.com/2019/05/queue-hardening-enhancements.html>
- **White House ONCD**, *Future Software Should Be Memory Safe*
  (February 2024):
  <https://bidenwhitehouse.archives.gov/oncd/briefing-room/2024/02/26/press-release-technical-report/>
- **CISA / NSA / FBI et al.**, *The Case for Memory Safe
  Roadmaps* (December 2023):
  <https://www.cisa.gov/resources-tools/resources/case-memory-safe-roadmaps>

## Sources

This lecture's prose, worked examples, and quizzes are original
to this course. The industry reports cited (Microsoft MSRC,
Chromium, Google Android) and the government memoranda (White
House ONCD, CISA / NSA / FBI joint publication) are public
documents authored by their respective agencies and vendors; we
quote and link to them rather than reproducing them. The ROP and
heap-spray descriptions are deliberately conceptual and do not
include working exploit code. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
