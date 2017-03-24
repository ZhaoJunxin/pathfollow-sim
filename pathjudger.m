function [ outx,outy,theta ] = pathjudger(inpx,inpy)
%PATHJUDGER Summary of this function goes here�����ô�Ӣ���ˣ�
%   �ú������ܣ�
%   1.���ڶ���ѧģ��ƽ��·��
%   2.��ȡ��Ŀ���ķ����theta�����ȣ�
%   inpxΪ������ֱ�ӻ���ͼ���X�����ݣ�inpyΪY������
%%%%%%%%���²������ڽ�x,y���ݺϲ�������ɾ�����е��ظ�����%%%%%%%%%
linearray = [inpx',inpy'];
%linearray = flip(linearray);
linearray = round(flip(linearray));
n = 0;
for i=1:length(linearray)-1
    j = i-n;
    if linearray(j,:) == linearray(j+1,:)  %����ɾ����˼·Ӧ�ø��£��ĳ��Ȼ�ȡindex��Ȼ��ɾ����Ӧindex
        linearray(j+1,:) = [];
        n = n+1;
    end
end
% 
% outx = linearray(:,1);
% outy = linearray(:,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%�����˶���ƽ�����ߣ������Ҫ��������%%%%%%%%%%%%%%%%%%%
r = 100;                        %С�����(mm)����ʵ������Ķ�
n = 0;
%linearray = [linearray(:,1),linearray(:,2)];
linearray = [[-1,0];linearray]; %�˴�����һ��Ԫ��[-1,0]�����ڴ�������㣬���ɾ��
thetarad = zeros(length(linearray)-1,1);
for i=2:length(linearray)-1
    j = i - n;
    a = linearray(j-1,:)-linearray(j,:);
    b = linearray(j+1,:)-linearray(j,:);
%    coner = acos(dot(a,b)/(norm(a)*norm(b)));
    coner = acos(sum(a.*b)/(norm(a)*norm(b)));
    mod = 2*r*cos(pi/2-(pi-coner)/2);      %��������ָ���Ƕȵ�ģֵ
    if norm(b)<mod
%         if i~=length(linearray)-1 %��ֹɾ�����һ���㣨��ʵ�����ϲ���������Ӧ��ɾ���ģ�
            linearray(j+1,:) = [];
            n = n+1;
%         end
    else
        thetarad(j) = vec2rad(a,b);         %���������������������Ŀ���ķ���
        if(thetarad(j)<pi)
            thetarad(j) = vec2rad([1,0],b) + (pi-thetarad(j))/2;
        else
            thetarad(j) = vec2rad([1,0],b) - (thetarad(j)-pi)/2;
        end
    end
end
linearray(1,:) = []; %ɾ����һ��Ԫ�أ���л������˽����
outx = linearray(:,1);
outy = linearray(:,2);
line(outx,outy,'marker','d','color','r')
thetarad([1,j+1:end]) = [];         %ɾ���հ׵Ĳ���
theta = thetarad;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%ɾ��ֱ�߶��м�ĵ㣬��Χ2-length(outx)-1%%%%%%%%%%%%%%%%%%%%%%%
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


    




