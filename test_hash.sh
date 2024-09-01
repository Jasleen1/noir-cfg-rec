#!/bin/bash


BACKEND=~/.bb/bb

start=$(date +%s%N) 
$BACKEND prove -b ./target/hash_checks.json -w ./target/hash_checks -o hash_proof >> test.txt
end=$(date +%s%N)
elapsed=$(echo "scale=3; ($end - $start) / 1000" | bc)
echo $elapsed 