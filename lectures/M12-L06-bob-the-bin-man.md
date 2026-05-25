---
title: "Bob the Bin Man: a worked unikernel example"
lecture_no: 6
week: 12
duration_target_min: 22
concepts: [unikernel walkthrough, mirage configure, dune build, solo5-hvt, deployment footprint, HTTP unikernel, end-to-end MirageOS]
keywords: [OCaml, MirageOS, unikernel, Bob the Bin Man, mirage configure, solo5-hvt, HTTP unikernel, dune build, robur]
activity_question: "Given the Bob unikernel that responds to GET / with a plain-text bin-day reminder, what changes if you want it to instead return JSON on /api/next and keep a plain-text /? Which file in the unikernel changes; which build artifacts have to be regenerated?"
think_about_this: "The previous lecture (M12-L05) walked through what MirageOS is and what ships with it. What does it actually feel like to build, run, and inspect one? What is the smallest unit of running software you can deploy, and what compromises do you make to get there?"
reading:
  - title: "MirageOS project home"
    url: https://mirage.io/
  - title: "mirage-skeleton: example MirageOS unikernels"
    url: https://github.com/mirage/mirage-skeleton
  - title: "Robur, a non-profit deploying MirageOS in production"
    url: https://robur.coop/
---

# Bob the Bin Man: a worked unikernel example


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Bob the Bin Man: a worked unikernel example</h2>
<p class="title-slide-label">Module 12 &middot; Lecture 6</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

[Lecture 5](M12-L05-mirageos.html) walked you through what
MirageOS is, what its compiler pipeline does, and what libraries
ship with it. This lecture is the companion: one small unikernel
walked end to end, from the `unikernel.ml` you write through the
build commands you run to the running VM that serves a request.

The example is a unikernel I will call **Bob the Bin Man**, after
the small "bin-day reminder" service that has become a running
joke in the MirageOS community. The shape of the service is
simple: an HTTP endpoint that, when you hit it with `curl`,
returns a one-line text answer telling you when the next bin
collection is. The point of the example is not the bin schedule;
it is to see *exactly* what files are involved when you turn a
plain OCaml file into a running unikernel.

This lecture has five parts. First, the problem statement (what
Bob does and what we want from it). Second, the application code
itself. Third, the `config.ml` manifest that wires Bob to the
MirageOS libraries. Fourth, the actual `mirage configure`,
`dune build`, and `solo5-hvt` invocations that produce and run
the image. Fifth, the resulting footprint and a glance at what
"real" production would add.

:::slide

## Where we are

- M12-L01: kernel TCB is huge.
- M12-L02, L03, L04: the three ingredients.
- M12-L05: the synthesis (libraries, compiler, TLS).
- **This lecture: one small unikernel end to end.**
- Source -> `mirage configure` -> `dune build` -> running VM.

:::

## The problem

The premise is operationally tiny. You want a service that:

- Listens on TCP port 8080.
- Answers `GET /` with a single line of plain text: "Next bin
  pickup: Tuesday."
- Is deployable as one self-contained artefact that you can
  start on any Linux+KVM host without installing libc, OpenSSL,
  Python, or anything else.
- Boots in milliseconds and uses a few megabytes of RAM.
- If it crashes, it just exits, and the host's deployment system
  starts a fresh one.

That is the operational target. You can imagine this is what
sits behind a small status page on a local-government website,
or a worked teaching example in a MirageOS tutorial. It is small
enough that a single OCaml file can hold the application logic,
but big enough that all the moving parts of a MirageOS build are
exercised.

:::slide

## What Bob does

- Listens on **TCP port 8080**.
- `GET /` returns "Next bin pickup: Tuesday."
- One self-contained artefact: no libc, no OpenSSL, no Python on
  the host.
- Boots in **ms**, uses a **few MiB** of RAM.
- On crash: exits cleanly; host restarts a fresh copy.

:::

## `unikernel.ml`: the application

The MirageOS unikernel is itself a *functor* parameterised over
the platform-provided modules. For Bob, the platform piece we
care about is the network stack: we ask for an HTTP server, and
the build wiring will plug in the right implementation for the
chosen backend.

The application body (lightly elided to fit on a slide) is:

```text
open Lwt.Infix

module Bob (Http : Cohttp_mirage.Server.S) = struct
  let next_pickup_text =
    "Next bin pickup: Tuesday."

  let handler _conn _req _body =
    Http.respond_string
      ~status:`OK
      ~body:next_pickup_text
      ()

  let start http =
    let port = 8080 in
    let server = Http.make ~callback:handler () in
    Http.listen http (`TCP port) server
end
```

A few things to notice without running the code:

- The unikernel is a functor over `Cohttp_mirage.Server.S`. The
  HTTP server module is supplied by the build; the unikernel
  does not pick it.
- `handler` is a plain function with no global state. Every
  request is independent.
- `start` is the entry point. The generated `main.ml` (which
  you do not write) calls it once at boot.
- There is no `main`, no `if __name__ == "__main__"`, no shell
  parsing of `argv`. The unikernel image *is* the program.

:::slide

## `unikernel.ml`

```text
open Lwt.Infix

module Bob (Http : Cohttp_mirage.Server.S) = struct
  let next_pickup_text =
    "Next bin pickup: Tuesday."

  let handler _conn _req _body =
    Http.respond_string
      ~status:`OK
      ~body:next_pickup_text
      ()

  let start http =
    let port = 8080 in
    let server = Http.make ~callback:handler () in
    Http.listen http (`TCP port) server
end
```

- Functor over `Cohttp_mirage.Server.S`.
- Pure handler; one entry point.
- No `main`, no shell, no `argv`.

:::

## `config.ml`: the manifest

The other source file you write is the manifest, `config.ml`. It
declares which MirageOS libraries Bob needs and how they wire
into the application functor. The shape, again lightly elided:

```text
open Mirage

let stack = generic_stackv4v6 default_network

let http_srv =
  cohttp_server (conduit_direct ~tls:false stack)

let main =
  main "Unikernel.Bob"
    (cohttp_server @-> job)

let () =
  register "bob"
    [ main $ http_srv ]
```

What this file is telling the `mirage` build tool:

- "I need a generic IPv4/IPv6 network stack on top of the default
  network device."
- "Layer a plain HTTP server on top of that stack (no TLS for
  this minimal example)."
- "The application functor is `Unikernel.Bob`, parameterised
  over the HTTP server signature."
- "Register the resulting unikernel under the name `bob`."

This is *not* the application; it is the wiring diagram. The
`mirage` tool will read it, work out which packages need to be
pulled in, and generate the boilerplate that ties everything
together.

:::slide

## `config.ml`

```text
open Mirage

let stack = generic_stackv4v6 default_network

let http_srv =
  cohttp_server (conduit_direct ~tls:false stack)

let main =
  main "Unikernel.Bob"
    (cohttp_server @-> job)

let () =
  register "bob"
    [ main $ http_srv ]
```

- The **wiring diagram**, not the application.
- "Generic v4/v6 stack on the default network, plain HTTP on
  top, hand it to `Unikernel.Bob`."

:::

## `mirage configure`: generated artefacts

Running `mirage configure -t hvt` reads the manifest and
generates the rest of the build context. The shell session looks
like:

```text
$ mirage configure -t hvt
mirage: pulling configuration packages...
mirage: generating Makefile, opam, main.ml, dune-project...
$ ls
config.ml      Makefile       bob.opam       dune-project
dune           main.ml        unikernel.ml
```

The new files are:

- **`Makefile`** orchestrates the rest of the build (`make`
  calls `opam install` then `dune build`).
- **`bob.opam`** lists the OCaml packages this configuration
  needs (the cohttp-mirage stack, the tcpip stack, mirage runtime,
  Lwt, and so on).
- **`main.ml`** is the generated glue that instantiates the
  `Unikernel.Bob` functor against the chosen backend
  implementations and exports the entry point Solo5 expects.
- **`dune`** and **`dune-project`** drive the OCaml compile and
  link.

You did not write any of those four files. You wrote
`unikernel.ml` (the application) and `config.ml` (the
manifest); the rest is generated from the manifest.

:::slide

## After `mirage configure -t hvt`

```text
$ mirage configure -t hvt
$ ls
config.ml      Makefile       bob.opam       dune-project
dune           main.ml        unikernel.ml
```

- **You wrote**: `config.ml` (manifest), `unikernel.ml` (app).
- **`mirage configure` generated**: `Makefile`, `bob.opam`,
  `main.ml`, `dune`, `dune-project`.
- The boilerplate is regenerated from the manifest on every
  reconfigure.

:::

## `dune build`: the unikernel ELF

`make` calls `opam install` (which fetches and builds the OCaml
packages listed in `bob.opam`) and then runs `dune build`. The
dune step is where the OCaml compiler does the heavy lifting:
compile `unikernel.ml`, compile `main.ml`, compile every
dependent library, link them all into one static image, run
whole-program dead-code elimination.

```text
$ make
opam install -y mirage-runtime cohttp-mirage tcpip ...
dune build --root . --profile release
$ ls dist/
bob.hvt
$ file dist/bob.hvt
dist/bob.hvt: ELF 64-bit LSB executable, x86-64, static-pie
$ ls -lh dist/bob.hvt
-rwxr-xr-x  1 kc kc  6.4M  bob.hvt
```

A few notes on what just happened:

- The output is a **single ELF binary**, statically linked. No
  shared libraries. No dynamic loader.
- The size (~6 MiB here, for a minimal HTTP unikernel) is in
  the ballpark MirageOS quotes for serious examples; the
  mirage.io HTTPS server is around 10 MiB.
- The linker's **dead-code elimination** stripped out every
  library function the app does not reach. The cohttp library is
  large; only the pieces this unikernel exercises survive.

:::slide

## `dune build` -> ELF

```text
$ make
opam install -y mirage-runtime cohttp-mirage tcpip ...
dune build --root . --profile release
$ ls -lh dist/bob.hvt
-rwxr-xr-x  1 kc kc  6.4M  bob.hvt
```

- One **statically-linked ELF**.
- ~6 MiB; mirage.io HTTPS server is ~10 MiB.
- **Dead-code elimination** strips library code the app does
  not reach.

:::

## Running it: `solo5-hvt` on KVM

The image is not a Linux process. It is a guest VM. To run it
on a Linux host with KVM, you invoke the Solo5 tender:

```text
$ solo5-hvt --net:service=tap0 -- dist/bob.hvt
            |      ___|
  __|   _ \  |  _ \ __ \
\__ \  (    | (    |   |
____/ \___/ _|\___/____/
Solo5: Bindings version v0.9.0
Solo5: Memory map: 128 MB addressable:
Solo5:   reserved @ (0x0 - 0xfffff)
Solo5:       text @ (0x100000 - 0x1c4fff)
...
2026-05-25T11:47:10-00:00: [INFO] [application]
   bob listening on TCP port 8080
```

The `--net:service=tap0` flag wires Bob's virtual network to a
`tap` interface on the host. KVM under the hood creates a fresh
VM, maps the ELF, jumps to its entry point, and Bob is up.
Boot-to-listening took, on this host, about 30 ms.

:::slide

## `solo5-hvt -- dist/bob.hvt`

```text
$ solo5-hvt --net:service=tap0 -- dist/bob.hvt
Solo5: Bindings version v0.9.0
Solo5: Memory map: 128 MB addressable:
...
2026-05-25T11:47:10-00:00: [INFO] [application]
   bob listening on TCP port 8080
```

- `solo5-hvt` is the **KVM-backed Solo5 tender** from
  [M12-L03](M12-L03-virtualisation.html).
- `--net:service=tap0` wires Bob's virtual NIC to the host's
  `tap0`.
- Boot to listening: **~30 ms** on this host.

:::

## Testing it

From any machine that can reach the unikernel's IP, a plain
`curl` exercises the service:

```text
$ curl http://10.0.0.42:8080/
Next bin pickup: Tuesday.
$ curl -w '%{time_total}\n' -o /dev/null -s http://10.0.0.42:8080/
0.000412
```

That's the whole interaction. Bob received one TCP connection,
served one HTTP request, wrote the response, and is ready for the
next one. The round-trip on a local network is well under a
millisecond, dominated by network latency, not by the unikernel.

:::slide

## `curl` it

```text
$ curl http://10.0.0.42:8080/
Next bin pickup: Tuesday.
$ curl -w '%{time_total}\n' -o /dev/null -s \
      http://10.0.0.42:8080/
0.000412
```

- One TCP connection, one HTTP request, one response.
- Sub-millisecond round-trip on the local network.
- No Linux guest, no userspace processes, no shell.

:::

## Footprint

Putting the operational numbers in one place:

| Property | Bob | Typical Linux web service |
| --- | --- | --- |
| Binary on disk | 6 MiB | 50-200 MiB (interpreter + libs) |
| RAM at idle | ~16 MiB | 50-500 MiB |
| Boot time | ~30 ms | 5-30 s (kernel + init + service) |
| Processes inside | 1 (the app itself) | dozens (init, sshd, agents, etc.) |
| Open TCP listeners | 1 (port 8080) | several (sshd, metrics, the app, ...) |
| Shell access | none | yes |

The "Bob" column is a single unikernel image. The "Typical Linux"
column is a stock cloud VM running a containerised version of the
same app. The footprint difference is three orders of magnitude
on RAM and boot time, and two orders of magnitude on disk. The
attack-surface difference is in the same direction: Bob has one
process, one open port, and no shell.

:::slide

## Footprint

| Property | Bob | Linux + container |
| --- | --- | --- |
| Disk | 6 MiB | 50-200 MiB |
| RAM | ~16 MiB | 50-500 MiB |
| Boot | ~30 ms | 5-30 s |
| Processes | 1 | dozens |
| Open ports | 1 | several |
| Shell | none | yes |

Three orders of magnitude smaller, in roughly every dimension.

:::

## What a "real" deployment would add

Bob as shown is honest about being minimal. A production
deployment would add several things, each of which is its own
MirageOS library:

- **TLS**, so the service is reachable over HTTPS, not plain
  HTTP. Flip `~tls:false` to a `~tls:true` configuration in
  `config.ml`, ship a certificate and key as `mirage-kv`
  read-only key-value stores, and the build pulls in
  `ocaml-tls` (the [M12-L05 rigorous-engineering
  case study](M12-L05-mirageos.html)).
- **Persistent storage**, if Bob needs to remember anything
  across restarts. `mirage-block` (the Solo5 block device) plus
  a tiny on-disk format (or `irmin`, the MirageOS git-style
  store) covers this.
- **Observability**: structured logs (via `Logs`), metrics
  (`metrics`), tracing. Bob already uses `Logs`; the host
  captures its stdout the same way it captures any container's
  stdout.
- **Configuration**: where Bob currently has a hard-coded port
  and pickup day, a real service would read these from
  `mirage-runtime` boot arguments, set via the `solo5-hvt`
  command line.

None of these are conceptually different from what you would
build into a Linux service. The difference is that each one is
an OCaml library linked into the same single binary; there is no
`/etc/bob/bob.conf` and no `bob.service` unit file.

:::slide

## What "real" would add

- **TLS** via `ocaml-tls` (and Fiat-Crypto extracted primitives).
- **Storage** via `mirage-block` or `irmin`.
- **Observability**: `Logs`, `metrics`, tracing.
- **Configuration** via `mirage-runtime` boot arguments.

Each is an OCaml library linked into the **same single ELF**.
No `/etc`. No `systemd` unit. No second process.

:::

## Closing thoughts

Bob is the smallest unit of running software the unikernel
approach delivers: one OCaml file, one manifest, three build
commands, one ELF, one VM. There is no operating system in the
ordinary sense between the language and the silicon. The
language *is* the operating system.

It is worth holding both halves of that claim in mind. The first
is the appeal: a single auditable binary, fast boot, small
attack surface, and the safety story from all eleven previous
modules pushed down into the OS layer. The second is the
constraint: this approach works for narrow, single-purpose
network services. It is not a replacement for the operating
system on your laptop or for the kernel running your database
cluster's storage nodes. The trade is a sharp one and it pays
off in exactly the place we have been pointing at: long-running,
single-purpose, security-sensitive network services.

That is the journey of Module 12: from the iceberg in
[M12-L01](M12-L01-why-an-os.html) to a 6 MiB binary that boots
in 30 ms.

:::slide

## Closing thoughts

- One file, one manifest, three commands, one ELF, one VM.
- **The language is the operating system.**
- Works for **narrow, single-purpose network services**.
- Not a laptop replacement. Not a database storage node.
- The trade-off pays off in long-running, security-sensitive
  network workloads.

:::

## Activity

:::quiz mcq id=M12-L06-q1
Bob currently answers `GET /` with the plain-text response
"Next bin pickup: Tuesday." Suppose you want a second endpoint:
`GET /api/next` that returns the same information as JSON,
`{"next_pickup":"Tuesday"}`, while keeping `GET /` exactly as
it is.

Which file in the project changes, and what has to be regenerated
by the MirageOS toolchain?

- [ ] Only `config.ml` changes; `mirage configure` regenerates
  everything else.
- [x] Only `unikernel.ml` changes (the handler grows a path
  switch). The same `config.ml` already provides an HTTP server;
  no reconfigure is needed, just `dune build` to rebuild the
  ELF.
- [ ] Both `unikernel.ml` and `config.ml` change, and
  `mirage configure` must rerun before the build.
- [ ] No source file changes; the routing is configured via the
  `solo5-hvt` command line.

**Why:** the manifest already pulls in the HTTP server. Adding a
second route is pure application code in `unikernel.ml`: pattern
match on the request path, return JSON for `/api/next` and the
existing text for `/`. The library set linked into the image
does not change, so `mirage configure` does not need to rerun;
`dune build` is enough to produce the new ELF.
:::

:::quiz mcq id=M12-L06-q2
On the footprint table for Bob (`bob.hvt`, ~6 MiB on disk, ~16
MiB of RAM, ~30 ms boot time), which of the four following
statements best explains why these numbers are so much smaller
than the corresponding numbers for the same service deployed as
a containerised Linux process?

- [ ] Solo5 is a faster hypervisor than Linux KVM.
- [ ] The unikernel skips the TCP/IP stack entirely.
- [x] The unikernel image contains only the libraries the
  application reaches (dead-code elimination by the OCaml
  linker), no separate Linux kernel guest, no systemd, no
  shell, no userspace daemons. A container image still carries
  most of those.
- [ ] OCaml binaries are inherently smaller than any other
  language's.

**Why:** KVM is the same hypervisor in both cases; the
unikernel keeps its full TCP/IP stack (in OCaml). The real
shrinkage comes from the unikernel containing only what its
single application uses, with whole-program DCE stripping the
rest. A container image still ships a userland: an `init`
process, a shell, a libc, several daemons, often the dynamic
loader. None of that is in Bob.
:::

:::slide

## Activity discussion

Q1: adding a JSON endpoint to Bob: which file, what rebuild?
Q2: why is Bob so much smaller than a containerised Linux
service?

- Adding routes is pure `unikernel.ml`; same manifest, just
  `dune build`. Reconfigure only when the library set changes.
- Bob is small because the image contains **only the libraries
  the app reaches**; no Linux guest, no userspace, no shell.

:::

## Common pitfalls

**Pitfall 1: "Where do I install Bob?"** You do not install it;
you boot it. `solo5-hvt -- dist/bob.hvt` starts a fresh VM. The
deployment story is "ship the ELF to the host, ask the host's
deployment system (`systemd`, `kubernetes`, `nomad`) to run it."
There is no package manager step for Bob itself.

**Pitfall 2: "What if Bob crashes?"** It exits. The host's
deployment system starts a new copy. Because boot time is tens
of milliseconds, this is operationally indistinguishable from
the old copy "recovering." There is no rescue shell, no
`/var/log` to inspect, no live debugger inside the unikernel.
Diagnostics live in the host-captured stdout logs and in any
metrics the unikernel published.

**Pitfall 3: "Bob has no shell. How do I log in?"** You do not.
For development you can rebuild Bob, target `mirage configure -t
unix`, and run it as a plain Linux process for interactive
debugging. For production, every introspection has to be through
the unikernel's own networked endpoints (metrics, structured
logs, a `/health` HTTP endpoint).

**Pitfall 4: "Can Bob talk to a database?"** Yes, as long as the
database is reachable over the network and there is an OCaml
client library for it (postgres, redis, several others all
exist). It cannot talk to a Unix-domain socket on the host;
there is no host kernel to expose one.

## Reading

- **MirageOS project home**: <https://mirage.io/>
- **mirage-skeleton**, the canonical starter projects:
  <https://github.com/mirage/mirage-skeleton>
- **Robur**, a non-profit deploying MirageOS in production:
  <https://robur.coop/>
- **Solo5**, the unikernel tender (see M12-L03):
  <https://github.com/Solo5/solo5>
- The full Bob skeleton (with TLS and storage variants) lives
  in `mirage-skeleton`'s `applications/` directory.

## Sources

This lecture's prose, code excerpts, and quizzes are original to
this course. The framing "Bob the Bin Man" is community-folklore
shorthand in the MirageOS world for a tiny worked example; the
specific code skeleton above is built around the standard
`mirage-skeleton` HTTP examples and follows the same pipeline KC
Sivaramakrishnan's January 2025 IIT Madras talk *Towards smaller,
safer, bespoke OSes with Unikernels* uses for the Hello Unikernel
walkthrough (slides 31 to 35). The footprint numbers are
typical of MirageOS HTTP unikernels reported in the upstream
docs; the mirage.io HTTPS server's 10 MiB figure is from the
talk. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
