#!/usr/bin/env bash
# tools/sync-xad-headers.sh
#
# Regenerates inst/include/XAD/ from the upstream XAD submodule
# (src/xad/src/XAD/*.hpp) and the pre-generated config headers
# (src/include/XAD/*.hpp). Run whenever the XAD submodule is bumped.
#
# The content of inst/include/XAD/ is what downstream packages that
# use `LinkingTo: xadr` will see; it is the canonical set of headers.

set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
SRC_SUBMODULE="${HERE}/src/xad/src/XAD"
SRC_PREGEN="${HERE}/src/include/XAD"
DST="${HERE}/inst/include/XAD"

if [ ! -d "${SRC_SUBMODULE}" ] || [ -z "$(ls -A "${SRC_SUBMODULE}" 2>/dev/null)" ]; then
  echo "ERROR: ${SRC_SUBMODULE} is empty. Run 'git submodule update --init --recursive' first." >&2
  exit 1
fi

echo "==> Syncing XAD headers into ${DST}"
mkdir -p "${DST}"

# 1. Copy all .hpp files from the upstream submodule.
#    This excludes .hpp.in template files (which get replaced by the
#    pre-generated versions below) and the JIT .cpp files (JIT is disabled).
find "${SRC_SUBMODULE}" -maxdepth 1 -name "*.hpp" -exec cp -f {} "${DST}/" \;

# 2. Overlay the pre-generated config headers (Config.hpp, Version.hpp,
#    GenerateMode.hpp, Instantiations.hpp). These are what xad-r builds
#    itself against and are the correct choice for downstream LinkingTo.
for f in Config.hpp Version.hpp GenerateMode.hpp Instantiations.hpp; do
  if [ -f "${SRC_PREGEN}/${f}" ]; then
    cp -f "${SRC_PREGEN}/${f}" "${DST}/${f}"
  fi
done

# 3. Ship Tape.cpp so downstream LinkingTo consumers can compile their own
#    copy. (R's LinkingTo mechanism ships headers only; the one required
#    XAD translation unit is Tape.cpp, which downstream Makevars can add
#    to SOURCES.)
cp -f "${HERE}/src/xad/src/Tape.cpp" "${DST}/Tape.cpp"

n_hpp=$(ls "${DST}"/*.hpp 2>/dev/null | wc -l)
echo "    ${n_hpp} headers + Tape.cpp synced into ${DST}"
echo "==> Done."
