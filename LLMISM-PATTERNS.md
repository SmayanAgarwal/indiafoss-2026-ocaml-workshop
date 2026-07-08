# LLMism patterns: a field guide

A catalogue of prose patterns that read as machine-generated, so we can
spot them in drafts and keep them out of the handouts. The house style
is plain and scientific: state the point once, directly, and let the
content carry the weight. Every pattern below dilutes that.

This guide is the standing reference. `LLMISM-AUDIT.md` is the current
punch list of actual instances found in the lectures. When KC flags a
new pattern, add it here.

## How to use this

- When drafting or editing a lecture, scan your own prose against the
  categories below.
- Most patterns have a cheap grep. The greps over-match (they catch
  legitimate uses too), so every hit needs a human read. Precision, not
  volume: a real technical contrast is not a contrastive-filler LLMism.
- The fix is almost always **deletion**. Filler is filler; cutting it
  leaves the sentence stronger. When a fix needs a replacement, replace
  the empty phrase with a concrete detail, not another adjective.

## The two hard rules (from global preferences)

These are not judgment calls. They are always wrong.

1. **No em-dashes.** Neither the `—` glyph nor the `--` digram (which
   renders as an em-dash in Markdown). Use colons, semicolons, parens,
   commas, or separate sentences. Exceptions: CLI flag names (`--dce`),
   Markdown table separators, YAML front-matter delimiters.
   - Grep: `grep -n "—" lectures/*.md` and for the digram in prose,
     `grep -nE "[a-z]--[a-z]" lectures/*.md` (then discard CLI flags).
2. **No hype adjectives or contrastive constructions.** See categories
   3 and 2 below.

## The pattern categories

### 1. Appended evaluative flourishes

A clause tacked on to tell the reader the content is valuable or
memorable, instead of just delivering it. Carries no information; it is
self-congratulatory padding.

- Tells: "it is worth noting/remembering/keeping in mind", "worth
  carrying forward", "worth holding onto", "an important point here",
  "the key insight is", "keep in mind that", "it is important to
  note/realize/understand".
- Canonical instance (flagged by Shriram Krishnamurthi on M02-L01):
  *"The answer has two parts, one practical and one principled, and both
  worth holding onto."* → cut the tail: *"...one practical and one
  principled."*
- Fix: delete the clause. If it was doing signposting, replace it with
  the actual content it was pointing at.
- Not this: signposting that carries real information ("The rest of the
  lecture covers guards, then exhaustiveness"). That orients the reader
  with content, not with an importance-announcement.
- Grep: `grep -niE "worth (noting|remembering|keeping|carrying|holding)|it is worth|it'?s worth|keep in mind|important to (note|realize|understand)" lectures/*.md`

### 2. Contrastive filler

The "not just X but Y" family, used for emphasis rather than to draw a
real distinction. The giveaway: the "X" and the "Y" are not two
genuinely different categories; the construction is there for rhythm.

- Tells: "not just X but Y", "X, not merely Y", "not only... but also",
  "isn't just... it's", "more than just", "rather than merely".
- Fix: state Y directly and drop the "not just X" scaffolding, or, if
  the contrast is real, name both sides plainly.
- Not this: a precise technical contrast that names a real second
  category. *"`map` is a pattern, not just a list function"* draws a
  genuine distinction and is fine. Flag *"this is not just powerful, it
  is transformative"* (two empty intensifiers, no real contrast).
- Grep: `grep -niE "not (just|merely|only)|isn'?t (just|merely)|more than (just|merely)|rather than (just|merely)" lectures/*.md`

### 3. Hype and evaluative adjectives

Decorative adjectives and adverbs that assert quality instead of showing
it. The reader should conclude a thing is powerful from what it does,
not be told so.

- Tells: powerful, elegant, seamless(ly), robust, compelling, genuinely,
  incredibly, vast, rich, crucial, essential, significant, remarkable,
  beautiful, delightful, wonderful, versatile.
- Fix: delete the adjective, or replace it with the concrete capability
  it stands in for. "A powerful abstraction" → "an abstraction that lets
  you X without Y".
- Not this: the same word used as a technical term. "robust" in a
  testing context, "pure function", "essential complexity", "sound type
  system" are precise, not decorative. CS3110's actual subtitle
  *Correct + Efficient + Beautiful* is a citation, not our hype.
- Grep: `grep -niwE "powerful|elegant|seamless|seamlessly|robust|compelling|genuinely|crucial|essential|remarkable|beautiful|versatile" lectures/*.md`

### 4. Marketing openers and scene-setting

Blog-launch register: warming the reader up before saying anything.

- Tells: "In the world of...", "When it comes to...", "At its core...",
  "Let's dive in/into", "Let's explore", "the beauty of", "the magic
  of", "unlock", "leverage", "harness", "delve into", "realm",
  "landscape", "journey", "under the hood".
- Fix: cut the runway; open on the first real sentence. A lecture on
  folds does not need "When it comes to processing lists in OCaml,"
  before "`fold_left` walks a list left to right."
- Grep: `grep -niE "in the world of|when it comes to|at its core|let'?s (dive|explore)|dive into|the (beauty|magic) of|delve into|leverage|harness|under the hood" lectures/*.md`

### 5. Invented rule-of-three and alliteration

Three parallel adjectives or clauses strung together for cadence rather
than because there are exactly three things to say. Alliteration for the
same reason.

- Tell: a triad where the third item adds nothing the first two didn't,
  or where the items are near-synonyms ("clean, clear, and concise").
- Fix: keep the items that carry distinct content; drop the rest.
- Not this: an enumeration where three is the actual count (three
  constructors, three cases of a match).

### 6. Empty transitions and connectives

Connective words that imply a logical relation that isn't there, or that
just pad the seam between two sentences.

- Tells: "Moreover", "Furthermore", "Additionally", "That said",
  "It's worth mentioning that", "As we've seen" (when nothing is
  actually being referred back to), "Importantly".
- Fix: delete, or replace with a plain "and"/"but"/"so" if a real
  connective is needed. "As we've seen" is only allowed when it points
  at something the reader has actually seen.
- Grep: `grep -niE "^(moreover|furthermore|additionally|importantly)|that said|it'?s worth mentioning|as we'?ve seen" lectures/*.md`

### 7. Hollow summary and importance announcements

Sentences that announce that a point is important or is a summary,
instead of being the point or the summary.

- Tells: "In conclusion", "To sum up", "The key takeaway is", "This is
  where X shines", "the real power of X", "This is the crux", "This is
  the punchline".
- Fix: state the takeaway as a plain declarative sentence. The reader
  does not need to be told it is the takeaway.
- Grep: `grep -niE "in conclusion|to sum up|key takeaway|this is where|the real power of|this is the (crux|punchline)" lectures/*.md`

### 8. Filler intensifiers

Words that inflate tone without adding meaning. Deleting them changes
nothing.

- Tells: "simply", "just", "basically", "essentially", "really", "of
  course", "clearly", "obviously", "actually", "quite".
- Fix: delete. "This is simply a wrapper" → "This is a wrapper".
- Caution: this category has the highest false-positive rate. "just" is
  often load-bearing ("returns just the head"). Flag only when the word
  inflates tone and deletion is lossless. Be sparing.

### 9. Self-referential and reader meta-narration

The prose narrating its own pedagogy or the reader's mental state,
rather than teaching. (Added after KC flagged "a signal to the reader".)

- Tells: "Now that we understand X, let's...", "you might be wondering",
  "As promised", "a signal to the reader", "this tells the reader",
  "the astute reader will notice", "as you can imagine".
- Fix: delete the meta-layer; say the thing directly. "This is a signal
  to the reader that the list is empty" → "The empty list matches here."
- Grep: `grep -niE "you might be wondering|as promised|signal to the reader|the (astute|careful) reader|as you can imagine|now that we (understand|know)" lectures/*.md`

## Why these read as machine-generated

LLM prose defaults to a register that flatters the reader and signals
effort: it announces importance, hedges with intensifiers, warms up
before making a point, and reaches for evaluative adjectives instead of
concrete detail. Human technical writing at its best does the opposite:
it trusts the reader, states the point once, and shows rather than
asserts. Every category above is a place where the default register
leaks back in.

## The tics this course is actually prone to

From the full-book audit (`LLMISM-AUDIT.md`), the patterns that recur
here, worth checking first in any new draft:

- **`genuinely`** as an empty intensifier. The single most common
  offender (17 instances across the book). Almost always deletable with
  no loss. Grep every draft for it.
- **`under the hood`** for "internally" (8 instances). Borderline: may
  be voice, but it is a stock idiom; decide per-project whether to keep.
- **"worth {noting, internalising, keeping in mind, naming, holding,
  pausing on, carrying}"** (15 instances). The flourish family. The
  content after the wrapper always stands on its own.
- **"a small but powerful toolkit" / "a remarkable amount of…" /
  "a surprising amount of…"** clustered in the higher-order-functions
  module. A stock enthusiasm register for a list of capabilities.
- **`elegant` / `compelling` / `beautiful`** as aesthetic judgments of
  code or another author's chapter (7 instances).
- **Importance lead-ins**: "The striking thing:", "The key thing:",
  "The crux:", "the single most important sentence".
- **`journey`** for the course arc, and theatrical openers ("Now the
  dramatic part.").

## Quick self-check before committing a lecture

1. Run the two hard-rule greps (em-dash, hype adjectives). Zero
   tolerance.
2. Read the first sentence of each section: is it content, or runway?
3. Read the last sentence of each section: is it a point, or an
   announcement that a point was made?
4. Search your own draft for "worth", "powerful", "simply", "not just".
   Read each hit in context; cut the filler.
