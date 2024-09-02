import sys 
import os


def parse_floats_from_file(file_path):
    floats = []
    try:
        with open(file_path, 'r') as file:
            for line in file:
                try:
                    floats.append(float(line.strip()))
                except ValueError:
                    print(f"Skipping invalid float: {line.strip()}")
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except Exception as e:
        print(f"An error occurred: {e}")
    return floats

def parse_floats_from_proof_time_file(file_path):
    floats = []
    try:
        with open(file_path, 'r') as file:
            for line in file:
                try:
                    split_line = line.split(',')
                    floats.append(float(split_line[1]))
                except ValueError:
                    print(f"Skipping invalid float: {line.strip()}")
    except FileNotFoundError:
        print(f"File not found: {file_path}")
    except Exception as e:
        print(f"An error occurred: {e}")
    return floats

def compile_results_rec_for_params(g, n, k, trials=1):
    folder="./results/grammar_size_" + str(g) + "/" + str(n) + "/" + str(k)
    setup_time_file=folder+"/setup_time.txt"
    base_exec_time_file=folder+"/time_base_exec.txt"
    base_proof_time_file=folder+"/time_base_proof.txt"
    
    base_rec_exec_time_file=folder+"/time_base_rec_exec.txt"
    base_rec_proof_time_file=folder+"/time_base_rec_proof.txt"

    rec_exec_time_file=folder+"/time_rec_exec.txt"
    rec_proof_time_file=folder+"/time_rec_proof.txt"

    verification_time_file=folder+"/time_verification.txt"

    proof_size_file=folder+"/proof_size.txt"

    setup_time=sum(parse_floats_from_file(setup_time_file))/trials

    total_exec_time=(sum(parse_floats_from_file(base_exec_time_file)) +\
                      sum(parse_floats_from_file(base_rec_exec_time_file)) +\
                        sum(parse_floats_from_file(rec_exec_time_file)))/trials
    total_proof_time=(sum(parse_floats_from_proof_time_file(base_proof_time_file)) +\
                       sum(parse_floats_from_proof_time_file(base_rec_proof_time_file)) +\
                        sum(parse_floats_from_proof_time_file(rec_proof_time_file)))/trials

    verification_time=sum(parse_floats_from_file(verification_time_file))/trials

    proof_size=sum(parse_floats_from_file(proof_size_file))/(1000*trials)

    out_str =  str(g) + "," + str(n) + "," + str(k) + "," \
        + str(setup_time) + "," + str(total_exec_time) + "," \
            + str(total_proof_time) + "," + str(verification_time) + "," \
            + str(proof_size) 
    return out_str


def compile_results_for_params(g, n, k, trials=1):
    folder="./results/grammar_size_" + str(g) + "/" + str(n) + "/" + str(k)
    setup_time_file=folder+"/setup_time.txt"
    base_exec_time_file=folder+"/time_base_exec.txt"
    base_proof_time_file=folder+"/time_base_proof.txt"
    
    # base_rec_exec_time_file=folder+"/time_base_rec_exec.txt"
    # base_rec_proof_time_file=folder+"/time_base_rec_proof.txt"

    # rec_exec_time_file=folder+"/time_rec_exec.txt"
    # rec_proof_time_file=folder+"/time_rec_proof.txt"

    verification_time_file=folder+"/time_verification.txt"

    proof_size_file=folder+"/proof_size.txt"

    # setup_time=sum(parse_floats_from_file(setup_time_file))/trials

    total_exec_time=sum(parse_floats_from_file(base_exec_time_file))/trials
    total_proof_time=sum(parse_floats_from_proof_time_file(base_proof_time_file))/(1000*trials)

    verification_time=sum(parse_floats_from_file(verification_time_file))/trials

    proof_size=sum(parse_floats_from_file(proof_size_file))/(1000*trials)

    out_str =  str(g) + "," + str(n) + "," + str(k) + "," \
         "," + str(total_exec_time) + "," \
            + str(total_proof_time) + "," + str(verification_time) + "," \
            + str(proof_size) 
    return out_str

def print_result_labels():
    return "Log(Grammar Size),String Size,Proof Batch Size, Setup Time, Total Execution Time, Total Proving Time (s),Verification Time,Proof Size (KB)"

print(print_result_labels())

for g in range(7, 11):
    for n in range(5, 11):
        print(compile_results_for_params(g, 2**n, 2**(n+1)))      

# print(compile_results_for_params(9, 1024, 8))
# print(compile_results_for_params(9, 1024, 16))
# print(compile_results_for_params(9, 1024, 32))
# print(compile_results_for_params(9, 1024, 64))