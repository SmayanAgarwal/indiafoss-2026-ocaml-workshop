(* Roman numeral conversion: a small multi-module dune project to
   exercise dune build / runtest / exec inside the VM. *)

let digits =
  [ (1000, "M"); (900, "CM"); (500, "D"); (400, "CD");
    (100, "C"); (90, "XC"); (50, "L"); (40, "XL");
    (10, "X"); (9, "IX"); (5, "V"); (4, "IV"); (1, "I") ]

let to_roman n =
  if n <= 0 || n > 3999 then invalid_arg "to_roman: out of range"
  else
    let rec go n ds acc =
      match ds with
      | [] -> acc
      | (v, s) :: rest ->
        if n >= v then go (n - v) ds (acc ^ s)
        else go n rest acc
    in
    go n digits ""

let value_of_char = function
  | 'I' -> 1 | 'V' -> 5 | 'X' -> 10 | 'L' -> 50
  | 'C' -> 100 | 'D' -> 500 | 'M' -> 1000
  | c -> invalid_arg (Printf.sprintf "of_roman: bad character %c" c)

let of_roman s =
  let n = String.length s in
  let rec go i acc =
    if i >= n then acc
    else
      let v = value_of_char s.[i] in
      if i + 1 < n && v < value_of_char s.[i + 1] then go (i + 1) (acc - v)
      else go (i + 1) (acc + v)
  in
  if n = 0 then invalid_arg "of_roman: empty string" else go 0 0
