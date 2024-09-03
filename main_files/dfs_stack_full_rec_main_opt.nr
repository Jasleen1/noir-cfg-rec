/*
 bb: c, b: cc
Rules:
   S, Ac, A
   Ac, A, C
   A, a, 0
   B, b, 0
   C, c, 0
   Bc, B, C
 */
/*
[S]          0, 0
[ Ac A ]     1, 0  [ Ac->1 A ] 
[ A C A]     6, 2  [ Ac->2 A C ]
[ A C Bc C ] 4, 3
[ A C Bc c ] 5, 2
[ A C B C c ]4, 3
[ a C B C c ]3, 2
[ a C b C c ]2, 0
[ a C b c c ]4, 1
[ a c b c c ]
 */
use dep::std;

global N = ${STR_SIZE};
global K = ${BATCH_SIZE};
global Log_Rules = ${GRAMMAR_SIZE};

global rules = ${RULES};

global S = 1;
global Ac = 2;
global A = 3;
global C = 4;
global a = 5;
global c = 6;

global terminals = [
	a, // 0 
	c // 1
];

global non_terminals = [
	S, // 0
	Ac, // 2
	A, // 3
	C, // 4
];




// Just got this from noir's source code and changed the hash fn
fn compute_merkle_root_poseiden<D>(leaf: Field, index: Field, hash_path: [Field; D]) -> Field {
    let n = hash_path.len();
    let index_bits = index.to_le_bits(n as u32);
    let mut current = leaf;
    for i in 0..n {
        let path_bit = index_bits[i] as bool;
        let (hash_left, hash_right) = if path_bit {
            (hash_path[i], current)
        } else {
            (current, hash_path[i])
        };
        current = std::hash::poseidon2::Poseidon2::hash([hash_left, hash_right], 2);
    }
    current
}




struct Production {
    parent: Field,
    childL: Field,
    childR: Field,
}

impl Production {
    pub fn new(parent: Field, childL: Field, childR: Field) -> Self {
        Production {
            parent,
            childL,
            childR
        }
    }
}

struct Node2 {
    label: Field,
    idx: Field
}


impl Node2 {
    fn new(label: Field, idx: Field) -> Self {
        Node2 {
            label,
            idx
        }
    }
}

struct Production2 {
    parent: Node2,
    childL: Node2,
    childR: Node2,
}

struct StackTuple {
    idx: Field,
    label: Field,
    hash_preimage: Field
}


fn made_up_hash_fn(x: Node2, y: Field) -> Field {
    let x_sum = x.label + x.idx;
    let total = x_sum + y;
    ((total as u32) % 10) as Field
}

fn poseidon_hash_fn(x: Node2, y: Field) -> Field {
    std::hash::poseidon::bn254::hash_4([x.label, x.idx, y, 0])
}

fn used_hash_fn(x: Node2, y: Field) -> Field {
    poseidon_hash_fn(x, y)
    // made_up_hash_fn(x, y)
}

// Same as parseTreeChecker but takes in positions of productions, instead of edges. 
fn parseTreeCheckerProdsNaive2(
    string: pub [Field; N],
    // labels: [Field; 3*N - 1],
    prods: [Production2; K],
    mem_proofs_prod: [MerkleProofProductions; K],
    next_parent_index_inp: Field,
    leaf_count_inp: Field,
    stack_hash_inp: Field, 
    stack_depth_inp: Field,
    expected_idx: Field, 
    expected_label: Field,
    stack_expected_popped_vals: [StackTuple; K],
    // production_com: Field,
) -> (Field, Field, Field, Field, Field, Field, bool) {
    // FIXME: Right now, none of the checks ensure that 
    // the root node is in the set of start symbols.
    let mut output = true;
    let mut leaf_count = leaf_count_inp;
    let mut next_parent_index = next_parent_index_inp;
    let mut stack_depth = stack_depth_inp;

    let mut running_hash = stack_hash_inp; 

    for i in 0..K {
        // print(i);
        // print("\n");
        let popped_item = stack_expected_popped_vals[i];
        stack_depth = stack_depth - 1;

        
        
        let prod = prods[i];
        let parent = prod.parent;
        let left_child = prod.childL;
        let right_child = prod.childR;

        let parent_id = parent.idx;
		let child_L_id = left_child.idx;
        let child_R_id = right_child.idx;

        let correct_pop = (popped_item.label == parent.label) * (popped_item.idx == parent_id);
        let counter_correctness = (parent_id == next_parent_index);

        // print("Popped item = ");
    
        output = output * counter_correctness * correct_pop;
        output = output * ((parent_id + 1) == child_L_id);
        // print("output 1 = ");
        // print(output);
        // print("\n");

        let hash_preimage = popped_item.hash_preimage;
        let stack_integrity = (used_hash_fn(parent, hash_preimage) == running_hash);
        // print("i = ");
        // print(i);
        // print(" stack integrity = ");
        // print(stack_integrity);
        // print("\n");
        // print("correct pop = ");
        // print(correct_pop);
        // print("\n");
        // print("counter correctness =");
        // print(counter_correctness);
        // print("\n");

        output = stack_integrity * output;
        running_hash = hash_preimage;
        // print("output 1.5 = ");
        // print(output);
        // print("\n");
        


        if child_R_id == 0 {
            // This is the case where we are dealing with a NT --> T rule
            // Terminal check checks both that a leaf node is a terminal 
            // and in the string, since we assume the string is correctly composed of terminals.
            let terminal_check = (left_child.label == string[leaf_count]);
            next_parent_index = child_L_id + 1;
            leaf_count = leaf_count + 1;
            output = output * terminal_check;
            // print("output 2 = ");
            // print(output);
            // print("\n");
        }
        else {
            // This and the other node counter check, above ensures that all child nodes
            // appear in exactly one production and that each non-root node
            // has a parent. 
            print(running_hash);
            //running_hash = used_hash_fn(right_child, running_hash);
            running_hash = used_hash_fn(right_child, hash_preimage);
            stack_depth = stack_depth + 1;
            // stack.insert(stack.len(), (right_child.label, right_child.idx));
            running_hash = used_hash_fn(left_child, running_hash);
            stack_depth = stack_depth + 1;
            // stack.insert(stack.len(), (left_child.label, left_child.idx));

            next_parent_index = child_L_id;
        }
        
        let rule = (parent.label as Field, left_child.label as Field, right_child.label as Field);
        // This finally checks that the production is valid.
        let prod_check = (rule == rules[mem_proofs_prod[i]]);
        
        output = output * prod_check;
        // print("output 3 = ");
        // print(output);
        // print("\n");
    }
	// Checks that all child nodes are in the correct range.
    // Note that we already checked that the start node is 0.
    // And that all real nodes after that respect increments of 1.
    // let nodes_check = (node_counter == ((3*N - 1) as Field));
    // Check that we had the exactly right number of leaves.
    // let leaves_check = (leaf_count == (N as Field));
    // Check that parent nodes are within range upper bound.
    // let parent_range_final_check = (latest_parent.lt((3*N - 1) as Field));
    // output = output * leaves_check  * nodes_check * parent_range_final_check;
    (next_parent_index, leaf_count, running_hash, stack_depth, expected.idx, expected.label, output)
}






/************ MAIN FUNCTIONS BELOW HERE ****************/


#[recursive]
fn main(
    string: pub [Field; N],
    labels: [Field; 3*N - 1],
    prods: [Production2; K],
    mem_proofs_prod: [Field; K],
    // These are passed in from the computation done before
    next_parent_index: Field,
    leaf_count: Field,
    stack_hash: Field, 
    stack_depth: Field,
    expected_idx: Field,
    expected_label: Field,
    stack_expected_popped_vals: [StackTuple; K],
    // Below is the stuff we need to verify the recursive proof
    verification_key : [Field; 114], 
    proof : [Field; 109], 
    key_hash : Field,
) -> pub (Field, Field, Field, Field) {
    let mut input_slice=string.as_slice();
    input_slice=input_slice.push_back(next_parent_index);
    input_slice=input_slice.push_back(leaf_count);
    input_slice=input_slice.push_back(stack_hash);
    input_slice=input_slice.push_back(stack_depth);
    input_slice=input_slice.push_back(expected_label);
    std::verify_proof(
        verification_key.as_slice(), 
        proof.as_slice(), 
        input_slice,
        key_hash,
    );
    // let (node_counter, leaf_count, out_bit) = parseTreeCheckerProdsNaive(string, labels, prods, mem_proofs_prod, string_elt_count, node_counter);
    // assert(out_bit == true);

    let (next_parent_index, leaf_count, 
                next_stack_hash, stack_depth, expected_label, out_bit) = 
                                            parseTreeCheckerProdsNaive2(string, prods, mem_proofs_prod, 
                                            next_parent_index, leaf_count, stack_hash, stack_depth, stack_expected_popped_vals);
    assert(out_bit == true);
    (next_parent_index, leaf_count, next_stack_hash, stack_depth, expected_idx, expected_label)
}


/*
Commenting since this test is for fixed N and K params


#[test]
fn test_parse_tree_checker_prods_naive_rec1() {
    let base_prod = Production2{
        parent: Node2::new(S, 0),
        childL: Node2::new(Ac, 1),
        childR: Node2::new(Ac, 6),
    };
    let mut prods = [base_prod; 4];

    /// Put in the parts of the DFS tree

    prods[0] = Production2{
        parent: Node2::new(C, 4),
        childL: Node2::new(c, 5),
        childR: Node2::new(0, 0),
    };

    prods[1] = Production2{
        parent: Node2::new(Ac, 6),
        childL: Node2::new(A, 7),
        childR: Node2::new(C, 9),
    };

    prods[2] = Production2{
        parent: Node2::new(A, 7),
        childL: Node2::new(a, 8),
        childR: Node2::new(0, 0),
    };

    prods[3] = Production2{
        parent: Node2::new(C, 9),
        childL: Node2::new(c, 10),
        childR: Node2::new(0, 0),
    };

    let stack_expected_popped_vals = [StackTuple { idx: 0x04, label: 0x04, hash_preimage: 0x08 },
            StackTuple { idx: 0x06, label: 0x02, hash_preimage: 0x00 },
            StackTuple { idx: 0x07, label: 0x03, hash_preimage: 0x03 },
            StackTuple { idx: 0x09, label: 0x04, hash_preimage: 0x00 }];
    let (next_parent_index, leaf_count, next_stack_hash, stack_depth, out_bit) = parseTreeCheckerProdsNaive2([a, c, a, c], 
	prods,
	[4, 2, 3, 4],
    4,
    1,
    6,
    2,
    stack_expected_popped_vals
    );
    // print("Output = ");
    // print((next_parent_index, leaf_count, next_stack_hash, stack_depth, out_bit) );
    assert(leaf_count == (4 as Field));
    assert(out_bit == true);
}

*/