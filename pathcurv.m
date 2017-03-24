function [ outx,outy,outcur ] = pathcurv( inpx,inpy,diststd )
%PATHCURV Summary of this function goes here
%   
    refp = [inpx,inpy];         %参考目标点reference point
    crtspot = refp(1,:);            %当前位置
    n = 2;                      %reference point index
    m = 1;                      %out index
    dist = diststd;             %标准路程差
    curacc = 0;                 %弧度累加，越大代表弯曲程度越高
    while n<=length(inpx)-1
%         if n == length(inpx)-2
%             crt = crtspot
%             pause();
%         end
        if norm(crtspot-refp(n,:))>dist
            coner = vec2rad([1,0],refp(n,:) - crtspot);      %注意vec2rad(a,b)得到的结果是a-b的顺时针夹角
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
        else                             %等于的情况几乎不可能，但是还是以防万一
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
    outx(m) = refp(length(inpx),1);               %这里index不能是m+1，应该是m，因为在while中已经进行过+1工作了
    outy(m) = refp(length(inpx),2);               %这里index不能是m+1，应该是m，因为在while中已经进行过+1工作了
    outcur(m) = 0;
    outx = [0,outx]';
    outy = [0,outy]';
    outcur = [0,outcur]';                          %这里可以设置第一个夹角，先设置为0（其实用不上这个点，但是为了程(qiang)序(po)完(zheng)整）
end

