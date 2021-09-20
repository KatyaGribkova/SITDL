function out = AIMIE(s1,s2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   This function calculates the mutual information between the given input
%   and output spike time series of a neuron. 
%
%   Inputs:
%       s1 is the input spike data and it must be given in the form
%       of a one-dimensional vector consisting of sequential times at which input spikes occur.
%
%       s2 is the output spike data and it must be given in the form of a
%       one-dimensional vector of sequential times at which output spikes occur.
%
%       Note that the order of input variables s1 and s2 does not matter
%
%   Output: 
%
%       mutual information (bits) between s1 and s2
%
%   Note: Unlike typical calculation of mutual information, this version
%   uses an adaptive partition of the interspike interval durations of one time series 
%   and spike densities of the other
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                              
s1count = nnz(s1);          % counts number of spikes in spike time series s1 
s2count = nnz(s2);          % counts number of spikes in spike time series s2

if s1count>s2count          % whichever series has the greater number of spikes is designated as X
    x = s2;                     %the other is designated as Y         
    y = s1;
else
    x = s1;
    y = s2;
end

%------------------------------------------------------------------------------------
%       PROCESSING AND MARGINAL PROBABILITIES
%------------------------------------------------------------------------------------
%counting spikes:
lx = 1;                            % lx will be the number of spike events in the time series x
ly = 1;                            % ly will be the number of spike events in the time series y


if (all(x) == 1)                   % If all elements are nonzero (the array has no padding)
    lx = length(x);                   % we take the full length of the array
else
    while ( x(lx+1) ~= 0)              % otherwise, the number of spikes (lx) are counted until we hit the first zero  
    lx = lx + 1;
    end
end


if (all(y) == 1)                   % If all elements are nonzero (the array has no padding)
    ly = length(y);                   % we take the full length of the array
else
    while ( y(ly+1) ~= 0)              % otherwise, the number of spikes (ly) are counted until we hit the first zero  
    ly = ly + 1;
    end
end



%-----------------------------------
%   Constructing new time series:



nx = zeros(1,ly);                   % nx will be a time series of the spike densities of X occuring in each interspike interval of Y  
dy = zeros(1,ly);                   % dy will be a time series of the length(ms) of each interspike interval of Y



ci = 1;                             % ci is a counter that goes through all of the spikes of x
for j = 1:ly
    ncount = 0;
    while y(j)> x(ci) && ci < lx    % if the input spike falls into the current output interval, we add to the spike count for nx (for that output interval)
        ncount = ncount + 1;            % and move on to the next input spike until we are outside the current output interval 
        ci = ci + 1;
    end
    if j > 1                      % the very first output interval is counted as the duration(ms) between the first input spike and the first output spike
       interval = y(j) - y(j-1);        % so that we do not lose the spikes at the beginning of our input sample. For all other intervals, we use the    
    elseif  y(1)> x(1)                               % duration between subsequent output spikes. 
       interval = y(j) - x(j);
    else
        interval = y(j) - 0;
    end
    dy(j) = interval;               % dy is the time series of interspike interval durations of Y
    nx(j) =  ncount/interval;       % nx is the time series of spike densities of X (based on the 
                                        %interspike intervals of Y)
   
end



%---------------------------------------------------------------
%   Setting up bins of the adaptive partition:


occupancy = round(nthroot(ly,2));       % Minimum occupancy of the adaptive partition 
                                               %is chosen to be the square root of ly
xbinning = sort(nx);
ybinning = sort(dy);

xbins = zeros(1,1);
ybins = zeros(1,1);


bincount = 0;
cy = 1;

ybins(1) = ybinning(1);
xbins(1) = xbinning(1);
while cy < ly
    
    if cy <= ly - occupancy
        cy = cy + occupancy;           % establishes minimum occupancy
    else
        cy = ly;
    end
    bincount = bincount + 1;
    if bincount > 0 && cy < ly         % if neighboring bins share same values, they are merged 
        while (ybins(bincount) == ybinning(cy)||xbins(bincount) == xbinning(cy)) && cy < ly
            cy = cy + 1;
        end
    end
    
    ybins(bincount+1) = ybinning(cy);
    xbins(bincount+1) = xbinning(cy);
    

end
xnbins = bincount;
ynbins = bincount;

%---------------------------------------------------------------
%   Calculating marginal probabilities:


npx = zeros(1,bincount);               % initialize marginal probability for nx
npy = zeros(1,bincount);               % initialize marginal probability for dy


for i = 1:bincount    
    x1 = xbins(i);       % defines the upper and lower bounds of a partition
    x2 = xbins(i+1) ;
    
    y1 = ybins(i);       % defines the upper and lower bounds of a partition
    y2 = ybins(i+1) ;

    for j = 1:ly
        
        if (nx(j) >= x1) && (nx(j) < x2)
            npx(i) = npx(i) + 1;
        end
        
        if (dy(j) >= y1) && (dy(j) < y2)
            npy(i) = npy(i) + 1;
        end
        
    end
 

end

npxcount = sum(npx);
npycount = sum(npy);

npx = npx/npxcount;
npy = npy/npycount;



%------------------------------------------------------------------------------------
%       CALCULATING JOINT PROBABILITY
%------------------------------------------------------------------------------------


npxpy = zeros(xnbins, ynbins);

%mcount = 0;
for i = 1:xnbins
    
     x1 = xbins(i);       % defines the upper and lower bounds of a partition
     x2 = xbins(i+1);
      
            for j = 1:ynbins               
                
                y1 = ybins(j);       % defines the upper and lower bounds of a partition
                y2 = ybins(j+1) ;
                ncount = 0;
                   
                for k = 1:ly   
                                     % if both nx(k) and dy(k) fall into the bin at the same time, it counts towards the joint probability 
                    if (dy(k) >= y1) && (dy(k) < y2) && (nx(k) >= x1) && (nx(k) < x2)
                       ncount = ncount + 1;
                    end 

                    npxpy(i,j) = ncount;
                    
                end
            end
end  

mcount = sum(sum(npxpy));
npxpy = npxpy/mcount;





%------------------------------------------------------------------------------------
%       CALCULATING MUTUAL INFORMATION
%------------------------------------------------------------------------------------

I = 0;



for i= 1:xnbins
    for j= 1:ynbins
            if (npxpy(i,j) == 0 || npx(i) == 0 || npy(j) == 0)    % ensures that there are no zeroes in the denominator or zeroes under log2
                hh = 0;
            else
                hh = npxpy(i,j)*log2(npxpy(i,j)/(npx(i)*npy(j))); % sums of MI
            end
            I = I + hh;
    end
end

out = I;            %the resulting mutual information is output

end
