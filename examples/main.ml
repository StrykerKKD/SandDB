open Record_t
open Lwt.Infix

let json_database = Sanddb.create_json_database "test.txt" (module Record_j)

let input1 = { year = 2018; month = 4; day = 30; data="Some data 1"}
let a_write1 = Sanddb.insert_record json_database input1 >>= fun id ->
  Lwt_io.printf "Id: %s\n" (Sanddb.Record_Id.to_string id)

let input2 = { year = 2018; month = 5; day = 1; data="Some data 2"}
let a_write2 = Sanddb.insert_record json_database input2 >>= fun id ->
  Lwt_io.printf "Id: %s\n" (Sanddb.Record_Id.to_string id)

let print_record_content record =
  match record with 
  | Ok(id, data) -> Lwt_io.printf "Record: %d-%d-%d %s\n" data.year data.month data.day data.data
  | Error error -> Lwt_io.printf "Error: %s\n" (Printexc.to_string error)

let a_read1 = Sanddb.read_all_records json_database () >>= fun records ->
  Lwt_list.iter_p print_record_content records

let a_read2 = Sanddb.read_all_records json_database () >>= fun records ->
  Lwt_list.iter_p print_record_content records

let _ = Lwt_main.run (Lwt.join [a_write1; a_write2; a_read1; a_read2])
