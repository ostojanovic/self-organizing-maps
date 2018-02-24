%% loading weights and data

files    = dir('*d_weights*.mat');
N        = length(files);
grid_len = 10;

for k = 1:N
    loaded_weights = load(files(k).name);
    weights = loaded_weights.weights;
    weights = reshape(weights,grid_len^2, 127);
    
    n_w = size(weights,1);
    
    data = dir('*data*.mat');
    loaded_data = load(data(k).name);
    data = loaded_data.data';
    
    n = size(data,1);
    
    data = (data-repmat(min(data),n,1))./repmat(max(data)-min(data),n,1);
    
    bmu = zeros(n,2);
    
    %% calculating the bmu for every data point
    
    for i = 1:n
        difference = repmat(data(i,:),[n_w,1]) - weights;
        dist = sum(difference.^2,2);
        [val, bmu_t] = min(dist);
        
        bmu(i,1) = mod(bmu_t-1, grid_len)+1;      % x-axis
        bmu(i,2) = ceil(bmu_t / grid_len);        % y-axis
    end
    
    %% plotting
    
    figure(k)
    hold on
    plot(bmu(:,1)+rand(n,1),bmu(:,2)+rand(n,1),'r.')
    
end

hold on
plot_network('*d_weights*.mat')


