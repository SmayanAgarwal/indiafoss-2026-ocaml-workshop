(** Course manifest: scans [lectures/W*-L*-*.md], reads their
    frontmatter, groups by week. Used to emit the GitBook-style
    sidebar + prev/next navigation on each lecture page. *)

type entry = {
  week : int;
  lecture : int;
  title : string;
  slug : string;
}

type week = {
  week_no : int;
  week_title : string;
  lectures : entry list;
}

type t = {
  weeks : week list;
  current_slug : string;
}

val build : lectures_dir:string -> current_slug:string -> t

(** [parse_filename name] returns [(week, lecture, slug)] for a
    filename matching [W<nn>-L<nn>-<rest>.md], else [None]. *)
val parse_filename : string -> (int * int * string) option

(** Previous and next entry in linear (week, lecture) order across
    all weeks. *)
val neighbors : t -> entry option * entry option
