import hashlib

# def sha_hash(inputs):
#     m = hashlib.sha256()
#     for i in range(len(inputs)):
#         # Calculate the number of bytes needed to represent the integer
#         num_bytes = (inputs[i].bit_length() + 7) // 8

#         # Convert to little-endian byte sequence
#         little_endian_bytes = inputs[i].to_bytes(num_bytes, byteorder='little')
#         for input_val in little_endian_bytes:
#             m.update(input_val)
#     return m.hexdigest()


def sha256_hash_of_integers(inputs):
    combined_bytes = b''
    for input_val in inputs: 
        # Convert the first integer to bytes (little-endian without specifying length)
        int_bytes = input_val.to_bytes((input_val.bit_length() + 7) // 8, byteorder='little')
       
        # Concatenate the byte sequences
        combined_bytes = combined_bytes + int_bytes
        
        # Compute the SHA-256 hash of the concatenated bytes
    sha256_hash = hashlib.sha256(combined_bytes).digest() #.hexdigest()
    # Convert the digest bytes to a list of base-10 integers
    base10_bytes = [int(b) for b in sha256_hash]
    
    return base10_bytes
    # return sha256_hash.digest()

   
# output_hash = sha_hash([1, 0])

# print(output_hash)

hash_result = sha256_hash_of_integers([1])
print("SHA-256 Hash:", hash_result)