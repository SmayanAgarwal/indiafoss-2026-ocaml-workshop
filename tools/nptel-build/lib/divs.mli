(** Pandoc-style fenced-div preprocessor.

    Transforms [:::name ... :::] blocks into raw HTML wrappers so that
    cmarkit parses surrounding markdown normally inside them. Supported
    names: [slide], [subslide], [fragment], [notes], [quiz mcq],
    [quiz code], [cols], [col], [vm-terminal].

    [:::vm-terminal] (optionally [:::vm-terminal dir=/root/morse])
    marks the spot for the in-browser Linux VM terminal; at most one
    per lecture, enforced with a failure. *)

(** [preprocess ?line_offset src] returns [src] with every fenced div
    rewritten as raw HTML. Quiz blocks additionally carry a
    [data-quiz-line] attribute reflecting the 1-based source line of
    the opening [:::] marker, shifted up by [line_offset] (default 0).
    Pass a positive [line_offset] when [src] is the body of a file
    whose YAML frontmatter has already been stripped, so the recorded
    line numbers still match the original file. *)
val preprocess : ?line_offset:int -> string -> string
