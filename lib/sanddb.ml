open Lwt.Infix

module type Database = sig
  type t
  val file_path : string
  val read : unit -> t Lwt.t
  val write : t -> unit Lwt.t
end;;

let database_read (type a) file_path serializer =
  let open Serializer_converter in
  let module Serializer = (val serializer : Serializer with type t = a) in
  Lwt_io.with_file ~mode: Input file_path (fun channel -> Lwt_io.read_line channel) >>= fun raw_data ->  
  let data = Serializer.t_of_string raw_data in
  Lwt.return data

let database_write (type a) file_path serializer data =
  let open Serializer_converter in
  let module Serializer = (val serializer : Serializer with type t = a) in
  Lwt_io.with_file 
    ~flags:([Unix.O_WRONLY; Unix.O_CREAT; Unix.O_NONBLOCK]) 
    ~mode: Output 
    file_path 
    (fun channel -> 
      let raw_data = Serializer.string_of_t data in
      let raw_data_size = String.length raw_data in
      Lwt_io.write_line channel raw_data >>= fun () ->
      Lwt_io.flush channel >>= fun () ->
      Lwt_unix.truncate file_path raw_data_size)

let create_json_database (type a) file_path json_serializer =
  let open Serializer_converter in
  let serializer = convert_json_serializer json_serializer in
  (module struct
    type t = a
    let file_path = file_path
    let read () = database_read file_path serializer
    let write data = database_write file_path serializer data
  end : Database with type t = a)

let create_biniou_database (type a) file_path biniou_serializer =
  let open Serializer_converter in
  let serializer = convert_biniou_serializer biniou_serializer in
  (module struct
    type t = a
    let file_path = file_path
    let read () = database_read file_path serializer
    let write data = database_write file_path serializer data
  end : Database with type t = a)

let write (type a) (module Database : Database with type t = a) (data : a) =
  Database.write data

let read (type a) (module Database : Database with type t = a) =
  Database.read
