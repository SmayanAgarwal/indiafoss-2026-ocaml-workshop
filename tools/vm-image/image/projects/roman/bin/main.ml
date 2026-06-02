let () =
  let ns = [ 7; 42; 1986; 2026; 3999 ] in
  List.iter
    (fun n -> Printf.printf "%4d = %s\n" n (Roman.to_roman n))
    ns
