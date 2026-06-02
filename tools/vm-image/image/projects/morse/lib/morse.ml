(* Letters are separated by single spaces, words by " / ". *)

let explode s = List.init (String.length s) (String.get s)

let encode_word w = String.concat " " (List.map Table.code_of_char (explode w))

let encode s =
  s
  |> String.split_on_char ' '
  |> List.filter (fun w -> w <> "")
  |> List.map encode_word
  |> String.concat " / "

let decode s =
  s
  |> String.split_on_char ' '
  |> List.filter (fun t -> t <> "")
  |> List.map (fun t ->
         if t = "/" then " " else String.make 1 (Table.char_of_code t))
  |> String.concat ""
