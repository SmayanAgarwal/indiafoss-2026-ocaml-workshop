(* Integration test: drive the full nptel-build pipeline on
   smoke.md and assert structural invariants on the emitted HTML. *)

open Nptel_build

let read path =
  let ic = open_in path in
  let n = in_channel_length ic in
  let s = really_input_string ic n in
  close_in ic;
  s

let contains s sub =
  try ignore (Str.search_forward (Str.regexp_string sub) s 0); true
  with Not_found -> false

let count_sub s sub =
  let r = Str.regexp_string sub in
  let rec go i n =
    match Str.search_forward r s i with
    | exception Not_found -> n
    | j -> go (j + String.length sub) (n + 1)
  in
  go 0 0

let render path =
  let raw = read path in
  let fm, body = Frontmatter.parse raw in
  let preprocessed = Divs.preprocess body in
  let doc = Cmarkit.Doc.of_string preprocessed in
  let doc' = Parse.transform doc in
  let html_body = Cmarkit_html.of_doc ~safe:false doc' in
  Emit.render ~asset_root:"" ~fm ~html_body ()

let html = lazy (render "smoke.md")

let check_bool = Alcotest.(check bool)
let check_int = Alcotest.(check int)

(* ---- Frontmatter is reflected in the page ---- *)

let title_in_head () =
  check_bool "title in <title>" true
    (contains (Lazy.force html) "<title>Integration test fixture</title>")

let title_in_header () =
  check_bool "title in header bar" true
    (contains (Lazy.force html) "Integration test fixture")

let metadata_in_footer () =
  let s = Lazy.force html in
  check_bool "concepts rendered" true (contains s "integration test");
  check_bool "activity question rendered" true (contains s "Did everything render?");
  check_bool "reading title rendered" true (contains s "cmarkit");
  check_bool "reading url rendered" true
    (contains s "https://erratique.ch/software/cmarkit")

(* ---- OCaml fences -> x-ocaml ---- *)

let three_x_ocaml_cells () =
  let s = Lazy.force html in
  (* Every emitted cell carries a data-source attribute and a closing
     </x-ocaml>. Counting the closing tag avoids both the in-script
     JS comment mentioning "<x-ocaml>" and any false positives in
     stylesheet selectors. *)
  check_int "three x-ocaml elements" 3 (count_sub s "</x-ocaml>")

let init_attribute_preserved () =
  check_bool "init=true preserved" true
    (contains (Lazy.force html) "init=\"true\"")

let data_source_present () =
  check_bool "every cell has data-source" true
    (let s = Lazy.force html in
     count_sub s "data-source=\"" = 3)

(* ---- Slide structure ---- *)

let two_slide_sections () =
  check_int "two slide sections" 2
    (count_sub (Lazy.force html) "<section class=\"slide\" data-slide>")

let speaker_notes () =
  check_bool "<aside class=notes> present" true
    (contains (Lazy.force html) "<aside class=\"notes\">")

let fragment_present () =
  check_bool "fragment div present" true
    (contains (Lazy.force html) "<div class=\"fragment\">")

(* ---- Mode toggle / runtime wiring ---- *)

let mode_toggle_button () =
  check_bool "mode-toggle button emitted" true
    (contains (Lazy.force html) "class=\"mode-toggle\"")

let cell_controls () =
  let s = Lazy.force html in
  check_bool "Run all button" true (contains s "class=\"run-all\"");
  check_bool "Clear outputs button" true (contains s "class=\"clear-all\"");
  check_bool "Reset all cells button" true (contains s "class=\"reset-all\"");
  check_bool "Run up to here button" true (contains s "class=\"run-up-to-here\"")

let asset_paths_root_relative () =
  let s = Lazy.force html in
  check_bool "x-ocaml asset path is /assets/..." true
    (contains s "src=\"/assets/x-ocaml/x-ocaml.js\"");
  check_bool "worker asset path is /assets/..." true
    (contains s "src-worker=\"/assets/x-ocaml/x-ocaml.worker.js\"")

let reveal_wrapper () =
  check_bool "empty .reveal .slides wrapper present" true
    (contains (Lazy.force html) "<div class=\"reveal\"")

let () =
  Alcotest.run "nptel-build-integration"
    [
      ( "frontmatter -> page",
        [
          Alcotest.test_case "<title> set" `Quick title_in_head;
          Alcotest.test_case "header bar has title" `Quick title_in_header;
          Alcotest.test_case "footer carries metadata" `Quick metadata_in_footer;
        ] );
      ( "code blocks -> cells",
        [
          Alcotest.test_case "3 x-ocaml cells" `Quick three_x_ocaml_cells;
          Alcotest.test_case "init attr preserved" `Quick init_attribute_preserved;
          Alcotest.test_case "data-source on every cell" `Quick data_source_present;
        ] );
      ( "slide structure",
        [
          Alcotest.test_case "two slide sections" `Quick two_slide_sections;
          Alcotest.test_case "speaker notes" `Quick speaker_notes;
          Alcotest.test_case "fragment" `Quick fragment_present;
        ] );
      ( "runtime wiring",
        [
          Alcotest.test_case "mode toggle button" `Quick mode_toggle_button;
          Alcotest.test_case "cell controls" `Quick cell_controls;
          Alcotest.test_case "root-relative asset paths" `Quick asset_paths_root_relative;
          Alcotest.test_case "reveal wrapper" `Quick reveal_wrapper;
        ] );
    ]
