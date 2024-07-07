#!/bin/bash

nargo execute rec_parsing_circuit

~/.bb/bb write_vk -b ./target/rec_parsing_circuit.json -o ./target/vk   

~/.bb/bb prove -b ./target/rec_parsing_circuit.json -w ./target/rec_parsing_circuit.gz

~/.bb/bb verify -p proofs/proof -v ./target/vk
