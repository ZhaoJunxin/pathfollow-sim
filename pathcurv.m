function [ outx,outy,outcur ] = pathcurv( inpx,inpy,diststd )
%PATHCURV Summary of this function goes here
%   
    refp = [inpx,inpy];         %�ο�Ŀ���reference point
    crtspot = refp(1,:);            %��ǰλ��
    n = 2;                      %reference point index
    m = 1;                      %out index
    dist = diststd;             %��׼·�̲�
    curacc = 0;                 %�����ۼӣ�Խ����������̶�Խ��
    while n<=length(inpx)-1
%         if n == length(inpx)-2
%             crt = crtspot
%             pause();
%         end
        if norm(crtspot-refp(n,:))>dist
            coner = vec2rad([1,0],refp(n,:) - crtspot);      %ע��vec2rad(a,b)�õ��Ľ����a-b��˳ʱ��н�
%            pause();
            crtspot(1) = crtspot(1) + dist*cos(coner);         %x
            crtspot(2) = crtspot(2) + dist*sin(coner);         %y
            patch('xdata',crtspot(1),'ydata',crtspot(2),'marker','o','edgecolor','m');
            dist = diststd;
 %           dist = norm(crtspot - refp(n,:)) - dist;
            outx(m) = crtspot(1);
            outy(m) = crtspot(2);
            outcur(m) = curacc;
            curacc = 0;
            m = m + 1;
        elseif norm(crtspot - refp(n,:)) < dist
            dist = dist - norm(refp(n,:)-crtspot);
            crtspot = refp(n,:);
%            patch('xdata',crtspot(1),'ydata',crtspot(2),'marker','o','edgecolor','m');
            a = refp(n-1,:)-refp(n,:);
            b = refp(n+1,:)-refp(n,:);
            curacc = curacc + (pi - acos(dot(a,b)/(norm(a)*norm(b))));
            n = n + 1;
        else                             %���ڵ�������������ܣ����ǻ����Է���һ
            crtspot = refp(n,:);
%            patch('xdata',crtspot(1),'ydata',crtspot(2),'marker','o','edgecolor','m');
            dist = diststd;
            a = refp(n-1,:)-refp(n,:);
            b = refp(n+1,:)-refp(n,:);
            curacc = curacc + (pi - acos(dot(a,b)/(norm(a)*norm(b))));
            n = n+1;
            outx(m) = crtspot(1);
            outy(m) = crtspot(2);
            outcur(m) = curacc;
            curacc = 0;
            m = m + 1;
        end
    end
    outx(m) = refp(length(inpx),1);               %����index������m+1��Ӧ����m����Ϊ��while���Ѿ����й�+1������
    outy(m) = refp(length(inpx),2);               %����index������m+1��Ӧ����m����Ϊ��while���Ѿ����й�+1������
    outcur(m) = 0;
    outx = [0,outx]';
    outy = [0,outy]';
    outcur = [0,outcur]';                          %����������õ�һ���нǣ�������Ϊ0����ʵ�ò�������㣬����Ϊ�˳�(qiang)��(po)��(zheng)����
end
