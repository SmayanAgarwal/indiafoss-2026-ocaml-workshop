(* [longest_streak xs] is the length of the longest run of equal
   adjacent elements of [xs]; 0 for the empty list.  This is the
   black-box example from the test-design lecture. *)
let longest_streak xs =
  let rec go prev run best = function
    | [] -> best
    | x :: rest ->
        let run = if prev = Some x then run + 1 else 1 in
        go (Some x) run (max best run) rest
  in
  go None 0 0 xs
