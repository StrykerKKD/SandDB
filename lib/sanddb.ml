open Lwt.Infix

module type Json_Serializer = sig
  type t
  val t_of_string : string -> t
  val string_of_t : ?len:int -> t -> string
end;;

module type Biniou_Serializer = sig
  type t
  val t_of_string : ?pos:int -> string -> t
  val string_of_t : ?len:int -> t -> string
end;;

module type Database = sig
  type t
  val file_path : string
  val read : unit -> t Lwt.t
  val write : t -> unit Lwt.t
end;;

let database_json_read (type a) file_path json_serializer =
  let module Json_Serializer = (val json_serializer : Json_Serializer with type t = a) in
  Lwt_io.with_file ~mode: Input file_path (fun channel -> Lwt_io.read_line channel) >>= fun raw_data ->
  let data = Json_Serializer.t_of_string raw_data in
  Lwt.return data

let database_json_write (type a) file_path json_serializer data =
  let module Json_Serializer = (val json_serializer : Json_Serializer with type t = a) in
  Lwt_io.with_file 
    ~flags:([Unix.O_WRONLY; Unix.O_CREAT; Unix.O_NONBLOCK]) 
    ~mode: Output 
    file_path 
    (fun channel -> 
      let raw_data = Json_Serializer.string_of_t data in
      let raw_data_size = String.length raw_data in
      Lwt_io.write_line channel raw_data >>= fun () ->
      Lwt_io.flush channel >>= fun () ->
      Lwt_unix.truncate file_path raw_data_size)

let create_json_database (type a) file_path json_serializer =
  let module Json_Serializer = (val json_serializer : Json_Serializer with type t = a) in
  (module struct
    type t = Json_Serializer.t
    let file_path = file_path
    let read () = database_json_read file_path json_serializer
    let write data = database_json_write file_path json_serializer data
  end : Database)

let database_biniou_read (type a) file_path biniou_serializer =
  let module Biniou_Serializer = (val biniou_serializer : Biniou_Serializer with type t = a) in
  Lwt_io.with_file ~mode: Input file_path (fun channel -> Lwt_io.read_line channel) >>= fun raw_data ->  
  let data = Biniou_Serializer.t_of_string raw_data in
  Lwt.return data

let database_biniou_write (type a) file_path biniou_serializer data =
  let module Biniou_Serializer = (val biniou_serializer : Biniou_Serializer with type t = a) in
  Lwt_io.with_file 
    ~flags:([Unix.O_WRONLY; Unix.O_CREAT; Unix.O_NONBLOCK]) 
    ~mode: Output 
    file_path 
    (fun channel -> 
      let raw_data = Biniou_Serializer.string_of_t data in
      let raw_data_size = String.length raw_data in
      Lwt_io.write_line channel raw_data >>= fun () ->
      Lwt_io.flush channel >>= fun () ->
      Lwt_unix.truncate file_path raw_data_size)

let create_biniou_database (type a) file_path biniou_serializer =
  let module Biniou_Serializer = (val biniou_serializer : Biniou_Serializer with type t = a) in
  (module struct
    type t = Biniou_Serializer.t
    let file_path = file_path
    let read () = database_biniou_read file_path biniou_serializer
    let write data = database_biniou_write file_path biniou_serializer data
  end : Database)

let write (type a) (module Database : Database with type t = a) (data : a) =
  Database.write data

let read (type a) (module Database : Database with type t = a) =
  Database.read