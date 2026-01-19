# Example usage of prepare_graphAI_data function
# This script demonstrates how to use the fixed R_step.R function

# Load the function
source("R_step.R")

# Example data - replace with your actual data
# lab: original labels (matrix/data.frame)
# new.lab: processed labels (matrix/data.frame) 
# feats: feature matrix
# adjs: adjacency matrix (2 columns for edges)
# data.age: age information matrix

# Create dummy data for demonstration
n_samples <- 100
n_features <- 50

# Dummy labels (binary classification)
lab <- matrix(sample(0:1, n_samples, replace = TRUE), ncol = 1)
new.lab <- lab  # In this case, they're the same

# Dummy features
feats <- matrix(rnorm(n_samples * n_features), nrow = n_samples, ncol = n_features)

# Dummy adjacency (random edges)
n_edges <- 200
adjs <- matrix(sample(1:n_samples, n_edges * 2, replace = TRUE), ncol = 2)

# Dummy age data
data.age <- matrix(sample(18:80, n_samples, replace = TRUE), ncol = 1)

# Run the data preparation
prepare_graphAI_data(lab, new.lab, feats, adjs, data.age)

# After running, you can:
# 1. cd to graphAI directory
# 2. Run: python -m train.py
# 3. Use the generated embeddings with DDRTree
# embedding <- np.load("graphAI/val_value.npy")
# result <- run_DDRTree(embedding)
