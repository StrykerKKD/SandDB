open Hello_t
open Lwt.Infix

let json_database = Sanddb.create_json_database "test.txt" (module Hello_j)
let input = [{ year = 1970; month = 1; day = 1 };{ year = 1970; month = 1; day = 1 }]
let a_write = Sanddb.write json_database input
let a_read = Sanddb.read json_database () >>= fun data ->
Lwt_list.iter_p (fun date -> Lwt_io.printf "year: %d, month: %d, day: %d\n" date.year date.month date.day ) data

let _ = Lwt_main.run (Lwt.join [a_read;a_read])
