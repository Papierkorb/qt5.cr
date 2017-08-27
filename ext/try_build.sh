#!/bin/bash

# Helper script building the `binding.a` if `qt_binding.cpp` exists.  This is
# useful when using the pre-generated shard version, which ships with that file,
# but not the compiled `binding.a` for compability reasons.

BASE="$(dirname "$(readlink -f "$0")")"
cd "$BASE"

if [ -f "qt_binding.cpp" ]; then
  make
fi
