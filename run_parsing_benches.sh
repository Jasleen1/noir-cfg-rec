#!/bin/bash
# set -eux



# N_var
N=1024
# K_var
K=16
# G_var
G=9


num_rounds=$((2*N/K))



BASE_CIRC=./base_parsing_circuit
BASE_REC_CIRC=./base_rec_parsing_circuit
REC_CIRC=./rec_parsing_circuit

# replace {{N}} and {{K}} in src/main.nr    
cat main_files/base_main.nr | STR_SIZE=$N BATCH_SIZE=$K GRAMMAR_SIZE=$G envsubst > $BASE_CIRC/src/main.nr
cat main_files/base_rec_main.nr | STR_SIZE=$N BATCH_SIZE=$K GRAMMAR_SIZE=$G envsubst > $BASE_REC_CIRC/src/main.nr
cat main_files/rec_main.nr | STR_SIZE=$N BATCH_SIZE=$K GRAMMAR_SIZE=$G envsubst > $REC_CIRC/src/main.nr

start=$(date +%s%N) 
sh ./setup_vks.sh
end=$(date +%s%N)
elapsed=$(echo "scale=3; ($end - $start) / 1000" | bc)
echo "Setup time"
echo $elapsed 


python3 generate_benchmark_str.py $N $K $G

BACKEND=~/.bb/bb


run_base_round() {
    nargo execute base_parsing_circuit --silence-warnings --package base_parsing_circuit 
    mkdir -p $BASE_CIRC/proofs
    # {
    #     time 
    #     {
    start=$(date +%s%N)   
    $BACKEND prove -b ./target/base_parsing_circuit.json -w ./target/base_parsing_circuit.gz -o $BASE_CIRC/proofs/proof 
    end=$(date +%s%N)
    elapsed=$(echo "scale=3; ($end - $start) / 1000" | bc)
    echo $elapsed >> "time_base_proof.txt"
    #     }; 
    # } 2> "time_base_proof.txt"
    # { time $(($BACKEND prove -b ./target/base_parsing_circuit.json -w ./target/base_parsing_circuit.gz -o $BASE_CIRC/proofs/proof)); } > time_proof.txt
    
    cp ./target/vk_base ./target/vk
    $BACKEND verify -p $BASE_CIRC/proofs/proof -v ./target/vk
    
    FULL_PROOF_AS_FIELDS="$($BACKEND proof_as_fields -p $BASE_CIRC/proofs/proof -k ./target/vk -o -)"
    PUBLIC_INPUTS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[:$((N+2))]")                            
    PROOF_AS_FIELDS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[$((N+2)):]")
    echo "proof=$PROOF_AS_FIELDS" >> ./prover_toml_files/Prover.toml1
    
}

run_first_rec_round() {
    nargo execute base_rec_parsing_circuit --silence-warnings --package base_rec_parsing_circuit 
    mkdir -p $BASE_REC_CIRC/proofs
    # {
    #     time 
    #     {
    start=$(date +%s%N)   
    $BACKEND prove -b ./target/base_rec_parsing_circuit.json -w ./target/base_rec_parsing_circuit.gz -o $BASE_REC_CIRC/proofs/proof
    end=$(date +%s%N)
    elapsed=$(echo "scale=3; ($end - $start) / 1000" | bc)
    echo $elapsed >> "time_base_rec_proof.txt"
    #     }; 
    # } 2> "time_base_rec_proof.txt"
    cp ./target/vk_base_rec ./target/vk
    $BACKEND verify -p $BASE_REC_CIRC/proofs/proof -v ./target/vk
    
    FULL_PROOF_AS_FIELDS="$($BACKEND proof_as_fields -p $BASE_REC_CIRC/proofs/proof -k ./target/vk -o -)"
    PUBLIC_INPUTS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[:$((N+2))]")                            
    PROOF_AS_FIELDS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[$((N+2)):]")
    echo "proof=$PROOF_AS_FIELDS" >> ./prover_toml_files/Prover.toml2
}

setup_next_round() {
    round=$1
    
    if [ "$round" -eq 1 ]; then
        cp ./prover_toml_files/Prover.toml$round $BASE_REC_CIRC/Prover.toml
        cat ./vks/base_vk >> $BASE_REC_CIRC/Prover.toml
        cat ./prover_toml_files/prods$round >> $BASE_REC_CIRC/Prover.toml
    else
        cp ./prover_toml_files/Prover.toml$round $REC_CIRC/Prover.toml
        if [ "$round" -eq 2 ]; then
            cat ./vks/base_rec_vk >> $REC_CIRC/Prover.toml
            cat ./prover_toml_files/prods$round >> $REC_CIRC/Prover.toml
        else 
            cat ./vks/rec_vk >> $REC_CIRC/Prover.toml
            cat ./prover_toml_files/prods$round >> $REC_CIRC/Prover.toml
        fi
    fi

}

run_base_round
echo "Done here 1"
setup_next_round 1
echo "Done here 2"
run_first_rec_round
echo "Done here 3"


LAST_ROUND=$num_rounds
for ((i=2; i<$num_rounds; i++)); do
    setup_next_round $i
    nargo execute rec_parsing_circuit --package rec_parsing_circuit --silence-warnings
    mkdir -p $REC_CIRC/proofs

    start=$(date +%s%N)
    $BACKEND prove -b ./target/rec_parsing_circuit.json -w ./target/rec_parsing_circuit.gz -o $REC_CIRC/proofs/proof
    end=$(date +%s%N)
    elapsed=$(echo "scale=3; ($end - $start) / 1000" | bc)
    echo $elapsed >> "time_rec_proof.txt"
    cp ./target/vk_rec ./target/vk
    $BACKEND verify -p $REC_CIRC/proofs/proof -v ./target/vk
    
    if [ "$i" -lt "$LAST_ROUND" ]; then 
        FULL_PROOF_AS_FIELDS="$($BACKEND proof_as_fields -p $REC_CIRC/proofs/proof -k ./target/vk -o -)"
        PUBLIC_INPUTS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[:$((N+2))]")                            
        PROOF_AS_FIELDS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[$((N+2)):]")
        echo "proof=$PROOF_AS_FIELDS" >> ./prover_toml_files/Prover.toml$((i+1))
    fi
    echo "Done here $i"
done

mkdir -p final_proof
cp $REC_CIRC/proofs/* ./final_proof
cp ./target/vk_rec ./target/vk
$BACKEND verify -p ./final_proof/proof -v ./target/vk