---
title: "Ingredient 1: Library OS"
lecture_no: 2
week: 12
duration_target_min: 25
concepts: [library operating system, single address space, Nemesis, Exokernel, kernel as library, function calls vs syscalls]
keywords: [OCaml, library OS, libOS, Nemesis, Exokernel, MIT, Cambridge, Glasgow, single address space]
activity_question: "If the kernel were just another library that the application linked against, like libc or libssl, what would change for the application programmer? What new freedoms and what new dangers would they have?"
think_about_this: "The big idea behind a library OS is that 'kernel mode' becomes a fiction. Every device driver, every scheduler decision, every storage call is an ordinary function call in your address space. The kernel is no longer ambient. What does that buy you, and what does that cost?"
reading:
  - title: "The Multi-Service Network Operating System (Nemesis)"
    url: https://www.cl.cam.ac.uk/research/srg/netos/projects/archive/nemesis/
  - title: "Exokernel: An Operating System Architecture for Application-Level Resource Management (Engler, Kaashoek, O'Toole, SOSP 1995)"
    url: https://pdos.csail.mit.edu/papers/exokernel-sosp95.pdf
---

# Ingredient 1: Library OS


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Ingredient 1: Library OS</h2>
<p class="title-slide-label">Module 12 &middot; Lecture 2</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

[Last lecture](M12-L01-why-an-os.html) ended with a question: do we
really have to ship the entire monolithic kernel with every
application, even when the application only needs a sliver of it?
This lecture is the first ingredient of an answer. We are going to
take the kernel apart, conceptually, and put it back together as a
*library*. The application will not call into an ambient operating
system any more; it will *link* with the OS functionality it needs, the
same way it links with `libssl` or `libm`.

The idea is old (the 1990s) and the academic version has a respectable
history. It is also, at first, slightly strange. We are used to
"kernel mode" being a separate thing from "user mode", protected by a
hardware boundary the CPU enforces. We are used to system calls being
a different kind of operation from function calls. The library-OS
proposal says: throw all of that out. There is one address space,
one mode, and the kernel is just code your program calls.

This lecture has three parts. First, the architectural picture:
what does the stack look like when the kernel becomes a library?
Second, a brief tour of the 1990s academic library-OS projects
(Nemesis and Exokernel) and why they did not displace monolithic
kernels at the time. Third, the honest pros and cons of the library-OS
model, including the cons that we will need a *second* ingredient to
fix.

:::slide

## Where we are

- M12-L01 set up the problem: kernels are huge, TCBs are huge,
  security suffers.
- This lecture: **ingredient 1**, the **library OS**.
- The kernel is broken from monolith into individual libraries.
- No "kernel mode"; just function calls.
- Wins and costs, in that order.

:::

## The architectural shift

Recall the conventional stack from last lecture. At the top, your
application. Below it, configuration files, the language runtime,
shared libraries, and then the kernel sitting between you and the
hardware as an ambient supervisor. Drawing it as boxes, the kernel is
a separate horizontal band underneath your process. The user-kernel
boundary is a hard line: above it, your code runs with low privilege;
below it, kernel code runs with full hardware privilege. Crossing the
line takes a syscall: a controlled, privileged transition.

In a library OS, that horizontal line *disappears*. The kernel
functionality, broken into libraries, is *inside* your process. Drawn
as boxes, the picture is one big container labelled "kernel" with
the application, the language runtime, the shared libraries, and the
new libraries (the scheduler, the network stack, the storage stack,
the device drivers) all inside it. There is no separate layer
underneath. The CPU executes everything in one address space, in one
privilege mode.

Picture the two side by side. The conventional kernel:

![Conventional layout: a Process box containing Jars, Application,
Java VM, libc, libssl, libm sits on a separate horizontal Kernel
band, which in turn sits on
Hardware.](/assets/m12/figures/slide-10-process-conventional.svg)

```
+-------------------------------+
| Process                       |
|  [Jars] [Application]         |
|     [Java VM]                 |
|  [libc][libssl][libm]         |
+-------------------------------+
+-------------------------------+
| Kernel                        |   <-- separate, privileged
+-------------------------------+
+-------------------------------+
| Hardware                      |
+-------------------------------+
```

A hard line between process and kernel; every device touch goes
through a syscall.

The library OS:

![Library OS layout: one big Kernel box containing Jars, Application,
Java VM, libc, libssl, libm and the new libsched, libnet, libfs all
in the same address space, sitting directly on
Hardware.](/assets/m12/figures/slide-12-libos-kernel-as-libraries.svg)

```
+-------------------------------+
| Kernel (just a name)          |
|  [Jars] [Application]         |
|     [Java VM]                 |
|  [libc][libssl][libm]         |
|  [libsched][libnet][libfs]    |
+-------------------------------+
+-------------------------------+
| Hardware                      |
+-------------------------------+
```

One box, one address space, one privilege mode. The "Kernel" label
is now just the name for the union of the libraries the application
chose to link. The thin line that used to live inside the picture is
gone.

![The same library-OS layout annotated with the three consequences:
"application runs in a single address space", "single calling
convention", and "drive hardware directly from
application".](/assets/m12/figures/slide-13-libos-single-address-space.svg)

Three callouts on the picture name the three consequences spelled out
below: one address space, one calling convention, hardware driven
directly from the application.

:::slide

## Conventional kernel (M12-L01)

```
+-------------------------------+
| Process                       |
|  [Jars] [Application]         |
|     [Java VM]                 |
|  [libc][libssl][libm]         |
+-------------------------------+
+-------------------------------+
| Kernel                        |  <-- separate, privileged
+-------------------------------+
+-------------------------------+
| Hardware                      |
+-------------------------------+
```

- A hard line between process and kernel.
- Every device touch goes through a syscall.

:::

:::slide

## Library OS

```
+-------------------------------+
| Kernel (just a name)          |
|  [Jars] [Application]         |
|     [Java VM]                 |
|  [libc][libssl][libm]         |
|  [libsched][libnet][libfs]    |
+-------------------------------+
+-------------------------------+
| Hardware                      |
+-------------------------------+
```

- One address space, one mode.
- "Kernel" is just the name for the union of the libraries.

:::

The conceptual move is small but the practical consequences are
large. Three of them are worth naming explicitly:

1. **Single address space.** All code, including what used to be
   "kernel" code, runs in the same virtual-address space. A pointer
   from the application can reach into the network stack; a pointer
   from the network stack can reach into the application. There is
   no MMU-enforced boundary between them.
2. **Single calling convention.** A network send is no longer a
   syscall with register-marshalling and a trap into ring 0; it is a
   function call. The compiler can inline across it. The cost of
   "crossing the kernel" is now the cost of "calling the next
   function," which is essentially free.
3. **Application-selected libraries.** The application picks which
   libraries to link. If it needs only TCP/IP and no filesystem, it
   links only the network library. The "kernel" that ends up in the
   binary is *only* the parts the application uses. The monolithic
   blob is replaced by a custom assembly.

The last point is the one that directly addresses the iceberg from
last lecture. A library-OS application that does not use a USB stack
does not have a USB stack in its image. A library-OS application that
does not touch a disk does not have a filesystem driver. The runtime
shrinks to what the application actually exercises.

:::slide

## What changes when the kernel is a library

1. **Single address space.** No MMU wall between "kernel" and
   "application."
2. **Single calling convention.** Network send is a function call,
   not a syscall.
3. **Application picks the libraries it needs.** No disk used means
   no filesystem driver shipped.

**The "kernel" in the binary is only the parts the app uses.**

:::

## A short history: Nemesis and Exokernel

This is not a new idea. In the early 1990s two academic projects
explored it seriously enough to produce running systems, papers, and
PhD theses.

**Nemesis** was developed at the University of Cambridge Computer
Laboratory in collaboration with the University of Glasgow, starting
around 1993. Its motivating workload was multimedia: video and audio
streams that need predictable latency more than they need raw
throughput. The Nemesis insight was that a conventional kernel hides
the resource-management decisions an application would need to keep
its latency bounded, and the way to give the application back that
control is to put the resource-management code *in the application's
address space*, as a library. Nemesis pioneered many of the
library-OS ideas: per-application schedulers, single address space,
direct device access from user code. It was a research success and a
deployment failure: a small set of Cambridge multimedia demos used
it, and almost nobody else.

**Exokernel** was developed at MIT, also starting in the early 1990s
and most associated with the work of Engler, Kaashoek, and their
students. The most influential paper is *Exokernel: An Operating
System Architecture for Application-Level Resource Management* at
SOSP 1995. Exokernel's idea was even more aggressive: the operating
system should *only* multiplex hardware resources securely and let
applications implement everything else themselves, including
filesystems and network protocols, as user-level libraries. The
exokernel itself is tiny; the per-application library OSes built on
top of it are where the real OS functionality lives.

Both projects produced working systems. Neither displaced the
monolithic kernel in industry. The reasons are practical, not
philosophical:

- **Device drivers.** Every device in the world has a driver; the
  monolithic kernel community maintains them collectively. A
  library-OS project that wants to support real hardware has to
  either rewrite each driver from scratch (Nemesis's path) or wrap
  the kernel drivers somehow (a never-quite-clean compromise). The
  cost of keeping up with the constantly-evolving hardware ecosystem
  outside of the Linux mainline is enormous.
- **Niche adoption only.** Both projects found niches that valued
  their performance enough to absorb the maintenance pain: network
  appliances, high-frequency trading systems, embedded
  multimedia. None of these niches has the userbase to support a
  general-purpose OS effort.

The lesson, by the early 2000s, was: the library-OS idea is correct,
but you cannot maintain the device drivers in isolation. Something
had to give.

:::slide

## 1990s library OSes: Nemesis and Exokernel

| Project | Where | What |
| --- | --- | --- |
| **Nemesis** | Cambridge + Glasgow | Multimedia OS, per-app scheduling, direct device access |
| **Exokernel** | MIT (Engler, Kaashoek) | Minimal kernel, all OS code in user libraries |

- Both **ran**. Both produced theses, papers, demos.
- **Neither displaced monolithic kernels.**
- Bottleneck: **device-driver maintenance** outside the Linux mainline.
- Found niches: network appliances, HFT, embedded multimedia.

:::

That "something had to give" is the cliffhanger this lecture leaves
on, and it is what M12-L03 (virtualisation) and M12-L05 (MirageOS plus
Solo5) resolve. For now, we hold the library-OS idea steady and look
at its strengths and weaknesses on their own terms.

## Pros: what a library OS buys you

Three concrete wins justify the architectural risk.

**Application-level hardware control.** When the network card sits
behind a kernel API, the application cannot tell the card "send this
packet, with this priority, on this queue, right now" without going
through the kernel's general-purpose scheduling and buffering. A
library OS lets the application drive the card directly. For
latency-sensitive workloads (high-frequency trading, real-time
audio, low-jitter networking), the difference is real and
measurable. This is precisely the niche where library OSes survived
commercially.

**Small attack surface.** This is the answer to the iceberg from
M12-L01. The runtime contains only the libraries the application
uses. A library-OS web server has no USB stack, no BlueTooth driver,
no parallel-port driver. The TCB shrinks from "the entire Linux
kernel" to "the libraries this application actually links."
Less code, fewer bugs, fewer CVEs.

**High performance.** Two effects compound here. The first is that
syscalls become function calls: no context switch, no register
save/restore, no privilege transition. The second is that the
compiler can see through the boundary that used to be opaque, inlining
the network-send call into the application loop and removing dead
code that would have been latent in the kernel. We will see in
[M12-L05](M12-L05-mirageos.html) that MirageOS unikernels routinely
boot in milliseconds, fit in a few megabytes of memory, and
outperform conventional Linux processes on networking benchmarks.

:::slide

## Pros of a library OS

- **Application-level hardware control.** Latency-sensitive code
  can drive the device directly.
- **Small attack surface.** Only the libraries you link are in your
  TCB.
- **High performance.** No syscall boundary; the compiler can
  inline through the whole stack.

:::

## Cons: where it hurts

Now the honest other half. A library OS, naively, has two real
problems, and we cannot wave them away.

**No internal protection.** In the monolithic kernel, the user-kernel
boundary protects the kernel from a buggy or malicious application:
the application cannot scribble over the kernel's data structures
because the MMU forbids it. In a library OS, *there is no boundary*.
A wild pointer in the application can corrupt the scheduler's run
queue, the network stack's buffer table, the filesystem's inode
cache. There is no hardware between them. This is a serious problem
for a multi-application system. It is *also* a serious problem within
one application if that application takes input from the network and
processes it with code that has memory-safety bugs.

**Device drivers all need to be rewritten.** Every device the library
OS supports needs a driver written specifically for the library OS's
internal conventions. There is no way to "use a Linux driver" inside
a library OS; the calling conventions, the locking model, the memory
allocator, the interrupt-handling style are all incompatible. The
academic projects ran into this wall hard. For a project to support
any meaningful slice of the hardware market, it has to choose between
spending engineering effort writing drivers (Nemesis) or restricting
itself to a tiny hardware target (Exokernel demos).

Both cons are real. Neither is fatal, but the library-OS approach
*on its own* will not become a production system that anyone outside
a research lab actually runs. That is the gap M12-L03 closes by
adding virtualisation. We do not need a library OS that can drive
every piece of hardware; we need a library OS that can run as a
guest on top of a hypervisor, and let the hypervisor (and its host
OS) deal with the drivers. The library OS only has to speak the
hypervisor's small, stable virtual-device interface.

:::slide

## Cons of a library OS

- **No internal protection.** A wild pointer in the app can
  corrupt the scheduler. The MMU is no longer a safety net.
- **Drivers all need to be rewritten.** No way to reuse Linux's
  drivers wholesale. The driver-ecosystem problem is what killed
  Nemesis and Exokernel commercially.

**Hold these. M12-L03 fixes both with virtualisation.**

:::

## Worth seeing on a real system

It is worth picturing, concretely, what a library-OS runtime image
*is*. It is one statically-linked binary. The entry point is a small
boot stub: zero the BSS, set up the stack, initialise the libraries,
call into the application's `main`. There is no `init` process, no
shell, no `/bin`, no `/etc`. The application is the only process and
the only thread that the runtime knows about. When the application
needs a packet, it calls into the network library, which builds the
Ethernet frame and pokes the network card's transmit ring directly.
When the application needs the time of day, it calls into the time
library, which reads the TSC. There is no `read`, no `write`, no
`open` in the sense those exist on Linux; there is just a graph of
function calls within the binary.

If you have ever booted a microcontroller image written in C or
Rust, you have built something very close to a library OS by hand.
The differences from a "real" library OS like the one MirageOS
produces are scale and modularity: the libraries are bigger, properly
typed, and composable; the application targets a stable API; the
build is automated. But the architectural shape is the same.

## Activity

:::quiz mcq id=M12-L02-q1
A library-OS application links the network library directly into its
image and drives the network card from inside its own address space.
A buggy network-library function dereferences a wild pointer.

Compared to the same bug in the equivalent monolithic-Linux setup
(where the buggy code is a kernel module), what is the practical
difference?

- [ ] On Linux the bug is masked by user-kernel separation; in the
  library OS the bug is masked by the language runtime.
- [x] On Linux the kernel might panic and other processes are
  affected; in the library OS only this unikernel is affected, but
  there is no MMU boundary protecting other parts of the same
  unikernel.
- [ ] In both cases the bug is contained to one process.
- [ ] In both cases the bug brings down the whole machine.

**Why:** the kernel-module bug on Linux can take the kernel down,
which takes every process with it. The library-OS bug only affects
this one VM/process, which is a *win* on the isolation axis between
applications; but inside the library OS there is no MMU wall, so
the bug can corrupt other parts of *that* unikernel freely. The
upshot: virtualisation gives us isolation between unikernels, and
the language (M12-L04) gives us safety within a unikernel.
:::

:::quiz mcq id=M12-L02-q2
What was the primary reason Nemesis and Exokernel did not become
production operating systems, despite the technical merit of the
library-OS idea?

- [ ] Library OSes are fundamentally slower than monolithic
  kernels.
- [ ] No one understood how to write applications for them.
- [x] Maintaining device drivers outside the Linux mainline was an
  enormous, ongoing engineering burden that academic projects could
  not sustain.
- [ ] They could not run on commodity x86 hardware.

**Why:** the technical results from both projects were strong. The
deployment problem was that hardware changes constantly and each
new device needs a driver. A research group cannot keep pace with
the driver-development volume of the global Linux community. The
fix, which we'll see in M12-L03, is to outsource the driver work to
a hypervisor: the library OS only has to speak the small, stable
virtual-device interface.
:::

:::slide

## Activity discussion

Q1: a wild-pointer bug in the network library, library OS vs
Linux kernel module: where does the blast radius land?
Q2: why Nemesis and Exokernel did not become production OSes.

- Library OS contains a fault **to its own unikernel** (no
  cross-process blast radius). But **inside** that unikernel,
  there's no MMU wall.
- We'll close the within-unikernel gap with **OCaml's type
  safety** (M12-L04).
- We'll close the between-unikernel gap with **virtualisation**
  (M12-L03).
- We'll close the driver-burden gap with **the hypervisor's
  virtio drivers** (also M12-L03).

:::

## Common pitfalls

**Pitfall 1: "Library OS = microkernel."** No. A microkernel moves the
OS into user-space *processes*, with IPC between them; the kernel
itself shrinks. A library OS removes the kernel as a separate
component entirely and links OS functionality directly into the
application's address space. Microkernels keep the user-kernel
boundary and add IPC overhead; library OSes drop the boundary.

**Pitfall 2: "If there's no kernel mode, the application can do
anything."** Within its own address space, yes. But the application
cannot reach outside that address space without help from whatever
is hosting it, which in the MirageOS story will be the hypervisor.
The hypervisor enforces the boundary the library OS gave up.

**Pitfall 3: "This is the same as a static binary."** A static binary
still relies on the kernel for system calls, scheduling, memory
allocation, and device I/O. A library OS *includes* the code that
used to do those things; the resulting binary is its own runtime
with no kernel underneath.

**Pitfall 4: "Containers are basically library OSes."** Containers
share the host kernel. The whole kernel is still there; containers
just give each application a different view of the userspace. A
library OS has no host kernel at all.

## What's next

Lecture 3 introduces the second ingredient. The library-OS cons
(no protection, no drivers) are solved not by abandoning the
library-OS idea but by *running it as a guest on a hypervisor*.
Virtualisation gives us isolation between guests for free, and lets
the hypervisor's host OS (or a small dedicated tender like Solo5)
handle the long tail of device drivers, exposing a tiny virtual-device
interface that the library OS can speak natively.

:::slide

## What's next

- Lecture 3: **Ingredient 2, Virtualisation.** The hypervisor
  closes both library-OS cons in one move.
- Lecture 4: **Ingredient 3, OCaml.** Safety inside the
  unikernel; matters because the MMU is no longer there.
- Lecture 5: **MirageOS.** All three put together.

:::

## Reading

- **Nemesis** (Cambridge / Glasgow), project archive:
  <https://www.cl.cam.ac.uk/research/srg/netos/projects/archive/nemesis/>
- **Engler, Kaashoek, O'Toole**, *Exokernel: An Operating System
  Architecture for Application-Level Resource Management*, SOSP 1995:
  <https://pdos.csail.mit.edu/papers/exokernel-sosp95.pdf>
- The MirageOS docs page on the library-OS idea also has a clear
  high-level write-up: <https://mirage.io/docs/>

## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. The architectural framing (kernel-as-libraries, single
address space, the three concrete consequences) follows KC
Sivaramakrishnan's January 2025 IIT Madras talk *Towards smaller,
safer, bespoke OSes with Unikernels*, slides 8 to 15. The historical
Nemesis and Exokernel references are well-established academic-
literature pointers. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
