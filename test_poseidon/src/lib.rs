use light_poseidon::{Poseidon, PoseidonBytesHasher};
use ark_bn254::Fr;

use hex;
use pyo3::prelude::*;


#[pyfunction]
pub fn poseidon_hash(a: u32, b: u32) -> String {

    // Initialize the hasher 
    let mut poseidon = Poseidon::<Fr>::new_circom(2).unwrap();

    // Convert input to bytes 
    let a_bytes = a.to_be_bytes();
    let b_bytes = b.to_be_bytes();
    
    // Calculate the hash
    let hash = poseidon.hash_bytes_be(&[&a_bytes, &b_bytes]).unwrap();
    
    // This is the hexstring without "0x" at the front
    // let encoded_hash = hex::encode(hash);
    // let mut hex_prefix_str = "0x".to_owned();
    // hex_prefix_str = hex_prefix_str + &encoded_hash; 
    // hex_prefix_str
    hex::encode(hash)
}

#[pyfunction]
pub fn poseidon_hash_4(a: u32, b: u32, c: u32, d: u32) -> String {

    // Initialize the hasher 
    let mut poseidon = Poseidon::<Fr>::new_circom(4).unwrap();

    // Convert input to bytes 
    let a_bytes = a.to_be_bytes();
    let b_bytes = b.to_be_bytes();
    let c_bytes = c.to_be_bytes();
    let d_bytes = d.to_be_bytes();

    // Calculate the hash
    let hash = poseidon.hash_bytes_be(&[&a_bytes, &b_bytes, &c_bytes, &d_bytes]).unwrap();
    
    // This is the hexstring without "0x" at the front
    // let encoded_hash = hex::encode(hash);
    // let mut hex_prefix_str = "0x".to_owned();
    // hex_prefix_str = hex_prefix_str + &encoded_hash; 
    // hex_prefix_str
    hex::encode(hash)
}

#[pyfunction]
pub fn poseidon_hash_from_c_bytes(a: u32, b: u32, c_bytes: [u8; 32], d: u32) -> String {

    // Initialize the hasher 
    let mut poseidon = Poseidon::<Fr>::new_circom(4).unwrap();

    // // Convert input to bytes 
    let a_bytes = a.to_be_bytes();
    let b_bytes = b.to_be_bytes();
    // let c_bytes = c.to_be_bytes();
    let d_bytes = d.to_be_bytes();

    // Calculate the hash
    let hash = poseidon.hash_bytes_be(&[&a_bytes, &b_bytes, &c_bytes, &d_bytes]).unwrap();
    
    // This is the hexstring without "0x" at the front
    // let encoded_hash = hex::encode(hash);
    // Code to add 0x to the front
    // let mut hex_prefix_str = "0x".to_owned();
    // hex_prefix_str = hex_prefix_str + &encoded_hash; 
    // hex_prefix_str

    hex::encode(hash)
}


// This module is a Python module implemented in Rust
#[pymodule]
fn test_poseidon(_py: Python, m: &PyModule) -> PyResult<()> {
    // m.add_function(wrap_pyfunction!(poseidon_hash, m)?)?;
    m.add_function(wrap_pyfunction!(poseidon_hash_4, m)?)?;
    m.add_function(wrap_pyfunction!(poseidon_hash_from_c_bytes, m)?)?;
    Ok(())
}