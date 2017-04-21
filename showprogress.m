%%%%%%%%%%%%%%���script������A*Ѱ·�Ĺ��̽���ͼ����ƣ�ʹ�ù��̸��Ӿ���%%%%%%%%%%%%%%%%%
plot(pathX,pathY,'color','r');
hold on
plot(carposX,carposY,'color','b');
blockcircle = circlemaker(100,20);
obstacle = block2obstacle(lastblock,blockcircle);
obstacle = obstacle.*20;
block = lastblock.*20;
scatter(obstacle(:,1),obstacle(:,2),'marker','s','sizedata',100,'markerfacecolor','c','markeredgecolor','none');
scatter(block(:,1),block(:,2),'marker','s','sizedata',100,'markerfacecolor','b','markeredgecolor','none');
scatter(lastwaypoints(:,1)*20,lastwaypoints(:,2)*20,'marker','s','sizedata',100,'markerfacecolor','r','markeredgecolor','none');
legend('path','following path','block circle','block','waypoints');
axis equal;
grid on
title('A star argorithm')
set(gca,'box','on')
hold off