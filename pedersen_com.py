# import ecdsa
# from ecdsa import ellipticcurve, numbertheory
# from hashlib import sha256

# # Parameters for the secp256k1 curve
# curve = ecdsa.curves.SECP256k1.curve
# generator = ecdsa.curves.SECP256k1.generator
# order = generator.order()

# def pedersen_hash(inputs, blindings):
#     """
#     Compute the Pedersen hash of a set of inputs with associated blindings.
    
#     :param inputs: List of integer inputs.
#     :param blindings: List of integer blinding factors.
#     :return: The Pedersen hash as a point on the elliptic curve.
#     """
#     assert len(inputs) == len(blindings), "Inputs and blindings must be of the same length"

#     # Start with the identity element (point at infinity)
#     result_point = curve.infinity()

#     for input_val, blinding in zip(inputs, blindings):
#         # Convert input to a point on the curve by multiplying the generator by input
#         input_point = input_val * generator
#         blinding_point = blinding * generator

#         # Pedersen hash: sum of all input_points + blinding_points
#         result_point += input_point + blinding_point

#     return result_point

# # Example usage
# if __name__ == "__main__":
#     # Example inputs and blinding factors
#     inputs = [12345, 67890]
#     blindings = [98765, 43210]
    
#     # Calculate the Pedersen hash
#     hash_point = pedersen_hash(inputs, blindings)
    
#     # Print the resulting hash as a point on the curve
#     print(f"Pedersen Hash Point: (x={hash_point.x()}, y={hash_point.y()})")
#     print(f"Hash Point (compressed): {hash_point.x() % order}")


from ecdsa import SECP256k1

# Assuming GENS is a precomputed list of points on the elliptic curve
curve = SECP256k1.curve
generator = SECP256k1.generator

# Example GENS, normally these would be specific points precomputed for your application
GENS = [generator * i for i in range(1, 3)]  # Replace with actual precomputed points

def pedersen_hash(inputs):
    if len(inputs) > len(GENS):
        raise ValueError("Too many inputs for available generators")

    result_point = None  # Start with None to represent the point at infinity
    
    for i in range(len(inputs)):
        input_val = inputs[i]
        point = GENS[i] * input_val

        if result_point is None:
            result_point = point
        else:
            result_point += point

    return result_point.x()  # Return the x-coordinate of the resulting point

# Example usage
inputs = [1, 0]  # Replace with actual inputs as integers
hash_result = pedersen_hash(inputs)
print(f"Pedersen Hash Result: {hex(hash_result)}")
