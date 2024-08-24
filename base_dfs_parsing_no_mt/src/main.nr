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

global N = 128;
global K = 16;
global Log_Rules = 3;

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
) -> (Field, bool) {
    // FIXME: Right now, none of the checks ensure that 
    // the root node is in the set of start symbols.
    let mut output = true;
    let mut leaf_count = 0;
    let mut next_parent_index = 0;

    // let mut stack: Vec<(Field, Field)> = Vec::new();
    let mut stack: BoundedVec<(Field, Field), K> = BoundedVec::new();
    let root_node = prods[0].parent;
    stack.push((root_node.label, root_node.idx));

    for i in 0..K - 1 {
        print("Stack = ");
        print(stack);
        print("\n");
        let current_parent = stack.pop();

        print("Popped item = ");
        print(current_parent);
        print("\n");

        print("Stack after pop = ");
        print(stack);
        print("\n");

        let prod = prods[i];
        let parent = prod.parent;
        let left_child = prod.childL;
        let right_child = prod.childR;

        let parent_id = parent.idx;
		let child_L_id = left_child.idx;
        let child_R_id = right_child.idx;

        let correct_pop = (current_parent.0 == parent.label) * (current_parent.1 == parent_id);
        let counter_correctness = (parent_id == next_parent_index);
        output = output * correct_pop * counter_correctness;

        print("correct pop 1 = ");
        print((current_parent.0 == parent.label));
        print("\n");
        print(current_parent.0);
        print("\n");
        print(parent.label);
        print("\n");


        print("Correct pop 2 = ");
        print((current_parent.1 == parent_id));
        print("\n");
        print(current_parent.1);
        print("\n");
        print(parent.idx);
        print("\n");

        print("Counter correctness = ");
        print(counter_correctness);
        print("\n");


        output = output * ((parent_id + 1) == child_L_id);

        print("Parent id = child_id - 1 test = ");
        print((parent_id + 1 == child_L_id));
        print("\n");

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
            print("Right child pre-push = ");
            print(right_child.label);
            print(",");
            print(right_child.idx);
            print("\n");
            stack.push((right_child.label, right_child.idx));
            // stack.insert(stack.len(), (right_child.label, right_child.idx));
            print("Stack after one push = ");
            print(stack);
            print("\n");
            stack.push((left_child.label, left_child.idx));
            // stack.insert(stack.len(), (left_child.label, left_child.idx));
            print("Stack after second push = ");
            print(stack);
            print("\n");

            print("Right child");
            print(right_child);
            print("\n");
            print("Left child");
            print(left_child);
            print("\n");
            next_parent_index = child_L_id;
        }
        
        let rule = (parent.label as Field, left_child.label as Field, right_child.label as Field);
        // This finally checks that the production is valid.
        let prod_check = (rule == rules[mem_proofs_prod[i]]);
        
        output = output * prod_check;
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
    (leaf_count, output)
}






/************ MAIN FUNCTIONS BELOW HERE ****************/

#[recursive]
fn main(
    string: pub [Field; N],
    prods: [Production2; K - 1],
    mem_proofs_prod:[Field; K - 1],
    // prods_com: Field,
) -> pub Field {

    let (leaf_count, out_bit) = parseTreeCheckerProdsNaive2(string, prods, mem_proofs_prod);
    print("Leaf count = ");
    print(leaf_count);
    print("\n");
    print("Out bit = ");
    print(out_bit);
    print("\n");
    assert(out_bit == true);
    leaf_count
   
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

    let (leaf_count, out_bit) = parseTreeCheckerProdsNaive2([a, c, a, c], 
	prods,
	[0, 2, 3, 4, 2, 3, 4]);
    
    assert(leaf_count == (4 as Field));
    assert(out_bit == true);
}
*/