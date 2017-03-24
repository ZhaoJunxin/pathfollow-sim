function [ outx,outy,theta ] = pathjudger(inpx,inpy)
%PATHJUDGER Summary of this function goes here（懒得打英语了）
%   该函数功能：
%   1.基于动力学模型平滑路径
%   2.提取出目标点的方向角theta（弧度）
%   inpx为画板中直接绘制图像的X轴数据，inpy为Y轴数据
%%%%%%%%以下部分用于将x,y数据合并处理，并删除其中的重复数据%%%%%%%%%
linearray = [inpx',inpy'];
%linearray = flip(linearray);
linearray = round(flip(linearray));
n = 0;
for i=1:length(linearray)-1
    j = i-n;
    if linearray(j,:) == linearray(j+1,:)  %这里删除的思路应该改下，改成先获取index，然后删除对应index
        linearray(j+1,:) = [];
        n = n+1;
    end
end
% 
% outx = linearray(:,1);
% outy = linearray(:,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%按照运动率平滑曲线，获得需要的期望点%%%%%%%%%%%%%%%%%%%
r = 100;                        %小车轴距(mm)，按实际需求改动
n = 0;
%linearray = [linearray(:,1),linearray(:,2)];
linearray = [[-1,0];linearray]; %此处增加一个元素[-1,0]，用于处理出发点，最后删掉
thetarad = zeros(length(linearray)-1,1);
for i=2:length(linearray)-1
    j = i - n;
    a = linearray(j-1,:)-linearray(j,:);
    b = linearray(j+1,:)-linearray(j,:);
%    coner = acos(dot(a,b)/(norm(a)*norm(b)));
    coner = acos(sum(a.*b)/(norm(a)*norm(b)));
    mod = 2*r*cos(pi/2-(pi-coner)/2);      %极坐标获得指定角度的模值
    if norm(b)<mod
%         if i~=length(linearray)-1 %防止删掉最后一个点（其实理论上不满足条件应该删掉的）
            linearray(j+1,:) = [];
            n = n+1;
%         end
    else
        thetarad(j) = vec2rad(a,b);         %下面这段条件语句用来获得目标点的方向
        if(thetarad(j)<pi)
            thetarad(j) = vec2rad([1,0],b) + (pi-thetarad(j))/2;
        else
            thetarad(j) = vec2rad([1,0],b) - (thetarad(j)-pi)/2;
        end
    end
end
linearray(1,:) = []; %删掉第一行元素，感谢他的无私奉献
outx = linearray(:,1);
outy = linearray(:,2);
line(outx,outy,'marker','d','color','r')
thetarad([1,j+1:end]) = [];         %删掉空白的部分
theta = thetarad;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%删除直线段中间的点，范围2-length(outx)-1%%%%%%%%%%%%%%%%%%%%%%%
linearray = [outx,outy];
n = 1;                  %useless index
useless = zeros(length(outx)-1,1);
for m = 2:length(outx)-1
    a = linearray(m-1,:)-linearray(m,:);
    b = linearray(m+1,:)-linearray(m,:);
    coner = acos(sum(a.*b)/(norm(a)*norm(b)));
    if coner == pi
        useless(n) = m;
        n = n+1;
    end      
end
useless(useless == 0) = [];
linearray(useless,:) = [];
theta(useless) = [];
outx = linearray(:,1);
outy = linearray(:,2);
line(outx,outy,'marker','o','markerfacecolor','b','markersize',4,'color','b')


    




