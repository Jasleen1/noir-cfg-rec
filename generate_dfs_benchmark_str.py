from math import floor
import sys 
import os

sys.setrecursionlimit(100000)

N=32
K=16


mt_hashes={}
mt_hashes[3]="0x0302bafdc1322e8c7c13a308ae1b1805e4f9cdb4fb007cca2e3b729797e17f31"
mt_hashes[4]="0x2de8decd8397dea6e321d348f3b53f18916c1b3deac0925598ec195526671dd0"
mt_hashes[5]="0x2997320cc5ef68f0892c03131741a8da7635b1cc371a1018c690daf9d6876a97"
mt_hashes[6]="0x138d83da3de1d21eba3ac684515d42668c9b02a328799cb56bb46a5241fc72ef"
mt_hashes[7]="0x1409f6c28a1bd7a02bd13ba062acab4c3255a191b5b083ecf57b03473afa9ead"
mt_hashes[8]="0x28fce67a63a8fe523b1918a59bafce40624033d077c8da27230e5137b6a683d7"
mt_hashes[9]="0x2bed8df99ff4ab1fcf78ba6adf7b5cf88c74976be2b48298156f6ba8fe6616f6"
mt_hashes[10]="0x16cfc9452bb102ea2f18649740a24ea70541f61af593fe5c25bec354e946f9fd"
mt_hashes[11]="0x213aa593e1e4ea8d4af21bd23e4241116b51613dc3cd8cea894127b6d633f388"
mt_hashes[12]="0x0d726001626c54bf66492c95840fa487ee814241de139792e931e91eff643b3e"
mt_hashes[13]="0x059f77fb4b306412d84bcf61bc103bc9f88a702f88cfa33292579eb988c36fed"
mt_hashes[14]="0x042591716ac5807e12dc976452639cc9b83df52df21e782f820b1b87d2a1ee71"
mt_hashes[15]="0x1d5d627cb1f0da65b3d860648c6464ba7da48a710b354fd0001f04ec843d30a0"
mt_hashes[16]="0x081f0b4f7ed2056c218db780039ca0d62c54e5dadcfdc0beab823d6db1d417f2"
mt_hashes[17]="0x24d4aa9f5a5aaabd947b2bd2633092a3092518e72d0e8d3159bfb674caa90c6c"
mt_hashes[18]="0x19ac6f6b56a794b6eb5fbe407dbb911792d151a4dfebbd9423a6b53e027be9b5"
mt_hashes[19]="0x2bdc60e86599419a3e24f06df65445d3a016af84ec3c11770e943df37051de8e"
mt_hashes[20]="0x2fdf536222da76b4eb9919e950049190bf2919b8560a911b761b3ec405de39aa"

# Hashed with "leaf=1"
merkle_prods={}
merkle_prods[3]="[[mem_proofs_prod]]\nindex=3\n hashpath=[0x02, 0x03, 0x04]\n"
merkle_prods[4]="[[mem_proofs_prod]]\nindex=3\nhashpath=[0x02, 0x03, 0x04, 0x05]\n"
merkle_prods[5]="[[mem_proofs_prod]]\nindex=3\nhashpath=[0x02, 0x03, 0x04, 0x05, 0x06]\n"
merkle_prods[6]="[[mem_proofs_prod]]\nindex=3\nhashpath=[0x02, 0x03, 0x04, 0x05, 0x06, 0x07]\n"
merkle_prods[7]="[[mem_proofs_prod]]\nindex=3\nhashpath=[0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08]\n"
merkle_prods[8]="[[mem_proofs_prod]]\nindex=3\nhashpath=[0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09]\n"
merkle_prods[9]="[[mem_proofs_prod]]\nindex=3\nhashpath=[0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a]\n"
merkle_prods[10]="[[mem_proofs_prod]]\nindex=3\nhashpath=[0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b]\n"
merkle_prods[20]="[[mem_proofs_prod]]\nindex=3\nhashpath=[0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15]\n"




##### ******************* DFS functions ************************** ########

S = 1
Ac = 2
A = 3
C = 4
a = 5
c = 6

terminals = [a, c]

g_1_rules = [
    (S, Ac, Ac),  #0 
    (Ac, Ac, Ac), #1
    (Ac, A, C),   #2
    (A, a, 0),   #3
    (C, c, 0),   #4
    (S, A, C),  #5
]; 

class Node:
    def __init__(self) -> None:
        self.label = 0
        self.childL = None
        self.childR = None
        self.bfsId = 0
        self.ruleId = -1
    
    # def __eq__(self, other: object) -> bool:
    #     return ((self.next == other.next) and (self.val == other.val))
        
    def new_node(label):
        new_node = Node()
        new_node.label = label
        return new_node
    
    def print_nodes(arr):
        if arr == []:
            return
        curr = arr.pop(0)
        print("label = " + str(curr.label) \
              + ", bfsId = " + str(curr.bfsId) \
              + ", ruleId = " + str(curr.ruleId))
        
        if curr.childL != None:
            print("Child L: " + str(curr.childL.bfsId))
            if curr.childR != None:
                print("Child R: " + str(curr.childR.bfsId))
            else:
                print("Child R: x")
        print("***************")

        if curr.childL != None:
            # self.childL.print()
            arr.append(curr.childL)
            if curr.childR != None:
                # self.childR.print()
                arr.append(curr.childR)
        Node.print_nodes(arr)
        

        



def build_parse_tree(string_len):
    root_node = Node.new_node(S)
    build_parse_tree_rec(string_len, root_node)
    return root_node

def build_parse_tree_rec(string_len, root_node):
    # Make sure the string is a multiple of 2
    if string_len % 2 == 1:
        return
    
    if string_len == 0:
        return  

    if string_len == 2:
        left_node = Node.new_node(A)
        left_node.childL = Node.new_node(a)
        right_node = Node.new_node(C) 
        right_node.childL = Node.new_node(c)
        root_node.childL = left_node
        root_node.childR = right_node
    else:
        left_node = Node.new_node(Ac)
        build_parse_tree_rec(2, left_node)
        right_node = Node.new_node(Ac)
        build_parse_tree_rec(string_len - 2, right_node)
        root_node.childL = left_node
        root_node.childR = right_node

def label_fn(curr, count):
    curr.bfsId = count
    rule = [curr.label, 0, 0]
    if curr.childL != None:
        rule[1] = curr.childL.label
        if curr.childR != None:
            rule[2] = curr.childR.label
        curr.ruleId = g_1_rules.index(tuple(rule))

def append_wits(node, extras_tuple):
    (label_arr, prod_arr, rule_arr) = extras_tuple
    label_arr.append(node.label)
    if node.ruleId != -1:
        rule_arr.append(node.ruleId)
        left_child = node.childL.bfsId
        right_child = 0
        if node.childR != None:
            right_child = node.childR.bfsId
        prod_arr.append((node.bfsId, left_child, right_child))
    
def bfs_parse_tree(root_node, thing_to_do_at_node, extra_args=None):
    stack = [root_node]
    count = 0
    while stack != []:
        curr = stack.pop(0)
        if curr != None:
            if extra_args != None:
                thing_to_do_at_node(curr, extra_args)
            else:
                thing_to_do_at_node(curr, count)
            stack.append(curr.childL)
            stack.append(curr.childR)
            count = count + 1
    return root_node
    
def dfs_parse_tree(root_node, thing_to_do_at_node, extra_args=None):
    stack = [root_node]
    count = 0
    while stack != []:
        curr = stack.pop(-1)
        if curr != None:
            if extra_args != None:
                thing_to_do_at_node(curr, extra_args)
            else:
                thing_to_do_at_node(curr, count)
            if curr.childR != None:
                stack.append(curr.childR)
            stack.append(curr.childL)
            count = count + 1
    return root_node
    
def generate_simple_str(string_len):
    # Make sure the string is a multiple of 2
    if string_len % 2 == 1:
        return
    out_str = []
    for i in range(int(string_len/2)):
        out_str.append(a)
        out_str.append(c)
    return out_str


def generate_prod_strings(prod_arr):
    out_str = ""
    for tup in prod_arr:
        out_str += "[[prods]]\nparent=" + str(tup[0]) + "\nchildL=" + str(tup[1]) + "\nchildR=" + str(tup[2]) + "\n"
    return out_str


def generate_prod_strings2(prod_arr, labels):
    out_str = ""
    for tup in prod_arr:
        parent_label=labels[tup[0]]
        childL_label=labels[tup[1]]
        childR_label=labels[tup[2]]
        if tup[2] == 0:
            childR_label = 0
        parent_idx=tup[0]
        childL_idx=tup[1]
        childR_idx=tup[2]
        out_str += "[[prods]]\nparent.label=" + str(parent_label) + "\nparent.idx=" + str(parent_idx) \
            + "\nchildL.label=" + str(childL_label) + "\nchildL.idx=" + str(childL_idx) \
               + "\nchildR.label=" + str(childR_label) + "\nchildR.idx=" + str(childR_idx) + "\n"
    return out_str



def generate_arr_str(label, arr):
    out_str = label
    out_str += "=["
    for i in range(len(arr) - 1):
        out_str += str(arr[i]) + ","
    out_str += str(arr[len(arr) - 1])
    out_str += "]"
    return out_str

def naive_prods_full_witness_generator(string_len):
    # Make sure the string is a multiple of 2
    if string_len % 2 == 1:
        return
    string_arr = generate_simple_str(string_len)
    root_node = bfs_parse_tree(build_parse_tree(string_len), label_fn)
    label_arr = [] 
    prod_arr = [] 
    rule_arr = []    
    bfs_parse_tree(root_node, append_wits, (label_arr, prod_arr,rule_arr))
    # string_str = generate_arr_str("string", string_arr)
    # label_str = generate_arr_str("labels", label_arr)
    # prods_str = generate_prod_strings(prod_arr)
    # mem_proofs_str = generate_arr_str("mem_proofs_prod", rule_arr)
    return [string_arr, label_arr, prod_arr, rule_arr]
    # return [string_str, label_str, prods_str, mem_proofs_str]

def naive_prods_full_witness_generator_dfs(string_len):
    # Make sure the string is a multiple of 2
    if string_len % 2 == 1:
        return
    string_arr = generate_simple_str(string_len)
    root_node = dfs_parse_tree(build_parse_tree(string_len), label_fn)
    label_arr = [] 
    prod_arr = [] 
    rule_arr = []    
    dfs_parse_tree(root_node, append_wits, (label_arr, prod_arr,rule_arr))
    # string_str = generate_arr_str("string", string_arr)
    # label_str = generate_arr_str("labels", label_arr)
    # prods_str = generate_prod_strings(prod_arr)
    # mem_proofs_str = generate_arr_str("mem_proofs_prod", rule_arr)
    return [string_arr, label_arr, prod_arr, rule_arr]
    # return [string_str, label_str, prods_str, mem_proofs_str]

def count_str_traversal(prod_arr, labels): 
    count = 0
    for prod in prod_arr:
        (_, child_l_loc, child_r_loc) = prod
        if (labels[child_l_loc] in terminals):
            count = count+1
        if (labels[child_r_loc] in terminals):
            count = count+1
    return count


def generate_all_prover_files(n, k, g=3):
    [string_arr, label_arr, prod_arr, rule_arr] = naive_prods_full_witness_generator(n)
    # for out_str in out_strs:
    #     print(out_str + "\n")
    string_str = generate_arr_str("string", string_arr)
    label_str = generate_arr_str("labels", label_arr)
    prods_com="prods_com=\"" + mt_hashes[g] + "\""
    num_proofs=int((2*n)/k)

    out_strs = []
    for i in range(num_proofs):
        if i == 0:
            prods_str = generate_prod_strings(prod_arr[0:k-1])
            # proofs=[merkle_prods[g] for _ in range(k-1)]
            # mem_proofs_str = ''.join(proofs)
            # print(prods_str)
            # print("******************")
            mem_proofs_str = generate_arr_str("mem_proofs_prod", rule_arr[:k-1])
            out_strs = [string_str, label_str,  
                prods_com, prods_str, mem_proofs_str]
            with open('./base_parsing_circuit/Prover.toml', 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')
            with open('./base_parsing_circuit/Verifier.toml', 'w') as file:
                file.write(string_str + '\n') 
            # Open a file in write mode ('w')

            prods_str2 = generate_prod_strings2(prod_arr[0:k-1], label_str)
            out_strs = [string_str, prods_com, prods_str2, mem_proofs_str]
            with open('./base_parsing_circuit_no_labels/Prover.toml', 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')
            with open('./base_parsing_circuit_no_labels/Verifier.toml', 'w') as file:
                file.write(string_str + '\n') 
            # Open a file in write mode ('w')

        else:
            prods_str = generate_prod_strings(prod_arr[i*k - 1:(i+1)*k - 1])
            # print(prods_str)
            # proofs=[merkle_prods[g] for _ in range(k)]
            # mem_proofs_str = ''.join(proofs)
            mem_proofs_str = generate_arr_str("mem_proofs_prod", rule_arr[i*k - 1:(i+1)*k - 1])
            last_pos = i*k - 2
            traversal_count = count_str_traversal(prod_arr[:i*k - 1], label_arr)
            node_counter=(prod_arr[last_pos][1] + 1 if prod_arr[last_pos][2]==0 else prod_arr[last_pos][2] + 1 )
            previous_final_parent = "node_counter=" + str(node_counter)
            start_prod_idx_str = "start_prod_idx=" + str(last_pos)
            string_elt_count="string_elt_count=" + str(traversal_count)
            out_strs = [string_str, label_str,  
                previous_final_parent, start_prod_idx_str, string_elt_count, prods_com]
            os.makedirs('./prover_toml_files', exist_ok=True)
            os.makedirs('./verifier_toml_files', exist_ok=True)
            with open('./prover_toml_files/Prover.toml' + str(i), 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')    
            with open('./prover_toml_files/prods' + str(i), 'w') as file:
                file.write(mem_proofs_str + '\n')
                file.write(prods_str + '\n')
            with open('./verifier_toml_files/Verifier.toml' + str(i), 'w') as file:
                file.write(string_str + '\n')    


def generate_all_prover_files_dfs(n, k, g=3):
    [string_arr, label_arr, prod_arr, rule_arr] = naive_prods_full_witness_generator_dfs(n)
    # for out_str in out_strs:
    #     print(out_str + "\n")
    string_str = generate_arr_str("string", string_arr)
    label_str = generate_arr_str("labels", label_arr)
    prods_com="prods_com=\"" + mt_hashes[g] + "\""
    num_proofs=int((2*n)/k)

    out_strs = []
    for i in range(num_proofs):
        if i == 0:
            prods_str = generate_prod_strings(prod_arr[0:k-1])
            # proofs=[merkle_prods[g] for _ in range(k-1)]
            # mem_proofs_str = ''.join(proofs)
            # print(prods_str)
            # print("******************")
            mem_proofs_str = generate_arr_str("mem_proofs_prod", rule_arr[:k-1])
            out_strs = [string_str, label_str,  
                prods_com, prods_str, mem_proofs_str]
            with open('./base_parsing_circuit/Prover.toml', 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')
            with open('./base_parsing_circuit/Verifier.toml', 'w') as file:
                file.write(string_str + '\n') 
            # Open a file in write mode ('w')

            prods_str2 = generate_prod_strings2(prod_arr[0:k-1], label_str)
            out_strs = [string_str, prods_com, prods_str2, mem_proofs_str]
            with open('./base_dfs_parsing_no_mt/Prover.toml', 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')
            with open('./base_dfs_parsing_no_mt/Verifier.toml', 'w') as file:
                file.write(string_str + '\n') 
            # Open a file in write mode ('w')

        else:
            prods_str = generate_prod_strings(prod_arr[i*k - 1:(i+1)*k - 1])
            # print(prods_str)
            # proofs=[merkle_prods[g] for _ in range(k)]
            # mem_proofs_str = ''.join(proofs)
            mem_proofs_str = generate_arr_str("mem_proofs_prod", rule_arr[i*k - 1:(i+1)*k - 1])
            last_pos = i*k - 2
            traversal_count = count_str_traversal(prod_arr[:i*k - 1], label_arr)
            node_counter=(prod_arr[last_pos][1] + 1 if prod_arr[last_pos][2]==0 else prod_arr[last_pos][2] + 1 )
            previous_final_parent = "node_counter=" + str(node_counter)
            start_prod_idx_str = "start_prod_idx=" + str(last_pos)
            string_elt_count="string_elt_count=" + str(traversal_count)
            out_strs = [string_str, label_str,  
                previous_final_parent, start_prod_idx_str, string_elt_count, prods_com]
            os.makedirs('./prover_toml_files', exist_ok=True)
            os.makedirs('./verifier_toml_files', exist_ok=True)
            with open('./prover_toml_files/Prover.toml' + str(i), 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')    
            with open('./prover_toml_files/prods' + str(i), 'w') as file:
                file.write(mem_proofs_str + '\n')
                file.write(prods_str + '\n')
            with open('./verifier_toml_files/Verifier.toml' + str(i), 'w') as file:
                file.write(string_str + '\n')    


def generate_all_prover_files_with_merkle_paths_dfs(n, k, g):
    [string_arr, label_arr, prod_arr, rule_arr] = naive_prods_full_witness_generator_dfs(n)
    # for out_str in out_strs:
    #     print(out_str + "\n")
    string_str = generate_arr_str("string", string_arr)
    label_str = generate_arr_str("labels", label_arr)
    prods_com="prods_com=\"" + mt_hashes[g] + "\""
    num_proofs=int((2*n)/k)

    out_strs = []
    for i in range(num_proofs):
        if i == 0:
            prods_str = generate_prod_strings(prod_arr[0:k-1])
            proofs=[merkle_prods[g] for _ in range(k-1)]
            mem_proofs_str = ''.join(proofs)
            # print(prods_str)
            # print("******************")
            # mem_proofs_str = generate_arr_str("mem_proofs_prod", rule_arr[:k-1])
            out_strs = [string_str, label_str,  
                prods_com, prods_str, mem_proofs_str]
            with open('./base_parsing_circuit/Prover.toml', 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')
            with open('./base_parsing_circuit/Verifier.toml', 'w') as file:
                file.write(string_str + '\n') 
            # Open a file in write mode ('w')

            prods_str2 = generate_prod_strings2(prod_arr[0:k-1], label_arr)
            out_strs = [string_str, prods_com, prods_str2, mem_proofs_str]
            with open('./base_dfs_parsing_no_mt/Prover.toml', 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')
            with open('./base_dfs_parsing_no_mt/Verifier.toml', 'w') as file:
                file.write(string_str + '\n') 

            mem_proofs_str2 = generate_arr_str("mem_proofs_prod", rule_arr[:k-1])
            prods_str3 = generate_prod_strings2(prod_arr[0:k-1], label_arr)
            out_strs = [string_str, prods_com, mem_proofs_str2, prods_str3]
            with open('./base_dfs_parsing_no_mt/Prover.toml', 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')
            with open('./base_dfs_parsing_no_mt/Verifier.toml', 'w') as file:
                file.write(string_str + '\n') 


        else:
            prods_str = generate_prod_strings(prod_arr[i*k - 1:(i+1)*k - 1])
            # print(prods_str)
            proofs=[merkle_prods[g] for _ in range(k)]
            mem_proofs_str = ''.join(proofs)
            # mem_proofs_str = generate_arr_str("mem_proofs_prod", rule_arr[i*k - 1:(i+1)*k - 1])
            last_pos = i*k - 2
            traversal_count = count_str_traversal(prod_arr[:i*k - 1], label_arr)
            node_counter=(prod_arr[last_pos][1] + 1 if prod_arr[last_pos][2]==0 else prod_arr[last_pos][2] + 1 )
            previous_final_parent = "node_counter=" + str(node_counter)
            start_prod_idx_str = "start_prod_idx=" + str(last_pos)
            string_elt_count="string_elt_count=" + str(traversal_count)
            out_strs = [string_str, label_str,  
                previous_final_parent, start_prod_idx_str, string_elt_count, prods_com]
            os.makedirs('./prover_toml_files', exist_ok=True)
            os.makedirs('./verifier_toml_files', exist_ok=True)
            with open('./prover_toml_files/Prover.toml' + str(i), 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')    
            with open('./prover_toml_files/prods' + str(i), 'w') as file:
                file.write(mem_proofs_str + '\n')
                file.write(prods_str + '\n')
            with open('./verifier_toml_files/Verifier.toml' + str(i), 'w') as file:
                file.write(string_str + '\n')  

def generate_all_prover_files_with_merkle_paths(n, k, g):
    [string_arr, label_arr, prod_arr, rule_arr] = naive_prods_full_witness_generator(n)
    # for out_str in out_strs:
    #     print(out_str + "\n")
    string_str = generate_arr_str("string", string_arr)
    label_str = generate_arr_str("labels", label_arr)
    prods_com="prods_com=\"" + mt_hashes[g] + "\""
    num_proofs=int((2*n)/k)

    out_strs = []
    for i in range(num_proofs):
        if i == 0:
            prods_str = generate_prod_strings(prod_arr[0:k-1])
            proofs=[merkle_prods[g] for _ in range(k-1)]
            mem_proofs_str = ''.join(proofs)
            # print(prods_str)
            # print("******************")
            # mem_proofs_str = generate_arr_str("mem_proofs_prod", rule_arr[:k-1])
            out_strs = [string_str, label_str,  
                prods_com, prods_str, mem_proofs_str]
            with open('./base_parsing_circuit/Prover.toml', 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')
            with open('./base_parsing_circuit/Verifier.toml', 'w') as file:
                file.write(string_str + '\n') 
            # Open a file in write mode ('w')

            prods_str2 = generate_prod_strings2(prod_arr[0:k-1], label_arr)
            out_strs = [string_str, prods_com, prods_str2, mem_proofs_str]
            with open('./base_parsing_circuit_no_labels/Prover.toml', 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')
            with open('./base_parsing_circuit_no_labels/Verifier.toml', 'w') as file:
                file.write(string_str + '\n') 

            mem_proofs_str2 = generate_arr_str("mem_proofs_prod", rule_arr[:k-1])
            prods_str3 = generate_prod_strings2(prod_arr[0:k-1], label_arr)
            out_strs = [string_str, prods_com, mem_proofs_str2, prods_str3]
            with open('./base_dfs_parsing_no_mt/Prover.toml', 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')
            with open('./base_dfs_parsing_no_mt/Verifier.toml', 'w') as file:
                file.write(string_str + '\n') 


        else:
            prods_str = generate_prod_strings(prod_arr[i*k - 1:(i+1)*k - 1])
            # print(prods_str)
            proofs=[merkle_prods[g] for _ in range(k)]
            mem_proofs_str = ''.join(proofs)
            # mem_proofs_str = generate_arr_str("mem_proofs_prod", rule_arr[i*k - 1:(i+1)*k - 1])
            last_pos = i*k - 2
            traversal_count = count_str_traversal(prod_arr[:i*k - 1], label_arr)
            node_counter=(prod_arr[last_pos][1] + 1 if prod_arr[last_pos][2]==0 else prod_arr[last_pos][2] + 1 )
            previous_final_parent = "node_counter=" + str(node_counter)
            start_prod_idx_str = "start_prod_idx=" + str(last_pos)
            string_elt_count="string_elt_count=" + str(traversal_count)
            out_strs = [string_str, label_str,  
                previous_final_parent, start_prod_idx_str, string_elt_count, prods_com]
            os.makedirs('./prover_toml_files', exist_ok=True)
            os.makedirs('./verifier_toml_files', exist_ok=True)
            with open('./prover_toml_files/Prover.toml' + str(i), 'w') as file:
                for elt in out_strs:
                    file.write(elt + '\n')    
            with open('./prover_toml_files/prods' + str(i), 'w') as file:
                file.write(mem_proofs_str + '\n')
                file.write(prods_str + '\n')
            with open('./verifier_toml_files/Verifier.toml' + str(i), 'w') as file:
                file.write(string_str + '\n')  

########## JSON writing functions


def generate_prod_strings_json(prod_arr, labels):
    out_str = "[\n"
    i = 0 
    arr_len = len(prod_arr)
    for tup in prod_arr:
        parent_label=labels[tup[0]]
        childL_label=labels[tup[1]]
        childR_label=labels[tup[2]]
        parent_idx=tup[0]
        childL_idx=tup[1]
        childR_idx=tup[2]
        out_str += "\t{\n"\
        + "\t\t\"parent\": {\"label\":" + str(parent_label) + ", \"index\": " + str(parent_idx) + "},\n" \
        + "\t\t\"childL\": {\"label\":" + str(childL_label) + ", \"index\": " + str(childL_idx) + "},\n" \
        + "\t\t\"childR\": {\"label\":" + str(childR_label) + ", \"index\": " + str(childR_idx) + "}\n\t}"
        if(i < (arr_len - 1)):
            out_str += ",\n"
        i += 1
    out_str = out_str + "\n]\n"
    return out_str


# Takes as input a string and a filename (without the .json ext) and writes 
# the corresponding string and production to a JSON file (complete with .json ext)
def generate_and_write_productions_json(string_len, filename):
    [string_arr, label_arr, prod_arr, _] = naive_prods_full_witness_generator(string_len)
    elt1 = "\"string\":" + str(string_arr) + ","
    elt2 = generate_prod_strings_json(prod_arr, label_arr)
    out_str = "{" + elt1 + "\n\"productions\": " + elt2 + "}" 
    with open(filename + '.json', 'w') as file:
        file.write(out_str)

# generate_and_write_productions_json(4, "test")

n_from_sys = int(sys.argv[1])
k_from_sys = int(sys.argv[2])
g_from_sys = int(sys.argv[3])
print(generate_all_prover_files_with_merkle_paths_dfs(n_from_sys, k_from_sys, g_from_sys))



# generate_all_prover_files_with_merkle_paths(n_from_sys, k_from_sys, g_from_sys)