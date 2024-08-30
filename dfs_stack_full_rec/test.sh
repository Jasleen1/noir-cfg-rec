#!/bin/bash
set -eux
nargo execute dfs_stack_full_rec --package dfs_stack_full_rec

BACKEND=../bbnew

$BACKEND write_vk -b ../target/dfs_stack_full_rec.json -o ../target/vk   
mkdir -p proofs
start=$(python3 -c "import time; print(time.time_ns())")
$BACKEND prove -b ../target/dfs_stack_full_rec.json -w ../target/dfs_stack_full_rec.gz -o ./proofs/proof
end=$(python3 -c "import time; print(time.time_ns())")
elapsed=$(echo "scale=9; ($end - $start) / 1000000000" | bc)
echo "Proving took $elapsed s" 
# mkdir -p target
# cp ../target/vk ./target/vk
# $BACKEND verify -p ./proofs/proof -v ./target/vk

# FULL_PROOF_AS_FIELDS="$($BACKEND proof_as_fields -p ./proofs/proof -k ./target/vk -o -)"
# PUBLIC_INPUTS=$(echo $FULL_PROOF_AS_FIELDS | jq -r '.[:18]')                            
# PROOF_AS_FIELDS=$(echo $FULL_PROOF_AS_FIELDS | jq -r '.[18:]')

# $BACKEND vk_as_fields -k ./target/vk -o ./target/vk_as_fields
# VK_HASH=$(jq -r '.[0]' ./target/vk_as_fields)
# VK_AS_FIELDS=$(jq -r '.[1:]' ./target/vk_as_fields)

# echo "proof=$PROOF_AS_FIELDS" >> ../recursive_parsing_circuit/Prover.toml
# echo "verification_key=$VK_AS_FIELDS" >> ../recursive_parsing_circuit/Prover.toml
# echo "key_hash=\"$VK_HASH\"" >> ../recursive_parsing_circuit/Prover.toml
# cat ../recursive_parsing_circuit/prods >> ../recursive_parsing_circuit/Prover.toml