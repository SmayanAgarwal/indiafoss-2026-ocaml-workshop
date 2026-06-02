(* Ten-pin bowling scorer. [score] takes the list of rolls of a
   complete game (pins knocked down per roll) and returns the
   total. Strikes and spares earn bonus pins from later rolls; the
   tenth frame's bonus rolls score once. *)

let score rolls =
  if List.exists (fun r -> r < 0 || r > 10) rolls then
    invalid_arg "score: a roll must knock down 0..10 pins";
  let rec go frame rolls =
    if frame = 10 then 0
    else
      match rolls with
      | 10 :: (b :: c :: _ as rest) ->
        (* strike: next two rolls are the bonus *)
        10 + b + c + go (frame + 1) rest
      | a :: b :: (c :: _ as rest) when a + b = 10 ->
        (* spare: next roll is the bonus *)
        10 + c + go (frame + 1) rest
      | a :: b :: rest when a + b < 10 ->
        a + b + go (frame + 1) rest
      | _ -> invalid_arg "score: not a complete game"
  in
  go 0 rolls
