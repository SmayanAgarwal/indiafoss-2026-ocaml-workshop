(* Unit tests for the OCaml side of the toolchain. *)

open Nptel_build

let check_string = Alcotest.(check string)
let check_int = Alcotest.(check int)
let check_bool = Alcotest.(check bool)
let check_string_list = Alcotest.(check (list string))

(* ---- Frontmatter ---------------------------------------------------- *)

let fm_basic () =
  let src =
    {|---
title: "Hello world"
lecture_no: 3
week: 2
duration_target_min: 25
concepts: [pure functions, immutability]
keywords: [OCaml, FP]
activity_question: "Is this referentially transparent?"
think_about_this: "Why?"
reading:
  - title: "CS3110"
    url: https://cs3110.github.io/textbook/
---

# Body
|}
  in
  let fm, body = Frontmatter.parse src in
  check_string "title" "Hello world" fm.title;
  Alcotest.(check (option int)) "lecture_no" (Some 3) fm.lecture_no;
  Alcotest.(check (option int)) "week" (Some 2) fm.week;
  Alcotest.(check (option int)) "duration_target_min" (Some 25) fm.duration_target_min;
  check_string_list "concepts" ["pure functions"; "immutability"] fm.concepts;
  check_string_list "keywords" ["OCaml"; "FP"] fm.keywords;
  Alcotest.(check (option string)) "activity"
    (Some "Is this referentially transparent?") fm.activity_question;
  Alcotest.(check (option string)) "think" (Some "Why?") fm.think_about_this;
  check_int "reading count" 1 (List.length fm.reading);
  check_string "reading title" "CS3110" (List.hd fm.reading).title;
  check_string "reading url" "https://cs3110.github.io/textbook/"
    (List.hd fm.reading).url;
  check_bool "body starts with # Body" true
    (String.length body > 0 && String.contains body '#')

let fm_no_frontmatter () =
  let fm, body = Frontmatter.parse "# Just a heading\n\nno frontmatter\n" in
  check_string "title is empty" "" fm.title;
  check_string "body preserved" "# Just a heading\n\nno frontmatter\n" body

let fm_quoted_strings () =
  let src = {|---
title: 'single quoted'
keywords: ["with spaces", bare]
---
|} in
  let fm, _ = Frontmatter.parse src in
  check_string "title unquoted" "single quoted" fm.title;
  check_string_list "keywords mixed quoting" ["with spaces"; "bare"] fm.keywords

(* ---- Divs preprocessor --------------------------------------------- *)

let divs_slide_simple () =
  let out = Divs.preprocess ":::slide\nhello\n:::\n" in
  check_bool "opens section" true
    (Str.string_match (Str.regexp_string "<section class=\"slide\"") out 0
     || (try ignore (Str.search_forward (Str.regexp_string "<section class=\"slide\"") out 0); true
         with Not_found -> false));
  check_bool "closes section" true
    (try ignore (Str.search_forward (Str.regexp_string "</section>") out 0); true
     with Not_found -> false)

let divs_notes () =
  let out = Divs.preprocess ":::notes\nspeaker\n:::\n" in
  check_bool "aside.notes opens" true
    (try ignore (Str.search_forward (Str.regexp_string "<aside class=\"notes\">") out 0); true
     with Not_found -> false);
  check_bool "aside closes" true
    (try ignore (Str.search_forward (Str.regexp_string "</aside>") out 0); true
     with Not_found -> false)

let divs_fragment () =
  let out = Divs.preprocess ":::fragment\nbullet\n:::\n" in
  check_bool "div.fragment opens" true
    (try ignore (Str.search_forward (Str.regexp_string "<div class=\"fragment\">") out 0); true
     with Not_found -> false)

let divs_nesting () =
  let out = Divs.preprocess ":::slide\n:::fragment\nx\n:::\n:::\n" in
  let count_sub sub =
    let r = Str.regexp_string sub in
    let rec go i n =
      match Str.search_forward r out i with
      | exception Not_found -> n
      | j -> go (j + String.length sub) (n + 1)
    in
    go 0 0
  in
  check_int "two opens (section + div.fragment)"
    1 (count_sub "<section class=\"slide\"");
  check_int "one fragment div" 1 (count_sub "<div class=\"fragment\">")

let divs_no_match () =
  let src = "plain prose, no divs\n" in
  let out = Divs.preprocess src in
  (* Should pass through, possibly with trailing newlines. *)
  check_bool "plain prose preserved" true
    (try ignore (Str.search_forward (Str.regexp_string "plain prose") out 0); true
     with Not_found -> false)

(* ---- OCaml fence -> <x-ocaml> -------------------------------------- *)

let parse_ocaml_block () =
  let doc =
    Cmarkit.Doc.of_string "```ocaml\nlet x = 1\n```\n"
  in
  let doc' = Parse.transform doc in
  let html = Cmarkit_html.of_doc ~safe:false doc' in
  check_bool "emits x-ocaml" true
    (try ignore (Str.search_forward (Str.regexp_string "<x-ocaml") html 0); true
     with Not_found -> false);
  check_bool "carries source verbatim" true
    (try ignore (Str.search_forward (Str.regexp_string "let x = 1") html 0); true
     with Not_found -> false);
  check_bool "carries data-source attribute" true
    (try ignore (Str.search_forward (Str.regexp_string "data-source=") html 0); true
     with Not_found -> false)

let parse_ocaml_attrs () =
  let doc =
    Cmarkit.Doc.of_string "```ocaml init=true autorun\nprint_endline \"hi\"\n```\n"
  in
  let html = Cmarkit_html.of_doc ~safe:false (Parse.transform doc) in
  check_bool "init=true preserved" true
    (try ignore (Str.search_forward (Str.regexp_string "init=\"true\"") html 0); true
     with Not_found -> false);
  check_bool "bare attribute -> =true" true
    (try ignore (Str.search_forward (Str.regexp_string "autorun=\"true\"") html 0); true
     with Not_found -> false)

let parse_non_ocaml_fence () =
  let doc =
    Cmarkit.Doc.of_string "```python\nprint('hi')\n```\n"
  in
  let html = Cmarkit_html.of_doc ~safe:false (Parse.transform doc) in
  check_bool "python fence stays as code" true
    (try ignore (Str.search_forward (Str.regexp_string "<code") html 0); true
     with Not_found -> false);
  check_bool "no x-ocaml emitted" true
    (try
       ignore (Str.search_forward (Str.regexp_string "<x-ocaml") html 0);
       false
     with Not_found -> true)

let parse_html_escape_in_cell () =
  let doc =
    Cmarkit.Doc.of_string "```ocaml\nlet s = \"<&>\"\n```\n"
  in
  let html = Cmarkit_html.of_doc ~safe:false (Parse.transform doc) in
  check_bool "angle brackets escaped" true
    (try ignore (Str.search_forward (Str.regexp_string "&lt;&amp;&gt;") html 0); true
     with Not_found -> false)

let parse_ocaml_test_attr () =
  let doc =
    Cmarkit.Doc.of_string
      "```ocaml test\nlet () = print_endline \"ok\"\n```\n"
  in
  let html = Cmarkit_html.of_doc ~safe:false (Parse.transform doc) in
  check_bool "data-quiz-test marker present" true
    (try ignore (Str.search_forward (Str.regexp_string "data-quiz-test=\"true\"") html 0); true
     with Not_found -> false);
  check_bool "implicit hidden=true" true
    (try ignore (Str.search_forward (Str.regexp_string "hidden=\"true\"") html 0); true
     with Not_found -> false);
  (* The test info-string flag must not leak into the rendered
     element as a stand-alone attribute. The substring is sought
     with a leading space; the dash in data-quiz-test then prevents
     a false positive. *)
  check_bool "test=true NOT emitted as own attribute" true
    (try
       ignore (Str.search_forward (Str.regexp_string " test=\"") html 0);
       false
     with Not_found -> true)

(* ---- Quiz fenced divs ---------------------------------------------- *)

let divs_quiz_mcq () =
  let out = Divs.preprocess ":::quiz mcq\nq?\n- [x] yes\n- [ ] no\n:::\n" in
  check_bool "quiz-mcq class opens" true
    (try ignore (Str.search_forward (Str.regexp_string "<div class=\"quiz quiz-mcq\"") out 0); true
     with Not_found -> false);
  check_bool "auto-id q1" true
    (try ignore (Str.search_forward (Str.regexp_string "data-quiz-id=\"q1\"") out 0); true
     with Not_found -> false)

let divs_quiz_code () =
  let out = Divs.preprocess ":::quiz code\nprompt\n```ocaml\nlet x = 1\n```\n:::\n" in
  check_bool "quiz-code class opens" true
    (try ignore (Str.search_forward (Str.regexp_string "<div class=\"quiz quiz-code\"") out 0); true
     with Not_found -> false);
  check_bool "auto-id q1" true
    (try ignore (Str.search_forward (Str.regexp_string "data-quiz-id=\"q1\"") out 0); true
     with Not_found -> false)

let divs_quiz_ids_sequential () =
  (* Two quizzes in one document get q1 and q2 respectively. *)
  let src =
    ":::quiz mcq\n- [x] a\n:::\n\nprose\n\n:::quiz code\n```ocaml\nlet _ = 1\n```\n:::\n"
  in
  let out = Divs.preprocess src in
  check_bool "first quiz is q1" true
    (try ignore (Str.search_forward (Str.regexp_string "data-quiz-id=\"q1\"") out 0); true
     with Not_found -> false);
  check_bool "second quiz is q2" true
    (try ignore (Str.search_forward (Str.regexp_string "data-quiz-id=\"q2\"") out 0); true
     with Not_found -> false)

(* ---- Run ----------------------------------------------------------- *)

let () =
  Alcotest.run "nptel-build"
    [
      ( "frontmatter",
        [
          Alcotest.test_case "basic" `Quick fm_basic;
          Alcotest.test_case "missing" `Quick fm_no_frontmatter;
          Alcotest.test_case "quoted strings" `Quick fm_quoted_strings;
        ] );
      ( "divs",
        [
          Alcotest.test_case "slide" `Quick divs_slide_simple;
          Alcotest.test_case "notes" `Quick divs_notes;
          Alcotest.test_case "fragment" `Quick divs_fragment;
          Alcotest.test_case "nesting" `Quick divs_nesting;
          Alcotest.test_case "no match" `Quick divs_no_match;
        ] );
      ( "parse",
        [
          Alcotest.test_case "ocaml block -> x-ocaml" `Quick parse_ocaml_block;
          Alcotest.test_case "attrs in info string" `Quick parse_ocaml_attrs;
          Alcotest.test_case "non-ocaml fence untouched" `Quick parse_non_ocaml_fence;
          Alcotest.test_case "html escape" `Quick parse_html_escape_in_cell;
          Alcotest.test_case "ocaml test -> quiz test cell" `Quick parse_ocaml_test_attr;
        ] );
      ( "quizzes",
        [
          Alcotest.test_case "quiz mcq div" `Quick divs_quiz_mcq;
          Alcotest.test_case "quiz code div" `Quick divs_quiz_code;
          Alcotest.test_case "ids sequential" `Quick divs_quiz_ids_sequential;
        ] );
    ]
