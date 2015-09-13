%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function peaks=peakDetect(s,thPrimary,thSecond,skipWin)
% peakDetect.m - detects peaks within the input signal s. A double 
% threshold is applied to s : It switches the output to a 
% high state when the input passes upward through the high threshold value 
% (thPrimary). It then prevents switching back to low state until the input
% passes down through a lower threshold value (thSecond).
% <INPUTS>
%   s: input signal (vector)
%   thPrimary: primary threshold for detecting locations of matched templates (0-100%)
%   thSecond: secondary threshold for detecting locations of matched templates (0-100%)
%   skipWin: min number of samples to skip over once a peak is found
% <OUTPUTS>
%   indices: locations of peaks

    overPk = (s >= thPrimary); %logical array (1 or 0) of whether index is
                               %above or below thPrimary
    b=diff(overPk); % gives array of 0,1,or -1. passing above thr = 1, passing
                    % below thr = -1
    b(end)=0;       %make sure last sample is not a peak (cannot be a peak)                
    
    s1=find(b==1)+1; %find all samples/indexes passing above thresh       
    
    peaks=zeros(length(s1),1); %preallocate memory
    x=1;
    yy=zeros(length(s),1);
    for i=1:length(s1)-1
        %Skip to next peak if necessary.
        %  This is useful if more than one SUCCESSIVE small peak
        %  exist that didn't drop below the second threshold.
        if x<=s1(i)
            x=s1(i);
            %loop until we drop below second threshold
            while (s(x+1)>=thSecond)
                x=x+1;
                yy(x)=1;
            end
            
            %find location of peak value
            tmp=find(s((s1(i):x))==max(s(s1(i):x))) + s1(i)-1;
            tmp=tmp(1); %make sure there is only one peak
            peaks(i)=tmp;
            
%             if i>5
%                 skipWin=floor(0.4*mean(diff(peaks(i-5:i))));
%                 x=x+skipWin;
%             end
        end
    end

    %remove any empty indices
    empty=(peaks==0); %find locations of empty peaks
    peaks(empty)=[];  %delete elements that are empty

end