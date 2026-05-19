(* Build entry: read N .md lecture files, emit N .html into _site/.
   Usage: nptel-build <src.md> <dst.html> [<relative_root>] *)

let read_file path =
  let ic = open_in path in
  let n = in_channel_length ic in
  let s = really_input_string ic n in
  close_in ic;
  s

let write_file path s =
  let dir = Filename.dirname path in
  if dir <> "" && dir <> "." then
    (try Unix.mkdir dir 0o755 with Unix.Unix_error _ -> ());
  let oc = open_out path in
  output_string oc s;
  close_out oc

(* Rewrite [src="/assets/...] and [href="/assets/...] attributes so
   they pick up the [asset_root] prefix that lecture-page CSS and JS
   already use. This lets ![alt](/assets/diagrams/foo.svg) in lecture
   markdown resolve to the right URL in both local preview and
   production. *)
let rewrite_asset_urls ~asset_root html =
  if asset_root = "" then html
  else
    let buf = Buffer.create (String.length html) in
    let needle = "\"/assets/" in
    let replacement = "\"" ^ asset_root ^ "/assets/" in
    let n = String.length html in
    let needle_len = String.length needle in
    let i = ref 0 in
    while !i < n do
      if !i + needle_len <= n && String.sub html !i needle_len = needle then begin
        Buffer.add_string buf replacement;
        i := !i + needle_len
      end else begin
        Buffer.add_char buf html.[!i];
        incr i
      end
    done;
    Buffer.contents buf

let render_one ~src ~dst ~asset_root =
  let raw = read_file src in
  let fm, body = Nptel_build.Frontmatter.parse raw in
  let preprocessed = Nptel_build.Divs.preprocess body in
  let doc = Cmarkit.Doc.of_string preprocessed in
  let doc' = Nptel_build.Parse.transform doc in
  let html_body =
    Cmarkit_html.of_doc ~safe:false doc'
    |> rewrite_asset_urls ~asset_root
  in
  (* The manifest scan looks at siblings of [src]: every
     [W<nn>-L<nn>-<rest>.md] file in the same directory becomes an
     entry. The current page is identified by its filename slug. *)
  let lectures_dir = Filename.dirname src in
  let current_slug =
    let base = Filename.basename src in
    if Filename.check_suffix base ".md" then Filename.chop_suffix base ".md"
    else base
  in
  let manifest =
    match Nptel_build.Manifest.parse_filename (Filename.basename src) with
    | None -> None  (* src isn't a lecture file; skip the sidebar. *)
    | Some _ ->
        Some (Nptel_build.Manifest.build ~lectures_dir ~current_slug)
  in
  let html =
    Nptel_build.Emit.render ~asset_root ~fm ~html_body ?manifest ()
  in
  write_file dst html

let usage () =
  prerr_endline "usage: nptel-build SRC.md DST.html [ASSET_ROOT]";
  exit 2

let () =
  match Sys.argv with
  | [| _; src; dst |] ->
      (* Default: assets served at the site root. The page loads from
         [http://host/path/to/lecture.html] and assets are at
         [http://host/assets/...]. *)
      render_one ~src ~dst ~asset_root:""
  | [| _; src; dst; root |] ->
      render_one ~src ~dst ~asset_root:root
  | _ -> usage ()
