# Synaptic Input Time Difference Learning (SITDL) model

**SITDL** mechanisms allow a synapse to learn the time difference between glutamate and voltage signals through activity-dependent changes in NMDA receptor expression. In a neuron with redundant silent synapses, SITDL mechanisms, along with synaptic elimination and maturation, enable the neuron to learn and reconstruct its original glutamate signal.

Note, Python code files for SITDL should be placed inside the same directory. For an example SITDL simulation that shows how a synapse's NMDA receptor dynamics change in response to glutamate and voltage signals, run SITDL_Example.py. All other Python code files, besides SITDL_Functions.py, are used for Excel data generation. The MATLAB code files are used for mutual information estimates (see https://github.com/KatyaGribkova/AIMIE for more detail).

**CAUTION**: Running the Python codes for Excel data generation may take up a significant amount of memory.

For more details please see our publication:
> Gribkova, E. D., & Gillette, R. (2021). Role of NMDAR plasticity in a computational model of synaptic memory. _Scientific reports_, 11(1), 1-16. https://doi.org/10.1038/s41598-021-00516-y.
