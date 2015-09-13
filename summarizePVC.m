function output=summarizeECG2()
%summarizeECG.m - sumarizes an entire directory of .mat files converted
%from ART ascii files. Summaries are broken into segments of x seconds long
%and include filenames, date/time, mean,max,min IBI, mean,max,min HR, 
%number of NaN's, number of outlers.
%

%% Set Parameters/Options
sampleRate=1000;
%ECG filtering option 
optFilt='basic'; %filter type ('basic'=basic filter, 'wavelet'=wavlet filter)

%beat detection options
upThresh = 0.4; %upper threshold
lowThresh = 0.35; %lower threshold
optTemplate='global'; %type of template ('global'=global template, 'self'=self template)

%% Get dir/folder paths
tmp=what; % get curent dir
inPath=uigetdir(tmp.path,'Choose folder containing ECG data.');
if inPath == 0
    error('Please choose an input dir!')
    return
end
outPath=uiputfile({'*.xlsx','Excel File (.xlsx)'}, ...
    'Choose file for exported results.',fullfile(inPath,'PVCsummary.xlsx'));
if outPath == 0
    error('Please choose an output file!')
    return
end

%% Load template: Global template option
[fName,pName]=uigetfile({'*.mat','Matlab Binary (.mat)'},'Choose template file.')
if fName == 0
    error('Please choose an output file!')
    return
end
templateFile=fullfile(pName,fName);
fInfo=whos('-file', templateFile); %get list of variables in .mat file
template=load(templateFile); %load template
template=template.(fInfo.name);
if strcmp('self',optTemplate)
    globalTemplate=template;
    template=[];        
end    

%% get list of data .mat files from dir
 fList=dir([inPath '\*.mat']);
 if isempty(fList)
    error('Dir contains no .mat files!')
    return
 end
% preallocate memory
fCnt=length(fList); %number of files in directory
output=cell(fCnt+1,3); %preallocate output array

%% create waitbar
abort=false;
h = waitbar(0,{['Processing ' strrep(inPath,'\','\\') ' :'] ...
    '0% complete.'},'CreateCancelBtn',@cancelcb);
pause(0.05); drawnow;
    
%setup output header
output(1,:)={'File','Date','Detections (count)'};

%% Begin Main Loop    
avgElapsed=0;
tic; 
for f=1:fCnt      
    subject=load(fullfile(inPath,fList(f).name)); %load data
    subject.ecg=double(subject.ecg); %make sure it's double precision
    startTime=subject.time;
    fprintf([fList(f).name ' - ']);   

    % Handle NaN
    i=isnan(segment.ecg(:,2));
    segment.ecg(i,2)=0;                     
        
    %% Filter ecg signal
    if strcmp(optFilt,'basic')
        %Remove low freq trend (high pass filter)
        trend=fastsmooth(segment.ecg,750,2,0);                
        segment.ecg=segment.ecg-trend;
        %Remove high freq jitter(low pass filter)
        segment.ecg=fastsmooth(segment.ecg,3,2,0);
        segment.ecg=segment.ecg-mean(segment.ecg); %remove mean
    elseif strcmp(optFilt,'wavelet')
        %filter using wavelets
        waveType='sym4'; % or try 'db3'
        lev=8;
        [c,l]=wavedec(segment.ecg,lev,waveType); %decompose signal
        c = wthcoef('d',c,l,[1,2,8]); %force to zero detail coef d1,d2,d8
        Cn = wthcoef('a',c,l); %force to zero the approx coefficient (low freq trend)
        segment.ecg=waverec(c,l,waveType); %recompose signal
    end

    %% create self template
    if strcmp('self',optTemplate)
        % detect r-peaks                                        
        tmp=segment.ecg(1:60*sampleRate);
        i=matchTemplate(tmp,globalTemplate,upThresh,lowThresh,1,1);                                        

        % create template from detected peaks
        L=length(globalTemplate); %length of template
        b1=i>((L-1)/2);
        b2=i<(length(tmp)-((L-1)/2));
        i=i(b1&b2);
        template=makeTemplate(tmp,i,L);            
    end

    %% Detect beats             
    [indexR,rxy2]=matchTemplate(segment.ecg,template,0.40,0.35,1,1);                                               

    %% build output                                    
    output(cnt+1,:)={fList(f).name,datestr(segment.time,'yyyy-mm-dd HH:MM:SS'),sum(indexR)};                   

    %% Update waitbar            
    % calculate remaining time for waitbar
    elapsedTime=toc; %total time elapsed since start
    avgElapsed=elapsedTime/cnt; %average time elapsed to process each segment
    timeRem=ceil(avgElapsed*(segmentCnt-cnt)/60); %time remaining in processing (min)        
    %update waitbar
    bar=round(cnt/segmentCnt*100);
    waitbar(bar/100,h,{['Processing ' strrep(inPath,'\','\\') ' :'] ...
        [num2str(bar) '% complete. (~' num2str(timeRem) ' min)']})
    if abort
        warning('Summary canceled.');
        close all force
        return; 
    end
    fprintf('%s\n',elapsedTime);
end
close all force   

%% Save output
xlswrite(outPath,output)        
disp('!!! Summary Complete !!!')

function cancelcb(a1, a2)
    abort = true;    
end

end
