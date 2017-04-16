function obstacle = block2obstacle( block,blockcircle )
%   This function returns the obstacle transfrom by block
%   Detailed explanation goes here
    obstacle = [zeros(size(blockcircle,1)*size(block,1),2)];
    for n = 1:size(block,1)
    obstacle((n-1)*size(blockcircle,1)+1:n*size(blockcircle,1),:) = ...
        [blockcircle(:,1)+block(n,1),blockcircle(:,2)+block(n,2)];
    end
    obstacle = unique(obstacle,'rows');
end

