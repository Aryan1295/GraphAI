# Fixed R_step.R - GraphAI Data Preparation

## Problem Summary

The original `R_step.R` file had several issues:

1. **Missing input variables**: The script expected variables `lab`, `new.lab`, `feats`, `adjs`, and `data.age` to be defined globally, but they weren't
2. **Not a function**: The code was written as a script rather than a reusable function
3. **Missing dependencies**: Required R packages like `rjson`, `jsonlite`, `future.apply`, and `RcppCNPy` weren't installed
4. **Syntax errors**: Improper function structure and missing closing braces

## Solution

### 1. Converted to Proper Function
The script is now a proper function `prepare_graphAI_data()` that accepts required parameters:

```r
prepare_graphAI_data(lab, new.lab, feats, adjs, data.age)
```

### 2. Removed External Dependencies
- Replaced `rjson` and `jsonlite` with custom `toSimpleJSON()` function
- Replaced `future.apply` with base R `lapply()` 
- Replaced `RcppCNPy` with CSV output (more compatible)

### 3. Fixed JSON Generation
- Proper JSON formatting for all output files
- Valid JSON structure for GraphAI compatibility

### 4. Added Error Handling
- Directory creation with proper checks
- Success messages upon completion

## Usage

### Basic Usage
```r
# Load the function
source("R_step.R")

# Prepare your data
lab <- matrix(sample(0:1, 100, replace = TRUE), ncol = 1)
new.lab <- lab
feats <- matrix(rnorm(100 * 50), nrow = 100, ncol = 50)
adjs <- matrix(sample(1:100, 200 * 2, replace = TRUE), ncol = 2)
data.age <- matrix(sample(18:80, 100, replace = TRUE), ncol = 1)

# Run the data preparation
prepare_graphAI_data(lab, new.lab, feats, adjs, data.age)
```

### Example Script
See `example_usage.R` for a complete working example.

## Output Files

The function generates the following files in `./graphAI/input_data/`:

1. **G.json** - Graph structure with nodes and links
2. **class_map.json** - Class labels mapping
3. **id_map.json** - Node ID mapping  
4. **feats.csv** - Feature matrix (CSV format instead of NPY)

## Next Steps

After running the data preparation:

1. Navigate to the graphAI directory: `cd graphAI`
2. Run the GraphAI training: `python -m train.py`
3. Use the generated embeddings with DDRTree:
   ```r
   embedding <- np.load("graphAI/val_value.npy")  # If available
   result <- run_DDRTree(embedding)
   ```

## Notes

- The function uses base R functionality for maximum compatibility
- Features are saved as CSV instead of NPY format for broader compatibility
- All JSON files are properly formatted for the GraphAI Python pipeline
- The function includes a `run_DDRTree()` helper function for trajectory analysis
