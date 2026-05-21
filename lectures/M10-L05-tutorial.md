---
title: "Tutorial: walking Heartbleed end to end"
lecture_no: 5
week: 10
duration_target_min: 25
concepts: [Heartbleed, CVE-2014-0160, TLS heartbeat, buffer over-read, bounds checking, Bytes.sub, Cstruct, structural impossibility]
keywords: [OCaml, Heartbleed, CVE-2014-0160, OpenSSL, TLS, heartbeat, buffer over-read, memory safety, bounds check, Cstruct]
activity_question: "If a TLS server's heartbeat handler is given a request with a payload of 1 byte but a length field claiming 65535 bytes, what should it do? What does the OpenSSL code in 2014 actually do? What would the equivalent OCaml code do?"
think_about_this: "Heartbleed leaked roughly 64 KB of server memory per request. What kind of data could an attacker recover from a TLS server's working memory, and why was the cleanup so expensive?"
reading:
  - title: "Heartbleed, the canonical writeup"
    url: https://heartbleed.com/
  - title: "CVE-2014-0160 in the National Vulnerability Database"
    url: https://nvd.nist.gov/vuln/detail/CVE-2014-0160
  - title: "OpenSSL commit 96db9023, the Heartbleed fix"
    url: https://github.com/openssl/openssl/commit/96db9023b881d7cd9f379b0c154650d6c108e9a3
  - title: "Cstruct, type-safe byte buffer slicing in OCaml"
    url: https://github.com/mirage/ocaml-cstruct
---

# Tutorial: walking Heartbleed end to end


:::slide

<div class="title-slide-inner">
<p class="title-slide-course">Functional Programming with OCaml</p>
<h2 class="title-slide-lecture">Tutorial: walking Heartbleed end to end</h2>
<p class="title-slide-label">Module 10 &middot; Lecture 5</p>
<p class="title-slide-instructor">KC Sivaramakrishnan<br>IIT Madras</p>
</div>

:::

The previous four lectures built the safety picture in
generality: the categories of memory-safety bugs (M10-L01); the
security cost when one of them ships (M10-L02); how OCaml rules
them out by construction (M10-L03); and the honest boundary where
OCaml itself admits UB (M10-L04). This tutorial lands all of that
on one concrete, exhaustively-documented case study:
**Heartbleed**, CVE-2014-0160, the OpenSSL bug that affected an
estimated two-thirds of the public internet in 2014.

The choice of Heartbleed is deliberate. It is the single best-
documented memory-safety incident in computing history. The bug is
clean to explain in two lines of code. The exploit is clean to
explain in one paragraph. The fix is clean to read; it is a single
length comparison. And the OCaml equivalent of the same protocol
handler, written using the standard `Bytes` or `Cstruct` APIs, is
*structurally incapable of having the same bug*. The bounds check
is mandatory; the out-of-bounds bytes are never read; the heart-
of-the-internet leak never gets started.

The lecture closes with a coding exercise: write a small bounds-
checked function that returns an `option` instead of raising. The
exercise is the OCaml-flavoured version of the discipline Heart-
bleed was missing.

:::slide

## Roadmap

- The TLS heartbeat extension, what it is supposed to do.
- The OpenSSL bug: the actual code, the actual mistake.
- The exploit: read up to 64 KB of server memory per request.
- The fix: one length comparison.
- The OCaml equivalent: same shape, bug class impossible.
- Closing exercise: a bounds-checked option-returning function.

:::

## The TLS heartbeat extension

TLS (Transport Layer Security) is the protocol behind every HTTPS
URL on the public internet. In 2012 the TLS standards committee
added an *extension* called *heartbeat*, defined in RFC 6520.
The motivation was that long-lived TLS connections sometimes go
quiet for minutes at a time, and intermediate network equipment
(firewalls, NAT boxes) may drop the connection during the silence.
The heartbeat extension lets either side send a small message,
asking the peer to echo it back, as a liveness check.

The message format is simple. A heartbeat *request* contains:

1. A *type* byte (request or response).
2. A two-byte *payload length* field, in network byte order.
3. *Payload* bytes of the declared length.
4. At least 16 bytes of *padding*.

A heartbeat *response* echoes back the same payload. The whole
exchange is protected by the existing TLS encryption; the peers
already have a shared secret and authenticated channel, so the
heartbeat is just a tiny inner ping-pong.

Spec-wise, the protocol is unremarkable. RFC 6520 is two
pages. The trouble is in how it was implemented.

:::slide

## TLS heartbeat (RFC 6520)

- A liveness check inside an already-established TLS connection.
- Request: `type | payload_length (2 bytes) | payload | padding`.
- Response: echo the payload back.
- Two-page spec. *Implementation is one screen of C.*

:::

## The OpenSSL code, abbreviated

OpenSSL is the open-source library that implements TLS for most
of the internet's HTTPS servers. In 2012 the OpenSSL team added
heartbeat support. The handler for incoming heartbeat requests
looked, in essence, like this (simplified for legibility; the
real code in `ssl/d1_both.c` and `ssl/t1_lib.c` had more
machinery, but the relevant lines are these):

```c
unsigned char *p = &s->s3->rrec.data[0];   /* incoming record */
unsigned int payload;
unsigned char *pl;

hbtype = *p++;
n2s(p, payload);                            /* read 2-byte length */
pl = p;                                     /* pointer to payload */

/* allocate response buffer */
unsigned char *buffer = OPENSSL_malloc(1 + 2 + payload + padding);
unsigned char *bp = buffer;

*bp++ = TLS1_HB_RESPONSE;
s2n(payload, bp);                           /* write 2-byte length */
memcpy(bp, pl, payload);                    /* copy payload bytes */
```

Trace the data flow. The incoming TLS record is a buffer of some
length `n` (whatever the peer actually sent). The handler reads
the type byte, then the two-byte `payload` length field. Then it
allocates a response buffer of the requested size and copies
`payload` bytes from the incoming record into the response.

The bug is right there, in the `memcpy`. The handler uses the
`payload` value as the source length of the copy, *without
checking that the incoming record actually contains that many
bytes*. The `payload` field is a 16-bit value chosen by the peer;
it can be anywhere from 0 to 65535. The incoming record's actual
size is whatever the peer sent, which can be much smaller.

If the attacker sends a heartbeat request with one byte of actual
payload but declares `payload = 65535`, the `memcpy` copies 65535
bytes starting from the address of `pl`. The first one comes
from the legitimate payload byte; the next 65534 come from
whatever happens to live in memory after the incoming record. That
memory is *the server's working memory*: the TLS connection's
session keys, the certificate's private key, other connections'
data, log buffers, anything else the server has in adjacent
allocations.

The handler then sends the entire response buffer back to the
attacker. Sixty-four kilobytes of server memory per request.
Indefinitely repeatable. Undetectable by any intrusion-detection
system, because the request is a perfectly well-formed TLS
heartbeat.

:::slide

## The bug, in two lines

```c
n2s(p, payload);          /* peer-controlled length, 0..65535 */
memcpy(bp, pl, payload);  /* copies payload bytes from incoming record */
```

- No check that the incoming record is *at least* `payload`
  bytes long.
- Attacker sends 1 byte of payload, declares length 65535.
- `memcpy` reads 65535 bytes; first one legitimate, rest is
  *adjacent server memory*.
- Server then *sends those bytes back to the attacker*.

:::

The technical name for the bug is *out-of-bounds read* (it is the
read side of buffer overflow). The Common Weakness Enumeration
classifies it as CWE-126. The bug shipped in OpenSSL versions
1.0.1 through 1.0.1f, was discovered independently by Neel Mehta
of Google and the Codenomicon security team in April 2014, and
publicly disclosed as CVE-2014-0160.

The disclosure was on 7 April 2014. By that evening, every public
TLS server on the internet was running code with this bug.
Estimates at the time put the proportion of affected HTTPS servers
at about two-thirds. The recovery effort, patching servers and
rotating keys and certificates, ran for months.

## The exploit

The exploit code was published within hours. The shape is:

1. Open a TLS connection to the target server. The connection is
   legitimate; the attacker does not need to break the encryption
   or impersonate the server.
2. Once the connection is established, send a heartbeat request
   with `payload = 65535` and one byte of actual payload.
3. The server replies with its 65535-byte response.
4. Repeat. Each request returns a fresh ~64 KB window of the
   server's memory.

The data returned was attacker-readable in plaintext (the
heartbeat response is inside the TLS channel that the attacker
shares with the server). What was in that 64 KB depended on the
server's recent activity; observed leaks included:

- The server's *TLS private key*, which is sometimes pre-loaded
  into a buffer near other TLS state. With the private key, an
  attacker can decrypt all captured traffic to that server and
  impersonate the server to clients.
- *Session tokens and cookies* from other concurrent TLS
  connections, allowing the attacker to hijack authenticated
  sessions.
- *Passwords* submitted to the server via HTTPS form posts.
- *Internal log buffers* that happened to be near the heartbeat
  buffer in memory.

The attacker had no need to choose what they got; they got
whatever happened to be there. Over millions of requests, an
attacker would harvest a lot.

:::slide

## The exploit

1. Open a legitimate TLS connection.
2. Send a heartbeat with `payload = 65535`, 1 actual byte.
3. Server returns 65535 bytes from its working memory.
4. Repeat. Free 64 KB samples of server memory per request.

Observed leaks: **TLS private keys**, session tokens, passwords,
log buffers, decrypted payloads.

:::

The financial impact has been estimated in the hundreds of
millions of dollars: every affected server needed a patched
binary, its TLS certificate revoked and reissued, its private
key rotated, and (for security-critical services) an audit of
data potentially exfiltrated during the vulnerability window.

The Heartbleed website [heartbleed.com](https://heartbleed.com/),
set up by Codenomicon at the disclosure, remains the canonical
writeup.

## The fix

The official fix, OpenSSL commit
[96db9023b881d7cd9f379b0c154650d6c108e9a3](https://github.com/openssl/openssl/commit/96db9023b881d7cd9f379b0c154650d6c108e9a3),
was a length comparison. Simplified, the patched handler reads:

```c
hbtype = *p++;
n2s(p, payload);
pl = p;

/* The new check */
if (1 + 2 + payload + 16 > s->s3->rrec.length)
    return 0;   /* silently discard the malformed request */

unsigned char *buffer = OPENSSL_malloc(1 + 2 + payload + padding);
/* ... allocate, build response, memcpy, send ... */
```

The `if` checks that the incoming record is at least large enough
to contain a type byte, the two-byte length field, `payload`
payload bytes, and the required 16 bytes of padding. If the
record is too small, the handler returns without copying anything.
The out-of-bounds read never happens. The server-memory leak
never starts.

One line. The fix is one length comparison.

:::slide

## The fix, in one comparison

```c
if (1 + 2 + payload + 16 > s->s3->rrec.length)
    return 0;
```

- Check that the incoming record is at least as big as the
  declared payload (plus type, length, padding).
- If not, refuse to process.
- *That is the entire fix.*

:::

This is the part of Heartbleed that is most often misread.
"OpenSSL is too complicated." "The OpenSSL developers should have
been more careful." "There should be more code review." All of
these miss the point. The bug was a missing length check, on a
hot path through a piece of C code in a 250,000-line library that
hundreds of contributors had reviewed. *In C, every memory
access needs a length check, and every length check is the
programmer's responsibility, and any one of them can be forgotten
on any line, and the bug ships*. The structural problem is the
language permitting the unchecked access in the first place. The
fix is one comparison; the *prevention* of the next Heartbleed
requires a language that does not let the comparison be omitted.

## The OCaml equivalent: bug class impossible

Now write the same protocol handler in OCaml. We will use the
standard library's `Bytes` module, which is the safe-fragment
equivalent of a C `unsigned char *` buffer. The sketch is:

```ocaml
(* Parse a heartbeat request and build the response.
   [record] is the incoming TLS record's payload bytes. *)
let handle_heartbeat (record : bytes) : bytes =
  let hbtype = Bytes.get record 0 in
  let payload_len =
    (Char.code (Bytes.get record 1) lsl 8)
    lor Char.code (Bytes.get record 2)
  in
  let payload = Bytes.sub record 3 payload_len in
  let response = Bytes.create (3 + payload_len + 16) in
  Bytes.set response 0 hbtype;
  Bytes.set response 1 (Char.chr (payload_len lsr 8));
  Bytes.set response 2 (Char.chr (payload_len land 0xff));
  Bytes.blit payload 0 response 3 payload_len;
  response
```

Read the code carefully. We never wrote a length check. There is
no `if Bytes.length record < 3 + payload_len then ...`. We just
asked for `Bytes.sub record 3 payload_len`. So what happens when
the attacker sends a record where `payload_len = 65535` but the
actual record is, say, 4 bytes long?

The answer is in `Bytes.sub`'s contract. From the OCaml manual:

> `Bytes.sub s pos len` returns a new byte sequence of length
> `len`, containing the subsequence of `s` that starts at position
> `pos` and has length `len`. Raises `Invalid_argument` if `pos`
> and `len` do not designate a valid range of `s`.

The bounds check is *part of the API*. Not optional. Not a
performance opt-in. Not a thing a programmer can forget to write.
The function refuses to read the bytes if the range is invalid;
it raises the exception at the call site, before any out-of-bounds
byte is touched.

Run the OCaml handler against an attacker's malformed request:

```text
record = "type | 0xff | 0xff | one_byte"   (* only 4 bytes long *)

Bytes.sub record 3 65535
  -> Invalid_argument "Bytes.sub / Bytes.sub_string"
```

The exception is raised before `Bytes.sub` produces any bytes.
The exception propagates up to the heartbeat handler's caller,
which presumably catches it and closes the connection. The
attacker gets a connection close; they do *not* get 64 KB of
server memory. The bug class is structurally impossible.

:::slide

## The OCaml equivalent

```ocaml
let payload = Bytes.sub record 3 payload_len in
```

- `Bytes.sub` is bounds-checked: in contract, in implementation,
  not optional.
- If `3 + payload_len > Bytes.length record`, raises
  `Invalid_argument`.
- *Exception raised at the call site, before any byte is read.*
- No memory leak. No malformed response. Connection closes.

:::

The contrast is worth pausing on. The C code needed a programmer
to *remember* to write a length check. The OCaml code needs a
programmer to *opt out* of a length check, and there is no way to
opt out from the safe fragment. The same protocol, the same data
flow, the same attacker, two languages, one bug, structurally
present in one and structurally absent in the other.

## A small refinement: `Cstruct`

The OCaml ecosystem has a library called `Cstruct` (used
extensively by MirageOS, which we will meet in Module 12) for
typed slicing of binary buffers. `Cstruct` adds a level of
type-safety beyond `Bytes`: each slice carries its bounds in the
type system, and slicing operations propagate them. The
equivalent of `Bytes.sub` in `Cstruct` is `Cstruct.sub`, which
has the same bounds-check semantics and the same exception. The
production OCaml TLS implementation in MirageOS,
[ocaml-tls](https://github.com/mirleft/ocaml-tls), uses `Cstruct`
throughout. It does not have Heartbleed-class bugs; it has not
had Heartbleed-class bugs ever; it cannot have them, because the
underlying APIs do not permit them.

:::slide

## `Cstruct` and `ocaml-tls`

- MirageOS uses `Cstruct` for typed binary slicing.
- `Cstruct.sub` has the same bounds-check semantics as `Bytes.sub`.
- The production OCaml TLS library, `ocaml-tls`, uses `Cstruct`.
- *It has not had Heartbleed-class bugs. It cannot have them.*

(M12, the unikernels module, returns to this stack.)

:::

## The big picture

What just happened in this tutorial is the entire module compressed
into one example. We saw:

- **M10-L01's UB catalogue**: the Heartbleed bug is buffer over-read,
  one of the four canonical memory bugs.
- **M10-L02's security argument**: the same bug exfiltrated TLS
  private keys, session tokens, passwords; the cost to the
  internet ran into hundreds of millions.
- **M10-L03's safety mechanisms**: bounds checking, mandatory on
  every `Bytes` access in the safe fragment, eliminates the bug
  class structurally.
- **M10-L04's honest boundary**: this safety holds in the safe
  fragment; it would not hold if the handler called into C via
  FFI without preserving the bounds-check discipline on the
  C side.

The single most important sentence in the module is:

> *OCaml's safety is not magic; it is GC + types + exhaustive
> matching + bounds-checked stdlib, applied consistently.*

The pieces are individually unremarkable. Many languages have
GC. Many languages have types. Many languages have bounds checks.
The OCaml story is that they are *applied consistently*: there is
no escape hatch on the hot path, no unchecked-array option for
performance, no "we will turn the check off because we measured."
The safety is the floor, not a feature.

:::slide

## The big picture

- Bounds checks: mandatory.
- GC: lifetimes are not the programmer's responsibility.
- Types: the value is what the type says it is, in the safe
  fragment.
- Exhaustive matching: cases are handled.
- *Applied consistently across the whole standard library.*

**That is what "memory-safe by default" buys you.**

:::

## Exercise

The closing exercise is the OCaml-flavoured discipline Heartbleed
was missing: write a small, bounds-checked function that returns
its result as an `option` rather than raising. The shape is the
one you would use if you wanted to handle bounds explicitly,
without an exception breaking the control flow.

:::quiz code id=M10-L05-q1
Write `safe_sub : bytes -> int -> int -> bytes option` that
returns `Some (Bytes.sub b pos len)` when the range `[pos,
pos + len)` lies entirely inside `b`, and `None` otherwise. The
function must never raise an exception, even for negative
arguments or arguments past the end of `b`. Hint: check that
`pos >= 0`, `len >= 0`, and `pos + len <= Bytes.length b` before
calling `Bytes.sub`.

```ocaml
let safe_sub b pos len =
  failwith "not implemented"
```

```ocaml skip
let mk s = Bytes.of_string s
let () =
  assert (safe_sub (mk "hello") 0 5 = Some (mk "hello"));
  assert (safe_sub (mk "hello") 1 3 = Some (mk "ell"));
  assert (safe_sub (mk "hello") 5 0 = Some (mk ""));
  assert (safe_sub (mk "hello") 0 6 = None);
  assert (safe_sub (mk "hello") 3 3 = None);
  assert (safe_sub (mk "hello") (-1) 1 = None);
  assert (safe_sub (mk "hello") 0 (-1) = None);
  assert (safe_sub (mk "hello") 6 0 = None);
  assert (safe_sub Bytes.empty 0 0 = Some Bytes.empty);
  print_endline "all tests passed"
```
:::

A reference solution: explicitly check the three preconditions
before calling `Bytes.sub`, and return `None` on any failure.

```ocaml
let safe_sub b pos len =
  if pos < 0 || len < 0 || pos + len > Bytes.length b
  then None
  else Some (Bytes.sub b pos len)
```

Notice what this gives you: the bounds check happens before the
underlying `Bytes.sub` is called, and the caller of `safe_sub`
sees a `None` instead of having to catch an exception. The
control-flow shape now matches the way a TLS heartbeat handler
should be written:

```ocaml
match safe_sub record 3 payload_len with
| None -> close_connection ()
| Some payload -> build_response payload
```

The malformed-request case is a pattern-match branch, not an
exception. The handler is exhaustive: every case is handled, the
type system enforces it (you cannot forget the `None` branch),
and the runtime never reads bytes outside the buffer. The C-style
"forget the length check, ship the bug" path has nowhere to land.

## What we did

We walked one CVE end to end:

- The TLS heartbeat extension, what it was supposed to do.
- The OpenSSL handler, with the actual missing length check.
- The exploit: 64 KB of server memory per request, private keys
  exfiltrated, two-thirds of the public internet affected.
- The fix: one length comparison.
- The OCaml equivalent: same protocol, bug class structurally
  impossible because `Bytes.sub` is bounds-checked in its
  contract.

This is the payoff for the whole module. Memory safety is not a
theoretical property; it is the difference between "two-thirds of
the public internet affected" and "the bug cannot be written."

:::slide

## What we did

| Step | C / OpenSSL | OCaml |
| --- | --- | --- |
| Read length | trust peer | trust peer |
| Read payload | `memcpy(..., payload)` (unchecked) | `Bytes.sub ... payload_len` (checked) |
| Result | 64 KB memory leak | `Invalid_argument` or `None` |
| Fix | One line patch | *No fix needed* |

:::

## What's next

Module 10 is complete. The next module, M11, picks up the safety
story at the type level: OCaml's vanilla type system catches a
lot, but not everything; OxCaml extends it with *modes*
(locality, uniqueness, linearity) that close two remaining C bug
classes the GC alone cannot reach: pointer-to-stack escape and
use-after-free of manually managed resources. M12 then applies
the whole safety stack to building an operating system in OCaml
(MirageOS).

:::slide

## What's next

- **M11**: OxCaml. Type-level extensions of safety. Locality,
  uniqueness, linearity.
- **M12**: Unikernels (MirageOS). Apply the safety stack to an OS.
- *Module 10 has established the foundation: types + GC +
  exhaustive matching + bounds-checked stdlib.*

:::

## Reading

- **Heartbleed**, the canonical writeup by Codenomicon:
  <https://heartbleed.com/>
- **CVE-2014-0160** in the National Vulnerability Database:
  <https://nvd.nist.gov/vuln/detail/CVE-2014-0160>
- **OpenSSL fix commit**, the one-line patch:
  <https://github.com/openssl/openssl/commit/96db9023b881d7cd9f379b0c154650d6c108e9a3>
- **RFC 6520**, the TLS heartbeat extension:
  <https://www.rfc-editor.org/rfc/rfc6520>
- **`Cstruct`**, type-safe binary buffer slicing:
  <https://github.com/mirage/ocaml-cstruct>
- **`ocaml-tls`**, the MirageOS TLS implementation:
  <https://github.com/mirleft/ocaml-tls>

## Sources

This lecture's prose, code examples, and exercises are original
to this course. The OpenSSL code excerpt is reproduced for
educational purposes from the public OpenSSL source tree (Apache
2.0 / OpenSSL dual licence) under the fair-use exemption for
critical commentary and teaching. The Heartbleed writeup at
heartbleed.com, the NVD CVE entry, and the OpenSSL fix commit are
public documents. The OCaml `Bytes.sub` contract is from the
OCaml manual. See
[`LICENSES.md`](https://github.com/fplaunchpad/ocaml_nptel/blob/main/LICENSES.md)
at the repository root for the full source posture.
