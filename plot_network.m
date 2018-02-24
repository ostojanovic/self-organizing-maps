
function [weights_figure] = plot_network(string)

% Plotting the som. Works with .mat files only.
% string should contain: *weights*.mat.

%% loading weights and plotting the grid

files    = dir(string);  
N        = length(files);
grid_len = 10;

for i = 1:N
    
    loaded_weights = load(files(i).name);
    weights = loaded_weights.weights;
    
    weights     = reshape(weights,grid_len,grid_len,size(weights,3));
    diff_weight = zeros(grid_len,grid_len,3,3);
    
    figure(i)
    
    [xx,yy] = meshgrid(1:grid_len);
    
    plot(xx(:),yy(:),'k.')
    set(gca,'xlim',[0,11]);
    set(gca,'ylim',[0,11]);
    hold on
    
    cmap = colormap;
    
    %% calculate the max diff and normalized distance
    
    for x = 1:grid_len                                    % x, y are coordinates in a matrix
        
        for y = 1:grid_len
            
            center_weight = squeeze(weights(x, y, :));
            
            for IDX = 1:3                           % IDX, IDY are coordinates in a small neighbourhood
                
                for IDY = 1:3
                    
                    Neighbour_X = min(10,max(1,IDX-2 + x));
                    Neighbour_Y = min(10,max(1,IDY-2 + y));
                    
                    diff_weight(x,y,IDX,IDY) = sum((center_weight - squeeze(weights(Neighbour_X, Neighbour_Y,:))).^2);
                    
                end
            end
        end
    end
    
    max_diff = max(max(max(max(diff_weight))));
    distance = diff_weight./max_diff;
    
    %% plotting the som weights
    
    act_color_Index = ceil(distance.*64);
    
    for x = 1:grid_len
        
        for y = 1:grid_len
            
            center_weight = squeeze(weights(x, y, :));
            
            for IDX = 1:3
                
                for IDY = 1:3
                    
                    Neighbour_X = min(10,max(1,IDX-2 + x));
                    Neighbour_Y = min(10,max(1,IDY-2 + y));
                    
                    if act_color_Index(x,y,IDX,IDY) ~= 0
                        plot([Neighbour_X, x],[Neighbour_Y, y],'-','linewidth', distance(x,y,IDX,IDY)*3,'color',cmap(act_color_Index(x,y,IDX,IDY),:))
                    end
                end
            end
        end
    end
    
    %% saving figures
    
    savefig(fullfile(pwd,strtok(files(i).name,'.mat')))
    
end

end
