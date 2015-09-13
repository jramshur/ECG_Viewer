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

function template=makeTemplate(s,indices,tWidth)
% makeTemplate: create a .mat file containing a template for use in
% template matching algorithms
% <INPUTS>
%   s: 1-dimension input signal vector
%   indices: locations in the input signal for the center of 
%            template waveforms to use. (sample number) 
%   tWidth: total width of template (samples)
% <OUTPUTS>
%   template: a template of tWidth samples wide and created from 
%             averaging all waveforms listed in the indices array. 
%
% Usage: templ=makeTemplate(inputECG,beatLocations,161)

%check inputs
if nargin<3
    error('Too few input arguments.')
end
if length(s)<tWidth
    error('template width cannot be greater than the input signal length');
    return
end
if ~mod(tWidth,2)
    error('template width must be an odd number');
    return
end
if (indices(1)-(tWidth-1)/2)<1 || ((indices(end)+(tWidth-1)/2)>length(s))
    error('template width cannot extend past input signal boundaries');
    return
end

%preallocate array
template=zeros(tWidth,length(indices));
%add templates
for i=1:length(indices)    
    tmp=s(indices(i)-(tWidth-1)/2:indices(i)+(tWidth-1)/2);
    template(:,i)=tmp;
end
%avgerage all templates together
template=mean(template,2);
%remove any dc offset
%template=template-mean(template);
end