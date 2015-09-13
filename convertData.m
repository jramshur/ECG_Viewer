function convertData(fileToRead1)
    %convertData(FILETOREAD1)
    %  converts data from the specified file
    %  FILETOREAD1:  file to read

    % Import the file
    rawData1 = importdata(fileToRead1);
    a=rawData1{2}; %ecg data is in row 2

    % Read formated data
    d=textscan(a,'/%d'); % read formated data
    d=double(d{:}); % convert cell to array

    % compute Time data
    sampleRate=500; % set sample rate for computing time values
    timeData=(0:1/sampleRate:length(d)/sampleRate-1/sampleRate)';

    ecgData=[timeData,d];
    plot(timeData,d)

    % Save data
    fileToSave=[fileToRead1(1:end-3) 'mat'];s
    save(fileToSave,'ecgData');

end