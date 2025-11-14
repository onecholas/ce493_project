import torch
import numpy as np
from torchvision import datasets, transforms
from model_fp import Net, CONV1_OUT_BITS
import os

# Quantization parameters
FRAC_BITS = 14
INT_BITS = 2
TOTAL_BITS = INT_BITS + FRAC_BITS
Q_MIN = -2**(TOTAL_BITS-1)
Q_MAX = 2**(TOTAL_BITS-1) - 1
SCALE = 2**FRAC_BITS

# Convert floating point values to fixed point
def float_to_fixed(f_val):
    # Scale floating point value
    scaled_val = f_val * SCALE
    # Round to nearest integer
    rounded_val = np.round(scaled_val)
    # Saturate value
    clipped_val = np.clip(rounded_val, Q_MIN, Q_MAX)
    return int(clipped_val)

if __name__ == "__main__":

    # Load the model in evaluation mode
    model = Net()
    model.load_state_dict(torch.load("mnist_cnn.pth"))
    model.eval()

    # Extract float32 weights from the first convolutional layer
    fp32_weights = model.conv1.weight.data.detach().numpy()
    
    print(f"\n--- Pre-Quantization Analysis ---")
    print(f"FP32 Weight Range: Min={np.min(fp32_weights):.4f}, Max={np.max(fp32_weights):.4f}")
    print(f"Q{INT_BITS}.{FRAC_BITS} Range: Min={Q_MIN/SCALE}, Max={Q_MAX/SCALE}")
    print(f"---------------------------------\n")

    # Quantize all weights
    quantize_v = np.vectorize(float_to_fixed)
    quantized_weights = quantize_v(fp32_weights)
    print(f"Quantized weights shape: {quantized_weights.shape}")
    
    # Get sample activations
    transform = transforms.Compose([transforms.ToTensor()])
    # Get test dataset
    test_dataset = datasets.MNIST('./mnist_test', train=False, transform=transform)
    # Get first test image
    fp32_input_image, _ = test_dataset[0]
    fp32_input_image = fp32_input_image.unsqueeze(0)
    
    # Quantize the input activations
    quantized_activations = quantize_v(fp32_input_image.numpy())
    print(f"Quantized activations shape: {quantized_activations.shape}")

    # Save weights
    os.makedirs("./mnist_npy", exist_ok=True)
    np.save("./mnist_npy/quantized_weights.npy", quantized_weights)
    np.save("./mnist_npy/quantized_activations.npy", quantized_activations)
    print("Quantized weights and activations saved as .npy files.")