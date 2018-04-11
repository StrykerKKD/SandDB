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

val create_json_database : Lwt_io.file_name -> (module Json_Serializer with type t = 'a) -> (module Database with type t = 'a)

val create_biniou_database : Lwt_io.file_name -> (module Biniou_Serializer with type t = 'a) -> (module Database with type t = 'a)

val write : (module Database with type t = 'a) -> 'a -> unit Lwt.t

val read : (module Database with type t = 'a) -> unit -> 'a Lwt.t