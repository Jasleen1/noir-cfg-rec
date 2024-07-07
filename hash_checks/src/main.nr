use dep::std::hash::poseidon;
use dep::std::hash::poseidon2;

global N=8;
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




fn main(leaf: Field, index: Field, hash_path: [Field; N]) -> pub Field {
    compute_merkle_root_poseiden(leaf, index, hash_path)
}

#[test]
fn test_main() {
    let arr = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21];
    let mut short_arr_slice = [].as_slice();
    for i in 0..N {
        short_arr_slice = short_arr_slice.push_back(arr[i]);
    }
    let short_arr = short_arr_slice.as_array();
    let out10 = main(1, 3, short_arr);
    print("merkle_prods[");
    print(N);
    print("]=");

    print("\"[[mem_proofs_prod]]\\n");
    print("hashpath=");
    print(short_arr);
    print("\\n index=3\\n\"");


    // Uncomment to make test fail
    // main(1, 1);
}
