module type T = sig
  type t
  val file_path : string
  val read_all_records : unit -> (Record_id.t * t, exn) result list Lwt.t
  val read_visible_records : unit -> (Record_id.t * t, exn) result list Lwt.t
  val insert_record : t -> Record_id.t Lwt.t
  val insert_shadowing_record : Record_id.t -> t -> Record_id.t Lwt.t
end

val create_json_database : string -> (module Serializer.Json_serializer with type t = 'a) -> (module T with type t = 'a)

val create_biniou_database : string -> (module Serializer.Biniou_serializer with type t = 'a) -> (module T with type t = 'a)