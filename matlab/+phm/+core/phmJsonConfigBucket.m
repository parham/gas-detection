classdef phmJsonConfigBucket
    %PHMJSONCONFIGBUCKET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        configBucket
    end
    
    methods
        function obj = phmJsonConfigBucket(jsonPath)
            obj.configBucket = struct();
            if nargin > 0
                if ~isfile(jsonPath)
                    error('The determined config file does not exist: %s', jsonPath);
                end
                try
                    txt = fileread(jsonPath);
                    obj.configBucket = jsondecode(txt);
                catch
                    error('The determined config file is invalid: %s', jsonPath);
                end
                % Add Information section
                infost = struct;
                infost.author = 'Parham Nooralishahi';
                infost.email = 'parham.nooralishahi@gmail.com';
                infost.org_email = 'parham.nooralishahi.1@ulaval.ca';
                infost.organization = 'Laval University';
                obj.configBucket.info = infost;
            end
        end
        
        function config = getConfig(obj, section)
            if isempty(obj.configBucket)
                error('Configuration bucket does not initialized!');
            end
            config = [];
            if isfield(obj.configBucket, section)
                config = obj.configBucket.(section);
            end
        end
    end
    
    methods(Access = private)
        function [] = print_info(obj)
            %PRINT_INFO Prints the info section of the yaml configuration 
            %   Detailed explanation goes here
            
            disp('');
            disp('<strong>******************************</strong>');
            if isfield(config,'info')
                info = obj.configBucket.info;
                fields = fieldnames(info);
                for i = 1:length(fields)
                    disp(['<strong>', fields{i}, '</strong>:  ', info.(fields{i})]);
                end
            else
                disp('THERE IS NO AVAILABLE INFO');
            end
            disp('<strong>******************************</strong>');
            disp('');
        end
    end
end

