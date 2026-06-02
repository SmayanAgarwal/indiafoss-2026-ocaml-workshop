let check msg b = if not b then (print_endline ("FAIL: " ^ msg); exit 1)

let zeros n = List.init n (fun _ -> 0)

let () =
  check "gutter game" (Bowling.score (zeros 20) = 0);
  check "all ones" (Bowling.score (List.init 20 (fun _ -> 1)) = 20);
  check "one spare" (Bowling.score ([ 5; 5; 3 ] @ zeros 17) = 16);
  check "one strike" (Bowling.score ([ 10; 3; 4 ] @ zeros 16) = 24);
  check "all spares" (Bowling.score (List.init 21 (fun _ -> 5)) = 150);
  check "perfect game" (Bowling.score (List.init 12 (fun _ -> 10)) = 300);
  check "spare in tenth"
    (Bowling.score (zeros 18 @ [ 5; 5; 7 ]) = 17);
  print_endline "All tests passed."
