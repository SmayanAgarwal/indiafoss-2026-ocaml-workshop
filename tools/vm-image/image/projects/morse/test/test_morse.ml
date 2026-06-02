let check msg b = if not b then (print_endline ("FAIL: " ^ msg); exit 1)

let () =
  check "sos" (Morse.encode "sos" = "... --- ...");
  check "word split"
    (Morse.encode "hello ocaml"
    = ".... . .-.. .-.. --- / --- -.-. .- -- .-..");
  check "decode" (Morse.decode "... --- ..." = "SOS");
  (* round-trip: decoding an encoding recovers the (uppercased) input *)
  check "round-trip sentence"
    (Morse.decode (Morse.encode "hello ocaml") = "HELLO OCAML");
  String.iter
    (fun c ->
      let s = String.make 1 c in
      check s (Morse.decode (Morse.encode s) = s))
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  print_endline "All tests passed."
