let check msg b = if not b then (print_endline ("FAIL: " ^ msg); exit 1)

let () =
  check "to_roman 1" (Roman.to_roman 1 = "I");
  check "to_roman 4" (Roman.to_roman 4 = "IV");
  check "to_roman 1986" (Roman.to_roman 1986 = "MCMLXXXVI");
  check "to_roman 3999" (Roman.to_roman 3999 = "MMMCMXCIX");
  check "of_roman MMXXVI" (Roman.of_roman "MMXXVI" = 2026);
  (* round-trip on the whole domain *)
  for n = 1 to 3999 do
    check (string_of_int n) (Roman.of_roman (Roman.to_roman n) = n)
  done;
  print_endline "All tests passed."
