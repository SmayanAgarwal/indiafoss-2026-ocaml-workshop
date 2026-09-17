(** Pandoc-style fenced-div preprocessor.

    Transforms [:::name ... :::] blocks into raw HTML wrappers so that
    cmarkit parses surrounding markdown normally inside them. Supported
    names: [slide], [subslide], [fragment], [notes], [quiz mcq],
    [quiz code], [solution], [cols], and [col]. *)

(** [preprocess ?line_offset ?game src] returns [src] with every fenced
    div rewritten as raw HTML. Quiz blocks additionally carry a
    [data-quiz-line] attribute reflecting the 1-based source line of
    the opening [:::] marker, shifted up by [line_offset] (default 0).
    Pass a positive [line_offset] when [src] is the body of a file
    whose YAML frontmatter has already been stripped, so the recorded
    line numbers still match the original file.

    Pass [~game:true] (default [false]) for a page with frontmatter
    [game: true]: every ocaml cell outside a [:::solution] block (the
    [:::game-panel] cell included) is marked [run-on="click"], so
    nothing runs -- and no [*_ref] gets reassigned to a still-unsolved
    student stub -- until the reader actually presses Run, matching
    the hand-authored game pages under x-ocaml's own repo root. *)
val preprocess : ?line_offset:int -> ?game:bool -> string -> string
