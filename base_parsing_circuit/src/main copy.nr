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

global N = 32;
global K = 8;
// N_var
// global N = 32;
// K_var
// global K = 16;
global Log_Rules = 10;

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


struct Node {
    next: Field,
    val: Field
}

fn node_equals(node1: Node, node2: Node) -> bool {
    let bool_1 = (node1.next == node2.next);
    let bool_2 = (node1.val == node2.val);
    bool_1 * bool_2
}

struct App {
	rule: Field,
	position: Field
}




unconstrained
fn find_loc(list: [Node; N], loc: Field) -> Field {
    let mut physical_loc: Field = 0;
    let mut req_node = Node { next: -1, val: 0 };
    let mut curr_node = list[0];
    let mut traversed = 0;
    for _ in 0..N {
        if traversed == loc {
            req_node = curr_node;
        } else {
            curr_node = list[curr_node.next];
        }
        traversed += 1;
    }
    let mut counter: Field = 0;
    for i in 0..N {
        if node_equals(list[i], req_node) {
            physical_loc = counter;
        }
        counter = counter + 1;
    }
    physical_loc
}

struct Edge {
	parent: Field,
	child: Field
}

struct Rule {
	left_child: Field,
	right_child: Field,
}





impl Rule {
    fn new(left_child: Field, right_child: Field) -> Self {
        Rule { left_child, right_child }
    }
}

// Used to represent a set of labels
struct Rule2 {
	left_child: Field,
	right_child: Field,
}

impl Rule2 {
    fn new(left_child: Field, right_child: Field) -> Self {
        Rule2 { left_child, right_child }
    }
}

impl Edge {
    fn new(parent: Field, child: Field) -> Self {
        Edge { parent, child }
    }
}



struct MerkleProofProductions {
	index: Field,
	hashpath: [Field; Log_Rules]
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


// Same as parseTreeChecker but takes in positions of productions, instead of edges. 
fn parseTreeCheckerProdsNaive(
    string: pub [Field; N],
    labels: [Field; 3*N - 1],
    prods: [Production; K - 1],
    mem_proofs_prod: [Field; K - 1]
) -> (Field, Field, bool) {
    println(prods);
    // FIXME: Right now, none of the checks ensure that 
    // the root node is in the set of start symbols.
    let mut output = true;
    let mut leaf_count = 0;
    let mut node_counter = 0;
    let mut latest_parent = 0;
    output = output * (node_counter == prods[0].parent);
    node_counter = node_counter + 1;
    for i in 0..K - 1 {
        let prod = prods[i];
        let parent_id = prod.parent;
		let child_L_id = prod.childL;
        let child_R_id = prod.childR;
        let parent = labels[parent_id];
        let left_child = labels[child_L_id];
        let mut right_child = 0;
        // First check for no cycles
        let mut parent_check = parent_id.lt(child_L_id);
        let mut count_check = child_L_id == node_counter;
        node_counter = node_counter + 1;
        if child_R_id == 0 {
            // This is the case where we are dealing with a NT --> T rule
            // Terminal check checks both that a leaf node is a terminal 
            // and in the string, since we assume the string is correctly composed of terminals.
            let terminal_check = (left_child == string[leaf_count]);
            leaf_count = leaf_count + 1;
            output = output * terminal_check;
        }
        else {
            // This and the other node counter check, above ensures that all child nodes
            // appear in exactly one production and that each non-root node
            // has a parent. 
            count_check = count_check * (child_R_id == node_counter);
            node_counter = node_counter + 1;
            right_child = labels[child_R_id];
            // Second check for no cycles
            parent_check = parent_check * (parent_id.lt(child_R_id));
        }
        
	
        let rule = (parent as Field, left_child as Field, right_child as Field);
        // // This finally checks that the production is valid.
        let prod_check = (rule == rules[mem_proofs_prod[i]]);

        // We need to ensure that exactly 2N-1 productions are made,
        // each with a unique parent node. 
        // The strictly increasing requirement ensures this. 
        let mut parent_increment_check = latest_parent.lt(parent_id);
        if i == 0 {
            parent_increment_check = latest_parent.eq(parent_id);
        }
        latest_parent = parent_id;
        output = output * parent_check * count_check * parent_increment_check * prod_check;
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


// Same as parseTreeChecker but takes in positions of productions, instead of edges. 
fn parseTreeCheckerProdsNaive2(
    string: pub [Field; N],
    labels: [Field; 3*N - 1],
    prods: [Production; K - 1],
    mem_proofs_prod: [MerkleProofProductions; 1],
    production_com: Field,
) -> (Field, Field, bool) {
    println(prods);
    // FIXME: Right now, none of the checks ensure that 
    // the root node is in the set of start symbols.
    let mut output = true;
    let mut leaf_count = 0;
    let mut node_counter = 0;
    let mut latest_parent = 0;
    
    let prod_proof=mem_proofs_prod[0];
    let hash_path = prod_proof.hashpath;
    let index=prod_proof.index;
    let computed_hash = compute_merkle_root_poseiden(1, index, hash_path);
    output = output * (computed_hash == production_com);

    output = output * (node_counter == prods[0].parent);
    node_counter = node_counter + 1;
    for i in 0..K - 1 {
        let prod = prods[i];
        let parent_id = prod.parent;
		let child_L_id = prod.childL;
        let child_R_id = prod.childR;
        let parent = labels[parent_id];
        let left_child = labels[child_L_id];
        let mut right_child = 0;
        // First check for no cycles
        let mut parent_check = parent_id.lt(child_L_id);
        let mut count_check = child_L_id == node_counter;
        node_counter = node_counter + 1;
        if child_R_id == 0 {
            // This is the case where we are dealing with a NT --> T rule
            // Terminal check checks both that a leaf node is a terminal 
            // and in the string, since we assume the string is correctly composed of terminals.
            let terminal_check = (left_child == string[leaf_count]);
            leaf_count = leaf_count + 1;
            output = output * terminal_check;
        }
        else {
            // This and the other node counter check, above ensures that all child nodes
            // appear in exactly one production and that each non-root node
            // has a parent. 
            count_check = count_check * (child_R_id == node_counter);
            node_counter = node_counter + 1;
            right_child = labels[child_R_id];
            // Second check for no cycles
            parent_check = parent_check * (parent_id.lt(child_R_id));
        }
        
	
        let rule = (parent as Field, left_child as Field, right_child as Field);
        // // This finally checks that the production is valid.
        // let prod_check = (rule == rules[mem_proofs_prod[i]]);

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

// Same as parseTreeChecker but takes in productions, instead of edges. 
// This is the most updated algorithm that has the least number of constraints. 
fn parseTreeCheckerProds(
    string: [Field; N],
    labels: [Field; 3*N - 1],
    prods: [Production; K - 1],
    mem_proofs_prod: [MerkleProofProductions; K - 1],
	rules_com: Field,
    start_prod_idx: u32,
    end_prod_idx: u32,
    string_elt_count: Field,
    previous_final_parent: Field,
) -> (Field, bool) {
    // FIXME: Right now, none of the checks ensure that 
    // the root node is in the set of start symbols.
    let mut output = true;
    let mut leaf_count = string_elt_count;
    let mut node_counter = 0;
    let mut latest_parent = previous_final_parent;
    output = output * (node_counter == prods[0].parent);
    node_counter = node_counter + 1;
    for i in start_prod_idx..end_prod_idx {
        let prod = prods[i];
        let parent_id = prod.parent;
		let child_L_id = prod.childL;
        let child_R_id = prod.childR;
        let parent = labels[parent_id];
        let left_child = labels[child_L_id];
        let mut right_child = 0;
        // First check for no cycles
        let mut parent_check = parent_id.lt(child_L_id);
        let mut count_check = child_L_id == node_counter;
        node_counter = node_counter + 1;
        if child_R_id == 0 {
            // This is the case where we are dealing with a NT --> T rule
            // Terminal check checks both that a leaf node is a terminal 
            // and in the string, since we assume the string is correctly composed of terminals.
            let terminal_check = (left_child == string[leaf_count]);
            leaf_count = leaf_count + 1;
            output = output * terminal_check;
        }
        else {
            // This and the other node counter check, above ensures that all child nodes
            // appear in exactly one production and that each non-root node
            // has a parent. 
            count_check = count_check * (child_R_id == node_counter);
            node_counter = node_counter + 1;
            right_child = labels[child_R_id];
            // Second check for no cycles
            parent_check = parent_check * (parent_id.lt(child_R_id));
        }
        
		let index = mem_proofs_prod[i].index;
		let path = mem_proofs_prod[i].hashpath;
        let rule = [parent as Field, left_child as Field, right_child as Field];
        // let rule_hash = std::hash::poseidon2::Poseidon2::hash(rule, 3);
        let rule_hash = std::hash::pedersen_hash(rule);
        let merkle_root = std::merkle::compute_merkle_root(rule_hash, index, path);
        // // This finally checks that the production is valid.
        let merkle_check = merkle_root == rules_com;

        // We need to ensure that exactly 2N-1 productions are made,
        // each with a unique parent node. 
        // The strictly increasing requirement ensures this. 
        let parent_increment_check = latest_parent.lt(parent_id);
        latest_parent = parent_id;
        output = output * parent_check * count_check * parent_increment_check * merkle_check;
    }
	// Checks that all child nodes are in the correct range.
    // Note that we already checked that the start node is 0.
    // And that all real nodes after that respect increments of 1.
    // let nodes_check = (node_counter == ((3*N - 1) as Field));
    // Check that we had the exactly right number of leaves.
    // let leaves_check = (leaf_count == (N as Field));
    // Check that parent nodes are within range upper bound.
    let parent_range_final_check = (latest_parent.lt((3*N - 1) as Field));
    output = output * parent_range_final_check;
    (leaf_count, output)
}




/************ MAIN FUNCTIONS BELOW HERE ****************/
/* Uncomment the function you want to benchmark and use the shell scripts in the noir-cfg directory */


// fn main(
//     string: [Field; N],
//     labels: [Field; 3*N - 1],
//     prods: [Production; 2*N - 1],
//     mem_proofs_prod: [MerkleProofProductions; 2*N - 1],
// 	rules_com: Field,
//     start_prod_idx: u32,
//     end_prod_idx: u32,
//     string_elt_count: Field,
//     previous_final_parent: Field,
// ) {
//     assert(parseTreeCheckerProds(string, labels, prods, mem_proofs_prod, rules_com, start_prod_idx, end_prod_idx, string_elt_count, previous_final_parent) == true);
// }

// #[recursive]
// fn main(
//     string: [Field; N],
//     labels: [Field; 3*N - 1],
//     prods: [Production; K],
//     mem_proofs_prod:[Field; K],
//     start_prod_idx: u32,
//     string_elt_count: Field,
//     previous_final_parent: Field,
// ) {
//     let (_, _, out_bit) = parseTreeCheckerProdsNaive(string, labels, prods, mem_proofs_prod, start_prod_idx, string_elt_count, previous_final_parent);
//     assert(out_bit == true);
// }

struct PubInputs {
    string: [Field; N],
    labels: [Field; 3*N - 1],
    prods: [Production; K],
    mem_proofs_prod:[Field; K],
    start_prod_idx: u32,
    string_elt_count: Field,
    previous_final_parent: Field,
}

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
    labels: [Field; 3*N - 1],
    prods: [Production; K - 1],
    mem_proofs_prod:[MerkleProofProductions; 1],
    prods_com: Field,
) -> pub (Field, Field) {

    let (node_counter, leaf_count, out_bit) = parseTreeCheckerProdsNaive2(string, labels, prods, mem_proofs_prod, prods_com);
    assert(out_bit == true);
    (node_counter, leaf_count)
   
}
// #[test]
// fn test_parse_tree_checker_prods_naive() {
//     let (latest_parent, pos, out_bit) = parseTreeCheckerProdsNaive([a, c, a, c], 
// 	[S, Ac, Ac, A, C, A, C, a, c, a, c], 
// 	[
//         Production::new(0, 1, 2),
//         Production::new(1, 3, 4),
//         Production::new(2, 5, 6),
//         Production::new(3, 7, 0),
//         Production::new(4, 8, 0),
//         Production::new(5, 9, 0),
//         Production::new(6, 10, 0),
//     ],
// 	[0, 2, 2, 3, 4, 3, 4],
//     0, 
//     0,
//     0);
    
//     assert(pos == (4 as Field));
//     assert(latest_parent == (6 as Field));
//     assert(out_bit == true);
// }