# Frontend to dune.

.PHONY: default build install uninstall test clean run-example

default: build

build:
	dune build

test:
	dune test

run-example:
	dune exec examples/main.exe

utop:
	dune utop

install:
	dune install

uninstall:
	dune uninstall

clean:
	dune clean

doc:
	dune build @doc

update-doc:
	rsync -r _build/default/_doc/_html/ docs/