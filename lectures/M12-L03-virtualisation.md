---
title: "Ingredient 2: Virtualisation"
lecture_no: 3
week: 12
duration_target_min: 25
concepts: [virtualisation, hypervisor, VMM, Type-1 vs Type-2, KVM, Xen, QEMU, VirtIO, Solo5, tender]
keywords: [OCaml, virtualisation, hypervisor, VMM, KVM, Xen, QEMU, VirtIO, Solo5, paravirtualisation]
activity_question: "If the library OS does not have hardware isolation between its own internal components, but it runs inside a VM, how is it possibly more secure than a regular Linux process? What is the boundary that protects whom from what?"
think_about_this: "A hypervisor is itself a kind of operating system, but one whose 'applications' are entire other OSes. What does that change about the safety story when one of those guests is a library OS that has no MMU boundaries inside it?"
reading:
  - title: "Xen and the Art of Virtualization (Barham et al., SOSP 2003)"
    url: https://www.cl.cam.ac.uk/research/srg/netos/papers/2003-xensosp.pdf
  - title: "Solo5: A sandboxed execution environment for unikernels"
    url: https://github.com/Solo5/solo5
---

# Ingredient 2: Virtualisation


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Ingredient 2: Virtualisation</h2>
<p class="title-slide-label">Module 12 &middot; Lecture 3</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

[Last lecture](M12-L02-library-os.html) we built a library OS and
listed its two big problems: no internal protection (the application
can corrupt the network stack because they share an address space)
and a heroic driver-maintenance burden (the library OS has to
re-implement every driver from scratch). Both problems are real.
This lecture introduces the second ingredient of the MirageOS recipe,
*virtualisation*, and shows how it solves both at once.

The argument has a satisfying shape. The library OS, on its own,
gives up the user-kernel boundary. Virtualisation gives us *a
different* boundary, one level up: the guest-host boundary enforced
by the hypervisor. That boundary is just as strong as the old
user-kernel one, but it isolates *whole guest OSes* from each other
rather than processes from a kernel. If we treat each library-OS
image as a guest VM, the isolation problem from M12-L02 goes away,
and the driver problem largely goes away too because the host's
hypervisor can take care of the heterogeneous hardware and expose a
small, stable virtual-device interface that the library OS speaks.

This lecture has four parts. First, a quick orientation to
virtualisation as a concept: what a hypervisor is, why it exists.
Second, the Type-1 vs Type-2 distinction. Third, KVM specifically,
because it is the deployment substrate the rest of the module
assumes. Fourth, the synthesis: how virtualisation plus a library OS
gives us something we can actually run, and a pointer to Solo5 as a
modern tender built specifically for unikernels.

:::slide

## Where we are

- M12-L01: kernels are huge.
- M12-L02: library OS shrinks the kernel but loses internal
  protection and shoulders the driver burden.
- M12-L03: **virtualisation** restores protection between library
  OSes, and lets the host take care of drivers.
- M12-L04: OCaml gives us safety **within** a library OS.

:::

## What virtualisation is

Virtualisation, in the sense we care about, is the technology that
lets multiple operating systems run on the same physical machine, each
believing it has the whole machine to itself. The piece of software
that maintains that illusion is called a *hypervisor* (or, equivalently,
a *Virtual Machine Monitor*, VMM). The hypervisor is what creates and
runs virtual machines. Each VM is a self-contained execution
environment with what looks, to its guest OS, like its own CPU, its
own memory, its own disks, and its own network cards.

The hardware support that makes modern virtualisation cheap arrived in
the early 2000s. Intel added VT-x; AMD added AMD-V. These extensions
gave the CPU a new privilege level above the conventional kernel
ring, plus a hardware-managed page-table layer (extended page tables,
or EPT, on Intel; rapid virtualisation indexing, RVI, on AMD), so the
hypervisor could enforce isolation between guests with very little
runtime overhead. Before these extensions, software-only virtualisation
existed (think VMware in the late 1990s) but it required heroic
binary translation and was not cheap. After the hardware extensions,
running a guest OS on a hypervisor costs only a few percent more than
running it on bare metal for most workloads.

The two things to take away here are: hypervisors are not new (the
idea goes back to IBM's CP/CMS in the 1960s), and hardware support
has made them ubiquitous. Every cloud provider runs their customer
workloads as VMs on top of some hypervisor. Your AWS EC2 instance,
your GCP Compute Engine VM, your Azure VM: under the hood, those are
guest OSes on a hypervisor.

:::slide

## Virtualisation in one paragraph

- Hardware extensions in the 2000s (Intel VT-x, AMD-V) made it cheap.
- A **hypervisor** (also called a **VMM**) creates and runs virtual
  machines.
- Multiple VMs share one physical machine, **isolated by the
  hypervisor**.
- Every cloud provider deploys their customers' workloads this way.
- The canonical academic citation is **Xen and the Art of
  Virtualization** (Barham et al., SOSP 2003).

:::

## Type-1 and Type-2 hypervisors

Hypervisors are conventionally classified into two types depending on
where they sit relative to the host hardware.

A **Type-1 hypervisor** runs directly on the hardware. It is its own
operating system, in the sense that it boots first and manages CPU,
memory, and interrupts itself. Guest OSes run on top of it.
Xen, originally from the University of Cambridge, is the canonical
Type-1 hypervisor. So is VMware ESXi. So is Hyper-V on Windows
Server in certain modes. Type-1 hypervisors are typical of
datacentre and cloud environments where every server is dedicated to
running VMs.

A **Type-2 hypervisor** runs as an application on top of a
conventional operating system. The host OS provides the drivers and
the scheduling; the hypervisor adds the VM-creation machinery on top.
VirtualBox is a canonical Type-2; so is VMware Workstation; so is
the original VMware Server. These are what you typically install on
a developer's laptop to run a Windows VM on Linux or vice versa.

The two types blur in practice. The most important example is **Linux
KVM**, which is structurally a Type-2 (it runs as a Linux kernel
module on top of a fully functional Linux) but is performant enough
and integrated tightly enough with the Linux kernel that for most
purposes it behaves like a Type-1. We say it "turns Linux into a
Type-1 VMM": Linux is still there, but it is being used as a
hypervisor more than as a general-purpose OS for the host.

:::slide

## Two types of hypervisor

| Type | Runs on... | Examples |
| --- | --- | --- |
| **Type-1** | Bare metal | Xen, VMware ESXi, Hyper-V |
| **Type-2** | A conventional host OS | VirtualBox, VMware Workstation |

- Type-1 typical of datacentres and cloud.
- Type-2 typical of developer laptops.
- **Linux KVM** sits between: Type-2 in structure, Type-1 in
  feel.

:::

The reason this taxonomy matters for us is that MirageOS unikernels
typically run as guests under a Type-1 (or Type-1-feeling) hypervisor
in production. The host machine has Linux with KVM, or Xen, or a
small dedicated stack like Solo5; each unikernel is a guest VM with
no Linux of its own.

## Linux KVM in detail

KVM stands for Kernel-based Virtual Machine. It is a kernel module
that ships with mainline Linux. When loaded, it exposes the hardware
virtualisation extensions (VT-x or AMD-V) to userspace, so that any
process can use them to create and run VMs. The piece that *creates*
the VM is typically a userspace program called QEMU, which has been
the canonical KVM frontend for over a decade.

Here is the picture, layered top to bottom:

- A small set of **userspace processes** on the host: a shell, the
  Linux init, your monitoring agents.
- For each VM, a **QEMU-KVM process** in userspace that uses the KVM
  kernel API. This process is what represents the VM to the host.
- Inside the VM, a **guest kernel** (Linux, Windows, or, in the
  MirageOS case, the unikernel image itself), and **guest userspace
  processes** running on top of that guest kernel.
- The **Linux kernel** on the host, with the **KVM module** loaded
  inside it.
- The **hardware** at the bottom, with VT-x / AMD-V extensions
  active.

QEMU's job is to emulate any hardware the guest expects that the host
hardware does not provide directly. The guest thinks it has a PCI
bus; QEMU emulates one. The guest thinks it has an IDE disk; QEMU
emulates one and backs it with a file on the host. The guest thinks
it has a serial port; QEMU pipes it to a terminal. The KVM module
intercepts the privileged operations (port I/O, control-register
writes, page-table updates) and either handles them in the kernel
fast path or kicks them out to QEMU for slower-path emulation.

![Linux KVM architecture: host userspace processes plus a QEMU-KVM
process running a guest with its own kernel and userspace, all on top
of a Linux kernel that has the KVM module loaded, on hardware with
VT-x / AMD-V extensions. A side panel notes the library-OS "cons"
with "device drivers all need to be rewritten" struck
through.](/assets/m12/figures/slide-18-linux-kvm.svg)

The same layering rendered as a slide-mode ASCII fallback:

:::slide

## Linux KVM, layered

```
+----+----+----+   +------+
| up | up | up |   | guest|
+----+----+----+   | user |
                   +------+
                   | guest|
                   |kernel|
                   +------+
                   | QEMU |
                   | KVM  |
+----------------------------+
| Linux Kernel  [KVM module] |
+----------------------------+
| Hardware  (VT-x / AMD-V)   |
+----------------------------+
```

- **Turns Linux into a Type-1 VMM** in practice.
- **QEMU** emulates CPUs and missing hardware.
- The KVM kernel module is the privileged piece.

:::

## VirtIO: paravirtualisation for the common case

Emulating real hardware (a particular Intel NIC, a particular SCSI
controller) is faithful but slow. For every packet, QEMU has to
emulate the device's register reads and writes, walk the device's
queues, and translate between the guest's view of the world and the
host's. The performance overhead can be significant on I/O-heavy
workloads.

The fix is *paravirtualisation*: instead of emulating real hardware,
expose a small, virtualisation-aware interface that the guest can
talk to natively. The standard for this is called **VirtIO**, a set
of conventions for virtual block devices, virtual network cards,
virtual consoles, and so on. A VirtIO network card is not a
particular Intel chip; it is a simple ring-buffer-based protocol that
the host implements directly and the guest's driver speaks. The
overhead is much lower because no real-hardware emulation is being
done.

This matters for MirageOS in two ways. First, MirageOS unikernels
target the VirtIO interface (among others), which means they can run
unmodified on KVM, Xen, and several other hypervisors that all
implement VirtIO. Second, because the VirtIO interface is *small and
stable*, MirageOS only needs to implement drivers for VirtIO devices,
not for the long tail of real hardware. The driver-burden problem
from M12-L02 largely evaporates: the host hypervisor (or Solo5) does
the hard work of talking to the actual network card, and the
unikernel only needs to talk to the abstract VirtIO ring.

:::slide

## VirtIO: a small, virtualisation-aware device interface

- Instead of emulating "an Intel e1000 NIC", expose a generic
  virtual NIC with a ring-buffer protocol.
- Guest's "driver" is small, fast, hypervisor-agnostic.
- **MirageOS unikernels target VirtIO**, which means:
  - One driver implementation works across KVM, Xen, etc.
  - **The driver-burden problem from M12-L02 mostly goes away.**

:::

## How virtualisation fixes library-OS isolation

We can now answer the question the activity-question of this lecture
opens with: if a library OS has no internal MMU protection, how is it
secure? The answer is that *inside* one unikernel image there is no
internal isolation, and OCaml's type system has to do that job (this
is M12-L04's argument). *Between* unikernel images, the hypervisor's
guest-host boundary provides isolation just as strong as the
conventional user-kernel boundary, and arguably stronger because the
hypervisor's API surface is much smaller than the Linux syscall
surface.

Concretely: if you deploy two MirageOS unikernels on the same host,
each in its own VM, a memory-safety bug in unikernel A cannot reach
into unikernel B, because the EPT/RVI hardware-managed page tables
do not allow it. The hypervisor enforces this with hardware support;
no software in either guest can defeat it. Compare this with two
processes on the same Linux kernel: a kernel CVE that escalates
privilege from process A can take down or compromise the whole
machine, including process B. The trust model is different.

The slogan from the talk is that the library-OS "con" of *"no kernel
protection internally, and device drivers all need to be rewritten
from a normal kernel"* gets struck through twice once you add
virtualisation. The first half ("no kernel protection internally") is
still true *within* one unikernel, and OCaml will help with that. The
second half ("device drivers all need to be rewritten") is no longer
true: VirtIO is the only device class the unikernel needs to support,
and that single driver suite works against every modern hypervisor.

![Memory-safety slide with the library-OS "Cons" panel underneath:
the whole "There is no kernel protection internally, and device
drivers all need to be rewritten from a normal kernel" line is struck
through in red, signalling that virtualisation (and the OCaml
ingredient in M12-L04) collectively close out both
halves.](/assets/m12/figures/slide-23-memory-safety-strikethrough.svg)

The figure above is the talk's "strike through the con" beat: the
same Cons sentence M12-L02 ended on is reproduced and crossed out
once virtualisation (this lecture) and language safety (M12-L04) are
both in hand.

:::slide

## Library OS + virtualisation: what changes

- **Cross-unikernel protection**: the hypervisor enforces it with
  hardware page tables. Strong, small attack surface.
- **Driver burden**: drastically reduced. Implement VirtIO drivers
  once; they work on KVM, Xen, anything VirtIO-aware.

The original M12-L02 cons:

> Cons: There is no kernel protection internally,
> ~~and device drivers all need to be rewritten from a normal kernel.~~

The crossed-out half is now solved.

:::

## Solo5: a tender for unikernels

QEMU is a powerful but heavy tool. It is designed to emulate full
PCs, with BIOSes, PCI buses, and dozens of device models. A
MirageOS unikernel does not need any of that: it boots with a
specific small set of expectations (a memory map, a console, a
network, a clock) and has no need for an emulated CD-ROM drive.
Running a unikernel under full QEMU is technically possible but
wasteful.

**Solo5** is a small, modern *tender* (a host-side bootstrap and
runtime) built specifically for unikernels. It is much lighter than
QEMU: a few thousand lines of C, no general-purpose machine
emulation, no virtual PCI bus. It supports multiple backend modes:

- `solo5-hvt` runs on top of KVM as the "hardware virtualisation
  tender."
- `solo5-spt` runs on Linux using only seccomp filters, no
  hypervisor, as a sandboxed Linux process. Useful for development
  and for environments where KVM is not available.
- Solo5 also has backends for Xen, muen, and others.

For MirageOS specifically, Solo5 is the typical production deployment
target. The unikernel image is an ELF binary compiled to talk to
Solo5's small ABI; Solo5 sets up the VM (or the seccomp sandbox), maps
the memory, attaches the virtual network and disk, and jumps into the
unikernel's entry point. We will look at exactly this in
[M12-L05](M12-L05-mirageos.html).

:::slide

## Solo5: the modern unikernel tender

- A small host-side bootstrap, much lighter than QEMU.
- Built specifically for unikernels: no PCI emulation, no CD-ROM,
  no BIOS.
- Backends include:
  - `solo5-hvt`: on top of KVM.
  - `solo5-spt`: as a sandboxed Linux process with seccomp.
  - Xen, muen, virtio.
- The typical production deployment substrate for MirageOS.

:::

## Worth picturing

A useful mental model: a host machine running Linux + KVM has, in
addition to the usual Linux processes (a shell, an SSH daemon, a
monitoring agent), several **unikernel guests** running side by side.
Each guest is a tiny self-contained OS image, perhaps 5 to 20 MB,
booted in milliseconds. Each one talks to the outside world through
VirtIO. The hypervisor isolates them from each other. If one of them
has a bug and crashes, only that guest dies; the host and the others
are untouched. If you need to deploy a new version of one of them, you
shoot the old guest and start the new one; the boot time is small
enough that this is essentially instantaneous.

This is a very different operational picture from "one big Linux
running many services." It is closer to "many small Linux-shaped
things, each handling one job, each independently restartable, each
with a TCB the size of itself rather than the size of a whole
distribution."

## Activity

:::quiz mcq id=M12-L03-q1
The conventional library-OS criticism from M12-L02 was that it has no
internal kernel protection and that device drivers all need to be
rewritten. Which of the following best describes how adding
virtualisation changes those criticisms?

- [ ] Both criticisms are eliminated entirely; with a hypervisor,
  every memory access inside the guest is checked.
- [ ] Both criticisms remain; virtualisation only affects
  performance.
- [x] Cross-unikernel protection is provided by the hypervisor's
  hardware page tables; the driver burden is largely solved by
  paravirtualised interfaces like VirtIO. Internal-to-the-unikernel
  protection is still missing and is OCaml's job.
- [ ] Virtualisation eliminates the driver problem but makes the
  internal-protection problem worse.

**Why:** the hypervisor isolates *guests* from each other, not parts
*within* one guest; for protection inside one unikernel we still need
the type-system story from M12-L04. The driver problem is reduced to
"implement VirtIO once," which is feasible. The combination of
library-OS plus virtualisation is genuinely deployable; adding OCaml
gives us the third ingredient.
:::

:::quiz mcq id=M12-L03-q2
Which statement most accurately distinguishes a Type-1 hypervisor
from a Type-2 hypervisor?

- [ ] Type-1 hypervisors are faster; Type-2 hypervisors are slower.
- [x] A Type-1 hypervisor runs directly on the hardware (it is its
  own OS); a Type-2 runs as an application on a conventional host
  OS.
- [ ] Type-1 hypervisors can run multiple guests; Type-2 can only
  run one.
- [ ] Type-1 hypervisors use hardware virtualisation extensions;
  Type-2 hypervisors do not.

**Why:** the defining structural distinction is where the hypervisor
sits in the stack. Both can be fast, both can run multiple guests,
both can use hardware extensions today. Linux KVM is the famous
in-between case; structurally Type-2 (it loads into a Linux that is
also running normal processes), in feel Type-1 (the Linux underneath
is doing very little besides hosting guests).
:::

:::slide

## Activity discussion

- The hypervisor closes the **cross-unikernel** isolation gap.
- VirtIO closes the **driver-burden** gap.
- Type-1 vs Type-2 is about *where the hypervisor sits*, not about
  speed or features.
- MirageOS deployments use KVM via Solo5 in practice.

:::

## Common pitfalls

**Pitfall 1: "A VM is just a process."** Functionally similar from the
outside, but structurally different. A process trusts the host
kernel completely; a VM has its own kernel and only trusts the
hypervisor's tiny interface. The TCB of a process is the whole host
Linux; the TCB of a VM is the hypervisor and the guest's own kernel.

**Pitfall 2: "VirtIO is a Linux thing."** VirtIO is a cross-OS
standard; the spec is maintained by OASIS. Linux happens to be where
much of the development is centred, but Windows, FreeBSD, and
unikernels including MirageOS all speak VirtIO natively.

**Pitfall 3: "Containers are VMs."** They are not. Containers are
processes on the host kernel with a different namespace view; they
share the kernel and the kernel CVEs. VMs are different machines
sharing a hypervisor.

**Pitfall 4: "Hypervisors are inherently slow."** With hardware
extensions, the per-VM overhead on most modern workloads is in the
low single-digit percent. The interesting overhead is in the I/O
path, and that is exactly what VirtIO is engineered to minimise. For
many workloads, a unikernel on a hypervisor is *faster* than the
equivalent Linux process, because the unikernel runs its own scheduler
and skips the syscall boundary entirely.

## What's next

We have now seen two of the three ingredients. The third, in
[M12-L04](M12-L04-ocaml-for-systems.html), is OCaml itself. The
question that lecture answers: given that the library-OS approach
gives up the internal MMU boundary, what *does* protect one part of
the unikernel from another? The answer is: a memory-safe language
with strong types. That brings the safety story back to the M10
material on memory safety and applies it at the OS level.

:::slide

## What's next

- Lecture 4: **Ingredient 3, OCaml for systems.** Why a memory-
  safe language matters when the MMU isn't there to save you.
- Lecture 5: **MirageOS = Library OS + Virtualisation + OCaml.**

:::

## Reading

- **Barham, Dragovic, Fraser, Hand, Harris, Ho, Neugebauer, Pratt,
  Warfield**, *Xen and the Art of Virtualization*, SOSP 2003:
  <https://www.cl.cam.ac.uk/research/srg/netos/papers/2003-xensosp.pdf>
- **Solo5**, the modern unikernel tender:
  <https://github.com/Solo5/solo5>
- **VirtIO** specification (OASIS):
  <https://docs.oasis-open.org/virtio/virtio/v1.2/virtio-v1.2.html>
- **KVM** project home:
  <https://www.linux-kvm.org/>

## Sources

This lecture's prose, worked examples, and quizzes are original to
this course. The library-OS-plus-virtualisation framing, the Linux
KVM diagram, and the strike-through-the-con argument follow KC
Sivaramakrishnan's January 2025 IIT Madras talk *Towards smaller,
safer, bespoke OSes with Unikernels*, slides 16 to 18. The
*Xen and the Art of Virtualization* citation is the standard
academic anchor for the modern hypervisor era. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
