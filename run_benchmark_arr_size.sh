#!/bin/bash

### Copied and edited from https://github.com/amiller/noir-microbenchmarks/blob/master/sortedlists/run_benchmark.sh

# Clear build folder
rm -r test_arr_circuits
mkdir -p test_arr_circuits

LOW_ARR_SIZE=0
HIGH_ARR_SIZE=10

LOW_LOOKUP_SIZE=0
HIGH_LOOKUP_SIZE=0

# Loop over sizes
for i in $(seq ${LOW_ARR_SIZE} ${HIGH_ARR_SIZE})
do  
    mkdir -p test_arr_circuits/2^${i}
    for j in $(seq ${LOW_LOOKUP_SIZE} ${HIGH_LOOKUP_SIZE})
    do
        # Generate a new build/2^{i} folder
        nargo new test_arr_circuits/2^${i}/2^${j}
        pushd test_arr_circuits/2^${i}/2^${j}

        # replace {{N}} in src/main.nr    
        cat ./../../../src/main1.nr | STR_SIZE=$((2**$i)) LOOKUP_SIZE=$((2**$j)) envsubst > ./src/main.nr
        
        
        # Generate the Prover.toml with an array
        # python3 ./../../../generate_arr_benchmark_inp.py $(($i)) $(($j)) | dd status=none of=./Prover.toml

        # echo >> ./Prover.toml "x = ["    
        # for j in $(seq 1 $((2**i)))
        # do
        # cat >> ./Prover.toml <<EOF
        # ${j},
        # EOF
        # done
        # echo >> ./Prover.toml "]"
        # pwd
        # Run the experiment
        nargo compile
        nargo info | tee ../info_${i}-${j}.txt
        # nargo info

        # { time nargo prove; } 2> ../time_proof_${i}-${j}.txt

        popd
    done
    # for j in $(seq $LOW_LOOKUP_SIZE ${HIGH_LOOKUP_SIZE})
    # do
    #     for k in $(seq 0 9)
    #     do
    #         pushd test_arr_circuits/2^${i}/2^${j}
    #         { time nargo prove; } 2>> ../time_proof_${i}-${j}.txt

    #         popd
    #     done
    # done 
    # pushd test_arr_circuits/2^${i}/
    # rm -rf 2^*
    # popd
done

# Collect results
# for i in $(seq ${LOW_ARR_SIZE} ${HIGH_ARR_SIZE})
# do
#     for j in $(seq ${LOW_LOOKUP_SIZE} ${HIGH_LOOKUP_SIZE})
#     do
#         python3 avg_time_output.py test_circuits/2\^${i}/time_proof_${i}-${j}.txt ${i} ${j}
#     done
# done

# for i in $(seq 2 2)
# do
#     for j in $(seq 1 1)
#     do
#         python3 avg_time_output.py test_circuits/2\^${i}/time_proof_${i}-${j}.txt ${i} ${j}
#     done
# done
