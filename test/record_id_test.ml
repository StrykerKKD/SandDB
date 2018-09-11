let tests_sexp_of_t () =
    let test_id = Sanddb__.Record_id.nil in
    let expected_value = Sanddb__.Record_id.to_string test_id in
    let actual_value = Sanddb__.Record_id.sexp_of_t test_id |> Base.Sexp.to_string in
    Alcotest.(check string) "sexp_of_t should return correct Sexp" expected_value actual_value

let tests = [
    "sexp_of_t", `Quick, tests_sexp_of_t;
]