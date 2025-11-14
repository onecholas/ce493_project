# Floating Point Reference Model for MNIST

import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torchvision import datasets, transforms

# CNN Architecture

CONV1_OUT_BITS = 16

# Pytorch model
class Net(nn.Module):
    def __init__(self):
        # Pytorch model constructor
        super(Net, self).__init__()
        
        # 2D Convolutional Layer
        #   Input: 1x28x28 (one 28x28 MNIST Images)
        #   Output: 16x24x24 (sixteen 24x24 convolved outputs)
        self.conv1 = nn.Conv2d(in_channels=1, out_channels=CONV1_OUT_BITS, kernel_size=5, stride=1, padding=0) 
        
        # Max Pooling Layer
        #   Input: 16x24x24 
        #   Output: 16x12x12
        self.pool1 = nn.MaxPool2d(kernel_size=2, stride=2) 
        
        # 2D Convolutional Layer
        #   Input: 16x12x12
        #   Output: 32x10x10
        self.conv2 = nn.Conv2d(in_channels=CONV1_OUT_BITS, out_channels=32, kernel_size=3, stride=1, padding=0) 
        
        # Max Pooling Layer
        #   Input: 32x10x10
        #   Output: 32x5x5
        self.pool2 = nn.MaxPool2d(kernel_size=2, stride=2)
        
        # Fully Connected Layer
        #   Input: 32x5x5
        #   Output: 128 features
        self.fc1 = nn.Linear(32 * 5 * 5, 128)
        
        # Fully Connected Layer
        #   Input: 128 features
        #   Output: 10 classes
        self.fc2 = nn.Linear(128, 10)

    def forward(self, x):
        # Forward pass input to first convolutional layer
        x = self.conv1(x)
        # ReLU
        x = F.relu(x)
        # Max Pooling Layer
        x = self.pool1(x)
        
        # Forward pass input to second convolutional layer
        x = self.conv2(x)
        # ReLU
        x = F.relu(x)
        # Max Pooling Layer
        x = self.pool2(x)
        
        # Flatten output of previous layer
        x = x.view(-1, 32 * 5 * 5)
        # ReLU
        x = F.relu(self.fc1(x))
        # Output layer
        x = self.fc2(x)
        
        return F.log_softmax(x, dim=1)

if __name__ == "__main__":

    # Transform MNIST images to Pytorch Tensors
    transform=transforms.Compose([transforms.ToTensor()])
    # Load in MNIST training dataset
    dataset_train = datasets.MNIST('./mnist_train', train=True, download=True, transform=transform)
    # Load in MNIST testing dataset
    dataset_test = datasets.MNIST('./mnist_test', train=False, download=True, transform=transform)
    # Train the model on 64 images at a time with randomized order
    train_loader = torch.utils.data.DataLoader(dataset_train, batch_size=64, shuffle=True)
    # Test the model on 1000 images at a time
    test_loader = torch.utils.data.DataLoader(dataset_test, batch_size=1000, shuffle=False)

    # Instantiate Pytorch model
    model = Net()
    # Select Adam optimizer
    optimizer = optim.Adam(model.parameters(), lr=0.01)
    # Loss function
    criterion = nn.CrossEntropyLoss()
    # Number of full passes over the entire training dataset
    num_epochs = 3

    for epoch in range(num_epochs):
        for batch_idx, (data, target) in enumerate(train_loader):
            # Clear gradients from previous iteration
            optimizer.zero_grad()
            # Forward pass
            output = model(data)
            # Calculate loss
            loss = criterion(output, target)
            # Backpropagation
            loss.backward()
            # Use gradients to update parameters
            optimizer.step()
            # Logging
            if batch_idx % 100 == 0:
                print(f'Epoch {epoch} [{batch_idx * len(data)}/{len(train_loader.dataset)}] Loss: {loss.item():.6f}')

    # Set the model to evaluation mode
    model.eval()
    test_loss = 0
    correct = 0

    # Skip gradient calculations for inference
    with torch.no_grad():
        for data, target in test_loader:
            # Run inference
            output = model(data)
            # Sum the batch loss
            test_loss += criterion(output, target).item() 
            # Get the prediction
            pred = output.argmax(dim=1, keepdim=True)  
            # Compare the prediction to the actual label
            correct += pred.eq(target.view_as(pred)).sum().item()

    # Calculate average loss and accuracy
    test_loss /= len(test_loader.dataset)
    accuracy = 100. * correct / len(test_loader.dataset)

    # Logging
    print(f'\nTest set results:')
    print(f'Average loss: {test_loss:.4f}')
    print(f'Accuracy: {correct}/{len(test_loader.dataset)} ({accuracy:.2f}%)\n')

    # Save trained model
    torch.save(model.state_dict(), "mnist_cnn.pth")
    print("Trained model saved to mnist_cnn.pth")