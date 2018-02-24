%% load, read, delete some channels and save the data

files = dir('*VP*.txt');

for i = 1:length(files)
    disp('loading data . . .')
    
    tmsidata = dlmread(files(i).name)';
    data = 10e-9*[tmsidata(2:66,2:end); tmsidata(75:138,2:end)];        % loads data from 2nd frame onwards (1st frame is always empty)
    
    data(1:65,:)   = data(1:65,:) - repmat(data(16,:),65,1);            % ref each amp's chans with the amp specific CZ ref.
    data(66:end,:) = data(66:end,:) - repmat(data(96,:), 64,1);
    data(16,:)     = [];                                                % these two rows are empty
    data(95,:)     = [];     
    
    clear tmsidata
    save(fullfile(pwd,strcat(strtok(files(i).name,'.txt'),'_data','.mat')),'data')
end
