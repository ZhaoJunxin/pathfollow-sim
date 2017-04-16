function dist  = heuristdist( point1,point2 )
%HEURITDIST Summary of this function goes here
%   Detailed explanation goes here
    deltax = abs(point1(1) - point2(1));
    deltay = abs(point1(2) - point2(2));
    if deltax >= deltay
        dist = (deltax - deltay)*10 + deltay * 14;
    elseif deltax < deltay
        dist = (deltay - deltax)*10 + deltax * 14;
    end
end

