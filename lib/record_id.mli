type t
type version = [ `V3 of t * string | `V4 | `V5 of t * string ]
type comparator_witness
val v : version -> t
val create : version -> t
val v3 : t -> string -> t
val v5 : t -> string -> t
val v4_gen : Random.State.t -> unit -> t
val nil : t
val ns_dns : t
val ns_url : t
val ns_oid : t
val ns_X500 : t
val compare : t -> t -> int
val equal : t -> t -> bool
val of_bytes : ?pos:int -> string -> t option
val to_bytes : t -> string
val unsafe_to_bytes : t -> string
val of_string : ?pos:int -> string -> t option
val to_string : ?upper:bool -> t -> string
val pp : Format.formatter -> t -> unit
val pp_string : ?upper:bool -> Format.formatter -> t -> unit
val print : ?upper:bool -> Format.formatter -> t -> unit
val sexp_of_t : t -> Sexplib0.Sexp.t
val comparator : (t, comparator_witness) Base.Comparator.t