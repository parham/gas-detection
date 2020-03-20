
%% Description
% @author Parham Nooralishahi
% @email parham.nooralishahi@gmail.com
% @email parham.nooralishahi.1@ulaval.ca
% @organization Laval University - TORNGATS
% @date 2020 March
% @version 1.0
%

function [st] = props2struct(props)
%PROPS2STRUCT Convert Properties array to MATLAB structure
    propsArr = props(~cellfun('isempty',props));
    st = {};
    if ~isempty(propsArr) && mod(length(propsArr),2) == 0
        for index=1:2:length(propsArr)
            key = propsArr{index};
            value = propsArr{index+1};
            if ~isfield(st, key)
                st.(key) = value;
            end
        end
    end
end

