function pose = carkine(lAngSpd,rAngSpd,yaw)
r = 20; %驱动轮的半径
d = 174; %轴距
%transMat = [r/2*cos(yaw),r/2*cos(yaw); r/2*sin(yaw),r/2*sin(yaw); -r/d,r/d];
%上一句存在因子r可以提出来，减小计算量
transMat = [1/2*cos(yaw),1/2*cos(yaw); 1/2*sin(yaw),1/2*sin(yaw); -1/d,1/d];
% transMat = repmat([1/2*cos(yaw); 1/2*sin(yaw); -1/d],1,2);
% transMat(length(transMat)) = transMat(length(transMat))*-1;
pose = transMat * ([lAngSpd rAngSpd]'.*r);
% tic
% carkine(20,20,0);
% toc
