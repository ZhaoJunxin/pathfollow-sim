function [ outx,outy,outcur,outtan ] = pathcurv( inpx,inpy,diststd )
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
%%%%%%%%%%%%%%%%%%用于DEBUG，显示采样点%%%%%%%%%%%%%%%%%%%%%%%%%%
%            patch('xdata',crtspot(1),'ydata',crtspot(2),'marker','o','edgecolor','m');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            dist = diststd;
 %           dist = norm(crtspot - refp(n,:)) - dist;
            outx(m) = crtspot(1);
            outy(m) = crtspot(2);
            outcur(m) = curacc;
            outtan(m) = coner;
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
            outtan(m) = vec2rad(a,b);         %下面这段条件语句用来获得目标点的方向
            if(outtan(m)<pi)
                outtan(m) = vec2rad([1,0],b) + (pi-outtan(m))/2;
            else
                outtan(m) = vec2rad([1,0],b) - (outtan(m)-pi)/2;
            end
            curacc = 0;
            m = m + 1;
        end
    end
    outx(m) = refp(length(inpx),1);               %补充最后一个点，这里index不能是m+1，应该是m，因为在while中已经进行过+1工作了
    outy(m) = refp(length(inpx),2);               %补充最后一个点，这里index不能是m+1，应该是m，因为在while中已经进行过+1工作了
    outcur(m) = 0;
    outtan(m) = vec2rad([1,0],[outx(m)-outx(m-1),outy(m)-outy(m-1)]);
    outx = [0,outx]';                             %补充第一个点
    outy = [0,outy]';
    outcur = [0,outcur]';                          %这里可以设置第一个夹角，先设置为0（其实用不上这个点，但是为了程(qiang)序(po)完(zheng)整）
    outtan = [0,outtan]';
%计算acos\asin反三角函数的过程中，由于误差使得输入的变量在[-1,1]的范围之外，最终将导致结果出现复数虚部，影响运算结果，这里用real()只保留实部    
    outcur = real(outcur);                          
    outtan = real(outtan);
end
