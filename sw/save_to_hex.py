import numpy as np

def to_hex_16bit(val):
    """Converts a signed integer to a 16-bit 2's complement hex string."""
    return f"{val & 0xFFFF:04X}"

def save_to_hex(data_array, filename):
    """Saves a numpy array as a flat .hex file."""
    # Flatten the array to a 1D list of values
    flat_data = data_array.flatten()
    
    with open(filename, 'w') as f:
        for val in flat_data:
            hex_val = to_hex_16bit(val)
            f.write(f"{hex_val}\n")
    print(f"Saved {len(flat_data)} values to {filename}")

if __name__ == "__main__":
    # --- Load the Quantized Data ---
    weights = np.load("mnist_npy/quantized_weights.npy")
    activations = np.load("mnist_npy/quantized_activations.npy")
    golden_out = np.load("mnist_npy/golden_output.npy")

    # --- Convert and Save ---
    save_to_hex(weights, "mnist_hex/weights.hex")
    save_to_hex(activations, "mnist_hex/activations.hex")
    save_to_hex(golden_out, "mnist_hex/golden_output.hex")