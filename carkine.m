function pose = carkine(lAngSpd,rAngSpd,yaw)
r = 20; %驱动轮的半径
d = 174; %轴距
transMat = [1/2*cos(yaw),1/2*cos(yaw); 1/2*sin(yaw),1/2*sin(yaw); -1/d,1/d];
pose = transMat * ([lAngSpd rAngSpd]'.*r);
%%%%%%%%%%%%%%第二种运动学模型计算方式，减少了三角函数运算消耗的资源****************
% % % v = sum([lAngSpd, rAngSpd] * r)/2;
% % % w = sum([-lAngSpd, rAngSpd] * r) /(2*d);
% % % pose = [cos(yaw),0; sin(yaw),0; 0,1] *[v,w]';
% tic
% carkine(20,20,0);
% toc
