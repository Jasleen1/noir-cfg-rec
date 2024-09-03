#!/bin/bash
# set -eux

low_grammar_size=7
high_grammar_size=12
low_log_n=5
high_log_n=9

num_trials=0

basic_prods_arr_str="   
    (S, Ac, Ac),  //0 
    (Ac, Ac, Ac), //1
    (Ac, A, C),   //2
    (A, a, 0),   //3
    (C, c, 0),   //4
    (S, A, C),  //5
    (S, A, C),  //5
    (S, A, C),  //5"


BACKEND=./bbnew
#~/.bb/bb

RESULTS_DIR=results
mkdir -p $RESULT_DIR

for G in $(seq $low_grammar_size $high_grammar_size) 
do
    G_DIR="$RESULTS_DIR/grammar_size_$G"
    mkdir -p $G_DIR

    # sized_grammar_prods="$basic_prods_arr_str"
    # grammar_copies=$(($G - 3))
    # for (( i=0; i<$grammar_copies; i++ )); do
    #     sized_grammar_prods+=$sized_grammar_prods
    # done
    # sized_grammar_prods+="
    # ]"
    # left_par="["
    # sized_grammar_prods="$left_par$sized_grammar_prods"
    
    

    for pow in $(seq $low_log_n $high_log_n) 
    do
        N=$((2**$pow))
        # low_log_k=5
        low_log_k=$(($pow + 1))
        high_log_k=$(($pow + 1))
        # high_log_k=3
        #$pow
        # high_log_k=$pow
        mkdir -p $G_DIR/$N
        for k_pow in $(seq $low_log_k $high_log_k) 
        do
            # K_var
            K=$((2**$k_pow))
            mkdir -p $G_DIR/$N/$K

            TIME_DIR=$G_DIR/$N/$K
            VK_DIR="grammar_size_$G/$N/$K"
            num_rounds=$((2*N/K - 1))



            BASE_CIRC=./dfs_stack_base
            BASE_REC_CIRC=./dfs_stack_rec_1
            REC_CIRC=./dfs_stack_full_rec
            # replace {{N}} and {{K}} in src/main.nr    
            cat main_files/dfs_stack_base_main_HC.nr | STR_SIZE=$N BATCH_SIZE=$K GRAMMAR_SIZE=$G LOG_STR_SIZE=$pow envsubst > $BASE_CIRC/src/main.nr
            cat main_files/dfs_stack_rec_1_main.nr | STR_SIZE=$N BATCH_SIZE=$K GRAMMAR_SIZE=$G envsubst > $BASE_REC_CIRC/src/main.nr
            cat main_files/dfs_stack_full_rec_main.nr | STR_SIZE=$N BATCH_SIZE=$K GRAMMAR_SIZE=$G envsubst > $REC_CIRC/src/main.nr

            
            rm -rf prover_toml_files
            rm -rf verifier_toml_files
            mkdir prover_toml_files
            mkdir verifier_toml_files
            python3 generate_dfs_rec_benchmark_str.py $N $K $G
            for trial in $(seq 0 $num_trials)
            do
                echo "Running $trial: $G $N $K" 
                # Capture start time in nanoseconds
                start=$(python3 -c "import time; print(time.time_ns())")
                # sh ./setup_vks_dfs_rec.sh "$BACKEND" 
                cp ./vks/$VK_DIR/* ./vks/
                cp ./vks/$VK_DIR/* ./target/
                echo "Setup complete"
                # # Capture end time in nanoseconds
                # end=$(python3 -c "import time; print(time.time_ns())")

                # elapsed=$(echo "scale=3; ($end - $start) / 1000000000" | bc)
                # echo $elapsed >> "$TIME_DIR/setup_time.txt"


                run_base_round() {
                    start=$(date +%s%N)
                    nargo execute dfs_stack_base --silence-warnings --package dfs_stack_base
                    end=$(date +%s%N)
                    elapsed=$(echo "scale=9; ($end - $start) / 1000000000" | bc)
                    echo $elapsed >> "$TIME_DIR/time_base_exec.txt"
                    mkdir -p $BASE_CIRC/proofs
                    echo "Executed base circuit..."
                    # {
                    #     time 
                    #     {
                    # start=$(date +%s%N)  
                    start=$(python3 -c "import time; print(time.time_ns())") 
                    gtime -v $BACKEND prove -b ./target/dfs_stack_base.json -w ./target/dfs_stack_base.gz -o $BASE_CIRC/proofs/proof >> "$TIME_DIR/time_base_proof.txt"
                    # end=$(date +%s%N)
                    end=$(python3 -c "import time; print(time.time_ns())")
                    elapsed=$(echo "scale=3; ($end - $start) / 1000000000" | bc)
                    echo "total,$elapsed" >> "$TIME_DIR/time_base_proof.txt"
                    #     }; 
                    # } 2> "time_base_proof.txt"
                    # { time $(($BACKEND prove -b ./target/dfs_stack_base.json -w ./target/dfs_stack_base.gz -o $BASE_CIRC/proofs/proof)); } > time_proof.txt
                    
                    cp ./target/vk_base ./target/vk
                    mkdir -p final_proof
                    cp $BASE_CIRC/proofs/* ./final_proof
                    # $BACKEND verify -p $BASE_CIRC/proofs/proof -v ./target/vk
                    if [ "$trial" -eq 0 ]; then 
                        FULL_PROOF_AS_FIELDS="$($BACKEND proof_as_fields -p $BASE_CIRC/proofs/proof -k ./target/vk -o -)"
                        PUBLIC_INPUTS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[:$((N+4))]")                            
                        PROOF_AS_FIELDS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[$((N+4)):]")
                        echo "proof=$PROOF_AS_FIELDS" >> ./prover_toml_files/Prover.toml1
                    fi

                    echo "Proven base circuit..."
                    
                }

                run_first_rec_round() {

                    # start=$(date +%s%N)
                    start=$(python3 -c "import time; print(time.time_ns())")
                    nargo execute dfs_stack_rec_1 --silence-warnings --package dfs_stack_rec_1 
                    # end=$(date +%s%N)
                    end=$(python3 -c "import time; print(time.time_ns())")
                    elapsed=$(echo "scale=9; ($end - $start) / 1000000000" | bc)
                    echo $elapsed >> "$TIME_DIR/time_base_rec_exec.txt"
                    echo "Executed round 1 circuit..."
                    mkdir -p $BASE_REC_CIRC/proofs
                    
                    # start=$(date +%s%N)  
                    start=$(python3 -c "import time; print(time.time_ns())") 
                    $BACKEND prove -b ./target/dfs_stack_rec_1.json -w ./target/dfs_stack_rec_1.gz -o $BASE_REC_CIRC/proofs/proof >> "$TIME_DIR/time_base_rec_proof.txt"
                    # end=$(date +%s%N)
                    end=$(python3 -c "import time; print(time.time_ns())")
                    elapsed=$(echo "scale=3; ($end - $start) / 1000000000" | bc) 
                    echo "total,$elapsed" >> "$TIME_DIR/time_base_rec_proof.txt"

                    echo "Proven round 1 circuit..."

                    cp ./target/vk_base_rec ./target/vk
                    mkdir -p final_proof
                    cp $BASE_REC_CIRC/proofs/* ./final_proof
                    # $BACKEND verify -p $BASE_REC_CIRC/proofs/proof -v ./target/vk
                    if [ "$trial" -eq 0 ]; then 
                        FULL_PROOF_AS_FIELDS="$($BACKEND proof_as_fields -p $BASE_REC_CIRC/proofs/proof -k ./target/vk -o -)"
                        PUBLIC_INPUTS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[:$((N+4))]")                            
                        PROOF_AS_FIELDS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[$((N+4)):]")
                        echo "proof=$PROOF_AS_FIELDS" >> ./prover_toml_files/Prover.toml2
                    fi
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

                

                run_rec_rounds() {
                    LAST_ROUND=$num_rounds
                    for i in $(seq 2 $num_rounds); do
                        setup_next_round $i
                        # start=$(date +%s%N)
                        start=$(python3 -c "import time; print(time.time_ns())")
                        nargo execute dfs_stack_full_rec --package dfs_stack_full_rec --silence-warnings
                        # end=$(date +%s%N)
                        end=$(python3 -c "import time; print(time.time_ns())")
                        elapsed=$(echo "scale=9; ($end - $start) / 1000000000" | bc)
                        echo $elapsed >> "$TIME_DIR/time_rec_exec.txt"
                        echo "Executed round $i circuit..."
                        mkdir -p $REC_CIRC/proofs

                        # start=$(date +%s%N)
                        start=$(python3 -c "import time; print(time.time_ns())")
                        $BACKEND prove -b ./target/dfs_stack_full_rec.json -w ./target/dfs_stack_full_rec.gz -o $REC_CIRC/proofs/proof >> "$TIME_DIR/time_rec_proof.txt"
                        # end=$(date +%s%N)
                        end=$(python3 -c "import time; print(time.time_ns())")
                        elapsed=$(echo "scale=3; ($end - $start) / 1000000000" | bc)
                        echo "total,$elapsed" >> "$TIME_DIR/time_rec_proof.txt"
                        echo "Proven round $i circuit..."

                        cp ./target/vk_rec ./target/vk
                        # $BACKEND verify -p $REC_CIRC/proofs/proof -v ./target/vk
                        
                        if [ "$i" -lt "$LAST_ROUND" ]; then 
                            if [ "$trial" -eq 0 ]; then 
                                FULL_PROOF_AS_FIELDS="$($BACKEND proof_as_fields -p $REC_CIRC/proofs/proof -k ./target/vk -o -)"
                                PUBLIC_INPUTS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[:$((N+4))]")                            
                                PROOF_AS_FIELDS=$(echo $FULL_PROOF_AS_FIELDS | jq -r ".[$((N+4)):]")
                                echo "proof=$PROOF_AS_FIELDS" >> ./prover_toml_files/Prover.toml$((i+1))
                            fi
                        fi
                        echo "Done here $i"
                    done

                    mkdir -p final_proof
                    cp $REC_CIRC/proofs/* ./final_proof
                    cp ./target/vk_rec ./target/vk
                    
                }

                run_base_round
                echo "Done here 0"
                if [ "$num_rounds" -gt 1 ]; then
                    setup_next_round 1
                    run_first_rec_round
                    echo "Done here 1"
                fi
                if [ "$num_rounds" -gt 2 ]; then
                    run_rec_rounds
                fi
                end=$(python3 -c "import time; print(time.time_ns())")
                $BACKEND verify -p ./final_proof/proof -v ./target/vk
                end=$(python3 -c "import time; print(time.time_ns())")
                elapsed=$(echo "scale=3; ($end - $start) / 1000000000" | bc)
                echo $elapsed >> "$TIME_DIR/time_verification.txt"
                echo $elapsed

                # Use this for Mac
                file_size=$(stat -f%z "./final_proof/proof")
                # Use this for Ubuntu
                # file_size=$(stat -c %s "./final_proof/proof")
                echo $file_size >> "$TIME_DIR/proof_size.txt"
            done

        done
    done
done 