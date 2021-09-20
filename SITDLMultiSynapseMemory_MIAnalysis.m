%SITDL MultiSynapseMemory Data Analysis
clear all

filename = 'SITDLwithP MultiSynapseMemory syn12,thresh1.002 DATA.xlsx';
SpikeTimeData = readtable(filename, 'Sheet', 'SpikeTimes');
SignalOriginal = SpikeTimeData{:,1}(~isnan(SpikeTimeData{:,1}));
SignalRecall_wL_step8 = SpikeTimeData{:,3}(~isnan(SpikeTimeData{:,3}));

filename = 'SITDLwithP MultiSynapseMemory syn49,thresh1.0215 DATA.xlsx';
SpikeTimeData = readtable(filename, 'Sheet', 'SpikeTimes');
SignalRecall_wL_step2 = SpikeTimeData{:,3}(~isnan(SpikeTimeData{:,3}));

filename = 'woutSITDL MultiSynapseMemory syn12,thresh1.002 DATA.xlsx';
SpikeTimeData = readtable(filename, 'Sheet', 'SpikeTimes');
SignalRecall_nL_step4 = SpikeTimeData{:,3}(~isnan(SpikeTimeData{:,3}));

filename = 'woutSITDL MultiSynapseMemory syn49,thresh1.0215 DATA.xlsx';
SpikeTimeData = readtable(filename, 'Sheet', 'SpikeTimes');
SignalRecall_nL_step2 = SpikeTimeData{:,3}(~isnan(SpikeTimeData{:,3}));

num_repeats = 1400;
period = SignalOriginal(6) - SignalOriginal(1);
SignalPart = SignalOriginal(1:5);
endtime = SignalOriginal(6) * num_repeats;
SOR = repeatSignal(SignalPart, period, endtime);

SRR_wL_step8 = repeatSignal(SignalRecall_wL_step8, period, endtime);
SRR_wL_step2 = repeatSignal(SignalRecall_wL_step2, period, endtime);
SRR_nL_step8 = repeatSignal(SignalRecall_nL_step4, period, endtime);
SRR_nL_step2 = repeatSignal(SignalRecall_nL_step2, period, endtime);

SITDL_step8_MI = AIMIE(SOR,SRR_wL_step8);%/size(SRR_wL_step8,1);
SITDL_step2_MI = AIMIE(SOR,SRR_wL_step2);%/size(SRR_wL_step2,1);
Control_step8_MI = AIMIE(SOR,SRR_nL_step8);%/size(SRR_nL_step8,1);
Control_step2_MI = AIMIE(SOR,SRR_nL_step2);%/size(SRR_nL_step2,1);

save('SITDLMultiSynapseMemory_MIAnalysis.mat', 'SITDL_step8_MI', 'SITDL_step2_MI', 'Control_step8_MI', 'Control_step2_MI')

function SignalPop = repeatSignal(SignalPart, period, endtime)
    partnum_pts = size(SignalPart, 1);
    SignalPop = [];
    repeat_count = -1;
    i = 1;
    spiketime = 0;
    while spiketime < endtime
        ind = mod(i,partnum_pts);
        if ind == 0
            ind = partnum_pts;
        end
        if ind == 1
            repeat_count = repeat_count + 1;
        end
        i  = i + 1;
        spiketime = SignalPart(ind) + repeat_count*period;
        if spiketime < endtime
            SignalPop = [SignalPop; spiketime];
        end
    end
end

 