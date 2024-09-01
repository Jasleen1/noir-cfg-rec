#!/bin/bash
# set -eux

low_grammar_size=7
high_grammar_size=7
low_log_n=16
high_log_n=16

num_trials=9

BACKEND=~/.bb/bb



touch base_parsing_no_labels.csv
touch base_parsing_no_labels_no_mt.csv

for G in $(seq $low_grammar_size $high_grammar_size) 
do
    G_DIR="$RESULTS_DIR/grammar_size_$G"
    mkdir -p $G_DIR
    for pow in $(seq $low_log_n $high_log_n) 
    do
        N=$((2**$pow))
        low_log_k=$pow
        high_log_k=$pow
        #$pow
        # high_log_k=$pow
        mkdir -p $G_DIR/$N
        for k_pow in $(seq $low_log_k $high_log_k) 
        do
            # K_var
            K=$((2**$k_pow))
            mkdir -p $G_DIR/$N/$K

            TIME_DIR=$G_DIR/$N/$K
            num_rounds=$((2*N/K))



            BASE_CIRC=./base_parsing_circuit_no_labels
            BASE_CIRC_NO_MT=./base_parsing_circuit_no_labels_no_mt
    

            # replace {{N}} and {{K}} in src/main.nr    
            cat main_files/no_labels_base_main.nr | STR_SIZE=$N BATCH_SIZE=$K GRAMMAR_SIZE=$G envsubst > $BASE_CIRC/src/main.nr
            cat main_files/no_labels_base_main_no_mt.nr | STR_SIZE=$N BATCH_SIZE=$K GRAMMAR_SIZE=$G envsubst > $BASE_CIRC_NO_MT/src/main.nr
           
            python3 generate_benchmark_str.py $N $K $G

            nargo execute base_parsing_circuit_no_labels --package base_parsing_circuit_no_labels

            # $BACKEND write_vk -b ./target/base_parsing_circuit_no_labels.json -o ./target/vk   
            mkdir -p proofs

            nargo execute base_parsing_circuit_no_labels_no_mt --package base_parsing_circuit_no_labels_no_mt

            # $BACKEND write_vk -b ./target/base_parsing_circuit_no_labels_no_mt.json -o ./target/vk   
            # mkdir -p proofs
            

            for trial in $(seq 0 $num_trials)
            do
                echo "Running $trial: $G $N $K" 
                # Capture start time in nanoseconds
                echo -n "$K,$N,$G," >> base_parsing_no_labels.csv
                start=$(python3 -c "import time; print(time.time_ns())")
                $BACKEND prove -b ./target/base_parsing_circuit_no_labels.json -w ./target/base_parsing_circuit_no_labels.gz -o ./proofs/proof >> base_parsing_no_labels.csv
                end=$(python3 -c "import time; print(time.time_ns())")
                elapsed=$(echo "scale=9; ($end - $start) / 1000000000" | bc)
                echo "Proving with MT took $elapsed s" 
                echo "$elapsed" >> base_parsing_no_labels.csv
                
                echo -n "$K,$N,$G," >> base_parsing_no_labels_no_mt.csv
                start=$(python3 -c "import time; print(time.time_ns())")
                $BACKEND prove -b ./target/base_parsing_circuit_no_labels_no_mt.json -w ./target/base_parsing_circuit_no_labels_no_mt.gz -o ./proofs/proof >> base_parsing_no_labels_no_mt.csv
                end=$(python3 -c "import time; print(time.time_ns())")
                elapsed=$(echo "scale=9; ($end - $start) / 1000000000" | bc)
                echo "Proving took $elapsed s" 
                echo "$elapsed" >> base_parsing_no_labels_no_mt.csv
            done

        done
    done
done 