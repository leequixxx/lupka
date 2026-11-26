#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

generated_dir="$repo_root/shells/macos/Sources/LupkaCore/Generated"
ffi_dir="$repo_root/shells/macos/Sources/LupkaCoreFFI"
mkdir -p "$generated_dir" "$ffi_dir"

cargo build -p lupka-core
cargo run -p uniffi-bindgen -- generate \
    --library "$repo_root/target/debug/liblupka_core.dylib" \
    --language swift \
    --out-dir "$generated_dir"

mv "$generated_dir/LupkaCoreFFI.h" "$ffi_dir/LupkaCoreFFI.h"
mv "$generated_dir/LupkaCoreFFI.modulemap" "$ffi_dir/module.modulemap"
