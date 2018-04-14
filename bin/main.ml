open Hello_t
open Lwt.Infix

let json_database = Sanddb.create_json_database "test.txt" (module Hello_j)

let input1 = [{ year = 1970; month = 1; day = 1 }]
let a_write1 = Sanddb.write json_database input1

let input2 = [{ year = 1970; month = 1; day = 1 };{ year = 1970; month = 1; day = 1 }]
let a_write2 = Sanddb.write json_database input2

let a_read1 = Sanddb.read json_database () >>= fun data ->
Lwt_list.iter_p (fun date -> Lwt_io.printf "<read1>:year: %d, month: %d, day: %d\n" date.year date.month date.day ) data

let a_read2 = Sanddb.read json_database () >>= fun data ->
Lwt_list.iter_p (fun date -> Lwt_io.printf "<read2>:year: %d, month: %d, day: %d\n" date.year date.month date.day ) data

let _ = Lwt_main.run (Lwt.join [a_write1;a_write2;a_read1;a_read2])
