
%%
% 
% *developed by*: Parham Nooralishahi
% *email*: parham.nooralishahi@gmail.com
% *organization*: Laval Université
% 

classdef (Abstract) AbstractDataSource
    %ABSTRACTDATASOURCE Abstract data source is the origin class for all data handlers
    
    methods
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

