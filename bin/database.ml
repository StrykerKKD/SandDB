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
  val read : string -> t
  val write : t -> string
end;;

let create_json_database file_path json_serializer =
  let module Json_Serializer = (val json_serializer : Json_Serializer) in
  (module struct
    type t = Json_Serializer.t
    let file_path = file_path
    let read data = Json_Serializer.t_of_string data
    let write data = Json_Serializer.string_of_t data
  end : Database)

let create_biniou_database file_path biniou_serializer =
  let module Biniou_Serializer = (val biniou_serializer : Biniou_Serializer) in
  (module struct
    type t = Biniou_Serializer.t
    let file_path = file_path
    let read data = Biniou_Serializer.t_of_string data
    let write data = Biniou_Serializer.string_of_t data
  end : Database)

let write (type a) (module Database : Database with type t = a) (data : a) =
  Database.write data

let read (type a) (module Database : Database with type t = a) (data : string) =
  Database.read data