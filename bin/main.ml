open Hello_t
open Lwt_io

let%lwt writing =
  let date = [{ year = 1970; month = 1; day = 1 };{ year = 1970; month = 1; day = 1 }] in
  with_file ~mode: Output "test.txt" (fun channel -> write channel (Hello_j.string_of_t date))

let%lwt reading =
  let%lwt content = with_file ~mode: Input "test.txt" (fun channel -> read channel) in
  let hello = Hello_j.t_of_string content in
  let _ = List.map (fun hello -> Printf.printf "year: %d, month: %d, day: %d\n" hello.year hello.month hello.day) hello in
  Lwt.return_unit

let atomic_stuff1 = atomic (fun channel -> write channel "macska") stdout
let atomic_stuff2 = atomic (fun channel -> write channel "macska") stdout

let database = Database.create_database "test.txt" (module Hello_j)