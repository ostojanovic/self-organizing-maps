%% load data and set up parameters

files    = dir('*data*.mat');
N        = length(files);
grid_len = 10;
nr_nodes = grid_len^2;
T        = 10000;              % number of iterations
L_0      = 0.1;                % initial learning rate

for i = 1:N
    
    loaded_data = load(files(i).name);
    data = loaded_data.data';
    data = (data-repmat(min(data),size(data,1),1))./repmat(max(data)-min(data),size(data,1),1);    % scale data
    
    data_training = data(1:ceil(size(data,1)*2/3),:);
    data_test     = data(ceil(size(data,1)*2/3):end,:);
    
    dim_data    = size(data,2);
    nr_training = size(data_training,1);                         % number of data points in a training set
    nr_test     = size(data_test,1);                             % number of data points in a testing set
    weights     = rand(N,nr_nodes,dim_data);                     % every node has weights (i.e. prototype vectors)
    sample_tr   = zeros(N,1,dim_data);
    sample_ts   = zeros(N,1,dim_data);
    
    %% Training the SOM
    
    for t = 1:T
        
        sample_tr(i,t,:) = data_training(randi(nr_training),:);
        
        difference = repmat(sample_tr(i,t,:),[1,nr_nodes]) - weights(i,:,:);   % calculate the bmu based on distances (squared)
        dist_tr = sum(difference.^2,2);
        [val, bmu] = min(dist_tr);
        
        x_bmu = mod(bmu-1, grid_len)+1;
        y_bmu = ceil(bmu / grid_len);
        
        x_win_1 = abs(1 - x_bmu);
        x_win_2 = abs(10 - x_bmu);
        
        y_win_1 = abs(1 - y_bmu);
        y_win_2 = abs(10 - y_bmu);
        
        window_width  = min(x_win_1,x_win_2);
        window_height = min(y_win_1,y_win_2);
        
        if t == 1
            map_radius = max(window_width, window_height)/2;        % that's our sigma_0
            lambda = T/log(map_radius);
        end
        
        sigma = map_radius * exp(-t/lambda);
        
        L = L_0 * exp(-t/lambda);
        
        for j = 1:nr_nodes
            
            x_i = mod(j-1, grid_len)+1;
            y_i = ceil(j / grid_len);
            
            dist_new = (x_i - x_bmu).^2 + (y_i - y_bmu).^2;         % distance squared from weights to the bmu
            
            theta = exp(-(dist_new)^2/(2*sigma^2));                 % the amount of influence a node's distance from the bmu has on its learning
            
            weights(i,j,:) = weights(i,j,:) + theta* L.*(sample_tr(i,t,:) - weights(i,j,:));
        end
        
    end
    
    %% Applying the SOM to testing data
    
    data_test = (data_test-repmat(min(data_test),size(data_test,1),1))./repmat(max(data_test)-min(data_test),size(data_test,1),1);    % scale data
    
    x_bmu_test = zeros(size(data_test,1),1);
    y_bmu_test = zeros(size(data_test,1),1);
    
    for k = 1:size(data_test,1)
        
        sample_ts(i,t,:) = data_test(randi(nr_test),:);
        
        difference = repmat(sample_ts(i,t,:),[1,nr_nodes]) - weights(i,:,:);
        dist_ts = sum(difference.^2,2);
        [val, bmu] = min(dist_ts);
        
        x_bmu_test(k) = mod(bmu-1, grid_len)+1;
        y_bmu_test(k) = ceil(bmu / grid_len);
    end
    
    %% save weights to .mat file
    
    weights = weights(i,:,:);
    save(fullfile(pwd,strcat(strtok(files(i).name,'.mat'),'_weights','.mat')),'weights')
    
end
