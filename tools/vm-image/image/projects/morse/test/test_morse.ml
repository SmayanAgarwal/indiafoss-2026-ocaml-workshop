open OUnit2

let id s = s

let tests =
  "morse"
  >::: [
         ("sos" >:: fun _ ->
           assert_equal ~printer:id "... --- ..." (Morse.encode "sos"));
         ("decode" >:: fun _ ->
           assert_equal ~printer:id "SOS" (Morse.decode "... --- ..."));
         ("word split" >:: fun _ ->
           assert_equal ~printer:id
             ".... . .-.. .-.. --- / --- -.-. .- -- .-.."
             (Morse.encode "hello ocaml"));
         ("round-trip sentence" >:: fun _ ->
           assert_equal ~printer:id "HELLO OCAML"
             (Morse.decode (Morse.encode "hello ocaml")));
         ("round-trip alphabet" >:: fun _ ->
           String.iter
             (fun c ->
               let s = String.make 1 c in
               assert_equal ~printer:id s (Morse.decode (Morse.encode s)))
             "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789");
         ("unknown character" >:: fun _ ->
           assert_raises (Invalid_argument "no Morse code for '?'")
             (fun () -> Morse.encode "?"));
       ]

let () = run_test_tt_main tests
