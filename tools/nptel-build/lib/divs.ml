(* Line-oriented preprocessor for Pandoc-style fenced div blocks.

   Transforms:

     :::slide
     contents
     :::

   into raw-HTML wrappers that cmarkit will pass through. We support
   these block names:

     slide      -> <section class="slide" data-slide>...</section>
     subslide   -> <section class="slide subslide" data-subslide>...</section>
     fragment   -> <div class="fragment">...</div>
     notes      -> <aside class="notes">...</aside>
     quiz mcq   -> <div class="quiz quiz-mcq" data-quiz-id="qN">...</div>
     quiz code  -> <div class="quiz quiz-code" data-quiz-id="qN">...</div>

   Quizzes get a sequential auto-id ("q1", "q2", ...) so the runtime
   JS can key localStorage by it without the author having to invent
   stable ids.

   Nesting is supported by tracking a stack: `:::name` opens, bare `:::`
   closes the most recent open block.

   The substitution is done by emitting the HTML opening tag *on its own
   line surrounded by blank lines*, so cmarkit treats it as an HTML
   block (open block + blank line + parsed content + blank line + close
   tag). This is the standard CommonMark recipe for embedding raw HTML
   that wraps markdown content.
*)

(* Quiz blocks carry an id string that becomes the data-quiz-id
   attribute on the rendered div. Authors may pin an explicit
   stable id with [:::quiz mcq id=cons-immutability]; without it,
   the build assigns a positional fallback ["q1", "q2", ...]. The
   stable id matters because the quiz_id is the persistent key in
   the analytics database; reordering quizzes within a lecture
   would otherwise silently re-attach old responses to the wrong
   question. *)
type kind =
  | Slide
  | Subslide
  | Fragment
  | Notes
  | Quiz_mcq of string
  | Quiz_code of string

(* Sanitise an author-supplied id to a slug shape that survives in
   URL fragments. Lowercase, [a-z0-9-] only, collapse repeats,
   trim leading/trailing dashes, length-capped. *)
let slugify_id s =
  let buf = Buffer.create (String.length s) in
  let last_dash = ref true in
  String.iter
    (fun c ->
      let c = Char.lowercase_ascii c in
      if (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') then begin
        Buffer.add_char buf c;
        last_dash := false
      end else if not !last_dash then begin
        Buffer.add_char buf '-';
        last_dash := true
      end)
    s;
  let raw = Buffer.contents buf in
  let n = String.length raw in
  let lo = if n > 0 && raw.[0] = '-' then 1 else 0 in
  let hi = if n > lo && raw.[n - 1] = '-' then n - 1 else n in
  let cleaned = if hi > lo then String.sub raw lo (hi - lo) else "" in
  let max_len = 64 in
  if String.length cleaned > max_len then String.sub cleaned 0 max_len
  else cleaned

(* Parse "quiz mcq [id=foo]" or "quiz code [id=foo]". The id, if
   present, must follow the keyword. We accept whitespace between
   the tokens but nothing else. *)
let parse_quiz_kind rest =
  let trimmed = String.trim rest in
  let starts_with prefix s =
    String.length s >= String.length prefix
    && String.sub s 0 (String.length prefix) = prefix
  in
  let after_prefix prefix s =
    String.sub s (String.length prefix) (String.length s - String.length prefix)
  in
  let parse_optional_id tail =
    let t = String.trim tail in
    if t = "" then None
    else if starts_with "id=" t then
      let v = after_prefix "id=" t |> String.trim in
      let slug = slugify_id v in
      if slug = "" then None else Some slug
    else None
  in
  if starts_with "quiz mcq" trimmed then
    let tail = after_prefix "quiz mcq" trimmed in
    Some (`Mcq, parse_optional_id tail)
  else if starts_with "quiz code" trimmed then
    let tail = after_prefix "quiz code" trimmed in
    Some (`Code, parse_optional_id tail)
  else None

(* Quiz state is threaded through preprocess as a mutable counter
   used only for positional fallback ids. *)
let parse_open ~quiz_counter line =
  let s = String.trim line in
  if String.length s < 3 || String.sub s 0 3 <> ":::" then None
  else
    let rest = String.sub s 3 (String.length s - 3) |> String.trim in
    match rest with
    | "" -> None  (* closing :::, not an open *)
    | "slide" -> Some Slide
    | "subslide" -> Some Subslide
    | "fragment" -> Some Fragment
    | "notes" -> Some Notes
    | _ ->
      (match parse_quiz_kind rest with
       | Some (kind, explicit_id) ->
         incr quiz_counter;
         let id = match explicit_id with
           | Some s -> s
           | None -> Printf.sprintf "q%d" !quiz_counter
         in
         (match kind with
          | `Mcq -> Some (Quiz_mcq id)
          | `Code -> Some (Quiz_code id))
       | None -> None)

let is_close line =
  let s = String.trim line in
  s = ":::"

let open_tag = function
  | Slide -> "<section class=\"slide\" data-slide>"
  | Subslide -> "<section class=\"slide subslide\" data-subslide>"
  | Fragment -> "<div class=\"fragment\">"
  | Notes -> "<aside class=\"notes\">"
  | Quiz_mcq id ->
      Printf.sprintf "<div class=\"quiz quiz-mcq\" data-quiz-id=\"%s\">" id
  | Quiz_code id ->
      Printf.sprintf "<div class=\"quiz quiz-code\" data-quiz-id=\"%s\">" id

let close_tag = function
  | Slide | Subslide -> "</section>"
  | Fragment -> "</div>"
  | Notes -> "</aside>"
  | Quiz_mcq _ | Quiz_code _ -> "</div>"

(* Inside [:::quiz code], the FIRST ocaml fence is the student cell
   and any subsequent ones are test cells (hidden assertion code).
   Authors write them as ```ocaml skip``` (skip is required by
   ocaml-mdx, which would otherwise try to run the assertion code
   against undefined names from the student cell).

   For the build's own use, we rewrite a test cell's info string to
   add the [quiz-test] marker. This rewriting happens only in the
   output we feed to cmarkit -- the source file mdx reads is
   untouched. Parse.ml looks for the [quiz-test] attribute. *)
let is_ocaml_fence_open line =
  let s = String.trim line in
  String.length s >= 3
  && String.sub s 0 3 = "```"
  && (let rest = String.sub s 3 (String.length s - 3) |> String.trim in
      match String.split_on_char ' ' rest with
      | "ocaml" :: _ -> true
      | _ -> false)

let inject_quiz_test_marker line =
  (* Find the [```ocaml] prefix and append [ quiz-test] after the
     info string. Preserve leading whitespace and any existing labels
     (notably [skip], which mdx needs). *)
  let s = line in
  let n = String.length s in
  (* Find end of info string (end of line or end of trailing spaces). *)
  let i = ref 0 in
  while !i < n && (s.[!i] = ' ' || s.[!i] = '\t') do incr i done;
  let prefix_len = !i in
  let body = String.sub s prefix_len (n - prefix_len) in
  let body_trimmed = String.trim body in
  let leading = String.sub s 0 prefix_len in
  leading ^ body_trimmed ^ " quiz-test"

let preprocess src =
  let lines = String.split_on_char '\n' src in
  let buf = Buffer.create (String.length src) in
  let stack = ref [] in
  let quiz_counter = ref 0 in
  (* Track, per active Quiz_code on the stack, how many ocaml fences
     have appeared inside it so we know which is the student cell vs
     the test cell(s). Map: a counter for the topmost Quiz_code. *)
  let quiz_code_fence_count = ref 0 in
  let in_quiz_code () =
    List.exists (function Quiz_code _ -> true | _ -> false) !stack
  in
  let in_code_block = ref false in
  List.iter
    (fun line ->
      (* Distinguish entering / leaving a fenced code block from the
         opening of a fenced div ([:::]). Code-block fences start with
         [```]; div opens / closes start with [:::]. *)
      let is_fence_line =
        let s = String.trim line in
        String.length s >= 3 && String.sub s 0 3 = "```"
      in
      match parse_open ~quiz_counter line with
      | Some k ->
          stack := k :: !stack;
          (match k with
           | Quiz_code _ -> quiz_code_fence_count := 0
           | _ -> ());
          Buffer.add_string buf "\n";
          Buffer.add_string buf (open_tag k);
          Buffer.add_string buf "\n\n"
      | None when is_close line -> (
          match !stack with
          | [] ->
              Buffer.add_string buf line;
              Buffer.add_char buf '\n'
          | k :: rest ->
              stack := rest;
              (match k with
               | Quiz_code _ -> quiz_code_fence_count := 0
               | _ -> ());
              Buffer.add_string buf "\n";
              Buffer.add_string buf (close_tag k);
              Buffer.add_string buf "\n\n")
      | None when is_fence_line && in_quiz_code () && not !in_code_block
                  && is_ocaml_fence_open line ->
          (* Opening an ocaml code block inside a quiz-code div.
             Count it; the 2nd+ are test cells. *)
          incr quiz_code_fence_count;
          let n_inside = !quiz_code_fence_count in
          in_code_block := true;
          if n_inside >= 2 then begin
            Buffer.add_string buf (inject_quiz_test_marker line);
            Buffer.add_char buf '\n'
          end else begin
            Buffer.add_string buf line;
            Buffer.add_char buf '\n'
          end
      | None when is_fence_line ->
          in_code_block := not !in_code_block;
          Buffer.add_string buf line;
          Buffer.add_char buf '\n'
      | None ->
          Buffer.add_string buf line;
          Buffer.add_char buf '\n')
    lines;
  List.iter
    (fun k ->
      Buffer.add_string buf "\n";
      Buffer.add_string buf (close_tag k);
      Buffer.add_string buf "\n")
    !stack;
  Buffer.contents buf
