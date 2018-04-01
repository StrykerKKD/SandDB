module type Serializer = sig
  type t
  val t_of_string : string -> t
  val string_of_t : t -> string
end;;

module type Database = sig
  type t
  val read : string -> t
  val write : t -> string
  val write_raw : string -> string
end;;

module Make_Database(Serializer : Serializer) : Database = struct
  type t = Serializer.t
  let read data = Serializer.t_of_string data
  let write data = Serializer.string_of_t data
  let write_raw data = data
end;;