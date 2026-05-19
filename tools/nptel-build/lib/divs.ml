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

type kind =
  | Slide
  | Subslide
  | Fragment
  | Notes
  | Quiz_mcq of int
  | Quiz_code of int

(* Quiz state is threaded through preprocess as a mutable counter. *)
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
    | "quiz mcq" ->
        incr quiz_counter;
        Some (Quiz_mcq !quiz_counter)
    | "quiz code" ->
        incr quiz_counter;
        Some (Quiz_code !quiz_counter)
    | _ -> None

let is_close line =
  let s = String.trim line in
  s = ":::"

let open_tag = function
  | Slide -> "<section class=\"slide\" data-slide>"
  | Subslide -> "<section class=\"slide subslide\" data-subslide>"
  | Fragment -> "<div class=\"fragment\">"
  | Notes -> "<aside class=\"notes\">"
  | Quiz_mcq n ->
      Printf.sprintf "<div class=\"quiz quiz-mcq\" data-quiz-id=\"q%d\">" n
  | Quiz_code n ->
      Printf.sprintf "<div class=\"quiz quiz-code\" data-quiz-id=\"q%d\">" n

let close_tag = function
  | Slide | Subslide -> "</section>"
  | Fragment -> "</div>"
  | Notes -> "</aside>"
  | Quiz_mcq _ | Quiz_code _ -> "</div>"

let preprocess src =
  let lines = String.split_on_char '\n' src in
  let buf = Buffer.create (String.length src) in
  let stack = ref [] in
  let quiz_counter = ref 0 in
  List.iter
    (fun line ->
      match parse_open ~quiz_counter line with
      | Some k ->
          stack := k :: !stack;
          Buffer.add_string buf "\n";
          Buffer.add_string buf (open_tag k);
          Buffer.add_string buf "\n\n"
      | None when is_close line -> (
          match !stack with
          | [] ->
              (* Stray :::; pass through verbatim to surface the problem. *)
              Buffer.add_string buf line;
              Buffer.add_char buf '\n'
          | k :: rest ->
              stack := rest;
              Buffer.add_string buf "\n";
              Buffer.add_string buf (close_tag k);
              Buffer.add_string buf "\n\n")
      | None ->
          Buffer.add_string buf line;
          Buffer.add_char buf '\n')
    lines;
  (* Close any unclosed blocks defensively. *)
  List.iter
    (fun k ->
      Buffer.add_string buf "\n";
      Buffer.add_string buf (close_tag k);
      Buffer.add_string buf "\n")
    !stack;
  Buffer.contents buf
