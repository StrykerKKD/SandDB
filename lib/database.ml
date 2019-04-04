(** [Sanddb.Database] contains the type of the database and it's internal implementation.*)

(** Database.T is the (module) type of the database. 
  In SandDB every database instance will have this type regardles of the serializing method.
*)
module type T = sig
  type t
  val file_path : string
  val read_all_records : unit -> (Record_id.t * t, exn) result list Lwt.t
  val read_visible_records : unit -> (Record_id.t * t, exn) result list Lwt.t
  val insert_record : t -> Record_id.t Lwt.t
  val insert_shadowing_record : Record_id.t -> t -> Record_id.t Lwt.t
end