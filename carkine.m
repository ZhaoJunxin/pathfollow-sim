function pose = carkine(lAngSpd,rAngSpd,yaw)
r = 20; %�����ֵİ뾶
d = 174; %���
%transMat = [r/2*cos(yaw),r/2*cos(yaw); r/2*sin(yaw),r/2*sin(yaw); -r/d,r/d];
%��һ���������r�������������С������
transMat = [1/2*cos(yaw),1/2*cos(yaw); 1/2*sin(yaw),1/2*sin(yaw); -1/d,1/d];
% transMat = repmat([1/2*cos(yaw); 1/2*sin(yaw); -1/d],1,2);
% transMat(length(transMat)) = transMat(length(transMat))*-1;
pose = transMat * ([lAngSpd rAngSpd]'.*r);
% tic
% carkine(20,20,0);
% toc
