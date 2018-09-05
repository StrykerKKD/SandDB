(** [Sanddb.Record_Id] is the basic record id type, which idetifies a record in the database.*)
module T = struct
  include Uuidm
  let sexp_of_t t =
    Base.Sexp.Atom (Uuidm.to_string t)
end
include T
include Base.Comparator.Make(T)