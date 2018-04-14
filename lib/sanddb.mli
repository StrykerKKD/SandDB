module type Database = sig
  type t
  val write_lock : Lwt_mutex.t
  val file_path : string
  val read : unit -> t Lwt.t
  val write : t -> unit Lwt.t
end;;

val create_json_database : Lwt_io.file_name -> (module Serializers.Json_Serializer with type t = 'a) -> (module Database with type t = 'a)

val create_biniou_database : Lwt_io.file_name -> (module Serializers.Biniou_Serializer with type t = 'a) -> (module Database with type t = 'a)

val write : (module Database with type t = 'a) -> 'a -> unit Lwt.t

val read : (module Database with type t = 'a) -> unit -> 'a Lwt.t