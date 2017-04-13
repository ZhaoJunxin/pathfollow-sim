function loc = ifexist( point,list )
%ifexist - Check if the point in the list
%   若传入的point在list(open或closed)中存在
%   函数将返回point在List中的Index(行)
%   若不存在，返回0
stdpointsize = [1,2];
    if isequal(size(point),stdpointsize) && ~isempty(list)
        loc = find(list(:,1) == point(1) & list (:,2) == point(2));
        if isempty(loc)
            loc = 0;
        end
    elseif ~isequal(size(point),stdpointsize)
        error('point size incorrect');
    elseif isempty(list)
        loc = 0;
    end
end

