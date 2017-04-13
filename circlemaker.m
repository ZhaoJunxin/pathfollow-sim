function circleblock = circlemaker( radius,blockunit )
%CIRCLEMAKER Summary of this function goes here
%   Detailed explanation goes here
blockradius = (radius/blockunit);
unitcircle = zeros(2*blockradius+1,2*blockradius+1);
for i= 0:blockradius
%     cedgey = i;
     cedgex = round(sqrt((blockradius*blockradius)-i*i));
     unitcircle(blockradius+i+1,blockradius+(0:cedgex)+1) = 1;
     unitcircle(blockradius+i+1,blockradius+(-cedgex:0)+1) = 1;
     unitcircle(blockradius-i+1,blockradius+(0:cedgex)+1) = 1;
     unitcircle(blockradius-i+1,blockradius+(-cedgex:0)+1) = 1;
end
unitcircle = unitcircle | unitcircle';          %为了解决不圆的问题，翻转然后合并下
[locx,locy] = find(unitcircle);
locx = locx - (blockradius+1);
locy = locy - (blockradius+1);
circleblock = [locx,locy];
end

