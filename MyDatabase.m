classdef MyDatabase
    %DATABASE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        root_path
        pos_db
        neg_db
        di_prop_names
        tri_prop_names
        max_samples
        dbNames
        selectedDB
    end
    
    methods
        function self = MyDatabase(maxs)
            self = set_props_names(self);
            if nargin < 1
                self.max_samples = -1;
            else
                self.max_samples = maxs;
            end
            self.dbNames = self.getDBsNames();
            self.selectedDB = 2;
        end
        
        function self = set_props_names(self)
            self.di_prop_names = {
                'Base stacking';
                'Protein induced deformability';
                'B-DNA twist';
                'Dinucleotide GC Content';
                'A-philicity';
                'Propeller twist';
                'Duplex stability:(freeenergy)';
                'Duplex tability(disruptenergy)';
                'DNA denaturation';
                'Bending stiffness';
                'Protein DNA twist';
                'Stabilising energy of Z-DNA';
                'Aida_BA_transition';
                'Breslauer_dG';
                'Breslauer_dH';
                'Breslauer_dS';
                'Electron_interaction';
                'Hartman_trans_free_energy';
                'Helix-Coil_transition';
                'Ivanov_BA_transition';
                'Lisser_BZ_transition';
                'Polar_interaction';
                'SantaLucia_dG';
                'SantaLucia_dH';
                'SantaLucia_dS';
                'Sarai_flexibility';
                'Stability';
                'Stacking_energy';
                'Sugimoto_dG';
                'Sugimoto_dH';
                'Sugimoto_dS';
                'Watson-Crick_interaction';
                'Twist';
                'Tilt';
                'Roll';
                'Shift';
                'Slide';
                'Rise'
            };
            self.tri_prop_names = {
                'Bendability (DNAse)';
                'Bendability (consensus)';
                'Trinucleotide GC Content';
                'Nucleosome positioning';
                'Consensus_roll';
                'Consensus-Rigid';
                'Dnase I';
                'Dnase I-Rigid';
                'MW-Daltons';
                'MW-kg';
                'Nucleosome';
                'Nucleosome-Rigid'
            };
        end
        
        function dbNames = getDBsNames(~)
            dbNames = {
                'Arabidopsis_tata';
                'Arabidopsis_non_tata';
                'Bacillus';
                'Ecoli';
                'Human';
                'Mouse_non_tata';
                'Mouse_tata'
            };
        end
        
        function [pos, neg] = getAllDBNames(self)
            pos_dinucs = {};
            neg_dinucs = {};
            dbName = self.dbNames{self.selectedDB};
            cont = 1;
            for i = 1:38
                f_name = fullfile('.', 'data', dbName, sprintf('pos-di-%02d.dat', i) );
                pos_dinucs{cont} = f_name;
                f_name = fullfile('.', 'data', dbName, sprintf('neg-di-%02d.dat', i) );
                neg_dinucs{cont} = f_name;
                cont = cont + 1;
            end
            
            pos_trinucs = {};
            neg_trinucs = {};
            cont = 1;
            for i = 1:12
                f_name = fullfile('.', 'data', dbName, sprintf('pos-tri-%02d.dat', i) );
                pos_trinucs{cont} = f_name;
                f_name = fullfile('.', 'data', dbName, sprintf('neg-tri-%02d.dat', i) );
                neg_trinucs{cont} = f_name;
                cont = cont + 1;
            end
            
            pos = {pos_dinucs; pos_trinucs};
            neg = {neg_dinucs; neg_trinucs};
        end
        
        function [pos, neg] = getSelectedDBsNames(self, Candidate)
            pos_dinucs = {};
            neg_dinucs = {};
            dbName = self.dbNames{self.selectedDB};
            cont = 1;
            for i = 1:38
                if Candidate.dinuc(1,i) == 1
                    f_name = fullfile('.', 'data', dbName, sprintf('pos-di-%02d.dat', i) );
                    pos_dinucs{cont} = f_name;
                    f_name = fullfile('.', 'data', dbName, sprintf('neg-di-%02d.dat', i) );
                    neg_dinucs{cont} = f_name;
                    cont = cont + 1;
                end
            end
            
            pos_trinucs = {};
            neg_trinucs = {};
            cont = 1;
            for i = 1:12
                if Candidate.trinuc(1,i) == 1
                    f_name = fullfile('.', 'data', dbName, sprintf('pos-tri-%02d.dat', i) );
                    pos_trinucs{cont} = f_name;
                    f_name = fullfile('.', 'data', dbName, sprintf('neg-tri-%02d.dat', i) );
                    neg_trinucs{cont} = f_name;
                    cont = cont + 1;
                end
            end
            
            pos = {pos_dinucs; pos_trinucs};
            neg = {neg_dinucs; neg_trinucs};
        end
        
        function [n_rows, n_cols] = estimate_features_lenght(self, data)
            n_cols = (size(data{1},2) * 72) + (size(data{2},2) * 71);
            n_rows = self.max_samples;
        end
        
        function features = concat_features(self, data, startCol, endCol)
            pos = 1;
            
            startCol = startCol-1;
            endCol = endCol-1;
            if self.max_samples == -1              
                endRow = size( csvread(  data{1}{1,1} ), 1)-1;                
            else
                endRow = self.max_samples-1;
            end
            
            nCols = (endCol - startCol + 1) * (size(data{1},2) + size(data{2},2));
            
            features = zeros(endRow+1, nCols);
            
            
            for i = 1:size(data,1)
                for j = 1:size(data{i},2)
%                     txt = sprintf('Reading data file (%s)', data{i}{1,j} );
%                     disp( txt );
                    values = csvread(  data{i}{1,j}, 0, startCol, [0, startCol, endRow, endCol] );
                    n_cols = size(values, 2);
                    features( :, pos:(pos+n_cols-1) ) = values(:,:);
                    pos = pos+n_cols;
                end
            end
        end
        
        function [X, Y] = setup_database(self, solution)
            if nargin == 1
                [pos, neg] = self.getAllDBNames();
                startCol = 160;
                endCol = 210;
            else
                [pos, neg] = self.getSelectedDBsNames(solution);
                [startCol, endCol] = solution.getOffsets();
            end

           % POSITIVE data
           pos = self.concat_features(pos, startCol, endCol);
           
           % NEGATIVE data
           neg = self.concat_features(neg, startCol, endCol);
           
%            disp( sprintf('Pos: %d | Neg: %d | Features: %d', size(pos,1), size(neg,1), size(neg,2)) );
           
           solution.length = size(pos,2);
           
           X = [pos; neg];
           Y = [ones(size(pos,1),1); zeros(size(neg,1),1)];
        end
    end
    
end

