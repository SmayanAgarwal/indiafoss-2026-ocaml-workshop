---
title: "MirageOS = Library OS + Virtualisation + OCaml"
lecture_no: 5
week: 12
duration_target_min: 25
concepts: [MirageOS, unikernel, mirage configure, Solo5, mirage-skeleton, OCaml libraries for networking, OCaml TLS, Fiat-Crypto, hardware-assisted unikernels]
keywords: [OCaml, MirageOS, unikernel, mirage, Solo5, TLS, OCaml-TLS, Fiat-Crypto, KVM, ELF, dune build]
activity_question: "If a MirageOS unikernel is a single statically-compiled ELF binary that contains its own OS, what file system, network stack, and TLS library does it use? Where does that code come from, and what is the trust story for it?"
think_about_this: "The course began with `let x = 1` and ends with an entire operating system written in the same language. What stayed true across those eleven modules of distance, and what changed?"
reading:
  - title: "MirageOS: A programming framework for building type-safe, modular systems"
    url: https://mirage.io/
  - title: "mirage-skeleton: example MirageOS unikernels"
    url: https://github.com/mirage/mirage-skeleton
  - title: "Kaloper-Meršinjak, Mehnert, Madhavapeddy, Sewell: Not-quite-so-broken TLS"
    url: https://www.usenix.org/system/files/conference/usenixsecurity15/sec15-paper-kaloper-mersinjak.pdf
---

# MirageOS = Library OS + Virtualisation + OCaml


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">MirageOS = Library OS + Virtualisation + OCaml</h2>
<p class="title-slide-label">Module 12 &middot; Lecture 5</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

We have the three ingredients now. [M12-L02](M12-L02-library-os.html)
shrank the kernel into a set of libraries.
[M12-L03](M12-L03-virtualisation.html) used a hypervisor to put a
strong protection boundary between guest images. And
[M12-L04](M12-L04-ocaml-for-systems.html) chose OCaml as the
implementation language so that the inside of each image is
memory-safe without needing the MMU. This last lecture puts the three
ingredients together. MirageOS is the result.

There is no live code here. MirageOS is statically compiled to an ELF
binary that boots inside a VM; running it in the browser is not on
the table for this course. Instead, this lecture is structured around
walking the pipeline (what does the build actually do?), looking at
the catalogue of libraries that ship with MirageOS, looking at one
specific case study (the OCaml TLS implementation, whose engineering
quality is the strongest single argument for the whole approach), and
then closing the course.

This lecture has five parts. First, the synthesis ("here is what
MirageOS *is*"). Second, the build pipeline (`config.ml` to `mirage
configure` to a static binary). Third, the library catalogue
(networking, storage, security, crypto, data structures). Fourth,
TLS as a case study and a pointer to hardware-assisted unikernels.
Fifth, a recap of where the course has been and where the safety
stack lands.

:::slide

## Where we are

- M12-L01 named the problem (kernel TCB is huge).
- M12-L02 gave ingredient 1 (library OS).
- M12-L03 gave ingredient 2 (virtualisation).
- M12-L04 gave ingredient 3 (OCaml).
- **This lecture: the synthesis.**

:::

## What MirageOS is

The one-line definition: **MirageOS is a library OS plus a compiler
that builds specialised images.** The images it produces are called
*unikernels*: a unikernel is a single statically-linked binary that
contains both an application and the operating-system pieces it
needs (network stack, storage, scheduling, crypto), bundled
together so there is no separate kernel underneath. The "uni" in
*unikernel* is the single image: one binary, one address space,
one OS-and-application combined unit.

The library OS part is exactly the M12-L02 story: a collection of
OCaml libraries that, between them, implement the functionality
that used to be in the kernel. The compiler part is the
interesting addition: MirageOS has its own build tool, `mirage`,
that takes a high-level description of the unikernel you want and
orchestrates the OCaml compiler, the package manager, and `dune`
into producing the final ELF binary.

A few properties of the resulting image are worth knowing up front:

- It is a **statically-compiled ELF binary**. No shared libraries.
  No dynamic loader. Everything the unikernel needs is in the
  binary.
- It is typically **a few megabytes**: the mirage.io HTTPS web
  server is about 10 MiB total.
- It **boots in milliseconds** when started under Solo5 on KVM.
- It uses **a few megabytes of RAM** for minimal workloads.
- It runs as **a VM** in production (Solo5-hvt on KVM, Solo5-xen on
  Xen, Solo5-spt as a seccomp-sandboxed Linux process) and can also
  run as a **plain Unix process** for debugging.

Drawn as a layer diagram: the host has hardware at the bottom, a
hypervisor above it, and several side-by-side unikernels on top.
Each unikernel is one tall column: at the very bottom of the column
is the Mirage Runtime (the bits of the OCaml runtime plus the Solo5
host interface). Above that is the application code. There is
nothing else. No syscall layer. No Linux. No `init`. No libc, in the
sense that any of you have used libc before; just the small set of
C bindings the OCaml runtime and the crypto libraries actually need.

:::slide

## MirageOS unikernel

```
+----------------+ +----------------+
| Application    | | Application    |
| (OCaml)        | | (OCaml)        |
| Mirage runtime | | Mirage runtime |   <-- one unikernel
| (OCaml + Solo5)| | (OCaml + Solo5)|
+----------------+ +----------------+
+------------------------------------+
| Hypervisor (KVM via Solo5)         |
+------------------------------------+
| Hardware                           |
+------------------------------------+
```

- A unikernel = **one statically-compiled ELF binary**.
- A few MiB on disk, a few MiB of RAM, boot in milliseconds.
- Side-by-side unikernels, **hypervisor-isolated**.

:::

The shape of this picture is what an *operating system written in
OCaml* looks like when you take the M01-to-M11 program seriously and
push it down to the lowest layer.

## The build pipeline

Building a MirageOS unikernel is a multi-stage pipeline. It is
worth walking step by step, because the same pipeline is what
delivers the "specialisation" property that gives unikernels their
small footprint.

The starting point is a small OCaml file called `config.ml`. This is
*not* the application; it is a *manifest* that describes which
libraries the unikernel needs and how they should be wired together.
The manifest uses combinators from the `mirage` package. A trivial
example for the "Hello, Unikernel" might say "I need a `Mirage_time`
module; please wire it to the platform's time implementation."

You then run `mirage configure -t <target>`. The target picks the
backend: `unix` for a plain Unix process, `hvt` for Solo5 on KVM,
`xen` for Solo5 on Xen, and so on. The `mirage configure` command
reads `config.ml`, decides which OCaml packages need to be installed
to satisfy its dependencies, and generates several files:

- A **`Makefile`** that orchestrates the rest of the build.
- An **opam file** listing the packages needed at this configuration.
- A **`main.ml`** that ties the application module to the chosen
  backend implementations of every library in the manifest. This
  `main.ml` is generated; you do not write it.
- One or more `mirage_*_<target>.ml` files that adapt the chosen
  libraries to the target backend.

The next stage is `make`, which essentially calls `opam install`
(pulling in the right backend libraries) and then `dune build`. The
`dune build` is where the OCaml compiler does its real work: it
compiles the application source, the generated `main.ml`, and every
library, links them all into one image, and runs the OCaml linker's
dead-code elimination pass. The result is a statically-linked binary
in `dist/<name>`.

Picture the pipeline as boxes connected by arrows. Far left: a green
`config.ml`. An arrow labelled `mirage configure` points at a stack
of files: `Makefile`, `opam`, `main.ml`. Below that stack, two more
generated `.ml` files: `mirage_net_XXX.ml`, `mirage_tcpip.ml`, and
so on. The two paths converge: `make` runs the opam install, `dune
build` runs the compile-and-link, and the output is a blue box
labelled `image`. Off to the side, a green `unikernel.ml` (the
application code you actually wrote) also feeds into the dune build.

![MirageOS compiler pipeline diagram: a green config.ml feeds into
mirage configure, which generates Makefile, opam, main.ml, and per-
backend mirage_net_XXX.ml / mirage_tcpip.ml stubs; make plus dune
build then combine these with the user's unikernel.ml to produce a
single image (ELF binary).](/assets/m12/figures/slide-31-mirageos-compiler-pipeline.svg)

The ASCII rendering below is the same pipeline for slide-mode and
screen-reader use.

:::slide

## MirageOS multi-stage pipeline

```
config.ml  ---- mirage configure ----+-- Makefile
                                     +-- opam
                                     +-- main.ml
                                     +-- mirage_net_XXX.ml
                                     +-- mirage_tcpip.ml
                                     +-- ...

unikernel.ml  ------------+
                          v
            make + dune build
                          |
                          v
                       image (ELF binary)
```

- `config.ml` is a **manifest**, not the application.
- The pipeline generates the wiring; you write `unikernel.ml`.
- `dune build` produces a single statically-linked ELF.

:::

Two things are interesting about this pipeline that we did not see in
ordinary OCaml development. First, the **specialisation** happens at
build time: the same `unikernel.ml` can be configured for `unix` or
`hvt` or `xen`, and each configuration gets a different set of
backend libraries linked into the image. The application code does
not change; the wiring underneath does. Second, the OCaml linker
performs **whole-program dead-code elimination**: any function that
no path through the application reaches is stripped out of the
binary. This is why the resulting image is only a few megabytes
despite linking entire network and storage stacks; only the parts
those stacks actually exercise survive.

:::slide

## Specialisation by configuration

- `unikernel.ml` is the application.
- `config.ml` is the manifest.
- `mirage configure -t <target>` picks the backend at build time.
- `dune build` plus the OCaml linker's **dead-code elimination**
  strips everything the application does not reach.

Result: the mirage.io HTTPS server is **10 MiB**. Boot time is **a
few ms**. The runtime fits in **a few MiB of RAM**.

:::

## What ships with MirageOS

A MirageOS unikernel does not call into any Linux. Every piece of
functionality the application needs has to come from an OCaml library
inside the binary. The MirageOS ecosystem is large enough that this
is feasible for many real applications.

![Talk slide "Available Libraries": five blocks listing the OCaml
libraries that ship with MirageOS, namely Network (Ethernet, IP,
UDP, TCP, HTTP 1.0/1.1/2.0, ALPN, DNS, ARP, DHCP, SMTP, IRC, cap-n-
proto, emails), Storage (block device, ramdisk, qcow, B-trees, VHD,
zlib, gzip, lzo, git, tar, FAT32), Data-structures (LRU, Rabin's
fingerprint, bloom filters, adaptive radix trees, DIET trees),
Security (x.509, ASN.1, TLS, SSH), and Crypto (hashes, ciphers, AEAD
primitives, public-key, Fortuna); plus a side note that TLS uses
"rigorous engineering" via Fiat-Crypto extracted from
Rocq.](/assets/m12/figures/slide-29-available-libraries.svg)

Roughly catalogued, the available libraries are:

- **Network.** Ethernet, IP (v4 and v6), UDP, TCP, HTTP 1.0 / 1.1 /
  2.0, ALPN, DNS, ARP, DHCP, SMTP, IRC, Cap'n Proto, email parsing.
  Pure-OCaml implementations of each layer, composable through
  module signatures.
- **Storage.** Block-device drivers, RAM disks, the QCow virtual-
  disk format, B-trees, VHD, Zlib, gzip, lzo, git, tar, FAT32.
- **Data structures.** LRU caches, Rabin's fingerprint, Bloom
  filters, adaptive radix trees, discrete interval encoding trees.
- **Security.** X.509 certificate parsing, ASN.1, TLS, SSH.
- **Crypto.** Hashes and checksums (SHA-1, SHA-2, SHA-3, MD5,
  Blake2), ciphers (AES, 3DES, RC4, ChaCha20/Poly1305), AEAD
  primitives (AES-GCM, AES-CCM), public-key (RSA, DSA, DH), the
  Fortuna PRNG.

Almost all of this is **reimplemented in OCaml**. The few exceptions
are performance-critical low-level routines (constant-time AES, for
example) which are either written in carefully audited C, or
extracted from formally verified Rocq (formerly Coq) sources
(we'll come to that in a
moment). For an application like a HTTPS web server, *every layer
from the Ethernet frame parser up to the HTTP response writer is
OCaml*. There is no `libssl`. There is no `libcurl`. There is no
glibc.

:::slide

## Available libraries (talk slide 29)

| Area | Libraries |
| --- | --- |
| **Network** | Ethernet, IP, UDP, TCP, HTTP/1.x and HTTP/2, ALPN, DNS, ARP, DHCP, SMTP, IRC, Cap'n Proto, emails |
| **Storage** | block device, ramdisk, qcow, B-trees, VHD, zlib, gzip, lzo, git, tar, FAT32 |
| **Data structures** | LRU, Rabin's fingerprint, bloom filters, ART trees, DIET trees |
| **Security** | x.509, ASN.1, TLS, SSH |
| **Crypto** | hashes, AES/3DES/RC4/ChaCha20, AES-GCM/CCM, RSA/DSA/DH, Fortuna |

**All in OCaml.** No libssl. No libc.

:::

## TLS as rigorous engineering

Of all the libraries on that list, the one that best illustrates the
ambition of the MirageOS project is the TLS implementation. TLS is
notoriously hard to implement correctly: the specifications are
sprawling, the state machine is intricate, the cryptographic
primitives are unforgiving, and a single bug can compromise the
confidentiality and integrity of every connection. OpenSSL's CVE
history is one long, painful demonstration of how much can go wrong.

The MirageOS TLS implementation was published at USENIX Security in
2015 by David Kaloper-Meršinjak, Hannes Mehnert, Anil Madhavapeddy,
and Peter Sewell, under the title *Not-quite-so-broken TLS: lessons
in re-engineering a security protocol specification and
implementation*. The paper's contributions are technical, but the
*engineering* approach is what is worth describing here.

Three properties stand out:

1. **Same pure code generates test oracles, verifies against
   real-world TLS traces, and serves as the real implementation.**
   In the conventional setup, the production implementation is one
   codebase and the testing infrastructure is another; mismatches
   between the two are how the production code drifts away from
   the spec. In OCaml-TLS, the state-machine code is purely
   functional, and the same functions are used to (a) drive the
   production server, (b) generate test inputs, and (c) validate
   against recorded traces from other TLS stacks. The lack of
   side effects in the core makes this consolidation possible.
2. **Cryptographic primitives use Fiat-Crypto, extracted from Rocq
   proofs.** The constant-time arithmetic that underpins
   elliptic-curve operations is notoriously fiddly: subtle
   side-channel leaks have produced multiple CVEs in mainstream
   implementations. Fiat-Crypto is a project that *proves*, in the
   Rocq proof assistant, that the C code implementing these
   primitives matches a mathematical specification, and then
   *extracts* the verified C automatically. OCaml-TLS uses these
   extracted primitives. The trust story for the cryptographic
   core is no longer "we audited the C very carefully"; it is
   "we have a machine-checked proof."
3. **Strong types track state-machine validity.** TLS has a state
   machine with dozens of states and constrained transitions. In
   OCaml-TLS, those states are encoded as variant types, and the
   compiler refuses to let the implementation enter an invalid
   state. Whole categories of "state confusion" CVEs (a category
   that has affected OpenSSL multiple times) cannot occur.

The combined picture is that OCaml-TLS is what you get when you
take the engineering principles of this whole course (memory
safety, exhaustive pattern matching, pure functions, strong types,
verified critical pieces) and apply them to the production
implementation of a security protocol. The result is a TLS
implementation small enough to audit and structured well enough that
audit means something.

:::slide

## OCaml TLS: rigorous engineering

> *Not-quite-so-broken TLS: lessons in re-engineering a security
> protocol specification and implementation*,
> Kaloper-Meršinjak, Mehnert, Madhavapeddy, Sewell, USENIX Security 2015.

- **Same pure OCaml code** drives the server, generates test
  oracles, and validates against real-world TLS traces.
- **Cryptographic primitives extracted from Rocq via Fiat-Crypto:
  machine-checked correctness for the constant-time arithmetic.**
- **Variant types encode the protocol state machine; invalid
  transitions are unrepresentable.**

This is what M01-M11's safety toolkit applied to a security
protocol looks like.

:::

## Hello Unikernel

Worth seeing the code for one concrete example. The simplest
MirageOS unikernel is something that, every second, logs the word
"hello" and exits after a few iterations. The actual `unikernel.ml`
looks like this. The `open Lwt.Infix` at the top brings the `>>=`
operator into scope: `>>=` is Lwt's monadic bind, the same shape
as the QCheck-generator `>>=` from
[property-based testing](M09-L05-property-based-testing.html); read `e >>= fun x -> ...`
as "wait for the Lwt computation `e`, then continue with its
result bound to `x`."

```text
open Lwt.Infix

module Hello (Time : Mirage_time.S) = struct
  let start _time =
    let rec loop = function
      | 0 -> Lwt.return_unit
      | n ->
          Logs.info (fun f -> f "hello");
          Time.sleep_ns (Duration.of_sec 1) >>= fun () -> loop (n - 1)
    in
    loop 4
end
```

A few things worth noticing, even without running it:

- The unikernel is a **functor**: `module Hello (Time :
  Mirage_time.S) = struct ... end`. The `Time` parameter is a
  module that implements the abstract time signature. At build
  time, `mirage configure -t unix` will plug in a Unix
  implementation; `mirage configure -t hvt` will plug in the
  Solo5 implementation. The unikernel does not know or care which.
- The body uses `Lwt`, the cooperative-concurrency library, and
  `Logs`, the structured logging library. Both are normal OCaml
  packages; in a Linux process they would do the same thing they
  do here.
- The entry point is a `start` function. The build pipeline (via
  the generated `main.ml`) calls it.
- There is no `main`. There is no `printf` to stdout. There is no
  Unix shell waiting for the binary's exit status. The image is
  the program, and `start` is the only entry point.

Configured for the **Unix backend** (`mirage configure -t unix`),
the build produces a `dist/hello` executable. Running it on a Linux
host gives output like:

```text
2024-11-25T17:04:16+05:30: [INFO] [application] hello
2024-11-25T17:04:17+05:30: [INFO] [application] hello
2024-11-25T17:04:18+05:30: [INFO] [application] hello
2024-11-25T17:04:19+05:30: [INFO] [application] hello
```

That is the unikernel running as a plain Linux process. Convenient
for development; useful for debugging; not the production target.

Configured for the **hvt** backend (`mirage configure -t hvt`),
the build produces `dist/hello.hvt`, which is a Solo5 image. You
run it with `solo5-hvt -- dist/hello.hvt`, and the output is:

```text
            |      ___|
  __|   _ \  |  _ \ __ \
\__ \  (    | (    |   |
____/ \___/ _|\___/____/
Solo5: Bindings version v0.9.0
Solo5: Memory map: 512 MB addressable:
Solo5:   reserved @ (0x0 - 0xfffff)
Solo5:       text @ (0x100000 - 0x1c4fff)
Solo5:     rodata @ (0x1c5000 - 0x1f5fff)
Solo5:       data @ (0x1f6000 - 0x289fff)
Solo5:       heap >= 0x28a000 < stack < 0x20000000
2024-11-25T11:47:10-00:00: [INFO] [application] hello
2024-11-25T11:47:11-00:00: [INFO] [application] hello
2024-11-25T11:47:12-00:00: [INFO] [application] hello
2024-11-25T11:47:13-00:00: [INFO] [application] hello
Solo5: solo5_exit(0) called
```

Same `unikernel.ml`. Same `config.ml` source. Different `mirage
configure` invocation. The first runs as a Linux process; the second
runs as a VM on KVM, with no Linux guest inside it.

:::slide

## Hello Unikernel (`unikernel.ml`)

```text
open Lwt.Infix

module Hello (Time : Mirage_time.S) = struct
  let start _time =
    let rec loop = function
      | 0 -> Lwt.return_unit
      | n ->
          Logs.info (fun f -> f "hello");
          Time.sleep_ns (Duration.of_sec 1)
          >>= fun () -> loop (n - 1)
    in
    loop 4
end
```

- A **functor over Mirage_time.S**: the same code runs against the
  Unix-backed implementation, the Solo5-backed implementation, etc.
- `mirage configure -t unix`: runs as a Linux process.
- `mirage configure -t hvt`: runs as a VM on KVM.

:::

A downloadable hands-on example: this minimal unikernel skeleton
plus a `dune-project`, `config.ml`, and `unikernel.ml` is bundled as
`/assets/m12/hello-mirage.tar.gz`. Clone, `mirage configure -t unix`,
`make`, and you have a working development setup on your own
machine. (To run the Solo5 backends you need KVM on Linux, or one of
the Solo5 alternatives.)

:::slide

## Try it locally

- Download `/assets/m12/hello-mirage.tar.gz`.
- `tar xzf hello-mirage.tar.gz && cd hello-mirage`.
- `opam install mirage`.
- `mirage configure -t unix && make`.
- `./dist/hello`.

For the KVM target: `mirage configure -t hvt && make && solo5-hvt --
dist/hello.hvt`.

:::

## What MirageOS is used for

MirageOS is not vapourware. Production users include:

- **mirage.io itself.** The web server hosting the MirageOS
  documentation is a MirageOS unikernel, around 10 MiB on disk.
- **Robur.io**, a non-profit collective that ships several
  production MirageOS deployments, including a CalDAV server,
  several DNS servers, and email infrastructure.
- **OPAM mirrors and OCaml infrastructure** (some of the package
  signing and mirror servers).
- **Tezos baking infrastructure**, in part. Tezos is the blockchain
  whose protocol is written in OCaml; some of the supporting
  network services are MirageOS unikernels.

The deployments are small in number but real, and the niche is
clear: long-running network services where the operational benefits
(small attack surface, fast restart, predictable resource use) pay
for the limited library ecosystem outside the supported areas.

## Advanced topic: hardware-assisted unikernels

The argument we have built in this module relies on the hypervisor
to isolate guests from each other. The hypervisor is itself a piece
of software, and a complex one: Linux KVM is hundreds of thousands
of lines of C; Xen is comparable. The hypervisor is, in the strict
sense, also in the TCB of every unikernel on the host.

There is an active research direction in *hardware-assisted
unikernels*: using newer CPU features (Intel TDX, AMD SEV-SNP, ARM
CCA) to reduce or eliminate the trust placed in the hypervisor.
The vision is a unikernel whose memory the hypervisor cannot read
and whose execution it cannot tamper with, even though it still
schedules the unikernel onto a physical CPU and routes its I/O.

KC Sivaramakrishnan's November 2024 talk *Securing the foundations*
at the Centre for Artificial Intelligence and Robotics (CAIR / DRDO)
covers this in detail: the threat model, the relevant hardware
extensions (notably the upcoming Indian CHERI-based work), and the
implications for unikernel design. We do not cover the material in
this course; the talk is the right starting point for the curious.

:::slide

## Advanced pointer: hardware-assisted unikernels

- Hypervisor is in the TCB.
- Newer CPUs (Intel TDX, AMD SEV-SNP, ARM CCA, CHERI) can reduce
  what the hypervisor is trusted to do.
- KC's CAIR / DRDO Nov 2024 talk, *Securing the foundations*, is
  the entry point.

:::

## Closing the course

This is the last lecture, and the safety story has come a long way
since `let x = 1`.

In [M01](M01-L02-why-fp.html) we argued that values and types are
the unit of reasoning in OCaml. In M02 to M08 we built the core
language: literals, bindings, functions, pattern matching, modules.
By the end of M08 you had a complete functional language and the
discipline to use it well.

In [Module 9](M09-L01-why-test-typed-code.html) we said that types catch type
errors but not behaviour, and added testing; especially property-
based testing, which works particularly well because pure functions
are properties.

In [Module 10](M10-L01-memory-safety-and-security.html) we made the
*memory-safety* claim precise. Use-after-free, buffer overflow,
uninitialised reads, double-frees: all ruled out by construction.
The numbers (70 percent of CVEs are memory-safety bugs) made the
argument concrete.

In [Module 11](M11-L01-locality.html) we pushed safety into
new territory with OxCaml's modes: locality made stack allocation
safe; uniqueness ruled out use-after-free at the type level;
linearity made a second use of a consumed handle unwritable; and
portability with contention delivered compile-time data-race
freedom. Types tracking *how* a value is used, not just *what*
it is.

In Module 12 we have taken the whole apparatus and pushed it down
into the operating system itself. MirageOS is what the safety
toolkit looks like when you apply it to the runtime your application
sits on. Library OS removes the kernel boundary; virtualisation
gives back the inter-application isolation; OCaml gives back the
intra-application safety. The result is a coherent, minimal, fast,
auditable platform.

That is the journey, end to end. Thirty hours of lecture, a hundred
runnable cells, several hundred quizzes, two textbook chapters in
each lecture: all of it adds up to one idea, that safety is something
you can *build into* your software at every level if you take the
language seriously.

:::slide

## Where the course has been

- M01-M08: the core language. Types, functions, pattern matching,
  modules.
- M09: tests catch what types do not. Properties as first-class.
- M10: memory safety as a property of the language. Categories of
  CVEs OCaml rules out.
- M11: modes track *how* values are used. Locality, uniqueness,
  linearity, portability, contention.
- **M12: the OS itself, in OCaml.** Safety, all the way down.

:::

## Activity

:::quiz mcq id=M12-L05-q1
A MirageOS unikernel is built by running `mirage configure -t hvt`,
then `make`. What is the *output* of this build, and what runs it?

- [ ] A Linux kernel module loaded into the host's running kernel.
- [x] A statically-compiled ELF binary that runs as a VM under
  Solo5 on KVM.
- [ ] A Docker container that runs on the host kernel.
- [ ] A bytecode file interpreted by the OCaml toplevel.

**Why:** `-t hvt` targets the Solo5 hardware-virtualisation tender
on KVM. The build produces an ELF image (`dist/<name>.hvt`); you
run it with `solo5-hvt -- dist/<name>.hvt`, which starts a KVM VM
whose only contents are this unikernel. There is no Linux guest
inside the VM; the unikernel *is* the OS. Containers share the host
kernel and would not give us the isolation guarantees M12-L03
discussed; bytecode is the development backend, not the production
one.
:::

:::quiz mcq id=M12-L05-q2
Why is the OCaml-TLS implementation considered "rigorous engineering"
in a way that conventional TLS libraries typically are not?

- [ ] It runs ten times faster than OpenSSL.
- [ ] It is written in a much smaller number of lines.
- [x] The same pure OCaml code drives the server, generates test
  oracles, and validates against recorded TLS traces; the
  cryptographic primitives are extracted from machine-checked Rocq
  proofs (Fiat-Crypto); and the protocol state machine is encoded
  in types so invalid transitions are unrepresentable.
- [ ] It is written by a different vendor from OpenSSL.

**Why:** the three engineering moves listed are precisely what the
USENIX Security 2015 paper documents. The result is a stack whose
correctness story is fundamentally different from "we wrote it
carefully": it is "we built the abstractions so the bugs cannot
occur." Speed and size are secondary; the safety argument is the
news.
:::

:::slide

## Activity discussion

Q1: `mirage configure -t hvt && make`: what's the output, what
runs it?
Q2: why OCaml-TLS is "rigorous engineering" in a way conventional
TLS libraries are not.

- `mirage configure -t hvt && make` produces a **statically-linked
  ELF** that runs as a **KVM VM via Solo5**.
- OCaml-TLS's rigorous engineering: same pure code drives prod,
  tests, and oracle; crypto from Rocq; types encode the state
  machine.

:::

## Common pitfalls

**Pitfall 1: "Unikernels replace Linux."** Not for general-purpose
computing. They replace Linux in *deployment niches*: long-running
network services, security-sensitive infrastructure, cloud workloads
where the per-instance footprint matters. Your developer workstation
is still going to run a conventional OS.

**Pitfall 2: "You have to write the whole OS yourself."** The
library catalogue we walked through covers most of what a typical
service needs. You write the application; the libraries supply the
rest. The MirageOS skeletons (`mirage-skeleton` on GitHub) are
good starting points.

**Pitfall 3: "If it crashes, what happens?"** The unikernel exits.
That is it. There is no kernel panic, no rescue shell, no
`systemd` restart logic inside the image. The host's
deployment system (`systemd`, `kubernetes`, `nomad`, whatever you
use) restarts the unikernel from scratch. The boot time is small
enough that this is operationally acceptable for most services.

**Pitfall 4: "There's no way to log in."** Right; there is no shell.
For observability, the unikernel logs via the `Logs` library to
stdout (in the Unix backend) or via Solo5's console output (in the
hvt backend). Production deployments capture those logs the same
way they capture any container's stdout.

## Reading

- **MirageOS project home**: <https://mirage.io/>
- **mirage-skeleton**, the canonical starter projects:
  <https://github.com/mirage/mirage-skeleton>
- **Solo5**: <https://github.com/Solo5/solo5>
- **Kaloper-Meršinjak, Mehnert, Madhavapeddy, Sewell**, *Not-quite-
  so-broken TLS: lessons in re-engineering a security protocol
  specification and implementation*, USENIX Security 2015:
  <https://www.usenix.org/system/files/conference/usenixsecurity15/sec15-paper-kaloper-mersinjak.pdf>
- **Robur**, a non-profit deploying MirageOS in production:
  <https://robur.coop/>
- **Fiat-Crypto** (Rocq-extracted cryptographic primitives):
  <https://github.com/mit-plv/fiat-crypto>
- KC Sivaramakrishnan, *Securing the foundations* (CAIR / DRDO,
  Nov 2024), for the hardware-assisted-unikernels pointer.

## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. The MirageOS narrative (synthesis, multi-stage pipeline
diagram, available-libraries catalogue, hello-unikernel example,
TLS-as-rigorous-engineering framing) follows KC Sivaramakrishnan's
January 2025 IIT Madras talk *Towards smaller, safer, bespoke OSes
with Unikernels*, slides 27 to 35. The pointer to hardware-assisted
unikernels follows KC's CAIR / DRDO November 2024 talk *Securing the
foundations*. The TLS paper (Kaloper-Meršinjak et al., USENIX
Security 2015) is the standard academic anchor for the OCaml-TLS
story. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
