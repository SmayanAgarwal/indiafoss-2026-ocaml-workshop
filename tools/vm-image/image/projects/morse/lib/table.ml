(* International Morse code: letters and digits. *)

let pairs =
  [ ('A', ".-"); ('B', "-..."); ('C', "-.-."); ('D', "-..");
    ('E', "."); ('F', "..-."); ('G', "--."); ('H', "....");
    ('I', ".."); ('J', ".---"); ('K', "-.-"); ('L', ".-..");
    ('M', "--"); ('N', "-."); ('O', "---"); ('P', ".--.");
    ('Q', "--.-"); ('R', ".-."); ('S', "..."); ('T', "-");
    ('U', "..-"); ('V', "...-"); ('W', ".--"); ('X', "-..-");
    ('Y', "-.--"); ('Z', "--..");
    ('0', "-----"); ('1', ".----"); ('2', "..---"); ('3', "...--");
    ('4', "....-"); ('5', "....."); ('6', "-...."); ('7', "--...");
    ('8', "---.."); ('9', "----.") ]

let code_of_char c =
  match List.assoc_opt (Char.uppercase_ascii c) pairs with
  | Some code -> code
  | None -> invalid_arg (Printf.sprintf "no Morse code for %C" c)

let char_of_code code =
  match List.find_opt (fun (_, m) -> m = code) pairs with
  | Some (c, _) -> c
  | None -> invalid_arg (Printf.sprintf "unknown Morse code %S" code)
