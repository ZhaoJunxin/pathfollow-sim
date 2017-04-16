function [path,obstacle] = astar( block,start,goal,radius,blockunit )
%ASTAR Summary of this function goes here
%   Detailed explanation goes here

open = [];
closed = [];
path = [];
vhcost = 10;        %vetical horizon move cost
diacost = 14;        %diagonal move cost
open(1,1:7) = [start(1,:),0,0,0,start(1,:)];
%%%%%%%%%%%%%%%%%%%obstacle����%%%%%%%%%%%%%%%%%%%%
blockcircle = circlemaker(radius,blockunit);
obstacle = zeros(size(blockcircle,1)*size(block,1),2);
for n = 1:size(block,1)
obstacle((n-1)*size(blockcircle,1)+1:n*size(blockcircle,1),:) = ...
    [blockcircle(:,1)+block(n,1),blockcircle(:,2)+block(n,2)];
end
obstacle = [kinecircle(start,blockcircle);obstacle];
obstacle = unique(obstacle,'rows');

%%%%%%%%%%%%%%%%%%�ж���ʼ���Ƿ����ϰ��ﵱ��%%%%%%%%%%%%
if ifexist(start(1,:),obstacle)
    error('��ʼ��(start)λ���ϰ���(obstacle)');
end

%%%%%%%%%%%%%%%%%%��ʼ������ֱ��goal����open�б���Ϊֹ%%%%%%%%%%%%%%%%%%%%%%%%
while ~ifexist(goal,open)
%%%%%%%%%�ҳ�Fֵ��С�ĵ���Ϊcurrentpoint������closed�У�����open�����%%%%%%%%%
    if isempty(open)
        warndlg('A*�㷨δ���·�������޸�Ŀ���','�Զ����·����ʾ')
    end
    [~,ind] = sort(open(:,5),'ascend');
    currentpoint = open(ind(1),:);
    closed(size(closed,1)+1,:) = currentpoint;
    open(ind(1),:) = [];
%%%%%%%%%%%%%%%%%%%%%%����currentpoint��Χ�İ˸���%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for m = -1:1
        for n = -1:1
%             if m == 0 && n == 0   %%%�Թ�currentpoint��ʡ�����Ҳ���ԣ���Ϊ�õ���closed��
%                 continue;
%             end
            checkpoint = [currentpoint(1)+m,currentpoint(2)+n];     %���checkpoint��λ������
            if ifexist(checkpoint,closed) || ifexist(checkpoint,obstacle)  %��checkpoint��closed����block�б���ֱ������
                continue;
%%%%%%��һ�������ڿ����ܷ�����ϰ�б�Ǵ�Խ�����ڳ�����ʹ����circleblock��block���й��������Ը�����Ϊ���Բ��øò���
% % %             elseif abs(m)+abs(n)>1
% % %                 if ifexist([currentpoint(1)+m,currentpoint(2)],obstacle) ...
% % %                     || ifexist([currentpoint(1),currentpoint(2)+n],obstacle)
% % %                     continue;
% % %                 end
            end
            if ifexist(checkpoint,open) %��checkpoint��open�б��У�����������cost
                ind = ifexist(checkpoint,open);
                checkpoint = open(ind,:);       %���checkpoint��ȫ����Ϣ
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
            else           %��checkpoint����closedҲ����open�У��������Ϣ������open
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

%%%%%%%%%%%%�ϲ�open��closed�б�ȡ��children��father�б����ƻ�ȡ·��%%%%%%%%%%%
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
        fatherpoint = fatherlist(ind,:);           %�������ô����������Ϊ�ڶ���start��ʱ��start���fatherҲ��start
    end
end
path = flip(path,1);        %��path�м�¼���ݴ���㵽�յ�
assignin('base','open',open);
assignin('base','closed',closed);
end

