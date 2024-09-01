use light_poseidon::{Poseidon, PoseidonHasher, PoseidonBytesHasher, parameters::bn254_x5};
use ark_bn254::Fr;
use ark_ff::{BigInteger, PrimeField};
use hex;
// use pyo3::prelude::*;

pub fn poseidon_hash_bytes(a: u32, b: u32) -> [u8; 32] {

    // Initialize the hasher 
    let mut poseidon = Poseidon::<Fr>::new_circom(2).unwrap();

    // Convert input to bytes 
    let a_bytes = a.to_be_bytes();
    let b_bytes = b.to_be_bytes();
    
    // Calculate the hash
    let hash = poseidon.hash_bytes_be(&[&a_bytes, &b_bytes]).unwrap();
    
    hash
}

pub fn poseidon_hash_bytes_4(a: u32, b: u32, c: u32, d: u32) -> [u8; 32] {

    // Initialize the hasher 
    let mut poseidon = Poseidon::<Fr>::new_circom(4).unwrap();

    // Convert input to bytes 
    let a_bytes = a.to_be_bytes();
    let b_bytes = b.to_be_bytes();
    let c_bytes = c.to_be_bytes();
    let d_bytes = d.to_be_bytes();

    // Calculate the hash
    let hash = poseidon.hash_bytes_be(&[&a_bytes, &b_bytes, &c_bytes, &d_bytes]).unwrap();
    
    hash
}

pub fn poseidon_hash_test(a: u32, b: u32) -> String {

    // Initialize the hasher 
    let mut poseidon = Poseidon::<Fr>::new_circom(2).unwrap();

    // Convert input to bytes 
    let a_bytes = a.to_be_bytes();
    let b_bytes = b.to_be_bytes();
    
    // Calculate the hash
    let hash = poseidon.hash_bytes_be(&[&a_bytes, &b_bytes]).unwrap();
    
    // This is the hexstring without "0x" at the front
    let encoded_hash = hex::encode(hash);
    let mut hex_prefix_str = "0x".to_owned();
    hex_prefix_str = hex_prefix_str + &encoded_hash; 
    hex_prefix_str
}

