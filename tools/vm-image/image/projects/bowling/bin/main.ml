let games =
  [ ("gutter game", List.init 20 (fun _ -> 0));
    ("all ones", List.init 20 (fun _ -> 1));
    ("one spare", [ 5; 5; 3 ] @ List.init 17 (fun _ -> 0));
    ("one strike", [ 10; 3; 4 ] @ List.init 16 (fun _ -> 0));
    ("perfect game", List.init 12 (fun _ -> 10)) ]

let () =
  List.iter
    (fun (name, rolls) ->
      Printf.printf "%-12s = %3d\n" name (Bowling.score rolls))
    games
