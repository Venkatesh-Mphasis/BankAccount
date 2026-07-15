#!/bin/bash
###################################################################
# run.sh - Execute LOCAL demo pipeline                            #
# Usage: cd LOCAL && bash run.sh                                  #
###################################################################

set -e

cd "$(dirname "$0")"

mkdir -p DATA OUTPUT

# Clean previous data files
rm -f DATA/BACAPP DATA/BACSIG DATA/BACCUST DATA/BACACC DATA/BACDOC
rm -f DATA/BACAPP-UPDATED
rm -f OUTPUT/*.txt OUTPUT/*.dat

echo "========================================"
echo " Business Banking - Local Demo Run"
echo "========================================"

# Sample online requests: 01=new application, 02=inquiry
cat > DATA/BACREQ.dat <<'EOF'
01
02APP0000001
EOF

echo ""
echo "[1/3] Generating sample master files..."
./BIN/BACGEND

echo ""
echo "[2/3] Running online account-creation portal..."
./BIN/BACONL01

echo ""
echo "[3/3] Running batch account-opening..."
./BIN/BACBAT01

echo ""
echo "========================================"
echo " DEMO COMPLETE"
echo "========================================"
echo ""
echo "Outputs:"
ls -1 OUTPUT/
echo ""
echo "--- ACCOUNT OPENING REPORT ---"
cat OUTPUT/ACCOUNT_OPEN_RPT.txt
echo "--- ONLINE RESPONSE ---"
cat OUTPUT/BACRESP.dat
