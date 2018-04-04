module type Serializer = sig
  type t
  val t_of_string : string -> t
  val string_of_t : ?len:int -> t -> string
end;;

module type Database = sig
  type t
  val file_path : string
  val read : string -> t
  val write : t -> string
  val write_raw : string -> string
end;;

(*module Make_Database(Serializer : Serializer) : Database = struct
  type t = Serializer.t
  let read data = Serializer.t_of_string data
  let write data = Serializer.string_of_t data
  let write_raw data = data
end;;*)

let create_database file_path serializer =
  let module Serializer = (val serializer : Serializer) in
  (module struct
    type t = Serializer.t
    let file_path = file_path
    let read data = Serializer.t_of_string data
    let write data = Serializer.string_of_t data
    let write_raw data = data
  end : Database)

let write (type a) (module Database : Database with type t = a) (data : a) =
  Database.write data

let read (type a) (module Database : Database with type t = a) (data : string) =
  Database.read data