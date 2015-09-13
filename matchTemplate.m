%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2010, John T. Ramshur, jramshur@gmail.com
% 
% This file is part of ECG Viewer
%
% ECG Viewer is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% ECG Viewer is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with ECG Viewer.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [indices, rxy] = matchTemplate(signal,template, ...
    thPrimary,thSecond,optRefine,optSpeed)
% matchTemplate.m - detects qrs complexes by sliding a window across the
% input signal, and comparing each window with the template. If the
% correlation between template and window exceed the thPrimary then a qrs
% complex was detected. 
%   A double threshold is applied on rxy : It switches the output to a 
% high state when the input passes upward through a high threshold value 
% (thPrimary). It then prevents switching back to the other state until the input
% passes down through a lower threshold value (thSecond).
%
% <INPUTS>
%   s: input signal (vector)
%   template: template to match (vector)
%   thPrimary: primary threshold for detecting locations of 
%              matched templates (0-100%)
%   thSecond: secondary threshold for detecting locations of 
%             matched templates (0-100%)
%   optRefine: refine detected beat locations. (1=yes, 0=no)
%   optSpeed: options to speed up calculation of rxy. Available options are
%       0: default option, calculates correlation values for each sample
%          of signal. Computes rxy using the cov function.
%       1: only calculates correlation every di samples. Computes
%          rxy using the cov function.
%       2: only calculates correlation every di samples. Computes
%          rxy using a custom and compiled function.
%       3: parrallelized For loop. Computes rxy using a custom and 
%          compiled function.
%       4: parrallelized For loop, skipping to every di sample. Computes
%          rxy using a custom and compiled function.
%
% <OUTPUTS>
%   indices: locations of matched templates
%   rxy: series containg correlation coefs

    %check inputs
    if size(signal,1)<size(signal,2) %convert to vector
        signal=signal';
    end
    if size(signal,2)>1 %discard time column if present
        signal=signal(:,2);
    end
    if nargin < 5
        optRefine=0;
        optSpeed=0;
    end
    if nargin < 6
        optSpeed=0;
    end

%% Calculate Correlations

    lenS = size(signal,1);
    lenT = size(template,1);
    hw=(lenT-1)/2; %half width of template
    cw=hw+1; %points to center of template

    %subtract mean (for inline code use below)
    %template=template-avg(template);

    %calculate QRS detection signals e and e2
    rxy=zeros(lenS,1); %preallocate array    
    
    %OPTIONS FOR CALCULATING rxy ARRAY
    switch optSpeed
        case 1
        %computer corr every di sample (skipping). Use cov function.   
            di=3; %number of samples to skip ahead
            for i=cw:di:(lenS - hw)
                C=cov([signal(i-hw:i+hw),template]);
                rxy(i)=C(1,2)/sqrt(C(1,1)*C(2,2));
            end
            %since we skip values, we need to interpret any
            %missing corr. values
            ii=find(rxy~=0);
            rxy=interp1(ii,rxy(ii),1:length(rxy),'linear');
        case 2
        %skip di number of samples. Use custom function.    
            di=3;
            for i=cw:di:(lenS - hw)
                rxy(i)=crosscorr(signal(i-hw:i+hw),template);
            end
            ii=find(rxy~=0);
            rxy=interp1(ii,rxy(ii),1:length(rxy),'linear');
        case 3
        %parrallelized For loop. Use custom function.
            parfor i=cw:(lenS - hw);            
                rxy(i)=crosscorr(signal(i-hw:i+hw),template);
            end    
        case 4 
        %parrallelized For loop, skipping to every di sample. Use
        %custome function.
            di=3;
            parfor i=cw:(lenS - hw);
                if ~mod(i,di)
                    rxy(i)=crosscorr(signal(i-hw:i+hw),template);
                end    
            end    
            ii=find(rxy~=0);
            rxy=interp1(ii,rxy(ii),1:length(rxy),'linear');
        otherwise %default. Use cov function.
            for i=cw:(lenS - hw)
                C=cov([signal(i-hw:i+hw),template]);
                rxy(i)=C(1,2)/sqrt(C(1,1)*C(2,2));
            end
    end

%% Detect peaks
    
    %detect peaks in cross-correlation series
    indices=peakDetect(rxy,thPrimary,thSecond,10);

%% Refine locations
% Refines detected peaks against original signal. Make sure peaks are on the "true" peaks    
    if optRefine==1
        dx=10; %Number of samples to look before and after peak for "true" peak
        for i=1:length(indices)
            idx=indices(i);
            %find max value within +- dx of indices value
            tmp1=signal(idx);
            for i2=idx-dx:idx+dx
               tmp2=signal(i2);
               if tmp2>tmp1;
                  indices(i)=i2;
                  tmp1=tmp2;
               end
            end
            %in-line alternative to above. Didn't seem any faster.
%           i2=idx-dx:idx+dx;
%           adjustment = find(signal(i2)==max(signal(i2)))-(dx+1);            
%           indices(i)=indices(i)+adjustment(1); %make adjustment to indices value
        end
    end
    
    %% check for peaks that are close together...choose one with hightest rxy    
   optClose=0;
    if optClose
        
        bInd=true(length(indices),1); %logical array to hold which peaks to keep
        ibi=diff(indices);    
        bout = locateOutliers([],ibi,'sd',4);
        btmp = ibi<mean(ibi);
        bout = bout & btmp;
        
        d=diff(bout);
        
        b=find(d>0); b2=find(d<0);                                
        runLen=b2-b; %length of adjacent nan runs
        irun = find(runLen==2); %index of runs = 2
        if sum(irun)~=0 %if there are runs = 2            
            bInd(b(irun)+2)=false; %remove peak            
        end
        
        indices=indices(bInd);
        
        
%         minWin=0.5*mean(di); %mininum distance between peaks
%         i2=find(di<=minWin); %find peaks that are close together
%     
%     
%     b=false(length(indices),1); %logical array to hold which peaks to remove
%     i=1;
%     
%     %TODO: mod code to remove false detected beat....perhaps do this in the
%     %peakDetect fxn by using a min window till next beat.
%     
%     while i<=length(i2)-1 %loop through each set of close peaks
%         if (i2(i)-i2(i+1))==1 && (i2(i+1)-i2(i+2))==1 %&& i2(i)<=
%             b(i2(i)+1)=true;
%             i=i+3;
%         else
%             %determine which one has largest rxy value, reject the lesser one
%             if rxy(indices(i2(i))) >= rxy(indices(i2(i)+1))
%                 b(i2(i)+1)=true;
%             else
%                 b(i2(i))=true;
%             end
%             i=i+2;
%         end
%     end
    
    
    end
   
end