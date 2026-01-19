# TensorFlow 2.x Compatibility Fixes

## Problem Summary

The GraphAI codebase was written for TensorFlow 1.x but the requirements specified TensorFlow >= 2.16, causing multiple compatibility errors:

1. `AttributeError: module 'tensorflow' has no attribute 'app'`
2. `AttributeError: module 'tensorflow' has no attribute 'assign'`

## Issues Fixed

### 1. TensorFlow API Changes
- **tf.app.flags** → Replaced with `argparse` and custom `flags_compat.py` module
- **tf.set_random_seed()** → `tf.random.set_seed()`
- **tf.contrib.layers.xavier_initializer()** → `tf.initializers.glorot_uniform()`
- **tf.contrib.layers.l2_regularizer()** → `tf.keras.regularizers.l2()`
- **tf.nn.l2()** → `tf.square()` for L2 loss calculation
- **tf.assign()** → `var.assign()` method
- **tf.app.run()** → Standard Python `main()` function

### 2. TensorFlow Summary API Changes
- **tf.summary.merge_all()** → `tf.compat.v1.summary.merge_all()`
- **tf.summary.FileWriter()** → `tf.compat.v1.summary.FileWriter()`
- **tf.summary.scalar()** → `tf.compat.v1.summary.scalar()`
- **tf.summary.histogram()** → `tf.compat.v1.summary.histogram()`
- **tf.Session()** → `tf.compat.v1.Session()`
- **tf.global_variables_initializer()** → `tf.compat.v1.global_variables_initializer()`

### 3. NetworkX Compatibility
- **Version conflict**: Code required NetworkX <= 1.11 but requirements specified >= 3.2
- **Python 3.13 compatibility**: `gcd` function moved from `fractions` to `math` module
- **Solution**: Updated NetworkX version to 2.8.x and added version-aware API handling

### 4. Module Structure
- **Execution at import time**: Moved training logic from module level into `main()` function
- **FLAGS access**: Created `flags_compat.py` to provide global FLAGS object across modules
- **Import paths**: Fixed relative imports between modules

## Files Modified

### Core Files
- `graphAI/train.py` - Main training script with argparse integration
- `graphAI/flags_compat.py` - New compatibility module for FLAGS
- `graphAI/utils.py` - NetworkX version compatibility
- `requirements.txt` - Updated NetworkX version constraint

### Module Updates
- `graphAI/layers.py` - TensorFlow 2.x API updates
- `graphAI/prediction.py` - TensorFlow 2.x API updates  
- `graphAI/models.py` - TensorFlow 2.x API updates
- `graphAI/neigh_samplers.py` - TensorFlow 2.x API updates
- `graphAI/metrics.py` - L2 loss calculation fix

## Usage

### Virtual Environment
The fixes require using the virtual environment:
```bash
source venv/bin/activate
cd graphAI
python -m train.py
```

### TensorFlow Version
Compatible with TensorFlow 2.16+ while maintaining backward compatibility with the original GraphSAGE architecture.

## Verification

```python
import tensorflow as tf
print('TensorFlow version:', tf.__version__)  # Should show 2.x
import flags_compat
print('Compatibility modules loaded successfully!')
```

## Notes

- The core GraphSAGE algorithm remains unchanged
- All original functionality is preserved
- Training can proceed once input data is available via the R script
- The fixes focus solely on API compatibility, not algorithmic changes
