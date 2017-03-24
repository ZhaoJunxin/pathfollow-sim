function [ outx,outy ] = pathsoom( inpx,inpy )
%PATHSOOM Summary of this function goes here
%   Detailed explanation goes here
r = 100;
n = 0;
linearray = [inpx,inpy];
linearray = [[-1,0];linearray];
for i=2:length(linearray)-1
    j = i - n;
    a = linearray(j-1,:)-linearray(j,:);
    b = linearray(j+1,:)-linearray(j,:);
    theta = acos(dot(a,b)/(norm(a)*norm(b)));
    mod = 2*r*cos(pi/2-(pi-theta)/2);
    if norm(b)<mod
        if i~=length(linearray)-1
            linearray(j+1,:) = [];
            n = n+1;
        end
    end
end
outx = linearray(:,1);
outy = linearray(:,2);

% a = [1,0];
% b = linearray(2,:);
% theta = acos(dot(a,b)/(norm(a)*norm(b)));
% mod = 2*r*cos(theta);
% if norm(b)<mod
%     linearray(2,:) = [];
end

