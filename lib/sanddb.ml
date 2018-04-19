open Lwt.Infix

module type Database = sig
  type t
  val write_lock : Lwt_mutex.t
  val file_path : string
  val read_records : unit -> (Uuidm.t * t, exn) result list Lwt.t
  val insert_record : t -> unit Lwt.t
end;;

let deserialize_record_data (type a) record_data_serializer record_data =
  let open Serializer_converter in
  let module Record_Data_Serializer = (val record_data_serializer : Serializer with type t = a) in
  Record_Data_Serializer.t_of_string record_data

let deserialize_record record_serializer record_data_serializer record =
  let open Serializer_converter in
  let open Record_t in
  let module Record_Serializer = (val record_serializer : Serializer with type t = Record_t.t) in
  let deserialized_record = Record_Serializer.t_of_string record in
  let record_uuid = Base.Result.of_option ~error: (Failure "UUID parsing failed") (Uuidm.of_string deserialized_record.id) in
  let record_data = Base.Result.try_with (fun () -> deserialize_record_data record_data_serializer deserialized_record.data) in
  match record_uuid, record_data with
  | Ok uuid, Ok data -> Ok (uuid, data)
  | Error _ as error ,  _ -> error
  | _ , (Error _ as error) -> error 

let database_read_records file_path record_serializer record_data_serializer =
  Lwt_io.with_file ~mode: Input file_path (fun channel -> Lwt_io.read channel) >>= fun raw_data ->
  let cleaned_raw_data = String.trim raw_data in
  let raw_records = String.split_on_char '\n' cleaned_raw_data in
  let serializer = deserialize_record record_serializer record_data_serializer in
  let records = List.map serializer raw_records in
  Lwt.return records

let serialize_record_data (type a) record_data_serializer record_data =
  let open Serializer_converter in
  let module Record_Data_Serializer = (val record_data_serializer : Serializer with type t = a) in
  Record_Data_Serializer.string_of_t record_data

let serialize_record record_serializer record_data_serializer record_data =
  let open Serializer_converter in
  let open Record_t in
  let module Record_Serializer = (val record_serializer : Serializer with type t = Record_t.t) in
  let serialized_record_data = serialize_record_data record_data_serializer record_data in
  let id = Uuidm.v `V4 |> Uuidm.to_string in
  let record = {id = id; data = serialized_record_data} in
  Record_Serializer.string_of_t record

let database_insert_record file_path record_serializer record_data_serializer record_data = 
  let serialized_record = serialize_record record_serializer record_data_serializer record_data in
  Lwt_io.with_file 
    ~flags:([Unix.O_WRONLY; Unix.O_NONBLOCK; Unix.O_APPEND; Unix.O_CREAT]) 
    ~mode: Output 
    file_path 
    (fun channel -> Lwt_io.write_line channel serialized_record)

let create_json_database (type a) file_path json_serializer =
  let open Serializer_converter in
  let record_serializer = convert_json_serializer (module Record_j) in
  let record_data_serializer = convert_json_serializer json_serializer in
  (module struct
    type t = a
    let write_lock = Lwt_mutex.create ()
    let file_path = file_path
    let read_records () = database_read_records file_path record_serializer record_data_serializer
    let insert_record record_data  = database_insert_record file_path record_serializer record_data_serializer record_data
  end : Database with type t = a)

let create_biniou_database (type a) file_path biniou_serializer =
  let open Serializer_converter in
  let record_serializer = convert_biniou_serializer (module Record_b) in
  let record_data_serializer = convert_biniou_serializer biniou_serializer in
  (module struct
    type t = a
    let write_lock = Lwt_mutex.create ()
    let file_path = file_path
    let read_records () = database_read_records file_path record_serializer record_data_serializer
    let insert_record record_data = database_insert_record file_path record_serializer record_data_serializer record_data
  end : Database with type t = a)

let insert_record (type a) (module Database : Database with type t = a) (record_data : a) =
  Lwt_mutex.with_lock Database.write_lock (fun () -> Database.insert_record record_data)

let read_records (type a) (module Database : Database with type t = a) =
  Database.read_records
