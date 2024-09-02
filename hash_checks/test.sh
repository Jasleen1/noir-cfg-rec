#!/bin/bash
BACKEND=../bbnew

nargo execute hash_checks --package hash_checks

$BACKEND write_vk -b ../target/hash_checks.json -o ../target/vk  
mkdir -p target 

$BACKEND write_pk -b ../target/hash_checks.json -o ../target/pk  
cp ../target/pk ./target/pk
cp ../target/vk ./target/vk
start=$(python3 -c "import time; print(time.time_ns())") 
mkdir -p proofs
start=$(python3 -c "import time; print(time.time_ns())")
$BACKEND prove -b ../target/hash_checks.json -w ../target/hash_checks.gz -p ./target/pk -o ./proofs/proof

end=$(python3 -c "import time; print(time.time_ns())")
elapsed=$(echo "scale=3; ($end - $start) / 1000000000" | bc)
echo $elapsed 
$BACKEND verify -p proofs/proof -v ./target/vk
