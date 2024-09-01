use light_poseidon::{Poseidon, PoseidonHasher, PoseidonBytesHasher, parameters::bn254_x5};
use ark_bn254::Fr;
use ark_ff::{BigInteger, PrimeField};
use hex;
mod test_file;


fn main() {
    println!("Hello, world!");


    let mut poseidon = Poseidon::<Fr>::new_circom(2).unwrap();

    let input1 = Fr::from_be_bytes_mod_order(&[1u8; 32]);
    let input2 = Fr::from_be_bytes_mod_order(&[0u8; 32]);

    let mut input_1 = [0u8; 4];
    input_1[3] = 1u8;

    // let hash = poseidon.hash(&[input1, input2]).unwrap();
    let hash = poseidon.hash_bytes_be(&[&input_1, &[0u8; 4]]).unwrap();
    
    let encoded_hash = hex::encode(hash);


    println!("Computed hash as bytes = {:?}", hash);

    let noir_hash_hex = "28bb28a2c7566e896a177dc7328d4298d197973bcac177fb8291984a1cc43b7f";
    let decoded_noir_hash = hex::decode(noir_hash_hex);
    println!("Decoded noir hash = {:?}", decoded_noir_hash);

    println!("Computed hash as hex = {}", encoded_hash);
    println!("Noir hash as hex = 0x{}", noir_hash_hex);

    let lib_test_str = test_file::poseidon_hash_bytes(1, 0);
    let lib_test_str_2 = test_file::poseidon_hash_bytes(2, 3);
    let lib_test_str_3 = poseidon.hash_bytes_be(&[&lib_test_str, &lib_test_str_2]).unwrap();
    let encoded_hash_4 = hex::encode(lib_test_str_3);
    println!("test fn outputs {}", encoded_hash_4);

    let lib_test_str_5 = test_file::poseidon_hash_bytes_4(1, 0, 2, 3);
    let encoded_hash_6 = hex::encode(lib_test_str_5);
    println!("Hashed 4 test = {}", encoded_hash_6);


    // Should print:
    // [
    //     13, 84, 225, 147, 143, 138, 140, 28, 125, 235, 94, 3, 85, 242, 99, 25, 32, 123, 132,
    //     254, 156, 162, 206, 27, 38, 231, 53, 200, 41, 130, 25, 144
    // ]
}

