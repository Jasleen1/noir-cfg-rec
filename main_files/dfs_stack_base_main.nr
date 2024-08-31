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

fn made_up_hash_fn(x: Node2, y: Field) -> Field {
    let x_sum = x.label + x.idx;
    let total = x_sum + y;
    // print("total = ");
    // print(total);
    // print("; out = ");
    // let output = ((total as u32) % 10) as Field;
    // print(output);
    // print("\n");
    ((total as u32) % 10) as Field
}

struct StackTuple {
    idx: Field,
    label: Field,
    hash_preimage: Field
}

impl StackTuple {
    fn new(idx: Field, label: Field, hash_preimage: Field) -> Self {
        StackTuple {
            idx: idx,
            label: label,
            hash_preimage: hash_preimage,
        }
    }

    fn print_tuple(self) {
        print("[[stack_expected_popped_vals]]\n");
        print("stack_expected_popped_vals.idx=");
        print(self.idx);
        print("\n");
        print("stack_expected_popped_vals.label=");
        print(self.label);
        print("\n");
        print("stack_expected_popped_vals.hash_preimage=");
        print(self.hash_preimage);
        print("\n");
    }
}

// Same as parseTreeChecker but takes in positions of productions, instead of edges. 
fn parseTreeCheckerProdsNaive2(
    string: pub [Field; N],
    // labels: [Field; 3*N - 1],
    prods: [Production2; K - 1],
    mem_proofs_prod: [Field; K-1],
    stack_expected_popped_vals: [StackTuple; K-1],
    // production_com: Field,
) -> (Field, Field, Field, Field, bool) {
    // FIXME: Right now, none of the checks ensure that 
    // the root node is in the set of start symbols.
    let mut output = true;
    let mut leaf_count = 0;
    let mut next_parent_index = 0;
    let mut stack_depth = 0;

    // let mut stack: Vec<(Field, Field)> = Vec::new();
    // let mut local_stack: BoundedVec<(Field, Field, Field), K> = BoundedVec::new();
    let root_node = prods[0].parent;
    // let mut running_hash = 0; 

    // local_stack.push((root_node.label, root_node.idx, running_hash));
    let mut running_hash = made_up_hash_fn(root_node, 0);
    stack_depth = stack_depth + 1;
    

    
    for i in 0..K - 1 {
        // let popped_item = local_stack.pop();
        stack_depth = stack_depth - 1;

        // let help_tuple = StackTuple::new(popped_item.1, popped_item.0, popped_item.2);
        // help_tuple.print_tuple();
        
        let help_tuple = stack_expected_popped_vals[i];
        let prod = prods[i];
        // print("\n****\nFrom input stack\n");
        // print(help_tuple);
        // print(",\n");

        // print("From local stack\n");
        // print(help_tuple);
        // print(",\n");
        
        
        let parent = prod.parent;
        let hash_preimage = help_tuple.hash_preimage;
        let stack_integrity = (made_up_hash_fn(parent, hash_preimage) == running_hash);
        // print("i = ");
        // print(i);
        // print("\nrunning hash = ");
        // print(running_hash);
        running_hash = hash_preimage;
        // let h = made_up_hash_fn(parent, hash_preimage);
        // print(" | hash computed = ");
        // print(h);
        // print("\n");
        // running_hash = hash_preimage;
        output = stack_integrity * output;


        let left_child = prod.childL;
        let right_child = prod.childR;

        let parent_id = parent.idx;
		let child_L_id = left_child.idx;
        let child_R_id = right_child.idx;

        let correct_pop = (help_tuple.label == parent.label) * (help_tuple.idx == parent_id);
        let counter_correctness = (parent_id == next_parent_index);
        output = output * correct_pop * counter_correctness;
        output = output * ((parent_id + 1) == child_L_id);

        
        
        

        
        


        if child_R_id == 0 {
            // This is the case where we are dealing with a NT --> T rule
            // Terminal check checks both that a leaf node is a terminal 
            // and in the string, since we assume the string is correctly composed of terminals.
            let terminal_check = (left_child.label == string[leaf_count]);
            next_parent_index = child_L_id + 1;
            leaf_count = leaf_count + 1;
            output = output * terminal_check;
        }
        else {
            // This and the other node counter check, above ensures that all child nodes
            // appear in exactly one production and that each non-root node
            // has a parent. 
            // local_stack.push((right_child.label, right_child.idx, running_hash));

            
            
            
            // print("\nPushed item = ");
            print(running_hash);
            stack_depth = stack_depth + 1;
            running_hash = made_up_hash_fn(right_child, running_hash);
            // print("\nRunning hash 1=");
            // print(running_hash);
            // print("\n");
            // stack.insert(stack.len(), (right_child.label, right_child.idx));
            // local_stack.push((left_child.label, left_child.idx, running_hash));
            // print("Pushed item = ");
            // print((left_child.label, left_child.idx, running_hash));
            running_hash = made_up_hash_fn(left_child, running_hash);
            // print("\nRunning hash 2=");
            // print(running_hash);
            // print("\n");
            stack_depth = stack_depth + 1;
            // stack.insert(stack.len(), (left_child.label, left_child.idx));
            next_parent_index = child_L_id;
        }
        
        let rule = (parent.label as Field, left_child.label as Field, right_child.label as Field);
        // This finally checks that the production is valid.
        let prod_check = (rule == rules[mem_proofs_prod[i]]);
        
        output = output * prod_check;

        // print("\nLeaf count = ");
        // print(leaf_count);
        // print("\nStack depth = ");
        // print(stack_depth);
        // print("\nRunning hash");
        // print(running_hash);
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
    
    (next_parent_index, leaf_count, running_hash, stack_depth, output)
}






/************ MAIN FUNCTIONS BELOW HERE ****************/

#[recursive]
fn main(
    string: pub [Field; N],
    prods: [Production2; K - 1],
    mem_proofs_prod:[Field; K - 1],
    stack_expected_popped_vals: [StackTuple; K - 1]
    // prods_com: Field,
) -> pub (Field, Field, Field, Field) {

    let (next_parent_index, leaf_count, running_hash, stack_depth, out_bit) = parseTreeCheckerProdsNaive2(string, prods, mem_proofs_prod, stack_expected_popped_vals);
    assert(out_bit == true);
    (next_parent_index, leaf_count, running_hash, stack_depth)
   
}


/*
Commenting since this test is for fixed N and K params


#[test]
fn test_parse_tree_checker_prods_naive() {
    let base_prod = Production2{
        parent: Node2::new(S, 0),
        childL: Node2::new(Ac, 1),
        childR: Node2::new(Ac, 6),
    };
    let mut prods = [base_prod; 7];

    /// Put in the parts of the DFS tree
    prods[1] = Production2{
        parent: Node2::new(Ac, 1),
        childL: Node2::new(A, 2),
        childR: Node2::new(C, 4),
    };

    prods[2] = Production2{
        parent: Node2::new(A, 2),
        childL: Node2::new(a, 3),
        childR: Node2::new(0, 0),
    };

    prods[3] = Production2{
        parent: Node2::new(C, 4),
        childL: Node2::new(c, 5),
        childR: Node2::new(0, 0),
    };

    prods[4] = Production2{
        parent: Node2::new(Ac, 6),
        childL: Node2::new(A, 7),
        childR: Node2::new(C, 9),
    };

    prods[5] = Production2{
        parent: Node2::new(A, 7),
        childL: Node2::new(a, 8),
        childR: Node2::new(0, 0),
    };

    prods[6] = Production2{
        parent: Node2::new(C, 9),
        childL: Node2::new(c, 10),
        childR: Node2::new(0, 0),
    };

    let stack_expected_popped_vals = [StackTuple { idx: 0x00, label: 0x01, hash_preimage: 0x00 },
            StackTuple { idx: 0x01, label: 0x02, hash_preimage: 0x08 },
            StackTuple { idx: 0x02, label: 0x03, hash_preimage: 0x06 },
            StackTuple { idx: 0x04, label: 0x04, hash_preimage: 0x08 },
            StackTuple { idx: 0x06, label: 0x02, hash_preimage: 0x00 },
            StackTuple { idx: 0x07, label: 0x03, hash_preimage: 0x03 },
            StackTuple { idx: 0x09, label: 0x04, hash_preimage: 0x00 }];
    let (next_parent_index, leaf_count, _, _, out_bit) = parseTreeCheckerProdsNaive2([a, c, a, c], 
	prods,
	[0, 2, 3, 4, 2, 3, 4],
    stack_expected_popped_vals);
    assert(next_parent_index == (11 as Field));
    assert(leaf_count == (4 as Field));
    assert(out_bit == true);
}
*/