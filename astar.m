function [path,obstacle] = astar( block,start,goal,radius,blockunit )
%ASTAR Summary of this function goes here
%   Detailed explanation goes here

open = [];
closed = [];
path = [];
vhcost = 10;        %vetical horizon move cost
diacost = 14;        %diagonal move cost
open(1,1:7) = [start(1,:),0,0,0,start(1,:)];
%%%%%%%%%%%%%%%%%%%obstacle生成%%%%%%%%%%%%%%%%%%%%
blockcircle = circlemaker(radius,blockunit);
obstacle = zeros(size(blockcircle,1)*size(block,1),2);
for n = 1:size(block,1)
obstacle((n-1)*size(blockcircle,1)+1:n*size(blockcircle,1),:) = ...
    [blockcircle(:,1)+block(n,1),blockcircle(:,2)+block(n,2)];
end
obstacle = [kinecircle(start,blockcircle);obstacle];
obstacle = unique(obstacle,'rows');

%%%%%%%%%%%%%%%%%%判断起始点是否在障碍物当中%%%%%%%%%%%%
if ifexist(start(1,:),obstacle)
    error('起始点(start)位于障碍中(obstacle)');
end

%%%%%%%%%%%%%%%%%%开始遍历，直至goal加入open列表中为止%%%%%%%%%%%%%%%%%%%%%%%%
while ~ifexist(goal,open)
%%%%%%%%%找出F值最小的点作为currentpoint，加入closed中，并从open中清除%%%%%%%%%
    if isempty(open)
        warndlg('A*算法未获得路径，请修改目标点','自动获得路径提示')
    end
    [~,ind] = sort(open(:,5),'ascend');
    currentpoint = open(ind(1),:);
    closed(size(closed,1)+1,:) = currentpoint;
    open(ind(1),:) = [];
%%%%%%%%%%%%%%%%%%%%%%遍历currentpoint周围的八个点%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for m = -1:1
        for n = -1:1
%             if m == 0 && n == 0   %%%略过currentpoint，省略这段也可以，因为该点在closed中
%                 continue;
%             end
            checkpoint = [currentpoint(1)+m,currentpoint(2)+n];     %获得checkpoint的位置坐标
            if ifexist(checkpoint,closed) || ifexist(checkpoint,obstacle)  %若checkpoint在closed或者block列表中直接跳过
                continue;
%%%%%%这一部分用于控制能否进行障碍斜角穿越，由于程序中使用了circleblock对block进行过处理，所以个人认为可以不用该部分
% % %             elseif abs(m)+abs(n)>1
% % %                 if ifexist([currentpoint(1)+m,currentpoint(2)],obstacle) ...
% % %                     || ifexist([currentpoint(1),currentpoint(2)+n],obstacle)
% % %                     continue;
% % %                 end
            end
            if ifexist(checkpoint,open) %若checkpoint在open列表中，重新评估其cost
                ind = ifexist(checkpoint,open);
                checkpoint = open(ind,:);       %获得checkpoint的全部信息
                if abs(m)+abs(n)>1
                    gcost = diacost;
                else
                    gcost = vhcost;
                end
                if currentpoint(3)+gcost<checkpoint(3)
                    checkpoint(3) = currentpoint(3)+gcost;
                    checkpoint(5) = sum(checkpoint(3:4));
                    checkpoint(6:7) = currentpoint(1:2);
                    open(ind,:) = checkpoint;
                end
            else           %若checkpoint不在closed也不在open中，获得其信息并加入open
                if abs(m)+abs(n)>1
                    gcost = diacost;
                else
                    gcost = vhcost;
                end
                checkpoint(3) = gcost + currentpoint(3);
                checkpoint(4) = heuristdist(checkpoint(1:2),goal);
                checkpoint(5) = sum(checkpoint(3:4));
                checkpoint(6:7) = currentpoint(1:2);
                open(size(open,1)+1,:) = checkpoint;
            end
        end
    end
end

%%%%%%%%%%%%合并open和closed列表，取出children和father列表并逆推获取路径%%%%%%%%%%%
totallist = [open;closed];
ind = ifexist(goal,totallist);
path(1,:) = totallist(ind,1:2);
fatherpoint = totallist(ind,6:7);
fatherlist = totallist(:,6:7);
childrenlist = totallist(:,1:2);
while ~isequal(path(end,:),start(1,:))
    ind = ifexist(fatherpoint,totallist);
    if ind
        path(size(path,1)+1,:) = childrenlist(ind,:);
        fatherpoint = fatherlist(ind,:);           %这里就这么结束，是因为在定义start的时候start点的father也是start
    end
end
path = flip(path,1);        %让path中记录数据从起点到终点
assignin('base','open',open);
assignin('base','closed',closed);
end

