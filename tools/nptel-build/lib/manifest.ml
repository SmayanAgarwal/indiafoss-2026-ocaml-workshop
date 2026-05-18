(* Course manifest: scan [lectures/W*-L*-*.md], read their frontmatter,
   sort by (week, lecture), group by week. The output is consumed by
   [Emit] to render a GitBook-style sidebar + prev/next navigation. *)

type entry = {
  week : int;
  lecture : int;
  title : string;
  slug : string;  (* basename without .md, e.g. "W01-L02-why-fp" *)
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

let parse_filename name =
  (* Expects [M<nn>-L<nn>-<rest>.md]. Returns (module_no, lecture, slug)
     or [None] if the filename doesn't match. *)
  let strip_ext s =
    if Filename.check_suffix s ".md" then
      Filename.chop_suffix s ".md"
    else s
  in
  let s = strip_ext (Filename.basename name) in
  try
    Scanf.sscanf s "M%d-L%d-" (fun w l ->
      Some (w, l, s))
  with Scanf.Scan_failure _ | End_of_file -> None

(* Walk [dir] for files matching the convention. Returns a list of
   (week, lecture, slug, path) tuples. *)
let scan_dir dir =
  let entries =
    try Sys.readdir dir |> Array.to_list with Sys_error _ -> []
  in
  List.filter_map
    (fun name ->
      match parse_filename name with
      | None -> None
      | Some (w, l, slug) ->
          let path = Filename.concat dir name in
          if Sys.is_directory path then None
          else Some (w, l, slug, path))
    entries

let read_title path =
  let raw =
    try
      let ic = open_in path in
      let n = in_channel_length ic in
      let s = really_input_string ic n in
      close_in ic;
      s
    with Sys_error _ -> ""
  in
  let fm, _ = Frontmatter.parse raw in
  fm.title

(* Read module titles from [<dir>/modules.txt]. Format: "[Mnn]: title".
   Lines beginning with '#' are comments. *)
let read_week_titles dir =
  let path = Filename.concat dir "modules.txt" in
  if not (Sys.file_exists path) then []
  else begin
    let ic = open_in path in
    let lines = ref [] in
    (try
       while true do
         let line = input_line ic in
         lines := line :: !lines
       done
     with End_of_file -> ());
    close_in ic;
    List.rev_map (fun s ->
      let s = String.trim s in
      if s = "" || (String.length s > 0 && s.[0] = '#') then None
      else
        try
          Scanf.sscanf s "M%d: %[^\n]" (fun n title ->
            Some (n, String.trim title))
        with _ -> None) !lines
    |> List.filter_map Fun.id
  end

let build ~lectures_dir ~current_slug =
  let raw = scan_dir lectures_dir in
  let week_titles = read_week_titles lectures_dir in
  let title_for_week n =
    match List.assoc_opt n week_titles with
    | Some t -> t
    | None -> Printf.sprintf "Module %02d" n
  in
  let entries =
    List.map
      (fun (w, l, slug, path) ->
        { week = w; lecture = l; title = read_title path; slug })
      raw
  in
  (* Group by week, sort within each. *)
  let by_week = Hashtbl.create 13 in
  List.iter
    (fun e ->
      let lst = try Hashtbl.find by_week e.week with Not_found -> [] in
      Hashtbl.replace by_week e.week (e :: lst))
    entries;
  let weeks =
    Hashtbl.fold
      (fun week_no es acc ->
        let lectures =
          List.sort (fun a b -> compare a.lecture b.lecture) es
        in
        { week_no; week_title = title_for_week week_no; lectures } :: acc)
      by_week []
    |> List.sort (fun a b -> compare a.week_no b.week_no)
  in
  { weeks; current_slug }

(* prev / next entry in linear order across all weeks. *)
let neighbors t =
  let flat =
    List.concat_map (fun w -> w.lectures) t.weeks
    |> List.sort (fun a b ->
        match compare a.week b.week with
        | 0 -> compare a.lecture b.lecture
        | c -> c)
  in
  let rec go prev = function
    | [] -> (None, None)
    | e :: rest when e.slug = t.current_slug ->
        let next = match rest with x :: _ -> Some x | [] -> None in
        (prev, next)
    | e :: rest -> go (Some e) rest
  in
  go None flat
