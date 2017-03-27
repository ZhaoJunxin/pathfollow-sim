function  radcw  = vec2rad( vec1,vec2 )
    %vec2rad - radian between two input vector
    %
    %   This function return the clockwise radian between vec1 and vec2
    %
    %   by:Zhao Junxin 2017/3/17
    if vec1 == vec2
        radcw = 0;
        return
    end
    vec1 = [vec1,0];
    vec2 = [vec2,0];
    arccos = acos(sum(vec1.*vec2)/(norm(vec1)*norm(vec2)));
    arcsin = sum(asin(cross(vec1,vec2)/(norm(vec1)*norm(vec2))));
    if arcsin >= 0
        radcw = arccos;
    elseif arcsin <0
        radcw = 2*pi - arccos;
    end
end


