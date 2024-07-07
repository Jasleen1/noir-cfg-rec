#!/bin/bash

nargo execute base_rec_parsing_circuit --package base_rec_parsing_circuit

~/.bb/bb write_vk -b ../target/base_rec_parsing_circuit.json -o ../target/vk   
mkdir -p proofs
~/.bb/bb prove -b ../target/base_rec_parsing_circuit.json -w ../target/base_rec_parsing_circuit -o ./proofs/proof
mkdir -p target
cp ../target/vk ./target/vk
~/.bb/bb verify -p ./proofs/proof -v ./target/vk
