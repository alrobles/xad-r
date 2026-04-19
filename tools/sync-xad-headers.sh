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

# 4. Re-apply xad-r local patches against upstream XAD.
#    Keep this list small and document each entry; anything here is drift
#    from the upstream submodule that we intentionally carry forward.
echo "==> Applying xad-r local patches to ${DST}"

# Patch: ADVar::calc_derivatives(info, s) 2-arg overload.
# Upstream (commit 401ee02) at src/xad/src/XAD/Literals.hpp calls
# ar_.calc_derivative(info, s) (singular, non-existent method on AReal).
# Inert in upstream because the 2-arg overload on ADVar is rarely
# instantiated, but downstream LinkingTo consumers that trigger it
# get a hard compile error. Fix: call the plural form.
python3 - "${DST}/Literals.hpp" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
src = p.read_text()
needle = ("    XAD_INLINE void calc_derivatives(DerivInfo<tape_type, Size>& info, tape_type& s) const\n"
          "    {\n"
          "        ar_.calc_derivative(info, s);\n"
          "    }\n")
fixed = ("    XAD_INLINE void calc_derivatives(DerivInfo<tape_type, Size>& info, tape_type& s) const\n"
         "    {\n"
         "        // xad-r LOCAL PATCH (see tools/sync-xad-headers.sh):\n"
         "        // Upstream XAD (commit 401ee02) calls `ar_.calc_derivative(info, s)`\n"
         "        // here (singular, which does not exist on AReal). That typo is inert\n"
         "        // in upstream's own tests because this 2-arg overload on ADVar is\n"
         "        // rarely instantiated, but it would hard-fail any downstream package\n"
         "        // that triggers it. The correct call is the plural form.\n"
         "        ar_.calc_derivatives(info, s);\n"
         "    }\n")
if needle in src:
    p.write_text(src.replace(needle, fixed))
    print(f"    patched {p.name}: ADVar::calc_derivatives (2-arg) typo")
elif fixed in src:
    print(f"    {p.name}: ADVar::calc_derivatives patch already applied")
else:
    sys.stderr.write(f"ERROR: could not locate ADVar::calc_derivatives patch site in {p}\n")
    sys.exit(1)
PY

n_hpp=$(ls "${DST}"/*.hpp 2>/dev/null | wc -l)
echo "    ${n_hpp} headers + Tape.cpp synced into ${DST}"
echo "==> Done."
