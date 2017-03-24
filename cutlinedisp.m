function cutlinedisp( inpx,inpy,theta,sw )
%CUTLINEDISP Summary of this function goes here
%   This function use to check if the tangent is correct after the pathjudger.
dist = 40;
if sw
    for m = 1:length(inpx)-1
        cutx1 = -dist/2*cos(theta(m))+inpx(m);
        cuty1 = -dist/2*sin(theta(m))+inpy(m);    
        cutx2 = dist/2*cos(theta(m))+inpx(m);
        cuty2 = dist/2*sin(theta(m))+inpy(m);
        line([cutx1,cutx2],[cuty1,cuty2],'color',[0.85,0.21,0.21],'linestyle','-');
    end
else
    delete(findobj('type','line','color',[0.85,0.85,0.85],'linestyle','-'))
end