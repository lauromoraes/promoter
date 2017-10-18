classdef Database
    %DATABASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        root_path
        pos_db
        neg_db
    end
    
    methods
        function obj = Database(obj, candidate)
            obj = setup_databases(obj, candidate);
        end
        
        function obj = setup_databases(obj, candidate)
            
            pos_dinucs = {};
            neg_dinucs = {};
            for i = 1:38
                if candidate.dinuc(1,i) == 1
                    f_name = fullfile('.', 'data', 'pos', sprintf('pos-di-%02d.dat', i) );
                    pos_dinucs = {pos_dinucs; f_name};
                    f_name = fullfile('.', 'data', 'neg', sprintf('neg-di-%02d.dat', i) );
                    neg_dinucs = {neg_dinucs; f_name};
                end
            end
            
            pos_trinucs = {};
            neg_trinucs = {};
            for i = 1:12
                if candidate.trinuc(1,i) == 1
                    f_name = fullfile('.', 'data', 'pos', sprintf('pos-tri-%02d.dat', i) );
                    pos_trinucs = {pos_dinucs; f_name};
                    f_name = fullfile('.', 'data', 'neg', sprintf('neg-tri-%02d.dat', i) );
                    neg_trinucs = {neg_dinucs; f_name};
                end
            end
            
            obj.pos_db = datastore( {pos_dinucs; pos_trinucs} );
            obj.neg_db = datastore( {neg_dinucs; neg_trinucs} );

        end
    end
    
end

