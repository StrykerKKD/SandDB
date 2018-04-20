(** [Sanddb.Database] is the basic module type that will be used to communicate with the database.*)
module type Database = sig
  type t
  val write_lock : Lwt_mutex.t
  val file_path : string
  val read_records : unit -> (Uuidm.t * t, exn) result list Lwt.t
  val insert_record : t -> Uuidm.t Lwt.t
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
val insert_record : (module Database with type t = 'a) -> 'a -> Uuidm.t Lwt.t

(** [Sanddb.read database unit] reads the data from the database.
Creates the database file if it doesn't exists.
Throws exception if the file is empty.*)
val read_records : (module Database with type t = 'a) -> unit -> (Uuidm.t * 'a, exn) result list Lwt.t