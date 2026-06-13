open Lwt.Syntax

let start () =
  let rec loop = function
    | 0 -> Lwt.return_unit
    | n ->
        Logs.info (fun f -> f "hello");
        let* () = Mirage_sleep.ns (Duration.of_sec 1) in
        loop (n - 1)
  in
  loop 4
