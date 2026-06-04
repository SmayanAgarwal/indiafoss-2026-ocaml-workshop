(* A DELIBERATELY PARTIAL black-box suite: only the first three
   rows of the lecture's table (empty, singleton, all-distinct).
   None of these has an adjacent equal pair, so the [run + 1]
   branch of [longest_streak] is never exercised: coverage will
   show it red.  The fix is to add the rows we left out, e.g.
   [7; 7; 7].  *)
let () =
  assert (Streak.longest_streak [] = 0);
  assert (Streak.longest_streak [5] = 1);
  assert (Streak.longest_streak [1; 2; 3] = 1);
  print_endline "partial streak suite passed"
