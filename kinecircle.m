function obstacle = kinecircle(startvector,blockcircle)
%   This function returns the obstacle to satisfy the kinematic:
%
%   obstacle = kinecircle(startvector,blockcircle)
%
%   输入的startvector有两个点，而且必须相邻。
%   注意：若A*计算时不能斜着穿过相邻的block，则下面代码可能需要改动后才能使用
movedir = vec2rad([1,0],startvector(1,:) - startvector(2,:));
%if abs(sum(startvector(1,:)-startvector(2,:)))<2
if abs(sin(movedir)) <= eps
    diagpoint = [0,1];
    while ifexist(diagpoint,blockcircle)
        diagpoint(2) = diagpoint(2) + 1;
    end
%    diagpoint(2) = diagpoint(2)+1;     %上面的while在ifexist为空的时候已经多加1了
elseif abs(sin(movedir)) >= 1-eps
    diagpoint = [1,0];
    while ifexist(diagpoint,blockcircle)
        diagpoint(1) = diagpoint(1) + 1;
    end    
else
    diagpoint = [1,1];
    while ifexist(diagpoint,blockcircle)
        diagpoint = diagpoint + 1;
    end
%    diagpoint(1) = diagpoint+1;         %上面的while在ifexist为空的时候已经多加1了
end
center1ang = movedir + pi/2;
center2ang = movedir - pi/2;
center1 = [startvector(1,1)+sign(cos(center1ang))*diagpoint(1,1)...
            startvector(1,2)+sign(sin(center1ang))*diagpoint(1,2)];
center2 = [startvector(1,1)+sign(cos(center2ang))*diagpoint(1,1)...
            startvector(1,2)+sign(sin(center2ang))*diagpoint(1,2)];
block = [center1;center2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%生成obstacle$%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obstacle = zeros(size(blockcircle,1)*size(block,1),2);
for n = 1:size(block,1)
    obstacle((n-1)*size(blockcircle,1)+1:n*size(blockcircle,1),:) = ...
        [blockcircle(:,1)+block(n,1),blockcircle(:,2)+block(n,2)];
end
obstacle = unique([obstacle;startvector(2,:)],'rows');
end

