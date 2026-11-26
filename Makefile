.PHONY: bindings build test run fmt lint docs

bindings:
	./scripts/generate-macos-bindings.sh

build: bindings
	cargo build --workspace
	swift build --package-path shells/macos

test: bindings
	cargo test --workspace
	swift test --package-path shells/macos

run: bindings
	swift run --package-path shells/macos lupka

fmt:
	cargo fmt --all

lint:
	cargo fmt --all --check
	cargo clippy --workspace --all-targets -- -D warnings

docs:
	python3 scripts/check-docs.py
	ruby scripts/check-issue-forms.rb
