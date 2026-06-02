let () =
  let input =
    match Array.to_list Sys.argv with
    | _ :: (_ :: _ as words) -> String.concat " " words
    | _ -> "hello ocaml"
  in
  Printf.printf "%s\n%s\n" input (Morse.encode input)
