#!/bin/bash
# set -eux

low_grammar_size=7
high_grammar_size=12
# low_log_n=11
# high_log_n=12
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
                echo "Computing VKs for: $G $N $K" 
                # Capture start time in nanoseconds
                start=$(python3 -c "import time; print(time.time_ns())")
                sh ./setup_vks_dfs_prep.sh "$BACKEND" "$VK_DIR"
                echo "Setup complete"
                # Capture end time in nanoseconds
                end=$(python3 -c "import time; print(time.time_ns())")

                elapsed=$(echo "scale=3; ($end - $start) / 1000000000" | bc)
                echo $elapsed >> "$TIME_DIR/setup_time.txt"
            done

        done
    done
done 