(** Pandoc-style fenced-div preprocessor.

    Transforms [:::name ... :::] blocks into raw HTML wrappers so that
    cmarkit parses surrounding markdown normally inside them. Supported
    names: [slide], [subslide], [fragment], [notes]. *)

val preprocess : string -> string
