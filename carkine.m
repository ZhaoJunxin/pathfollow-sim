function pose = carkine(lAngSpd,rAngSpd,yaw)
r = 20; %�����ֵİ뾶
d = 174; %���
transMat = [1/2*cos(yaw),1/2*cos(yaw); 1/2*sin(yaw),1/2*sin(yaw); -1/d,1/d];
pose = transMat * ([lAngSpd rAngSpd]'.*r);
%%%%%%%%%%%%%%�ڶ����˶�ѧģ�ͼ��㷽ʽ�����������Ǻ����������ĵ���Դ****************
% % % v = sum([lAngSpd, rAngSpd] * r)/2;
% % % w = sum([-lAngSpd, rAngSpd] * r) /(2*d);
% % % pose = [cos(yaw),0; sin(yaw),0; 0,1] *[v,w]';
% tic
% carkine(20,20,0);
% toc
