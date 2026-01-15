## DEPORT: DisEase PrOgression Trajectory (DEPOT) approach for delineating trajecotry in EMR Data

### Overview

We develop the DisEase PrOgression Trajectory (DEPOT) approach to model CKD progression trajectories and individualize clinical decision support. The DEPOT is an evidence-driven, graph-based clinical informatics approach that addresses the unique challenges in longitudinal EHR data by systematically using the graph artificial intelligence (graph-AI) model for representation learning and the reverse graph embedding for trajectory reconstruction. Moreover, DEPOT includes a prediction model so that new patients can be assigned along the progression trajectory. 
This directory contains code necessary to run the DEPORT approach with Graph-AI model and DDRTree method for trajectory learning.
GraphAI model can be viewed as a stochastic generalization of graph convolutions, and it is especially useful for massive, dynamic graphs that contain rich feature information. DDRTree method is an effecitive and efficient emthod for leanring trajectory.

See our paper(XXX) for details on the DEPORT approach.

### Requirements

Recent versions of TensorFlow, numpy, scipy, sklearn, and networkx are required (but networkx must be <=1.11). You can install all the required packages using the following command:

	$ pip install -r requirements.txt

### Running the code

The R_step.R will produce the input folder for graphAI model. The learned representation will be used in DDRTree for trajectory analysis. 

#### Acknowledgements

The original version of this code base was originally forked from https://github.com/williamleif/GraphSAGE, and we owe many thanks to William Hamilton for making his code available.
