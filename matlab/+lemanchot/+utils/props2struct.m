function [st] = props2struct(propsArr)
%PROPS2STRUCT Convert Properties array to MATLAB structure

if isempty(propsArr) || mod(length(propsArr),2) ~= 0
    error('The properties array is empty or its length is not even');
end

st = {};
for index=1:2:length(propsArr)
    key = propsArr{index};
    value = propsArr{index+1};
    st.(key) = value;
end

end

