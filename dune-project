(lang dune 3.0)

(name sanddb)

(version 0.3.0)

(generate_opam_files true)

(source
 (github StrykerKKD/SandDB))

(authors "Robert Toth")

(maintainers "Robert Toth")

(license MIT)

(documentation https://strykerkkd.github.io/SandDB/)

(package
 (name sanddb)
 (synopsis "A simple immutable database for the masses")
 (description "SandDB is a simple easy async immutable database")
 (depends (ocaml (>= 4.6.0)) dune atdgen base lwt uuidm alcotest))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
