# -*- coding: utf-8 -*-
"""
Created on Tue Nov 12 11:55:14 2019

@author: Katya Gribkova

Example of single-synapse SITDL simulations, with output plotted.
"""
import openpyxl
import xlsxwriter
import os
import inspect
src_file_path = inspect.getfile(lambda: None)
os.path.join(src_file_path)

import math as mth
import random 
import numpy
import matplotlib.pyplot as plt  
from SITDL_Functions import saveLists, readList, generateSignals, generateRecallSpike, shiftSignal, combinedSaveIndeces,\
                                SITDL, plotSITDLOutput, SITDL_TauLoop, generateInitialTaus, \
                                SITDL_MultiSynapseMemory_Learn, SITDL_MultiSynapseMemory_SynElimination, SITDL_MultiSynapseMemory_Recall, \
                                extractSpikeTimes, normalize, calculateDerivatives
                              
#**************INITIALIZATION************************************************

# constants used for all subsequent function calls
t=0.01                                                  # integration time step (ms)
dts=0.05                                               # tau_glu time step
intervals_list = [30, 66, 48, 72, 90, 54]               # determines repeated sequence of inter-spike intervals
I0 = 0.01                                                 # DC current
a = 3.9                                                  # constant, determines contribution of dendritic signal to voltage
b = 0.4                                                 # constant, determines contribution of synaptic current to voltage

# %%
#************* SITDL Simulation *************************
num_pts=1000000
tau_den = 15               #dendritic delay, based on distance between synapses
tau_glu = 5           #starting synaptic time constant for NMDAR glutamate gate activation

[tg, f, f2]  = generateSignals(num_pts, t, intervals_list, 1, 30., 10., False, False)       # signal generation  
data = SITDL(tau_den, tau_glu, f, f2, num_pts, t, dts, I0, a, b, False, 2, '', '', [])
title = "SITDL, without Stabilization" + " for initial Tau Den = " + str(round(tau_den,1)) + ", Tau Glu = " + str(round(tau_glu,1))
plotSITDLOutput(data,0,7,5,title) #Plots: "Denritic signal", "Glutamate signal", "gGlu", "gV", "g", "Tau Glu", "Glu and V gate conductance mismatch", "P"

# %%

#************* SITDL Simulation with Stabilization ************************* (runs longer)
num_pts=40000000
tau_den = 15               #dendritic delay, based on distance between synapses
tau_glu = 5           #starting synaptic time constant for NMDAR glutamate gate activation

[tg, f, f2]  = generateSignals(num_pts, t, intervals_list, 1, 30., 10., False, False)       # signal generation  
data = SITDL(tau_den, tau_glu, f, f2, num_pts, t, dts, I0, a, b, True, 1000, '', '', [])
title = "SITDL, with Stabilization" + " for initial Tau Den = " + str(round(tau_den,1)) + ", Tau Glu = " + str(round(tau_glu,1))
plotSITDLOutput(data, 5, 7, 5, title)

