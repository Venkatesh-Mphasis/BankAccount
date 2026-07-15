#!/bin/bash
###################################################################
# build.sh - Compile all LOCAL GNUCOBOL programs                 #
# Usage: cd LOCAL && bash build.sh                                #
###################################################################

set -e

COBC="cobc"
COBOL_DIR="COBOL"
BIN_DIR="BIN"
COPY_DIR="../COPYBOOK"

mkdir -p "$BIN_DIR"

PROGRAMS=(
    "BACGEND"
    "BACONL01"
    "BACBAT01"
)

PASS=0
FAIL=0

echo "========================================"
echo " Business Banking - GnuCOBOL Build"
echo "========================================"
echo ""

for PGM in "${PROGRAMS[@]}"; do
    SRC="$COBOL_DIR/${PGM}.cbl"
    OUT="$BIN_DIR/${PGM}"

    if [ ! -f "$SRC" ]; then
        echo "[SKIP] $PGM - source not found"
        continue
    fi

    echo -n "[BUILD] ${PGM}... "
    if $COBC -x -o "$OUT" "$SRC" -I "$COPY_DIR" -std=ibm 2>build_err.tmp; then
        echo "OK"
        PASS=$((PASS + 1))
    else
        echo "FAILED"
        cat build_err.tmp
        FAIL=$((FAIL + 1))
    fi
    rm -f build_err.tmp
done

echo ""
echo "========================================"
echo " Build Summary: $PASS passed, $FAIL failed"
echo "========================================"
exit $FAIL
