function outliers=leslie_IBIfilt(ecg,ibi,thr,hWin)

    %% check inputs
    if nargin < 4
       error('Not enough input arguments')
       return;
    end        
    %check size of ecg
    [m,n]=size(ecg);
    if m<n 
        ecg=ecg'; %transpose to row vector...i like row vectors.
    end
    if (n>1)
        ecg=ecg(:,2); %discard time column. This will allow inputs of 1dim
    end    
    %check size of ibi
    [m,n]=size(ibi);
    if m<n
        ibi=ibi'; %transpose
    end
    if n==1
        error('IBI input array must be a 2dim array.')
        return;
    end
    
    %% Initialize Variables/settings    
    sampleRate=1000;
    nIbi=size(ibi,1);
    nEcg=size(ecg,1);
    
    %% set default for all ibi to "false". "false" means not an outlier
    outliers=false(nIbi,1);
    
    %% convert time to sample number
    beat=round((ibi(:,1)*sampleRate));    
        
    %% define window around ibi locations
    b1=beat-hWin;       %array that contains start of windows
    b2=beat+hWin;       %array that contains end of windows
    b1(b1<1)=1;         %make sure calculated start does not occur before sample 1
    b2(b2>nEcg)=nEcg;   %make sure calculated end does not occur beyond last sample
    
    %% Main Loop
    for f=1:nIbi
        if any(abs(ecg(b1(f):b2(f)))>thr) %if "any" ecg value beyond threshold
            outliers(f)=true; %mark as "true" outlier
        end         
    end

end