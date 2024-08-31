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

global rules = [
    (S, Ac, Ac),  //0 
    (Ac, Ac, Ac), //1
    (Ac, A, C),   //2
    (A, a, 0),   //3
    (C, c, 0),   //4
    (S, A, C),  //5
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
// Same as parseTreeChecker but takes in positions of productions, instead of edges. 
fn parseTreeCheckerProdsNaive2(
    string: pub [Field; N],
    // labels: [Field; 3*N - 1],
    prods: [Production2; K - 1],
    mem_proofs_prod: [Field; K-1],
    // production_com: Field,
) -> (Field, Field, bool) {
    // FIXME: Right now, none of the checks ensure that 
    // the root node is in the set of start symbols.
    let mut output = true;
    let mut leaf_count = 0;
    let mut node_counter = 0;
    let mut latest_parent = 0;
    
    output = output * (node_counter == prods[0].parent.idx);
    node_counter = node_counter + 1;
    for i in 0..K - 1 {
        let prod = prods[i];
        let parent = prod.parent;
        let left_child = prod.childL;
        let right_child = prod.childR;
        let parent_id = parent.idx;
		let child_L_id = left_child.idx;
        let child_R_id = right_child.idx;
        // First check for no cycles
        let mut parent_check = parent_id.lt(child_L_id);
        let mut count_check = child_L_id == node_counter;
        node_counter = node_counter + 1;

        
        if child_R_id == 0 {
            // This is the case where we are dealing with a NT --> T rule
            // Terminal check checks both that a leaf node is a terminal 
            // and in the string, since we assume the string is correctly composed of terminals.
            let terminal_check = (left_child.label == string[leaf_count]);
            leaf_count = leaf_count + 1;
            output = output * terminal_check;
        }
        else {
            // This and the other node counter check, above ensures that all child nodes
            // appear in exactly one production and that each non-root node
            // has a parent. 
            count_check = count_check * (child_R_id == node_counter);
            node_counter = node_counter + 1;
            // right_child = labels[child_R_id];
            // Second check for no cycles
            parent_check = parent_check * (parent_id.lt(child_R_id));
        }
        
	
        let rule = (parent.label as Field, left_child.label as Field, right_child.label as Field);
        // This finally checks that the production is valid.
        let prod_check = (rule == rules[mem_proofs_prod[i]]);

        // We need to ensure that exactly 2N-1 productions are made,
        // each with a unique parent node. 
        // The strictly increasing requirement ensures this. 
        let mut parent_increment_check = latest_parent.lt(parent_id);
        if i == 0 {
            parent_increment_check = latest_parent.eq(parent_id);
        }
        latest_parent = parent_id;
        output = output * parent_check * count_check * parent_increment_check;
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
    (node_counter, leaf_count, output)
}






/************ MAIN FUNCTIONS BELOW HERE ****************/





// #[recursive]
// fn main(
//     string: pub [Field; N],
//     labels: [Field; 3*N - 1],
//     prods: [Production; K - 1],
//     mem_proofs_prod:[Field; K - 1]
// ) -> pub (Field, Field) {

//     let (node_counter, leaf_count, out_bit) = parseTreeCheckerProdsNaive(string, labels, prods, mem_proofs_prod);
//     assert(out_bit == true);
//     (node_counter, leaf_count)
   
// }

#[recursive]
fn main(
    string: pub [Field; N],
    prods: [Production2; K - 1],
    mem_proofs_prod:[Field; K - 1],
    prods_com: Field,
) -> pub (Field, Field) {

    let (node_counter, leaf_count, out_bit) = parseTreeCheckerProdsNaive2(string, prods, mem_proofs_prod);
    assert(out_bit == true);
    (node_counter, leaf_count)
   
}

