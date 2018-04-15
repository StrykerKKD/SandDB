(** [Sanddb.Database] is the basic module type that will be used to communicate with the database.*)
module type Database = sig
  type t
  val write_lock : Lwt_mutex.t
  val file_path : string
  val read : unit -> t Lwt.t
  val write : t -> unit Lwt.t
end;;

(** [Sanddb.create_json_database file_name json_serializer] will create a json database based on the provided:
 - [file_name] which will be tha base of the database
 - [json_serializer] which will be responsible with the serialization between the database and the client
 This function will return a first class database module, which can be used to communicate with the database.
*)
val create_json_database : Lwt_io.file_name -> (module Serializers.Json_Serializer with type t = 'a) -> (module Database with type t = 'a)

(** [Sanddb.create_biniou_database file_name biniou_serializer] will create a biniou database based on the provided:
 - [file_name] which will be tha base of the database
 - [biniou_serializer] which will be responsible with the serialization between the database and the client
 This function will return a first class database module, which can be used to communicate with the database.
*)
val create_biniou_database : Lwt_io.file_name -> (module Serializers.Biniou_Serializer with type t = 'a) -> (module Database with type t = 'a)


(** [Sanddb.write database data] writes the data into the database, by overwriting the existing data.
Creates the database file if it doesn't exists.*)
val write : (module Database with type t = 'a) -> 'a -> unit Lwt.t

(** [Sanddb.read database unit] reads the data from the database.
Creates the database file if it doesn't exists.
Throws exception if the file is empty.*)
val read : (module Database with type t = 'a) -> unit -> 'a Lwt.t