import numpy as np
from model_q import FRAC_BITS, INT_BITS, TOTAL_BITS, Q_MIN, Q_MAX, SCALE
from model_fp import CONV1_OUT_BITS

# Accumulator bits
ACC_BITS = 40

# 40-bit Accumulator Min/Max
ACC_MIN = -2**(ACC_BITS-1)
ACC_MAX = 2**(ACC_BITS-1) - 1

# Convolution Layer Output Min/Max
OUT_MIN = -2**(CONV1_OUT_BITS-1)
OUT_MAX = 2**(CONV1_OUT_BITS-1) - 1

# Multiply-Accumulate
def quantized_mac(acc, act_q, w_q):
    # 16b * 16b -> 32b product  
    product = int(act_q) * int(w_q) 
    
    # 40b + 32b -> 40b accumulation
    acc = int(acc) + product

    # Ensure that the accumulator value does not exceed the maximum
    acc = np.clip(acc, ACC_MIN, ACC_MAX)
    
    return acc

def finalize_pixel(acc):
    # Scale down 32b product to 16b
    final_val = acc >> FRAC_BITS 
    
    # 2. Saturate to 16-bit output
    final_val = np.clip(final_val, OUT_MIN, OUT_MAX)
    
    return int(final_val)

if __name__ == "__main__":

    # Load Quantized Weights (16, 1, 5, 5)
    w = np.load("./mnist_npy/quantized_weights.npy")
    # Load Quantized Activations (1, 1, 28, 28)
    a = np.load("./mnist_npy/quantized_activations.npy")

    # Get activation and weight shapes
    (N, C_in, H_in, W_in) = a.shape
    (K, C_in_k, KH, KW) = w.shape
    
    # Ensure that they are the correct shape
    assert C_in == C_in_k, "Input channels don't match"

    # Calculate output dimensions
    H_out = H_in - KH + 1  # 28 - 5 + 1 = 24
    W_out = W_in - KW + 1  # 28 - 5 + 1 = 24
    golden_output = np.zeros((N, K, H_out, W_out), dtype=np.int64)

    # Standard convolution loops
    
    # Iterate over all input channels (1)
    for n in range(N):
        # Iterate over all filters (16)
        for k in range(K):
            # Iterate over all Y coordinates (24)
            for y in range(H_out):
                # Iterate over all X coordinates (24)
                for x in range(W_out):
                    
                    # 40-bit accumulator for each output pixel
                    acc = 0 
                    if y == 3 and x == 6:
                        print(f"y: {y}, x: {x}")
                    
                    # Iterate overall input channels (1)
                    for c in range(C_in):
                        # Iterate over all Y coordinates (5)
                        for ky in range(KH):
                            # Iterate over all X coordinates (5)
                            for kx in range(KW):
                                
                                # Get the quantized integer values
                                act_val = a[n, c, y + ky, x + kx]
                                w_val = w[k, c, ky, kx]
                                
                                # Perform multiply-accumulate
                                acc = quantized_mac(acc, act_val, w_val)
                                if y == 3 and x == 6:
                                    print(f"act_val: {act_val}, w_val: {w_val}")
                                    print(f"acc: {acc}")
                                    
                            acc = finalize_pixel(acc) << FRAC_BITS
                    
                    # Finalize the pixel (scale, truncate, saturate)
                    golden_output[n, k, y, x] = acc >> FRAC_BITS
                    if y == 3 and x == 6:
                        print(f"pixel: {golden_output[n, k, y, x]}")

    # Save golden output
    np.save("mnist_npy/golden_output.npy", golden_output)
    print("Golden output calculated and saved to golden_output.npy")